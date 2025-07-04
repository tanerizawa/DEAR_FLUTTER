# backend/app/api/v1/quote.py

from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from app import crud, schemas, models
from app.dependencies import get_db, get_current_user
# Import tugas yang akan kita panggil
from app.tasks import generate_quote_task

router = APIRouter()


@router.get("/", response_model=list[schemas.MotivationalQuote])
def get_quotes(db: Session = Depends(get_db)):
    return crud.motivational_quote.get_multi(db)


@router.get("/latest", response_model=schemas.MotivationalQuote | None)
def get_latest_quote(db: Session = Depends(get_db)):
    return crud.motivational_quote.get_latest(db)


# --- ENDPOINT BARU UNTUK MEMICU GENERASI KUTIPAN ---
@router.post("/trigger-generation", status_code=202)
async def trigger_quote_generation(
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(get_current_user),
):
    """
    Memicu proses generasi kutipan motivasi di latar belakang.
    """
    # Menambahkan tugas ke background agar API merespons dengan cepat
    background_tasks.add_task(generate_quote_task)
    return {"message": "Quote generation process has been started."}