#!/bin/bash
set -e

# Variables
APP_DIR="/home/deploy/GreenAIT"
BACKUP_DIR="$APP_DIR/backups"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
DB_PASS="${POSTGRES_PASSWORD}"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_BACKUPS=7

# Export password pour pg_dump
export PGPASSWORD=$DB_PASS

# Créer le répertoire de backup si inexistant
mkdir -p $BACKUP_DIR

# Nom du fichier SQL temporaire et compressé
TMP_SQL="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.tar.gz"

echo "Sauvegarde de la DB $DB_NAME dans $TMP_SQL"
pg_dump -U $DB_USER -h localhost $DB_NAME > $TMP_SQL

echo "Compression du backup en $BACKUP_FILE"
tar -czf $BACKUP_FILE -C $BACKUP_DIR "$(basename $TMP_SQL)"

# Supprimer le dump SQL temporaire
rm -f $TMP_SQL

# Supprimer les backups anciens (>7)
BACKUPS_COUNT=$(ls $BACKUP_DIR/*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUPS_COUNT" -gt "$MAX_BACKUPS" ]; then
  REMOVE_COUNT=$((BACKUPS_COUNT - MAX_BACKUPS))
  echo "Suppression de $REMOVE_COUNT anciens backups..."
  ls -t $BACKUP_DIR/*.tar.gz | tail -n $REMOVE_COUNT | xargs rm -f
fi

echo "Backup terminé !"
