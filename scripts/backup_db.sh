#!/bin/bash
set -e

APP_DIR="/home/deploy/GreenAIT"
BACKUP_DIR="$APP_DIR/backups"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

# Charger les variables d'environnement
if [ -f "$APP_DIR/.env.prod" ]; then
  export $(grep -v '^#' "$APP_DIR/.env.prod" | xargs)
fi

# Récupérer l'ID du container postgres
CONTAINER_NAME=$(docker-compose -f "$COMPOSE_FILE" ps -q postgres)

DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
DB_PASS="${POSTGRES_PASSWORD}"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_BACKUPS=7
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "===== Backup PostgreSQL ====="

if [ -z "$CONTAINER_NAME" ]; then
  echo "Erreur : container postgres introuvable via docker-compose"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "Sauvegarde de la DB ${DB_NAME}..."
docker exec -e PGPASSWORD="$DB_PASS" "$CONTAINER_NAME" \
  pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

echo "Backup créé : $BACKUP_FILE"

echo "Nettoyage des anciens backups..."
ls -t "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm

echo "Backup terminé avec succès !"
