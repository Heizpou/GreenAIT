# api-ai/api.py
from fastapi import FastAPI

app = FastAPI(title="Moteur AI RL")

@app.get("/health")
def health():
    return {
        "status": "ok"
    }
