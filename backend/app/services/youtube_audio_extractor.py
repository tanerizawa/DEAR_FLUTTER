import subprocess
import json
from typing import Optional

YT_DLP_BIN = "yt-dlp"

# Fungsi ekstraksi audio YouTube yang playable di Indonesia (ID)
def extract_audio_url(youtube_url: str) -> Optional[dict]:
    cmd = [
        YT_DLP_BIN,
        # "--geo-bypass",  # removed strict geo-bypass for Indonesia
        # "--geo-bypass-country", "ID",  # removed strict geo-bypass for Indonesia
        "-f", "bestaudio[ext=m4a]/bestaudio/best",
        "--no-playlist",
        "--skip-download",
        "--print-json",
        youtube_url
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        info = json.loads(result.stdout)
        return {
            "audio_url": info.get("url"),
            "duration": info.get("duration"),
            "title": info.get("title"),
            "artist": info.get("artist") or info.get("uploader"),
            "thumbnail": info.get("thumbnail"),
            "ext": info.get("ext"),
            "format_id": info.get("format_id"),
        }
    except Exception as e:
        print(f"yt-dlp extraction error: {e}")
        return None
