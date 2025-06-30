from pydantic import BaseModel, ConfigDict


class AudioTrackBase(BaseModel):
    title: str
    youtube_id: str


class AudioTrackCreate(AudioTrackBase):
    pass


class AudioTrackUpdate(AudioTrackBase):
    pass


class AudioTrack(AudioTrackBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
