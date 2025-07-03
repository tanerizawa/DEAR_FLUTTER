# backend/app/api/v1/music.py (Versi Final dengan Logika VideoID)

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
import structlog

from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
from app.state.music import get_latest_music as _get_latest_music

router = APIRouter()
log = structlog.get_logger(__name__)


@router.get("/recommend", response_model=schemas.SongSuggestion)
async def recommend_music(
    *,
    mood: str = Query(..., min_length=1),
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
    suggestion_service: MusicSuggestionService = Depends(),
):
    profile = crud.user_profile.get_by_user_id(db, user_id=current_user.id)
    return await suggestion_service.suggest_song(mood=mood, user_profile=profile)


@router.get("/latest", response_model=schemas.AudioTrack | None)
def get_latest_music() -> schemas.AudioTrack | None:
    """Return the most recently generated music recommendation."""
    return _get_latest_music()
