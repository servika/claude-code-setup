#!/usr/bin/env python3
"""
Import Checker Hook for Claude Code

Validates that import/require paths in JavaScript/TypeScript files
point to existing files after edits.

Hook Type: PostToolUse (Edit|Write)
Exit Codes:
  0 - All imports valid
  1 - Warning: broken imports found (non-blocking)
"""

import json
import os
import re
import sys


# Customise: File extensions to check
CHECK_EXTENSIONS = {'.js', '.jsx', '.ts', '.tsx'}

# Import patterns
IMPORT_PATTERNS = [
    # ES6 imports: import X from './path'
    r"""(?:import\s+.*?\s+from\s+['"])(\.\.?/[^'"]+)['"]""",
    # Dynamic imports: import('./path')
    r"""import\(\s*['"](\.\.\?/[^'"]+)['"]\s*\)""",
    # Require: require('./path')
    r"""require\(\s*['"](\.\.\?/[^'"]+)['"]\s*\)""",
]

# Extensions to try when resolving imports
RESOLVE_EXTENSIONS = ['', '.js', '.jsx', '.ts', '.tsx', '/index.js', '/index.jsx', '/index.ts', '/index.tsx']


def resolve_import(base_dir, import_path):
    """Try to resolve an import path to an existing file."""
    full_path = os.path.normpath(os.path.join(base_dir, import_path))
    for ext in RESOLVE_EXTENSIONS:
        candidate = full_path + ext
        if os.path.isfile(candidate):
            return True
    return False


def check_imports(file_path):
    """Check all relative imports in a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except (IOError, UnicodeDecodeError):
        return []

    base_dir = os.path.dirname(file_path)
    broken = []

    for pattern in IMPORT_PATTERNS:
        for match in re.finditer(pattern, content):
            import_path = match.group(1)
            if not resolve_import(base_dir, import_path):
                line_num = content[:match.start()].count('\n') + 1
                broken.append({
                    'line': line_num,
                    'import': import_path,
                })

    return broken


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

    if not file_path:
        sys.exit(0)

    _, ext = os.path.splitext(file_path)
    if ext.lower() not in CHECK_EXTENSIONS:
        sys.exit(0)

    if not os.path.isfile(file_path):
        sys.exit(0)

    broken = check_imports(file_path)

    if broken:
        details = '; '.join(
            f"line {b['line']}: {b['import']}" for b in broken[:5]
        )
        output = {
            'message': f"Broken imports in {os.path.basename(file_path)}: {details}",
        }
        print(json.dumps(output))
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
