#!/usr/bin/env python3
"""
Code Formatter Hook for Claude Code

Auto-formats files after Edit/Write operations using the appropriate
formatter for the file type (Prettier, Black, gofmt, etc.)

Hook Type: PostToolUse (Edit|Write)
Exit Codes:
  0 - Formatted successfully or no formatter needed
  1 - Formatter warning (non-blocking)
"""

import json
import os
import subprocess
import sys


# Customise: Map file extensions to formatters
FORMATTERS = {
    # JavaScript/TypeScript (Prettier)
    '.js': ['npx', 'prettier', '--write'],
    '.jsx': ['npx', 'prettier', '--write'],
    '.ts': ['npx', 'prettier', '--write'],
    '.tsx': ['npx', 'prettier', '--write'],
    '.css': ['npx', 'prettier', '--write'],
    '.scss': ['npx', 'prettier', '--write'],
    '.json': ['npx', 'prettier', '--write'],
    '.md': ['npx', 'prettier', '--write'],
    '.yaml': ['npx', 'prettier', '--write'],
    '.yml': ['npx', 'prettier', '--write'],

    # Python (Black)
    '.py': ['black', '--quiet'],

    # Go
    '.go': ['gofmt', '-w'],

    # Rust
    '.rs': ['rustfmt'],

    # Shell
    '.sh': ['shfmt', '-w'],
}

# Customise: Skip formatting for these paths
SKIP_PATHS = [
    'node_modules/',
    'dist/',
    'build/',
    '.git/',
    'vendor/',
    'coverage/',
    'package-lock.json',
    'yarn.lock',
]


def should_skip(file_path):
    """Check if file should skip formatting."""
    for skip in SKIP_PATHS:
        if skip in file_path:
            return True
    return False


def get_formatter(file_path):
    """Get the formatter command for a file type."""
    _, ext = os.path.splitext(file_path)
    return FORMATTERS.get(ext.lower())


def formatter_available(cmd):
    """Check if a formatter binary is available."""
    try:
        subprocess.run(
            ['which', cmd[0] if cmd[0] != 'npx' else cmd[1]],
            capture_output=True,
            timeout=5,
        )
        return True
    except (subprocess.SubprocessError, FileNotFoundError):
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
    file_path = tool_input.get('file_path', '')

    if not file_path or not os.path.isfile(file_path):
        sys.exit(0)

    if should_skip(file_path):
        sys.exit(0)

    formatter = get_formatter(file_path)
    if not formatter:
        sys.exit(0)

    try:
        result = subprocess.run(
            formatter + [file_path],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            # Non-blocking warning
            print(json.dumps({
                'message': f"Formatter warning for {os.path.basename(file_path)}: {result.stderr[:200]}",
            }))
            sys.exit(1)
    except FileNotFoundError:
        # Formatter not installed, skip silently
        pass
    except subprocess.TimeoutExpired:
        print(json.dumps({
            'message': f"Formatter timed out for {os.path.basename(file_path)}",
        }))
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
