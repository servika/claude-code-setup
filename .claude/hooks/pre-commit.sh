#!/bin/bash

# Pre-commit hook for linting and test coverage validation
# This hook runs before each commit to ensure code quality standards

set -e

echo "🔍 Running pre-commit checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any check fails
CHECKS_FAILED=0

# 0. Auto-generate documentation from code
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOOKS_DIR/generate-docs.sh" ]; then
    bash "$HOOKS_DIR/generate-docs.sh"
else
    echo -e "${YELLOW}⚠️  Documentation generator not found, skipping${NC}"
fi

# 1. ESLint Check
echo ""
echo "📝 Running ESLint..."
if npm run lint --silent; then
    echo -e "${GREEN}✓ ESLint passed${NC}"
else
    echo -e "${RED}✗ ESLint failed - fix linting errors before committing${NC}"
    CHECKS_FAILED=1
fi

# 2. Check for console.log statements (warning only)
echo ""
echo "🔍 Checking for console.log statements..."
if git diff --cached --name-only | grep -E '\.(js|jsx)$' | xargs grep -n "console\.log" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Found console.log statements. Consider using a proper logger.${NC}"
fi

# 3. Test Coverage Check
echo ""
echo "🧪 Running tests with coverage..."
if npm run test:coverage --silent 2>&1 | tee /tmp/coverage-output.txt; then

    # Check overall coverage
    COVERAGE=$(grep -oP "All files\s+\|\s+\K[\d.]+" /tmp/coverage-output.txt | head -1)

    if [ ! -z "$COVERAGE" ]; then
        COVERAGE_INT=$(echo $COVERAGE | cut -d. -f1)

        if [ "$COVERAGE_INT" -lt 60 ]; then
            echo -e "${RED}✗ Test coverage is ${COVERAGE}% (minimum: 60%)${NC}"
            echo -e "${RED}  Please add tests to increase coverage${NC}"
            CHECKS_FAILED=1
        else
            echo -e "${GREEN}✓ Test coverage: ${COVERAGE}% (minimum: 60%)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not determine coverage percentage${NC}"
    fi

    # Check for files with less than 20% coverage
    LOW_COVERAGE_FILES=$(grep -E "^\s+src/" /tmp/coverage-output.txt | awk '{if ($2 < 20 && $2 != "0") print $1, $2"%"}')

    if [ ! -z "$LOW_COVERAGE_FILES" ]; then
        echo -e "${YELLOW}⚠️  Files with less than 20% coverage:${NC}"
        echo "$LOW_COVERAGE_FILES"
        echo -e "${YELLOW}  Consider adding tests for these files${NC}"
    fi

    rm -f /tmp/coverage-output.txt
else
    echo -e "${RED}✗ Tests failed - fix failing tests before committing${NC}"
    CHECKS_FAILED=1
    rm -f /tmp/coverage-output.txt
fi

# 4. Check for JSDoc comments on functions
echo ""
echo "📚 Checking for JSDoc comments..."
MISSING_JSDOC=0

# Get list of staged JavaScript files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx)$' || true)

if [ ! -z "$STAGED_FILES" ]; then
    for FILE in $STAGED_FILES; do
        # Skip test files
        if [[ "$FILE" =~ \.(test|spec)\.(js|jsx)$ ]]; then
            continue
        fi

        # Check for function declarations without JSDoc
        # This is a simple check - it looks for functions without /** */ above them
        FUNCTIONS_WITHOUT_JSDOC=$(grep -n "^\s*\(export\s\+\)\?\(async\s\+\)\?function\s" "$FILE" 2>/dev/null | while read -r LINE; do
            LINE_NUM=$(echo "$LINE" | cut -d: -f1)
            PREV_LINE=$((LINE_NUM - 1))

            # Check if previous line has JSDoc
            if ! sed -n "${PREV_LINE}p" "$FILE" | grep -q "\*/"; then
                echo "$FILE:$LINE_NUM"
            fi
        done)

        if [ ! -z "$FUNCTIONS_WITHOUT_JSDOC" ]; then
            echo -e "${YELLOW}⚠️  Functions without JSDoc in $FILE:${NC}"
            echo "$FUNCTIONS_WITHOUT_JSDOC"
            MISSING_JSDOC=1
        fi
    done

    if [ $MISSING_JSDOC -eq 0 ]; then
        echo -e "${GREEN}✓ All functions have JSDoc comments${NC}"
    else
        echo -e "${YELLOW}⚠️  Some functions are missing JSDoc comments${NC}"
        echo -e "${YELLOW}  Add JSDoc comments with @param, @returns, @throws${NC}"
    fi
fi

# 5. Check for updated documentation
echo ""
echo "📖 Checking documentation updates..."
if git diff --cached --name-only | grep -qE '\.(js|jsx)$'; then
    if ! git diff --cached --name-only | grep -qE '(README\.md|\.md$)'; then
        echo -e "${YELLOW}⚠️  Code changes detected but no documentation updates${NC}"
        echo -e "${YELLOW}  Consider updating README.md or relevant documentation${NC}"
    else
        echo -e "${GREEN}✓ Documentation updates detected${NC}"
    fi
fi

# Summary
echo ""
echo "========================================"
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Ready to commit.${NC}"
    echo "========================================"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please fix the issues above.${NC}"
    echo "========================================"
    exit 1
fi