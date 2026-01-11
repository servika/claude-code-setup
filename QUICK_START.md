# Quick Start Guide

**Universal Node.js/React/MUI Claude Configuration**

Get up and running in 5 minutes! 🚀

---

## New Project Setup

### Step 1: Copy Configuration

```bash
# Copy .claude folder to your new project
cp -r /path/to/claude-configuration/.claude /path/to/your-project/

# Navigate to your project
cd /path/to/your-project
```

### Step 2: Run Project Interview (Important!)

This is the **most important step** to customize the configuration for your project.

```bash
# Inside Claude Code
> Claude, use the project interview agent to configure this project
```

The interview will ask you 33 questions about:
- Your project type and tech stack
- Testing preferences
- Code quality requirements
- Git workflow
- Security needs
- Team preferences

**What you'll get:**
- `.claude/project-config.json` - Your project profile
- `.env.example` - Environment variables template
- `eslint.config.js` - Code quality rules
- `.prettierrc.json` - Code formatting rules
- `jest.config.js` or `vitest.config.js` - Test configuration
- `tsconfig.json` - TypeScript config (if applicable)
- `docker-compose.yml` - Docker setup (if needed)
- `.github/workflows/ci.yml` - CI/CD workflow (if using GitHub Actions)

### Step 3: Install Git Hooks

```bash
# Install quality gates
bash .claude/hooks/install-hooks.sh
```

This enables:
- ✅ Auto-documentation generation on commit
- ✅ ESLint validation
- ✅ Test coverage checks (60% minimum)
- ✅ JSDoc validation
- ⚠️ console.log warnings

### Step 4: Install Dependencies

```bash
# Install ESLint and Prettier
npm install --save-dev eslint prettier eslint-config-prettier

# Install testing tools
npm install --save-dev jest @testing-library/react @testing-library/jest-dom

# Install any additional tools based on your interview responses
```

### Step 5: Start Coding!

You're ready! Use the specialized agents to speed up development:

```bash
# Generate backend code
> Claude, use the backend generator agent to create user authentication API

# Generate frontend components
> Claude, use the frontend generator agent to create a login form with MUI

# Generate documentation
> Claude, use the project docs generator agent to create a comprehensive README

# Analyze libraries
> Claude, use the library analyzer agent to evaluate axios vs native fetch
```

---

## Existing Project Setup

### Step 1: Copy Configuration

```bash
# Copy .claude folder to your existing project
cp -r /path/to/claude-configuration/.claude /path/to/your-existing-project/

# Navigate to your project
cd /path/to/your-existing-project
```

### Step 2: Run Project Interview

```bash
# Tell Claude about your existing setup
> Claude, use the project interview agent to configure this existing project
```

**Tip:** Mention what you already have installed:
```
> Claude, use the project interview agent. We already have:
> - React 18.2.0
> - ESLint with Airbnb config
> - Jest with 75% coverage
> - PostgreSQL with Prisma
> Please configure around our existing setup.
```

### Step 3: Review Generated Configs

**Before overwriting your existing configs, review the generated ones:**

```bash
# Compare ESLint config
diff eslint.config.js .claude/templates/eslint.config.js

# Compare Prettier config
diff .prettierrc.json .claude/templates/.prettierrc.json

# Compare Jest config
diff jest.config.js .claude/templates/jest.config.js
```

**Merge carefully!** Keep your existing customizations.

### Step 4: Install Git Hooks (Optional)

```bash
# Only if you want automated quality checks
bash .claude/hooks/install-hooks.sh
```

**Note:** This will enforce:
- 60% minimum test coverage
- ESLint with no errors
- JSDoc comments on functions

If your project doesn't meet these yet, you can:
- Skip hooks for now
- Adjust thresholds in `.claude/hooks/pre-commit.sh`
- Gradually improve to meet standards

### Step 5: Start Using Agents

```bash
# Generate new features
> Claude, use the backend generator agent to add password reset functionality

# Improve existing code
> Claude, review this component and suggest improvements based on MUI best practices

# Generate documentation
> Claude, use the dev docs generator agent to create testing guidelines
```

---

## Available Agents

### 1. Project Interview Agent (START HERE!)
```
Claude, use the project interview agent to configure this project
```
**Creates project-specific configuration and starter files**

### 2. Library Analyzer Agent
```
Claude, use the library analyzer agent to evaluate [package-name]
```
**Analyzes libraries for security, performance, and compatibility**

Examples:
- `Claude, analyze moment vs date-fns using the library analyzer agent`
- `Claude, should we use Redux or Zustand? Use the library analyzer agent`

### 3. Backend Generator Agent
```
Claude, use the backend generator agent to create [feature]
```
**Generates Express routes, controllers, services, and tests**

Examples:
- `Claude, create a RESTful API for blog posts using the backend generator agent`
- `Claude, implement JWT authentication using the backend generator agent`

### 4. Frontend Generator Agent
```
Claude, use the frontend generator agent to create [component]
```
**Generates React components with MUI styling and hooks**

Examples:
- `Claude, create a user profile form with validation using the frontend generator agent`
- `Claude, build a data table with sorting and filtering using the frontend generator agent`

### 5. Project Docs Generator Agent
```
Claude, use the project docs generator agent to create [document]
```
**Generates user-facing documentation like README, guides, etc.**

Examples:
- `Claude, create a comprehensive README using the project docs generator agent`
- `Claude, generate deployment documentation using the project docs generator agent`

### 6. Dev Docs Generator Agent
```
Claude, use the dev docs generator agent to create [document]
```
**Generates technical documentation for developers**

Examples:
- `Claude, create a testing guide using the dev docs generator agent`
- `Claude, document our coding standards using the dev docs generator agent`

### 7. Architecture Docs Generator Agent
```
Claude, use the architecture docs generator agent to document [aspect]
```
**Generates system architecture documentation**

Examples:
- `Claude, create a system architecture document using the architecture docs generator agent`
- `Claude, document our database schema using the architecture docs generator agent`

---

## Common Workflows

### Creating a New Feature

```bash
# 1. Generate backend API
> Claude, use the backend generator agent to create user profile management API with CRUD operations

# 2. Generate frontend component
> Claude, use the frontend generator agent to create a user profile page with edit functionality

# 3. Write tests
> Claude, add comprehensive tests for the user profile feature

# 4. Document
> Claude, use the project docs generator agent to document the user profile feature

# 5. Commit (hooks will run automatically)
git add .
git commit -m "feat: add user profile management"
```

### Evaluating New Dependencies

```bash
# 1. Analyze options
> Claude, use the library analyzer agent to compare React Query vs SWR vs Apollo Client for data fetching

# 2. Review recommendations
# [Agent provides security, performance, bundle size analysis]

# 3. Install chosen library
npm install @tanstack/react-query

# 4. Implement
> Claude, use the frontend generator agent to create a custom hook for user data fetching with React Query
```

### Improving Code Quality

```bash
# 1. Run code review
> Claude, review my staged changes using the code review checklist in .claude/hooks/code-review-prompt.md

# 2. Address issues
# [Fix identified problems]

# 3. Check coverage
npm run test:coverage

# 4. Commit (hooks enforce quality)
git add .
git commit -m "refactor: improve error handling in user service"
```

### Onboarding New Team Members

```bash
# 1. Share configuration
# New dev clones repo with .claude folder

# 2. Install hooks
bash .claude/hooks/install-hooks.sh

# 3. Generate onboarding docs
> Claude, use the dev docs generator agent to create an onboarding guide

# 4. Review architecture
> Claude, use the architecture docs generator agent to document our system for new developers
```

---

## Configuration Files Explained

### `.claude/CLAUDE.md`
**Main development guidelines** - Core identity, architecture patterns, verification requirements, communication style

### `.claude/rules/`
**Technology-specific rules:**
- `express.md` - Express.js API patterns
- `mui.md` - Material-UI component guidelines
- `nodejs.md` - Node.js runtime patterns
- `react.md` - React component patterns
- `security.md` - Security best practices
- `testing.md` - Testing strategies
- `package-json.md` - Package management

### `.claude/agents/`
**Specialized agents** for code generation, documentation, and analysis

### `.claude/hooks/`
**Git hooks** for automated quality checks and documentation generation

### `.claude/project-config.json` (Generated)
**Your project profile** - Created by project interview agent, stores all project-specific settings

---

## Customization

### Adjusting Coverage Thresholds

Edit `.claude/hooks/pre-commit.sh`:

```bash
# Change from 60 to your desired percentage
if [ "$COVERAGE_INT" -lt 60 ]; then
```

### Disabling Specific Checks

Comment out sections in `.claude/hooks/pre-commit.sh`:

```bash
# # 2. Check for console.log statements (warning only)
# echo ""
# echo "🔍 Checking for console.log statements..."
# ...
```

### Adding Custom Rules

Edit `.claude/CLAUDE.md` or create custom rule files:

```bash
# Add company-specific rules
echo "# Custom Company Rules" > .claude/rules/company-specific.md
```

### Updating Agent Behavior

Edit agent files in `.claude/agents/*.md` to customize generation patterns.

---

## Troubleshooting

### Hook Not Running

```bash
# Verify hook is executable
ls -la .git/hooks/pre-commit

# If not executable
chmod +x .git/hooks/pre-commit
```

### Coverage Check Failing

```bash
# Run coverage manually to see details
npm run test:coverage

# Check coverage report
open coverage/lcov-report/index.html
```

### ESLint Errors

```bash
# Run linting manually
npm run lint

# Auto-fix issues
npm run lint -- --fix
```

### Agent Not Following Your Project Style

```bash
# Re-run project interview
> Claude, re-run the project interview agent to update our configuration

# Or manually edit
vim .claude/project-config.json
```

### Bypassing Hooks Temporarily

```bash
# Only for emergency fixes!
git commit --no-verify -m "Emergency hotfix"
```

---

## Best Practices

### ✅ Do

- **Run project interview first** - Essential for customization
- **Use agents for generation** - Consistent patterns across codebase
- **Let hooks run** - They catch issues before CI/CD
- **Document as you code** - JSDoc comments for auto-documentation
- **Write tests as you develop** - Maintain coverage threshold
- **Review agent output** - Always verify generated code

### ❌ Don't

- **Skip project interview** - Configuration won't match your needs
- **Bypass hooks regularly** - They exist for code quality
- **Ignore coverage failures** - Test your code properly
- **Commit without JSDoc** - Documentation is required
- **Use console.log in production** - Use proper logging
- **Override security patterns** - Follow security guidelines

---

## Next Steps

1. **✅ Complete:** Copy `.claude` folder
2. **✅ Complete:** Run project interview agent
3. **✅ Complete:** Install git hooks
4. **✅ Complete:** Install dependencies
5. **🚀 Start:** Use agents to build features!

---

## Support

**Documentation:**
- [Configuration Review](./CONFIGURATION_REVIEW.md) - Detailed analysis
- [Agent README](./.claude/agents/README.md) - All agents explained
- [Hooks README](./.claude/hooks/README.md) - Git hooks explained

**Issues:**
- Edit `.claude/project-config.json` for project settings
- Edit `.claude/rules/*.md` for rule customization
- Edit `.claude/agents/*.md` for agent behavior

---

**You're ready to build production-grade Node.js/React/MUI applications!** 🎉

Happy coding with Claude Code! 🚀