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
    dengan improved success rate dan fallback strategies.
    """
    db = SessionLocal()
    try:
        log.info("music_generation_flow:start")
        
        # Clean up old failed tracks (keep only last 5 failed tracks)
        failed_tracks = (
            db.query(models.MusicTrack)
            .filter(models.MusicTrack.status == 'failed')
            .order_by(models.MusicTrack.created_at.desc())
            .offset(5)  # Keep newest 5 failed tracks
            .all()
        )
        if failed_tracks:
            for track in failed_tracks:
                db.delete(track)
            db.commit()
            log.info("music_generation_flow:cleaned_old_failed_tracks", count=len(failed_tracks))

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

        max_suggestion_attempts = 5  # Increase attempts for better variety
        suggestion_attempt = 0
        found_valid_track = False
        final_track_data = None
        
        # Buat entry dengan status 'generating' untuk tracking
        from app.models.music_track import MusicTrack
        temp_track = MusicTrack(title="Generating...", youtube_id="", artist="", status="generating")
        db.add(temp_track)
        db.commit()
        db.refresh(temp_track)
        temp_id = temp_track.id
        log.info("music_generation_flow:created_temp_track", temp_id=temp_id)

        while suggestion_attempt < max_suggestion_attempts and not found_valid_track:
            log.info("music_generation_flow:attempt", attempt=suggestion_attempt + 1, max_attempts=max_suggestion_attempts)
            
            try:
                suggestion_service = MusicSuggestionService(settings=settings)
                
                # Get multiple diverse suggestions for better variety and success rate
                previous_titles = []
                if prev_track and prev_track.title:
                    previous_titles.append(prev_track.title)
                
                # Get diverse suggestions (fallback to single suggestion if that fails)
                suggestions = await suggestion_service.suggest_diverse_songs(
                    keyword, count=3, avoid_titles=previous_titles
                )
                
                if not suggestions:
                    # Fallback to single suggestion
                    single_suggestion = await suggestion_service.suggest_song(keyword)
                    suggestions = [single_suggestion] if single_suggestion else []
                
                if not suggestions:
                    log.warn("music_generation_flow:no_suggestions", attempt=suggestion_attempt + 1)
                    suggestion_attempt += 1
                    continue

                # Try each suggestion until we find one that works
                for suggestion_idx, suggestion in enumerate(suggestions):
                    log.info("music_generation_flow:trying_suggestion", 
                            suggestion_idx=suggestion_idx + 1,
                            title=suggestion.title,
                            artist=suggestion.artist)

                # Try each suggestion until we find one that works
                for suggestion_idx, suggestion in enumerate(suggestions):
                    log.info("music_generation_flow:trying_suggestion", 
                            suggestion_idx=suggestion_idx + 1,
                            title=suggestion.title,
                            artist=suggestion.artist)

                    # Search for YouTube video with multiple search strategies
                    youtube_id = None
                    search_queries = [
                        f"{suggestion.title} {suggestion.artist}",
                        f"{suggestion.title} {suggestion.artist} official",
                        f"{suggestion.title} {suggestion.artist} music video",
                        f"{suggestion.title} audio",
                        suggestion.title  # fallback to just title
                    ]
                    
                    for query in search_queries:
                        try:
                            log.info("music_generation_flow:searching_youtube", query=query)
                            search = VideosSearch(query, limit=3)  # Get more results for better selection
                            result = search.result()
                            items = result.get("result", [])
                            
                            # Try to find a video that's not the same as previous and looks good
                            for item in items:
                                video_id = item.get("id", "")
                                video_title = item.get("title", "").lower()
                                video_duration = item.get("duration")
                                
                                # Skip if same as previous or too short/long
                                if (video_id != prev_youtube_id and 
                                    video_id and 
                                    "audio" in video_title or "music" in video_title or "official" in video_title):
                                    youtube_id = video_id
                                    log.info("music_generation_flow:found_youtube_video", 
                                            youtube_id=youtube_id, 
                                            title=item.get("title"),
                                            duration=video_duration)
                                    break
                            
                            if youtube_id:
                                break
                                
                        except Exception as e:
                            log.error("music_generation_flow:youtube_search_failed", query=query, error=str(e))
                            continue

                    if not youtube_id:
                        log.warn("music_generation_flow:no_youtube_id_for_suggestion", 
                                suggestion=suggestion.title,
                                suggestion_idx=suggestion_idx + 1)
                        continue  # Try next suggestion

                    # Try to extract audio with improved service
                    log.info("music_generation_flow:extracting_audio", youtube_id=youtube_id)
                    from app.services.youtube_audio_extractor import extract_audio_url
                    youtube_url = f"https://www.youtube.com/watch?v={youtube_id}"
                    audio_info = extract_audio_url(youtube_url)
                    
                    if audio_info and audio_info.get("audio_url"):
                        # Success! We have a valid track
                        final_track_data = {
                            "title": suggestion.title,
                            "youtube_id": youtube_id,
                            "artist": suggestion.artist,
                            "stream_url": audio_info["audio_url"],
                            "status": "done"
                        }
                        found_valid_track = True
                        log.info("music_generation_flow:success_extraction", 
                                title=suggestion.title,
                                youtube_id=youtube_id,
                                suggestion_idx=suggestion_idx + 1,
                                strategy=audio_info.get("strategy_used"))
                        break  # Exit suggestion loop
                    else:
                        log.warn("music_generation_flow:extraction_failed_for_suggestion", 
                                youtube_id=youtube_id, 
                                suggestion=suggestion.title,
                                suggestion_idx=suggestion_idx + 1)
                        # Continue to next suggestion
                
                if found_valid_track:
                    break  # Exit main attempt loop
                else:
                    suggestion_attempt += 1
                    log.info("music_generation_flow:all_suggestions_failed", 
                            attempt=suggestion_attempt,
                            tried_suggestions=len(suggestions))
                    
            except Exception as e:
                log.error("music_generation_flow:unexpected_error", 
                         attempt=suggestion_attempt + 1, 
                         error=str(e))
                suggestion_attempt += 1

        # Update temp track with final result
        if found_valid_track and final_track_data:
            temp_track.title = final_track_data["title"]
            temp_track.youtube_id = final_track_data["youtube_id"]
            temp_track.artist = final_track_data["artist"]
            temp_track.stream_url = final_track_data["stream_url"]
            temp_track.status = "done"
            db.commit()
            log.info("music_generation_flow:success", 
                    title=final_track_data["title"], 
                    youtube_id=final_track_data["youtube_id"])
            return "Music recommendation generated successfully."
        else:
            temp_track.status = "failed"
            temp_track.title = f"Failed after {suggestion_attempt} attempts"
            db.commit()
            log.warn("music_generation_flow:all_attempts_failed", attempts=suggestion_attempt)
            return f"Could not generate valid music after {suggestion_attempt} attempts."

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