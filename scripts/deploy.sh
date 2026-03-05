#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
cd "$APP_DIR"

echo "Pull du repo"
git pull origin main

# Sauvegarde des images actuelles
GIT_COMMIT=$(git rev-parse --short HEAD)
echo "Tagging current images as stable-$GIT_COMMIT"
docker tag api-ai:latest api-ai:stable-$GIT_COMMIT || true
docker tag api-collect-metrics:latest api-collect-metrics:stable-$GIT_COMMIT || true
docker tag api-recommendations:latest api-recommendations:stable-$GIT_COMMIT || true
docker tag server-simulator:latest server-simulator:stable-$GIT_COMMIT || true

echo "Déploiement nouvelle version"
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --remove-orphans

# Vérification healthchecks
echo "Vérification des healthchecks"
rollback=false
for service in api-ai api-collect-metrics api-recommendations server-simulator; do
    status=$(docker inspect --format='{{.State.Health.Status}}' "$service")
    echo "$service : $status"
    if [ "$status" != "healthy" ]; then
        echo "$service unhealthy!"
        rollback=true
    fi
done

if [ "$rollback" = true ]; then
    echo "Healthcheck failed! Rollback en cours..."
    docker-compose -f docker-compose.prod.yml down
    docker tag api-ai:stable-$GIT_COMMIT api-ai:latest
    docker tag api-collect-metrics:stable-$GIT_COMMIT api-collect-metrics:latest
    docker tag api-recommendations:stable-$GIT_COMMIT api-recommendations:latest
    docker tag server-simulator:stable-$GIT_COMMIT server-simulator:latest
    docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d
    echo "Rollback terminé"
else
    echo "Déploiement OK, tous les services sont healthy"
fi
