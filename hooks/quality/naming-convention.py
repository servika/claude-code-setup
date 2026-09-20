#!/usr/bin/env python3
"""
Naming Convention Checker Hook for Claude Code

Validates that newly created or renamed files follow the project's
naming conventions based on their directory and purpose.

Hook Type: PostToolUse (Write)
Output:
  Non-blocking. Violations are surfaced to Claude as PostToolUse
  `hookSpecificOutput.additionalContext`; the exit code is always 0.
"""

import json
import os
import re
import sys


def warn(message):
    """Surface a non-blocking note to Claude via PostToolUse additionalContext."""
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PostToolUse",
                    "additionalContext": message,
                },
            }
        )
    )
    sys.exit(0)



# Customise: Naming conventions per directory
CONVENTIONS = {
    "components": {
        "pattern": r"^[A-Z][A-Za-z0-9]+\.(tsx|jsx)$",
        "description": "PascalCase with .tsx extension",
        "example": "UserProfile.tsx",
    },
    "pages": {
        "pattern": r"^[A-Z][A-Za-z0-9]+\.(tsx|jsx)$",
        "description": "PascalCase with .tsx extension",
        "example": "Dashboard.tsx",
    },
    "layouts": {
        "pattern": r"^[A-Z][A-Za-z0-9]+\.(tsx|jsx)$",
        "description": "PascalCase with .tsx extension",
        "example": "MainLayout.tsx",
    },
    "hooks": {
        "pattern": r"^use[A-Z][A-Za-z0-9]+\.(ts|tsx|js)$",
        "description": 'camelCase starting with "use"',
        "example": "useAuth.ts",
    },
    "services": {
        "pattern": r"^[a-z][a-z0-9-]+\.service\.(ts|js)$",
        "description": "kebab-case with .service.ts extension",
        "example": "user.service.ts",
    },
    "controllers": {
        "pattern": r"^[a-z][a-z0-9-]+\.controller\.(ts|js)$",
        "description": "kebab-case with .controller.ts extension",
        "example": "users.controller.ts",
    },
    "repositories": {
        "pattern": r"^[a-z][a-z0-9-]+\.repository\.(ts|js)$",
        "description": "kebab-case with .repository.ts extension",
        "example": "users.repository.ts",
    },
    "routes": {
        "pattern": r"^[a-z][a-z0-9-]+\.routes?\.(ts|js)$",
        "description": "kebab-case with .routes.ts extension",
        "example": "users.routes.ts",
    },
    "middleware": {
        "pattern": r"^[a-z][a-z0-9-]+\.middleware\.(ts|js)$",
        "description": "kebab-case with .middleware.ts extension",
        "example": "auth.middleware.ts",
    },
    "schemas": {
        "pattern": r"^[a-z][a-z0-9-]+\.schema\.(ts|js)$",
        "description": "kebab-case with .schema.ts extension (Zod schemas)",
        "example": "user.schema.ts",
    },
    "validators": {
        "pattern": r"^[a-z][a-z0-9-]+\.validator\.(ts|js)$",
        "description": "kebab-case with .validator.ts extension",
        "example": "user.validator.ts",
    },
    "utils": {
        "pattern": r"^[a-z][a-z0-9-]+\.(ts|js)$",
        "description": "kebab-case with .ts extension",
        "example": "format-date.ts",
    },
    "lib": {
        "pattern": r"^[a-z][a-z0-9-]+\.(ts|js)$",
        "description": "kebab-case with .ts extension",
        "example": "query-client.ts",
    },
    "migrations": {
        "pattern": r"^\d{3,}[_-][a-z0-9][a-z0-9-_]*\.(sql|ts)$",
        "description": "numeric prefix + snake/kebab description",
        "example": "0001_create_users.sql",
    },
    "tests": {
        "pattern": r"^.*\.(test|spec)\.(ts|tsx|js|jsx|mts)$",
        "description": "Matching source file with .test/.spec suffix",
        "example": "user.service.test.ts",
    },
}


def get_convention(file_path):
    """Determine which convention applies based on directory."""
    parts = file_path.replace("\\", "/").split("/")
    for part in reversed(parts[:-1]):
        part_lower = part.lower()
        if part_lower in CONVENTIONS:
            return CONVENTIONS[part_lower]
        # Check for __tests__ directory
        if part_lower in ("__tests__", "__test__", "test", "tests"):
            return CONVENTIONS["tests"]
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
    tool_name = input_data.get("tool_name", "")
    if tool_name != "Write":
        sys.exit(0)

    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path:
        sys.exit(0)

    convention = get_convention(file_path)
    if not convention:
        sys.exit(0)

    filename = os.path.basename(file_path)
    if not re.match(convention["pattern"], filename):
        warn(
            f"Naming convention: {filename} in this directory should be "
            f"{convention['description']} (e.g., {convention['example']})"
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
