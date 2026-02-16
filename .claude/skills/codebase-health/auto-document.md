---
description: Batch-generate JSDoc comments, README sections, and API documentation for undocumented code
model: sonnet
---

# /auto-document

Batch-generate documentation for undocumented code using parallel Haiku agents, with type-specific templates for functions, components, APIs, and modules.

## When to Use This Skill

- Documenting a legacy or inherited codebase
- Preparing for a documentation audit
- Adding JSDoc to files before a release
- Generating README sections for modules

## Usage

```
/auto-document [--type jsdoc|readme|api|all] [--path <directory>] [--dry-run]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| type | What documentation to generate | No | jsdoc |
| path | Directory to process | No | src/ |
| dry-run | Preview changes without writing | No | false |

## Instructions

### Phase 1: Identify Undocumented Code

1. Scan source files for functions, classes, and exports
2. Check which items lack JSDoc comments
3. For README: identify modules without README.md
4. For API: find route handlers without documentation
5. Group files into batches of 10-15

### Phase 2: Parallel Documentation (Batch Agents)

Spawn N Haiku agents (one per batch) using the Task tool:

**Documentation Agent** (Haiku, one per batch)
Task: Generate documentation for assigned files
For each undocumented item:

**JSDoc generation**:
- Read the function/component code
- Infer parameter types from usage
- Identify return type from return statements
- Write JSDoc with `@param`, `@returns`, `@throws`
- Follow project conventions (see backend.md, frontend.md rules)

**README generation**:
- Identify module purpose from file names and exports
- List key exports and their roles
- Add usage examples based on how the module is imported
- Include dependency notes

**API documentation**:
- Extract route method, path, and middleware chain
- Infer request body schema from validation (Zod schemas)
- Document response format from controller code
- List error responses from error handling

Return: Documentation patches ready to apply

### Phase 3: Apply or Preview

If `--dry-run`: Show documentation that would be added
Otherwise: Apply JSDoc comments, create README files, update API docs

## Output Format

```markdown
# Auto-Documentation Report

**Scanned**: [X] files | **Documented**: [Y] items | **Skipped**: [Z] (already documented)

## Changes Applied

### JSDoc Added
| File | Functions Documented | Status |
|------|---------------------|--------|
| src/services/user.service.js | 4 | Applied |
| src/utils/format.js | 3 | Applied |

### READMEs Created
| Directory | Status |
|-----------|--------|
| src/services/ | Created |
| src/middleware/ | Created |

### Preview (dry-run)
[Show diff-like preview of documentation to be added]
```

## Examples

### Example 1: Add JSDoc to Services
```
/auto-document --type jsdoc --path src/services
```

### Example 2: Preview All Documentation
```
/auto-document --type all --dry-run
```
