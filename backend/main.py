import os
import io
import requests
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from nutrition_data import get_nutrition
from PIL import Image

app = FastAPI(title="NutriScan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

HF_TOKEN = os.getenv("HF_TOKEN", "")

# Локальная модель — загружается один раз при первом запросе, кешируется
_classifier = None

def get_classifier():
    global _classifier
    if _classifier is None:
        print("Загрузка модели локально (первый раз ~300 МБ)...")
        from transformers import pipeline
        _classifier = pipeline(
            "image-classification",
            model="nateraw/food",
            top_k=5,
        )
        print("Модель загружена и готова к работе.")
    return _classifier


@app.get("/")
def root():
    return {"status": "ok", "message": "NutriScan API is running"}


@app.post("/recognize")
async def recognize_food(file: UploadFile = File(...)):
    image_bytes = await file.read()

    results = None

    # 1. Сначала пробуем HuggingFace Inference API (быстро, не требует памяти)
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

    # 2. Если API недоступны — запускаем модель локально
    if results is None:
        try:
            clf = get_classifier()
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            local_results = clf(image)
            results = [{"label": r["label"], "score": r["score"]} for r in local_results]
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
            {"label": r["label"], "confidence": round(r["score"] * 100, 1)}
            for r in results[:3]
        ],
    }
