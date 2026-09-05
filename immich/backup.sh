#!/bin/bash
# Immich backup script

BACKUP_DIR="/data/backups/kashyyyk"
DATE=$(date +'%Y-%m-%d')
LOG="/var/log/immich_backup.log"
IMMICH_DIR="/apps/runtime/immich"
COMPOSE_FILE="/apps/homelab-docker/immich/docker-compose.yml"
ENV_FILE="/apps/homelab-docker/immich/.env"

echo "[$(date)] Starting Immich backup..." | tee -a "$LOG"

# Ensure backup drive is mounted
#mountpoint -q $BACKUP_DIR || {
#    echo "[$(date)] ERROR: Backup drive not mounted!" | tee -a "$LOG"
#    exit 1
#}

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# 1. Backup Immich data directory
echo "[$(date)] Backing up Immich data directory..." | tee -a "$LOG"

rsync -avh --delete --numeric-ids --inplace \
    "$IMMICH_DIR/" "$BACKUP_DIR/$DATE/immich/" \
    | tee -a "$LOG"

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: rsync failed!" | tee -a "$LOG"
    exit 1
fi

# 2. Backup Postgres database
echo "[$(date)] Dumping Immich database..." | tee -a "$LOG"

docker exec immich-postgres pg_dump -U postgres immich \
    > "$BACKUP_DIR/$DATE/immich_backup.sql"

gzip "$BACKUP_DIR/$DATE/immich_backup.sql"

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: pg_dump failed!" | tee -a "$LOG"
    exit 1
fi

# 3. Backup configs
echo "[$(date)] Backing up config files..." | tee -a "$LOG"

[ -f "$COMPOSE_FILE" ] && cp "$COMPOSE_FILE" "$BACKUP_DIR/$DATE/"
[ -f "$ENV_FILE" ] && cp "$ENV_FILE" "$BACKUP_DIR/$DATE/"

# 4. Prune old backups
echo "[$(date)] Pruning backups older than 30 days..." | tee -a "$LOG"

find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;

echo "[$(date)] Immich backup completed successfully." | tee -a "$LOG"
