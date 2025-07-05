import subprocess
import json
from typing import Optional
import structlog
import time

log = structlog.get_logger(__name__)
YT_DLP_BIN = "yt-dlp"

# Fungsi ekstraksi audio YouTube yang playable di Indonesia (ID) dengan retry dan fallback
def extract_audio_url(youtube_url: str, max_retries: int = 3) -> Optional[dict]:
    """
    Extract audio URL from YouTube with multiple strategies for better success rate.
    """
    strategies = [
        # Strategy 1: Best audio quality with geo-bypass for Indonesia
        {
            "name": "high_quality_geo_bypass",
            "args": [
                "--geo-bypass",
                "--geo-bypass-country", "ID",
                "-f", "bestaudio[ext=m4a]/bestaudio[ext=webm]/bestaudio",
                "--no-playlist",
                "--skip-download",
                "--print-json",
            ]
        },
        # Strategy 2: More compatible format selection
        {
            "name": "compatible_format",
            "args": [
                "--geo-bypass",
                "--geo-bypass-country", "ID", 
                "-f", "140/251/250/249/bestaudio/best",
                "--no-playlist",
                "--skip-download",
                "--print-json",
            ]
        },
        # Strategy 3: Fallback without geo restrictions
        {
            "name": "no_geo_restrictions",
            "args": [
                "-f", "bestaudio[ext=m4a]/bestaudio/best",
                "--no-playlist", 
                "--skip-download",
                "--print-json",
            ]
        }
    ]
    
    for strategy in strategies:
        log.info("youtube_extractor:trying_strategy", strategy=strategy["name"], url=youtube_url)
        
        for attempt in range(max_retries):
            try:
                cmd = [YT_DLP_BIN] + strategy["args"] + [youtube_url]
                
                # Add timeout to prevent hanging
                result = subprocess.run(
                    cmd, 
                    capture_output=True, 
                    text=True, 
                    check=True,
                    timeout=60  # 60 second timeout
                )
                
                info = json.loads(result.stdout)
                audio_url = info.get("url")
                
                if audio_url:
                    log.info("youtube_extractor:success", 
                            strategy=strategy["name"], 
                            attempt=attempt + 1,
                            format_id=info.get("format_id"),
                            ext=info.get("ext"))
                    
                    return {
                        "audio_url": audio_url,
                        "duration": info.get("duration"),
                        "title": info.get("title"),
                        "artist": info.get("artist") or info.get("uploader"),
                        "thumbnail": info.get("thumbnail"),
                        "ext": info.get("ext"),
                        "format_id": info.get("format_id"),
                        "strategy_used": strategy["name"]
                    }
                else:
                    log.warn("youtube_extractor:no_url", strategy=strategy["name"], attempt=attempt + 1)
                    
            except subprocess.TimeoutExpired:
                log.error("youtube_extractor:timeout", strategy=strategy["name"], attempt=attempt + 1)
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)  # Exponential backoff
                    
            except subprocess.CalledProcessError as e:
                log.error("youtube_extractor:subprocess_error", 
                         strategy=strategy["name"], 
                         attempt=attempt + 1,
                         stderr=e.stderr[:200] if e.stderr else None)
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)
                    
            except json.JSONDecodeError as e:
                log.error("youtube_extractor:json_decode_error", 
                         strategy=strategy["name"], 
                         attempt=attempt + 1,
                         error=str(e))
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)
                    
            except Exception as e:
                log.error("youtube_extractor:unexpected_error", 
                         strategy=strategy["name"], 
                         attempt=attempt + 1,
                         error=str(e))
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)
    
    log.error("youtube_extractor:all_strategies_failed", url=youtube_url)
    return None
