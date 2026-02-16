# Claude Code Configuration for SDLC Projects

A comprehensive `.claude` configuration for full-stack web development teams. Covers the entire Software Development Life Cycle with specialized rules, skills (slash commands), agents, and automated hooks.

## Features

- **12 Specialized Rule Files** covering frontend, backend, DevOps, architecture, testing, and more
- **37 Skills (Slash Commands)** across 8 categories with agent-team patterns
- **11 Configured Agents** for task delegation and specialized workflows
- **10 Production-Ready Hooks** for security, quality, and UX automation
- **Complete SDLC Coverage** for all team roles
- **Quality Gates** with automated and manual verification checklists

## Tech Stack

| Category   | Technologies                                   |
| ---------- | ---------------------------------------------- |
| Frontend   | React 18+, Material-UI v5+                     |
| Backend    | Node.js, Express.js                            |
| Database   | PostgreSQL                                     |
| Testing    | Jest/Vitest, Playwright, React Testing Library |
| CI/CD      | GitHub Actions                                 |
| Containers | Docker, Docker Compose                         |
| Validation | Zod                                            |

## Structure

```
.claude/
├── CLAUDE.md                          # Main configuration
├── settings.json                      # Hooks, permissions, agents
├── rules/
│   ├── api-design.md                  # REST conventions, OpenAPI
│   ├── architecture.md                # ADRs, system design, Mermaid
│   ├── backend.md                     # Node.js/Express patterns
│   ├── code-review.md                 # PR templates, review checklists
│   ├── database.md                    # PostgreSQL schema, migrations
│   ├── devops.md                      # GitHub Actions, Docker
│   ├── documentation.md               # Technical writing, runbooks
│   ├── frontend.md                    # React/MUI patterns
│   ├── no-ascii-diagrams.md           # Enforce Mermaid over ASCII
│   ├── quality-gates.md               # QA processes, release criteria
│   ├── security.md                    # OWASP, auth, validation
│   └── testing.md                     # Unit, integration, E2E
└── skills/
    ├── architecture/                  # 8 skills
    ├── diagramming/                   # 3 skills
    ├── content-processing/            # 8 skills
    ├── codebase-health/               # 6 skills
    ├── scoring/                       # 2 skills
    ├── reporting/                     # 2 skills
    ├── meetings/                      # 3 skills
    └── knowledge/                     # 5 skills
hooks/
├── security/
│   ├── secret-detection.py            # Block secrets in prompts
│   ├── secret-file-scanner.py         # Block secrets in file writes
│   └── file-protection.py            # Protect .env, lockfiles, keys
├── quality/
│   ├── code-formatter.py             # Auto-format after edits
│   ├── import-checker.py             # Validate import paths
│   └── naming-convention.py          # Enforce file naming
├── ux/
│   ├── context-loader.sh             # Auto-load skill context
│   └── search-hint.sh               # Suggest faster searches
├── safety/
│   └── bash-safety.py               # Auto-allow safe commands
└── notification/
    └── desktop-notify.sh             # Desktop notification on completion
docs/
└── agent-teams-guide.md              # Agent team patterns guide
```

## Quick Start

### Option 1: Clone and Copy

```bash
git clone https://github.com/servika/claude-configuration.git
cp -r claude-configuration/.claude your-project/
cp -r claude-configuration/hooks your-project/
```

### Option 2: Use degit

```bash
npx degit servika/claude-configuration your-project-config
cp -r your-project-config/.claude your-project/
cp -r your-project-config/hooks your-project/
```

### Hook Setup

After copying, make hook scripts executable:

```bash
chmod +x hooks/**/*.py hooks/**/*.sh
```

Hooks are configured in `.claude/settings.json` and run automatically during Claude Code sessions.

## SDLC Role Coverage

| Role                 | Primary Rules                           | Focus Areas                            |
| -------------------- | --------------------------------------- | -------------------------------------- |
| **Developer**        | frontend, backend, api-design, database | Feature implementation, code quality   |
| **QA Engineer**      | testing, quality-gates                  | Test automation, E2E, release criteria |
| **Technical Writer** | documentation, architecture             | Docs, runbooks, ADRs                   |
| **DevOps Engineer**  | devops, security                        | CI/CD, Docker, deployment              |
| **Architect**        | architecture, api-design, database      | System design, technical decisions     |

## Configured Agents

| Agent           | Description             | Key Rules                               |
| --------------- | ----------------------- | --------------------------------------- |
| `frontend`      | React + MUI development | frontend, testing, security             |
| `backend`       | Node.js + Express APIs  | backend, api-design, database, security |
| `devops`        | CI/CD and deployment    | devops, security                        |
| `architect`     | System design and ADRs  | architecture, api-design, database      |
| `qa`            | E2E testing and quality | testing, quality-gates                  |
| `api-designer`  | REST API design         | api-design, documentation               |
| `documentation` | Technical writing       | documentation, architecture             |
| `testing`       | All test types          | testing, quality-gates                  |
| `code-review`   | PR quality assessment   | code-review, security                   |
| `security`      | Security review         | security, backend                       |
| `database`      | Schema and queries      | database, backend                       |

## Skills (Slash Commands)

37 skills organized across 8 categories. Skills use agent-team patterns (fan-out/fan-in, batch, triage) for parallel analysis.

### Architecture

| Command                | Description                                                          |
| ---------------------- | -------------------------------------------------------------------- |
| `/adr`                 | Generate Architecture Decision Records                               |
| `/impact-analysis`     | 4-agent impact analysis (technical, organisational, financial, risk) |
| `/scenario-compare`    | Compare architectural scenarios with weighted scoring                |
| `/nfr-capture`         | Capture Non-Functional Requirements (ISO 25010)                      |
| `/nfr-review`          | Review NFRs for completeness, measurability, feasibility             |
| `/architecture-report` | 5-agent governance report with RAG health dashboard                  |
| `/cost-analysis`       | Infrastructure, licensing, and operational cost analysis             |
| `/dependency-graph`    | Generate Mermaid dependency graphs with criticality                  |

### Diagramming

| Command           | Description                                             |
| ----------------- | ------------------------------------------------------- |
| `/diagram`        | Generate Mermaid diagrams (C4, data flow, sequence, ER) |
| `/c4-diagram`     | C4-specific diagrams (Context, Container, Component)    |
| `/diagram-review` | 4-agent review for readability, completeness, accuracy  |

### Content Processing

| Command             | Description                                             |
| ------------------- | ------------------------------------------------------- |
| `/pdf-extract`      | Extract and structure content from PDFs                 |
| `/pptx-extract`     | Extract content from PowerPoint files                   |
| `/youtube-analyze`  | Analyse YouTube videos (technical/summary/action-items) |
| `/video-digest`     | Triage and deep-analyse video content                   |
| `/weblink`          | Quick web page capture with summary                     |
| `/article`          | Article capture with relevance scoring                  |
| `/research-notes`   | Structured notes from research materials                |
| `/document-extract` | Auto-detect and extract from any document format        |

### Codebase Health

| Command                | Description                                                            |
| ---------------------- | ---------------------------------------------------------------------- |
| `/code-quality-report` | 5-dimension quality analysis (complexity, coverage, lint, deps, build) |
| `/broken-references`   | Find broken imports, missing files, dead exports                       |
| `/dead-code-finder`    | Detect unused files, unreachable components, dead routes               |
| `/auto-document`       | Batch-generate JSDoc, README sections, API docs                        |
| `/auto-categorize`     | Classify files by architectural layer                                  |
| `/dependency-checker`  | Audit npm deps for security, freshness, usage, licenses                |

### Scoring

| Command           | Description                                           |
| ----------------- | ----------------------------------------------------- |
| `/score-document` | Score documents against rubrics with parallel agents  |
| `/exec-summary`   | Generate audience-tailored executive summaries (BLUF) |

### Reporting

| Command           | Description                                        |
| ----------------- | -------------------------------------------------- |
| `/sprint-summary` | Generate sprint summaries from git history and PRs |
| `/project-report` | Project status report with RAG indicators          |

### Meetings

| Command          | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `/meeting-notes` | Structure meeting notes with parallel extraction     |
| `/voice-meeting` | Process voice transcripts into structured notes      |
| `/email-capture` | Capture emails as structured notes with action items |

### Knowledge

| Command           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| `/summarize`      | Summarise content at configurable depth and audience |
| `/find-related`   | Discover related code via imports, deps, patterns    |
| `/find-decisions` | Catalogue decisions from ADRs, PRs, commits          |
| `/timeline`       | Generate timelines from git history and milestones   |
| `/skill-creator`  | Create new skills with agent-team patterns           |

## Hooks

Hooks run automatically during Claude Code sessions to enforce quality and security.

| Hook                     | Type             | Purpose                                           |
| ------------------------ | ---------------- | ------------------------------------------------- |
| `secret-detection.py`    | UserPromptSubmit | Block secrets (AWS, JWT, Stripe, etc.) in prompts |
| `secret-file-scanner.py` | PreToolUse       | Block secrets in file writes                      |
| `file-protection.py`     | PreToolUse       | Protect .env, lockfiles, keys from modification   |
| `code-formatter.py`      | PostToolUse      | Auto-format with Prettier/Black/gofmt after edits |
| `import-checker.py`      | PostToolUse      | Validate JS/TS import paths resolve to files      |
| `naming-convention.py`   | PostToolUse      | Enforce file naming conventions per directory     |
| `context-loader.sh`      | UserPromptSubmit | Auto-load relevant rules when skills are invoked  |
| `search-hint.sh`         | PreToolUse       | Suggest faster search methods (Glob over Grep)    |
| `bash-safety.py`         | PreToolUse       | Auto-allow safe read-only commands                |
| `desktop-notify.sh`      | Stop             | Desktop notification (macOS/Linux) on completion  |

### Hook Lifecycle

```
UserPromptSubmit → PreToolUse → [Tool Executes] → PostToolUse → Stop
```

Exit codes: `0` = allow, `1` = warn (message shown), `2` = block (tool prevented)

## What's Included

### Development Rules

- **frontend.md** - React component patterns, MUI styling with `sx` prop, hooks, forms, accessibility
- **backend.md** - Express architecture (routes → controllers → services), error handling, validation, auth
- **api-design.md** - REST conventions, HTTP methods/status codes, pagination, versioning, OpenAPI specs
- **database.md** - PostgreSQL schema design, naming conventions, migrations, query optimization

### Quality Rules

- **testing.md** - Unit testing with Jest, integration with Supertest, E2E with Playwright, Page Object Model
- **quality-gates.md** - PR checks, CI pipeline gates, staging QA, release criteria, performance thresholds
- **code-review.md** - PR templates, review checklists, comment etiquette, approval criteria
- **security.md** - OWASP Top 10 prevention, input validation, JWT security, rate limiting, XSS prevention

### Operations Rules

- **devops.md** - GitHub Actions workflows, Docker configuration, deployment strategies, health checks
- **architecture.md** - ADR templates, system design documentation, Mermaid diagrams, technical debt tracking
- **documentation.md** - README structure, API docs, runbooks, incident response templates
- **no-ascii-diagrams.md** - Enforce Mermaid diagrams, never ASCII art

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

Edit `.claude/CLAUDE.md` to change frameworks, libraries, or coverage thresholds.

### Add Custom Rules

Create new files in `.claude/rules/` and reference them in `settings.json` under the appropriate agent.

### Add Custom Skills

Create new files in `.claude/skills/<category>/` with YAML frontmatter:

```markdown
---
description: "Short description for /my-skill"
model: sonnet
---

# My Skill

Instructions for the skill...
```

Or use `/skill-creator` to generate skills interactively.

### Adjust Permissions

Edit `.claude/settings.json` to add or remove allowed/denied commands.

### Customise Hooks

Hook scripts in `hooks/` can be modified to adjust patterns, thresholds, or behaviour. Key customisation points:

- `secret-detection.py` — Add patterns to `SECRET_PATTERNS` list
- `file-protection.py` — Modify `PROTECTED_PATHS` and `SAFE_DIRECTORIES`
- `bash-safety.py` — Extend `SAFE_COMMANDS` or `NEVER_SAFE` lists
- `naming-convention.py` — Adjust `CONVENTIONS` per directory

## Requirements

- [Claude Code](https://claude.ai/code) or compatible tool
- Node.js 18+ (for the configured tech stack)
- Python 3 (for hook scripts)
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

## Acknowledgments

- Built for teams using Claude Code who want consistent, high-quality development practices across the entire SDLC
- Skills adapted from [Dave's Claude Code Skills](https://github.com/DavidROliverBA/Daves-Claude-Code-Skills) with significant adaptation for SDLC/web development workflows

## License

MIT License - see [LICENSE](LICENSE) for details.
