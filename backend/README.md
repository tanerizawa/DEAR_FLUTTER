# Backend

This directory hosts the FastAPI service for Dear Diary.

## Setup

Create and activate a virtual environment, then install dependencies:


```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

> **Note**: Running `pip install -r requirements.txt` is mandatory before
> starting Uvicorn. Omitting it can lead to import errors such as
> `ModuleNotFoundError` if required packages are missing.

Copy `backend/.env.example` to `.env` and edit the values before running the server.

Run the development server from within this directory:

```bash
uvicorn app.main:app --reload
```
gunicorn --preload -w 4 -k uvicorn.workers.UvicornWorker app.main:app

## Configuration

See `.env.example` for the list of required environment variables including
`DATABASE_URL` and `OPENROUTER_API_KEY`.

`LOG_LEVEL` controls verbosity for both `logging` and `structlog`. Set
`LOG_LEVEL=DEBUG` to enable detailed debug logs during development.

## Background tasks

Motivational quotes are generated automatically using Celery. Ensure Redis is running and start the worker and beat processes alongside Uvicorn:

```bash
celery -A app.celery_app.celery_app worker --loglevel=info
celery -A app.celery_app.celery_app beat --loglevel=info
```

The scheduled task `generate_quote_task` runs every 15 minutes and inserts a new
quote based on recent journal moods. `generate_music_recommendation_task` runs on
the same schedule. It extracts a keyword from the most recent journals using
`MusicKeywordService`, requests song suggestions via `MusicSuggestionService`,
performs a lightweight YouTube search to resolve a `youtube_id`, and finally
stores the resulting track in the `musictracks` table. The most recent entry can
be fetched from `/music/latest`, which the Flutter app polls every 15 minutes.

## Deploying to Render

`render.yaml` defines a Postgres database, a Redis instance and three Docker
services: the FastAPI `web` container along with separate Celery `worker` and
`beat` processes. All of them share an environment variable group named
`dear-diary-secrets`.

1. In the Render dashboard choose **New > Blueprint** and select this repository.
   Render reads `backend/render.yaml` and creates the services.
2. Create an environment group called **dear-diary-secrets** and add:
   - `OPENROUTER_API_KEY` – your OpenRouter token.
   - `DATABASE_URL` – connection string for the Postgres service.
   - `REDIS_HOST` and `REDIS_PORT` – host and port of the Redis service,
     usually `redis` and `6379`.
3. Attach the group to the `web`, `worker` and `beat` services.

Deploying the blueprint runs Gunicorn for the API and starts both Celery
processes automatically, so scheduled tasks work without extra steps.
