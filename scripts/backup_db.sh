#!/bin/bash
set -e
set -o pipefail

# ----------------------------
# Variables
# ----------------------------
APP_DIR="/home/deploy/GreenAIT"
BACKUP_DIR="$APP_DIR/backups"
POSTGRES_CONTAINER="greenait-postgres"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_BACKUPS=7

# Récupérer les variables d'environnement
POSTGRES_USER="${POSTGRES_USER:?POSTGRES_USER non défini}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:?POSTGRES_PASSWORD non défini}"
POSTGRES_DB="${POSTGRES_DB:?POSTGRES_DB non défini}"

# Préparer le dossier backup
mkdir -p "$BACKUP_DIR"

# Fichiers de backup
BACKUP_FILE="$BACKUP_DIR/${POSTGRES_DB}_${TIMESTAMP}.sql.gz"
LATEST_BACKUP="$BACKUP_DIR/latest.sql.gz"

echo "===== Backup PostgreSQL ====="
echo "Vérification de l'existence de la DB '$POSTGRES_DB' dans le container $POSTGRES_CONTAINER..."

# Vérifie que la DB existe
DB_EXISTS=$(docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$POSTGRES_CONTAINER" \
  psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB';")

if [ "$DB_EXISTS" != "1" ]; then
  echo "Erreur : la base de données '$POSTGRES_DB' n'existe pas dans le container $POSTGRES_CONTAINER."
  exit 1
fi

echo "Base de données trouvée, démarrage du dump..."

# Exécution du dump
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$POSTGRES_CONTAINER" \
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" | gzip > "$BACKUP_FILE"

# Vérifie la création du dump
if [ ! -s "$BACKUP_FILE" ]; then
  echo "Backup échoué : fichier vide ou problème de pg_dump"
  exit 1
fi

# Mise à jour du backup latest
cp -f "$BACKUP_FILE" "$LATEST_BACKUP"

echo "Backup créé : $BACKUP_FILE"
echo "Backup 'latest' mis à jour : $LATEST_BACKUP"
ls -lh "$LATEST_BACKUP"

# Rotation des anciens backups (garder les MAX_BACKUPS derniers)
echo "Nettoyage des anciens backups..."
ls -t "$BACKUP_DIR"/*.sql.gz 2>/dev/null | grep -v "latest\.sql\.gz" | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm

echo "Backup terminé avec succès !"
echo "=============================================="
