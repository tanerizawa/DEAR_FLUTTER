from typing import Optional
from pydantic import BaseModel

from .motivational_quote import MotivationalQuote
from .audio import AudioTrack


class HomeFeed(BaseModel):
    """Combined content for the home screen."""

    quote: Optional[MotivationalQuote] = None
    music: Optional[AudioTrack] = None
    music_status: str = "done"
