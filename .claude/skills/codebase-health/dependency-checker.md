---
description: Validate npm dependencies for vulnerabilities, outdated packages, and unused packages
model: sonnet
---

# /dependency-checker

Comprehensive dependency health check using parallel agents to scan for vulnerabilities, outdated packages, unused dependencies, and license compliance.

## When to Use This Skill

- Pre-release dependency audit
- Regular security hygiene checks
- After inheriting a project
- Before upgrading major framework versions

## Usage

```
/dependency-checker [--scope security|freshness|unused|licenses|all]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | What aspects to check | No | all |

## Instructions

### Phase 1: Gather Dependency Data

1. Read package.json for declared dependencies
2. Check for lock file (package-lock.json, yarn.lock, pnpm-lock.yaml)
3. Scan source files for actually-used imports

### Phase 2: Parallel Analysis (Batch Agents)

Spawn N Haiku agents to check dependencies in parallel batches:

**Security Scanner** (Haiku)
Task: Check for known vulnerabilities
- Run `npm audit --json` and parse results
- Categorise by severity (critical, high, moderate, low)
- For each vulnerability: affected package, severity, fix available, advisory URL
Return: Vulnerability table with fix commands

**Freshness Checker** (Haiku)
Task: Check for outdated packages
- Run `npm outdated --json` and parse results
- Categorise: current, wanted (minor/patch), latest (major)
- Flag packages more than 2 major versions behind
- Identify packages with breaking changes in newer versions
Return: Outdated package table with update risk assessment

**Usage Scanner** (Sonnet)
Task: Find unused dependencies
- Scan all source files for import/require statements
- Cross-reference with package.json dependencies
- Identify packages in package.json but never imported
- Check devDependencies usage in test/build files
- Flag packages only used in commented-out code
Return: Unused package list with removal commands

**License Checker** (Haiku)
Task: Check license compliance
- Extract license field from each dependency's package.json
- Flag copyleft licenses (GPL, AGPL) in production dependencies
- Flag packages with no declared license
- Check for license compatibility with project's MIT license
Return: License summary table

### Phase 3: Synthesise

1. Merge all findings
2. Generate overall dependency health score
3. Prioritise actions: security fixes first, then unused removal, then updates

## Output Format

```markdown
# Dependency Health Report

**Total deps**: [X] production + [Y] dev | **Health**: [X/100]

## Summary

| Check | Status | Issues |
|-------|--------|--------|
| Security | Red | 2 critical, 3 high |
| Freshness | Amber | 8 outdated |
| Unused | Green | 1 unused |
| Licenses | Green | All compatible |

## Critical: Security Vulnerabilities

| Package | Severity | Fix | Command |
|---------|----------|-----|---------|
| lodash | Critical | 4.17.21 | `npm update lodash` |

## Outdated Packages

| Package | Current | Latest | Risk | Breaking Changes |
|---------|---------|--------|------|-----------------|
| react | 18.2.0 | 19.0.0 | High | Concurrent mode changes |

## Unused Dependencies
```bash
npm uninstall unused-package-1 unused-package-2
```

## Action Plan
1. [ ] Fix critical security vulnerabilities (immediate)
2. [ ] Remove unused dependencies (this sprint)
3. [ ] Plan major version upgrades (next sprint)
```

## Examples

### Example 1: Full Audit
```
/dependency-checker
```

### Example 2: Security Only
```
/dependency-checker --scope security
```
