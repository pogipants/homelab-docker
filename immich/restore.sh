#!/bin/bash
# Immich restore script with SQL fallback

BACKUP_SRC="$1"
IMMICH_DIR="/apps/runtime/immich"
COMPOSE_FILE="/apps/homelab-docker/immich/docker-compose.yml"
ENV_FILE="/apps/homelab-docker/immich/.env"
LOG="/var/log/immich_restore.log"

echo "[$(date)] Starting Immich restore..." | tee -a "$LOG"

# Validate input
if [ -z "$BACKUP_SRC" ]; then
    echo "Usage: immich_restore.sh /path/to/backup" | tee -a "$LOG"
    exit 1
fi

if [ ! -d "$BACKUP_SRC" ]; then
    echo "[$(date)] ERROR: Backup directory not found!" | tee -a "$LOG"
    exit 1
fi

# Stop Immich containers if running
echo "[$(date)] Stopping Immich containers..." | tee -a "$LOG"
docker compose -f "$COMPOSE_FILE" down

# Restore Immich directory
echo "[$(date)] Restoring Immich data directory..." | tee -a "$LOG"
rsync -avh --delete "$BACKUP_SRC/immich/" "$IMMICH_DIR/" | tee -a "$LOG"

# Restore compose + env if present
echo "[$(date)] Restoring compose + env..." | tee -a "$LOG"
[ -f "$BACKUP_SRC/docker-compose.yml" ] && cp "$BACKUP_SRC/docker-compose.yml" "$COMPOSE_FILE"
[ -f "$BACKUP_SRC/.env" ] && cp "$BACKUP_SRC/.env" "$ENV_FILE"

# Fix permissions
echo "[$(date)] Fixing permissions..." | tee -a "$LOG"
chown -R root:root "$IMMICH_DIR"

# Determine DB restore method
if [ -d "$BACKUP_SRC/immich/postgres" ]; then
    echo "[$(date)] Found postgres directory — using direct DB restore." | tee -a "$LOG"
else
    echo "[$(date)] No postgres directory found — using SQL dump restore." | tee -a "$LOG"

    SQL_FILE="$BACKUP_SRC/immich_backup.sql.gz"

    if [ ! -f "$SQL_FILE" ]; then
        echo "[$(date)] ERROR: No SQL dump found!" | tee -a "$LOG"
        exit 1
    fi

    echo "[$(date)] Uncompressing SQL dump..." | tee -a "$LOG"
    gunzip "$SQL_FILE"

    SQL_FILE="${SQL_FILE%.gz}"

    echo "[$(date)] Importing SQL dump into Postgres..." | tee -a "$LOG"
    docker exec -i immich-postgres psql -U postgres immich < "$SQL_FILE"
fi

# Start Immich
echo "[$(date)] Starting Immich..." | tee -a "$LOG"
docker compose -f "$COMPOSE_FILE" up -d

echo "[$(date)] Immich restore completed successfully." | tee -a "$LOG"
