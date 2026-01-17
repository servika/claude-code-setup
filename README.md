# Claude Code Configuration

A comprehensive `.claude` configuration for full-stack web development with Node.js, Express, React, and Material-UI.

## What's Included

```
.claude/
├── CLAUDE.md              # Main configuration
├── settings.json          # Hooks, permissions, agents
└── rules/
    ├── frontend.md        # React + MUI patterns
    ├── backend.md         # Node.js + Express
    ├── documentation.md   # Technical writing standards
    ├── testing.md         # Unit/integration testing
    └── security.md        # Security best practices
```

## Quick Start

### Option 1: Clone directly

```bash
git clone https://github.com/servika/claude-code-setup.git my-project
cd my-project
rm -rf .git
git init
```

### Option 2: Copy `.claude` folder

Copy the `.claude` directory into your existing project root.

### Option 3: Use degit

```bash
npx degit servika/claude-code-setup/.claude .claude
```

## Features

### Specialized Agents

| Agent | Purpose |
|-------|---------|
| `frontend` | React components, MUI styling, hooks |
| `backend` | Express routes, middleware, APIs |
| `documentation` | Architecture docs, API specs, READMEs |
| `testing` | Unit tests, integration tests |
| `security` | Security review, vulnerability checks |

### Code Quality Standards

- JSDoc comments required on all functions
- Test coverage: 60% overall, 20% per file minimum
- ESLint must pass before completion
- No `console.log` in production code

### Tech Stack

- **Frontend**: React 18+, Material-UI v5+
- **Backend**: Node.js, Express.js
- **Testing**: Jest/Vitest, React Testing Library, Supertest
- **Validation**: Zod

## Configuration Files

### CLAUDE.md

Main configuration defining:
- Tech stack assumptions
- Agent definitions
- Intent recognition rules
- Pre-completion checklist

### settings.json

```json
{
  "hooks": { ... },
  "permissions": { ... },
  "agents": { ... }
}
```

### Rules

| File | Contents |
|------|----------|
| `frontend.md` | Component patterns, MUI sx prop, hooks, forms, accessibility |
| `backend.md` | Express architecture, error handling, validation, auth |
| `documentation.md` | ADRs, OpenAPI specs, mermaid diagrams |
| `testing.md` | Given-When-Then structure, mocking patterns |
| `security.md` | OWASP prevention, JWT, rate limiting, XSS |

## Customization

### Modify Tech Stack

Edit `.claude/CLAUDE.md` to change:
- Framework versions
- Preferred libraries
- Code style preferences

### Add Custom Rules

Create new files in `.claude/rules/`:

```markdown
# My Custom Rule

## When to Apply
Description of when this rule applies.

## Guidelines
- Guideline 1
- Guideline 2
```

### Adjust Coverage Thresholds

Edit thresholds in `.claude/rules/testing.md`:

```javascript
coverageThreshold: {
  global: { lines: 60 },  // Adjust as needed
}
```

## Requirements

- Claude Code CLI
- Node.js 18+

## License

MIT