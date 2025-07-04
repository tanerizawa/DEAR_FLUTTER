from app import crud, schemas


def test_articles_endpoint_empty_returns_list(client):
    client_app, _ = client
    resp = client_app.get("/api/v1/articles")
    assert resp.status_code == 200
    data = resp.json()
    assert data == []
    assert isinstance(data, list)


def test_articles_endpoint_returns_items(client):
    client_app, session_local = client
    db = session_local()
    try:
        crud.article.create(db, obj_in=schemas.ArticleCreate(title="t1", url="u1"))
        crud.article.create(db, obj_in=schemas.ArticleCreate(title="t2", url="u2"))
    finally:
        db.close()

    resp = client_app.get("/api/v1/articles")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert len(data) == 2


def test_quotes_endpoint_empty_returns_list(client):
    client_app, _ = client
    resp = client_app.get("/api/v1/quotes")
    assert resp.status_code == 200
    data = resp.json()
    assert data == []
    assert isinstance(data, list)


def test_quotes_endpoint_returns_items(client):
    client_app, session_local = client
    db = session_local()
    try:
        crud.motivational_quote.create(
            db,
            obj_in=schemas.MotivationalQuoteCreate(text="q1", author="anon"),
        )
        crud.motivational_quote.create(
            db,
            obj_in=schemas.MotivationalQuoteCreate(text="q2", author="anon"),
        )
    finally:
        db.close()

    resp = client_app.get("/api/v1/quotes")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert len(data) == 2


def test_quotes_latest_endpoint_returns_latest_item(client):
    client_app, session_local = client
    db = session_local()
    try:
        crud.motivational_quote.create(
            db,
            obj_in=schemas.MotivationalQuoteCreate(text="old", author="anon"),
        )
        crud.motivational_quote.create(
            db,
            obj_in=schemas.MotivationalQuoteCreate(text="new", author="anon"),
        )
    finally:
        db.close()

    resp = client_app.get("/api/v1/quotes/latest")
    assert resp.status_code == 200
    data = resp.json()
    assert data["text"] == "new"


def test_music_latest_endpoint_returns_none_by_default(client):
    client_app, _ = client
    resp = client_app.get("/api/v1/music/latest")
    assert resp.status_code == 200
    assert resp.json() is None


def test_music_latest_endpoint_returns_track(client):
    client_app, session_local = client
    db = session_local()
    try:
        crud.music_track.create(
            db,
            obj_in=schemas.AudioTrackCreate(
                title="t",
                youtube_id="y",
                artist="a",
                cover_url="c",
            ),
        )
    finally:
        db.close()
    resp = client_app.get("/api/v1/music/latest")
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "t"
    assert data["artist"] == "a"
    assert data["cover_url"] is None
