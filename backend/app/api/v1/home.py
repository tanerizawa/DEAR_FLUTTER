from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from app import crud, schemas
from app.dependencies import get_db

router = APIRouter()


@router.get("/home-feed", response_model=schemas.HomeFeed)
def get_home_feed(db: Session = Depends(get_db)):
    """Return the latest quote and music recommendation."""
    music_obj = crud.music_track.get_latest(db)
    # Validasi ketat: field wajib tidak boleh null/kosong
    if music_obj is not None:
        if not (music_obj.id and music_obj.title and music_obj.youtube_id and music_obj.stream_url) or music_obj.status == 'failed':
            music_obj = None
    
    # Always return response with quote, music can be null
    music_status = music_obj.status if music_obj else "done"
    quote_obj = crud.motivational_quote.get_latest(db)
    
    # Return 204 only if both quote and music are null
    if quote_obj is None and music_obj is None:
        return JSONResponse(status_code=204, content=None)
    
    return schemas.HomeFeed(
        quote=quote_obj,
        music=music_obj,
        music_status=music_status,
    )
