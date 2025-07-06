# backend/app/services/stealth_youtube_extractor.py

import subprocess
import json
import asyncio
import random
import time
from typing import Optional, Dict, Any, List
import structlog
from datetime import datetime, timedelta
import tempfile
import os
import hashlib
import uuid
from urllib.parse import urlencode, urlparse

try:
    import aiohttp
except ImportError:
    aiohttp = None

# Import our rate limiter
from app.core.rate_limiter import rate_limiter
from app.core.request_queue import request_queue, RequestPriority

log = structlog.get_logger(__name__)
YT_DLP_BIN = "yt-dlp"

class StealthYouTubeExtractor:
    """
    Stealth YouTube extractor with anti-bot detection techniques
    """
    
    def __init__(self):
        self.cache: Dict[str, Dict[str, Any]] = {}
        self.cache_ttl = 3600  # 1 hour cache
        self.last_request_time = 0
        self.min_request_interval = 3  # Minimum 3 seconds between requests
        self.user_agents = [
            # Chrome on Windows (latest)
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            # Chrome on macOS
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_2_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            # Firefox on Windows (latest)
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
            # Safari on macOS (latest)
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_2_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
            # Edge on Windows (latest)
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0",
            # Mobile user agents for diversity
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1",
            "Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36",
            # Opera
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 OPR/107.0.0.0"
        ]
        
        # Session fingerprinting resistance
        self.session_data = {
            "screen_resolutions": [
                {"width": 1920, "height": 1080},
                {"width": 1366, "height": 768},
                {"width": 1440, "height": 900},
                {"width": 1536, "height": 864},
                {"width": 1600, "height": 900},
                {"width": 2560, "height": 1440}
            ],
            "timezones": [
                "Asia/Jakarta", "Asia/Makassar", "Asia/Jayapura",
                "America/New_York", "America/Los_Angeles", "Europe/London"
            ],
            "languages": [
                "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7",
                "en-US,en;q=0.9,id;q=0.8",
                "id-ID,id;q=0.9,en;q=0.8"
            ]
        }
        
        self.bot_detection_count = 0
        self.adaptive_delay_multiplier = 1.0
        self.session_start_time = time.time()
        self.requests_this_session = 0
        self.max_requests_per_session = 50
        self.session_id = str(uuid.uuid4())
        self.browser_fingerprint = self._generate_browser_fingerprint()
        self.failed_strategies = set()
        
    def _generate_browser_fingerprint(self) -> Dict[str, Any]:
        """Generate a realistic browser fingerprint for enhanced stealth"""
        screen_resolutions = [
            {"width": 1920, "height": 1080}, {"width": 1366, "height": 768},
            {"width": 1536, "height": 864}, {"width": 1440, "height": 900},
            {"width": 1280, "height": 720}, {"width": 1600, "height": 900},
            {"width": 2560, "height": 1440}, {"width": 3840, "height": 2160}
        ]
        
        return {
            "screen_resolution": random.choice(screen_resolutions),
            "timezone_offset": random.choice([-480, -420, -360, -300, -240, -180, 0, 60, 120, 240, 480, 540]),
            "canvas_hash": hashlib.md5(str(random.random()).encode()).hexdigest()[:8],
            "webgl_vendor": random.choice([
                "Google Inc. (NVIDIA)", "Google Inc. (AMD)", "Google Inc. (Intel)",
                "Mozilla", "WebKit WebGL"
            ]),
            "platform": random.choice(["Win32", "MacIntel", "Linux x86_64"]),
            "cpu_cores": random.choice([2, 4, 6, 8, 12, 16]),
            "memory": random.choice([4, 8, 16, 32]),
            "device_pixel_ratio": random.choice([1, 1.25, 1.5, 2]),
            "touch_support": random.choice([True, False]),
            "webrtc_leak": self._generate_webrtc_leak()
        }
    
    def _generate_webrtc_leak(self) -> str:
        """Generate a fake WebRTC IP to simulate real browser behavior"""
        return f"192.168.{random.randint(1,255)}.{random.randint(1,255)}"
        
    def _get_random_user_agent(self) -> str:
        """Get random user agent to mimic different browsers"""
        return random.choice(self.user_agents)
    
    def _get_stealth_headers(self) -> Dict[str, str]:
        """Generate realistic browser headers with enhanced fingerprinting resistance"""
        language = random.choice(self.session_data["languages"])
        resolution = self.browser_fingerprint["screen_resolution"]
        
        headers = {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "Accept-Language": language,
            "Accept-Encoding": "gzip, deflate, br",
            "DNT": "1",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-User": "?1",
            "Cache-Control": "max-age=0",
            "Sec-Ch-Ua": '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            "Sec-Ch-Ua-Mobile": "?0" if not self.browser_fingerprint["touch_support"] else "?1",
            "Sec-Ch-Ua-Platform": f'"{self.browser_fingerprint["platform"]}"',
            "Sec-Ch-Viewport-Width": str(resolution["width"]),
            "Sec-Ch-Viewport-Height": str(resolution["height"]),
            "Sec-Ch-Dpr": str(self.browser_fingerprint["device_pixel_ratio"]),
            "X-Session-Id": self.session_id
        }
        
        # Add realistic timing headers
        if random.random() < 0.7:
            headers["Sec-Ch-Prefers-Color-Scheme"] = random.choice(["light", "dark"])
        
        # Add fingerprinting resistance headers
        if random.random() < 0.4:
            headers["X-Requested-With"] = "XMLHttpRequest"
        
        if random.random() < 0.3:
            headers["X-Forwarded-For"] = f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}"
        
        # Simulate browser memory and hardware info
        if random.random() < 0.2:
            headers["Sec-Ch-Ua-Arch"] = random.choice(['"x86"', '"arm"'])
            headers["Sec-Ch-Ua-Bitness"] = '"64"'
            headers["Sec-Ch-Ua-Model"] = '""'
        
        return headers
    
    def _create_stealth_config(self) -> str:
        """Create temporary config file with advanced stealth settings"""
        user_agent = self._get_random_user_agent()
        headers = self._get_stealth_headers()
        language = random.choice(self.session_data["languages"])
        
        # Randomize some parameters
        sleep_interval = random.uniform(1, 3)
        max_sleep = random.uniform(3, 6)
        socket_timeout = random.randint(45, 75)
        
        config_content = f"""
# Advanced stealth yt-dlp configuration
--user-agent "{user_agent}"
--referer "https://www.youtube.com/"
--add-header "Accept: {headers['Accept']}"
--add-header "Accept-Language: {language}"
--add-header "Accept-Encoding: {headers['Accept-Encoding']}"
--add-header "DNT: 1"
--add-header "Connection: keep-alive"
--add-header "Upgrade-Insecure-Requests: 1"
--add-header "Sec-Fetch-Dest: document"
--add-header "Sec-Fetch-Mode: navigate"
--add-header "Sec-Fetch-Site: cross-site"
--add-header "Sec-Fetch-User: ?1"
--add-header "Sec-Ch-Ua: {headers.get('Sec-Ch-Ua', '""')}"
--add-header "Sec-Ch-Ua-Mobile: ?0"
--add-header "Sec-Ch-Ua-Platform: \\"Windows\\""
--geo-bypass
--geo-bypass-country ID
--extractor-args "youtube:player_client=web,mweb;player_skip=webpage,configs"
--cookies-from-browser chrome
--sleep-interval {sleep_interval:.1f}
--max-sleep-interval {max_sleep:.1f}
--retries 3
--fragment-retries 3
--skip-unavailable-fragments
--abort-on-unavailable-fragment false
--socket-timeout {socket_timeout}
--no-warnings
--quiet
--no-check-certificate
--prefer-free-formats
--youtube-skip-dash-manifest
"""
        
        # Create temporary config file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.conf', delete=False) as f:
            f.write(config_content.strip())
            return f.name
    
    def _get_stealth_strategies(self) -> List[Dict[str, Any]]:
        """Get advanced stealth extraction strategies with enhanced anti-detection"""
        base_delay = random.uniform(1, 4)
        strategies = [
            {
                "name": "stealth_web_desktop_enhanced",
                "args": [
                    "--config-location", self._create_stealth_config(),
                    "--user-agent", self._get_random_user_agent(),
                    "-f", "bestaudio[ext=m4a][filesize<50M]/bestaudio[ext=webm][filesize<50M]/140/251/250/bestaudio[filesize<50M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(45, 75)),
                    "--sleep-requests", str(base_delay),
                    "--extractor-args", "youtube:player_skip=webpage,configs",
                    "--add-header", f"X-Session-Fingerprint: {self.browser_fingerprint['canvas_hash']}",
                    "--add-header", f"X-Client-Data: eyJoYXNGYXN0Q29ubmVjdGlvbiI6e30sImhhc0N1c3RvbURhdGEiOnt9fQ==",
                    "--add-header", "Sec-Ch-Ua-Full-Version-List: \"Not_A Brand\";v=\"8.0.0.0\", \"Chromium\";v=\"120.0.6099.109\", \"Google Chrome\";v=\"120.0.6099.109\"",
                ]
            },
            {
                "name": "stealth_mobile_ios_enhanced", 
                "args": [
                    "--user-agent", f"Mozilla/5.0 (iPhone; CPU iPhone OS {random.choice(['17_2_1', '17_1_2', '16_7_4'])} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1",
                    "--extractor-args", "youtube:player_client=ios,mweb",
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["US", "GB", "CA", "AU"]),
                    "-f", "140[filesize<50M]/251[filesize<50M]/250[filesize<50M]/bestaudio[filesize<50M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(30, 60)),
                    "--sleep-requests", str(base_delay + random.uniform(0.5, 2)),
                    "--retries", "2",
                    "--add-header", "X-YouTube-Client-Name: 5",
                    "--add-header", f"X-YouTube-Client-Version: {random.choice(['17.49.4', '17.48.3', '17.47.2'])}",
                    "--add-header", f"X-Device-ID: {str(uuid.uuid4())[:8]}"
                ]
            },
            {
                "name": "stealth_android_app_enhanced",
                "args": [
                    "--user-agent", f"com.google.android.youtube/{random.choice(['17.49.37', '17.48.36', '17.47.34'])} (Linux; U; Android {random.choice(['14', '13', '12'])}; {random.choice(['SM-G998B', 'Pixel-7', 'OnePlus-9'])}) gzip",
                    "--extractor-args", "youtube:player_client=android",
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["ID", "SG", "MY", "TH"]),
                    "-f", "140[filesize<50M]/251[filesize<50M]/best[height<=480][filesize<50M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(30, 60)),
                    "--sleep-requests", str(base_delay + random.uniform(0, 1.5)),
                    "--add-header", "X-YouTube-Client-Name: 3",
                    "--add-header", f"X-YouTube-Client-Version: {random.choice(['17.49.37', '17.48.36'])}",
                    "--add-header", f"X-Goog-Api-Key: AIza{hashlib.md5(str(random.random()).encode()).hexdigest()[:26]}"
                ]
            },
            {
                "name": "stealth_with_browser_cookies",
                "args": [
                    "--cookies-from-browser", random.choice(["chrome", "firefox", "safari", "edge"]),
                    "--user-agent", self._get_random_user_agent(),
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["ID", "US", "GB"]),
                    "-f", "bestaudio[ext=m4a][filesize<50M]/best[height<=480][filesize<50M]/best[filesize<50M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(60, 90)),
                    "--sleep-requests", str(base_delay + random.uniform(1, 3)),
                    "--extractor-args", "youtube:player_skip=webpage",
                    "--add-header", f"X-Browser-Session: {hashlib.md5((self.session_id + str(time.time())).encode()).hexdigest()[:16]}"
                ]
            },
            {
                "name": "stealth_tv_client_enhanced",
                "args": [
                    "--user-agent", f"Mozilla/5.0 (SMART-TV; Linux; Tizen {random.choice(['6.0', '5.5', '4.0'])}) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/{random.choice(['4.0', '3.4', '2.4'])} Chrome/76.0.3809.146 TV Safari/537.36",
                    "--extractor-args", "youtube:player_client=tv_embedded",
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["US", "GB", "DE"]),
                    "-f", "140[filesize<30M]/251[filesize<30M]/worst[filesize<30M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(45, 75)),
                    "--add-header", "X-YouTube-Client-Name: 85",
                    "--add-header", f"X-YouTube-Client-Version: {random.choice(['2.0', '1.9', '1.8'])}",
                    "--add-header", f"X-TV-Device-ID: {str(uuid.uuid4())[:12]}"
                ]
            },
            {
                "name": "stealth_music_client",
                "args": [
                    "--user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                    "--extractor-args", "youtube:player_client=web_music",
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["US", "ID", "MY"]),
                    "-f", "140[filesize<50M]/251[filesize<50M]/bestaudio[acodec^=opus]/bestaudio",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(40, 70)),
                    "--sleep-requests", str(base_delay + random.uniform(0.5, 2.5)),
                    "--add-header", "X-YouTube-Client-Name: 67",
                    "--add-header", "X-YouTube-Client-Version: 1.20231204.01.00",
                    "--add-header", "X-Goog-Visitor-Id: CgtVRzNzaGdPWUNhUSiW8fKmBg%3D%3D"
                ]
            },
            {
                "name": "stealth_incognito_mode",
                "args": [
                    "--user-agent", self._get_random_user_agent(),
                    "--geo-bypass",
                    "--geo-bypass-country", random.choice(["US", "CA", "AU", "NZ"]),
                    "-f", "bestaudio[ext=m4a][filesize<40M]/bestaudio[ext=webm][filesize<40M]/140/251/bestaudio",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", str(random.randint(35, 65)),
                    "--sleep-requests", str(base_delay + random.uniform(1, 3)),
                    "--no-check-certificate",
                    "--add-header", "Cache-Control: no-cache",
                    "--add-header", "Pragma: no-cache",
                    "--add-header", f"X-Incognito-Session: {hashlib.md5(str(random.random()).encode()).hexdigest()[:12]}",
                    "--add-header", "Sec-Fetch-Site: same-origin"
                ]
            },
            {
                "name": "fallback_minimal",
                "args": [
                    "--user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                    "--geo-bypass",
                    "-f", "worst[filesize<25M]/worstaudio[filesize<25M]",
                    "--no-playlist",
                    "--skip-download", 
                    "--print-json",
                    "--socket-timeout", "25",
                    "--no-check-certificate",
                    "--retries", "1"
                ]
            }
        ]
        
        # Filter out failed strategies
        available_strategies = [s for s in strategies if s["name"] not in self.failed_strategies]
        if not available_strategies:
            # Reset failed strategies if all have failed
            self.failed_strategies.clear()
            available_strategies = strategies
        
        return available_strategies
    
    async def extract_audio_url(
        self, 
        youtube_url: str, 
        priority: RequestPriority = RequestPriority.NORMAL,
        use_cache: bool = True,
        stealth_mode: bool = True,
        use_proxy: bool = False
    ) -> Optional[dict]:
        """
        Extract audio URL with advanced stealth techniques
        """
        # Check cache first
        if use_cache and youtube_url in self.cache:
            cache_entry = self.cache[youtube_url]
            if time.time() - cache_entry['timestamp'] < self.cache_ttl:
                log.info("stealth_youtube_extractor:cache_hit", url=youtube_url)
                return cache_entry['data']
        
        # Check rate limits with jitter
        jitter = random.uniform(0.5, 3.0)  # Increased jitter
        await asyncio.sleep(jitter)
        
        if not await rate_limiter.wait_for_available_slot("youtube", max_wait=300):
            log.error("stealth_youtube_extractor:rate_limit_timeout", url=youtube_url)
            raise Exception("Rate limit exceeded, please try again later")
        
        # Add to queue with stealth mode
        request_id = await request_queue.add_request(
            func=self._extract_audio_url_stealth if stealth_mode else self._extract_audio_url_basic,
            args=(youtube_url, use_proxy),
            priority=priority,
            timeout=300  # 5 minutes timeout for stealth mode
        )
        
        try:
            # Wait for result
            result = await request_queue.get_result(request_id, timeout=320)
            
            # Cache successful result
            if result and use_cache:
                self.cache[youtube_url] = {
                    'data': result,
                    'timestamp': time.time()
                }
                # Limit cache size
                if len(self.cache) > 100:
                    oldest_key = min(self.cache.keys(), 
                                   key=lambda k: self.cache[k]['timestamp'])
                    del self.cache[oldest_key]
            
            return result
            
        except Exception as e:
            log.error("stealth_youtube_extractor:queue_error", 
                     url=youtube_url, error=str(e))
            raise
    
    async def _extract_audio_url_stealth(self, youtube_url: str, use_proxy: bool = False) -> Optional[dict]:
        """
        Stealth extraction with advanced anti-bot techniques
        """
        await rate_limiter.record_request("youtube")
        
        try:
            # Enforce minimum interval with enhanced jitter
            current_time = time.time()
            time_since_last = current_time - self.last_request_time
            min_interval = self.min_request_interval + random.uniform(0, 4)
            
            if time_since_last < min_interval:
                await asyncio.sleep(min_interval - time_since_last)
            
            self.last_request_time = time.time()
            
            # Get proxy if requested
            proxy_args = []
            if use_proxy:
                from app.services.proxy_rotation_service import proxy_rotation_service
                proxy = proxy_rotation_service.get_next_proxy()
                if proxy:
                    proxy_args = ["--proxy", proxy.get("http", "")]
                    log.info("stealth_youtube_extractor:using_proxy", proxy=proxy.get("http", ""))
            
            # Try stealth strategies with enhanced rotation
            strategies = self._get_stealth_strategies()
            random.shuffle(strategies)  # Randomize strategy order
            
            for strategy in strategies:
                log.info("stealth_youtube_extractor:trying_strategy", 
                        strategy=strategy["name"], url=youtube_url)
                
                config_file = None
                try:
                    # Add proxy args if available
                    strategy_args = strategy["args"].copy()
                    if proxy_args:
                        strategy_args.extend(proxy_args)
                    
                    # Create temp config if needed
                    if strategy["name"] == "stealth_web_desktop":
                        config_file = self._create_stealth_config()
                        # Replace placeholder in args
                        for i, arg in enumerate(strategy_args):
                            if arg == self._create_stealth_config():
                                strategy_args[i] = config_file
                                break
                    
                    result = await self._try_extraction_strategy(youtube_url, {
                        "name": strategy["name"],
                        "args": strategy_args
                    })
                    
                    if result:
                        log.info("stealth_youtube_extractor:success",
                                strategy=strategy["name"],
                                title=result.get("title", "Unknown"),
                                duration=result.get("duration_string", "Unknown"))
                        return result
                    else:
                        log.warning("stealth_youtube_extractor:strategy_failed", 
                                   strategy=strategy["name"])
                        
                except Exception as e:
                    log.error("stealth_youtube_extractor:strategy_error",
                             strategy=strategy["name"], error=str(e))
                    
                    # Check if proxy failed
                    if use_proxy and proxy_args and ("proxy" in str(e).lower() or "connection" in str(e).lower()):
                        from app.services.proxy_rotation_service import proxy_rotation_service
                        proxy = {"http": proxy_args[1]} if len(proxy_args) > 1 else {}
                        if proxy:
                            proxy_rotation_service.mark_proxy_failed(proxy)
                finally:
                    # Clean up temp config file
                    if config_file and os.path.exists(config_file):
                        try:
                            os.unlink(config_file)
                        except:
                            pass
                
                # Enhanced delay between strategies with exponential backoff
                base_delay = random.uniform(2, 5)
                strategy_index = strategies.index(strategy)
                backoff_delay = base_delay * (1.5 ** strategy_index)
                await asyncio.sleep(min(backoff_delay, 15))  # Cap at 15 seconds
            
            log.error("stealth_youtube_extractor:all_strategies_failed", url=youtube_url)
            return None
            
        finally:
            await rate_limiter.complete_request("youtube")
    
    async def _extract_audio_url_basic(self, youtube_url: str) -> Optional[dict]:
        """Fallback to basic extraction without stealth"""
        # Fallback to original improved extractor logic
        from app.services.improved_youtube_extractor import ImprovedYouTubeExtractor
        basic_extractor = ImprovedYouTubeExtractor()
        return await basic_extractor._extract_audio_url_internal(youtube_url)
    
    async def _try_extraction_strategy(self, youtube_url: str, strategy: Dict) -> Optional[dict]:
        """Try a specific extraction strategy with enhanced anti-detection"""
        
        cmd = [YT_DLP_BIN] + strategy["args"] + [youtube_url]
        
        try:
            # Add enhanced random delay before execution
            pre_delay = random.uniform(1.0, 3.0)
            await asyncio.sleep(pre_delay)
            
            # Set environment variables for additional stealth
            env = os.environ.copy()
            env.update({
                'HTTP_PROXY': '',
                'HTTPS_PROXY': '',
                'NO_PROXY': '',
                'PYTHONHTTPSVERIFY': '0'
            })
            
            # Execute with timeout and enhanced error detection
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                env=env
            )
            
            try:
                # Dynamic timeout based on strategy
                timeout = 180 if "tv_client" in strategy["name"] else 120
                stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=timeout)
            except asyncio.TimeoutError:
                process.kill()
                log.error("stealth_youtube_extractor:timeout", 
                         strategy=strategy["name"], timeout=timeout)
                return None
            
            if process.returncode != 0:
                stderr_str = stderr.decode('utf-8', errors='ignore')
                
                # Enhanced error pattern detection
                bot_detection_patterns = [
                    "Sign in to confirm", "bot", "automated", "unusual traffic",
                    "verify you're human", "captcha", "suspicious activity",
                    "403", "blocked", "access denied"
                ]
                
                rate_limit_patterns = [
                    "429", "Too Many Requests", "rate limit", "quota exceeded",
                    "slow down", "try again later"
                ]
                
                if any(pattern in stderr_str.lower() for pattern in bot_detection_patterns):
                    log.error("stealth_youtube_extractor:bot_detection", 
                             strategy=strategy["name"], stderr=stderr_str[:300])
                    # Increase delay for future requests
                    self.min_request_interval = min(self.min_request_interval * 1.5, 10)
                elif any(pattern in stderr_str.lower() for pattern in rate_limit_patterns):
                    log.error("stealth_youtube_extractor:rate_limited", 
                             strategy=strategy["name"])
                    # Significant delay increase
                    self.min_request_interval = min(self.min_request_interval * 2, 15)
                    await asyncio.sleep(random.uniform(10, 20))
                else:
                    log.error("stealth_youtube_extractor:subprocess_error",
                             strategy=strategy["name"], 
                             stderr=stderr_str[:500])
                return None
            
            # Parse JSON output with enhanced validation
            try:
                output_str = stdout.decode('utf-8', errors='ignore')
                if not output_str.strip():
                    log.warning("stealth_youtube_extractor:empty_output", strategy=strategy["name"])
                    return None
                
                data = json.loads(output_str)
                audio_url = data.get("url")
                
                if not audio_url:
                    log.warning("stealth_youtube_extractor:no_audio_url", strategy=strategy["name"])
                    return None
                
                # Enhanced validation
                duration = data.get("duration", 0)
                filesize = data.get("filesize", 0)
                
                # Skip videos that are too long or too large
                if duration and duration > 3600:  # 1 hour
                    log.warning("stealth_youtube_extractor:video_too_long", 
                               strategy=strategy["name"], duration=duration)
                    return None
                
                if filesize and filesize > 100 * 1024 * 1024:  # 100MB
                    log.warning("stealth_youtube_extractor:file_too_large", 
                               strategy=strategy["name"], filesize=filesize)
                    return None
                
                # Validate URL accessibility
                if not await self._validate_audio_url(audio_url):
                    log.warning("stealth_youtube_extractor:url_not_accessible", 
                               strategy=strategy["name"])
                    return None
                
                # Success - reduce delay for future requests
                self.min_request_interval = max(self.min_request_interval * 0.9, 2)
                
                return {
                    "audio_url": audio_url,
                    "title": data.get("title", "Unknown"),
                    "duration": duration,
                    "duration_string": data.get("duration_string", "Unknown"),
                    "strategy_used": strategy["name"],
                    "filesize": filesize,
                    "format_id": data.get("format_id", ""),
                    "ext": data.get("ext", ""),
                    "quality": data.get("quality", "")
                }
                
            except json.JSONDecodeError as e:
                log.error("stealth_youtube_extractor:json_error", 
                         strategy=strategy["name"], error=str(e))
                return None
                
        except Exception as e:
            log.error("stealth_youtube_extractor:unexpected_error",
                     strategy=strategy["name"], error=str(e))
            return None
    
    async def _validate_audio_url(self, url: str) -> bool:
        """Validate that the audio URL is accessible"""
        try:
            if aiohttp:
                async with aiohttp.ClientSession() as session:
                    async with session.head(url, timeout=aiohttp.ClientTimeout(total=10)) as response:
                        return response.status == 200
            else:
                # Fallback: basic URL validation without actual request
                return url.startswith(('http://', 'https://')) and len(url) > 10
        except Exception:
            return True  # If we can't validate, assume it's OK

    def _should_rotate_session(self) -> bool:
        """Check if we should rotate session parameters"""
        session_duration = time.time() - self.session_start_time
        return (
            self.requests_this_session >= self.max_requests_per_session or
            session_duration > 3600 or  # 1 hour
            self.bot_detection_count > 3
        )
    
    def _rotate_session(self):
        """Rotate session parameters to avoid detection"""
        self.session_start_time = time.time()
        self.requests_this_session = 0
        self.bot_detection_count = 0
        self.adaptive_delay_multiplier = 1.0
        # Clear some cache to simulate new session
        if len(self.cache) > 20:
            keys_to_remove = list(self.cache.keys())[:10]
            for key in keys_to_remove:
                del self.cache[key]
        log.info("stealth_youtube_extractor:session_rotated")
    
    def _adapt_to_detection(self, detected: bool):
        """Adapt behavior based on bot detection"""
        if detected:
            self.bot_detection_count += 1
            self.adaptive_delay_multiplier *= 2.0
            self.min_request_interval = min(self.min_request_interval * 1.5, 20)
            log.warning("stealth_youtube_extractor:adapting_to_detection", 
                       count=self.bot_detection_count,
                       delay_multiplier=self.adaptive_delay_multiplier)
        else:
            # Gradually reduce delays on success
            self.adaptive_delay_multiplier = max(self.adaptive_delay_multiplier * 0.95, 1.0)
            self.min_request_interval = max(self.min_request_interval * 0.98, 2.0)

    def get_session_status(self) -> Dict[str, Any]:
        """Get detailed session status for monitoring"""
        session_duration = time.time() - self.session_start_time
        
        return {
            "session_id": self.session_id,
            "session_duration": session_duration,
            "requests_this_session": self.requests_this_session,
            "max_requests_per_session": self.max_requests_per_session,
            "bot_detection_count": self.bot_detection_count,
            "adaptive_delay_multiplier": self.adaptive_delay_multiplier,
            "min_request_interval": self.min_request_interval,
            "cache_size": len(self.cache),
            "failed_strategies": list(self.failed_strategies),
            "browser_fingerprint": {
                "platform": self.browser_fingerprint["platform"],
                "screen_resolution": self.browser_fingerprint["screen_resolution"],
                "canvas_hash": self.browser_fingerprint["canvas_hash"][:4] + "...",  # Partial for security
                "touch_support": self.browser_fingerprint["touch_support"]
            },
            "health_score": self._calculate_health_score(),
            "should_rotate": self._should_rotate_session()
        }
    
    def _calculate_health_score(self) -> float:
        """Calculate a health score for the current session (0-1, higher is better)"""
        base_score = 1.0
        
        # Reduce score based on bot detection
        detection_penalty = min(self.bot_detection_count * 0.2, 0.8)
        base_score -= detection_penalty
        
        # Reduce score based on failed strategies
        strategy_penalty = min(len(self.failed_strategies) * 0.1, 0.5)
        base_score -= strategy_penalty
        
        # Reduce score based on session age
        session_duration = time.time() - self.session_start_time
        age_penalty = min(session_duration / 7200, 0.3)  # 2 hours max penalty
        base_score -= age_penalty
        
        return max(base_score, 0.0)
    
    def rotate_session_parameters(self):
        """Manually rotate session parameters for enhanced stealth"""
        old_session_id = self.session_id
        self._rotate_session()
        self.browser_fingerprint = self._generate_browser_fingerprint()
        
        log.info("stealth_youtube_extractor:manual_session_rotation",
                old_session_id=old_session_id,
                new_session_id=self.session_id,
                new_platform=self.browser_fingerprint["platform"])
    
    async def intelligent_strategy_selection(self, youtube_url: str) -> List[Dict[str, Any]]:
        """Intelligently select strategies based on URL patterns and past performance"""
        strategies = self._get_stealth_strategies()
        
        # Analyze URL to determine optimal strategy preference
        url_hash = hashlib.md5(youtube_url.encode()).hexdigest()
        url_preference = int(url_hash[-1], 16) % 3  # 0, 1, or 2
        
        # Prioritize strategies based on URL pattern and session state
        if self.bot_detection_count > 2:
            # High detection - prefer mobile and TV clients
            priority_order = ["stealth_mobile_ios_enhanced", "stealth_android_app_enhanced", 
                            "stealth_tv_client_enhanced", "stealth_incognito_mode"]
        elif self.requests_this_session > 30:
            # High volume - prefer browser cookie strategies
            priority_order = ["stealth_with_browser_cookies", "stealth_web_desktop_enhanced", 
                            "stealth_music_client", "stealth_incognito_mode"]
        else:
            # Normal operation - prefer based on URL pattern
            if url_preference == 0:
                priority_order = ["stealth_web_desktop_enhanced", "stealth_music_client"]
            elif url_preference == 1:
                priority_order = ["stealth_mobile_ios_enhanced", "stealth_android_app_enhanced"]
            else:
                priority_order = ["stealth_with_browser_cookies", "stealth_tv_client_enhanced"]
        
        # Sort strategies by priority, then by past success
        sorted_strategies = []
        
        # Add prioritized strategies first
        for strategy_name in priority_order:
            strategy = next((s for s in strategies if s["name"] == strategy_name), None)
            if strategy and strategy["name"] not in self.failed_strategies:
                sorted_strategies.append(strategy)
        
        # Add remaining strategies
        for strategy in strategies:
            if strategy not in sorted_strategies and strategy["name"] not in self.failed_strategies:
                sorted_strategies.append(strategy)
        
        # Add fallback strategies at the end
        fallback_strategies = [s for s in strategies if "fallback" in s["name"]]
        for strategy in fallback_strategies:
            if strategy not in sorted_strategies:
                sorted_strategies.append(strategy)
        
        return sorted_strategies
    
    async def adaptive_extraction_with_intelligence(self, youtube_url: str, use_proxy: bool = False) -> Optional[dict]:
        """Enhanced extraction with intelligent strategy selection and adaptation"""
        await rate_limiter.record_request("youtube")
        
        try:
            # Check if session should be rotated
            if self._should_rotate_session():
                self.rotate_session_parameters()
            
            # Adaptive delay based on current state
            base_delay = self.min_request_interval * self.adaptive_delay_multiplier
            jitter = random.uniform(0.5, 2.0)
            await asyncio.sleep(base_delay + jitter)
            
            # Get intelligent strategy selection
            strategies = await self.intelligent_strategy_selection(youtube_url)
            
            # Try strategies with enhanced monitoring
            for i, strategy in enumerate(strategies):
                log.info("stealth_youtube_extractor:trying_intelligent_strategy",
                        strategy=strategy["name"],
                        attempt=i+1,
                        total_strategies=len(strategies),
                        health_score=self._calculate_health_score())
                
                start_time = time.time()
                try:
                    result = await self._try_extraction_strategy(youtube_url, strategy)
                    
                    if result:
                        extraction_time = time.time() - start_time
                        log.info("stealth_youtube_extractor:intelligent_success",
                                strategy=strategy["name"],
                                extraction_time=extraction_time,
                                title=result.get("title", "Unknown"))
                        
                        # Update session stats
                        self.requests_this_session += 1
                        self._adapt_to_detection(False)  # Mark as successful
                        
                        return result
                    else:
                        # Strategy failed, mark it and continue
                        self.failed_strategies.add(strategy["name"])
                        log.warning("stealth_youtube_extractor:intelligent_strategy_failed",
                                   strategy=strategy["name"])
                        
                except Exception as e:
                    error_str = str(e).lower()
                    self.failed_strategies.add(strategy["name"])
                    
                    # Detect specific error types for adaptive behavior
                    if any(pattern in error_str for pattern in ["bot", "captcha", "403", "blocked"]):
                        self._adapt_to_detection(True)
                        log.error("stealth_youtube_extractor:bot_detection_in_intelligent",
                                 strategy=strategy["name"], error=str(e))
                    elif any(pattern in error_str for pattern in ["429", "rate limit", "quota"]):
                        self.adaptive_delay_multiplier *= 2.0
                        log.error("stealth_youtube_extractor:rate_limit_in_intelligent",
                                 strategy=strategy["name"])
                        await asyncio.sleep(random.uniform(10, 30))  # Longer delay for rate limits
                    else:
                        log.error("stealth_youtube_extractor:strategy_error_in_intelligent",
                                 strategy=strategy["name"], error=str(e))
                
                # Progressive delay between strategies
                delay = min(2.0 * (i + 1), 15.0)
                await asyncio.sleep(delay)
            
            log.error("stealth_youtube_extractor:all_intelligent_strategies_failed", url=youtube_url)
            return None
            
        finally:
            await rate_limiter.complete_request("youtube")
    
    def clear_failed_strategies(self):
        """Clear failed strategies to allow retry"""
        old_count = len(self.failed_strategies)
        self.failed_strategies.clear()
        log.info("stealth_youtube_extractor:cleared_failed_strategies", count=old_count)
    
    def get_performance_metrics(self) -> Dict[str, Any]:
        """Get detailed performance metrics for monitoring"""
        session_duration = time.time() - self.session_start_time
        
        metrics = {
            "session_metrics": {
                "duration": session_duration,
                "requests_count": self.requests_this_session,
                "requests_per_hour": (self.requests_this_session / max(session_duration / 3600, 0.01)),
                "health_score": self._calculate_health_score()
            },
            "detection_metrics": {
                "bot_detection_count": self.bot_detection_count,
                "adaptive_delay_multiplier": self.adaptive_delay_multiplier,
                "min_request_interval": self.min_request_interval,
                "failed_strategies_count": len(self.failed_strategies)
            },
            "cache_metrics": {
                "cache_size": len(self.cache),
                "cache_hit_rate": getattr(self, 'cache_hits', 0) / max(self.requests_this_session, 1)
            },
            "fingerprint_info": {
                "session_id": self.session_id,
                "platform": self.browser_fingerprint["platform"],
                "screen_resolution": f"{self.browser_fingerprint['screen_resolution']['width']}x{self.browser_fingerprint['screen_resolution']['height']}",
                "canvas_hash_prefix": self.browser_fingerprint["canvas_hash"][:6]
            }
        }
        
        return metrics

# Global instance
stealth_youtube_extractor = StealthYouTubeExtractor()
