# backend/app/services/playlist_cache_service.py

import datetime
from typing import List, Optional
from app.schemas.song import SongSuggestion

# Simple in-memory cache (replace with Redis/DB in production)
class PlaylistCacheService:
    _cache = {}

    @classmethod
    def get_playlist(cls, user_id: int, date: str, category: str) -> Optional[List[SongSuggestion]]:
        key = (user_id, date, category)
        return cls._cache.get(key)

    @classmethod
    def set_playlist(cls, user_id: int, date: str, category: str, playlist: List[SongSuggestion]):
        key = (user_id, date, category)
        cls._cache[key] = playlist

    @classmethod
    def clear_old(cls):
        # Optionally clear old cache entries
        pass
