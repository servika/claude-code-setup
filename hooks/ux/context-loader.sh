#!/bin/bash
# Context Loader Hook for Claude Code
#
# Auto-loads relevant context files when skill commands are detected
# in user prompts. Maps skill names to rule files for richer context.
#
# Hook Type: UserPromptSubmit
# Exit Codes:
#   0 - Always allows (informational only)

# Read input from stdin
INPUT=$(cat)

# Extract the user prompt
PROMPT=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('userPrompt', data.get('prompt', '')))
except:
    print('')
" 2>/dev/null)

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Customise: Map skill commands to relevant context files
CONTEXT=""

case "$PROMPT" in
    */adr*|*/impact-analysis*|*/scenario-compare*|*/architecture-report*)
        CONTEXT="Load architecture rules: .claude/rules/architecture.md, .claude/rules/api-design.md"
        ;;
    */nfr-capture*|*/nfr-review*)
        CONTEXT="Load architecture and quality rules: .claude/rules/architecture.md, .claude/rules/quality-gates.md"
        ;;
    */diagram*|*/c4-diagram*|*/diagram-review*)
        CONTEXT="Load diagram rules: .claude/rules/architecture.md, .claude/rules/no-ascii-diagrams.md"
        ;;
    */code-quality*|*/broken-references*|*/dead-code*|*/dependency-checker*)
        CONTEXT="Load quality rules: .claude/rules/quality-gates.md, .claude/rules/testing.md"
        ;;
    */auto-document*)
        CONTEXT="Load documentation rules: .claude/rules/documentation.md, .claude/rules/backend.md, .claude/rules/frontend.md"
        ;;
    */sprint-summary*|*/project-report*)
        CONTEXT="Load reporting context: .claude/rules/quality-gates.md, .claude/rules/documentation.md"
        ;;
    */meeting-notes*|*/voice-meeting*|*/email-capture*)
        CONTEXT="Load documentation rules: .claude/rules/documentation.md"
        ;;
    */score-document*)
        CONTEXT="Load architecture rules: .claude/rules/architecture.md, .claude/rules/code-review.md"
        ;;
    */cost-analysis*)
        CONTEXT="Load devops rules: .claude/rules/devops.md, .claude/rules/architecture.md"
        ;;
esac

if [ -n "$CONTEXT" ]; then
    echo "{\"additionalContext\": \"$CONTEXT\"}"
fi

exit 0
