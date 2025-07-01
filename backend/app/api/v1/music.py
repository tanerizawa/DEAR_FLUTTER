# backend/app/api/v1/music.py (Versi Final dengan Logika VideoID)

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from spotipy import Spotify
from spotipy.oauth2 import SpotifyClientCredentials
import structlog

from app import crud, models, schemas, dependencies
from app.core.config import settings
from app.services.music_suggestion_service import MusicSuggestionService
from app.state.music import get_latest_music as _get_latest_music

router = APIRouter()
log = structlog.get_logger(__name__)

# --- Spotify client will be initialized lazily ---
spotify: Spotify | None = None


def get_spotify() -> Spotify:
    """Return a Spotify client or raise 503 if credentials are missing."""
    global spotify
    if spotify is not None:
        return spotify

    if not settings.SPOTIFY_CLIENT_ID or not settings.SPOTIFY_CLIENT_SECRET:
        log.warning("Spotify credentials missing")
        raise HTTPException(status_code=503, detail="Spotify credentials missing")

    try:
        creds = SpotifyClientCredentials(
            client_id=settings.SPOTIFY_CLIENT_ID,
            client_secret=settings.SPOTIFY_CLIENT_SECRET,
        )
        spotify = Spotify(auth_manager=creds)
        log.info("Spotify client initialized")
        return spotify
    except Exception as e:
        log.error("Failed to initialize Spotify client", error=str(e))
        raise HTTPException(status_code=503, detail="Spotify initialization failed")


# --- Akhir Blok Inisialisasi ---


# --- PERBAIKAN LOGIKA FUNDAMENTAL DI SINI ---
def _process_search_results(search_results: dict) -> list[schemas.AudioTrack]:
    """
    Helper function to process search results and return a list of AudioTrack.
    Tugas fungsi ini HANYA untuk memformat hasil pencarian, BUKAN untuk mendapatkan URL stream.
    """
    musics: list[schemas.AudioTrack] = []
    if not search_results:
        return musics

    tracks = search_results.get("tracks", {}).get("items", [])
    for idx, track in enumerate(tracks, start=1):
        title = track.get("name")
        preview = track.get("preview_url")
        external = track.get("external_urls", {}).get("spotify")
        youtube_id = preview or external or track.get("id")
        if youtube_id and title:
            musics.append(
                schemas.AudioTrack(id=idx, title=title, youtube_id=youtube_id)
            )

    return musics


# --- AKHIR PERBAIKAN ---


@router.get("/", response_model=list[schemas.AudioTrack])
def search_music(
    mood: str = Query(..., min_length=1),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    if not mood:
        raise HTTPException(status_code=400, detail="Mood parameter is required")

    try:
        client = get_spotify()
        search_results = client.search(q=mood, type="track", limit=20)
        musics = _process_search_results(search_results)
    except Exception as e:
        log.error("Pencarian musik manual gagal", query=mood, error=str(e))
        raise HTTPException(
            status_code=503, detail="Layanan pencarian musik sedang bermasalah."
        )

    if not musics:
        raise HTTPException(status_code=404, detail="No music found for the given mood")

    return musics


@router.get("/recommend", response_model=list[schemas.SongSuggestion])
async def recommend_music(
    *,
    mood: str = Query(..., min_length=1),
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
    suggestion_service: MusicSuggestionService = Depends(),
):
    profile = crud.user_profile.get_by_user_id(db, user_id=current_user.id)
    return await suggestion_service.suggest_songs(mood=mood, user_profile=profile)


@router.get("/latest", response_model=schemas.AudioTrack | None)
def get_latest_music() -> schemas.AudioTrack | None:
    """Return the most recently generated music recommendation."""
    return _get_latest_music()
