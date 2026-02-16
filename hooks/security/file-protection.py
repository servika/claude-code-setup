#!/usr/bin/env python3
"""
File Protection Hook for Claude Code

Blocks edits to sensitive files like .env, lockfiles, private keys,
credentials, and CI/CD configs unless explicitly allowed.

Hook Type: PreToolUse (Edit|Write)
Exit Codes:
  0 - File is not protected, allow
  2 - File is protected, block edit
"""

import json
import re
import sys


# Customise: Files and patterns to protect from modification
PROTECTED_PATTERNS = [
    # Environment and secrets
    (r'\.env($|\.)', 'Environment file — may contain secrets'),
    (r'\.env\.local', 'Local environment file'),
    (r'\.env\.production', 'Production environment file'),
    (r'credentials\.json', 'Credentials file'),
    (r'service[_\-]account.*\.json', 'Service account key'),

    # Private keys and certificates
    (r'\.pem$', 'Certificate/key file'),
    (r'\.key$', 'Private key file'),
    (r'\.p12$', 'PKCS12 certificate'),
    (r'id_rsa', 'SSH private key'),
    (r'id_ed25519', 'SSH private key'),

    # Lock files (prevent accidental modification)
    (r'package-lock\.json$', 'npm lock file — use npm install to modify'),
    (r'yarn\.lock$', 'Yarn lock file — use yarn to modify'),
    (r'pnpm-lock\.yaml$', 'pnpm lock file — use pnpm to modify'),

    # CI/CD configs (require careful review)
    (r'\.github/workflows/', 'GitHub Actions workflow — modify with caution'),

    # Docker production configs
    (r'docker-compose\.prod', 'Production Docker config'),
]

# Customise: Directories where edits are always allowed
SAFE_DIRECTORIES = [
    r'^\.claude/',
    r'^docs/',
    r'^tests?/',
    r'^__tests__/',
    r'^examples?/',
]


def is_safe_directory(file_path):
    """Check if file is in a safe directory."""
    for pattern in SAFE_DIRECTORIES:
        if re.search(pattern, file_path):
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
    file_path = tool_input.get('file_path', '')

    if not file_path:
        sys.exit(0)

    if is_safe_directory(file_path):
        sys.exit(0)

    for pattern, reason in PROTECTED_PATTERNS:
        if re.search(pattern, file_path, re.IGNORECASE):
            output = {
                'decision': 'block',
                'reason': f"Protected file: {reason}. Path: {file_path}",
            }
            print(json.dumps(output))
            sys.exit(2)

    sys.exit(0)


if __name__ == '__main__':
    main()
