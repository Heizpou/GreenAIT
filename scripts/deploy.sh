#!/bin/bash
set -eo pipefail

APP_DIR="/home/deploy/GreenAIT"
cd "$APP_DIR"

echo "Export des variables d'environnement"
export $(grep -v '^#' .env.prod | xargs)

echo "Pull du repo"
git pull origin main

echo "Récupération du commit courant"
GIT_COMMIT=$(git rev-parse --short HEAD)

echo "Sauvegarde des images actuelles"

docker tag api-ai:latest api-ai:backup-$GIT_COMMIT || true
docker tag api-collect-metrics:latest api-collect-metrics:backup-$GIT_COMMIT || true
docker tag api-recommendations:latest api-recommendations:backup-$GIT_COMMIT || true
docker tag server-simulator:latest server-simulator:backup-$GIT_COMMIT || true

echo "Déploiement de la nouvelle version"

if docker compose \
    --env-file .env.prod \
    -f docker-compose.prod.yml \
    up -d --remove-orphans --wait
then

    echo "Déploiement réussi : tous les services sont healthy"

else

    echo "Healthcheck échoué → rollback"

    # echo "Arrêt des containers"
    # docker compose -f docker-compose.prod.yml down

    # echo "Restauration des images précédentes"
    # docker tag api-ai:backup-$GIT_COMMIT api-ai:latest
    # docker tag api-collect-metrics:backup-$GIT_COMMIT api-collect-metrics:latest
    # docker tag api-recommendations:backup-$GIT_COMMIT api-recommendations:latest
    # docker tag server-simulator:backup-$GIT_COMMIT server-simulator:latest

    # echo "Redémarrage avec l'ancienne version"
    # docker compose \
    #     --env-file .env.prod \
    #     -f docker-compose.prod.yml \
    #     up -d

    # echo "Rollback terminé"
    # exit 1
fi
