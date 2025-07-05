# backend/app/core/rate_limiter.py

import asyncio
import time
from typing import Dict, Optional
from datetime import datetime, timedelta
import structlog

logger = structlog.get_logger(__name__)

class RateLimiter:
    """Advanced rate limiter for YouTube API requests"""
    
    def __init__(self):
        self.requests: Dict[str, list] = {}
        self.youtube_limits = {
            'requests_per_minute': 100,  # Conservative limit
            'requests_per_hour': 1000,   # Daily quota management
            'concurrent_requests': 3,    # Max concurrent requests
        }
        self.active_requests = 0
        self.lock = asyncio.Lock()
        
    async def can_make_request(self, source: str = "youtube") -> bool:
        """Check if we can make a request within rate limits"""
        async with self.lock:
            now = time.time()
            
            # Initialize if not exists
            if source not in self.requests:
                self.requests[source] = []
            
            # Clean old requests (older than 1 hour)
            self.requests[source] = [
                req_time for req_time in self.requests[source] 
                if now - req_time < 3600
            ]
            
            # Check concurrent requests
            if self.active_requests >= self.youtube_limits['concurrent_requests']:
                logger.warning("rate_limiter:concurrent_limit_reached", 
                             active=self.active_requests)
                return False
            
            # Check per-minute limit
            recent_requests = [
                req_time for req_time in self.requests[source] 
                if now - req_time < 60
            ]
            
            if len(recent_requests) >= self.youtube_limits['requests_per_minute']:
                logger.warning("rate_limiter:minute_limit_reached", 
                             count=len(recent_requests))
                return False
            
            # Check hourly limit
            if len(self.requests[source]) >= self.youtube_limits['requests_per_hour']:
                logger.warning("rate_limiter:hour_limit_reached", 
                             count=len(self.requests[source]))
                return False
            
            return True
    
    async def record_request(self, source: str = "youtube"):
        """Record a new request"""
        async with self.lock:
            now = time.time()
            if source not in self.requests:
                self.requests[source] = []
            self.requests[source].append(now)
            self.active_requests += 1
            logger.info("rate_limiter:request_recorded", 
                       source=source, active=self.active_requests)
    
    async def complete_request(self, source: str = "youtube"):
        """Mark request as completed"""
        async with self.lock:
            self.active_requests = max(0, self.active_requests - 1)
            logger.info("rate_limiter:request_completed", 
                       source=source, active=self.active_requests)
    
    async def wait_for_available_slot(self, source: str = "youtube", max_wait: int = 300):
        """Wait until we can make a request (with timeout)"""
        start_time = time.time()
        
        while time.time() - start_time < max_wait:
            if await self.can_make_request(source):
                return True
            
            logger.info("rate_limiter:waiting_for_slot", 
                       source=source, waited=int(time.time() - start_time))
            await asyncio.sleep(5)  # Wait 5 seconds before retry
        
        logger.error("rate_limiter:timeout_waiting_for_slot", 
                    source=source, max_wait=max_wait)
        return False
    
    async def get_status(self) -> dict:
        """Get current rate limiter status"""
        now = time.time()
        status = {}
        
        for operation_type in ["youtube", "music_generation", "youtube_search"]:
            history = self.requests.get(operation_type, [])
            recent_requests = [t for t in history if now - t < 3600]  # Last hour
            
            status[operation_type] = {
                "can_make_request": await self.can_make_request(operation_type),
                "active_requests": self.get_active_count(operation_type),
                "requests_last_hour": len(recent_requests),
                "wait_time_seconds": self.get_wait_time(operation_type)
            }
        
        return status
    
    def get_active_count(self, operation_type: str) -> int:
        """Get number of active requests for operation type"""
        return len(self.requests.get(operation_type, []))
    
    def get_wait_time(self, source: str) -> int:
        """Estimate wait time before next request can be made"""
        # TODO: Implement wait time calculation based on request history
        return 0

# Global rate limiter instance
rate_limiter = RateLimiter()
