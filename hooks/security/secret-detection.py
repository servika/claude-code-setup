#!/usr/bin/env python3
"""
Secret Detection Hook for Claude Code

Scans user prompts for potential secrets (API keys, tokens, passwords,
connection strings) and blocks them before Claude processes them.

Hook Type: UserPromptSubmit
Exit Codes:
  0 - No secrets detected, allow
  2 - Secret detected, block prompt
"""

import json
import re
import sys


# Customise: Add or remove patterns for your project
SECRET_PATTERNS = [
    # AWS
    (r'AKIA[0-9A-Z]{16}', 'AWS Access Key ID'),
    (r'aws[_\-]?secret[_\-]?access[_\-]?key\s*[:=]\s*\S+', 'AWS Secret Key'),

    # Generic API keys
    (r'api[_\-]?key\s*[:=]\s*["\']?[A-Za-z0-9_\-]{20,}', 'API Key'),
    (r'api[_\-]?secret\s*[:=]\s*["\']?[A-Za-z0-9_\-]{20,}', 'API Secret'),

    # JWT / Bearer tokens
    (r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', 'JWT Token'),
    (r'bearer\s+[A-Za-z0-9_\-\.]{20,}', 'Bearer Token'),

    # Database connection strings
    (r'postgres(?:ql)?://[^\s]+:[^\s]+@[^\s]+', 'PostgreSQL Connection String'),
    (r'mongodb(?:\+srv)?://[^\s]+:[^\s]+@[^\s]+', 'MongoDB Connection String'),
    (r'mysql://[^\s]+:[^\s]+@[^\s]+', 'MySQL Connection String'),
    (r'redis://[^\s]*:[^\s]+@[^\s]+', 'Redis Connection String'),

    # Private keys
    (r'-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----', 'Private Key'),
    (r'-----BEGIN OPENSSH PRIVATE KEY-----', 'SSH Private Key'),

    # Common service tokens
    (r'sk[_\-]live[_\-][A-Za-z0-9]{20,}', 'Stripe Secret Key'),
    (r'sk[_\-]test[_\-][A-Za-z0-9]{20,}', 'Stripe Test Key'),
    (r'ghp_[A-Za-z0-9]{36,}', 'GitHub Personal Access Token'),
    (r'gho_[A-Za-z0-9]{36,}', 'GitHub OAuth Token'),
    (r'github_pat_[A-Za-z0-9_]{20,}', 'GitHub Fine-Grained PAT'),
    (r'xox[bporas]-[A-Za-z0-9\-]{10,}', 'Slack Token'),
    (r'SG\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}', 'SendGrid API Key'),
    (r'sq0[a-z]{3}-[A-Za-z0-9_\-]{20,}', 'Square Token'),

    # Generic secrets in assignments
    (r'password\s*[:=]\s*["\'][^"\']{8,}["\']', 'Hardcoded Password'),
    (r'secret\s*[:=]\s*["\'][^"\']{8,}["\']', 'Hardcoded Secret'),
    (r'token\s*[:=]\s*["\'][^"\']{16,}["\']', 'Hardcoded Token'),

    # npm tokens
    (r'npm_[A-Za-z0-9]{36,}', 'npm Token'),

    # Google
    (r'AIza[A-Za-z0-9_\-]{35}', 'Google API Key'),
]

# Customise: Known safe patterns to exclude (e.g., example values in docs)
SAFE_PATTERNS = [
    r'sk_test_example',
    r'password123',
    r'your-api-key-here',
    r'REPLACE_ME',
    r'<your[_\-]',
    r'example\.com',
]


def is_safe(match_text):
    """Check if a match is a known safe/example value."""
    for safe in SAFE_PATTERNS:
        if re.search(safe, match_text, re.IGNORECASE):
            return True
    return False


def scan_for_secrets(text):
    """Scan text for potential secrets."""
    findings = []
    for pattern, name in SECRET_PATTERNS:
        matches = re.finditer(pattern, text, re.IGNORECASE)
        for match in matches:
            if not is_safe(match.group()):
                findings.append({
                    'type': name,
                    'position': match.start(),
                    'preview': match.group()[:20] + '...' if len(match.group()) > 20 else match.group(),
                })
    return findings


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            sys.exit(0)
        input_data = json.loads(raw_input)
    except (json.JSONDecodeError, Exception):
        sys.exit(0)

    prompt = input_data.get('userPrompt', '') or input_data.get('prompt', '')
    if not prompt:
        sys.exit(0)

    findings = scan_for_secrets(prompt)

    if findings:
        types = list(set(f['type'] for f in findings))
        output = {
            'decision': 'block',
            'reason': f"Potential secrets detected in prompt: {', '.join(types)}. "
                      f"Remove secrets before submitting. Use environment variables instead.",
        }
        print(json.dumps(output))
        sys.exit(2)

    sys.exit(0)


if __name__ == '__main__':
    main()
