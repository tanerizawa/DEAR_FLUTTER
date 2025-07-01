from pydantic import BaseModel


class SongSuggestion(BaseModel):
    """Simple schema representing a song recommendation."""

    title: str
    artist: str
