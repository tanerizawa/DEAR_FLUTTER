# backend/app/api/v1/personalized_playlist.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import structlog
import datetime
from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
from app.services.prompt_builder_service import build_dynamic_prompt
from app.services.playlist_cache_service import PlaylistCacheService
from youtubesearchpython import VideosSearch

router = APIRouter()
log = structlog.get_logger(__name__)

@router.get("/personalized-playlist", response_model=list[schemas.AudioTrack])
async def get_personalized_playlist(
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
    suggestion_service: MusicSuggestionService = Depends(),
):
    today = datetime.date.today().isoformat()
    # 1. Cek cache
    cached = PlaylistCacheService.get_playlist(current_user.id, today, "personalized")
    if cached:
        log.info("api:personalized_playlist_cache_hit", count=len(cached))
        return cached
    # 2. Ambil data jurnal, chat, mood, history
    journals = crud.journal.get_by_user_id(db, user_id=current_user.id)
    chats = crud.chat.get_by_user_id(db, user_id=current_user.id)
    mood = crud.user_profile.get_by_user_id(db, user_id=current_user.id).sentiment_label
    last_tracks = [] # TODO: ambil dari history lagu user jika ada
    # 3. Build prompt dinamis
    prompt = build_dynamic_prompt(journals, chats, mood, last_tracks)
    # 4. Panggil AI untuk dapatkan 10 lagu
    suggestions = await suggestion_service.suggest_playlist_with_prompt(prompt)
    if not suggestions:
        raise HTTPException(status_code=404, detail="Gagal mendapatkan playlist personal dari AI.")
    # 5. Cari YouTube ID untuk setiap lagu
    async def find_youtube_id(song):
        try:
            search_result = await asyncio.to_thread(
                VideosSearch(f"{song.title} {song.artist}", limit=1).result
            )
            items = search_result.get("result", [])
            if items:
                video_id = items[0].get("id")
                if video_id:
                    return schemas.AudioTrack(
                        id=0,
                        title=song.title,
                        artist=song.artist,
                        youtube_id=video_id,
                    )
        except Exception as e:
            log.warn("Youtube_failed", song=song.title, error=str(e))
        return None
    tasks = [find_youtube_id(song) for song in suggestions]
    results = await asyncio.gather(*tasks)
    playlist = [track for track in results if track]
    for i, track in enumerate(playlist):
        track.id = i + 1
    if not playlist:
        raise HTTPException(status_code=404, detail="Tidak dapat menemukan video untuk playlist personal.")
    PlaylistCacheService.set_playlist(current_user.id, today, "personalized", playlist)
    log.info("api:personalized_playlist_created", count=len(playlist))
    return playlist
