#!/bin/bash
# rotate.sh — Apply a new heartbeat prompt
# Usage: ./rotate.sh [custom-prompt]
#   Without args: generates from generator.sh
#   With args: uses provided prompt

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GHOST_DIR="${GHOST_DIR:-$HOME/.ghost}"
LOG_FILE="${GHOST_WORKSPACE:-.}/memory/heartbeat-interval-log.md"

# Get prompt
if [ -n "$1" ]; then
    PROMPT="$*"
else
    PROMPT=$("$SCRIPT_DIR/generator.sh" "${GHOST_NAME:-ghost}" "${GHOST_WORKSPACE:-.}")
fi

# Log the change
mkdir -p "$(dirname "$LOG_FILE")"
if [ ! -f "$LOG_FILE" ]; then
    echo "# Heartbeat Interval Log" > "$LOG_FILE"
fi

cat >> "$LOG_FILE" << EOF

## $(date +%Y-%m-%d\ %H:%M)
- **Prompt:** $PROMPT
- **Method:** $([ -n "$1" ] && echo "manual" || echo "auto-generated")
EOF

# Try common platforms
APPLIED=false

# OpenClaw
if command -v openclaw &>/dev/null; then
    openclaw config set agents.defaults.heartbeat.prompt "$PROMPT" 2>/dev/null && APPLIED=true
fi

# Fallback: write to config file
if [ "$APPLIED" = false ]; then
    mkdir -p "$GHOST_DIR"
    echo "$PROMPT" > "$GHOST_DIR/heartbeat-prompt"
fi

echo "✅ Heartbeat prompt updated"
echo "Prompt: $PROMPT"
