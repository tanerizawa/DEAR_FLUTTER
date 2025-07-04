# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException
from sqlalchemy.orm import Session
import structlog
import asyncio # -> Import asyncio
from app.services.playlist_cache_service import PlaylistCacheService
import datetime

from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
from app.tasks import run_music_generation_flow
from youtubesearchpython import VideosSearch


router = APIRouter()
log = structlog.get_logger(__name__)

# ... (endpoint /recommend, /latest, dan /trigger-generation tetap sama) ...
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
def get_latest_music(
    db: Session = Depends(dependencies.get_db),
) -> schemas.AudioTrack | None:
    """Return the most recently generated music recommendation."""
    return crud.music_track.get_latest(db)


@router.post("/trigger-generation", status_code=202)
async def trigger_music_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    log.info("api:trigger_music_generation", user_id=current_user.id)
    background_tasks.add_task(run_music_generation_flow)
    return {"message": "Music recommendation generation process has been started."}