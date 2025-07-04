# backend/app/main.py

import os
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


from app.api.api import api_router
from app.core.config import settings
import sentry_sdk
import structlog

# --- Setup Logging ---
log_level = logging.getLevelName(settings.LOG_LEVEL)
logging.basicConfig(level=log_level)
structlog.configure(
    wrapper_class=structlog.make_filtering_bound_logger(log_level),
)
logger = structlog.get_logger()

# --- Inisialisasi Sentry ---
SENTRY_DSN = os.getenv("SENTRY_DSN", None)

if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        traces_sample_rate=1.0,  # Untuk performance monitoring
        profiles_sample_rate=1.0,  # Untuk profiling detail
        environment=os.getenv("ENVIRONMENT", "development"),
    )
    logger.info(
        "Sentry initialized", environment=os.getenv("ENVIRONMENT", "development")
    )


# --- Lifespan: Migrasi database saat startup ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Logika migrasi telah dipindahkan ke build.sh
    logger.info("Application startup...")
    yield
    logger.info("Application shutdown complete.")


# --- Inisialisasi FastAPI App ---
app = FastAPI(title="Dear Diary API", lifespan=lifespan)

# Add response handling middleware to prevent Content-Length mismatch
from app.core.response_handler import ResponseHandlerMiddleware

app.add_middleware(ResponseHandlerMiddleware)

# --- Setup CORS ---
allowed_origins_str = os.getenv("ALLOWED_ORIGINS", "")
allowed_origins = allowed_origins_str.split(",") if allowed_origins_str else []

if not allowed_origins and os.getenv("ENVIRONMENT") == "production":
    allowed_origins = []
elif not allowed_origins:
    allowed_origins = ["http://localhost:3000", "http://127.0.0.1:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routing API ---
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
def read_root():
    logger.info("Root endpoint accessed")
    return {"message": "Welcome to Dear Diary API"}
