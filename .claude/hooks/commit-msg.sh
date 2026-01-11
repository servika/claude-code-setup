#!/bin/bash

# Commit message hook to ensure documentation updates are mentioned
# This runs after the commit message is entered

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if this is a merge commit or revert
if echo "$COMMIT_MSG" | grep -qE "^(Merge|Revert)"; then
    exit 0
fi

# Get list of changed files
CHANGED_FILES=$(git diff --cached --name-only)

# Check if code files were changed
CODE_CHANGED=$(echo "$CHANGED_FILES" | grep -E '\.(js|jsx)$' | wc -l)

# Check if documentation was changed
DOCS_CHANGED=$(echo "$CHANGED_FILES" | grep -E '(README\.md|docs/|\.md$)' | wc -l)

if [ $CODE_CHANGED -gt 0 ] && [ $DOCS_CHANGED -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Documentation Update Reminder${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Code files were changed but no documentation updates detected.${NC}"
    echo ""
    echo "Consider updating:"
    echo "  • README.md - if public API or features changed"
    echo "  • Function JSDoc comments - for new/modified functions"
    echo "  • Architecture docs - if structure changed"
    echo "  • API documentation - if endpoints changed"
    echo ""
    echo -e "${YELLOW}If documentation is not needed for this change, you can proceed.${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

# Check commit message format (optional - can be customized)
MIN_LENGTH=10

if [ ${#COMMIT_MSG} -lt $MIN_LENGTH ]; then
    echo ""
    echo "❌ Commit message too short (minimum $MIN_LENGTH characters)"
    echo "Please provide a descriptive commit message."
    echo ""
    exit 1
fi

# Check for common commit message anti-patterns
if echo "$COMMIT_MSG" | grep -qiE "^(wip|test|fix|temp|asdf|todo|hack|debug)\s*$"; then
    echo ""
    echo "⚠️  Generic commit message detected: '$COMMIT_MSG'"
    echo "Consider using a more descriptive commit message."
    echo ""
    echo "Examples:"
    echo "  • feat: Add user authentication with JWT"
    echo "  • fix: Resolve memory leak in data processing"
    echo "  • docs: Update API documentation for v2 endpoints"
    echo "  • refactor: Extract validation logic into separate module"
    echo ""
    # Warning only, don't block
fi

echo -e "${GREEN}✓ Commit message validation passed${NC}"
exit 0