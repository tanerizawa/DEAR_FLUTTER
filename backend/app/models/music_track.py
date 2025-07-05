# backend/app/models/music_track.py

from sqlalchemy import Column, Integer, String, DateTime, Text
import datetime
from app.db.base_class import Base

class MusicTrack(Base):
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    youtube_id = Column(String)
    artist = Column(String)
    # --- TAMBAHAN BARU: Kolom untuk menyimpan URL audio ---
    stream_url = Column(Text, nullable=True) # Gunakan Text untuk URL yang panjang
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    status = Column(String, default="done")  # status: generating, done, failed