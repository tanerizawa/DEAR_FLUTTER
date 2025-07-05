# app/core/config.py

import os
from pydantic_settings import BaseSettings, SettingsConfigDict

# Tentukan path ke file .env. Ini membantu pydantic-settings menemukannya.
# Di Render, Secret Files akan ditempatkan di root direktori.
dotenv_path = os.path.join(os.path.dirname(__file__), "..", "..", ".env")


class Settings(BaseSettings):
    # --- Konfigurasi pydantic-settings ---
    # Ini memberi tahu Pydantic untuk membaca dari file .env DAN dari environment variables.
    # Variabel lingkungan sistem (seperti yang di-inject oleh Render) akan menimpa nilai dari .env.
    model_config = SettingsConfigDict(
        env_file=dotenv_path,
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",  # Abaikan variabel ekstra yang tidak didefinisikan di model ini
    )

    # --- Variabel yang Dibutuhkan Aplikasi ---

    # Pengaturan Aplikasi Utama
    PROJECT_NAME: str = "Dear Diary API"
    PROJECT_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"  # Default ke development, akan ditimpa di produksi
    APP_NAME: str = "Dear Diary API"
    APP_SITE_URL: str = "http://localhost"

    # Database & Redis - WAJIB ADA
    DATABASE_URL: str
    CELERY_BROKER_URL: str
    CELERY_RESULT_BACKEND: str

    # Keamanan - WAJIB ADA
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 hari

    # Kredensial & Konfigurasi Layanan Eksternal
    OPENROUTER_API_KEY: str | None = None
    OPENROUTER_BASE_URL: str = "https://openrouter.ai/api/v1"
    PLANNER_MODEL_NAME: str = "deepseek/deepseek-chat-v3-0324"
    GENERATOR_MODEL_NAME: str = "deepseek/deepseek-chat-v3-0324"

    # Pengaturan Opsional (Contoh: CORS, Sentry)
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://127.0.0.1:3000"
    SENTRY_DSN: str | None = None
    LOG_LEVEL: str = "INFO"

    # --- Konfigurasi Pembatasan Laju dan Performa ---

    # Konfigurasi Pembatasan Laju
    RATE_LIMIT_ENABLED: bool = True
    YOUTUBE_REQUESTS_PER_MINUTE: int = 5
    YOUTUBE_REQUESTS_PER_HOUR: int = 30
    MUSIC_GENERATION_REQUESTS_PER_HOUR: int = 10

    # Konfigurasi YouTube
    YOUTUBE_MAX_RETRIES: int = 2
    YOUTUBE_TIMEOUT_SECONDS: int = 45
    YOUTUBE_CONCURRENT_REQUESTS: int = 2
    YOUTUBE_MIN_INTERVAL_SECONDS: int = 3

    # Konfigurasi Respons
    MAX_RESPONSE_SIZE_MB: float = 10.0
    ENABLE_COMPRESSION: bool = True

    # Konfigurasi Server
    WORKER_TIMEOUT: int = 300  # 5 menit
    MAX_REQUEST_SIZE: int = 50 * 1024 * 1024  # 50MB

    # Konfigurasi Cache
    CACHE_TTL_SECONDS: int = 3600  # 1 jam
    MAX_CACHE_ENTRIES: int = 1000


# Buat satu instance settings untuk digunakan di seluruh aplikasi
settings = Settings()
