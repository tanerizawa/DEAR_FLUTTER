"""Utilities for generating a music keyword suggestion."""

import httpx
import structlog
from typing import List, Dict, Optional
from textwrap import dedent
import json

from fastapi import Depends

from app.core.config import Settings, settings
from app.models.journal import Journal
from app.models.user_profile import UserProfile


class MusicKeywordService:
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
                timeout=20.0,
            )
            response.raise_for_status()
            return response.json()

    async def generate_keyword(self, journals: List[Journal], user_profile: Optional[UserProfile] = None) -> str:
        """Generate a music keyword based on journal entries and psychological profile."""
        sorted_journals = sorted(
            journals,
            key=lambda j: getattr(j, "created_at", 0),
            reverse=True,
        )
        
        # Prepare journal content with mood and sentiment
        journal_analysis = []
        for j in sorted_journals[:5]:
            journal_info = {
                "content": j.content,
                "mood": getattr(j, "mood", "netral"),
                "sentiment_score": getattr(j, "sentiment_score", 0.0),
                "sentiment_label": getattr(j, "sentiment_label", "netral"),
                "created_at": str(getattr(j, "created_at", ""))
            }
            journal_analysis.append(journal_info)
        
        # Build psychological context
        psychological_context = ""
        if user_profile:
            emerging_themes = getattr(user_profile, "emerging_themes", {}) or {}
            sentiment_trend = getattr(user_profile, "sentiment_trend", "stabil")
            
            if emerging_themes:
                themes_text = ", ".join([f"{tema}: {score:.1f}" for tema, score in emerging_themes.items()])
                psychological_context = f"\n\nKonteks Psikologis Pengguna:\n- Tema dominan: {themes_text}\n- Tren sentimen: {sentiment_trend}"
        
        # Enhanced prompt with psychological analysis
        prompt = dedent(
            f"""
            Kamu adalah AI musik therapist yang ahli dalam menganalisis kondisi psikologis dan merekomendasikan musik yang tepat.
            
            Berdasarkan data berikut, buatlah 5 rekomendasi musik yang sesuai dengan kondisi emosional dan psikologis pengguna:
            
            ANALISIS JURNAL TERBARU:
            {json.dumps(journal_analysis, indent=2, ensure_ascii=False)}
            {psychological_context}
            
            INSTRUKSI:
            1. Analisis pola emosi dari jurnal dan mood yang terdeteksi
            2. Pertimbangkan sentiment score dan trend psikologis jika tersedia
            3. Rekomendasikan musik yang bisa memberikan dukungan emosional atau healing
            4. Berikan variasi genre dan suasana (uplifting, calming, energizing, dll)
            5. Format output: "Judul Lagu" - Artis (alasan singkat)
            
            Contoh format output:
            1. "Weightless" - Marconi Union (musik ambient untuk relaksasi dan mengurangi kecemasan)
            2. "Happy" - Pharrell Williams (musik upbeat untuk meningkatkan mood positif)
            3. "The Sound of Silence" - Simon & Garfunkel (musik contemplatif untuk refleksi diri)
            4. "Shake It Off" - Taylor Swift (musik energik untuk membangun kepercayaan diri)
            5. "Clair de Lune" - Claude Debussy (musik klasik untuk ketenangan jiwa)
            
            Berikan 5 rekomendasi musik yang paling sesuai:
            """
        ).strip()

        messages = [{"role": "system", "content": prompt}]

        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME,
                messages=messages,
            )
            keyword = data["choices"][0]["message"]["content"].strip()
            self.log.info("music_keyword_generated", keyword=keyword)
            return keyword
        except Exception as e:
            self.log.error("music_keyword_service_error", error=str(e))
            # Fallback to simple keyword if AI fails
            return self._generate_fallback_keyword(journals)

    def _generate_fallback_keyword(self, journals: List[Journal]) -> str:
        """Generate fallback keyword if AI service fails"""
        if not journals:
            return "1. \"Weightless\" - Marconi Union (musik relaksasi)\n2. \"Happy\" - Pharrell Williams (musik positif)"
        
        # Simple mood-based fallback
        moods = [getattr(j, "mood", "netral") for j in journals[:3]]
        mood_counts = {}
        for mood in moods:
            mood_counts[mood] = mood_counts.get(mood, 0) + 1
        
        dominant_mood = max(mood_counts, key=mood_counts.get) if mood_counts else "netral"
        
        fallback_recommendations = {
            "bahagia": "1. \"Happy\" - Pharrell Williams\n2. \"Good as Hell\" - Lizzo\n3. \"Can't Stop the Feeling\" - Justin Timberlake",
            "sedih": "1. \"The Sound of Silence\" - Simon & Garfunkel\n2. \"Mad World\" - Gary Jules\n3. \"Hurt\" - Johnny Cash",
            "marah": "1. \"Angry Too\" - Lola Blanc\n2. \"Break Stuff\" - Limp Bizkit\n3. \"Killing in the Name\" - Rage Against the Machine",
            "cemas": "1. \"Weightless\" - Marconi Union\n2. \"Clair de Lune\" - Claude Debussy\n3. \"Aqueous Transmission\" - Incubus",
            "stress": "1. \"Breathe Me\" - Sia\n2. \"The Scientist\" - Coldplay\n3. \"Skinny Love\" - Bon Iver",
            "lelah": "1. \"Tired\" - Alan Walker\n2. \"Heavy\" - Linkin Park ft. Kiiara\n3. \"Exhausted\" - Foo Fighters",
            "netral": "1. \"Perfect\" - Ed Sheeran\n2. \"Count on Me\" - Bruno Mars\n3. \"Better Days\" - OneRepublic"
        }
        
        return fallback_recommendations.get(dominant_mood, fallback_recommendations["netral"])

    async def generate_diverse_recommendations(self, journals: List[Journal], user_profile: Optional[UserProfile] = None, count: int = 5) -> List[str]:
        """Generate diverse music recommendations with psychological insight"""
        keyword_response = await self.generate_keyword(journals, user_profile)
        
        # Parse the AI response to extract individual recommendations
        recommendations = []
        lines = keyword_response.split('\n')
        
        for line in lines:
            line = line.strip()
            if line and (line.startswith(('1.', '2.', '3.', '4.', '5.')) or '-' in line):
                recommendations.append(line)
        
        # If we don't have enough recommendations, add fallbacks
        if len(recommendations) < count:
            fallback = self._generate_fallback_keyword(journals)
            fallback_lines = fallback.split('\n')
            for line in fallback_lines:
                if len(recommendations) >= count:
                    break
                if line.strip() and line.strip() not in recommendations:
                    recommendations.append(line.strip())
        
        return recommendations[:count]
