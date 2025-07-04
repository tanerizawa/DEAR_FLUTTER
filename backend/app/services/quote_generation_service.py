# backend/app/services/quote_generation_service.py

import httpx
import structlog
import re # -> Import library regular expression
from fastapi import Depends
from textwrap import dedent
from typing import List, Dict, Tuple

from app.core.config import Settings, settings


class QuoteGenerationService:
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

    def _parse_quote(self, content: str) -> Tuple[str, str]:
        """
        Memisahkan teks kutipan dan penulis dengan lebih cerdas.
        """
        # Pola untuk mencari pemisah seperti ' - ' atau ' — '
        match = re.search(r'\s+[-—]\s+([\w\s]+)$', content)
        
        if match:
            # Jika ditemukan, pisahkan berdasarkan pola tersebut
            author = match.group(1).strip()
            text = content[:match.start()].strip().strip('"')
            return text, author
        else:
            # Jika tidak ada pemisah, anggap penulisnya 'Unknown'
            return content.strip().strip('"'), "Unknown"

    async def generate_quote(self, mood: str) -> Tuple[str, str]:
        """Menghasilkan satu kutipan motivasi singkat dan penulisnya."""
        
        # --- PERBAIKAN PADA PROMPT ---
        prompt = dedent(
            f"""
            Buat HANYA SATU kutipan motivasi yang singkat (maksimal 160 karakter) 
            sesuai dengan suasana hati '{mood}'.
            Setelah kutipan, sertakan nama penulisnya diawali dengan tanda pemisah ' - '.
            Contoh: "Ini adalah kutipan. - Penulis"
            JANGAN membuat beberapa kutipan. JANGAN menggunakan format list atau bullet.
            """
        ).strip()

        messages = [{"role": "system", "content": prompt}]

        try:
            data = await self._call_openrouter(
                model=self.settings.GENERATOR_MODEL_NAME,
                messages=messages,
            )
            content = data["choices"][0]["message"]["content"].strip()
            
            # --- PERBAIKAN PADA LOGIKA PARSING ---
            text, author = self._parse_quote(content)
            
            # Memastikan teks tidak melebihi batas (sebagai pengaman tambahan)
            if len(text) > 160:
                text = text[:157] + "..."
            
            return text, author
        except Exception as e:
            self.log.error("quote_generation_error", error=str(e))
            return "", ""