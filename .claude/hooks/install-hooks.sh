#!/bin/bash

# Installation script for git hooks
# This script copies hooks to .git/hooks and makes them executable

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔧 Installing Git Hooks..."
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository root directory${NC}"
    echo "Please run this script from the root of your git repository."
    exit 1
fi

# Get the directory where this script is located
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy and install hooks
HOOKS_INSTALLED=0

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit.sh" ]; then
    cp "$HOOKS_DIR/pre-commit.sh" ".git/hooks/pre-commit"
    chmod +x ".git/hooks/pre-commit"
    echo -e "${GREEN}✓ Installed pre-commit hook${NC}"
    HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
fi

# Install commit-msg hook
if [ -f "$HOOKS_DIR/commit-msg.sh" ]; then
    cp "$HOOKS_DIR/commit-msg.sh" ".git/hooks/commit-msg"
    chmod +x ".git/hooks/commit-msg"
    echo -e "${GREEN}✓ Installed commit-msg hook${NC}"
    HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
fi

# Copy code review prompt
if [ -f "$HOOKS_DIR/code-review-prompt.md" ]; then
    cp "$HOOKS_DIR/code-review-prompt.md" ".git/hooks/code-review-prompt.md"
    echo -e "${GREEN}✓ Installed code review prompt${NC}"
fi

echo ""
echo "=========================================="
if [ $HOOKS_INSTALLED -gt 0 ]; then
    echo -e "${GREEN}✓ Successfully installed $HOOKS_INSTALLED git hook(s)${NC}"
    echo ""
    echo "Hooks will now run automatically:"
    echo "  • pre-commit: Runs linting and coverage checks"
    echo "  • commit-msg: Reminds about documentation updates"
    echo ""
    echo "To bypass hooks (not recommended):"
    echo "  git commit --no-verify"
else
    echo -e "${YELLOW}⚠️  No hooks were installed${NC}"
fi
echo "=========================================="