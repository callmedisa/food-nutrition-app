import os
import requests
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from nutrition_data import get_nutrition

app = FastAPI(title="NutriScan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

HF_TOKEN = os.getenv("HF_TOKEN", "")
HF_MODEL_URL = "https://api-inference.huggingface.co/models/nateraw/food"


@app.get("/")
def root():
    return {"status": "ok", "message": "NutriScan API is running"}


@app.post("/recognize")
async def recognize_food(file: UploadFile = File(...)):
    image_bytes = await file.read()

    headers = {}
    if HF_TOKEN:
        headers["Authorization"] = f"Bearer {HF_TOKEN}"

    try:
        response = requests.post(
            HF_MODEL_URL,
            headers=headers,
            data=image_bytes,
            timeout=30,
        )
        response.raise_for_status()
        results = response.json()
    except requests.exceptions.Timeout:
        raise HTTPException(status_code=504, detail="Модель загружается, повторите через 30 секунд")
    except requests.exceptions.HTTPError as e:
        if response.status_code == 503:
            raise HTTPException(status_code=503, detail="Модель прогревается, повторите через 20 секунд")
        raise HTTPException(status_code=500, detail=f"Ошибка HuggingFace: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    if not results or not isinstance(results, list):
        raise HTTPException(status_code=500, detail="Неверный ответ от модели")

    top = results[0]
    label = top.get("label", "unknown")
    confidence = round(top.get("score", 0) * 100, 1)

    nutrition = get_nutrition(label)

    return {
        "label": label,
        "confidence": confidence,
        "nutrition": {
            "nameRu": nutrition["nameRu"],
            "emoji": nutrition["emoji"],
            "calories": nutrition["calories"],
            "protein": nutrition["protein"],
            "fat": nutrition["fat"],
            "carbs": nutrition["carbs"],
        },
        "all_predictions": [
            {"label": r["label"], "confidence": round(r["score"] * 100, 1)}
            for r in results[:3]
        ],
    }
