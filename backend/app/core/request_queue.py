# backend/app/core/request_queue.py

import asyncio
import uuid
from typing import Optional, Callable, Any, Dict
from datetime import datetime
from enum import Enum
import structlog

logger = structlog.get_logger(__name__)

class RequestPriority(Enum):
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4

class QueuedRequest:
    def __init__(
        self, 
        request_id: str,
        func: Callable,
        args: tuple = (),
        kwargs: dict = None,
        priority: RequestPriority = RequestPriority.NORMAL,
        timeout: int = 300
    ):
        self.request_id = request_id
        self.func = func
        self.args = args
        self.kwargs = kwargs or {}
        self.priority = priority
        self.timeout = timeout
        self.created_at = datetime.now()
        self.future: Optional[asyncio.Future] = None

class RequestQueue:
    """Queue system for managing YouTube API requests"""
    
    def __init__(self, max_workers: int = 3):
        self.max_workers = max_workers
        self.queue: asyncio.PriorityQueue = asyncio.PriorityQueue()
        self.active_requests: Dict[str, QueuedRequest] = {}
        self.workers_running = 0
        self.stats = {
            'total_processed': 0,
            'total_failed': 0,
            'queue_size': 0
        }
        self._workers = []
        self._results = {}
        
    async def add_request(
        self, 
        func: Callable, 
        args: tuple = (), 
        kwargs: dict = None,
        priority: RequestPriority = RequestPriority.NORMAL,
        timeout: int = 300
    ) -> str:
        """Add request to queue and return request ID"""
        
        request_id = str(uuid.uuid4())
        request = QueuedRequest(
            request_id=request_id,
            func=func,
            args=args,
            kwargs=kwargs,
            priority=priority,
            timeout=timeout
        )
        
        # Create future for result
        request.future = asyncio.get_event_loop().create_future()
        
        # Add to queue (priority queue uses negative priority for correct ordering)
        await self.queue.put((-priority.value, request.created_at, request))
        
        self.stats['queue_size'] = self.queue.qsize()
        
        logger.info("request_queue:added", 
                   request_id=request_id, 
                   priority=priority.name,
                   queue_size=self.stats['queue_size'])
        
        # Start workers if not running
        await self._ensure_workers_running()
        
        return request_id
    
    async def get_result(self, request_id: str, timeout: int = 300) -> Any:
        """Wait for request result"""
        if request_id in self.active_requests:
            request = self.active_requests[request_id]
            if request.future:
                try:
                    result = await asyncio.wait_for(request.future, timeout=timeout)
                    return result
                except asyncio.TimeoutError:
                    logger.error("request_queue:timeout", request_id=request_id)
                    raise
                finally:
                    # Cleanup
                    if request_id in self.active_requests:
                        del self.active_requests[request_id]
        
        raise ValueError(f"Request {request_id} not found")
    
    async def _ensure_workers_running(self):
        """Ensure we have enough workers running"""
        while self.workers_running < self.max_workers:
            self.workers_running += 1
            worker = asyncio.create_task(self._worker(f"worker-{self.workers_running}"))
            self._workers.append(worker)
            logger.info("request_queue:worker_started", 
                       worker_id=self.workers_running,
                       total_workers=self.workers_running)
    
    async def _worker(self, worker_id: str):
        """Worker coroutine to process queue"""
        logger.info("request_queue:worker_starting", worker_id=worker_id)
        
        try:
            while True:
                try:
                    # Get request from queue (wait up to 60 seconds)
                    priority, created_at, request = await asyncio.wait_for(
                        self.queue.get(), timeout=60
                    )
                    
                    self.stats['queue_size'] = self.queue.qsize()
                    self.active_requests[request.request_id] = request
                    
                    logger.info("request_queue:processing", 
                               worker_id=worker_id,
                               request_id=request.request_id,
                               queue_size=self.stats['queue_size'])
                    
                    # Process request
                    try:
                        result = await asyncio.wait_for(
                            request.func(*request.args, **request.kwargs),
                            timeout=request.timeout
                        )
                        
                        # Set result
                        if request.future and not request.future.done():
                            request.future.set_result(result)
                        
                        self.stats['total_processed'] += 1
                        logger.info("request_queue:completed", 
                                   worker_id=worker_id,
                                   request_id=request.request_id)
                        
                    except Exception as e:
                        # Set exception
                        if request.future and not request.future.done():
                            request.future.set_exception(e)
                        
                        self.stats['total_failed'] += 1
                        logger.error("request_queue:failed", 
                                    worker_id=worker_id,
                                    request_id=request.request_id,
                                    error=str(e))
                    
                    finally:
                        # Mark task as done
                        self.queue.task_done()
                        
                        # Cleanup active request
                        if request.request_id in self.active_requests:
                            del self.active_requests[request.request_id]
                
                except asyncio.TimeoutError:
                    # No requests in queue for 60 seconds, keep worker alive
                    continue
                    
        except Exception as e:
            logger.error("request_queue:worker_error", 
                        worker_id=worker_id, error=str(e))
        finally:
            self.workers_running -= 1
            logger.info("request_queue:worker_stopped", 
                       worker_id=worker_id,
                       remaining_workers=self.workers_running)
    
    def get_stats(self) -> dict:
        """Get queue statistics"""
        return {
            **self.stats,
            'queue_size': self.queue.qsize(),
            'active_requests': len(self.active_requests),
            'workers_running': self.workers_running
        }
    
    def get_queue_size(self) -> int:
        """Get current queue size"""
        return self.queue.qsize()
    
    def get_active_workers(self) -> int:
        """Get number of active workers"""
        return len([w for w in self._workers if not w.done()])
    
    def get_failed_count(self) -> int:
        """Get number of failed requests (approximate)"""
        return len([result for result in self._results.values() 
                   if hasattr(result, 'exception') and result.exception()])
    
    def get_detailed_status(self) -> dict:
        """Get detailed status for monitoring"""
        return {
            "queue_size": self.get_queue_size(),
            "active_workers": self.get_active_workers(),
            "total_workers": len(self._workers),
            "completed_requests": len(self._results),
            "failed_requests": self.get_failed_count()
        }

# Global request queue instance
request_queue = RequestQueue(max_workers=3)
