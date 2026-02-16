---
description: Find broken imports, missing files, dead exports, and stale references across the codebase
model: sonnet
---

# /broken-references

Scan the codebase for broken references using three parallel agents examining imports, exports, and configuration references.

## When to Use This Skill

- After large refactoring sessions
- Before releases to catch broken references
- After file renames or directory restructuring
- When encountering mysterious import errors

## Usage

```
/broken-references [--scope imports|exports|config|all] [--path <directory>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | What type of references to check | No | all |
| path | Directory to scan | No | src/ |

## Instructions

### Phase 1: Map the Codebase

1. Glob all source files (`.js`, `.jsx`, `.ts`, `.tsx`)
2. Build a file path index for quick lookup
3. Identify entry points (routes, pages, index files)

### Phase 2: Parallel Scanning (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Import Scanner** (Sonnet)
Task: Find broken import/require statements
- Scan all import/require statements in source files
- Verify each relative import resolves to an existing file
- Check that named imports match actual exports
- Verify package imports exist in node_modules (check package.json)
- Flag dynamic imports that reference non-existent paths
Return: List of broken imports with file:line references

**Agent 2: Export Scanner** (Haiku)
Task: Find dead exports
- Catalogue all named exports across the codebase
- Cross-reference with import statements
- Identify exports that are never imported anywhere
- Check for re-exports that point to missing modules
- Flag index.js barrel files with stale re-exports
Return: List of unused exports with file:line references

**Agent 3: Configuration Scanner** (Haiku)
Task: Find broken config references
- Check route definitions reference existing components/handlers
- Verify test configuration paths exist
- Check CI/CD workflow file references
- Validate Docker and docker-compose file paths
- Check package.json script references
Return: List of broken config references

### Phase 3: Synthesise

1. Merge all findings, deduplicate
2. Categorise by severity:
   - **Error**: Will cause runtime failure
   - **Warning**: Dead code, potential confusion
   - **Info**: Cleanup opportunity
3. Generate fix suggestions for each issue

## Output Format

```markdown
# Broken References Report

**Scanned**: [X] files | **Issues found**: [X]

## Summary

| Type | Errors | Warnings | Info |
|------|--------|----------|------|
| Broken imports | X | — | — |
| Dead exports | — | X | — |
| Config references | X | X | — |

## Errors (Must Fix)

| File | Line | Issue | Suggested Fix |
|------|------|-------|---------------|
| src/pages/Users.jsx | 3 | Import `./UserCard` not found | Renamed to `./components/UserCard` |

## Warnings (Should Fix)

| File | Line | Issue |
|------|------|-------|
| src/utils/format.js | 15 | `formatPhone` exported but never imported |

## Auto-Fix Script
[If applicable, suggest sed/rename commands to fix common issues]
```

## Examples

### Example 1: Full Scan
```
/broken-references
```

### Example 2: Imports Only After Refactor
```
/broken-references --scope imports --path src/features/auth
```
