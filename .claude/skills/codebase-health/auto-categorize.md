---
description: Auto-categorise source files by architectural layer and purpose
model: haiku
---

# /auto-categorize

Batch-categorise source files by their architectural role (component, service, utility, test, config, etc.) using parallel Haiku agents with pattern-based and content-based classification.

## When to Use This Skill

- Understanding an unfamiliar codebase structure
- Auditing adherence to architectural patterns
- Preparing for codebase reorganisation
- Generating architecture documentation

## Usage

```
/auto-categorize [--path <directory>] [--output table|tree|json]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| path | Directory to categorise | No | src/ |
| output | Output format | No | table |

## Instructions

### Phase 1: Define Categories

Standard categories for the project's architecture:

| Category | Indicators | Examples |
|----------|-----------|----------|
| **Page** | Route-level component, in `pages/` | Dashboard.jsx, Login.jsx |
| **Component** | Reusable UI, in `components/` | Button.jsx, UserCard.jsx |
| **Feature** | Feature-specific, in `features/` | UserList.jsx, OrderForm.jsx |
| **Layout** | Page layouts, in `layouts/` | MainLayout.jsx, AuthLayout.jsx |
| **Hook** | Custom hook, `use` prefix | useAuth.js, useDebounce.js |
| **Context** | React context, in `context/` | AuthContext.jsx, ThemeContext.jsx |
| **Route** | Express routes, in `routes/` | users.routes.js, auth.routes.js |
| **Controller** | Request handlers, in `controllers/` | users.controller.js |
| **Service** | Business logic, in `services/` | user.service.js, email.service.js |
| **Middleware** | Express middleware, in `middleware/` | auth.middleware.js |
| **Validator** | Zod schemas, in `validators/` | user.validator.js |
| **Model** | Data models, in `models/` | user.model.js |
| **Utility** | Helper functions, in `utils/` | format.js, errors.js |
| **Config** | Configuration files | index.js in `config/` |
| **Test** | Test files, `.test.` or `.spec.` | user.service.test.js |
| **Migration** | Database migrations | 001_create_users.sql |

### Phase 2: Parallel Classification (Batch Agents)

Group files into batches of 15-20. Spawn Haiku agents:

**Categoriser Agent** (Haiku, one per batch)
Task: Classify each file in the batch
- Check file path against category patterns (directory name, file naming convention)
- If ambiguous, read file content to determine purpose
- Assign primary category and optional secondary category
- Flag files that don't fit standard categories (potential misplacement)
Return: Classification list: `{ file, category, secondary?, confidence, notes }`

### Phase 3: Compile Results

1. Aggregate classifications
2. Build category distribution (count per category)
3. Flag misplaced files (e.g., a service in `components/`)
4. Generate output in requested format

## Output Format

```markdown
# Codebase Categorisation

**Files scanned**: [X] | **Categories**: [Y]

## Distribution

| Category | Count | % | Example |
|----------|-------|---|---------|
| Component | 25 | 20% | UserCard.jsx |
| Service | 15 | 12% | user.service.js |
| Test | 30 | 24% | user.service.test.js |
| ... | | | |

## Architecture Tree
```
src/
├── components/ (25 files) — UI components
├── services/ (15 files) — Business logic
├── routes/ (8 files) — API endpoints
├── middleware/ (5 files) — Express middleware
└── utils/ (12 files) — Helpers
```

## Misplaced Files
| File | Current Category | Suggested Category | Reason |
|------|-----------------|-------------------|--------|
| src/components/fetchUser.js | Component | Service | Contains API logic, not UI |
```

## Examples

### Example 1: Full Categorisation
```
/auto-categorize --output tree
```

### Example 2: Specific Directory
```
/auto-categorize --path src/features --output table
```
