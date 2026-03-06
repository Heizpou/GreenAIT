#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"
ENV_FILE="$APP_DIR/.env.prod"

cd "$APP_DIR"

echo "===== Pull du repo ====="
git pull origin main

# Commit courant
NEW_COMMIT=$(git rev-parse --short HEAD)
echo "Commit courant : $NEW_COMMIT"

# Commit précédent pour rollback
PREV_COMMIT=$(git rev-parse --short HEAD^ || true)
echo "Commit précédent pour rollback : $PREV_COMMIT"

# Liste des services à builder/tagger
SERVICES=(
  "greenait-api-ai"
  "greenait-api-collect-metrics"
  "greenait-api-recommendations"
  "greenait-server-simulator"
)

echo "===== Build des images (no cache) ====="
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" build --no-cache

echo "===== Tag des nouvelles images ====="
for SERVICE in "${SERVICES[@]}"; do
  docker tag "$SERVICE:latest" "$SERVICE:$NEW_COMMIT"
done

echo "===== Déploiement ====="
if docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --remove-orphans --wait; then
  echo "Déploiement réussi"

  echo "Nettoyage des images inutilisées..."
  docker image prune -f

else
  echo "Healthcheck échoué → rollback"

  if [ -n "$PREV_COMMIT" ]; then
    echo "Rollback vers commit $PREV_COMMIT"

    docker compose -f "$COMPOSE_FILE" down

    # Tag rollback
    for SERVICE in "${SERVICES[@]}"; do
      docker tag "$SERVICE:$PREV_COMMIT" "$SERVICE:latest"
    done

    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --remove-orphans --wait

    echo "Rollback terminé"
  else
    echo "Aucune image précédente trouvée, rollback impossible"
  fi

  exit 1
fi
