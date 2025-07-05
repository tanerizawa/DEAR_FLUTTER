# backend/app/core/response_handler.py

import json
from typing import Any, Optional
from fastapi import Response
from fastapi.responses import JSONResponse, StreamingResponse
import structlog
import gzip
import io

logger = structlog.get_logger(__name__)

class SafeResponseHandler:
    """Handle responses safely to prevent Content-Length mismatch"""
    
    @staticmethod
    def create_json_response(
        data: Any, 
        status_code: int = 200,
        compress: bool = True,
        max_size_mb: float = 10.0
    ) -> Response:
        """Create JSON response with proper content handling"""
        
        try:
            # Serialize data
            json_str = json.dumps(data, ensure_ascii=False, separators=(',', ':'))
            json_bytes = json_str.encode('utf-8')
            
            # Check size
            size_mb = len(json_bytes) / (1024 * 1024)
            if size_mb > max_size_mb:
                logger.warning("response_handler:large_response", 
                              size_mb=size_mb, max_size_mb=max_size_mb)
                # Truncate or paginate large responses
                return SafeResponseHandler._handle_large_response(data, status_code)
            
            headers = {
                'Content-Type': 'application/json; charset=utf-8'
            }
            
            # Compress if beneficial and requested
            if compress and len(json_bytes) > 1024:  # Only compress if > 1KB
                try:
                    compressed = gzip.compress(json_bytes)
                    if len(compressed) < len(json_bytes) * 0.9:  # Only if 10%+ reduction
                        headers['Content-Encoding'] = 'gzip'
                        headers['Content-Length'] = str(len(compressed))
                        return Response(
                            content=compressed,
                            status_code=status_code,
                            headers=headers
                        )
                except Exception as e:
                    logger.warning("response_handler:compression_failed", error=str(e))
            
            # Return uncompressed
            headers['Content-Length'] = str(len(json_bytes))
            return Response(
                content=json_bytes,
                status_code=status_code,
                headers=headers
            )
            
        except Exception as e:
            logger.error("response_handler:serialization_error", error=str(e))
            return JSONResponse(
                content={"error": "Internal server error", "code": "SERIALIZATION_ERROR"},
                status_code=500
            )
    
    @staticmethod
    def _handle_large_response(data: Any, status_code: int) -> Response:
        """Handle large responses by streaming or truncation"""
        
        # If it's a list, implement pagination
        if isinstance(data, list):
            # Return first 100 items with pagination info
            truncated_data = {
                "items": data[:100],
                "total": len(data),
                "truncated": True,
                "message": "Response was truncated due to size. Use pagination for full results."
            }
            return SafeResponseHandler.create_json_response(
                truncated_data, status_code, compress=True, max_size_mb=float('inf')
            )
        
        # For other types, return error
        return JSONResponse(
            content={
                "error": "Response too large", 
                "code": "RESPONSE_TOO_LARGE",
                "message": "The response size exceeds limits. Please refine your request."
            },
            status_code=413
        )
    
    @staticmethod
    def create_streaming_response(
        data_generator,
        media_type: str = "application/json"
    ) -> StreamingResponse:
        """Create streaming response for large data"""
        
        async def generate():
            try:
                chunk_size = 8192  # 8KB chunks
                buffer = io.BytesIO()
                
                async for item in data_generator:
                    if isinstance(item, str):
                        chunk = item.encode('utf-8')
                    elif isinstance(item, bytes):
                        chunk = item
                    else:
                        chunk = json.dumps(item).encode('utf-8')
                    
                    buffer.write(chunk)
                    
                    # Yield when buffer is full
                    if buffer.tell() >= chunk_size:
                        buffer.seek(0)
                        yield buffer.read()
                        buffer = io.BytesIO()
                
                # Yield remaining data
                if buffer.tell() > 0:
                    buffer.seek(0)
                    yield buffer.read()
                    
            except Exception as e:
                logger.error("response_handler:streaming_error", error=str(e))
                error_response = json.dumps({
                    "error": "Streaming error",
                    "code": "STREAMING_ERROR"
                }).encode('utf-8')
                yield error_response
        
        return StreamingResponse(
            generate(),
            media_type=media_type,
            headers={
                'Cache-Control': 'no-cache',
                'Connection': 'keep-alive'
            }
        )
    
    @staticmethod
    def create_error_response(
        message: str,
        code: str = "UNKNOWN_ERROR", 
        status_code: int = 500,
        details: Optional[dict] = None
    ) -> JSONResponse:
        """Create standardized error response"""
        
        error_data = {
            "error": message,
            "code": code,
            "timestamp": logger.info("response_handler:error_response", 
                                   code=code, status=status_code)
        }
        
        if details:
            error_data["details"] = details
        
        return JSONResponse(
            content=error_data,
            status_code=status_code,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )

class ResponseHandlerMiddleware:
    """Middleware to handle response content-length issues"""
    
    def __init__(self, app):
        self.app = app
    
    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return
        
        # Wrap send to handle content-length
        async def wrapped_send(message):
            if message["type"] == "http.response.body":
                # Calculate and set proper content-length
                body = message.get("body", b"")
                if body:
                    message["body"] = body
                    # Let ASGI server handle content-length
                    if "more_body" not in message:
                        message["more_body"] = False
            
            await send(message)
        
        try:
            await self.app(scope, receive, wrapped_send)
        except Exception as e:
            logger.error("response_middleware_error", error=str(e))
            # Send error response
            await send({
                "type": "http.response.start",
                "status": 500,
                "headers": [[b"content-type", b"application/json"]],
            })
            error_body = json.dumps({"detail": "Internal server error"}).encode()
            await send({
                "type": "http.response.body",
                "body": error_body,
                "more_body": False,
            })
