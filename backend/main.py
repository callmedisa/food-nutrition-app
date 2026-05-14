import os
import io
import ssl
import json
import requests
import torch
import torch.nn as nn
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from nutrition_data import get_nutrition
from PIL import Image, ImageEnhance
from collections import defaultdict
from torchvision import transforms, models

ssl._create_default_https_context = ssl._create_unverified_context

app = FastAPI(title="NutriScan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

HF_TOKEN        = os.getenv("HF_TOKEN", "")
KAZAKH_MODEL    = os.path.join(os.path.dirname(__file__), "kazakh_model.pth")
KAZAKH_CLASSES  = os.path.join(os.path.dirname(__file__), "kazakh_classes.json")
KAZAKH_THRESHOLD = 0.70   # если казахская модель даёт >70% — доверяем ей

# ── Казахская модель ─────────────────────────────────────

_kazakh_model   = None
_kazakh_classes = None
_kazakh_device  = None
_kazakh_tf      = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])

def get_kazakh_model():
    global _kazakh_model, _kazakh_classes, _kazakh_device
    if _kazakh_model is not None:
        return _kazakh_model, _kazakh_classes, _kazakh_device
    if not os.path.exists(KAZAKH_MODEL) or not os.path.exists(KAZAKH_CLASSES):
        return None, None, None
    with open(KAZAKH_CLASSES, encoding="utf-8") as f:
        _kazakh_classes = json.load(f)
    _kazakh_device = (
        torch.device("mps")  if torch.backends.mps.is_available() else
        torch.device("cuda") if torch.cuda.is_available() else
        torch.device("cpu")
    )
    model = models.efficientnet_b0(weights=None)
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(_kazakh_classes))
    model.load_state_dict(torch.load(KAZAKH_MODEL, map_location=_kazakh_device))
    model.to(_kazakh_device)
    model.eval()
    _kazakh_model = model
    print(f"Казахская модель загружена: {len(_kazakh_classes)} классов на {_kazakh_device}")
    return _kazakh_model, _kazakh_classes, _kazakh_device


def predict_kazakh(image: Image.Image) -> dict | None:
    """Возвращает {'label': ..., 'score': ...} если модель есть, иначе None."""
    model, classes, device = get_kazakh_model()
    if model is None:
        return None
    img = image.convert("RGB")
    tensor = _kazakh_tf(img).unsqueeze(0).to(device)
    with torch.no_grad():
        logits = model(tensor)
        probs  = torch.softmax(logits, dim=1)[0]
    best_idx   = probs.argmax().item()
    best_score = probs[best_idx].item()
    return {"label": classes[best_idx], "score": best_score}


# ── Основная (Food-101) модель ────────────────────────────

_classifier = None

def get_classifier():
    global _classifier
    if _classifier is None:
        print("Загрузка основной модели (~300 МБ, первый раз)...")
        from transformers import pipeline
        _classifier = pipeline("image-classification", model="nateraw/food", top_k=10)
        print("Основная модель загружена.")
    return _classifier


def preprocess(image: Image.Image) -> Image.Image:
    image = image.convert("RGB")
    image = image.resize((384, 384), Image.LANCZOS)
    image = ImageEnhance.Contrast(image).enhance(1.15)
    image = ImageEnhance.Sharpness(image).enhance(1.1)
    return image


def make_crops(image: Image.Image) -> list[Image.Image]:
    w, h = image.size
    cx, cy = w // 2, h // 2
    crop_size = int(min(w, h) * 0.82)
    half = crop_size // 2
    centers = [
        (cx, cy), (half, half), (w - half, half),
        (half, h - half), (w - half, h - half),
    ]
    crops = []
    for x, y in centers:
        left  = max(0, x - half)
        upper = max(0, y - half)
        right = min(w, x + half)
        lower = min(h, y + half)
        crops.append(image.crop((left, upper, right, lower)).resize((384, 384), Image.LANCZOS))
    return crops


def ensemble_predict(clf, image: Image.Image) -> list[dict]:
    crops = make_crops(image)
    scores: dict[str, float] = defaultdict(float)
    for crop in crops:
        for p in clf(crop):
            scores[p["label"]] += p["score"]
    n = len(crops)
    averaged = [{"label": lbl, "score": s / n} for lbl, s in scores.items()]
    averaged.sort(key=lambda x: x["score"], reverse=True)
    return averaged


# ── Endpoints ─────────────────────────────────────────────

@app.get("/")
def root():
    kazakh_ready = os.path.exists(KAZAKH_MODEL)
    return {
        "status": "ok",
        "message": "NutriScan API is running",
        "kazakh_model": kazakh_ready,
    }


@app.post("/recognize")
async def recognize_food(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image_pil   = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # 1. Казахская специализированная модель
    kazakh = predict_kazakh(image_pil)
    if kazakh and kazakh["score"] >= KAZAKH_THRESHOLD:
        label      = kazakh["label"]
        confidence = round(kazakh["score"] * 100, 1)
        nutrition  = get_nutrition(label)
        return {
            "label": label,
            "confidence": confidence,
            "source": "kazakh_model",
            "nutrition": {
                "nameRu":   nutrition["nameRu"],
                "emoji":    nutrition["emoji"],
                "calories": nutrition["calories"],
                "protein":  nutrition["protein"],
                "fat":      nutrition["fat"],
                "carbs":    nutrition["carbs"],
            },
            "all_predictions": [{
                "label": label,
                "confidence": confidence,
                "nutrition": nutrition,
            }],
        }

    # 2. HuggingFace Inference API
    results = None
    hf_models = [
        "https://api-inference.huggingface.co/models/eslamxm/vit-base-food101",
        "https://api-inference.huggingface.co/models/skylord/swin-finetuned-food101",
    ]
    headers = {"Authorization": f"Bearer {HF_TOKEN}"} if HF_TOKEN else {}
    for model_url in hf_models:
        try:
            resp = requests.post(model_url, headers=headers, data=image_bytes, timeout=20)
            if resp.status_code == 200:
                data = resp.json()
                if isinstance(data, list) and data and "label" in data[0]:
                    results = data
                    break
        except Exception:
            continue

    # 3. Локальная Food-101 модель с ансамблем
    if results is None:
        try:
            clf    = get_classifier()
            image  = preprocess(image_pil)
            results = ensemble_predict(clf, image)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Ошибка модели: {str(e)}")

    if not results:
        raise HTTPException(status_code=500, detail="Не удалось распознать блюдо")

    # Если казахская модель дала результат, но ниже порога — добавляем его в топ
    if kazakh:
        kaz_entry = {"label": kazakh["label"], "score": kazakh["score"]}
        results = [kaz_entry] + [r for r in results if r.get("label") != kazakh["label"]]

    top        = results[0]
    label      = top.get("label", "unknown")
    confidence = round(top.get("score", 0) * 100, 1)
    nutrition  = get_nutrition(label)

    return {
        "label": label,
        "confidence": confidence,
        "source": "food101_model",
        "nutrition": {
            "nameRu":   nutrition["nameRu"],
            "emoji":    nutrition["emoji"],
            "calories": nutrition["calories"],
            "protein":  nutrition["protein"],
            "fat":      nutrition["fat"],
            "carbs":    nutrition["carbs"],
        },
        "all_predictions": [
            {
                "label": r["label"],
                "confidence": round(r["score"] * 100, 1),
                "nutrition": get_nutrition(r["label"]),
            }
            for r in results[:3]
        ],
    }
