# backend/app/schemas/audio.py

from pydantic import BaseModel, ConfigDict

class AudioTrackBase(BaseModel):
    title: str
    youtube_id: str
    artist: str | None = None
    cover_url: str | None = None
    # --- TAMBAHAN BARU: Field untuk URL audio ---
    stream_url: str | None = None

    def model_dump(self, *args, **kwargs):
        d = super().model_dump(*args, **kwargs)
        for k in ['artist', 'cover_url', 'stream_url']:
            if d.get(k) == "":
                d[k] = None
        return d

class AudioTrackCreate(AudioTrackBase):
    pass

class AudioTrackUpdate(AudioTrackBase):
    pass

class AudioTrack(AudioTrackBase):
    id: int
    status: str = "done"
    model_config = ConfigDict(from_attributes=True)