#!/usr/bin/env python3
"""
Bash Safety Hook for Claude Code

Auto-allows safe, read-only bash commands to reduce permission prompt
fatigue. Only applies to commands that cannot modify the system.

Hook Type: PreToolUse (Bash)
Exit Codes:
  0 - Command is safe, allow without prompting
  (no output) - Let the normal permission flow handle it
"""

import json
import re
import sys


# Customise: Commands that are always safe to run
SAFE_COMMANDS = [
    # File listing and info
    r'^ls\b',
    r'^pwd$',
    r'^wc\b',
    r'^file\b',
    r'^stat\b',
    r'^du\b',
    r'^df\b',
    r'^which\b',
    r'^whereis\b',

    # Git read operations
    r'^git\s+status',
    r'^git\s+log',
    r'^git\s+diff',
    r'^git\s+show',
    r'^git\s+branch\b(?!.*-[dD])',  # branch but not delete
    r'^git\s+remote\s+-v',
    r'^git\s+tag\b(?!.*-d)',
    r'^git\s+stash\s+list',

    # Node.js read operations
    r'^node\s+--version',
    r'^node\s+-v',
    r'^npm\s+--version',
    r'^npm\s+ls',
    r'^npm\s+list',
    r'^npm\s+outdated',
    r'^npm\s+audit(?!\s+fix)',  # audit but not fix
    r'^npm\s+view',
    r'^npm\s+info',
    r'^npx\s+--version',

    # Testing and linting (safe operations)
    r'^npm\s+run\s+lint',
    r'^npm\s+run\s+test',
    r'^npm\s+run\s+typecheck',
    r'^npm\s+test\b',
    r'^npx\s+eslint\b',
    r'^npx\s+prettier\s+--check',
    r'^npx\s+tsc\s+--noEmit',

    # Docker read operations
    r'^docker\s+ps',
    r'^docker\s+images',
    r'^docker\s+logs',
    r'^docker\s+inspect',
    r'^docker\s+compose\s+ps',
    r'^docker\s+compose\s+logs',

    # System info
    r'^uname\b',
    r'^hostname$',
    r'^date$',
    r'^env$',
    r'^printenv\b',
    r'^echo\s',

    # GitHub CLI read operations
    r'^gh\s+pr\s+list',
    r'^gh\s+pr\s+view',
    r'^gh\s+pr\s+status',
    r'^gh\s+issue\s+list',
    r'^gh\s+issue\s+view',
    r'^gh\s+repo\s+view',
    r'^gh\s+api\b',

    # Python version check
    r'^python3?\s+--version',
    r'^pip3?\s+list',
    r'^pip3?\s+show',
]

# Commands that should never be auto-allowed
NEVER_SAFE = [
    r'\brm\s',
    r'\bsudo\b',
    r'\bchmod\b',
    r'\bchown\b',
    r'\bkill\b',
    r'\bpkill\b',
    r'\bcurl\b.*\b-X\s*(POST|PUT|DELETE|PATCH)',
    r'\bwget\b',
    r'>[^>]',  # Output redirection (but not >>)
    r'\|.*\brm\b',  # Piped to rm
]


def is_safe(command):
    """Check if a command is safe to auto-allow."""
    command = command.strip()

    # Check never-safe patterns first
    for pattern in NEVER_SAFE:
        if re.search(pattern, command):
            return False

    # Check against safe patterns
    for pattern in SAFE_COMMANDS:
        if re.search(pattern, command):
            return True

    return False


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            sys.exit(0)
        input_data = json.loads(raw_input)
    except (json.JSONDecodeError, Exception):
        sys.exit(0)

    tool_input = input_data.get('tool_input', {})
    command = tool_input.get('command', '')

    if not command:
        sys.exit(0)

    if is_safe(command):
        # Auto-allow safe commands
        print(json.dumps({'decision': 'allow'}))

    sys.exit(0)


if __name__ == '__main__':
    main()
