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
stores the resulting `AudioTrack` in memory via `set_latest_music`. The most
recent track can be fetched from `/music/latest`, which the Flutter app polls
every 15 minutes.

