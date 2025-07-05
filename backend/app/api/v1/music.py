# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException, Body
from sqlalchemy.orm import Session
import structlog
import asyncio # -> Import asyncio
from app.services.playlist_cache_service import PlaylistCacheService
import datetime
from fastapi.responses import JSONResponse

from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
from app.tasks import run_music_generation_flow
from youtubesearchpython import VideosSearch
from app.services.youtube_audio_extractor import extract_audio_url


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
):
    """Return the most recently generated music recommendation."""
    track = crud.music_track.get_latest(db)
    # Filter: hanya return jika status bukan 'failed' dan field wajib valid
    if not track or track.status == 'failed' or not (track.id and track.title and track.youtube_id and track.stream_url):
        # Kembalikan 204 No Content agar frontend tahu tidak ada lagu valid
        return JSONResponse(status_code=204, content=None)
    return track


@router.post("/trigger-generation", status_code=202)
async def trigger_music_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    log.info("api:trigger_music_generation", user_id=current_user.id)
    background_tasks.add_task(run_music_generation_flow)
    return {"message": "Music recommendation generation process has been started."}


@router.post("/extract-audio")
def extract_audio(
    data: dict = Body(...)
):
    """Ekstrak audio YouTube yang playable di Indonesia (ID), hanya audio stream."""
    youtube_url = data.get("youtube_url")
    if not youtube_url:
        raise HTTPException(status_code=400, detail="youtube_url is required")
    result = extract_audio_url(youtube_url)
    if not result or not result.get("audio_url"):
        raise HTTPException(status_code=422, detail="Gagal ekstrak audio dari YouTube (region/geo-block atau format tidak tersedia)")
    return result