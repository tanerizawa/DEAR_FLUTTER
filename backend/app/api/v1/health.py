# backend/app/api/v1/health.py

from fastapi import APIRouter
from typing import Dict, Any
import structlog
from app.core.rate_limiter import rate_limiter
from app.core.request_queue import request_queue

router = APIRouter()
log = structlog.get_logger(__name__)

@router.get("/health")
async def health_check() -> Dict[str, Any]:
    """Health check endpoint untuk monitoring"""
    try:
        # Check rate limiter status
        rate_limit_status = {
            "youtube_requests_available": await rate_limiter.can_make_request("youtube"),
            "active_requests": rate_limiter.get_active_count("youtube"),
            "rate_limit_history": len(rate_limiter._request_history.get("youtube", []))
        }
        
        # Check request queue status
        queue_status = {
            "pending_requests": request_queue.get_queue_size(),
            "active_workers": request_queue.get_active_workers(),
            "failed_requests": request_queue.get_failed_count()
        }
        
        return {
            "status": "healthy",
            "timestamp": "2025-01-06T21:43:00Z",
            "rate_limiter": rate_limit_status,
            "request_queue": queue_status,
            "version": "1.0.0"
        }
    except Exception as e:
        log.error("health_check_error", error=str(e))
        return {
            "status": "unhealthy",
            "error": str(e)
        }

@router.get("/health/detailed")
async def detailed_health_check() -> Dict[str, Any]:
    """Detailed health check untuk debugging"""
    try:
        detailed_info = {
            "rate_limiter_config": {
                "youtube_per_minute": 5,
                "youtube_per_hour": 30,
                "max_concurrent": 3
            },
            "queue_config": {
                "max_workers": 3,
                "max_queue_size": 100,
                "worker_timeout": 45
            },
            "system_info": {
                "worker_count": 3,
                "worker_timeout": 300
            }
        }
        
        return {
            "status": "healthy",
            "config": detailed_info,
            "rate_limiter": await rate_limiter.get_status(),
            "request_queue": request_queue.get_detailed_status()
        }
    except Exception as e:
        log.error("detailed_health_check_error", error=str(e))
        return {
            "status": "unhealthy",
            "error": str(e)
        }
