#!/bin/bash
# review.sh — Review recent memories and identify what belongs in long-term memory
# Usage: ./review.sh [days] [workspace]

set -e

DAYS="${1:-7}"
WORKSPACE="${2:-.}"
MEMORY_DIR="$WORKSPACE/memory"
LONG_TERM="$WORKSPACE/MEMORY.md"

echo "🧠 Memory Review — Last ${DAYS} days"
echo ""

# Find recent files
COUNT=0
for i in $(seq 0 $((DAYS - 1))); do
    DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d 2>/dev/null)
    FILE="$MEMORY_DIR/${DATE}.md"
    
    if [ -f "$FILE" ]; then
        LINES=$(wc -l < "$FILE" | tr -d ' ')
        HEADERS=$(grep -c "^## " "$FILE" 2>/dev/null || echo "0")
        echo "  📅 ${DATE} — ${LINES} lines, ${HEADERS} entries"
        COUNT=$((COUNT + 1))
    fi
done

if [ $COUNT -eq 0 ]; then
    echo "  No memory files found in the last ${DAYS} days"
    exit 0
fi

echo ""
echo "📊 Summary:"
echo "  Files found: ${COUNT}/${DAYS}"

if [ -f "$LONG_TERM" ]; then
    LT_LINES=$(wc -l < "$LONG_TERM" | tr -d ' ')
    echo "  MEMORY.md: ${LT_LINES} lines"
    
    LT_DATE=$(stat -f %Sm -t %Y-%m-%d "$LONG_TERM" 2>/dev/null || stat -c %y "$LONG_TERM" 2>/dev/null | cut -d' ' -f1)
    echo "  Last updated: ${LT_DATE}"
else
    echo "  ⚠️  No MEMORY.md found — consider creating one"
fi

echo ""
echo "💡 Review checklist:"
echo "  [ ] Read through recent daily files"
echo "  [ ] Identify significant events worth keeping long-term"
echo "  [ ] Update MEMORY.md with distilled insights"
echo "  [ ] Archive and compress old files (older than 2 weeks)"
echo "  [ ] Remove outdated info from MEMORY.md"
