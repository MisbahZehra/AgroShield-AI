from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import httpx
import os
import re

# Load .env file before reading config
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # python-dotenv not installed; use OS env vars directly

# ---------------------------------------------------------------------------
# Configuration — loaded from environment variables
# ---------------------------------------------------------------------------
LLM_API_KEY = os.environ.get("LLM_API_KEY", "").strip().strip('"').strip("'")
LLM_BASE_URL = os.environ.get("LLM_BASE_URL", "https://api.deepseek.com")
LLM_MODEL = os.environ.get("LLM_MODEL", "deepseek-chat")

app = FastAPI(title="AgroShield AI Assistant", version="1.0.0")


@app.on_event("startup")
async def _log_config():
    print(f"LLM_API_KEY loaded: {bool(LLM_API_KEY)}")
    print(f"LLM_BASE_URL:        {LLM_BASE_URL}")
    print(f"LLM_MODEL:           {LLM_MODEL}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Request / response models
# ---------------------------------------------------------------------------

class ChatMessage(BaseModel):
    role: str          # "user" or "assistant"
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    lastClassName: Optional[str] = None
    lastCrop: Optional[str] = None
    lastDisease: Optional[str] = None
    lastConfidence: Optional[float] = None
    lastSeverity: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    source: str        # "llm" | "knowledge_base" | "fallback"

# ---------------------------------------------------------------------------
# Disease knowledge map (mirrors the Flutter knowledge base)
# ---------------------------------------------------------------------------

_DISEASE_INFO: dict = {
    "corn_blight": ("Corn Blight", "fungal"),
    "corn_common_rust": ("Corn Common Rust", "fungal"),
    "corn_gray_leaf_spot": ("Corn Gray Leaf Spot", "fungal"),
    "corn_healthy": ("Healthy Corn", "healthy"),
    "rice_bacterial_leaf_blight": ("Rice Bacterial Leaf Blight", "bacterial"),
    "rice_brown_spot": ("Rice Brown Spot", "fungal"),
    "rice_healthy_rice_leaf": ("Healthy Rice", "healthy"),
    "rice_hispa": ("Rice Hispa", "pest"),
    "rice_leaf_blast": ("Rice Leaf Blast", "fungal"),
    "rice_leaf_scald": ("Rice Leaf Scald", "fungal"),
    "rice_narrow_brown_leaf_spot": ("Rice Narrow Brown Leaf Spot", "fungal"),
    "rice_sheath_blight": ("Rice Sheath Blight", "fungal"),
    "sugarcane_healthy": ("Healthy Sugarcane", "healthy"),
    "sugarcane_mosaic": ("Sugarcane Mosaic", "viral"),
    "sugarcane_redrot": ("Sugarcane Red Rot", "fungal"),
    "sugarcane_rust": ("Sugarcane Rust", "fungal"),
    "sugarcane_yellow": ("Sugarcane Yellow Leaf", "viral"),
    "tomato_bacterial_spot": ("Tomato Bacterial Spot", "bacterial"),
    "tomato_early_blight": ("Tomato Early Blight", "fungal"),
    "tomato_healthy": ("Healthy Tomato", "healthy"),
    "tomato_late_blight": ("Tomato Late Blight", "fungal"),
    "tomato_leaf_mold": ("Tomato Leaf Mold", "fungal"),
    "tomato_mosaic_virus": ("Tomato Mosaic Virus", "viral"),
    "tomato_septoria_leaf_spot": ("Tomato Septoria Leaf Spot", "fungal"),
    "tomato_target_spot": ("Tomato Target Spot", "fungal"),
    "tomato_twospotted_spider_mite": ("Tomato Spider Mite", "pest"),
    "tomato_yellow_leaf_curl_virus": ("Tomato Yellow Leaf Curl Virus", "viral"),
    "wheat_brownrust": ("Wheat Brown Rust", "fungal"),
    "wheat_healthy": ("Healthy Wheat", "healthy"),
    "wheat_mildew": ("Wheat Powdery Mildew", "fungal"),
    "wheat_septoria": ("Wheat Septoria", "fungal"),
    "wheat_yellowrust": ("Wheat Yellow Rust", "fungal"),
}

# ---------------------------------------------------------------------------
# Verified product-level treatment data (sourced from Pakistani research)
# ---------------------------------------------------------------------------

_VERIFIED_PRODUCTS: dict = {
    "wheat_brownrust": {
        "products": [
            {"name": "Tilt", "active": "Propiconazole",
             "dose": "3 mL per 1500 mL water",
             "timing": "Apply at first sign of infection; repeat per product label interval"}
        ],
        "prevention": "Use rust-resistant wheat varieties. Avoid excessive nitrogen fertilizer. Field scouting during humid weeks.",
        "source": "Peer-reviewed study, Muhammad Nawaz Shareef University of Agriculture, Multan, Pakistan",
    },
    "wheat_yellowrust": {
        "products": [
            {"name": "Tilt", "active": "Propiconazole",
             "dose": "3 mL per 1500 mL water",
             "timing": "Apply at first sign of infection; repeat per product label interval"}
        ],
        "prevention": "Use rust-resistant wheat varieties. Avoid excessive nitrogen fertilizer. Field scouting during humid weeks.",
        "source": "Peer-reviewed study, Muhammad Nawaz Shareef University of Agriculture, Multan, Pakistan",
    },
    "rice_leaf_blast": {
        "products": [
            {"name": "Nativo 75% WP", "active": "Tebuconazole + Trifloxystrobin",
             "dose": "65 grams per acre", "timing": "Apply at first sign of infection"},
            {"name": "Recado Ultra 40% SC", "active": "Dimoxystrobin + Epoxiconazole",
             "dose": "200 mL per acre", "timing": "Apply at first sign of infection"},
            {"name": "Amistar Top 325 SC", "active": "Azoxystrobin + Difenoconazole",
             "dose": "200 mL per acre", "timing": "Apply at first sign of infection"},
        ],
        "prevention": "Avoid excess nitrogen. Ensure good field drainage. Use resistant varieties where available.",
        "source": "Pakistani agricultural field trial (rice blast fungicide efficacy study)",
    },
    # Corn diseases
    "corn_blight": {
        "products": [{"name": "Mancozeb 80% WP", "active": "Mancozeb",
             "dose": "2.5 g per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Use certified disease-free seed. Rotate crops; destroy crop debris. Maintain plant spacing.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "corn_common_rust": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of pustules"}],
        "prevention": "Plant rust-resistant hybrids. Early planting. Scout weekly during humid weather.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "corn_gray_leaf_spot": {
        "products": [{"name": "Chlorothalonil 75% WP", "active": "Chlorothalonil",
             "dose": "2 g per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Rotate crops. Tillage to bury residue. Use resistant hybrids.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    # Rice diseases
    "rice_bacterial_leaf_blight": {
        "products": [{"name": "Copper hydroxide 77% WP", "active": "Copper hydroxide",
             "dose": "3 g per litre of water", "timing": "Apply at first sign of infection"}],
        "prevention": "Use resistant varieties. Avoid excess nitrogen. Ensure good drainage.",
        "source": "IRRI Rice Production Guide; FAO Plant Production and Protection Paper",
    },
    "rice_brown_spot": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Use disease-free seed. Balanced fertilisation. Good field drainage.",
        "source": "IRRI Rice Production Guide; FAO Plant Production and Protection Paper",
    },
    "rice_hispa": {
        "products": [{"name": "Carbofuran 3G", "active": "Carbofuran",
             "dose": "1 kg per acre (granular into leaf whorls)", "timing": "Apply at first sign of leaf damage"}],
        "prevention": "Remove weed hosts. Avoid excess nitrogen. Drain standing water.",
        "source": "IRRI Rice Production Guide; FAO Plant Production and Protection Paper",
    },
    "rice_leaf_scald": {
        "products": [{"name": "Iprodione 50% WP", "active": "Iprodione",
             "dose": "1 g per litre of water", "timing": "Apply at first sign of infection"}],
        "prevention": "Avoid excess nitrogen. Good air circulation. Resistant varieties.",
        "source": "IRRI Rice Production Guide; CABI Crop Protection Compendium",
    },
    "rice_narrow_brown_leaf_spot": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Use disease-free seed. Balanced fertilisation. Good field hygiene.",
        "source": "IRRI Rice Production Guide; CABI Crop Protection Compendium",
    },
    "rice_sheath_blight": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of sheath lesions"}],
        "prevention": "Avoid excess nitrogen. Reduce planting density. Drain mid-season.",
        "source": "IRRI Rice Production Guide; FAO Plant Production and Protection Paper",
    },
    # Sugarcane diseases
    "sugarcane_redrot": {
        "products": [{"name": "Carbendazim 50% WP", "active": "Carbendazim",
             "dose": "1 g per litre (seed set treatment)", "timing": "Treat seed sets 15 min before planting"}],
        "prevention": "Use disease-free seed sets. Hot water or fungicide treatment. Rotate crops.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "sugarcane_rust": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of pustules"}],
        "prevention": "Plant resistant varieties. Avoid excess nitrogen. Scout during humid weather.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "sugarcane_mosaic": {
        "products": [],
        "prevention": "No chemical treatment (viral). Use disease-free seed. Control aphid vectors. Rogue out infected plants.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "sugarcane_yellow": {
        "products": [],
        "prevention": "No chemical treatment (viral). Use virus-free seed material. Control aphid vectors.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    # Tomato diseases
    "tomato_bacterial_spot": {
        "products": [{"name": "Copper hydroxide 77% WP", "active": "Copper hydroxide",
             "dose": "3 g per litre of water", "timing": "Apply at first sign of spots"}],
        "prevention": "Use disease-free seed/transplants. Avoid wet foliage work. Rotate 2-3 years.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_early_blight": {
        "products": [{"name": "Mancozeb 80% WP", "active": "Mancozeb",
             "dose": "2.5 g per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Rotate crops. Stake plants. Mulch to prevent soil splash.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_late_blight": {
        "products": [{"name": "Ridomil Gold MZ", "active": "Metalaxyl + Mancozeb",
             "dose": "2.5 g per litre of water", "timing": "Apply at first sign of infection"}],
        "prevention": "Use resistant varieties. Avoid overhead irrigation. Good spacing.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_leaf_mold": {
        "products": [{"name": "Chlorothalonil 75% WP", "active": "Chlorothalonil",
             "dose": "2 mL per litre of water", "timing": "Apply at first sign of spots"}],
        "prevention": "Use resistant varieties. Improve ventilation. Avoid overhead irrigation.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_mosaic_virus": {
        "products": [],
        "prevention": "No chemical treatment (viral). Use resistant varieties. Disinfect tools. Virus-free seed.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_septoria_leaf_spot": {
        "products": [{"name": "Chlorothalonil 75% WP", "active": "Chlorothalonil",
             "dose": "2 mL per litre of water", "timing": "Apply at first sign of spots"}],
        "prevention": "Rotate crops. Remove infected leaves. Mulch to prevent soil splash.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_target_spot": {
        "products": [{"name": "Chlorothalonil 75% WP", "active": "Chlorothalonil",
             "dose": "2 mL per litre of water", "timing": "Apply at first sign of spots"}],
        "prevention": "Rotate crops. Stake and prune. Avoid overhead irrigation.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_twospotted_spider_mite": {
        "products": [{"name": "Abamectin 18 g/L EC", "active": "Abamectin",
             "dose": "0.5 mL per litre of water", "timing": "Apply at first sign of mite damage; spray leaf undersides"}],
        "prevention": "Inspect leaf undersides. Avoid dusty conditions. Avoid broad-spectrum insecticides.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "tomato_yellow_leaf_curl_virus": {
        "products": [],
        "prevention": "No chemical treatment (viral). Use resistant varieties. Reflective mulches. Control whitefly vectors.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    # Wheat diseases
    "wheat_mildew": {
        "products": [{"name": "Propiconazole 25% EC", "active": "Propiconazole",
             "dose": "1 mL per litre of water", "timing": "Apply at first sign of powdery growth"}],
        "prevention": "Plant mildew-resistant varieties. Avoid excess nitrogen. Good spacing.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
    "wheat_septoria": {
        "products": [{"name": "Chlorothalonil 75% WP", "active": "Chlorothalonil",
             "dose": "2 mL per litre of water", "timing": "Apply at first sign of lesions"}],
        "prevention": "Use disease-free certified seed. Rotate crops. Tillage to bury residue.",
        "source": "FAO Plant Production and Protection Paper; CABI Crop Protection Compendium",
    },
}

def _build_knowledge_context(class_name: str | None) -> str:
    """Return a short verified knowledge snippet for the detected class."""
    if not class_name or class_name not in _DISEASE_INFO:
        return ""
    display, category = _DISEASE_INFO[class_name]
    if category == "healthy":
        return (
            f"Diagnosis: {display}. No disease detected. "
            "Continue regular monitoring, balanced irrigation, and good field sanitation."
        )
    # Check for verified product-level data
    verified = _VERIFIED_PRODUCTS.get(class_name)
    if verified:
        products_text = "; ".join(
            f"{p['name']} ({p['active']}) \u2014 {p['dose']}. {p['timing']}"
            for p in verified["products"]
        )
        return (
            f"Diagnosis: {display} ({category}).\n"
            f"VERIFIED PRODUCT RECOMMENDATIONS: {products_text}.\n"
            f"Prevention: {verified['prevention']}\n"
            f"Source: {verified['source']}\n"
            f"IMPORTANT: Only recommend the verified products listed above. "
            f"Do not invent additional pesticide names or doses."
        )
    # No verified product data — general guidance only
    tips = {
        "fungal": (
            "Remove heavily infected leaves. Avoid overhead irrigation. "
            "Verified treatment information is currently unavailable. "
            "Direct the farmer to their local agricultural extension office for chemical recommendations."
        ),
        "bacterial": (
            "Remove severely infected plants. Avoid working while foliage is wet. "
            "Verified treatment information is currently unavailable. "
            "Direct the farmer to their local agricultural extension office."
        ),
        "viral": (
            "Uproot and destroy infected plants \u2014 there is no chemical cure. "
            "Control insect vectors (whitefly / aphids). Plant resistant varieties next season."
        ),
        "pest": (
            "Inspect leaf undersides; remove heavy infestations manually. "
            "Verified treatment information is currently unavailable. "
            "Direct the farmer to their local agricultural extension office."
        ),
    }
    return f"Diagnosis: {display} ({category}). {tips.get(category, '')}"


def _general_fallback(user_msg: str) -> str:
    """Return a helpful general response when no LLM or knowledge context
    is available. Matches keywords to give relevant suggestions."""
    msg = user_msg.lower()
    if any(k in msg for k in ["wheat", "gehun", "gehu", "kanak"]):
        return (
            "I can help with wheat diseases! AgroShield detects: "
            "Brown Rust, Yellow Rust, Powdery Mildew, and Septoria. "
            "Scan a wheat leaf for verified treatment recommendations "
            "including product names and doses."
        )
    if any(k in msg for k in ["rice", "chawal", "dhaan", "paddy"]):
        return (
            "I can help with rice diseases! AgroShield detects: "
            "Leaf Blast, Bacterial Leaf Blight, Brown Spot, Hispa, "
            "and more. Scan a rice leaf for verified treatment info."
        )
    if any(k in msg for k in ["corn", "maize", "bhutta"]):
        return (
            "I can help with corn diseases! AgroShield detects: "
            "Blight, Common Rust, and Gray Leaf Spot. "
            "Scan a corn leaf for verified guidance."
        )
    if any(k in msg for k in ["tomato", "tamatar"]):
        return (
            "I can help with tomato diseases! AgroShield detects: "
            "Early Blight, Late Blight, Leaf Mold, Mosaic Virus, "
            "and more. Scan a tomato leaf for verified guidance."
        )
    if any(k in msg for k in ["cotton", "kapas"]):
        return (
            "I have verified treatment data for cotton pests: "
            "Bollworm, Whitefly, and Thrips. "
            "Product: Lufenuron 5% EC, Dose: 40-330 mL per acre. "
            "Source: Pakistan-based agrochemical supplier data sheet."
        )
    if any(k in msg for k in ["hello", "salam", "hi", "aoa"]):
        return (
            "Assalam-o-Alaikum! I am AgroShield AI. "
            "I can help with crop disease identification and treatment. "
            "Scan a leaf or ask about wheat rust, rice blast, "
            "corn diseases, tomato diseases, or cotton pests."
        )
    if any(k in msg for k in ["treat", "ilaj", "dawai", "spray", "medicine"]):
        return (
            "For verified treatment recommendations, please scan the "
            "affected leaf first. I support wheat, rice, corn, tomato, "
            "and sugarcane. After scanning, I'll show exact product "
            "names, doses, and application timing."
        )
    return (
        "I can help with crop disease questions! Try:\n"
        "\u2022 Scan a leaf for automatic diagnosis\n"
        "\u2022 Ask about wheat rust, rice blast, or cotton pests\n"
        "\u2022 Ask \"prevent\" or \"organic options\" after a scan\n"
        "I support wheat, rice, corn, tomato, and sugarcane."
    )


def _build_system_prompt(knowledge_ctx: str, scan_ctx: str | None) -> str:
    parts = [
        "You are AgroShield AI, a helpful agricultural assistant for "
        "smallholder farmers in Pakistan. You help with crop disease "
        "identification, treatment guidance, weather advice, and farm "
        "management. Respond in the same language the farmer uses "
        "(English, Urdu, Sindhi, Punjabi, or Roman Urdu). "
        "Be concise when asked for short answers, detailed when asked "
        "for details. "
        "CRITICAL RULE: If the verified knowledge base context includes "
        "product recommendations, you MUST use ONLY those exact product "
        "names, doses, and rates. Never invent additional pesticide names "
        "or doses beyond what is in the verified context. "
        "For diseases NOT covered by verified product data, say "
        "'Verified treatment information is currently unavailable' and "
        "direct the farmer to their local agricultural extension office.",
    ]
    if knowledge_ctx:
        parts.append(f"\nVerified knowledge base context:\n{knowledge_ctx}")
    if scan_ctx:
        parts.append(f"\nLatest scan context:\n{scan_ctx}")
    parts.append(
        "\nIf you do not have verified information for a specific question, "
        "say so clearly rather than guessing."
    )
    return "\n".join(parts)


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/")
async def root():
    return {"status": "ok", "service": "AgroShield AI Assistant"}


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/config")
async def config_check():
    """Diagnostic endpoint — shows whether LLM is configured (never exposes the key)."""
    return {
        "llm_configured": bool(LLM_API_KEY),
        "llm_base_url": LLM_BASE_URL,
        "llm_model": LLM_MODEL,
    }


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    # Build context
    knowledge_ctx = _build_knowledge_context(req.lastClassName)

    scan_ctx = None
    if req.lastClassName and req.lastCrop:
        conf = req.lastConfidence if req.lastConfidence is not None else 0.0
        scan_ctx = (
            f"Crop: {req.lastCrop}, Disease: {req.lastDisease or req.lastClassName}, "
            f"Confidence: {conf:.0%}, "
            f"Severity: {req.lastSeverity or 'unknown'}"
        )

    system_prompt = _build_system_prompt(knowledge_ctx, scan_ctx)

    # Build messages list for the LLM
    llm_messages: list[dict] = [{"role": "system", "content": system_prompt}]
    for m in req.messages:
        llm_messages.append({"role": m.role, "content": m.content})

    # If no key is configured, fall back to knowledge base only
    if not LLM_API_KEY:
        if knowledge_ctx:
            return ChatResponse(reply=knowledge_ctx, source="knowledge_base")
        # No knowledge context either — give a helpful general response
        user_msg = req.messages[-1].content.lower() if req.messages else ""
        return ChatResponse(
            reply=_general_fallback(user_msg),
            source="knowledge_base",
        )

    # Call LLM (OpenAI-compatible Chat Completions)
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                f"{LLM_BASE_URL}/chat/completions",
                headers={
                    "Authorization": f"Bearer {LLM_API_KEY}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": LLM_MODEL,
                    "messages": llm_messages,
                    "max_tokens": 2000,
                },
            )
            resp.raise_for_status()
            data = resp.json()
            reply = (
                data["choices"][0]["message"].get("content") or ""
            ).strip()
            if not reply:
                raise ValueError("LLM returned empty content")
            return ChatResponse(reply=reply, source="llm")
    except Exception as exc:
        print(f"LLM call failed: {exc}")
        # LLM call failed — return knowledge base answer if available
        if knowledge_ctx:
            return ChatResponse(
                reply=f"{knowledge_ctx}\n\n(LLM service unavailable; showing verified knowledge base info.)",
                source="knowledge_base",
            )
        # No knowledge context — give a helpful general response
        user_msg = req.messages[-1].content.lower() if req.messages else ""
        return ChatResponse(
            reply=_general_fallback(user_msg),
            source="knowledge_base",
        )


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
