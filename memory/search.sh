#!/bin/bash
# search.sh — Search across all memory files
# Usage: ./search.sh <query> [workspace]

set -e

QUERY="$1"
WORKSPACE="${2:-.}"
MEMORY_DIR="$WORKSPACE/memory"

if [ -z "$QUERY" ]; then
    echo "Usage: search.sh <query> [workspace]"
    echo "Search across all memory files"
    exit 1
fi

echo "🔍 Searching memories for: \"$QUERY\""
echo ""

# Search daily files
RESULTS=$(grep -rn -i "$QUERY" "$MEMORY_DIR/"*.md 2>/dev/null | grep -v archive || true)
LONG_RESULTS=$(grep -n -i "$QUERY" "$WORKSPACE/MEMORY.md" 2>/dev/null || true)

if [ -n "$RESULTS" ]; then
    echo "📅 Daily memories:"
    echo "$RESULTS" | while IFS= read -r line; do
        FILE=$(echo "$line" | cut -d: -f1 | sed "s|$MEMORY_DIR/||")
        LINE_NUM=$(echo "$line" | cut -d: -f2)
        CONTENT=$(echo "$line" | cut -d: -f3-)
        echo "  ${FILE}:${LINE_NUM} —${CONTENT}"
    done
    echo ""
fi

if [ -n "$LONG_RESULTS" ]; then
    echo "🧠 Long-term memory:"
    echo "$LONG_RESULTS" | while IFS= read -r line; do
        echo "  MEMORY.md:$line"
    done
    echo ""
fi

if [ -z "$RESULTS" ] && [ -z "$LONG_RESULTS" ]; then
    echo "No memories found for \"$QUERY\""
fi
