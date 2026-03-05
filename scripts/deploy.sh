#!/bin/bash
set -eo pipefail

# -----------------------------
# Directory
# -----------------------------
APP_DIR="/home/deploy/GreenAIT"
cd "$APP_DIR"

# -----------------------------
# Export des variables d'environnement
# -----------------------------
echo "Export des variables d'environnement"
if [ -f .env.prod ]; then
    export $(grep -v '^#' .env.prod | xargs)
else
    echo ".env.prod introuvable !"
    exit 1
fi

# -----------------------------
# Pull depuis le repo
# -----------------------------
echo "Pull du repo"
git pull origin main

# -----------------------------
# Build des images
# -----------------------------
echo "Build des images Docker"
docker-compose -f docker-compose.prod.yml build

# -----------------------------
# Sauvegarde des images actuelles
# -----------------------------
GIT_COMMIT=$(git rev-parse --short HEAD)
echo "Tagging current images as stable-$GIT_COMMIT"
for image in api-ai api-collect-metrics api-recommendations server-simulator; do
    if docker image inspect "$image:latest" >/dev/null 2>&1; then
        docker tag "$image:latest" "$image:stable-$GIT_COMMIT"
    else
        echo "Image $image:latest introuvable, skipping tag"
    fi
done

# -----------------------------
# Déploiement nouvelle version
# -----------------------------
echo "Déploiement nouvelle version"
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --remove-orphans

# -----------------------------
# Vérification des healthchecks
# -----------------------------
echo "Vérification des healthchecks"
rollback=false
services=(api-ai api-collect-metrics api-recommendations server-simulator-1 server-simulator-2 server-simulator-3)

for service in "${services[@]}"; do
    container_id=$(docker-compose -f docker-compose.prod.yml ps -q "$service")
    if [ -z "$container_id" ]; then
        echo "$service : container introuvable"
        rollback=true
        continue
    fi

    # Attendre que le healthcheck ait une chance de réussir
    for i in {1..12}; do
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" || echo "unavailable")
        if [ "$status" = "healthy" ]; then
            break
        fi
        echo "$service : $status (attente...)"
        sleep 5
    done

    status=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" || echo "unavailable")
    echo "$service : $status"
    if [ "$status" != "healthy" ]; then
        echo "$service unhealthy!"
        rollback=true
    fi
done

# -----------------------------
# Rollback si nécessaire
# -----------------------------
if [ "$rollback" = true ]; then
    echo "Healthcheck failed! Rollback en cours..."
    docker-compose -f docker-compose.prod.yml down

    for image in api-ai api-collect-metrics api-recommendations server-simulator; do
        if docker image inspect "$image:stable-$GIT_COMMIT" >/dev/null 2>&1; then
            docker tag "$image:stable-$GIT_COMMIT" "$image:latest"
        fi
    done

    docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d
    echo "Rollback terminé"
else
    echo "Déploiement OK, tous les services sont healthy"
fi
