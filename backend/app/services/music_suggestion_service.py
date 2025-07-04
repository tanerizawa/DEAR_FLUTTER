# backend/app/services/music_suggestion_service.py

import json
from textwrap import dedent
from typing import List, Dict, Optional

import httpx
import structlog
from fastapi import Depends

from app.core.config import Settings, settings
from app.models.user_profile import UserProfile
from app.schemas.song import SongSuggestion


class MusicSuggestionService:
    """Service for generating song recommendations via OpenRouter."""

    def __init__(self, settings: Settings = Depends(lambda: settings)):
        self.settings = settings
        self.api_base_url = self.settings.OPENROUTER_BASE_URL
        self.log = structlog.get_logger(__name__)

    async def _call_openrouter(
        self, model: str, messages: List[Dict[str, str]]
    ) -> Dict:
        headers = {"Authorization": f"Bearer {self.settings.OPENROUTER_API_KEY}"}
        json_data = {"model": model, "messages": messages}
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_base_url}/chat/completions",
                headers=headers,
                json=json_data,
                timeout=30.0, # Tambahkan timeout sedikit lebih lama untuk playlist
            )
            response.raise_for_status()
            return response.json()

    async def suggest_song(
        self, mood: str, user_profile: Optional[UserProfile] = None
    ) -> SongSuggestion | None:
        # Fungsi ini tetap ada untuk fitur "Lagu Perasaan" Anda
        # (Tidak perlu diubah)
        # ... implementasi suggest_song yang sudah ada ...
        profile_summary = ""
        if user_profile:
            emerging = user_profile.emerging_themes or {}
            themes_str = (
                ", ".join(f"{k} ({v:.0%})" for k, v in emerging.items())
                if emerging
                else "Tidak tersedia"
            )
            sentiment = user_profile.sentiment_trend or "Tidak tersedia"
            profile_summary = f"Tema: {themes_str}; Tren emosi: {sentiment}."

        prompt = dedent(
            f"""
            Sarankan satu lagu beserta artis yang cocok untuk mood berikut: {mood}.
            {profile_summary}
            Balas dengan JSON {{"title": "...", "artist": "..."}} saja.
            """
        ).strip()
        messages = [{"role": "system", "content": prompt}]
        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME, messages=messages
            )
            content = data["choices"][0]["message"]["content"].strip()
            if content.startswith("```json"):
                content = content[len("```json") :].strip()
            if content.endswith("```"):
                content = content[:-3].strip()
            item = json.loads(content)
            self.log.info("music_suggestion_result", item=item)
            return SongSuggestion(**item)
        except Exception as e:
            self.log.error("music_suggestion_error", error=str(e))
            return None


    # --- FUNGSI BARU UNTUK RADIO STATION ---
    async def suggest_playlist_for_activity(self, category: str) -> List[SongSuggestion]:
        """Menyarankan 10 lagu untuk sebuah kategori aktivitas."""
        
        prompt_map = {
            "fokus": "instrumental, lo-fi, atau musik klasik tanpa vokal untuk membantu fokus saat bekerja atau belajar.",
            "santai": "akustik, ambient, atau jazz yang menenangkan untuk bersantai.",
            "semangat": "upbeat, pop, atau elektronik yang membangkitkan semangat di pagi hari."
        }
        
        description = prompt_map.get(category, "musik populer umum")

        prompt = dedent(
            f"""
            Buat sebuah daftar putar berisi 10 lagu {description}
            Balas HANYA dengan array JSON valid yang berisi objek dengan key "title" dan "artist".
            Contoh: [{{"title": "Judul A", "artist": "Artis A"}}, {{"title": "Judul B", "artist": "Artis B"}}]
            """
        ).strip()

        messages = [{"role": "system", "content": prompt}]

        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME, messages=messages
            )
            content = data["choices"][0]["message"]["content"].strip()
            
            # Membersihkan jika ada blok kode markdown
            if content.startswith("```json"):
                content = content[len("```json") :].strip()
            if content.endswith("```"):
                content = content[:-3].strip()
                
            items = json.loads(content)
            return [SongSuggestion(**item) for item in items]
        except Exception as e:
            self.log.error("playlist_suggestion_error", error=str(e), category=category)
            return []