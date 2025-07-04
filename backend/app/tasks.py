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
import structlog

log = structlog.get_logger(__name__)

# --- FUNGSI LOGIKA INTI YANG BISA DIGUNAKAN KEMBALI ---
async def run_music_generation_flow():
    """
    Menjalankan alur lengkap untuk menghasilkan dan menyimpan rekomendasi musik.
    Fungsi ini sekarang terpisah agar bisa dipanggil dari mana saja.
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

        keyword = await MusicKeywordService().generate_keyword(journals)
        if not keyword:
            log.warn("music_generation_flow:no_keyword_generated")
            return "No keyword generated from journals."

        suggestion = await MusicSuggestionService().suggest_song(keyword)
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
            youtube_id = "" # Pastikan kosong jika gagal

        if youtube_id:
            crud.music_track.create(
                db,
                obj_in=AudioTrackCreate(
                    title=suggestion.title,
                    youtube_id=youtube_id,
                    artist=suggestion.artist,
                ),
            )
            log.info("music_generation_flow:success", title=suggestion.title)
            return "Music recommendation generated successfully."
        else:
            log.warn("music_generation_flow:no_youtube_result")
            return "Could not find a suitable YouTube video for the suggestion."

    finally:
        db.close()


@celery_app.task
def analyze_profile_task(user_id: int):
    """
    Tugas Celery untuk menganalisis profil pengguna.
    """
    db = SessionLocal()
    try:
        user = crud.user.get(db, id=user_id)
        if user:
            profile_analyzer.analyze_and_update_profile(db=db, user=user)
    finally:
        db.close()
    return f"Profile analysis complete for user_id {user_id}"


@celery_app.task
async def generate_quote_task():
    """Generate a motivational quote based on the latest journal mood."""
    db = SessionLocal()
    try:
        latest = (
            db.query(models.Journal).order_by(models.Journal.created_at.desc()).first()
        )
        mood = latest.mood if latest and latest.mood else "Netral"
        service = QuoteGenerationService()
        text, author = await service.generate_quote(mood)
        if text:
            crud.motivational_quote.create(
                db,
                obj_in=MotivationalQuoteCreate(text=text, author=author),
            )
    finally:
        db.close()
    return "Quote generation complete"


# Tugas Celery sekarang hanya memanggil fungsi inti
@celery_app.task
async def generate_music_recommendation_task():
    """Tugas Celery terjadwal yang memicu alur generasi musik."""
    log.info("celery_task:starting_music_generation")
    result = await run_music_generation_flow()
    log.info("celery_task:finished_music_generation", result=result)
    return result