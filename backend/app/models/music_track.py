from sqlalchemy import Column, Integer, String, DateTime
import datetime
from app.db.base_class import Base


class MusicTrack(Base):
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    youtube_id = Column(String)
    artist = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
