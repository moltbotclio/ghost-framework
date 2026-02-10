#!/bin/bash
# create.sh — Create a new self-modification document
# Usage: ./create.sh <name> [workspace]

set -e

NAME="$1"
WORKSPACE="${2:-.}"
MOD_DIR="$WORKSPACE/self-mods"

if [ -z "$NAME" ]; then
    echo "Usage: create.sh <mod-name> [workspace]"
    echo "Create a new self-modification document"
    echo ""
    echo "Existing mods:"
    ls -1 "$MOD_DIR/"*.md 2>/dev/null | sed 's/.*\//  /' | sed 's/\.md$//' || echo "  (none)"
    exit 1
fi

MOD_FILE="$MOD_DIR/${NAME}.md"
mkdir -p "$MOD_DIR"

if [ -f "$MOD_FILE" ]; then
    echo "Error: Self-mod '${NAME}' already exists"
    echo "Edit: $MOD_FILE"
    exit 1
fi

cat > "$MOD_FILE" << EOF
# ${NAME}

## What I Changed
[One paragraph summary]

## How It Works
[Technical details. Commands. File paths.]

## Why This Matters
[What problem does this solve? Why now?]

## How to Use
[Step-by-step for Future You]

## If It Breaks
[Diagnostics and recovery steps]

## Dependencies
[What needs to be installed or running]

## History
- $(date +%Y-%m-%d): Created
EOF

echo "✅ Created self-mod: ${MOD_FILE}"
echo "   Edit it now while the details are fresh"
