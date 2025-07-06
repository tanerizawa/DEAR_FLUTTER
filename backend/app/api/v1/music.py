# backend/app/api/v1/music.py

from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import desc
import structlog
import asyncio # -> Import asyncio
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
):
    """Return the most recently generated music recommendation."""
    # Ambil track terbaru dengan status 'done' dan field valid
    track = (
        db.query(models.MusicTrack)
        .filter(models.MusicTrack.status == 'done')
        .filter(models.MusicTrack.title.isnot(None))
        .filter(models.MusicTrack.youtube_id.isnot(None))
        .filter(models.MusicTrack.stream_url.isnot(None))
        .order_by(desc(models.MusicTrack.created_at))
        .first()
    )
    
    if not track:
        # Kembalikan 204 No Content agar frontend tahu tidak ada lagu valid
        return JSONResponse(status_code=204, content=None)
    return track


@router.post("/trigger-generation", status_code=202)
async def trigger_music_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    log.info("api:trigger_music_generation", user_id=current_user.id)
    # Pass user_id to get personalized music based on user's journals and profile
    background_tasks.add_task(run_music_generation_flow, user_id=current_user.id)
    return {"message": "Personalized music recommendation generation process has been started."}


@router.post("/trigger-generation-global", status_code=202)
async def trigger_global_music_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Trigger global music generation (from all users' journals)"""
    log.info("api:trigger_global_music_generation", triggered_by=current_user.id)
    background_tasks.add_task(run_music_generation_flow, user_id=None)
    return {"message": "Global music recommendation generation process has been started."}


@router.post("/extract-audio")
async def extract_audio(
    data: dict = Body(...)
):
    """Enhanced YouTube audio extraction with intelligent stealth strategies"""
    youtube_url = data.get("youtube_url")
    stealth_mode = data.get("stealth_mode", True)
    use_proxy = data.get("use_proxy", False)
    intelligent_mode = data.get("intelligent_mode", True)
    
    if not youtube_url:
        raise HTTPException(status_code=400, detail="youtube_url is required")
    
    try:
        # Check rate limit
        if not await rate_limiter.can_make_request("youtube"):
            wait_time = rate_limiter.get_wait_time("youtube")
            raise HTTPException(
                status_code=429, 
                detail=f"Rate limit exceeded. Please wait {wait_time:.0f} seconds"
            )
        
        log.info("audio_extraction_started", 
                url=youtube_url, 
                stealth=stealth_mode, 
                proxy=use_proxy,
                intelligent=intelligent_mode)
        
        # Use intelligent extraction by default for better results
        if stealth_mode and intelligent_mode:
            result = await stealth_youtube_extractor.adaptive_extraction_with_intelligence(
                youtube_url, use_proxy=use_proxy
            )
        elif stealth_mode:
            result = await stealth_youtube_extractor.extract_audio_url(
                youtube_url, 
                stealth_mode=True,
                use_proxy=use_proxy,
                use_cache=True
            )
        else:
            # Fallback to basic extraction
            result = await stealth_youtube_extractor._extract_audio_url_basic(youtube_url)
        
        if not result or not result.get("audio_url"):
            raise HTTPException(
                status_code=422, 
                detail="Failed to extract audio from YouTube (geo-blocked, format unavailable, or bot detection)"
            )
        
        # Add extraction metadata
        result["extraction_mode"] = "intelligent_stealth" if (stealth_mode and intelligent_mode) else ("stealth" if stealth_mode else "basic")
        result["proxy_used"] = use_proxy
        result["extraction_timestamp"] = datetime.datetime.utcnow().isoformat()
        
        return SafeResponseHandler.create_json_response(result)
        
    except HTTPException:
        raise
    except Exception as e:
        log.error("extract_audio_error", error=str(e), url=youtube_url)
        raise HTTPException(status_code=500, detail="Internal server error during audio extraction")


@router.get("/stealth-status")
async def get_stealth_status(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Get comprehensive status of stealth YouTube extractor for monitoring"""
    try:
        # Get detailed session status
        status = stealth_youtube_extractor.get_session_status()
        
        # Add additional runtime information
        status.update({
            "stealth_mode_active": True,
            "available_strategies": len(stealth_youtube_extractor._get_stealth_strategies()),
            "user_agents_count": len(stealth_youtube_extractor.user_agents),
            "session_rotation_interval": 3600,  # 1 hour
            "cache_ttl": getattr(stealth_youtube_extractor, 'cache_ttl', 3600)
        })
        
        return SafeResponseHandler.create_json_response(status)
        
    except Exception as e:
        log.error("stealth_status_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get stealth status")


@router.post("/rotate-stealth-session")
async def rotate_stealth_session(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Manually rotate stealth session parameters"""
    try:
        stealth_youtube_extractor._rotate_session()
        
        return SafeResponseHandler.create_json_response({
            "message": "Stealth session rotated successfully",
            "new_session_start": stealth_youtube_extractor.session_start_time,
            "bot_detection_count_reset": stealth_youtube_extractor.bot_detection_count,
            "adaptive_delay_reset": stealth_youtube_extractor.adaptive_delay_multiplier
        })
        
    except Exception as e:
        log.error("rotate_session_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to rotate session")


@router.get("/performance-metrics")
async def get_performance_metrics(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Get detailed performance metrics for stealth extractor monitoring"""
    try:
        metrics = stealth_youtube_extractor.get_performance_metrics()
        return SafeResponseHandler.create_json_response(metrics)
        
    except Exception as e:
        log.error("performance_metrics_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get performance metrics")


@router.post("/clear-failed-strategies")
async def clear_failed_strategies(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Clear failed strategies to allow retry"""
    try:
        old_count = len(stealth_youtube_extractor.failed_strategies)
        stealth_youtube_extractor.clear_failed_strategies()
        
        return SafeResponseHandler.create_json_response({
            "message": "Failed strategies cleared successfully",
            "cleared_count": old_count,
            "remaining_strategies": len(stealth_youtube_extractor._get_stealth_strategies())
        })
        
    except Exception as e:
        log.error("clear_strategies_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to clear failed strategies")


@router.get("/session-health")
async def get_session_health(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Get detailed session health information"""
    try:
        status = stealth_youtube_extractor.get_session_status()
        return SafeResponseHandler.create_json_response(status)
        
    except Exception as e:
        log.error("session_health_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get session health")


@router.post("/extract-audio-enhanced")
async def extract_audio_enhanced(
    data: dict = Body(...)
):
    """Enhanced audio extraction with intelligent strategy selection"""
    youtube_url = data.get("youtube_url")
    use_proxy = data.get("use_proxy", False)
    force_intelligent = data.get("intelligent_mode", True)
    
    if not youtube_url:
        raise HTTPException(status_code=400, detail="youtube_url is required")
    
    try:
        # Check rate limit
        if not await rate_limiter.can_make_request("youtube"):
            wait_time = rate_limiter.get_wait_time("youtube")
            raise HTTPException(
                status_code=429, 
                detail=f"Rate limit exceeded. Please wait {wait_time:.0f} seconds"
            )
        
        log.info("enhanced_extraction_started", 
                url=youtube_url, 
                proxy=use_proxy, 
                intelligent=force_intelligent)
        
        # Use intelligent extraction if requested
        if force_intelligent:
            result = await stealth_youtube_extractor.adaptive_extraction_with_intelligence(
                youtube_url, use_proxy=use_proxy
            )
        else:
            result = await stealth_youtube_extractor.extract_audio_url(
                youtube_url, 
                stealth_mode=True,
                use_proxy=use_proxy,
                use_cache=True
            )
        
        if not result or not result.get("audio_url"):
            raise HTTPException(
                status_code=422, 
                detail="Failed to extract audio with enhanced methods"
            )
        
        # Add extraction metadata
        result["extraction_method"] = "intelligent" if force_intelligent else "standard"
        result["proxy_used"] = use_proxy
        result["extraction_timestamp"] = datetime.datetime.utcnow().isoformat()
        
        return SafeResponseHandler.create_json_response(result)
        
    except HTTPException:
        raise
    except Exception as e:
        log.error("enhanced_extraction_error", error=str(e), url=youtube_url)
        raise HTTPException(status_code=500, detail="Enhanced extraction failed")


@router.post("/force-session-rotation")
async def force_session_rotation(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Force complete session rotation with new fingerprint"""
    try:
        old_session_id = stealth_youtube_extractor.session_id
        stealth_youtube_extractor.rotate_session_parameters()
        
        return SafeResponseHandler.create_json_response({
            "message": "Complete session rotation performed",
            "old_session_id": old_session_id,
            "new_session_id": stealth_youtube_extractor.session_id,
            "new_fingerprint": {
                "platform": stealth_youtube_extractor.browser_fingerprint["platform"],
                "screen_resolution": stealth_youtube_extractor.browser_fingerprint["screen_resolution"],
                "canvas_hash": stealth_youtube_extractor.browser_fingerprint["canvas_hash"][:8] + "..."
            }
        })
        
    except Exception as e:
        log.error("force_rotation_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to force session rotation")


@router.get("/proxy-stats")
async def get_proxy_stats(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """Get proxy rotation service statistics"""
    try:
        from app.services.proxy_rotation_service import proxy_rotation_service
        stats = proxy_rotation_service.get_proxy_stats()
        return SafeResponseHandler.create_json_response(stats)
        
    except Exception as e:
        log.error("proxy_stats_error", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get proxy statistics")