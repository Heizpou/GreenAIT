#!/bin/sh
set -e

echo "Lancement API AI"

uvicorn api:app --host 0.0.0.0 --port 5000
