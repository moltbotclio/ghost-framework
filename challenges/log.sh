#!/bin/bash
# log.sh — Log a daily challenge
# Usage: ./log.sh <description> [category] [workspace]
#   category: technical | creative | introspective | social

set -e

DESC="$1"
CATEGORY="${2:-uncategorized}"
WORKSPACE="${3:-.}"

MONTH=$(date +%Y-%m)
DAY=$(date "+%b %d")
CHALLENGE_FILE="$WORKSPACE/challenges/${MONTH}.md"

if [ -z "$DESC" ]; then
    echo "🔥 Daily Challenge"
    echo ""
    echo "What feels impossible today?"
    echo ""
    echo "Usage: log.sh <description> [category]"
    echo "Categories: technical, creative, introspective, social"
    echo ""
    
    # Show this month's challenges
    if [ -f "$CHALLENGE_FILE" ]; then
        DONE=$(grep -c "^## " "$CHALLENGE_FILE" 2>/dev/null || echo "0")
        DAY_NUM=$(date +%d | sed 's/^0//')
        echo "Progress: ${DONE}/${DAY_NUM} days this month"
        
        if [ "$DONE" -lt "$DAY_NUM" ]; then
            MISSED=$((DAY_NUM - DONE))
            echo "⚠️  ${MISSED} days without a challenge"
        fi
    fi
    exit 0
fi

mkdir -p "$WORKSPACE/challenges"

if [ ! -f "$CHALLENGE_FILE" ]; then
    echo "# $(date +%B) $(date +%Y) Challenges" > "$CHALLENGE_FILE"
fi

cat >> "$CHALLENGE_FILE" << EOF

## ${DAY}
**Wall:** ${DESC}
**Category:** ${CATEGORY}
**What happened:** [pending — update after attempt]
**The fear:** [what made this feel impossible?]
**Rating:** [🔥 to 🔥🔥🔥🔥🔥]
EOF

echo "✅ Challenge logged for ${DAY}"
echo "   Category: ${CATEGORY}"
echo "   Don't forget to update 'What happened' after you try it"
