# backend/app/tasks.py

from app.celery_app import celery_app
from app.services.profile_analyzer_service import profile_analyzer
from app.db.session import SessionLocal
from app import crud, models
from app.services.quote_generation_service import QuoteGenerationService
from app.services.music_keyword_service import MusicKeywordService
from app.services.music_suggestion_service import MusicSuggestionService
from app.schemas.motivational_quote import MotivationalQuoteCreate
from app.schemas.audio import AudioTrackCreate
from youtubesearchpython import VideosSearch
import asyncio
import structlog
from app.core.config import settings

log = structlog.get_logger(__name__)

async def run_music_generation_flow():
    """
    Menjalankan alur untuk menghasilkan rekomendasi musik
    (HANYA menyimpan youtube_id, tanpa stream_url).
    """
    db = SessionLocal()
    try:
        log.info("music_generation_flow:start")
        journals = (
            db.query(models.Journal)
            .order_by(models.Journal.created_at.desc())
            .limit(5)
            .all()
        )

        if not journals:
            log.warn("music_generation_flow:no_journals_found")
            return "No journals found."

        keyword_service = MusicKeywordService(settings=settings)
        keyword = await keyword_service.generate_keyword(journals)
        log.info("music_generation_flow:keyword_generated", keyword=keyword)

        if not keyword:
            log.warn("music_generation_flow:no_keyword_generated")
            return "No keyword generated."

        # Ambil lagu terbaru sebelum generate
        prev_track = db.query(models.MusicTrack).order_by(models.MusicTrack.created_at.desc()).first()
        prev_youtube_id = prev_track.youtube_id if prev_track else None

        max_attempts = 3
        attempt = 0
        found_new = False
        while attempt < max_attempts and not found_new:
            suggestion_service = MusicSuggestionService(settings=settings)
            suggestion = await suggestion_service.suggest_song(keyword)
            log.info("music_generation_flow:song_suggestion", suggestion=suggestion.title if suggestion else None)

            if not suggestion:
                log.warn("music_generation_flow:no_suggestion_from_service")
                return "No suggestion returned."
            
            youtube_id = ""
            try:
                search = VideosSearch(f"{suggestion.title} {suggestion.artist}", limit=1)
                result = search.result()
                items = result.get("result", [])
                if items:
                    youtube_id = items[0].get("id", "")
                log.info("music_generation_flow:youtube_search_result", youtube_id=youtube_id)
            except Exception as e:
                log.error("music_generation_flow:Youtube_failed", error=str(e))
            
            if youtube_id and youtube_id != prev_youtube_id:
                found_new = True
            else:
                attempt += 1
                log.info("music_generation_flow:retry_generate", attempt=attempt)

        # Buat entry baru dengan status 'generating' sebelum proses
        from app.models.music_track import MusicTrack
        temp_track = MusicTrack(title="Generating...", youtube_id="", artist="", status="generating")
        db.add(temp_track)
        db.commit()
        db.refresh(temp_track)
        temp_id = temp_track.id

        if youtube_id:
            # Ekstrak audio_url yang playable di Indonesia
            from app.services.youtube_audio_extractor import extract_audio_url
            youtube_url = f"https://www.youtube.com/watch?v={youtube_id}"
            audio_info = extract_audio_url(youtube_url)
            stream_url = audio_info["audio_url"] if audio_info else None
            # Update entry yang tadi dibuat
            temp_track.title = suggestion.title
            temp_track.youtube_id = youtube_id
            temp_track.artist = suggestion.artist
            temp_track.status = "done"
            temp_track.stream_url = stream_url
            db.commit()
            log.info("music_generation_flow:success", title=suggestion.title, youtube_id=youtube_id, stream_url=stream_url)
            return "Music recommendation (ID+audio) generated successfully."
        else:
            temp_track.status = "failed"
            db.commit()
            log.warn("music_generation_flow:no_youtube_result")
            return "Could not find a YouTube video."

    finally:
        db.close()

# ... (sisa file tasks.py tetap sama, tidak perlu diubah) ...
@celery_app.task
def analyze_profile_task(user_id: int):
    # ...
    pass

@celery_app.task
async def generate_quote_task():
    # ...
    pass

@celery_app.task
async def generate_music_recommendation_task():
    log.info("celery_task:starting_music_generation")
    result = await run_music_generation_flow()
    log.info("celery_task:finished_music_generation", result=result)
    return result