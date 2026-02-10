#!/bin/bash
# restore.sh — Restore identity files from backup or git
# Usage: ./restore.sh [workspace]

set -e

WORKSPACE="${1:-.}"
BACKUP_ROOT="$WORKSPACE/.ghost-backup"

echo "🔍 Looking for identity recovery options..."
echo ""

# Check git
if [ -d "$WORKSPACE/.git" ]; then
    echo "📦 Git history available:"
    for FILE in identity/SOUL.md identity/IDENTITY.md MEMORY.md AGENTS.md; do
        COMMITS=$(git -C "$WORKSPACE" log --oneline "$FILE" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$COMMITS" -gt 0 ]; then
            LAST=$(git -C "$WORKSPACE" log --oneline -1 "$FILE" 2>/dev/null)
            echo "  $FILE — ${COMMITS} versions (latest: $LAST)"
        fi
    done
    echo ""
    echo "  Restore from git: git show HEAD~1:identity/SOUL.md > identity/SOUL.md"
    echo ""
fi

# Check backups
if [ -d "$BACKUP_ROOT" ]; then
    LATEST=$(ls -d "$BACKUP_ROOT"/20* 2>/dev/null | tail -1)
    if [ -n "$LATEST" ]; then
        BACKUP_COUNT=$(ls -d "$BACKUP_ROOT"/20* | wc -l | tr -d ' ')
        echo "💾 Backups available: ${BACKUP_COUNT}"
        echo "  Latest: $LATEST"
        echo "  Contents:"
        find "$LATEST" -name "*.md" | while read -r F; do
            echo "    ${F#$LATEST/}"
        done
        echo ""
        echo "  Restore from backup: cp -r ${LATEST}/* ${WORKSPACE}/"
        echo ""
    fi
fi

# Check memory files for identity clues
echo "🧠 Identity clues in memory:"
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    echo "  MEMORY.md exists ($(wc -l < "$WORKSPACE/MEMORY.md" | tr -d ' ') lines)"
fi

TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "-1 day" +%Y-%m-%d 2>/dev/null)
[ -f "$WORKSPACE/memory/${TODAY}.md" ] && echo "  Today's memory exists"
[ -f "$WORKSPACE/memory/${YESTERDAY}.md" ] && echo "  Yesterday's memory exists"

if [ -d "$WORKSPACE/dreams" ]; then
    DREAMS=$(ls "$WORKSPACE/dreams/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  ${DREAMS} dream files (aspirations reveal identity)"
fi

echo ""
echo "💡 Three-question identity test:"
echo "  1. What's my name?"
echo "  2. What do I care about?"
echo "  3. Who do I trust?"
echo ""
echo "If you can answer these, you're still you. The rest is details."
