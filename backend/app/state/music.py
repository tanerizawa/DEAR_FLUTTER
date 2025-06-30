from typing import Optional
from app.schemas.audio import AudioTrack

_latest_music: Optional[AudioTrack] = None


def set_latest_music(track: AudioTrack) -> None:
    """Store the latest music recommendation in memory."""
    global _latest_music
    _latest_music = track


def get_latest_music() -> Optional[AudioTrack]:
    """Return the most recent music recommendation if available."""
    return _latest_music
