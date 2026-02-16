---
description: Detect unused files, unreachable components, dead routes, and unused exports
model: sonnet
---

# /dead-code-finder

Find dead code across the project using four parallel scanners for components, routes, utilities, and configuration, then suggest connections or safe removals.

## When to Use This Skill

- Periodic codebase cleanup
- Before major version releases
- When the project feels bloated
- During technical debt reduction sprints

## Usage

```
/dead-code-finder [--scope files|exports|routes|all] [--path <directory>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | What to scan for dead code | No | all |
| path | Directory to scan | No | src/ |

## Instructions

### Phase 1: Build Dependency Graph

1. Map all files in the source directory
2. Build an import graph (which files import which)
3. Identify entry points (main app, route definitions, test files)
4. Mark files reachable from entry points

### Phase 2: Parallel Scanning (Agent Team)

Launch 4 agents using the Task tool:

**Agent 1: Component Scanner** (Haiku)
Task: Find unreachable React components
- List all component files (`.jsx`, `.tsx`)
- Check if each component is imported/used somewhere
- Trace from route definitions → page components → child components
- Flag components not in the render tree
Return: List of orphaned components with last-modified date

**Agent 2: Route Scanner** (Haiku)
Task: Find dead routes and handlers
- Parse route definitions (Express routes, React Router)
- Verify each route handler/component exists
- Check for routes that are defined but unreachable (no navigation to them)
- Identify commented-out routes
Return: List of dead routes with context

**Agent 3: Utility Scanner** (Sonnet)
Task: Find unused utilities and helpers
- Scan `utils/`, `helpers/`, `lib/` directories
- Check export usage across the codebase
- Identify utility functions with zero callers
- Find duplicated utility logic
Return: List of unused utilities with size impact

**Agent 4: Connection Suggester** (Sonnet)
Task: Determine if orphaned code should be connected or removed
- For each orphaned item, check git history (recently modified = likely WIP)
- Check if there are TODO comments referencing it
- Assess if it could be useful (e.g., utility that solves a common need)
- Recommend: **Remove** (truly dead) or **Connect** (should be wired up)
Return: Recommendations per orphaned item

### Phase 3: Synthesise

1. Merge scanner results
2. Calculate dead code metrics (files, lines, percentage)
3. Estimate cleanup impact (bundle size reduction, maintenance reduction)
4. Prioritise removal candidates

## Output Format

```markdown
# Dead Code Report

**Scanned**: [X] files | **Dead code**: [X] files ([Y]%)

## Impact Summary
- **Files to remove**: [X] ([Y] lines of code)
- **Estimated bundle reduction**: ~[X]KB
- **Dead exports**: [X]

## Removal Candidates (Safe to Delete)

| File | Type | Last Modified | Lines | Reason |
|------|------|---------------|-------|--------|
| src/components/OldHeader.jsx | Component | 6 months ago | 120 | Not imported anywhere |

## Connection Candidates (Wire Up or Remove)

| File | Type | Suggestion | Reason |
|------|------|------------|--------|
| src/utils/retry.js | Utility | Connect | Useful for API error handling |

## Cleanup Commands
```bash
# Remove confirmed dead files
rm src/components/OldHeader.jsx
rm src/utils/deprecated-format.js
```
```

## Examples

### Example 1: Full Scan
```
/dead-code-finder
```

### Example 2: Components Only
```
/dead-code-finder --scope files --path src/components
```
