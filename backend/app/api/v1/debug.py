# backend/app/api/v1/debug.py

import os
from fastapi import APIRouter, HTTPException
from sqlalchemy.orm import Session
from app import crud, dependencies
from app.db.session import SessionLocal
import structlog

router = APIRouter()
log = structlog.get_logger(__name__)

@router.get("/ping")
def debug_ping():
    """Debug endpoint - aktif di semua environment untuk troubleshooting"""
    env = os.environ.get("ENVIRONMENT", "development")
    debug_mode = os.environ.get("DEBUG_LOCAL", "0") == "1"
    
    # Temporarily allow debug endpoints in production for troubleshooting
    # if env == "production" and not debug_mode:
    #     raise HTTPException(status_code=403, detail="Debug endpoint not available in production")
    
    return {
        "message": "pong",
        "environment": env,
        "debug_mode": debug_mode,
        "server": "local"
    }

@router.get("/db-test")
def debug_db_test():
    """Test koneksi database - debug only"""
    env = os.environ.get("ENVIRONMENT", "development")
    debug_mode = os.environ.get("DEBUG_LOCAL", "0") == "1"
    
    # Temporarily allow debug endpoints in production for troubleshooting
    # if env == "production" and not debug_mode:
    #     raise HTTPException(status_code=403, detail="Debug endpoint not available in production")
    
    try:
        db = SessionLocal()
        # Test simple query
        result = db.execute("SELECT 1 as test").fetchone()
        db.close()
        return {
            "message": "Database connection OK",
            "test_result": result[0] if result else None
        }
    except Exception as e:
        log.error("debug:db_test_failed", error=str(e))
        return {
            "message": "Database connection FAILED",
            "error": str(e)
        }

@router.get("/info")
def debug_info():
    """Informasi sistem - debug only"""
    env = os.environ.get("ENVIRONMENT", "development")
    debug_mode = os.environ.get("DEBUG_LOCAL", "0") == "1"
    
    # Temporarily allow debug endpoints in production for troubleshooting
    # if env == "production" and not debug_mode:
    #     raise HTTPException(status_code=403, detail="Debug endpoint not available in production")
    
    return {
        "environment": env,
        "debug_local": debug_mode,
        "python_version": f"{os.sys.version_info.major}.{os.sys.version_info.minor}.{os.sys.version_info.micro}",
        "cwd": os.getcwd(),
        "env_vars": {
            "DATABASE_URL": "***" if os.environ.get("DATABASE_URL") else None,
            "OPENROUTER_API_KEY": "***" if os.environ.get("OPENROUTER_API_KEY") else None,
            "SENTRY_DSN": "***" if os.environ.get("SENTRY_DSN") else None,
        }
    }

@router.get("/music-tracks")
def debug_music_tracks():
    """Debug music tracks - debug only"""
    env = os.environ.get("ENVIRONMENT", "development")
    debug_mode = os.environ.get("DEBUG_LOCAL", "0") == "1"
    
    # Temporarily allow debug endpoints in production for troubleshooting
    # if env == "production" and not debug_mode:
    #     raise HTTPException(status_code=403, detail="Debug endpoint not available in production")
    
    try:
        db = SessionLocal()
        # Use SQLAlchemy ORM instead of raw SQL
        from app.models.music_track import MusicTrack
        tracks = db.query(MusicTrack).order_by(MusicTrack.created_at.desc()).limit(10).all()
        db.close()
        return {
            "tracks": [
                {
                    "id": track.id,
                    "title": track.title, 
                    "youtube_id": track.youtube_id,
                    "status": track.status,
                    "stream_url": track.stream_url[:50] + "..." if track.stream_url else None,
                    "created_at": str(track.created_at)
                } for track in tracks
            ]
        }
    except Exception as e:
        log.error("debug:music_tracks_failed", error=str(e))
        return {
            "error": str(e)
        }

@router.get("/music-stats")
def debug_music_stats():
    """Music generation statistics - debug only"""
    env = os.environ.get("ENVIRONMENT", "development")
    debug_mode = os.environ.get("DEBUG_LOCAL", "0") == "1"
    
    # Temporarily allow debug endpoints in production for troubleshooting
    # if env == "production" and not debug_mode:
    #     raise HTTPException(status_code=403, detail="Debug endpoint not available in production")
    
    try:
        db = SessionLocal()
        from app.models.music_track import MusicTrack
        
        # Get stats for last 24 hours
        from datetime import datetime, timedelta
        yesterday = datetime.now() - timedelta(days=1)
        
        total_attempts = db.query(MusicTrack).filter(MusicTrack.created_at >= yesterday).count()
        successful = db.query(MusicTrack).filter(
            MusicTrack.created_at >= yesterday,
            MusicTrack.status == 'done'
        ).count()
        failed = db.query(MusicTrack).filter(
            MusicTrack.created_at >= yesterday,
            MusicTrack.status == 'failed'
        ).count()
        generating = db.query(MusicTrack).filter(
            MusicTrack.created_at >= yesterday,
            MusicTrack.status == 'generating'
        ).count()
        
        success_rate = (successful / total_attempts * 100) if total_attempts > 0 else 0
        
        # Get latest successful track
        latest_success = db.query(MusicTrack).filter(
            MusicTrack.status == 'done'
        ).order_by(MusicTrack.created_at.desc()).first()
        
        db.close()
        return {
            "last_24_hours": {
                "total_attempts": total_attempts,
                "successful": successful,
                "failed": failed,
                "generating": generating,
                "success_rate": f"{success_rate:.1f}%"
            },
            "latest_successful_track": {
                "title": latest_success.title if latest_success else None,
                "artist": latest_success.artist if latest_success else None,
                "created_at": str(latest_success.created_at) if latest_success else None,
                "youtube_id": latest_success.youtube_id if latest_success else None
            } if latest_success else None
        }
    except Exception as e:
        log.error("debug:music_stats_failed", error=str(e))
        return {
            "error": str(e)
        }
