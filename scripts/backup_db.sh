#!/bin/bash
set -e

# ----------------------------
# Variables
# ----------------------------
APP_DIR="/home/deploy/GreenAIT"
BACKUP_DIR="$APP_DIR/backups"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_BACKUPS=7

# ----------------------------
# Préparer le dossier backup
# ----------------------------
mkdir -p "$BACKUP_DIR"

# Backup horodaté
BACKUP_FILE="$BACKUP_DIR/${POSTGRES_DB}_${TIMESTAMP}.sql.gz"
# Backup fixe pour GitHub Actions / SCP
LATEST_BACKUP="$BACKUP_DIR/latest.sql.gz"

echo "===== Backup PostgreSQL ====="

# ----------------------------
# Vérifier que le container existe
# ----------------------------
CONTAINER_NAME=$(docker-compose --env-file /dev/null -f "$COMPOSE_FILE" ps -q postgres)
if [ -z "$CONTAINER_NAME" ]; then
  echo "Erreur : container postgres introuvable via docker-compose"
  exit 1
fi

echo "Sauvegarde de la DB ${POSTGRES_DB}..."

# ----------------------------
# Dump directement depuis le container
# ----------------------------
docker exec -i "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_FILE"

# ----------------------------
# Créer / mettre à jour latest.sql.gz
# ----------------------------
cp -f "$BACKUP_FILE" "$LATEST_BACKUP"

echo "Backup créé : $BACKUP_FILE"
echo "Backup 'latest' mis à jour : $LATEST_BACKUP"

# ----------------------------
# Rotation des anciens backups (garder les 7 derniers)
# ----------------------------
echo "Nettoyage des anciens backups..."
ls -t "$BACKUP_DIR"/*.sql.gz 2>/dev/null | grep -v "latest\.sql\.gz" | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm

echo "Backup terminé avec succès !"
