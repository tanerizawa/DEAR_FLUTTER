# tests/test_music_api.py (Versi Perbaikan)

import pytest
from app import crud, models
from app.services.music_suggestion_service import MusicSuggestionService
from app.schemas.song import SongSuggestion
from app.core.config import settings


@pytest.mark.asyncio
async def test_music_suggestion_service_builds_prompt(monkeypatch):
    captured = {}

    async def fake_call(self, model, messages):
        captured["prompt"] = messages[0]["content"]
        return {"choices": [{"message": {"content": '{"title": "t", "artist": "a"}'}}]}

    monkeypatch.setattr(MusicSuggestionService, "_call_openrouter", fake_call)

    from datetime import datetime
    from app.schemas.user_profile import UserProfile

    service = MusicSuggestionService(settings=settings)
    profile = UserProfile(
        emerging_themes={"rock": 1.0},
        sentiment_trend="menurun",
        id=1,
        user_id=1,
        last_analyzed=datetime.utcnow(),
    )

    result = await service.suggest_song("happy", profile)

    assert result.title == "t"
    assert "happy" in captured["prompt"]
    assert "rock" in captured["prompt"]


def test_music_recommend_returns_suggestions(client, monkeypatch):
    captured = {}

    async def fake_suggest(self, mood, user_profile=None):
        captured["mood"] = mood
        captured["profile"] = user_profile
        return SongSuggestion(title="t", artist="a")

    monkeypatch.setattr(MusicSuggestionService, "suggest_song", fake_suggest)

    client_app, session_local = client
    db = session_local()
    try:
        user = db.query(models.User).first()
        crud.user_profile.create_with_user(db, user_id=user.id)
    finally:
        db.close()

    resp = client_app.get("/api/v1/music/recommend?mood=joy")
    assert resp.status_code == 200
    assert resp.json()["title"] == "t"
    assert captured["mood"] == "joy"
    assert captured["profile"] is not None
