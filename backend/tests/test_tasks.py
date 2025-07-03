from datetime import datetime

import pytest
from app import models
from app.services.music_keyword_service import MusicKeywordService
from app.services.music_suggestion_service import MusicSuggestionService
from app.schemas.song import SongSuggestion
from app.state.music import get_latest_music


@pytest.mark.asyncio
async def test_generate_music_recommendation_task_sets_track(monkeypatch, temp_session):
    db = temp_session()
    try:
        db.add(models.Journal(content="j1", created_at=datetime.utcnow()))
        db.commit()
    finally:
        db.close()

    # Inject minimal settings so the services do not fail on import
    monkeypatch.setenv("DATABASE_URL", "sqlite:///./test.db")
    monkeypatch.setenv("CELERY_BROKER_URL", "redis://localhost")
    monkeypatch.setenv("CELERY_RESULT_BACKEND", "redis://localhost")
    monkeypatch.setenv("SECRET_KEY", "x")

    from app.tasks import generate_music_recommendation_task

    monkeypatch.setattr("app.tasks.SessionLocal", temp_session)

    async def fake_keyword(self, journals):
        return "lofi"

    async def fake_suggest(self, mood):
        return [SongSuggestion(title="Song", artist="Artist")]

    class DummySearch:
        def __init__(self, query, limit=1):
            self.query = query
            self.limit = limit

        def result(self):
            return {"result": [{"id": "ytid"}]}

    monkeypatch.setattr(MusicKeywordService, "generate_keyword", fake_keyword)
    monkeypatch.setattr(MusicSuggestionService, "suggest_songs", fake_suggest)
    monkeypatch.setattr("youtubesearchpython.VideosSearch", DummySearch)

    await generate_music_recommendation_task()
    track = get_latest_music()
    assert track is not None
    assert track.title == "Song"
    assert track.youtube_id == "ytid"
