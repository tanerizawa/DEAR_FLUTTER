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
        tracks = db.execute("SELECT id, title, youtube_id, status, created_at FROM musictracks ORDER BY created_at DESC LIMIT 10").fetchall()
        db.close()
        return {
            "tracks": [
                {
                    "id": track[0],
                    "title": track[1], 
                    "youtube_id": track[2],
                    "status": track[3],
                    "created_at": str(track[4])
                } for track in tracks
            ]
        }
    except Exception as e:
        log.error("debug:music_tracks_failed", error=str(e))
        return {
            "error": str(e)
        }
