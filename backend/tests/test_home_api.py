from app import crud, schemas
from app.state.music import set_latest_music


def test_home_feed_returns_latest_data(client):
    client_app, session_local = client
    db = session_local()
    try:
        crud.motivational_quote.create(
            db, obj_in=schemas.MotivationalQuoteCreate(text="old", author="a")
        )
        latest = crud.motivational_quote.create(
            db, obj_in=schemas.MotivationalQuoteCreate(text="new", author="b")
        )
    finally:
        db.close()

    set_latest_music(
        schemas.AudioTrack(id=1, title="t", youtube_id="y", artist="a", cover_url=None)
    )

    resp = client_app.get("/api/v1/home-feed")
    assert resp.status_code == 200
    data = resp.json()
    assert data["quote"]["id"] == latest.id
    assert data["music"]["title"] == "t"
    set_latest_music(None)


def test_home_feed_without_music(client):
    client_app, session_local = client
    db = session_local()
    try:
        quote = crud.motivational_quote.create(
            db, obj_in=schemas.MotivationalQuoteCreate(text="only", author="a")
        )
    finally:
        db.close()

    set_latest_music(None)

    resp = client_app.get("/api/v1/home-feed")
    assert resp.status_code == 200
    data = resp.json()
    assert data["quote"]["id"] == quote.id
    assert data["music"] is None
