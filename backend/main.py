import os
import io
import json
import requests
import torch
import torch.nn as nn
import math
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from nutrition_data import get_nutrition
from PIL import Image, ImageEnhance
from collections import defaultdict
from torchvision import transforms, models


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

# Казахская модель уверена → показываем её результат
KAZAKH_HIGH_THRESHOLD   = 0.70
# Казахская модель умеренно уверена → добавляем как альтернативу, но Food-101 — главный
KAZAKH_MIN_THRESHOLD    = 0.40
# Минимальная уверенность Food-101 для показа результата (ниже → "не еда")
FOOD101_MIN_CONFIDENCE  = 0.12
# Минимальная энтропия топа: если модель размазала всё равномерно → не еда
MIN_TOP_SCORE_FOR_FOOD  = 0.10


# ── Казахская модель ──────────────────────────────────────────────────────────

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
    """Возвращает {'label': ..., 'score': float, 'all_probs': list[float]} или None."""
    model, classes, device = get_kazakh_model()
    if model is None:
        return None
    img = image.convert("RGB")
    tensor = _kazakh_tf(img).unsqueeze(0).to(device)
    with torch.no_grad():
        logits = model(tensor)
        probs  = torch.softmax(logits, dim=1)[0].cpu().tolist()
    best_idx   = max(range(len(probs)), key=lambda i: probs[i])
    best_score = probs[best_idx]
    return {
        "label":     classes[best_idx],
        "score":     best_score,
        "all_probs": probs,
        "classes":   classes,
    }


def kazakh_looks_like_food(kazakh_result: dict) -> bool:
    """
    Проверяет, "уверена" ли казахская модель что это вообще похоже на еду.
    Метрика: энтропия вероятностей.
    Если распределение почти равномерное — это не казахское блюдо.
    Max возможная энтропия для 14 классов = log2(14) ≈ 3.81 бит.
    Если энтропия > 3.0 — модель ничего не узнаёт → не казахская еда.
    """
    probs = kazakh_result["all_probs"]
    entropy = -sum(p * math.log2(p + 1e-9) for p in probs)
    max_entropy = math.log2(len(probs))
    # Нормализованная энтропия: 0.0 (полная уверенность) → 1.0 (полная неопределённость)
    norm_entropy = entropy / max_entropy
    return norm_entropy < 0.85  # уверена хотя бы чуть-чуть


# ── Food-101 модель ───────────────────────────────────────────────────────────

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


def looks_like_food(results: list[dict]) -> bool:
    """
    Проверяет, является ли изображение едой по результатам Food-101 модели.
    Если топ-1 результат < MIN_TOP_SCORE_FOR_FOOD → скорее всего не еда.
    """
    if not results:
        return False
    top_score = results[0].get("score", 0)
    return top_score >= MIN_TOP_SCORE_FOR_FOOD


# ── Endpoints ─────────────────────────────────────────────────────────────────

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

    # ── Шаг 1: Казахская специализированная модель ────────────────────────────
    kazakh = predict_kazakh(image_pil)

    # ИСПРАВЛЕНИЕ: казахская модель срабатывает ТОЛЬКО если:
    #   а) уверенность выше высокого порога (0.70), И
    #   б) распределение вероятностей не равномерное (модель что-то узнаёт)
    if kazakh and kazakh["score"] >= KAZAKH_HIGH_THRESHOLD and kazakh_looks_like_food(kazakh):
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
                "label":      label,
                "confidence": confidence,
                "source":     "kazakh_model",
                "nutrition":  nutrition,
            }],
        }

    # ── Шаг 2: Food-101 через HuggingFace API или локальную модель ────────────
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

    # Локальная модель с ансамблем 5 кропов
    if results is None:
        try:
            clf    = get_classifier()
            image  = preprocess(image_pil)
            results = ensemble_predict(clf, image)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Ошибка модели: {str(e)}")

    if not results:
        raise HTTPException(status_code=500, detail="Не удалось распознать блюдо")

    # ── Шаг 3: Проверка "это вообще еда?" ────────────────────────────────────
    # Если топ-1 Food-101 уверен меньше чем на MIN_TOP_SCORE_FOR_FOOD (10%),
    # значит модель видит размытое распределение → скорее всего не еда.
    if not looks_like_food(results):
        raise HTTPException(
            status_code=422,
            detail=(
                "На фото не удалось распознать еду. "
                "Убедитесь, что на снимке блюдо или продукт питания."
            ),
        )

    # ── Шаг 4: Дополнительная проверка по уверенности ────────────────────────
    top_score = results[0].get("score", 0)
    if top_score < FOOD101_MIN_CONFIDENCE:
        raise HTTPException(
            status_code=422,
            detail=(
                f"Изображение распознано с низкой уверенностью ({round(top_score*100)}%). "
                "Попробуйте сфотографировать блюдо крупнее и при хорошем освещении."
            ),
        )

    # ── Шаг 5: Формируем ответ ────────────────────────────────────────────────
    # ИСПРАВЛЕНИЕ: казахская модель добавляется как альтернатива ТОЛЬКО если:
    #   а) её уверенность выше умеренного порога (0.40), И
    #   б) распределение не равномерное (модель что-то узнаёт)
    # Она НЕ вставляется первой — Food-101 остаётся главным.
    if (kazakh
            and kazakh["score"] >= KAZAKH_MIN_THRESHOLD
            and kazakh_looks_like_food(kazakh)):
        kaz_entry = {"label": kazakh["label"], "score": kazakh["score"]}
        # Добавляем только если этого класса ещё нет в топе
        if not any(r.get("label") == kaz_entry["label"] for r in results[:3]):
            results = results[:2] + [kaz_entry] + results[2:]

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
                "label":      r["label"],
                "confidence": round(r["score"] * 100, 1),
                "source":     "food101_model",
                "nutrition":  get_nutrition(r["label"]),
            }
            for r in results[:3]
        ],
    }