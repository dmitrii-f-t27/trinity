#!/bin/bash
# Auto-report Ralph progress to Telegram
# Watches .response_analysis for changes and sends summary

set -uo pipefail

PROJECT_ROOT="/Users/playra/trinity"
RESPONSE_FILE="$PROJECT_ROOT/.ralph/.response_analysis"
LAST_HASH_FILE="/tmp/ralph_response_last_hash"
REPORT_SCRIPT="$PROJECT_ROOT/.ralph/scripts/report.sh"

# Get current hash of response file
if [ -f "$RESPONSE_FILE" ]; then
    CURRENT_HASH=$(md5 -q "$RESPONSE_FILE" 2>/dev/null || md5sum "$RESPONSE_FILE" | cut -d' ' -f1)
else
    echo "No response file yet"
    exit 0
fi

# Check if changed
if [ -f "$LAST_HASH_FILE" ]; then
    LAST_HASH=$(cat "$LAST_HASH_FILE")
    if [ "$CURRENT_HASH" = "$LAST_HASH" ]; then
        # No change, skip
        exit 0
    fi
fi

# Save new hash
echo "$CURRENT_HASH" > "$LAST_HASH_FILE"

# Extract summary from response_analysis
if [ -f "$RESPONSE_FILE" ]; then
    # Parse JSON for work_summary
    WORK_SUMMARY=$(cat "$RESPONSE_FILE" | grep -o '"work_summary":"[^"]*"' | head -1 | sed 's/"work_summary":"//;s/"$//' | head -c 500)
    
    LOOP_NUM=$(cat "$RESPONSE_FILE" | grep -o '"loop_number":[0-9]*' | cut -d: -f2)
    FILES_MODIFIED=$(cat "$RESPONSE_FILE" | grep -o '"files_modified":[0-9]*' | cut -d: -f2)
    STATUS=$(cat "$RESPONSE_FILE" | grep -o '"status":"[^"]*"' | head -1 | cut -d: -f2 | tr -d '"')
    
    # Check provider status from Ralph log
    RALPH_LOG="/Users/playra/trinity/.ralph/logs/ralph.log"
    PROVIDER=$(grep -i "Provider status:" "$RALPH_LOG" 2>/dev/null | tail -1 | grep -o "primary:[a-z]*" | cut -d: -f2 || echo "unknown")
    HAS_RATE_LIMIT=$(grep -i "rate.limit\|429" "$RALPH_LOG" 2>/dev/null | tail -5 | wc -l | tr -d ' ')
    HAS_FALLBACK=$(grep -i "fallback.*glm\|switching to glm" "$RALPH_LOG" 2>/dev/null | tail -5 | wc -l | tr -d ' ')
    
    # Build alert flags
    ALERT_FLAGS=""
    if [ "$PROVIDER" = "glm" ]; then
        ALERT_FLAGS="⚠️ FALLBACK (GLM-5) "
    elif [ "$HAS_RATE_LIMIT" -gt 0 ]; then
        ALERT_FLAGS="⚠️ Rate limit detected "
    fi
    
    # Send report
    MESSAGE="**🔄 Ralph Loop #$LOOP_NUM Complete** ${ALERT_FLAGS}
Status: $STATUS
Provider: ${PROVIDER}
Files: $FILES_MODIFIED

${WORK_SUMMARY:-Working...}"
    
    "$REPORT_SCRIPT" custom "$MESSAGE" 2>/dev/null || true
fi
