# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import desc
import structlog
import asyncio # -> Import asyncio
from typing import List
from app.services.playlist_cache_service import PlaylistCacheService
import datetime
from fastapi.responses import JSONResponse

from app import crud, models, schemas, dependencies
from app.services.music_suggestion_service import MusicSuggestionService
from app.tasks import run_music_generation_flow
from youtubesearchpython import VideosSearch
from app.services.stealth_youtube_extractor import stealth_youtube_extractor
from app.core.rate_limiter import rate_limiter
from app.core.response_handler import SafeResponseHandler


router = APIRouter()
log = structlog.get_logger(__name__)

# Radio station categories mapping
RADIO_CATEGORIES = {
    'santai': {'mood': 'relax', 'keywords': ['chill', 'relax', 'ambient', 'peaceful']},
    'energik': {'mood': 'energetic', 'keywords': ['upbeat', 'motivational', 'workout', 'dance']},
    'fokus': {'mood': 'focus', 'keywords': ['instrumental', 'concentration', 'study', 'productivity']},
    'bahagia': {'mood': 'happy', 'keywords': ['happy', 'uplifting', 'positive', 'cheerful']},
    'sedih': {'mood': 'sad', 'keywords': ['melancholy', 'emotional', 'ballad', 'contemplative']},
    'romantis': {'mood': 'romantic', 'keywords': ['love', 'romantic', 'intimate', 'soulful']},
    'nostalgia': {'mood': 'nostalgic', 'keywords': ['classic', 'vintage', 'memories', 'timeless']},
    'instrumental': {'mood': 'instrumental', 'keywords': ['no vocals', 'classical', 'cinematic', 'atmospheric']},
    'jazz': {'mood': 'jazz', 'keywords': ['smooth', 'sophisticated', 'lounge', 'swing']},
    'rock': {'mood': 'rock', 'keywords': ['guitar', 'alternative', 'indie', 'energetic']},
    'pop': {'mood': 'pop', 'keywords': ['mainstream', 'catchy', 'contemporary', 'hits']},
    'electronic': {'mood': 'electronic', 'keywords': ['synth', 'beats', 'digital', 'futuristic']},
}

@router.get("/station", response_model=List[schemas.AudioTrack])
async def get_radio_station(
    *,
    category: str = Query(..., description="Radio station category"),
    db: Session = Depends(dependencies.get_db),
    suggestion_service: MusicSuggestionService = Depends(),
):
    """Get radio station playlist based on category."""
    log.info("radio_station_request", category=category)
    
    # Validate category
    if category not in RADIO_CATEGORIES:
        log.warning("invalid_radio_category", category=category, available=list(RADIO_CATEGORIES.keys()))
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid category. Available: {', '.join(RADIO_CATEGORIES.keys())}"
        )
    
    try:
        category_config = RADIO_CATEGORIES[category]
        mood = category_config['mood']
        keywords = category_config['keywords']
        
        # Generate playlist using music suggestion service
        playlist = []
        
        # Generate 5-8 songs for the radio station
        for i in range(5):
            try:
                # Use different mood variations to get diverse songs
                mood_variation = f"{mood} {keywords[i % len(keywords)]}"
                suggestion = await suggestion_service.suggest_song(mood=mood_variation)
                
                if suggestion:
                    # Search for YouTube video
                    search_query = f"{suggestion.title} {suggestion.artist}"
                    videos_search = VideosSearch(search_query, limit=1)
                    results = videos_search.result()
                    
                    youtube_id = None
                    if results and results.get('result') and len(results['result']) > 0:
                        youtube_id = results['result'][0]['id']
                    
                    if youtube_id:
                        # Convert SongSuggestion to AudioTrack format
                        audio_track = {
                            "id": i + 1,  # Use integer ID
                            "title": suggestion.title,
                            "artist": suggestion.artist,
                            "youtube_id": youtube_id,
                            "stream_url": None,
                            "cover_url": None,
                            "status": "done",
                        }
                        playlist.append(audio_track)
                        log.info("radio_track_added", track=suggestion.title, artist=suggestion.artist, youtube_id=youtube_id)
                    else:
                        log.warning("youtube_search_failed", query=search_query)
                    
            except Exception as e:
                log.warning("radio_track_generation_failed", error=str(e), iteration=i)
                continue
        
        if not playlist:
            # Fallback: return some default tracks if generation fails
            log.warning("radio_generation_failed_completely", category=category)
            playlist = _get_fallback_playlist(category)
        
        log.info("radio_station_generated", category=category, track_count=len(playlist))
        return playlist
        
    except Exception as e:
        log.error("radio_station_error", category=category, error=str(e))
        # Return fallback playlist instead of error
        return _get_fallback_playlist(category)


def _get_fallback_playlist(category: str) -> List[dict]:
    """Generate a fallback playlist when radio generation fails."""
    fallback_tracks = {
        'santai': [
            {"title": "Peaceful Waves", "artist": "Nature Sounds", "youtube_id": "dQw4w9WgXcQ"},
            {"title": "Calm Evening", "artist": "Ambient Collective", "youtube_id": "dQw4w9WgXcQ"},
        ],
        'energik': [
            {"title": "High Energy", "artist": "Workout Music", "youtube_id": "dQw4w9WgXcQ"},
            {"title": "Power Up", "artist": "Motivation Mix", "youtube_id": "dQw4w9WgXcQ"},
        ],
        'pop': [
            {"title": "Popular Hit", "artist": "Chart Toppers", "youtube_id": "dQw4w9WgXcQ"},
            {"title": "Mainstream Sound", "artist": "Radio Friendly", "youtube_id": "dQw4w9WgXcQ"},
        ],
    }
    
    tracks = fallback_tracks.get(category, fallback_tracks['pop'])
    playlist = []
    
    for i, track in enumerate(tracks):
        audio_track = {
            "id": i + 1,  # Use integer ID
            "title": track["title"],
            "artist": track["artist"],
            "youtube_id": track["youtube_id"],
            "stream_url": None,
            "cover_url": None,
            "status": "done",
        }
        playlist.append(audio_track)
    
    return playlist

# ...existing code...