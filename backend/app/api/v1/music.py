# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks
from sqlalchemy.orm import Session
import structlog

from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
# Import fungsi yang baru kita buat
from app.tasks import run_music_generation_flow

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
def get_latest_music(
    db: Session = Depends(dependencies.get_db),
) -> schemas.AudioTrack | None:
    """Return the most recently generated music recommendation."""
    return crud.music_track.get_latest(db)


# --- ENDPOINT BARU UNTUK DEVELOPMENT ---
@router.post("/trigger-generation", status_code=202)
async def trigger_music_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Memicu proses generasi rekomendasi musik di latar belakang.
    Endpoint ini ideal untuk development dan aksi 'pull-to-refresh'.
    """
    log.info("api:trigger_music_generation", user_id=current_user.id)
    # Menambahkan tugas ke background, API akan langsung merespons
    background_tasks.add_task(run_music_generation_flow)
    return {"message": "Music recommendation generation process has been started."}