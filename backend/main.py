import os
import io
import requests
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from nutrition_data import get_nutrition
from PIL import Image, ImageEnhance
from collections import defaultdict

app = FastAPI(title="NutriScan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

HF_TOKEN = os.getenv("HF_TOKEN", "")

_classifier = None

def get_classifier():
    global _classifier
    if _classifier is None:
        print("Загрузка модели локально (первый раз ~300 МБ)...")
        from transformers import pipeline
        _classifier = pipeline(
            "image-classification",
            model="nateraw/food",
            top_k=10,
        )
        print("Модель загружена и готова к работе.")
    return _classifier


def preprocess(image: Image.Image) -> Image.Image:
    """Нормализуем размер и слегка усиливаем контраст."""
    image = image.convert("RGB")
    # Оптимальный размер для ViT-моделей
    image = image.resize((384, 384), Image.LANCZOS)
    # Лёгкое усиление контраста помогает модели различать текстуры
    image = ImageEnhance.Contrast(image).enhance(1.15)
    image = ImageEnhance.Sharpness(image).enhance(1.1)
    return image


def make_crops(image: Image.Image) -> list[Image.Image]:
    """5 кропов: центр + 4 угла. Ансамбль кропов повышает точность."""
    w, h = image.size
    cx, cy = w // 2, h // 2
    crop_size = int(min(w, h) * 0.82)
    half = crop_size // 2

    centers = [
        (cx, cy),                          # центр
        (half, half),                      # верх-лево
        (w - half, half),                  # верх-право
        (half, h - half),                  # низ-лево
        (w - half, h - half),              # низ-право
    ]
    crops = []
    for x, y in centers:
        left  = max(0, x - half)
        upper = max(0, y - half)
        right = min(w, x + half)
        lower = min(h, y + half)
        crop = image.crop((left, upper, right, lower)).resize((384, 384), Image.LANCZOS)
        crops.append(crop)
    return crops


def ensemble_predict(clf, image: Image.Image) -> list[dict]:
    """Прогоняем все кропы через модель и усредняем оценки."""
    crops = make_crops(image)
    scores: dict[str, float] = defaultdict(float)

    for crop in crops:
        preds = clf(crop)
        for p in preds:
            scores[p["label"]] += p["score"]

    # Нормализуем (делим на количество кропов)
    n = len(crops)
    averaged = [{"label": lbl, "score": s / n} for lbl, s in scores.items()]
    averaged.sort(key=lambda x: x["score"], reverse=True)
    return averaged


@app.get("/")
def root():
    return {"status": "ok", "message": "NutriScan API is running"}


@app.post("/recognize")
async def recognize_food(file: UploadFile = File(...)):
    image_bytes = await file.read()

    results = None

    # 1. Сначала пробуем HuggingFace Inference API
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
                if isinstance(data, list) and len(data) > 0 and "label" in data[0]:
                    results = data
                    break
        except Exception:
            continue

    # 2. Локальная модель с ансамблем кропов
    if results is None:
        try:
            clf = get_classifier()
            image = Image.open(io.BytesIO(image_bytes))
            image = preprocess(image)
            results = ensemble_predict(clf, image)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Ошибка локальной модели: {str(e)}")

    if not results:
        raise HTTPException(status_code=500, detail="Не удалось распознать блюдо")

    top = results[0]
    label = top.get("label", "unknown")
    confidence = round(top.get("score", 0) * 100, 1)
    nutrition = get_nutrition(label)

    return {
        "label": label,
        "confidence": confidence,
        "nutrition": {
            "nameRu": nutrition["nameRu"],
            "emoji":   nutrition["emoji"],
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
