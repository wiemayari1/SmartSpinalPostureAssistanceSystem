from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from datetime import datetime
from typing import Literal
import numpy as np
import json
import os
import asyncio
import aiohttp

# Configuration minimale (gratuite, pas besoin d'OpenAI pour commencer)
app = FastAPI(title="PostureAI", version="1.0")

# Modèles de données
class SensorData(BaseModel):
    device_id: str
    pitch: float
    roll: float
    lang: Literal["FR", "AR", "EN"] = "FR"

class AIResponse(BaseModel):
    device_id: str
    posture_state: int  # 0: Bon, 1: Attention, 2: Mauvais
    confidence: float
    risk_score: float
    recommendation: str
    exercise: str
    language: str

# IA simple (fonctionne sans OpenAI, 100% gratuit)
def analyze_posture_ai(pitch: float, roll: float, lang: str):
    tilt = np.sqrt(pitch**2 + roll**2)
    
    if tilt < 15:
        state = 0
        conf = 0.95
        risk = tilt * 1.5
    elif tilt < 30:
        state = 1
        conf = 0.85
        risk = 25 + (tilt - 15) * 2
    else:
        state = 2
        conf = 0.90
        risk = min(55 + (tilt - 30) * 3, 100)
    
    # Recommandations multilingues (fallback gratuit)
    recs = {
        "FR": ["Posture parfaite", "Attention légère", "Redressez-vous immédiatement"],
        "AR": ["وضعية ممتازة", "تنبيه خفيف", "استقيم فوراً"],
        "EN": ["Perfect posture", "Slight warning", "Straighten up now"]
    }
    
    exercises = {
        "FR": ["Aucun exercice", "Respiration 3x", "Étirement trapèzes 30s"],
        "AR": ["لا تمرين", "تنفس 3 مرات", "تمدد 30 ثانية"],
        "EN": ["No exercise", "Breathe 3x", "Stretch traps 30s"]
    }
    
    return {
        "state": state,
        "confidence": conf,
        "risk": risk,
        "rec": recs[lang][state],
        "ex": exercises[lang][state]
    }

@app.post("/api/v2/analyze", response_model=AIResponse)
async def analyze(data: SensorData):
    print(f"📥 {data.device_id}: Pitch={data.pitch}°, Roll={data.roll}°")
    
    ai_result = analyze_posture_ai(data.pitch, data.roll, data.lang)
    
    # Envoi n8n si risque élevé (async, ne bloque pas la réponse)
    if ai_result["state"] == 2:
        asyncio.create_task(send_n8n_alert(data, ai_result))
    
    return AIResponse(
        device_id=data.device_id,
        posture_state=ai_result["state"],
        confidence=ai_result["confidence"],
        risk_score=ai_result["risk"],
        recommendation=ai_result["rec"],
        exercise=ai_result["ex"],
        language=data.lang
    )

async def send_n8n_alert(data: SensorData, result: dict):
    """Webhook vers n8n (optionnel pour l'instant)"""
    n8n_url = os.getenv("N8N_WEBHOOK_URL", "")
    if not n8n_url:
        return
    
    try:
        async with aiohttp.ClientSession() as session:
            await session.post(n8n_url, json={
                "device": data.device_id,
                "risk": result["risk"],
                "lang": data.lang,
                "msg": result["rec"]
            }, timeout=2)
    except:
        pass

@app.get("/health")
def health():
    return {"status": "ok", "ai": "active", "version": "1.0"}

@app.get("/")
def root():
    return {"message": "PostureAI Cloud API - Envoyer POST vers /api/v2/analyze"}
