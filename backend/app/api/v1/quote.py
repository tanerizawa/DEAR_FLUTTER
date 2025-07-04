# backend/app/api/v1/quote.py

import asyncio
from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from app import crud, schemas, models
from app.dependencies import get_db, get_current_user
from app.tasks import generate_quote_task

router = APIRouter()

# --- FUNGSI PEMBUNGKUS UNTUK MENJALANKAN TUGAS ASYNC ---
def run_async_task(task):
    """Fungsi ini menjalankan event loop untuk await coroutine."""
    asyncio.run(task)


@router.get("/", response_model=list[schemas.MotivationalQuote])
def get_quotes(db: Session = Depends(get_db)):
    return crud.motivational_quote.get_multi(db)


@router.get("/latest", response_model=schemas.MotivationalQuote | None)
def get_latest_quote(db: Session = Depends(get_db)):
    return crud.motivational_quote.get_latest(db)


@router.post("/trigger-generation", status_code=202)
async def trigger_quote_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(get_current_user),
):
    """
    Memicu proses generasi kutipan motivasi di latar belakang.
    """
    # --- PERBAIKAN: Panggil fungsi pembungkus, bukan tugasnya langsung ---
    # Kita sekarang memberikan fungsi pembungkus ke BackgroundTasks,
    # dan tugas async kita sebagai argumennya.
    background_tasks.add_task(run_async_task, generate_quote_task())
    return {"message": "Quote generation process has been started."}