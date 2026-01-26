# Claude Code Configuration for SDLC Projects

A comprehensive `.claude` configuration for full-stack web development teams. Covers the entire Software Development Life Cycle with specialized rules for developers, QA engineers, technical writers, DevOps engineers, and architects.

## Features

- **11 Specialized Rule Files** covering frontend, backend, DevOps, architecture, testing, and more
- **11 Configured Agents** for task delegation and specialized workflows
- **Complete SDLC Coverage** for all team roles
- **Production-Ready Patterns** with real-world code examples
- **Quality Gates** with automated and manual verification checklists

## Tech Stack

| Category | Technologies |
|----------|--------------|
| Frontend | React 18+, Material-UI v5+ |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Testing | Jest/Vitest, Playwright, React Testing Library |
| CI/CD | GitHub Actions |
| Containers | Docker, Docker Compose |
| Validation | Zod |

## Structure

```
.claude/
├── CLAUDE.md                 # Main configuration with SDLC role coverage
├── settings.json             # Hooks, permissions, 11 specialized agents
└── rules/
    ├── api-design.md         # REST conventions, OpenAPI specs
    ├── architecture.md       # ADRs, system design, Mermaid diagrams
    ├── backend.md            # Node.js/Express patterns
    ├── code-review.md        # PR templates, review checklists
    ├── database.md           # PostgreSQL schema, migrations, queries
    ├── devops.md             # GitHub Actions, Docker, deployment
    ├── documentation.md      # Technical writing, runbooks
    ├── frontend.md           # React/MUI patterns
    ├── quality-gates.md      # QA processes, release criteria
    ├── security.md           # OWASP, authentication, validation
    └── testing.md            # Unit, integration, E2E (Playwright)
```

## Quick Start

### Option 1: Clone and Copy

```bash
git clone https://github.com/servika/claude-configuration.git
cp -r claude-configuration/.claude your-project/
```

### Option 2: Use degit

```bash
npx degit servika/claude-configuration/.claude .claude
```

### Option 3: Download ZIP

Download the repository and copy the `.claude` folder to your project root.

## SDLC Role Coverage

| Role | Primary Rules | Focus Areas |
|------|---------------|-------------|
| **Developer** | frontend, backend, api-design, database | Feature implementation, code quality |
| **QA Engineer** | testing, quality-gates | Test automation, E2E, release criteria |
| **Technical Writer** | documentation, architecture | Docs, runbooks, ADRs |
| **DevOps Engineer** | devops, security | CI/CD, Docker, deployment |
| **Architect** | architecture, api-design, database | System design, technical decisions |

## Configured Agents

| Agent | Description | Key Rules |
|-------|-------------|-----------|
| `frontend` | React + MUI development | frontend, testing, security |
| `backend` | Node.js + Express APIs | backend, api-design, database, security |
| `devops` | CI/CD and deployment | devops, security |
| `architect` | System design and ADRs | architecture, api-design, database |
| `qa` | E2E testing and quality | testing, quality-gates |
| `api-designer` | REST API design | api-design, documentation |
| `documentation` | Technical writing | documentation, architecture |
| `testing` | All test types | testing, quality-gates |
| `code-review` | PR quality assessment | code-review, security |
| `security` | Security review | security, backend |
| `database` | Schema and queries | database, backend |

## What's Included

### Development Rules

- **frontend.md** - React component patterns, MUI styling with `sx` prop, hooks best practices, form handling, accessibility
- **backend.md** - Express architecture (routes → controllers → services), error handling, validation middleware, authentication
- **api-design.md** - REST conventions, HTTP methods/status codes, pagination, versioning, OpenAPI specs
- **database.md** - PostgreSQL schema design, naming conventions, migrations, query optimization, connection pooling

### Quality Rules

- **testing.md** - Unit testing with Jest, integration testing with Supertest, E2E with Playwright, Page Object Model, coverage thresholds
- **quality-gates.md** - PR checks, CI pipeline gates, staging QA, release criteria, performance thresholds, accessibility standards
- **code-review.md** - PR templates, review checklists, comment etiquette, approval criteria, anti-patterns to flag
- **security.md** - OWASP Top 10 prevention, input validation, JWT security, rate limiting, XSS prevention

### Operations Rules

- **devops.md** - GitHub Actions workflows, Docker configuration, deployment strategies, health checks, monitoring
- **architecture.md** - ADR templates, system design documentation, Mermaid diagrams, technical debt tracking
- **documentation.md** - README structure, API docs, runbooks, incident response templates, changelog format

## Code Quality Standards

### Automated Verification

- ESLint must pass
- Build must succeed
- Test coverage ≥60% overall, ≥20% per file
- Security audit (npm audit) clean

### Code Requirements

- JSDoc comments on all functions
- Parameterized database queries (no SQL injection)
- Input validation with Zod
- No `console.log` in production code

## Customization

### Modify Tech Stack

Edit `.claude/CLAUDE.md` to change:
- Framework versions
- Preferred libraries
- Coverage thresholds

### Add Custom Rules

Create new files in `.claude/rules/`:

```markdown
# My Custom Rule

## When to Apply
Description of when this rule applies.

## Guidelines
- Guideline 1
- Guideline 2

## Checklist
- [ ] Check 1
- [ ] Check 2
```

Then reference it in `settings.json` under the appropriate agent.

### Adjust Permissions

Edit `.claude/settings.json` to add or remove allowed/denied commands:

```json
{
  "permissions": {
    "allow": ["Bash(your-command)"],
    "deny": ["Bash(dangerous-command)"]
  }
}
```

## Requirements

- [Claude Code](https://claude.ai/code) or compatible tool
- Node.js 18+ (for the configured tech stack)
- PostgreSQL 14+ (if using database rules)
- Docker (if using DevOps rules)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Guidelines

- Follow the existing rule file format
- Include practical code examples
- Add checklists where appropriate
- Test with Claude Code before submitting

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built for teams using Claude Code who want consistent, high-quality development practices across the entire SDLC.
