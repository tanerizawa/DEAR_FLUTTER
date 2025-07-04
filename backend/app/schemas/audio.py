# backend/app/schemas/audio.py

from pydantic import BaseModel, ConfigDict

class AudioTrackBase(BaseModel):
    title: str
    youtube_id: str
    artist: str | None = None
    cover_url: str | None = None
    # --- TAMBAHAN BARU: Field untuk URL audio ---
    stream_url: str | None = None

class AudioTrackCreate(AudioTrackBase):
    pass

class AudioTrackUpdate(AudioTrackBase):
    pass

class AudioTrack(AudioTrackBase):
    id: int
    model_config = ConfigDict(from_attributes=True)