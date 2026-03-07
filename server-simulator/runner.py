import json
import os
import threading
import time

import requests
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from server_lib.server import Server
from server_lib.workload import Workload

STEP_SECONDS = 30
METRICS_API_URL = os.environ.get("METRICS_API_URL", "http://localhost:5002/api/metrics")
_initial_server_id = os.environ.get("SERVER_ID")


# ---------- Shared state ----------

class SimulatorState:
    def __init__(self):
        self.lock = threading.Lock()
        self.workload = Workload(step_seconds=STEP_SECONDS)
        self.server: Server | None = None
        self.latest_metrics: dict | None = None
        if _initial_server_id:
            self.server = Server(_initial_server_id)


state = SimulatorState()


# ---------- Simulation loop ----------

def simulation_loop():
    while True:
        with state.lock:
            load = state.workload.get_load()
            if state.server is not None:
                state.server.step(load)
                metrics = state.server.get_metrics()
                metrics["timestamp"] = time.time()
                metrics["simulated_hour"] = round(state.workload.hour_of_day, 2)
                metrics["incoming_load"] = round(load, 2)
                state.latest_metrics = metrics.copy()
            else:
                metrics = None

        if metrics:
            print(json.dumps(metrics), flush=True)
            try:
                resp = requests.post(METRICS_API_URL, json=metrics, timeout=5)
                if not resp.ok:
                    print(f"[{metrics['server_id']}] API error {resp.status_code}: {resp.text}", flush=True)
            except requests.RequestException as e:
                print(f"POST failed: {e}", flush=True)

        time.sleep(STEP_SECONDS)


# ---------- FastAPI ----------

app = FastAPI(title="Server Simulator Control API")


class RegisterRequest(BaseModel):
    server_id: str


class PowerRequest(BaseModel):
    powered_on: bool


class EcoRequest(BaseModel):
    eco_mode: bool


@app.get("/status")
def get_status():
    with state.lock:
        if state.server is None:
            return {"registered": False, "latest_metrics": None}
        return {
            "registered": True,
            "server_id": state.server.id,
            "powered_on": state.server.powered_on,
            "eco_mode": state.server.eco_mode,
            "latest_metrics": state.latest_metrics,
        }


@app.post("/register")
def register(req: RegisterRequest):
    with state.lock:
        state.server = Server(req.server_id)
    print(f"[register] server_id={req.server_id}", flush=True)
    return {"server_id": req.server_id, "registered": True}


@app.patch("/power")
def set_power(req: PowerRequest):
    with state.lock:
        if state.server is None:
            raise HTTPException(status_code=400, detail="Server not registered")
        state.server.powered_on = req.powered_on
    return {"powered_on": req.powered_on}


@app.patch("/eco")
def set_eco(req: EcoRequest):
    with state.lock:
        if state.server is None:
            raise HTTPException(status_code=400, detail="Server not registered")
        state.server.eco_mode = req.eco_mode
    return {"eco_mode": req.eco_mode}


# ---------- Entry point ----------

if __name__ == "__main__":
    thread = threading.Thread(target=simulation_loop, daemon=True)
    thread.start()
    print(f"Simulator API démarré — METRICS_API_URL={METRICS_API_URL}", flush=True)
    uvicorn.run(app, host="0.0.0.0", port=8080, log_level="warning")
