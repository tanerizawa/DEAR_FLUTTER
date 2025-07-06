# backend/app/services/proxy_rotation_service.py

import random
import asyncio
import time
from typing import List, Optional, Dict, Set
import structlog

try:
    import aiohttp
except ImportError:
    aiohttp = None

log = structlog.get_logger(__name__)

class ProxyRotationService:
    """
    Enhanced service for rotating proxies to avoid IP-based detection
    """
    
    def __init__(self):
        self.proxies: List[Dict[str, str]] = []
        self.current_proxy_index = 0
        self.failed_proxies: Set[str] = set()
        self.proxy_health: Dict[str, Dict] = {}
        self.last_rotation_time = 0
        self.rotation_interval = 300  # 5 minutes
        
        # Load proxy configuration
        self._load_default_proxies()
    
    def _load_default_proxies(self):
        """Load default proxy configuration"""
        # In production, you should load these from environment variables or a secure config
        # For now, we'll use free/public proxies as examples
        self.proxies = [
            # Add your proxy list here
            # Example format:
            # {"http": "http://proxy1:port", "https": "https://proxy1:port", "location": "US"},
            # {"http": "http://proxy2:port", "https": "https://proxy2:port", "location": "EU"},
            # Note: Replace with actual working proxies in production
        ]
        
        # Initialize health tracking for each proxy
        for proxy in self.proxies:
            proxy_key = proxy.get("http", "")
            self.proxy_health[proxy_key] = {
                "failures": 0,
                "successes": 0,
                "last_used": 0,
                "response_time": 0,
                "location": proxy.get("location", "Unknown")
            }
    
    async def load_proxies_from_sources(self):
        """Load proxies from external sources (implement as needed)"""
        try:
            # You can implement loading from proxy services here
            # For example, ProxyMesh, SmartProxy, etc.
            log.info("proxy_rotation:loading_from_sources")
            
            # Example: Load from a proxy API
            # proxies = await self._fetch_from_proxy_api()
            # self.proxies.extend(proxies)
            
            log.info("proxy_rotation:loaded_proxies", count=len(self.proxies))
        except Exception as e:
            log.error("proxy_rotation:load_error", error=str(e))
    
    def get_next_proxy(self, preferred_location: Optional[str] = None) -> Optional[Dict[str, str]]:
        """Get next available proxy with optional location preference"""
        if not self.proxies:
            return None
        
        # Filter proxies by location if specified
        available_proxies = self.proxies
        if preferred_location:
            location_proxies = [p for p in self.proxies if p.get("location", "").upper() == preferred_location.upper()]
            if location_proxies:
                available_proxies = location_proxies
        
        # Sort by health score (fewer failures, better response time)
        available_proxies = sorted(available_proxies, key=lambda p: self._get_health_score(p))
        
        attempts = 0
        while attempts < len(available_proxies):
            proxy = available_proxies[self.current_proxy_index % len(available_proxies)]
            self.current_proxy_index = (self.current_proxy_index + 1) % len(available_proxies)
            
            proxy_key = proxy.get("http", "")
            
            # Skip recently failed proxies
            if proxy_key not in self.failed_proxies:
                # Update last used time
                if proxy_key in self.proxy_health:
                    self.proxy_health[proxy_key]["last_used"] = time.time()
                return proxy
            
            attempts += 1
        
        # All proxies failed recently, reset failed list and try again
        if self.failed_proxies:
            log.warning("proxy_rotation:all_proxies_failed_resetting", count=len(self.failed_proxies))
            self.failed_proxies.clear()
            if available_proxies:
                proxy = available_proxies[0]
                proxy_key = proxy.get("http", "")
                if proxy_key in self.proxy_health:
                    self.proxy_health[proxy_key]["last_used"] = time.time()
                return proxy
        
        return None
    
    def _get_health_score(self, proxy: Dict[str, str]) -> float:
        """Calculate health score for proxy (lower is better)"""
        proxy_key = proxy.get("http", "")
        if proxy_key not in self.proxy_health:
            return 0.5  # Neutral score for unknown proxies
        
        health = self.proxy_health[proxy_key]
        failure_rate = health["failures"] / max(health["failures"] + health["successes"], 1)
        response_penalty = min(health["response_time"] / 10.0, 1.0)  # Normalize response time
        recency_bonus = max(0, (time.time() - health["last_used"]) / 3600.0)  # Prefer less recently used
        
        return failure_rate + response_penalty - (recency_bonus * 0.1)
    
    def mark_proxy_failed(self, proxy: Dict[str, str]):
        """Mark proxy as failed and update health metrics"""
        proxy_key = proxy.get("http", "")
        self.failed_proxies.add(proxy_key)
        
        if proxy_key in self.proxy_health:
            self.proxy_health[proxy_key]["failures"] += 1
        
        log.warning("proxy_rotation:proxy_failed", 
                   proxy=proxy_key, 
                   total_failures=self.proxy_health.get(proxy_key, {}).get("failures", 0))
    
    def mark_proxy_success(self, proxy: Dict[str, str], response_time: float = 0):
        """Mark proxy as successful and update health metrics"""
        proxy_key = proxy.get("http", "")
        
        # Remove from failed list if present
        self.failed_proxies.discard(proxy_key)
        
        if proxy_key in self.proxy_health:
            self.proxy_health[proxy_key]["successes"] += 1
            self.proxy_health[proxy_key]["response_time"] = response_time
        
        log.debug("proxy_rotation:proxy_success", 
                 proxy=proxy_key,
                 response_time=response_time)
    
    async def test_proxy(self, proxy: Dict[str, str], timeout: int = 10) -> bool:
        """Test if proxy is working with enhanced validation"""
        if not aiohttp:
            return True  # Assume working if we can't test
        
        proxy_key = proxy.get("http", "")
        start_time = time.time()
        
        try:
            # Test with multiple endpoints for better validation
            test_urls = [
                "https://httpbin.org/ip",
                "https://api.ipify.org?format=json",
                "https://icanhazip.com"
            ]
            
            async with aiohttp.ClientSession() as session:
                for url in test_urls:
                    try:
                        async with session.get(
                            url,
                            proxy=proxy.get("http"),
                            timeout=aiohttp.ClientTimeout(total=timeout)
                        ) as response:
                            if response.status == 200:
                                response_time = time.time() - start_time
                                self.mark_proxy_success(proxy, response_time)
                                return True
                    except Exception:
                        continue
                        
        except Exception as e:
            log.debug("proxy_rotation:test_failed", proxy=proxy_key, error=str(e))
        
        self.mark_proxy_failed(proxy)
        return False
    
    async def test_all_proxies(self) -> Dict[str, bool]:
        """Test all proxies and return results"""
        if not self.proxies:
            return {}
        
        results = {}
        tasks = []
        
        for proxy in self.proxies:
            task = asyncio.create_task(self.test_proxy(proxy))
            tasks.append((proxy.get("http", ""), task))
        
        for proxy_key, task in tasks:
            try:
                result = await task
                results[proxy_key] = result
            except Exception as e:
                log.error("proxy_rotation:test_error", proxy=proxy_key, error=str(e))
                results[proxy_key] = False
        
        working_count = sum(1 for working in results.values() if working)
        log.info("proxy_rotation:test_complete", 
                total=len(results), 
                working=working_count)
        
        return results
    
    def should_rotate(self) -> bool:
        """Check if it's time to rotate proxies"""
        return time.time() - self.last_rotation_time > self.rotation_interval
    
    def force_rotation(self):
        """Force proxy rotation"""
        self.last_rotation_time = time.time()
        self.failed_proxies.clear()
        # Shuffle proxy order
        random.shuffle(self.proxies)
        self.current_proxy_index = 0
        log.info("proxy_rotation:forced_rotation")
    
    def get_proxy_stats(self) -> Dict:
        """Get proxy health statistics"""
        total_proxies = len(self.proxies)
        failed_proxies = len(self.failed_proxies)
        working_proxies = total_proxies - failed_proxies
        
        avg_response_time = 0
        if self.proxy_health:
            response_times = [h["response_time"] for h in self.proxy_health.values() if h["response_time"] > 0]
            if response_times:
                avg_response_time = sum(response_times) / len(response_times)
        
        return {
            "total_proxies": total_proxies,
            "working_proxies": working_proxies,
            "failed_proxies": failed_proxies,
            "failure_rate": failed_proxies / max(total_proxies, 1),
            "avg_response_time": avg_response_time,
            "last_rotation": self.last_rotation_time
        }

# Global instance
proxy_rotation_service = ProxyRotationService()
