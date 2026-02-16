#!/bin/bash
# Desktop Notification Hook for Claude Code
#
# Sends a desktop notification (with sound) when Claude finishes
# a long-running task. Supports macOS and Linux.
#
# Hook Type: Stop
# Exit Codes:
#   0 - Always succeeds

TITLE="Claude Code"
MESSAGE="Task completed"

# Try to get a more specific message from input
INPUT=$(cat 2>/dev/null)
if [ -n "$INPUT" ]; then
    EXTRACTED=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    msg = data.get('message', data.get('stopReason', 'Task completed'))
    print(msg[:100])
except:
    print('Task completed')
" 2>/dev/null)
    if [ -n "$EXTRACTED" ]; then
        MESSAGE="$EXTRACTED"
    fi
fi

# macOS notification
if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\"" 2>/dev/null
    exit 0
fi

# Linux notification (notify-send)
if command -v notify-send &>/dev/null; then
    notify-send "$TITLE" "$MESSAGE" --urgency=normal 2>/dev/null
    # Play sound if paplay is available
    if command -v paplay &>/dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
    fi
    exit 0
fi

# Fallback: terminal bell
printf '\a'

exit 0
