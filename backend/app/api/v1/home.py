from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import crud, schemas
from app.dependencies import get_db

router = APIRouter()


@router.get("/home-feed", response_model=schemas.HomeFeed)
def get_home_feed(db: Session = Depends(get_db)):
    """Return the latest quote and music recommendation."""
    return schemas.HomeFeed(
        quote=crud.motivational_quote.get_latest(db),
        music=crud.music_track.get_latest(db),
    )
