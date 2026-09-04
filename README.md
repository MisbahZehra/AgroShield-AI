# AgroShield AI

**On-device crop disease detection for smallholder farmers in Pakistan.**

AgroShield AI is a mobile Android application that uses TensorFlow Lite machine learning to detect crop diseases directly on a farmer's phone — no internet required for scanning. Farmers snap a photo of a diseased leaf and receive an instant diagnosis with verified treatment recommendations, all in their local language.

---

## Problem

Smallholder farmers in Pakistan lose 20–40% of crop yield annually to diseases they cannot identify. Extension officers are scarce, lab testing takes days, and by the time a diagnosis arrives, the damage is done. Most farmers cannot read English pesticide labels and rely on guesswork for chemical selection and dosing.

## Solution

AgroShield AI puts a trained plant-pathologist in every farmer's pocket:

- **Offline TFLite inference** — detect diseases in under 2 seconds, no internet needed
- **32 disease classes** across 5 major crops (wheat, rice, corn, tomato, sugarcane)
- **Verified treatment data** — real fungicide/insecticide product names, doses, and rates sourced from Pakistani agricultural research
- **Multilingual** — English, Urdu, Sindhi, and Pashto interface
- **AI assistant** — ask questions in natural language (English or Roman Urdu) and get grounded answers
- **7-day risk forecasting** — weather-aware disease risk alerts using OpenWeather API
- **Accessibility-first** — text-to-speech on every screen for low-literacy users

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Flutter Android App                  │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐ │
│  │ Camera / │  │ TFLite   │  │ Riverpod State    │ │
│  │ Gallery  │→ │ Inference│→ │ Management        │ │
│  │ Input    │  │ (FP16)   │  │ + go_router Nav   │ │
│  └──────────┘  └──────────┘  └───────────────────┘ │
│        │              │              │               │
│        ▼              ▼              ▼               │
│  ┌──────────────────────────────────────────────┐   │
│  │         Verified Knowledge Base               │   │
│  │  32 classes · product data · source citations │   │
│  └──────────────────────────────────────────────┘   │
│        │              │              │               │
│        ▼              ▼              ▼               │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ OpenWeather│  │ DeepSeek │  │ SharedPreferences│  │
│  │ API       │  │ LLM via  │  │ + SQLite         │  │
│  │ (weather) │  │ FastAPI  │  │ (persistence)    │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
              ┌──────────────────┐
              │  FastAPI Backend  │
              │  (DeepSeek LLM)  │
              └──────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Riverpod |
| **Navigation** | go_router |
| **On-device ML** | TensorFlow Lite (FP16 quantized model) |
| **Camera** | camera + image_picker |
| **Backend (LLM)** | FastAPI (Python) → DeepSeek Chat API |
| **Weather** | OpenWeather API + GPS geolocation |
| **Persistence** | SQLite (sqflite) + SharedPreferences |
| **Localization** | gen-l10n (ARB-based, 4 languages) |
| **Accessibility** | flutter_tts (text-to-speech) |
| **Location** | geolocator (runtime GPS + reverse geocoding) |

---

## Features

### Core
- **Disease Scanning** — Camera or gallery capture with real-time quality checks
- **On-device Detection** — TFLite FP16 model classifies 32 disease/healthy classes
- **Severity Estimation** — Color-based severity scoring (mild / moderate / severe)
- **Treatment Recommendations** — Verified product-level data with fungicide names, doses, and application timing
- **Source Citations** — Every recommendation shows its research origin

### Verified Treatment Data
| Disease | Product | Dose | Source |
|---------|---------|------|--------|
| Wheat Rust (brown/yellow) | Tilt (Propiconazole) | 3 mL / 1500 mL water | Muhammad Nawaz Shareef Univ. of Agriculture, Multan |
| Rice Blast | Nativo 75% WP | 65 g / acre | Pakistani field trial |
| Rice Blast | Recado Ultra 40% SC | 200 mL / acre | Pakistani field trial |
| Rice Blast | Amistar Top 325 SC | 200 mL / acre | Pakistani field trial |
| Cotton Pests | Lufenuron 5% EC | 40–330 mL / acre | Agrochemical supplier data sheet |

Classes without verified data show *"Verified treatment information is currently unavailable"* — the app never guesses.

### Weather & Risk
- **Real GPS location** — runtime permission request with reverse geocoding
- **7-day disease risk forecast** — rule-based scoring from humidity, rain chance, and temperature
- **Notification center** — rain alerts and high-risk day warnings

### AI Assistant
- **Offline mode** — keyword-matched Q&A against the verified knowledge base (English + Roman Urdu)
- **Online mode** — FastAPI backend routes questions to DeepSeek LLM with RAG-grounded context
- **Conversation memory** — multi-turn chat with pronoun resolution
- **Scan context** — assistant knows your last scan result for follow-up questions

### Accessibility & Localization
- **4 languages** — English, Urdu, Sindhi, Pashto
- **Text-to-speech** — audio button on every informational screen
- **Dark mode** — system/light/dark theme toggle

---

## Screens (18 total)

| Screen | Description |
|--------|-------------|
| Splash | Animated logo with app branding |
| Onboarding | 3-page farmer introduction carousel |
| Home | Dashboard with scan, weather, risk summary |
| Scan | Camera viewfinder with quality overlay |
| Analyzing | TFLite inference progress with animation |
| Result | Disease name, confidence, severity score |
| Treatment | Verified product recommendations + source |
| Risk | 7-day disease risk forecast cards |
| History | Past scan records with detail view |
| Crops | Crop catalog with disease reference |
| Assistant | AI chat with offline/online modes |
| Profile | User settings and preferences |
| Farm Information | Farm details form (location, crops, soil) |
| Notification Center | Active alerts from weather and risk data |
| Notification Settings | Toggle alert categories |
| Language | Switch between 4 languages |
| Settings | General app settings |

---

## Project Structure

```
AgroShield-AI/
├── agroshield_app/          # Flutter application
│   ├── lib/
│   │   ├── ai/              # TFLite inference, preprocessing, severity
│   │   ├── core/            # Theme, routing, constants, services
│   │   ├── data/            # Models, repositories, API datasources
│   │   ├── domain/          # Abstract repository interfaces
│   │   ├── features/        # 18 UI screens
│   │   ├── knowledge/       # Verified disease knowledge base (32 classes)
│   │   ├── l10n/            # Localization (EN, UR, SD, PA)
│   │   └── providers/       # Riverpod provider definitions
│   ├── assets/
│   │   ├── models/          # TFLite FP16 model + class index
│   │   └── images/          # Crop illustrations and samples
│   └── test/                # Unit tests
├── backend/                 # FastAPI LLM assistant
│   ├── main.py              # /chat endpoint → DeepSeek
│   ├── requirements.txt
│   ├── render.yaml          # Render.com deployment config
│   └── Procfile
└── README.md
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Android SDK (API 21+)
- Python 3.10+ (for backend)

### Build the APK
```bash
cd agroshield_app
export PATH=/path/to/flutter/bin:$PATH
export JAVA_HOME=/path/to/jdk17

flutter build apk --release \
  --dart-define=OPENWEATHER_API_KEY=your_key_here
```

### Run the Backend
```bash
cd backend
pip install -r requirements.txt

# Create .env file with your DeepSeek API key
echo 'LLM_API_KEY=your_deepseek_key_here' > .env
echo 'LLM_BASE_URL=https://api.deepseek.com' >> .env
echo 'LLM_MODEL=deepseek-chat' >> .env

uvicorn main:app --host 0.0.0.0 --port 8000
```

### Deploy Backend to Render.com
1. Push the `backend/` folder to your GitHub repo
2. Create a new **Web Service** on [Render.com](https://render.com)
3. Set **Root Directory** → `backend`
4. Build command → `pip install -r requirements.txt`
5. Start command → `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. Add env var `LLM_API_KEY` with your DeepSeek key
7. Rebuild the APK with `--dart-define=ASSISTANT_BACKEND_URL=https://your-app.onrender.com`

---

## Testing

```bash
cd agroshield_app
flutter analyze    # Static analysis — 0 issues
flutter test       # 8/8 tests pass
```

Tests cover:
- Image preprocessing pipeline (decode → resize → normalize → tensor)
- Severity estimation bounds and labeling
- Knowledge base completeness (all 32 classes)
- Verified product data correctness (doses, sources)
- Non-verified classes do not invent product data
- 7-day risk scoring rules

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **On-device TFLite** | Farmers in rural Pakistan have unreliable internet; scanning must work offline |
| **FP16 quantization** | Balances accuracy and speed on low-end Android devices |
| **No extrapolation** | If we don't have verified data, we say so — never guess pesticide doses |
| **Source citations** | Every recommendation links to its research origin for data integrity |
| **Roman Urdu support** | Most farmers type in Roman Urdu, not formal Urdu script |
| **Riverpod over Provider** | Better testability, compile-time safety, and async support |
| **FastAPI backend** | Lightweight Python server for LLM proxy; easy to deploy on free tiers |
| **SharedPreferences + SQLite** | Offline-first persistence for scan history, settings, and farm info |

---

## License

This project was developed for agricultural hackathon demonstration purposes.
