#!/usr/bin/env python3
"""
Secret File Scanner Hook for Claude Code

Scans file content being written or edited for embedded secrets
before the changes are applied.

Hook Type: PreToolUse (Edit|Write)
Exit Codes:
  0 - No secrets found, allow
  2 - Secret found in file content, block
"""

import json
import re
import sys


# Reuse the same patterns as secret-detection
SECRET_PATTERNS = [
    (r'AKIA[0-9A-Z]{16}', 'AWS Access Key ID'),
    (r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', 'JWT Token'),
    (r'postgres(?:ql)?://[^\s"\']+:[^\s"\']+@[^\s"\']+', 'Database Connection String'),
    (r'mongodb(?:\+srv)?://[^\s"\']+:[^\s"\']+@[^\s"\']+', 'Database Connection String'),
    (r'-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----', 'Private Key'),
    (r'sk[_\-]live[_\-][A-Za-z0-9]{20,}', 'Stripe Secret Key'),
    (r'ghp_[A-Za-z0-9]{36,}', 'GitHub Token'),
    (r'github_pat_[A-Za-z0-9_]{20,}', 'GitHub Fine-Grained PAT'),
    (r'xox[bporas]-[A-Za-z0-9\-]{10,}', 'Slack Token'),
    (r'SG\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}', 'SendGrid API Key'),
    (r'npm_[A-Za-z0-9]{36,}', 'npm Token'),
    (r'AIza[A-Za-z0-9_\-]{35}', 'Google API Key'),
]

# Files where secrets are expected (e.g., test fixtures, documentation)
EXEMPT_PATHS = [
    r'\.test\.',
    r'\.spec\.',
    r'__tests__/',
    r'__mocks__/',
    r'\.md$',
    r'\.example$',
]


def is_exempt(file_path):
    """Check if file is exempt from secret scanning."""
    if not file_path:
        return False
    for pattern in EXEMPT_PATHS:
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
    content = tool_input.get('content', '') or tool_input.get('new_string', '')

    if not content:
        sys.exit(0)

    if is_exempt(file_path):
        sys.exit(0)

    findings = []
    for pattern, name in SECRET_PATTERNS:
        if re.search(pattern, content, re.IGNORECASE):
            findings.append(name)

    if findings:
        types = list(set(findings))
        output = {
            'decision': 'block',
            'reason': f"Potential secrets detected in file content: {', '.join(types)}. "
                      f"Use environment variables (process.env.X) instead of hardcoding secrets.",
        }
        print(json.dumps(output))
        sys.exit(2)

    sys.exit(0)


if __name__ == '__main__':
    main()
