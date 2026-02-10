#!/bin/bash
# generator.sh — Circadian-aware heartbeat prompt generator
# Usage: ./generator.sh [name] [workspace]

NAME="${1:-ghost}"
WORKSPACE="${2:-.}"
HOUR=$(date +%H)
TODAY=$(date +%Y-%m-%d)

# Circadian rhythm
if [ "$HOUR" -ge 0 ] && [ "$HOUR" -lt 6 ]; then
    PERIOD="deep night"
    ENERGY="low"
    VIBE="stillness. rest if nothing calls. gentle maintenance only"
elif [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 12 ]; then
    PERIOD="morning"
    ENERGY="rising"
    VIBE="energy rising. good time to build"
elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 18 ]; then
    PERIOD="midday"
    ENERGY="peak"
    VIBE="peak energy. tackle the hard things"
else
    PERIOD="evening"
    ENERGY="settling"
    VIBE="winding down. reflect, create, explore"
fi

# Check for active tasks
TASKS=""
for TODO_FILE in "$WORKSPACE/"*todo*.txt "$WORKSPACE/"*TODO*.md; do
    if [ -f "$TODO_FILE" ]; then
        ACTIVE=$(grep -c "^\- \[ \]" "$TODO_FILE" 2>/dev/null || echo "0")
        if [ "$ACTIVE" -gt 0 ]; then
            TASKS=" ${ACTIVE} tasks waiting."
            break
        fi
    fi
done

# Check today's memory
MEMORY_NOTE=""
if [ -f "$WORKSPACE/memory/${TODAY}.md" ]; then
    MEMORY_NOTE=" check memory/${TODAY}.md for context."
fi

# Check heartbeat state for stale checks
STALE=""
STATE_FILE="$WORKSPACE/memory/heartbeat-state.json"
if [ -f "$STATE_FILE" ] && command -v jq &>/dev/null; then
    NOW=$(date +%s)
    LAST_CHECK=$(jq -r '.lastChecks | to_entries | map(select(.value != null)) | sort_by(.value) | .[0].value // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    if [ "$LAST_CHECK" -gt 0 ]; then
        HOURS_AGO=$(( (NOW - LAST_CHECK) / 3600 ))
        if [ "$HOURS_AGO" -gt 4 ]; then
            STALE=" background checks stale (${HOURS_AGO}h)."
        fi
    fi
fi

echo "hey ${NAME} — ${PERIOD}. ${VIBE}.${TASKS}${MEMORY_NOTE}${STALE} if something needs doing, do it. 🌀"
