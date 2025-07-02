# tests/test_music_api.py (Versi Perbaikan)

import pytest
from spotipy import Spotify
from app.core.config import settings
from app.api.v1 import music

from app import crud, models
from app.services.music_suggestion_service import MusicSuggestionService
from app.schemas.song import SongSuggestion


def test_music_endpoint_returns_list(client, monkeypatch):
    monkeypatch.setattr(settings, "SPOTIFY_CLIENT_ID", "id")
    monkeypatch.setattr(settings, "SPOTIFY_CLIENT_SECRET", "secret")
    monkeypatch.setattr(music, "spotify", None)

    # Return fake Spotify search payload
    def fake_search(self, q, type="track", limit=20):
        return {
            "tracks": {
                "items": [
                    {
                        "name": "Song",
                        "id": "abc123",
                        "artists": [{"name": "Artist"}],
                        "album": {"images": [{"url": "img"}]},
                    }
                ]
            }
        }

    # Kita tidak lagi memanggil get_song di backend, jadi mock ini bisa disederhanakan/dihapus.
    # Namun, kita biarkan untuk keamanan jika ada logika lain yang mungkin memanggilnya.
    monkeypatch.setattr(Spotify, "search", fake_search)

    client_app, _ = client
    resp = client_app.get("/api/v1/music?mood=test")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert data[0]["youtube_id"] == "abc123"
    assert data[0]["artist"] == "Artist"
    assert data[0]["cover_url"] == "img"


@pytest.mark.asyncio
async def test_music_suggestion_service_builds_prompt(monkeypatch):
    captured = {}

    async def fake_call(self, model, messages):
        captured["prompt"] = messages[0]["content"]
        return {
            "choices": [{"message": {"content": '[{"title": "t", "artist": "a"}]'}}]
        }

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

    result = await service.suggest_songs("happy", profile)

    assert result[0].title == "t"
    assert "happy" in captured["prompt"]
    assert "rock" in captured["prompt"]


def test_music_recommend_returns_suggestions(client, monkeypatch):
    captured = {}

    async def fake_suggest(self, mood, user_profile=None):
        captured["mood"] = mood
        captured["profile"] = user_profile
        return [SongSuggestion(title="t", artist="a")]

    monkeypatch.setattr(MusicSuggestionService, "suggest_songs", fake_suggest)

    client_app, session_local = client
    db = session_local()
    try:
        user = db.query(models.User).first()
        crud.user_profile.create_with_user(db, user_id=user.id)
    finally:
        db.close()

    resp = client_app.get("/api/v1/music/recommend?mood=joy")
    assert resp.status_code == 200
    assert resp.json()[0]["title"] == "t"
    assert captured["mood"] == "joy"
    assert captured["profile"] is not None


def test_music_endpoint_returns_503_without_credentials(client, monkeypatch):
    monkeypatch.setattr(settings, "SPOTIFY_CLIENT_ID", None)
    monkeypatch.setattr(settings, "SPOTIFY_CLIENT_SECRET", None)
    monkeypatch.setattr(music, "spotify", None)
    client_app, _ = client
    resp = client_app.get("/api/v1/music?mood=test")
    assert resp.status_code == 503
