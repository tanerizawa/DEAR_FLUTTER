from app import crud, schemas
from app.api.v1 import home as home_api
from app.schemas.audio import AudioTrack


def _create_sample_data(db):
    crud.article.create(db, obj_in=schemas.ArticleCreate(title="a1", url="u1"))
    crud.article.create(db, obj_in=schemas.ArticleCreate(title="a2", url="u2"))
    crud.motivational_quote.create(
        db, obj_in=schemas.MotivationalQuoteCreate(text="q1", author="au")
    )


def test_home_feed_structure_and_ordering(client, monkeypatch):
    client_app, session_local = client
    db = session_local()
    try:
        _create_sample_data(db)
    finally:
        db.close()

    async def fake_recommend_music(**kwargs):
        return [AudioTrack(id=99, title="rec", youtube_id="y1")]

    monkeypatch.setattr(home_api, "recommend_music", fake_recommend_music)

    resp = client_app.get("/api/v1/home-feed")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 4
    assert all("type" in item and "data" in item for item in data)
    types = {item["type"] for item in data}
    assert types == {"article", "audio", "quote"}
