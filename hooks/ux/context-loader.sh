#!/bin/bash
# Context Loader Hook for Claude Code
#
# Points skill commands at the path-scoped rule files they rely on, which
# are not loaded until matching files are touched.
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
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/api-design.md"
        ;;
    */nfr-capture*|*/nfr-review*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/quality-gates.md"
        ;;
    */diagram*|*/c4-diagram*|*/diagram-review*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/no-ascii-diagrams.md"
        ;;
    */code-quality*|*/broken-references*|*/dead-code*|*/dependency-checker*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/quality-gates.md, .claude/rules/testing.md"
        ;;
    */auto-document*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/documentation.md, .claude/rules/backend.md, .claude/rules/frontend.md"
        ;;
    */sprint-summary*|*/project-report*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/quality-gates.md, .claude/rules/documentation.md"
        ;;
    */meeting-notes*|*/voice-meeting*|*/email-capture*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/documentation.md"
        ;;
    */score-document*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/code-review.md"
        ;;
    */cost-analysis*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/devops.md, .claude/rules/architecture.md"
        ;;
    */dependency-graph*|*/find-related*|*/auto-categorize*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/frontend.md, .claude/rules/backend.md"
        ;;
    */find-decisions*|*/timeline*)
        CONTEXT="Read these rule files before starting - they are path-scoped and may not be in context yet: .claude/rules/architecture.md, .claude/rules/documentation.md"
        ;;
    */skill-creator*)
        CONTEXT="Skills live in .claude/skills/<name>/SKILL.md with name, description and model frontmatter. See docs/agent-teams-guide.md for agent-team patterns."
        ;;
esac

if [ -n "$CONTEXT" ]; then
    python3 -c "
import json, sys
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'UserPromptSubmit',
        'additionalContext': sys.argv[1],
    }
}))
" "$CONTEXT"
fi

exit 0
