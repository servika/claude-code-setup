#!/usr/bin/env python3
"""
Naming Convention Checker Hook for Claude Code

Validates that newly created or renamed files follow the project's
naming conventions based on their directory and purpose.

Hook Type: PostToolUse (Write)
Exit Codes:
  0 - Naming convention followed
  1 - Warning: naming convention violation (non-blocking)
"""

import json
import os
import re
import sys


# Customise: Naming conventions per directory
CONVENTIONS = {
    'components': {
        'pattern': r'^[A-Z][A-Za-z0-9]+\.(jsx|tsx)$',
        'description': 'PascalCase with .jsx/.tsx extension',
        'example': 'UserProfile.jsx',
    },
    'pages': {
        'pattern': r'^[A-Z][A-Za-z0-9]+\.(jsx|tsx)$',
        'description': 'PascalCase with .jsx/.tsx extension',
        'example': 'Dashboard.jsx',
    },
    'hooks': {
        'pattern': r'^use[A-Z][A-Za-z0-9]+\.(js|ts)$',
        'description': 'camelCase starting with "use"',
        'example': 'useAuth.js',
    },
    'services': {
        'pattern': r'^[a-z][a-z0-9-]+\.service\.(js|ts)$',
        'description': 'kebab-case with .service.js extension',
        'example': 'user.service.js',
    },
    'controllers': {
        'pattern': r'^[a-z][a-z0-9-]+\.controller\.(js|ts)$',
        'description': 'kebab-case with .controller.js extension',
        'example': 'users.controller.js',
    },
    'routes': {
        'pattern': r'^[a-z][a-z0-9-]+\.routes?\.(js|ts)$',
        'description': 'kebab-case with .routes.js extension',
        'example': 'users.routes.js',
    },
    'middleware': {
        'pattern': r'^[a-z][a-z0-9-]+\.middleware\.(js|ts)$',
        'description': 'kebab-case with .middleware.js extension',
        'example': 'auth.middleware.js',
    },
    'validators': {
        'pattern': r'^[a-z][a-z0-9-]+\.validator\.(js|ts)$',
        'description': 'kebab-case with .validator.js extension',
        'example': 'user.validator.js',
    },
    'utils': {
        'pattern': r'^[a-z][a-z0-9-]+\.(js|ts)$',
        'description': 'kebab-case with .js extension',
        'example': 'format-date.js',
    },
    'tests': {
        'pattern': r'^.*\.(test|spec)\.(js|jsx|ts|tsx)$',
        'description': 'Matching source file with .test/.spec suffix',
        'example': 'user.service.test.js',
    },
}


def get_convention(file_path):
    """Determine which convention applies based on directory."""
    parts = file_path.replace('\\', '/').split('/')
    for part in reversed(parts[:-1]):
        part_lower = part.lower()
        if part_lower in CONVENTIONS:
            return CONVENTIONS[part_lower]
        # Check for __tests__ directory
        if part_lower in ('__tests__', '__test__', 'test', 'tests'):
            return CONVENTIONS['tests']
    return None


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            sys.exit(0)
        input_data = json.loads(raw_input)
    except (json.JSONDecodeError, Exception):
        sys.exit(0)

    # Only check Write tool (new file creation)
    tool_name = input_data.get('tool_name', '')
    if tool_name != 'Write':
        sys.exit(0)

    tool_input = input_data.get('tool_input', {})
    file_path = tool_input.get('file_path', '')

    if not file_path:
        sys.exit(0)

    convention = get_convention(file_path)
    if not convention:
        sys.exit(0)

    filename = os.path.basename(file_path)
    if not re.match(convention['pattern'], filename):
        output = {
            'message': (
                f"Naming convention: {filename} in this directory should be "
                f"{convention['description']} (e.g., {convention['example']})"
            ),
        }
        print(json.dumps(output))
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
