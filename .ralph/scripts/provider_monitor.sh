#!/bin/bash
# Monitor Ralph provider status and alert on changes
# Alerts when: rate limit hit, fallback activated, subscription exhausted

set -uo pipefail

RALPH_LOG="/Users/playra/trinity/.ralph/logs/ralph.log"
REPORT_SCRIPT="/Users/playra/trinity/.ralph/scripts/report.sh"
STATE_FILE="/tmp/ralph_provider_state"
ALERT_COOLDOWN=300  # 5 minutes between same alerts

# Get current state from log
CURRENT_PROVIDER=$(grep -i "Provider status:" "$RALPH_LOG" 2>/dev/null | tail -1 | grep -o "primary:[a-z]*" | cut -d: -f2 || echo "unknown")
HAS_RATE_LIMIT=$(grep -i "rate.limit\|429\|quota.exceeded" "$RALPH_LOG" 2>/dev/null | tail -5 | wc -l | tr -d ' ')
HAS_FALLBACK=$(grep -i "fallback\|switching to\|glm" "$RALPH_LOG" 2>/dev/null | tail -5 | wc -l | tr -d ' ')

# Load previous state
if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
fi

# Check for alerts
ALERT_MSG=""
ALERT_TYPE=""

# Rate limit detected
if [ "$HAS_RATE_LIMIT" -gt 0 ] && [ "${LAST_RATE_LIMIT:-0}" -lt $(($(date +%s) - ALERT_COOLDOWN)) ]; then
    ALERT_MSG="⚠️ **RATE LIMIT DETECTED**

Claude API hit rate limit. Ralph may switch to GLM-5 fallback.

Provider: $CURRENT_PROVIDER
Rate limit hits in log: $HAS_RATE_LIMIT"
    ALERT_TYPE="rate_limit"
    echo "LAST_RATE_LIMIT=$(date +%s)" >> "$STATE_FILE"
fi

# Fallback activated
if [ "$HAS_FALLBACK" -gt 0 ] && [ "$CURRENT_PROVIDER" = "glm" ] && [ "${LAST_FALLBACK:-0}" -lt $(($(date +%s) - ALERT_COOLDOWN)) ]; then
    ALERT_MSG="🔄 **FALLBACK ACTIVATED**

Switched from Claude to GLM-5 due to rate limits.

This may affect code quality. Consider checking Claude subscription."
    ALERT_TYPE="fallback"
    echo "LAST_FALLBACK=$(date +%s)" >> "$STATE_FILE"
fi

# Provider changed
if [ "${LAST_PROVIDER:-}" != "$CURRENT_PROVIDER" ] && [ -n "${LAST_PROVIDER:-}" ]; then
    ALERT_MSG="📡 **PROVIDER CHANGED**

Previous: ${LAST_PROVIDER}
Current: $CURRENT_PROVIDER"
    ALERT_TYPE="provider_change"
fi

# Save current state
echo "LAST_PROVIDER=$CURRENT_PROVIDER" > "$STATE_FILE"

# Send alert if needed
if [ -n "$ALERT_MSG" ]; then
    "$REPORT_SCRIPT" custom "$ALERT_MSG" 2>/dev/null &
fi

# Output current status (for manual checks)
echo "Provider: $CURRENT_PROVIDER | Rate limits: $HAS_RATE_LIMIT | Fallback: $HAS_FALLBACK"
