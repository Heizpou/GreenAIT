#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

cd "$APP_DIR"

echo "===== Pull du repo ====="
git fetch origin main
git reset --hard origin/main

NEW_COMMIT=$(git rev-parse --short HEAD)
PREV_COMMIT=$(git rev-parse --short HEAD^ || true)
echo "Commit courant : $NEW_COMMIT"
echo "Commit précédent : $PREV_COMMIT"

SERVICES=("greenait-frontend" "greenait-api-ai" "greenait-api-collect-metrics" "greenait-api-recommendations" \
"greenait-server-simulator-1" "greenait-server-simulator-2" "greenait-server-simulator-3")

# Retourne true si un service doit être rebuild selon les fichiers modifiés
service_changed() {
  local short="$1"
  local changed
  changed=$(git diff --name-only HEAD^ HEAD)
  case "$short" in
    server-simulator-*)
      echo "$changed" | grep -qE "^(server-simulator|shared/server-lib)/"
      ;;
    api-collect-metrics|api-recommendations)
      echo "$changed" | grep -qE "^($short|shared/GreenAIT\.Data)/"
      ;;
    *)
      echo "$changed" | grep -q "^$short/"
      ;;
  esac
}

echo "===== Détection des services modifiés ====="
MODIFIED_SERVICES=()
for S in "${SERVICES[@]}"; do
  SHORT="${S#greenait-}"
  if service_changed "$SHORT"; then
    MODIFIED_SERVICES+=("$SHORT")
  fi
done
# Dédoublonner (les 3 simulateurs partagent le même Dockerfile)
MODIFIED_SERVICES=($(printf '%s\n' "${MODIFIED_SERVICES[@]}" | sort -u))

if [ ${#MODIFIED_SERVICES[@]} -eq 0 ]; then
  echo "Aucun service modifié → utilisation des images existantes"
else
  echo "Services à rebuild : ${MODIFIED_SERVICES[*]}"
  docker compose --project-name greenait --env-file /dev/null -f "$COMPOSE_FILE" build --pull "${MODIFIED_SERVICES[@]}"
fi

# Tag commit pour rollback
for S in "${SERVICES[@]}"; do
  docker tag "$S:latest" "$S:$NEW_COMMIT"
done

# Down des containers
echo "Down des containers et suppression de Traefik"
docker rm -f traefik || true
docker compose --project-name greenait --env-file /dev/null -f "$COMPOSE_FILE" down --remove-orphans

# Déploiement
echo "Déploiement des nouveaux containers"
if docker compose --project-name greenait --env-file /dev/null -f "$COMPOSE_FILE" up -d --remove-orphans --wait; then
  echo "Déploiement réussi"
  docker image prune -f
else
  echo "Healthcheck échoué, rollback"
  if [ -n "$PREV_COMMIT" ]; then
    docker compose --project-name greenait --env-file /dev/null -f "$COMPOSE_FILE" down
    for S in "${SERVICES[@]}"; do
      docker tag "$S:$PREV_COMMIT" "$S:latest"
    done
    docker compose --project-name greenait --env-file /dev/null -f "$COMPOSE_FILE" up -d --remove-orphans --wait
    echo "Rollback terminé"
  else
    echo "❌ Aucun commit précédent → rollback impossible"
    exit 1
  fi
fi
