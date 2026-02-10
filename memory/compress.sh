#!/bin/bash
# compress.sh — Compress old memory files while preserving key moments
# Usage: ./compress.sh <date> [workspace]
#   e.g. ./compress.sh 2026-02-05

set -e

DATE="$1"
WORKSPACE="${2:-.}"
MEMORY_DIR="$WORKSPACE/memory"
ARCHIVE_DIR="$MEMORY_DIR/archive"

if [ -z "$DATE" ]; then
    echo "Usage: compress.sh <YYYY-MM-DD> [workspace]"
    echo "Compress a daily memory file, archiving the original"
    exit 1
fi

SOURCE="$MEMORY_DIR/${DATE}.md"

if [ ! -f "$SOURCE" ]; then
    echo "Error: No memory file found at $SOURCE"
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"

# Archive original
cp "$SOURCE" "$ARCHIVE_DIR/${DATE}-full.md"
echo "✅ Archived original to $ARCHIVE_DIR/${DATE}-full.md"

# Count lines before
BEFORE=$(wc -l < "$SOURCE" | tr -d ' ')

# Create compressed version
# Keep: headers, timestamps, key decisions, emotional markers
# Remove: verbose logs, repeated info, routine entries
awk '
    /^#/ { print; next }
    /^---/ { print; next }
    /^##/ { print; next }
    /\*\*/ { print; next }
    /✅|❌|🔥|🌀|💙|⚠️/ { print; next }
    /lesson|breakthrough|important|critical|decision|realized|learned/ { print; next }
    /MISSING|ERROR|BROKEN|FIXED/ { print; next }
    { next }
' "$SOURCE" > "${SOURCE}.tmp"

mv "${SOURCE}.tmp" "$SOURCE"

AFTER=$(wc -l < "$SOURCE" | tr -d ' ')
SAVED=$((BEFORE - AFTER))

echo "✅ Compressed: ${BEFORE} → ${AFTER} lines (saved ${SAVED})"
echo "   Original preserved in archive/"
