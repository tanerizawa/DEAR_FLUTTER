# backend/app/tasks.py

from app.celery_app import celery_app
from app.services.profile_analyzer_service import profile_analyzer
from app.db.session import SessionLocal
from app import crud
import asyncio
from app.services.quote_generation_service import QuoteGenerationService
from app.services.music_keyword_service import MusicKeywordService
from app.services.music_suggestion_service import MusicSuggestionService
from app.schemas.motivational_quote import MotivationalQuoteCreate
from app.schemas.audio import AudioTrack
from app.state.music import set_latest_music
from app import models


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
def generate_quote_task():
    """Generate a motivational quote based on the latest journal mood."""
    db = SessionLocal()
    try:
        latest = (
            db.query(models.Journal).order_by(models.Journal.created_at.desc()).first()
        )
        mood = latest.mood if latest and latest.mood else "Netral"
        service = QuoteGenerationService()
        text, author = asyncio.run(service.generate_quote(mood))
        if text:
            crud.motivational_quote.create(
                db,
                obj_in=MotivationalQuoteCreate(text=text, author=author),
            )
    finally:
        db.close()
    return "Quote generation complete"


@celery_app.task
def generate_music_recommendation_task():
    """Generate and store a music recommendation based on recent journals."""
    db = SessionLocal()
    try:
        journals = (
            db.query(models.Journal)
            .order_by(models.Journal.created_at.desc())
            .limit(5)
            .all()
        )

        keyword = asyncio.run(MusicKeywordService().generate_keyword(journals))
        if not keyword:
            return "No keyword generated"

        suggestions = asyncio.run(MusicSuggestionService().suggest_songs(keyword))
        if not suggestions:
            return "No suggestions returned"

        suggestion = suggestions[0]
        youtube_id = ""
        try:
            from youtubesearchpython import VideosSearch

            search = VideosSearch(f"{suggestion.title} {suggestion.artist}", limit=1)
            result = search.result()
            items = result.get("result", [])
            if items:
                youtube_id = items[0].get("id", "")
        except Exception:
            youtube_id = ""

        if youtube_id:
            track = AudioTrack(
                id=0,
                title=suggestion.title,
                youtube_id=youtube_id,
                artist=suggestion.artist,
            )
            set_latest_music(track)
            return "Music recommendation generated"
        return "No YouTube result"
    finally:
        db.close()
