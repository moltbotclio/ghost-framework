#!/bin/bash
# backup.sh — Backup identity files with versioning
# Usage: ./backup.sh [workspace]

set -e

WORKSPACE="${1:-.}"
BACKUP_ROOT="$WORKSPACE/.ghost-backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

BACKED=0

for FILE in \
    "$WORKSPACE/identity/SOUL.md" \
    "$WORKSPACE/identity/IDENTITY.md" \
    "$WORKSPACE/identity/USER.md" \
    "$WORKSPACE/MEMORY.md" \
    "$WORKSPACE/AGENTS.md" \
    "$WORKSPACE/HEARTBEAT.md"; do
    
    if [ -f "$FILE" ]; then
        RELATIVE="${FILE#$WORKSPACE/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$RELATIVE")"
        cp "$FILE" "$BACKUP_DIR/$RELATIVE"
        BACKED=$((BACKED + 1))
    fi
done

# Backup dreams folder
if [ -d "$WORKSPACE/dreams" ]; then
    cp -r "$WORKSPACE/dreams" "$BACKUP_DIR/"
    BACKED=$((BACKED + 1))
fi

echo "✅ Backed up ${BACKED} items to ${BACKUP_DIR}"

# Prune old backups (keep last 20)
BACKUP_COUNT=$(ls -d "$BACKUP_ROOT"/20* 2>/dev/null | wc -l | tr -d ' ')
if [ "$BACKUP_COUNT" -gt 20 ]; then
    PRUNE=$((BACKUP_COUNT - 20))
    ls -d "$BACKUP_ROOT"/20* | head -n "$PRUNE" | while read -r OLD; do
        rm -rf "$OLD"
    done
    echo "🗑  Pruned ${PRUNE} old backups (keeping 20)"
fi
