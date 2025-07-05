# ENHANCED_MUSIC_TRIGGER_SYSTEM.md

## 🎵 **SISTEM TRIGGER LAGU YANG DIPERKAYA**

### **📋 OVERVIEW**

Sistem trigger lagu telah ditingkatkan untuk memberikan rekomendasi musik yang lebih personal dan kontekstual berdasarkan:
- ✅ **Isi jurnal** pengguna (content, mood, sentiment)
- ✅ **Profil psikologi** pengguna (emerging themes, sentiment trends)
- ✅ **Konteks emosional** yang lebih mendalam
- ✅ **Variasi genre** dan suasana musik

---

## 🔄 **FLOW TRIGGER SYSTEM**

### **1. Auto-Trigger saat Journal Save**
```
Pengguna Menulis Jurnal 
    ↓
Journal API → create_journal()
    ↓
Background Tasks:
- analyze_profile_task() → Update profil psikologi
- run_music_generation_flow(user_id) → Generate musik personal
    ↓
AI Music Therapist Analysis
    ↓
5 Rekomendasi Musik Kontekstual
```

### **2. Manual Trigger**
```
User Request → /music/trigger-generation
    ↓
run_music_generation_flow(user_id) → Personal music
    
Admin Request → /music/trigger-generation-global  
    ↓
run_music_generation_flow(None) → Global music
```

---

## 🧠 **ENHANCED AI PROMPT**

### **Data Input ke OpenRouter:**
```json
{
  "journals": [
    {
      "content": "Hari ini aku merasa...",
      "mood": "sedih",
      "sentiment_score": -0.3,
      "sentiment_label": "negative",
      "created_at": "2025-01-06"
    }
  ],
  "psychological_context": {
    "emerging_themes": {
      "pekerjaan": 0.8,
      "hubungan": 0.6,
      "kecemasan": 0.4
    },
    "sentiment_trend": "menurun"
  }
}
```

### **AI Prompt Template:**
```
Kamu adalah AI musik therapist yang ahli dalam menganalisis kondisi psikologis dan merekomendasikan musik yang tepat.

ANALISIS JURNAL TERBARU:
[Journal data dengan mood, sentiment, content]

KONTEKS PSIKOLOGIS PENGGUNA:
- Tema dominan: pekerjaan (0.8), hubungan (0.6)
- Tren sentimen: menurun

INSTRUKSI:
1. Analisis pola emosi dari jurnal dan mood yang terdeteksi
2. Pertimbangkan sentiment score dan trend psikologis
3. Rekomendasikan musik untuk dukungan emosional/healing
4. Berikan variasi genre dan suasana (uplifting, calming, energizing)
5. Format: "Judul Lagu" - Artis (alasan singkat)

Output: 5 rekomendasi musik yang sesuai
```

### **Contoh AI Response:**
```
1. "Weightless" - Marconi Union (musik ambient untuk relaksasi dan mengurangi kecemasan)
2. "The Scientist" - Coldplay (musik contemplatif untuk refleksi masalah pekerjaan)
3. "Shake It Off" - Taylor Swift (musik energik untuk membangun kepercayaan diri)
4. "Clair de Lune" - Claude Debussy (musik klasik untuk ketenangan jiwa)
5. "Count on Me" - Bruno Mars (musik positif untuk dukungan dalam hubungan)
```

---

## 🛠️ **TECHNICAL IMPLEMENTATION**

### **Backend Components:**

#### **1. Enhanced MusicKeywordService**
```python
async def generate_keyword(journals, user_profile=None) -> str
async def generate_diverse_recommendations(journals, user_profile, count=5) -> List[str]
def _generate_fallback_keyword(journals) -> str
```

#### **2. Enhanced MusicSuggestionService**
```python
async def parse_music_keywords_to_suggestions(keyword_response) -> List[SongSuggestion]
```

#### **3. Updated Tasks**
```python
async def run_music_generation_flow(user_id=None)
# - Support user-specific dan global generation
# - Include psychological profile context
# - Enhanced error handling dan fallbacks
```

#### **4. Auto-Trigger di Journal API**
```python
@router.post("/")
def create_journal(...):
    # Save journal
    background_tasks.add_task(analyze_profile_task, user_id)
    background_tasks.add_task(run_music_generation_flow, user_id)  # AUTO-TRIGGER
```

### **API Endpoints:**

#### **Personal Music Generation**
```http
POST /v1/music/trigger-generation
Authorization: Bearer <token>

Response: {
  "message": "Personalized music recommendation generation process has been started."
}
```

#### **Global Music Generation (Admin)**
```http
POST /v1/music/trigger-generation-global
Authorization: Bearer <token>

Response: {
  "message": "Global music recommendation generation process has been started."
}
```

---

## 📊 **PSYCHOLOGICAL CONTEXT VARIABLES**

### **Dari UserProfile Model:**
```python
emerging_themes: {
    "pekerjaan": 0.8,      # Dominance score 0-1
    "hubungan": 0.6,
    "kecemasan": 0.4,
    "kesehatan": 0.3,
    "keluarga": 0.7
}

sentiment_trend: "menurun" | "meningkat" | "stabil"
```

### **Dari Journal Model:**
```python
content: str           # Isi jurnal lengkap
mood: str             # "bahagia", "sedih", "marah", "cemas", dll
sentiment_score: float # -1.0 to 1.0
sentiment_label: str   # "positive", "negative", "neutral"
created_at: datetime   # Untuk temporal analysis
```

---

## 🎯 **MUSIC RECOMMENDATION LOGIC**

### **Mood-Based Recommendations:**
```python
mood_music_mapping = {
    "bahagia": ["Happy - Pharrell Williams", "Good as Hell - Lizzo"],
    "sedih": ["The Sound of Silence - Simon & Garfunkel", "Mad World - Gary Jules"],
    "marah": ["Angry Too - Lola Blanc", "Break Stuff - Limp Bizkit"],
    "cemas": ["Weightless - Marconi Union", "Clair de Lune - Claude Debussy"],
    "stress": ["Breathe Me - Sia", "The Scientist - Coldplay"],
    "lelah": ["Tired - Alan Walker", "Heavy - Linkin Park"],
    "netral": ["Perfect - Ed Sheeran", "Count on Me - Bruno Mars"]
}
```

### **Theme-Based Adjustments:**
```python
theme_adjustments = {
    "pekerjaan": "Focus on work-stress relief music",
    "hubungan": "Include relationship/love songs", 
    "kecemasan": "Prioritize calming/ambient music",
    "kesehatan": "Include healing/recovery music"
}
```

### **Sentiment Trend Considerations:**
```python
trend_adjustments = {
    "menurun": "Include uplifting/motivational music",
    "meningkat": "Maintain positive energy music",
    "stabil": "Balanced mix of genres"
}
```

---

## 🔍 **FALLBACK STRATEGIES**

### **1. AI Service Failure:**
```python
if ai_service_fails:
    return mood_based_fallback_recommendations()
```

### **2. No User Profile:**
```python
if no_user_profile:
    use_journal_mood_only()
```

### **3. No Recent Journals:**
```python
if no_journals:
    return default_wellness_music()
```

### **4. Parsing Failure:**
```python
if parsing_fails:
    return structured_fallback_suggestions()
```

---

## 📈 **MONITORING & ANALYTICS**

### **Logging Points:**
```python
log.info("music_generation_flow:start", user_id=user_id)
log.info("music_generation_flow:profile_loaded", has_profile=True, themes=emerging_themes)
log.info("music_generation_flow:keyword_generated", keyword=keyword)
log.info("music_generation_flow:ai_recommendations", count=len(recommendations))
log.info("music_generation_flow:success_extraction", title=title, strategy=strategy)
```

### **Success Metrics:**
- ✅ Music generation completion rate
- ✅ AI recommendation quality (user feedback)
- ✅ YouTube extraction success rate
- ✅ User engagement with recommended music

---

## 🚀 **TESTING & VALIDATION**

### **Test Cases:**
1. **Journal Save Auto-Trigger**
   - Save journal → Verify music generation triggered
   - Check personalized recommendations based on mood

2. **Psychological Context Integration**
   - User with profile themes → Verify theme-aware music
   - User without profile → Verify fallback to mood-based

3. **AI Response Parsing**
   - Valid AI response → Verify correct song extraction
   - Invalid AI response → Verify fallback mechanisms

4. **Multi-Language Support**
   - Indonesian content → Verify AI understands context
   - Mixed language → Verify robust processing

### **Load Testing:**
```bash
# Test concurrent journal saves
ab -n 100 -c 10 -H "Authorization: Bearer <token>" \
   -p journal_payload.json \
   http://localhost:8000/v1/journals/

# Test music generation endpoints
ab -n 50 -c 5 -H "Authorization: Bearer <token>" \
   http://localhost:8000/v1/music/trigger-generation
```

---

## 📝 **SUMMARY**

**SEBELUM:**
- ❌ Trigger hanya dari manual API call
- ❌ Hanya menggunakan keyword sederhana dari jurnal
- ❌ Tidak ada konteks psikologi
- ❌ Rekomendasi musik generic

**SESUDAH:**
- ✅ Auto-trigger saat journal save
- ✅ AI musik therapist dengan analisis mendalam
- ✅ Konteks psikologi (themes, sentiment trends)
- ✅ 5 rekomendasi musik personal dengan alasan
- ✅ Fallback strategies untuk robustness
- ✅ Support personal & global generation

**IMPACT:**
- 🎯 Musik lebih relevan dengan kondisi emosional user
- 🎯 Personalisasi berdasarkan profil psikologi
- 🎯 Automatic music therapy setelah journaling
- 🎯 Better user engagement dan wellness support
