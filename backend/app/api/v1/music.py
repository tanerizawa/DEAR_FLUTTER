# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException
from sqlalchemy.orm import Session
import structlog
import asyncio # -> Import asyncio

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


# --- ENDPOINT BARU UNTUK RADIO STATION ---
@router.get("/station", response_model=list[schemas.AudioTrack])
async def get_activity_station(
    category: str = Query(..., enum=["fokus", "santai", "semangat"]),
    suggestion_service: MusicSuggestionService = Depends(),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Menghasilkan playlist untuk menemani aktivitas pengguna."""
    log.info("api:get_activity_station", category=category, user_id=current_user.id)
    
    # 1. Dapatkan 10 saran lagu dari AI
    suggestions = await suggestion_service.suggest_playlist_for_activity(category=category)
    if not suggestions:
        raise HTTPException(status_code=404, detail="Gagal mendapatkan sugesti playlist dari AI.")

    async def find_youtube_id(song: schemas.SongSuggestion):
        """Helper async untuk mencari ID YouTube untuk satu lagu."""
        try:
            # Menggunakan VideosSearch di dalam executor untuk tidak memblokir event loop
            search_result = await asyncio.to_thread(
                VideosSearch(f"{song.title} {song.artist}", limit=1).result
            )
            items = search_result.get("result", [])
            if items:
                video_id = items[0].get("id")
                if video_id:
                    return schemas.AudioTrack(
                        id=0, # ID akan diabaikan karena tidak disimpan
                        title=song.title,
                        artist=song.artist,
                        youtube_id=video_id,
                    )
        except Exception as e:
            log.warn("Youtube_failed", song=song.title, error=str(e))
        return None

    # 2. Jalankan semua pencarian YouTube secara paralel untuk efisiensi
    tasks = [find_youtube_id(song) for song in suggestions]
    results = await asyncio.gather(*tasks)

    # 3. Filter hasil yang tidak null dan berikan ID sementara
    playlist = [track for track in results if track]
    for i, track in enumerate(playlist):
        track.id = i + 1

    if not playlist:
        raise HTTPException(status_code=404, detail="Tidak dapat menemukan video untuk sugesti lagu yang ada.")

    log.info("api:activity_station_created", category=category, count=len(playlist))
    return playlist