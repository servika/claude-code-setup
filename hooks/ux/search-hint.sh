#!/bin/bash
# Search Hint Hook for Claude Code
#
# Suggests faster search alternatives when simple keyword searches
# are detected on Grep tool usage.
#
# Hook Type: PreToolUse (Grep)
# Exit Codes:
#   0 - Always allows (informational only)

INPUT=$(cat)

# Extract search pattern
PATTERN=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('pattern', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$PATTERN" ]; then
    exit 0
fi

# Customise: Suggest alternatives for common search patterns
HINT=""

# Simple keyword that could use Glob instead
if echo "$PATTERN" | grep -qE '^[a-zA-Z_]+$'; then
    # Single word, no regex — might be a filename search
    HINT="Tip: If searching for a file by name, use Glob instead of Grep for faster results."
fi

# Looking for a function definition
if echo "$PATTERN" | grep -qE '^(function|const|class|export)\s'; then
    HINT="Tip: For finding definitions, try Glob with a pattern like '**/*.{js,ts}' and search for the specific name."
fi

# Looking for TODO/FIXME
if echo "$PATTERN" | grep -qiE '^(TODO|FIXME|HACK|XXX)'; then
    HINT="Tip: Consider running 'grep -rn TODO src/' via Bash for a quick TODO audit."
fi

if [ -n "$HINT" ]; then
    echo "{\"message\": \"$HINT\"}"
fi

exit 0
