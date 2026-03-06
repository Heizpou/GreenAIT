#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

cd "$APP_DIR"

echo "===== Pull du repo ====="
git pull origin main

NEW_COMMIT=$(git rev-parse --short HEAD)
PREV_COMMIT=$(git rev-parse --short HEAD^ || true)
echo "Commit courant : $NEW_COMMIT"
echo "Commit précédent : $PREV_COMMIT"

SERVICES=("greenait-frontend" "greenait-api-ai" "greenait-api-collect-metrics" "greenait-api-recommendations" \
"greenait-server-simulator-1" "greenait-server-simulator-2" "greenait-server-simulator-3")

echo "===== Détection des services modifiés ====="
MODIFIED_SERVICES=()
for S in "${SERVICES[@]}"; do
  DIR=${S#greenait-}
  if git diff --name-only HEAD^ HEAD | grep -q "^$DIR"; then
    MODIFIED_SERVICES+=("$S")
  fi
done

if [ ${#MODIFIED_SERVICES[@]} -eq 0 ]; then
  echo "Aucun service modifié → utilisation des images existantes"
else
  echo "Services à rebuild : ${MODIFIED_SERVICES[*]}"
  docker compose -f "$COMPOSE_FILE" build --pull "${MODIFIED_SERVICES[@]}"
fi

# Tag commit pour rollback
for S in "${SERVICES[@]}"; do
  docker tag "$S:latest" "$S:$NEW_COMMIT"
done

# Déploiement
if docker compose -f "$COMPOSE_FILE" up -d --remove-orphans --wait; then
  echo "Déploiement réussi"
  docker image prune -f
else
  echo "Healthcheck échoué, rollback"
  if [ -n "$PREV_COMMIT" ]; then
    docker compose -f "$COMPOSE_FILE" down
    for S in "${SERVICES[@]}"; do
      docker tag "$S:$PREV_COMMIT" "$S:latest"
    done
    docker compose -f "$COMPOSE_FILE" up -d --remove-orphans --wait
    echo "Rollback terminé"
  else
    echo "❌ Aucun commit précédent → rollback impossible"
    exit 1
  fi
fi
