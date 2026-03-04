#!/bin/bash
set -e

echo "Lancement de l'API AI RL"
uvicorn api-ai.api:app --host 0.0.0.0 --port 5000 --reload
