#!/bin/bash
set -euo pipefail

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_FILE="/tmp/backup-${TIMESTAMP}.tar.gz"
BUCKET="cloud-exam-backups-crown-2026"
LOG_FILE="/var/log/backup.log"

if tar -czf "$BACKUP_FILE" -C /var/app data; then
    if aws s3 cp "$BACKUP_FILE" "s3://${BUCKET}/backups/"; then
        echo "$(date): Backup uploaded successfully: $(basename "$BACKUP_FILE")" >> "$LOG_FILE"
        rm -f "$BACKUP_FILE"
    else
        echo "$(date): Backup upload failed: $(basename "$BACKUP_FILE")" >> "$LOG_FILE"
        exit 1
    fi
else
    echo "$(date): Backup archive creation failed" >> "$LOG_FILE"
    exit 1
fi
