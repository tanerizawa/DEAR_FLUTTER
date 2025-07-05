from fastapi import APIRouter
from app.api.v1 import auth, journal, chat, user, article, quote, home
from app.api.v1.music import router as music_router
from app.api.v1 import debug
from app.api.v1.health import router as health_router

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(journal.router, prefix="/journals", tags=["journals"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(user.router, prefix="/users", tags=["users"])
api_router.include_router(article.router, prefix="/articles", tags=["articles"])
api_router.include_router(quote.router, prefix="/quotes", tags=["quotes"])
api_router.include_router(home.router, tags=["home"])
api_router.include_router(music_router, prefix="/music", tags=["music"])
api_router.include_router(debug.router, prefix="/debug", tags=["debug"])
api_router.include_router(health_router, prefix="/health", tags=["health"])
