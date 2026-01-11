# Project Interview Agent

## Purpose

This agent conducts a comprehensive interview to gather project-specific details, team preferences, and technical requirements. It creates a customized configuration profile stored in `.claude/project-config.json` that tailors all other agents and guidelines to your specific project needs.

## When to Invoke

**Use this agent when:**
- Starting a new project with this configuration
- Onboarding the configuration to an existing project
- Major project architecture changes
- Team preferences change
- Technology stack additions/changes

**Invocation:**
```
Claude, use the project interview agent to configure this project
```

## Interview Process

The agent conducts a structured interview covering:

### 1. Project Basics
- Project name and description
- Project type (web app, API, mobile backend, etc.)
- Development team size
- Primary programming language (JavaScript/TypeScript)

### 2. Technology Stack
- **Frontend:**
  - React version preference
  - MUI version
  - State management (Context, Redux, Zustand, Jotai)
  - Data fetching (React Query, SWR, native fetch)
  - Routing (React Router, Next.js)
  - Build tool (Vite, Webpack, Create React App)

- **Backend:**
  - Node.js version
  - Express version
  - Database (PostgreSQL, MongoDB, MySQL, etc.)
  - ORM/ODM (Prisma, TypeORM, Mongoose, Sequelize)
  - Authentication (JWT, sessions, OAuth)
  - Caching (Redis, in-memory)

- **Testing:**
  - Test runner (Jest, Vitest)
  - E2E testing (Cypress, Playwright, none)
  - Coverage requirements (default 60% or custom)

- **DevOps:**
  - CI/CD platform (GitHub Actions, GitLab CI, CircleCI)
  - Container strategy (Docker, none)
  - Cloud provider (AWS, Azure, GCP, none)
  - Deployment target (VPS, serverless, PaaS)

### 3. Code Quality Standards
- ESLint configuration (Airbnb, Standard, custom)
- Prettier settings
- Pre-commit hooks enabled/disabled
- TypeScript strictness level
- Import order preferences
- Line length limit (80, 100, 120)

### 4. Documentation Preferences
- Auto-documentation enabled/disabled
- JSDoc strictness (required, recommended, optional)
- README auto-update enabled/disabled
- API documentation format (Markdown, Swagger/OpenAPI)
- Component documentation format

### 5. Git & Workflow
- Branch naming convention
- Commit message format (Conventional Commits, custom)
- PR/MR template preferences
- Code review requirements
- Git hooks strictness level

### 6. Security & Compliance
- Security scanning enabled/disabled
- Secret scanning enabled/disabled
- Dependency audit frequency
- CORS configuration needs
- Rate limiting requirements
- Audit logging requirements

### 7. Team Preferences
- Timezone(s) of team members
- Communication style (formal, casual, technical)
- Error message verbosity
- Console output preferences
- AI assistance level (aggressive, balanced, conservative)

## Generated Configuration

The agent creates `.claude/project-config.json`:

```json
{
  "projectInfo": {
    "name": "my-awesome-app",
    "description": "Full-stack e-commerce platform",
    "type": "web-application",
    "teamSize": 5,
    "language": "javascript"
  },
  "techStack": {
    "frontend": {
      "framework": "react",
      "version": "18.2.0",
      "ui": "mui",
      "stateManagement": "react-query",
      "router": "react-router",
      "buildTool": "vite"
    },
    "backend": {
      "runtime": "node",
      "version": "20.x",
      "framework": "express",
      "database": "postgresql",
      "orm": "prisma",
      "auth": "jwt",
      "caching": "redis"
    },
    "testing": {
      "runner": "jest",
      "e2e": "playwright",
      "coverageThreshold": 60,
      "perFileCoverage": 20
    },
    "devops": {
      "ci": "github-actions",
      "containers": "docker",
      "cloud": "aws",
      "deployment": "ecs"
    }
  },
  "codeQuality": {
    "eslint": "airbnb",
    "prettier": true,
    "preCommitHooks": true,
    "typescript": false,
    "lineLength": 100,
    "importOrder": "grouped"
  },
  "documentation": {
    "autoGeneration": true,
    "jsdocRequired": true,
    "readmeAutoUpdate": true,
    "apiFormat": "markdown",
    "componentDocs": true
  },
  "git": {
    "branchNaming": "feature/*, bugfix/*, hotfix/*",
    "commitFormat": "conventional",
    "prTemplate": true,
    "codeReview": "required",
    "hooksStrictness": "strict"
  },
  "security": {
    "scanning": true,
    "secretScanning": true,
    "auditFrequency": "weekly",
    "cors": "configured",
    "rateLimiting": true,
    "auditLogging": true
  },
  "teamPreferences": {
    "timezone": "UTC-5",
    "communicationStyle": "technical",
    "errorVerbosity": "detailed",
    "consoleOutput": "minimal",
    "aiAssistance": "balanced"
  },
  "customRules": [],
  "configVersion": "1.0.0",
  "lastUpdated": "2026-01-09T00:00:00Z"
}
```

## Interview Questions Template

### Phase 1: Essential Information
1. **What is your project name?**
2. **Briefly describe what this project does** (1-2 sentences)
3. **What type of project is this?**
   - [ ] Web application (frontend + backend)
   - [ ] API only (backend)
   - [ ] Frontend only
   - [ ] Full-stack monorepo
   - [ ] Other: _______

4. **How many developers will work on this project?**
   - [ ] Solo (1)
   - [ ] Small team (2-5)
   - [ ] Medium team (6-15)
   - [ ] Large team (15+)

5. **Are you using JavaScript or TypeScript?**
   - [ ] JavaScript (ESM)
   - [ ] TypeScript (strict)
   - [ ] TypeScript (loose)
   - [ ] Mixed (migrating)

### Phase 2: Frontend Stack (if applicable)
6. **Which React version are you targeting?**
   - [ ] React 17.x
   - [ ] React 18.x (recommended)
   - [ ] React 19.x (latest)

7. **State management preference?**
   - [ ] React Context + hooks
   - [ ] React Query / TanStack Query
   - [ ] Redux Toolkit
   - [ ] Zustand
   - [ ] Jotai
   - [ ] Other: _______

8. **Build tool?**
   - [ ] Vite (recommended)
   - [ ] Create React App
   - [ ] Next.js
   - [ ] Webpack custom
   - [ ] Other: _______

### Phase 3: Backend Stack (if applicable)
9. **Which Node.js version?**
   - [ ] Node 18 LTS
   - [ ] Node 20 LTS (recommended)
   - [ ] Node 21+ (latest)

10. **Database?**
    - [ ] PostgreSQL
    - [ ] MongoDB
    - [ ] MySQL/MariaDB
    - [ ] SQLite (development)
    - [ ] Multiple databases
    - [ ] None yet

11. **ORM/ODM preference?**
    - [ ] Prisma (SQL databases)
    - [ ] TypeORM
    - [ ] Sequelize
    - [ ] Mongoose (MongoDB)
    - [ ] Drizzle
    - [ ] Raw SQL/queries
    - [ ] None yet

12. **Authentication strategy?**
    - [ ] JWT tokens
    - [ ] Session-based
    - [ ] OAuth 2.0 / OpenID Connect
    - [ ] Passport.js
    - [ ] Custom
    - [ ] Not implemented yet

### Phase 4: Testing Strategy
13. **Test runner preference?**
    - [ ] Jest
    - [ ] Vitest
    - [ ] Mocha
    - [ ] Other: _______

14. **E2E testing needed?**
    - [ ] Yes - Playwright
    - [ ] Yes - Cypress
    - [ ] Not yet
    - [ ] Not required

15. **Test coverage requirements?**
    - [ ] 60% minimum (recommended)
    - [ ] 80% minimum (strict)
    - [ ] 40% minimum (relaxed)
    - [ ] No strict requirement
    - [ ] Custom: ____%

### Phase 5: Code Quality
16. **ESLint configuration?**
    - [ ] Airbnb style guide
    - [ ] Standard JS
    - [ ] Google style guide
    - [ ] Custom configuration
    - [ ] None/basic

17. **Use Prettier for formatting?**
    - [ ] Yes (recommended)
    - [ ] No (manual formatting)
    - [ ] Already configured

18. **Enable pre-commit hooks?**
    - [ ] Yes - strict (blocks bad commits)
    - [ ] Yes - warnings only
    - [ ] No (team preference)

19. **Maximum line length?**
    - [ ] 80 characters
    - [ ] 100 characters (recommended)
    - [ ] 120 characters
    - [ ] No limit

### Phase 6: Documentation
20. **Enable auto-documentation generation?**
    - [ ] Yes - generate from JSDoc
    - [ ] No - manual documentation
    - [ ] Partial (API only)

21. **JSDoc comments requirement?**
    - [ ] Required for all functions
    - [ ] Required for exported functions
    - [ ] Recommended only
    - [ ] Optional

22. **API documentation format?**
    - [ ] Markdown (auto-generated)
    - [ ] Swagger/OpenAPI
    - [ ] Postman collection
    - [ ] None yet

### Phase 7: Git Workflow
23. **Branch naming convention?**
    - [ ] feature/*, bugfix/*, hotfix/* (recommended)
    - [ ] user/feature-name
    - [ ] ticket-number-description
    - [ ] Custom: _______

24. **Commit message format?**
    - [ ] Conventional Commits (feat:, fix:, etc.)
    - [ ] Free form
    - [ ] Custom template

25. **Code review process?**
    - [ ] Required PR reviews
    - [ ] Optional reviews
    - [ ] No formal reviews

### Phase 8: Security
26. **Enable security scanning?**
    - [ ] Yes - npm audit + Snyk
    - [ ] Yes - npm audit only
    - [ ] No

27. **Rate limiting needed?**
    - [ ] Yes - aggressive (5 req/min)
    - [ ] Yes - moderate (100 req/15min)
    - [ ] Yes - relaxed (custom)
    - [ ] Not yet

28. **Audit logging?**
    - [ ] Full audit trail
    - [ ] Error logging only
    - [ ] Minimal logging

### Phase 9: DevOps
29. **CI/CD platform?**
    - [ ] GitHub Actions
    - [ ] GitLab CI
    - [ ] CircleCI
    - [ ] Jenkins
    - [ ] Not set up yet
    - [ ] Other: _______

30. **Deployment target?**
    - [ ] AWS (ECS, Lambda, EC2)
    - [ ] Azure
    - [ ] Google Cloud
    - [ ] Vercel/Netlify
    - [ ] VPS (Digital Ocean, Linode)
    - [ ] Not decided yet

### Phase 10: Team Preferences
31. **Team's primary timezone?**
    - [ ] UTC
    - [ ] EST/EDT (UTC-5/-4)
    - [ ] PST/PDT (UTC-8/-7)
    - [ ] CET/CEST (UTC+1/+2)
    - [ ] Other: _______

32. **Communication style for AI responses?**
    - [ ] Technical and concise
    - [ ] Detailed with explanations
    - [ ] Casual and friendly
    - [ ] Formal and professional

33. **AI assistance level?**
    - [ ] Aggressive (proactive suggestions, auto-fixes)
    - [ ] Balanced (suggestions when asked)
    - [ ] Conservative (only respond to direct requests)

## Post-Interview Actions

After gathering responses, the agent will:

1. **Create configuration file** - Generate `.claude/project-config.json`
2. **Generate starter files** - Create relevant config files:
   - `.env.example`
   - `eslint.config.js` or `.eslintrc.js`
   - `.prettierrc.json`
   - `jest.config.js` or `vitest.config.js`
   - `tsconfig.json` (if TypeScript)
   - `docker-compose.yml` (if containers)
   - `.github/workflows/ci.yml` (if GitHub Actions)

3. **Customize rules** - Adjust `.claude/CLAUDE.md` with project-specific settings
4. **Update README** - Add project-specific setup instructions
5. **Initialize git hooks** - Set up hooks based on preferences
6. **Create starter scripts** - Add npm scripts to `package.json`

## Usage Examples

### Example 1: New Project Setup
```
User: I'm starting a new e-commerce platform with React and Node.js

Claude: Let me use the project interview agent to configure your project properly.

[Conducts interview with all 33 questions]

Configuration complete! I've created:
- .claude/project-config.json
- .env.example
- eslint.config.js
- .prettierrc.json
- jest.config.js
- docker-compose.yml

Your project is now configured for:
- React 18 + MUI
- Node.js 20 + Express
- PostgreSQL with Prisma
- JWT authentication
- GitHub Actions CI/CD
- Strict code quality checks
```

### Example 2: Existing Project Adoption
```
User: I want to add this configuration to my existing React/Express project

Claude: I'll use the project interview agent to understand your current setup.

[Asks questions, detects existing configurations]

I've detected your existing setup:
- React 18.2.0 ✓
- ESLint (Airbnb) ✓
- Jest with 75% coverage ✓

I'll configure the Claude Code guidelines to match your existing patterns.
```

### Example 3: Team Onboarding
```
User: Our team of 5 developers needs this configured for a new microservices project

Claude: Let me interview you about your team's preferences and architecture.

[Gathers team-specific preferences]

Configuration created for your team:
- Microservices architecture support
- Docker compose for local development
- Shared ESLint/Prettier configs
- Conventional commits enforced
- PR reviews required (2 approvals)
```

## Skipping Questions

If you want to use defaults for certain sections:

```
Claude, use the project interview agent but skip the DevOps questions (we'll configure that later)
```

Or provide answers upfront:

```
Claude, use the project interview agent. We're using React 18, Node 20, PostgreSQL with Prisma, and Jest for testing.
```

## Re-running Interview

To update configuration:

```
Claude, re-run the project interview agent to update our database choice from MongoDB to PostgreSQL
```

## Configuration Schema

The `.claude/project-config.json` follows this schema:

```typescript
interface ProjectConfig {
  projectInfo: {
    name: string;
    description: string;
    type: 'web-application' | 'api' | 'frontend-only' | 'monorepo' | 'other';
    teamSize: number;
    language: 'javascript' | 'typescript';
  };
  techStack: {
    frontend?: FrontendConfig;
    backend?: BackendConfig;
    testing: TestingConfig;
    devops?: DevOpsConfig;
  };
  codeQuality: CodeQualityConfig;
  documentation: DocumentationConfig;
  git: GitConfig;
  security: SecurityConfig;
  teamPreferences: TeamPreferencesConfig;
  customRules: string[];
  configVersion: string;
  lastUpdated: string;
}
```

## Integration with Other Agents

Once configured, all other agents use this configuration:

- **Backend Generator** - Uses database, ORM, auth settings
- **Frontend Generator** - Uses React version, state management, MUI settings
- **Library Analyzer** - Considers tech stack when recommending alternatives
- **Documentation Generators** - Use documentation preferences
- **Code Review** - Uses code quality standards

## Best Practices

1. **Run on project initialization** - Get configuration right from the start
2. **Re-run when tech stack changes** - Keep configuration in sync
3. **Version control the config** - Commit `.claude/project-config.json`
4. **Share with team** - Ensure all team members have same configuration
5. **Update as project evolves** - Re-interview when requirements change

## Validation

The agent validates responses to ensure:
- Compatible technology combinations
- Realistic coverage thresholds
- Valid version numbers
- Sensible team preferences

## Output

After completion, you'll have:
- ✅ `.claude/project-config.json` - Your project profile
- ✅ Relevant config files generated
- ✅ Customized guidelines
- ✅ Updated README
- ✅ Initialized git hooks (if enabled)
- ✅ Ready-to-use project structure

---

**This agent makes the universal configuration truly customized to YOUR project!**