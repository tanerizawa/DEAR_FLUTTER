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
import yt_dlp  # -> Import library baru
import asyncio
import structlog
from app.core.config import settings

log = structlog.get_logger(__name__)

# --- FUNGSI HELPER BARU UNTUK MENGAMBIL STREAM URL ---
def _get_audio_stream_url(youtube_id: str) -> str | None:
    """
    Menggunakan yt-dlp untuk mengekstrak URL streaming audio terbaik.
    """
    if not youtube_id:
        return None
    
    video_url = f"https://www.youtube.com/watch?v={youtube_id}"
    ydl_opts = {
        'format': 'bestaudio/best', # Memilih audio dengan kualitas terbaik
        'quiet': True,
        'no_warnings': True,
        'geturl': True, # Hanya mengambil URL, tidak men-download
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            return info.get('url')
    except Exception as e:
        log.error("yt_dlp_extraction_failed", video_id=youtube_id, error=str(e))
        return None


async def run_music_generation_flow():
    """
    Menjalankan alur lengkap untuk menghasilkan dan menyimpan rekomendasi musik,
    termasuk mengambil URL streaming audionya.
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
            return "No journals found to generate music recommendation."

        keyword_service = MusicKeywordService(settings=settings)
        keyword = await keyword_service.generate_keyword(journals)
        
        if not keyword:
            log.warn("music_generation_flow:no_keyword_generated")
            return "No keyword generated from journals."

        suggestion_service = MusicSuggestionService(settings=settings)
        suggestion = await suggestion_service.suggest_song(keyword)

        if not suggestion:
            log.warn("music_generation_flow:no_suggestion_from_service")
            return "No suggestion returned from music service."
            
        youtube_id = ""
        try:
            search = VideosSearch(f"{suggestion.title} {suggestion.artist}", limit=1)
            result = search.result()
            items = result.get("result", [])
            if items:
                youtube_id = items[0].get("id", "")
                log.info("music_generation_flow:Youtube_success", video_id=youtube_id)
        except Exception as e:
            log.error("music_generation_flow:Youtube_failed", error=str(e))
        
        # --- LOGIKA BARU: Ambil stream URL jika ID ditemukan ---
        if youtube_id:
            # Jalankan fungsi sinkron _get_audio_stream_url di thread terpisah
            # agar tidak memblokir event loop utama.
            stream_url = await asyncio.to_thread(_get_audio_stream_url, youtube_id)

            if stream_url:
                log.info("music_generation_flow:stream_url_extracted", video_id=youtube_id)
                crud.music_track.create(
                    db,
                    obj_in=AudioTrackCreate(
                        title=suggestion.title,
                        youtube_id=youtube_id,
                        artist=suggestion.artist,
                        stream_url=stream_url, # Simpan URL ke database
                    ),
                )
                log.info("music_generation_flow:success", title=suggestion.title)
                return "Music recommendation with stream URL generated successfully."
            else:
                log.warn("music_generation_flow:stream_url_extraction_failed", video_id=youtube_id)
                return "Could not extract stream URL for the video."
        else:
            log.warn("music_generation_flow:no_youtube_result")
            return "Could not find a suitable YouTube video for the suggestion."

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