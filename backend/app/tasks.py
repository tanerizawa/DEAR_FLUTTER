# backend/app/tasks.py

from app.celery_app import celery_app
from app.services.profile_analyzer_service import profile_analyzer
from app.db.session import SessionLocal
from app import crud
import asyncio
from app.services.quote_generation_service import QuoteGenerationService
from app.schemas.motivational_quote import MotivationalQuoteCreate
from app import models
from app.api.v1.music import get_spotify, _process_search_results
from app.services.music_keyword_service import MusicKeywordService
from app.state.music import set_latest_music
import re


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
    """Generate and store a music recommendation."""
    db = SessionLocal()
    try:
        user = db.query(models.User).first()
        if not user:
            return "No users available"

        journals = crud.journal.get_multi_by_owner(
            db=db, owner_id=user.id, limit=5, order_by="created_at desc"
        )

        musics = []
        if journals:
            try:
                raw_keyword = asyncio.run(
                    MusicKeywordService().generate_keyword(journals)
                )
                cleaned = re.sub(r"[^a-zA-Z0-9\s]", "", raw_keyword).strip()
                if cleaned:
                    client = get_spotify()
                    search_results = client.search(q=cleaned, type="track", limit=20)
                    musics = _process_search_results(search_results)
                if not musics:
                    mood = journals[0].mood
                    fallback_map = {
                        "Sangat Negatif": "lagu sedih",
                        "Negatif": "lagu galau",
                        "Netral": "lofi hip hop instrumental",
                        "Positif": "lagu semangat",
                        "Sangat Positif": "lagu ceria playlist",
                    }
                    keyword = fallback_map.get(mood, "musik instrumental santai")
                    client = get_spotify()
                    search_results_fallback = client.search(
                        q=keyword, type="track", limit=20
                    )
                    musics = _process_search_results(search_results_fallback)
            except Exception:
                musics = []

        if not musics:
            try:
                client = get_spotify()
                default_results = client.search(
                    q="top hits indonesia", type="track", limit=20
                )
                musics = _process_search_results(default_results)
            except Exception:
                musics = []

        if musics:
            set_latest_music(musics[0])
    finally:
        db.close()
    return "Music recommendation complete"
