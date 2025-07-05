# backend/app/services/prompt_builder_service.py

from typing import List, Optional
from app.schemas.journal import JournalInDB
from app.schemas.chat import ChatMessageInDBBase
from app.schemas.song import SongSuggestion

def summarize_journals(journals: List[JournalInDB]) -> str:
    if not journals:
        return "Tidak ada jurnal terbaru."
    # Ambil 1-2 jurnal terakhir, ringkas isi
    return "; ".join(j.content[:100] for j in journals[-2:])

def summarize_chats(chats: List[ChatMessageInDBBase]) -> str:
    if not chats:
        return "Tidak ada chat terbaru."
    # Ambil 1-2 chat terakhir, ringkas isi
    return "; ".join(c.content[:100] for c in chats[-2:])

def build_dynamic_prompt(journals: List[JournalInDB], chats: List[ChatMessageInDBBase], mood: Optional[str], last_tracks: List[SongSuggestion]) -> str:
    journal_summary = summarize_journals(journals)
    chat_summary = summarize_chats(chats)
    mood_str = f"Mood terakhir: {mood}" if mood else ""
    last_tracks_str = ", ".join([t.title for t in last_tracks[-3:]]) if last_tracks else ""
    prompt = f"""
    Berdasarkan data berikut:
    - Jurnal terbaru user: {journal_summary}
    - Chat terbaru user: {chat_summary}
    - {mood_str}
    - Lagu terakhir yang diputar: {last_tracks_str}
    Rekomendasikan 10 lagu (title & artist) yang paling merepresentasikan perasaan, aktivitas, dan kebutuhan user hari ini.
    Balas hanya array JSON valid: [{{\"title\": \"...\", \"artist\": \"...\"}}]
    """
    return prompt.strip()
