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

    async def suggest_diverse_songs(
        self, keyword: str, count: int = 3, avoid_titles: List[str] = None
    ) -> List[SongSuggestion]:
        """
        Generate multiple diverse song suggestions based on keyword/mood.
        Used for better variety in music generation flow.
        """
        avoid_titles = avoid_titles or []
        avoid_str = f" Hindari lagu: {', '.join(avoid_titles)}." if avoid_titles else ""
        
        prompt = dedent(
            f"""
            Berdasarkan kata kunci atau mood: "{keyword}", sarankan {count} lagu yang berbeda dengan genre yang beragam.
            Prioritaskan lagu-lagu populer yang mudah ditemukan di YouTube.{avoid_str}
            
            Berikan variasi genre seperti: pop, rock, indie, acoustic, electronic, R&B, dll.
            Sertakan campuran lagu Indonesia dan internasional.
            
            Format JSON array: [
                {{"title": "judul lagu 1", "artist": "artist 1"}},
                {{"title": "judul lagu 2", "artist": "artist 2"}},
                {{"title": "judul lagu 3", "artist": "artist 3"}}
            ]
            """
        ).strip()
        
        messages = [{"role": "system", "content": prompt}]
        
        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME, messages=messages
            )
            content = data["choices"][0]["message"]["content"].strip()
            
            # Clean up JSON formatting
            if content.startswith("```json"):
                content = content[len("```json") :].strip()
            if content.endswith("```"):
                content = content[:-3].strip()
            
            songs_data = json.loads(content)
            suggestions = [SongSuggestion(**song) for song in songs_data]
            
            self.log.info("diverse_music_suggestions", 
                         count=len(suggestions), 
                         keyword=keyword,
                         titles=[s.title for s in suggestions])
            return suggestions
            
        except Exception as e:
            self.log.error("diverse_music_suggestion_error", error=str(e), keyword=keyword)
            return []
    
    async def parse_music_keywords_to_suggestions(self, keyword_response: str) -> List[SongSuggestion]:
        """Parse AI-generated music keywords into structured song suggestions"""
        suggestions = []
        lines = keyword_response.split('\n')
        
        for line in lines:
            line = line.strip()
            if not line or not any(line.startswith(str(i)) for i in range(1, 10)):
                continue
                
            try:
                # Parse format: "1. \"Song Title\" - Artist (reason)"
                # Remove number prefix
                content = line.split('.', 1)[1].strip() if '.' in line else line
                
                # Extract title and artist
                if '"' in content and '-' in content:
                    # Format: "Title" - Artist (reason)
                    title_part = content.split('"')[1] if '"' in content else ""
                    remaining = content.split('"', 2)[-1].strip()
                    if remaining.startswith(' - '):
                        artist_part = remaining[3:].split('(')[0].strip()
                    else:
                        artist_part = remaining.split('(')[0].strip()
                elif '-' in content:
                    # Format: Title - Artist (reason)
                    parts = content.split(' - ', 1)
                    title_part = parts[0].strip()
                    artist_part = parts[1].split('(')[0].strip() if len(parts) > 1 else ""
                else:
                    # Fallback: assume whole line is title
                    title_part = content.split('(')[0].strip()
                    artist_part = ""
                
                if title_part:
                    suggestion = SongSuggestion(
                        title=title_part,
                        artist=artist_part if artist_part else "Unknown Artist",
                        genre="",  # Genre detection could be added later
                        reason=""  # Reason could be extracted from parentheses
                    )
                    suggestions.append(suggestion)
                    
            except Exception as e:
                self.log.warning("parse_suggestion_error", line=line, error=str(e))
                continue
        
        # Fallback if no suggestions parsed
        if not suggestions:
            suggestions = [
                SongSuggestion(title="Happy", artist="Pharrell Williams", genre="Pop", reason="Mood booster"),
                SongSuggestion(title="Weightless", artist="Marconi Union", genre="Ambient", reason="Relaxation"),
                SongSuggestion(title="Perfect", artist="Ed Sheeran", genre="Pop", reason="Feel-good music")
            ]
        
        return suggestions[:5]  # Return max 5 suggestions
