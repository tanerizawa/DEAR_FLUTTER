from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import crud, models, schemas
from app.dependencies import get_db, get_current_user
from app.api.v1.music import recommend_music
from app.services.music_keyword_service import MusicKeywordService

router = APIRouter()


@router.get("/home-feed")
async def get_home_feed(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Return combined recent content for the home screen."""
    articles = crud.article.get_multi(db)
    quotes = crud.motivational_quote.get_multi(db)

    journals = crud.journal.get_multi_by_owner(
        db=db, owner_id=current_user.id, limit=5, order_by="created_at desc"
    )
    keyword = await MusicKeywordService().generate_keyword(journals)

    audio_tracks = await recommend_music(
        mood=keyword,
        db=db,
        current_user=current_user,
    )

    items = []
    for obj in articles:
        items.append({"type": "article", "data": schemas.Article.model_validate(obj)})
    for obj in audio_tracks:
        items.append({"type": "audio", "data": obj})
    for obj in quotes:
        items.append(
            {"type": "quote", "data": schemas.MotivationalQuote.model_validate(obj)}
        )

    items.sort(key=lambda x: x["data"].id, reverse=True)
    return items
