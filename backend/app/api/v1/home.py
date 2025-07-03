from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import crud, schemas
from app.dependencies import get_db
from app.state.music import get_latest_music

router = APIRouter()


@router.get("/home-feed", response_model=schemas.HomeFeed)
def get_home_feed(db: Session = Depends(get_db)):
    """Return the latest quote and music recommendation."""
    return schemas.HomeFeed(
        quote=crud.motivational_quote.get_latest(db),
        music=get_latest_music(),
    )
