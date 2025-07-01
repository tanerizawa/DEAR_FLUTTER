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
        self.api_base_url = "https://openrouter.ai/api/v1"
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
                timeout=20.0,
            )
            response.raise_for_status()
            return response.json()

    async def suggest_songs(
        self, mood: str, user_profile: Optional[UserProfile] = None
    ) -> List[SongSuggestion]:
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
            Sarankan tiga lagu beserta artis yang cocok untuk mood berikut: {mood}.
            {profile_summary}
            Balas dengan JSON list berisi objek {{"title": "...", "artist": "..."}}.
            """
        ).strip()

        messages = [{"role": "system", "content": prompt}]

        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME,
                messages=messages,
            )
            content = data["choices"][0]["message"]["content"].strip()
            if content.startswith("```json"):
                content = content[len("```json") :].strip()
            if content.endswith("```"):
                content = content[:-3].strip()
            items = json.loads(content)
            return [SongSuggestion(**item) for item in items]
        except Exception as e:
            self.log.error("music_suggestion_error", error=str(e))
            return []
