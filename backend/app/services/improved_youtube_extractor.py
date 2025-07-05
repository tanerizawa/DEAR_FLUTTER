# backend/app/services/improved_youtube_extractor.py

import subprocess
import json
import asyncio
from typing import Optional, Dict, Any
import structlog
import time
from datetime import datetime, timedelta

# Import our rate limiter
from app.core.rate_limiter import rate_limiter
from app.core.request_queue import request_queue, RequestPriority

log = structlog.get_logger(__name__)
YT_DLP_BIN = "yt-dlp"

class ImprovedYouTubeExtractor:
    """
    Improved YouTube extractor with rate limiting, queueing, and better error handling
    """
    
    def __init__(self):
        self.cache: Dict[str, Dict[str, Any]] = {}
        self.cache_ttl = 3600  # 1 hour cache
        self.last_request_time = 0
        self.min_request_interval = 2  # Minimum 2 seconds between requests
        
    async def extract_audio_url(
        self, 
        youtube_url: str, 
        priority: RequestPriority = RequestPriority.NORMAL,
        use_cache: bool = True
    ) -> Optional[dict]:
        """
        Extract audio URL with rate limiting and caching
        """
        # Check cache first
        if use_cache and youtube_url in self.cache:
            cache_entry = self.cache[youtube_url]
            if time.time() - cache_entry['timestamp'] < self.cache_ttl:
                log.info("youtube_extractor:cache_hit", url=youtube_url)
                return cache_entry['data']
        
        # Check rate limits
        if not await rate_limiter.wait_for_available_slot("youtube", max_wait=300):
            log.error("youtube_extractor:rate_limit_timeout", url=youtube_url)
            raise Exception("Rate limit exceeded, please try again later")
        
        # Add to queue
        request_id = await request_queue.add_request(
            func=self._extract_audio_url_internal,
            args=(youtube_url,),
            priority=priority,
            timeout=180  # 3 minutes timeout
        )
        
        try:
            # Wait for result
            result = await request_queue.get_result(request_id, timeout=200)
            
            # Cache successful result
            if result and use_cache:
                self.cache[youtube_url] = {
                    'data': result,
                    'timestamp': time.time()
                }
                # Limit cache size
                if len(self.cache) > 100:
                    # Remove oldest entries
                    oldest_key = min(self.cache.keys(), 
                                   key=lambda k: self.cache[k]['timestamp'])
                    del self.cache[oldest_key]
            
            return result
            
        except Exception as e:
            log.error("youtube_extractor:queue_error", 
                     url=youtube_url, error=str(e))
            raise
    
    async def _extract_audio_url_internal(self, youtube_url: str) -> Optional[dict]:
        """
        Internal extraction method with improved error handling
        """
        await rate_limiter.record_request("youtube")
        
        try:
            # Enforce minimum interval between requests
            current_time = time.time()
            time_since_last = current_time - self.last_request_time
            if time_since_last < self.min_request_interval:
                await asyncio.sleep(self.min_request_interval - time_since_last)
            
            self.last_request_time = time.time()
            
            strategies = [
                {
                    "name": "high_quality_safe",
                    "args": [
                        "--no-warnings",
                        "--quiet",
                        "--geo-bypass",
                        "--geo-bypass-country", "ID",
                        "-f", "bestaudio[ext=m4a][filesize<50M]/bestaudio[ext=webm][filesize<50M]/bestaudio[filesize<50M]",
                        "--no-playlist",
                        "--skip-download", 
                        "--print-json",
                        "--socket-timeout", "30",
                        "--retries", "2"
                    ]
                },
                {
                    "name": "compatible_format_safe",
                    "args": [
                        "--no-warnings",
                        "--quiet",
                        "--geo-bypass",
                        "-f", "140[filesize<50M]/251[filesize<50M]/250[filesize<50M]/bestaudio[filesize<50M]",
                        "--no-playlist",
                        "--skip-download",
                        "--print-json",
                        "--socket-timeout", "30",
                        "--retries", "1"
                    ]
                },
                {
                    "name": "fallback_safe",
                    "args": [
                        "--no-warnings",
                        "--quiet",
                        "-f", "bestaudio[filesize<50M]/best[filesize<50M]",
                        "--no-playlist",
                        "--skip-download",
                        "--print-json",
                        "--socket-timeout", "20",
                        "--retries", "1"
                    ]
                }
            ]
            
            for strategy in strategies:
                log.info("youtube_extractor:trying_strategy", 
                        strategy=strategy["name"], url=youtube_url)
                
                try:
                    result = await self._execute_ytdlp(youtube_url, strategy)
                    if result:
                        return result
                        
                except Exception as e:
                    log.warning("youtube_extractor:strategy_failed", 
                              strategy=strategy["name"], 
                              error=str(e)[:200])
                    # Small delay between strategies
                    await asyncio.sleep(1)
            
            log.error("youtube_extractor:all_strategies_failed", url=youtube_url)
            return None
            
        finally:
            await rate_limiter.complete_request("youtube")
    
    async def _execute_ytdlp(self, youtube_url: str, strategy: dict) -> Optional[dict]:
        """
        Execute yt-dlp with timeout and error handling
        """
        cmd = [YT_DLP_BIN] + strategy["args"] + [youtube_url]
        
        # Run in executor to avoid blocking
        loop = asyncio.get_event_loop()
        
        try:
            result = await asyncio.wait_for(
                loop.run_in_executor(
                    None,
                    lambda: subprocess.run(
                        cmd,
                        capture_output=True,
                        text=True,
                        check=True,
                        timeout=45  # 45 second timeout per strategy
                    )
                ),
                timeout=50  # Additional asyncio timeout
            )
            
            if not result.stdout.strip():
                log.warning("youtube_extractor:empty_output", strategy=strategy["name"])
                return None
            
            info = json.loads(result.stdout)
            audio_url = info.get("url")
            
            if not audio_url:
                log.warning("youtube_extractor:no_audio_url", strategy=strategy["name"])
                return None
            
            # Validate extracted info
            duration = info.get("duration", 0)
            if duration > 600:  # Skip videos longer than 10 minutes
                log.warning("youtube_extractor:video_too_long", 
                           duration=duration, strategy=strategy["name"])
                return None
            
            log.info("youtube_extractor:success",
                    strategy=strategy["name"],
                    duration=duration,
                    format_id=info.get("format_id"),
                    ext=info.get("ext"))
            
            return {
                "audio_url": audio_url,
                "duration": duration,
                "title": info.get("title", "Unknown"),
                "artist": info.get("artist") or info.get("uploader", "Unknown"),
                "thumbnail": info.get("thumbnail"),
                "ext": info.get("ext"),
                "format_id": info.get("format_id"),
                "strategy_used": strategy["name"],
                "extracted_at": datetime.now().isoformat()
            }
            
        except asyncio.TimeoutError:
            log.error("youtube_extractor:timeout", strategy=strategy["name"])
            raise Exception(f"YouTube extraction timeout for strategy {strategy['name']}")
            
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr[:200] if e.stderr else "Unknown subprocess error"
            
            # Check for specific YouTube errors
            if "429" in error_msg or "Too Many Requests" in error_msg:
                log.error("youtube_extractor:rate_limited", strategy=strategy["name"])
                raise Exception("YouTube rate limit exceeded")
            elif "Sign in to confirm" in error_msg:
                log.error("youtube_extractor:bot_detection", strategy=strategy["name"])
                raise Exception("YouTube bot detection triggered")
            else:
                log.error("youtube_extractor:subprocess_error",
                         strategy=strategy["name"], error=error_msg)
                raise Exception(f"YouTube extraction failed: {error_msg}")
                
        except json.JSONDecodeError as e:
            log.error("youtube_extractor:json_error", 
                     strategy=strategy["name"], error=str(e))
            raise Exception("Invalid response from YouTube extractor")
            
        except Exception as e:
            log.error("youtube_extractor:unexpected_error",
                     strategy=strategy["name"], error=str(e))
            raise
    
    def get_cache_stats(self) -> dict:
        """Get cache statistics"""
        current_time = time.time()
        valid_entries = sum(
            1 for entry in self.cache.values()
            if current_time - entry['timestamp'] < self.cache_ttl
        )
        
        return {
            "total_entries": len(self.cache),
            "valid_entries": valid_entries,
            "cache_hit_rate": getattr(self, '_cache_hits', 0) / getattr(self, '_total_requests', 1),
            "ttl_seconds": self.cache_ttl
        }

# Global extractor instance
youtube_extractor = ImprovedYouTubeExtractor()
