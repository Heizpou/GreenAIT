#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
cd "$APP_DIR"

echo "Export des variables d'environnement"
export $(grep -v '^#' .env.prod | xargs)

echo "Pull du repo"
git pull origin main

echo "Commit courant"
NEW_COMMIT=$(git rev-parse --short HEAD)

echo "Commit précédent (pour rollback)"
PREV_COMMIT=$(docker images greenait-api-ai --format "{{.Tag}}" | grep -v latest | head -n 1 || true)

echo "Build des images (no cache)"

docker compose \
  --env-file .env.prod \
  -f docker-compose.prod.yml \
  build --no-cache

echo "Tag des nouvelles images avec le commit"

docker tag greenait-api-ai:latest greenait-api-ai:$NEW_COMMIT
docker tag greenait-api-collect-metrics:latest greenait-api-collect-metrics:$NEW_COMMIT
docker tag greenait-api-recommendations:latest greenait-api-recommendations:$NEW_COMMIT
docker tag greenait-server-simulator:latest greenait-server-simulator:$NEW_COMMIT

echo "Déploiement"

if docker compose \
  --env-file .env.prod \
  -f docker-compose.prod.yml \
  up -d --remove-orphans --wait
then

  echo "Déploiement réussi"

  echo "Nettoyage des images inutilisées"
  docker image prune -f

else

  echo "Healthcheck échoué → rollback"

  if [ -n "$PREV_COMMIT" ]; then

    echo "Rollback vers $PREV_COMMIT"

    docker compose -f docker-compose.prod.yml down

    docker tag greenait-api-ai:$PREV_COMMIT greenait-api-ai:latest
    docker tag greenait-api-collect-metrics:$PREV_COMMIT greenait-api-collect-metrics:latest
    docker tag greenait-api-recommendations:$PREV_COMMIT greenait-api-recommendations:latest
    docker tag greenait-server-simulator:$PREV_COMMIT greenait-server-simulator:latest

    docker compose \
      --env-file .env.prod \
      -f docker-compose.prod.yml \
      up -d

    echo "Rollback terminé"

  else

    echo "Aucune image précédente trouvée, rollback impossible"

  fi

  exit 1
fi
