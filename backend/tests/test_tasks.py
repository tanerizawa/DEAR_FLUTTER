# backend/tests/test_tasks.py

from datetime import datetime
import pytest
from app import models, crud
from app.schemas.song import SongSuggestion

# --- PERBAIKAN: Import layanan yang akan kita mock ---
from app.services.music_keyword_service import MusicKeywordService
from app.services.music_suggestion_service import MusicSuggestionService


@pytest.mark.asyncio
async def test_generate_music_recommendation_task_sets_track(monkeypatch, temp_session):
    db = temp_session()
    try:
        db.add(models.Journal(content="j1", created_at=datetime.utcnow()))
        db.commit()
    finally:
        db.close()

    # --- PERBAIKAN: setenv tidak diperlukan jika settings tidak digunakan ---
    # monkeypatch.setenv(...) bisa dihapus jika tidak ada pengaruh

    from app.tasks import generate_music_recommendation_task

    # --- PERBAIKAN: Mock __init__ agar tidak error saat dipanggil ---
    def fake_init(self, settings=None):
        """Mencegah __init__ asli berjalan dan menyebabkan AttributeError."""
        pass

    monkeypatch.setattr(MusicKeywordService, "__init__", fake_init)
    monkeypatch.setattr(MusicSuggestionService, "__init__", fake_init)
    # --- AKHIR PERBAIKAN ---

    monkeypatch.setattr("app.tasks.SessionLocal", temp_session)

    async def fake_keyword(self, journals):
        return "lofi"

    async def fake_suggest(self, mood, user_profile=None): # Tambahkan user_profile agar cocok
        return SongSuggestion(title="Song", artist="Artist")

    class DummySearch:
        def __init__(self, query, limit=1):
            self.query = query
            self.limit = limit

        def result(self):
            return {"result": [{"id": "ytid"}]}

    monkeypatch.setattr(MusicKeywordService, "generate_keyword", fake_keyword)
    monkeypatch.setattr(MusicSuggestionService, "suggest_song", fake_suggest)
    monkeypatch.setattr("youtubesearchpython.VideosSearch", DummySearch)

    await generate_music_recommendation_task()
    
    db = temp_session()
    try:
        track = crud.music_track.get_latest(db)
        assert track is not None  # <-- Ini seharusnya berhasil sekarang
        assert track.title == "Song"
        assert track.youtube_id == "ytid"
    finally:
        db.close()