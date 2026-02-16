---
description: Generate comprehensive code quality metrics across five analysis dimensions
model: sonnet
---

# /code-quality-report

Analyse codebase quality using five parallel agents examining complexity, test coverage, lint health, dependency freshness, and bundle/build metrics.

## When to Use This Skill

- Sprint retrospectives to track quality trends
- Pre-release quality assessment
- Identifying technical debt hotspots
- Onboarding — understanding codebase health

## Usage

```
/code-quality-report [--scope full|directory] [--path <directory>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | Analysis scope | No | full |
| path | Specific directory to analyse | No | Project root |

## Instructions

### Phase 1: Prepare Context

1. Identify project root and tech stack from package.json
2. Locate test configuration (jest.config, playwright.config)
3. Find lint configuration (.eslintrc, .prettierrc)
4. Check for existing quality reports or metrics

### Phase 2: Parallel Analysis (Agent Team)

Launch 5 agents using the Task tool:

**Agent 1: Complexity Analysis** (Haiku)
Task: Measure code complexity
- Count files by type (components, services, utils, tests, config)
- Identify largest files (lines of code) — flag files >300 lines
- Find deeply nested code (>3 levels of indentation)
- Detect functions with many parameters (>4)
- Identify files with many imports (>10) — potential coupling
Return: Complexity metrics table with hotspot list

**Agent 2: Test Coverage Analysis** (Haiku)
Task: Assess test health
- Run `npm test -- --coverage --coverageReporters=json-summary` if possible
- Identify files with zero test coverage
- Find test files that don't match source files (orphan tests)
- Check test-to-code ratio
- Assess test quality: look for assertion-free tests, skipped tests
Return: Coverage metrics with gap list (files missing tests)

**Agent 3: Lint & Style Analysis** (Haiku)
Task: Assess code consistency
- Run `npm run lint -- --format json` if possible
- Categorise lint issues by severity (error, warning)
- Identify most common lint violations
- Check for consistent formatting (Prettier compliance)
- Find files excluded from linting
Return: Lint health score with top issues

**Agent 4: Dependency Analysis** (Sonnet)
Task: Assess dependency health
- Run `npm audit --json` for vulnerability scan
- Run `npm outdated --json` for freshness check
- Identify unused dependencies (scan imports vs package.json)
- Check for duplicate packages in dependency tree
- Flag dependencies with known issues or deprecations
Return: Dependency health table with action items

**Agent 5: Build & Bundle Analysis** (Haiku)
Task: Assess build health
- Run `npm run build` and capture output
- Check build time and success
- Identify large build artifacts
- Look for build warnings
- Check for environment-specific issues
Return: Build metrics with warnings

### Phase 3: Synthesise

1. Collect all agent results
2. Calculate overall health score (0-100)
3. Generate RAG dashboard (Red/Amber/Green per dimension)
4. Prioritise top 10 improvement actions

## Output Format

```markdown
# Code Quality Report

**Project**: [Name] | **Date**: [Date] | **Score**: [X/100]

## Health Dashboard

| Dimension | Score | Status | Trend |
|-----------|-------|--------|-------|
| Complexity | X/100 | Green | — |
| Test Coverage | X/100 | Amber | — |
| Lint Health | X/100 | Green | — |
| Dependencies | X/100 | Red | — |
| Build Health | X/100 | Green | — |

## Key Findings

### Critical
- [Issues that need immediate attention]

### Warnings
- [Issues to address soon]

## Detailed Metrics
[Per-dimension details from each agent]

## Top 10 Actions
1. [ ] [Action with priority and effort estimate]
```

## Examples

### Example 1: Full Project Report
```
/code-quality-report
```

### Example 2: Specific Directory
```
/code-quality-report --scope directory --path src/services
```
