# GitHub Templates & Workflows

This directory contains GitHub-specific configuration files for issue templates, pull request templates, and CI/CD workflows.

---

## Structure

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml           # Bug report template
│   ├── feature_request.yml      # Feature request template
│   ├── documentation.yml        # Documentation issue template
│   └── config.yml               # Issue template configuration
├── workflows/                   # GitHub Actions workflows
│   ├── ci.yml                   # Continuous Integration (lint, test, build)
│   ├── security.yml             # Security audits and vulnerability scanning
│   ├── deploy-staging.yml       # Deploy to staging environment
│   ├── deploy-production.yml    # Deploy to production (blue-green)
│   └── dependency-updates.yml   # Automated dependency maintenance
├── pull_request_template.md    # PR template
└── README.md                    # This file
```

---

## Issue Templates

### Bug Report (`bug_report.yml`)

Structured template for reporting bugs that includes:
- **Severity classification**: P0-P3 (aligned with `.claude/rules/quality-management.md`)
- **Component identification**: Frontend, Backend, Database, etc.
- **Reproduction steps**: Clear steps to reproduce the issue
- **Environment details**: Version, browser, Node.js version
- **Regression tracking**: Was this working before?

**When to use**: Report unexpected behavior, errors, or broken functionality.

### Feature Request (`feature_request.yml`)

Template for suggesting new features that includes:
- **Problem statement**: Focus on the problem, not the solution
- **RICE scoring inputs**: Reach, Impact, Confidence, Effort (see `.claude/rules/product-development.md`)
- **Use cases**: Specific user stories
- **Priority assessment**: User's perspective on importance
- **Technical considerations**: Optional implementation notes

**When to use**: Propose new functionality or enhancements.

### Documentation Issue (`documentation.yml`)

Template for documentation improvements that includes:
- **Documentation type**: README, API docs, code comments, guides, etc.
- **Issue classification**: Missing, incorrect, outdated, unclear, incomplete, broken
- **Location**: Where the docs are (or should be)
- **Impact assessment**: Who is affected and how
- **Proposed content**: Suggested documentation text

**When to use**: Report missing, incorrect, or unclear documentation.

### Configuration (`config.yml`)

Controls the issue template chooser with:
- Disables blank issues (forces use of templates)
- Links to development guidelines (`.claude/`)
- Links to discussions for questions
- Links to security advisories for vulnerabilities
- Links to documentation

---

## Pull Request Template

The PR template (`pull_request_template.md`) provides comprehensive checklist covering:

### Core Sections
1. **Summary & Type**: What changed and why
2. **Related Issues**: Links to issue numbers
3. **Changes Made**: Detailed list of modifications
4. **Technical Details**: Backend and frontend specifics

### Quality Checklists
1. **Testing**: Unit, integration, manual testing with coverage requirements
2. **Security**: Hardcoded secrets, input validation, auth checks
3. **Code Quality**: ESLint, formatting, JSDoc, architecture patterns
4. **Documentation**: README, API docs, comments, examples

### Additional Considerations
1. **Database Changes**: Migrations, rollback, backwards compatibility
2. **Performance**: N+1 queries, memoization, optimization
3. **Accessibility**: Keyboard nav, screen readers, ARIA labels
4. **Breaking Changes**: Migration instructions and deprecation period

### Deployment
1. **Deployment Notes**: Environment variables, configuration, steps
2. **Rollback Procedure**: How to revert if deployment fails
3. **Post-Merge Actions**: Changelog, monitoring, notifications

### Reviewer Guidelines
Links to `.claude/rules/coding-standards.md` for systematic code review approach.

---

## GitHub Actions Workflows

### Available Workflows

The following workflows are configured and ready to use:

#### 1. CI Workflow (`ci.yml`)

**Purpose**: Continuous Integration - runs on every push and pull request

**Jobs**:
- **Lint**: ESLint code quality checks and Prettier formatting verification
- **Type Check**: TypeScript type checking (if applicable)
- **Test**: Run test suite with PostgreSQL service, enforce ≥60% coverage
- **Build**: Compile/bundle project and upload build artifacts

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

**Requirements**:
- `npm run lint` script
- `npm run format:check` script
- `npm run type-check` script (for TypeScript projects)
- `npm run test:coverage` script
- `npm run build` script

**Configuration**: No secrets required for basic CI

---

#### 2. Security Audit (`security.yml`)

**Purpose**: Daily security scans and vulnerability detection

**Jobs**:
- **NPM Audit**: Check for known vulnerabilities in dependencies
- **Snyk**: Advanced vulnerability scanning with Snyk
- **CodeQL**: Semantic code analysis for security issues
- **Dependency Review**: Review dependency changes in PRs

**Triggers**:
- Daily at midnight (cron schedule)
- Every push to `main` or `develop`
- Pull requests
- Manual trigger via workflow_dispatch

**Required Secrets**:
```
SNYK_TOKEN - Snyk API token (get from https://snyk.io)
```

**Setup**:
1. Create Snyk account and get API token
2. Add `SNYK_TOKEN` to GitHub repository secrets
3. Enable CodeQL in repository settings (Security → Code scanning)

---

#### 3. Deploy to Staging (`deploy-staging.yml`)

**Purpose**: Automated deployment to staging environment

**Jobs**:
- Run tests before deployment
- Build project for production
- Deploy to staging server via SSH
- Run smoke tests on deployed application
- Send deployment notifications

**Triggers**:
- Push to `develop` branch
- Manual trigger via workflow_dispatch

**Required Secrets**:
```
STAGING_SSH_PRIVATE_KEY - SSH private key for staging server
STAGING_HOST            - Staging server hostname
STAGING_USER            - SSH username for staging server
```

**Environment Configuration**:
- Create `staging` environment in repository settings
- Set environment URL: `https://staging.yourdomain.com`
- Add required secrets to the environment

**Setup**:
1. Generate SSH key pair: `ssh-keygen -t ed25519 -C "github-actions"`
2. Add public key to staging server's `~/.ssh/authorized_keys`
3. Add private key to GitHub secrets as `STAGING_SSH_PRIVATE_KEY`
4. Update deployment script with correct paths and commands
5. Ensure PM2 is installed on staging server

---

#### 4. Deploy to Production (`deploy-production.yml`)

**Purpose**: Blue-green deployment to production environment

**Jobs**:
- Run full test suite
- Build production artifacts
- Deploy using blue-green strategy (zero-downtime)
- Run smoke tests
- Create GitHub release
- Rollback on failure

**Triggers**:
- Push tags matching `v*.*.*` (e.g., `v1.0.0`)
- Manual trigger via workflow_dispatch

**Required Secrets**:
```
PRODUCTION_SSH_PRIVATE_KEY - SSH private key for production server
PRODUCTION_HOST            - Production server hostname
PRODUCTION_USER            - SSH username for production server
```

**Environment Configuration**:
- Create `production` environment in repository settings
- Set environment URL: `https://yourdomain.com`
- Enable protection rules (required reviewers)
- Add required secrets to the environment

**Deployment Strategy**:
- Uses blue-green deployment for zero-downtime
- Runs health checks before switching traffic
- Maintains previous version for instant rollback

**How to Deploy**:
```bash
# Create and push version tag
git tag v1.0.0
git push origin v1.0.0

# Workflow automatically triggers
# Production environment requires approval
```

**Server Setup**:
```bash
# Production server structure
/var/www/
├── production-blue/      # Blue slot
├── production-green/     # Green slot
├── production-current    # Symlink to active slot
└── releases/             # Release archives

# Nginx configuration points to production-current
```

---

#### 5. Dependency Updates (`dependency-updates.yml`)

**Purpose**: Automated dependency maintenance

**Jobs**:
- Check for outdated packages
- Update dependencies and run security fixes
- Run tests to verify compatibility
- Create PR with changes
- Auto-merge minor/patch Dependabot PRs

**Triggers**:
- Weekly on Monday at 9 AM (cron schedule)
- Manual trigger via workflow_dispatch
- Dependabot PRs (for auto-merge logic)

**Configuration**: No secrets required

**Features**:
- Creates weekly PR with dependency updates
- Auto-approves and merges Dependabot patch/minor updates
- Runs full test suite before creating PR

---

### Workflow Configuration

#### Required GitHub Secrets

Add these secrets in **Settings → Secrets and variables → Actions**:

**For Staging Deployment**:
- `STAGING_SSH_PRIVATE_KEY`: SSH private key for staging server
- `STAGING_HOST`: Staging server hostname (e.g., `staging.yourdomain.com`)
- `STAGING_USER`: SSH username (e.g., `deploy`)

**For Production Deployment**:
- `PRODUCTION_SSH_PRIVATE_KEY`: SSH private key for production server
- `PRODUCTION_HOST`: Production server hostname (e.g., `yourdomain.com`)
- `PRODUCTION_USER`: SSH username (e.g., `deploy`)

**For Security Scanning**:
- `SNYK_TOKEN`: Snyk API token from https://snyk.io

#### Environment Setup

Create environments in **Settings → Environments**:

**Staging Environment**:
- Name: `staging`
- URL: `https://staging.yourdomain.com`
- Protection rules: Optional

**Production Environment**:
- Name: `production`
- URL: `https://yourdomain.com`
- Protection rules:
  - ✓ Required reviewers (1-2 team members)
  - ✓ Wait timer (5 minutes recommended)
  - ✓ Restrict to protected branches

#### Package.json Scripts

Ensure these scripts exist in your `package.json`:

```json
{
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node dist/server.js",
    "build": "tsc",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "test:coverage:check": "jest --coverage --coverageThreshold='{\"global\":{\"statements\":60,\"branches\":60,\"functions\":60,\"lines\":60}}'",
    "lint": "eslint src --ext .js,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{js,ts,tsx,json,md}\"",
    "format:check": "prettier --check \"src/**/*.{js,ts,tsx,json,md}\"",
    "type-check": "tsc --noEmit"
  }
}
```

#### Server Prerequisites

**Staging and Production Servers Need**:
- Node.js 18+ installed
- PM2 process manager: `npm install -g pm2`
- Nginx for load balancing (production blue-green setup)
- SSH access configured
- Deploy user with appropriate permissions

**For Blue-Green Deployment (Production)**:
```bash
# Create deployment directories
sudo mkdir -p /var/www/production-blue
sudo mkdir -p /var/www/production-green
sudo mkdir -p /var/www/releases
sudo chown -R deploy:deploy /var/www

# Initial symlink
ln -s /var/www/production-blue /var/www/production-current

# Nginx configuration
server {
    location / {
        proxy_pass http://localhost:3000;  # production-current
    }
}
```

---

### Customizing Workflows

To customize workflows for your project:

1. **Update Server Paths**: Change deployment paths in deploy workflows
2. **Modify Health Check URLs**: Update smoke test endpoints
3. **Adjust Schedules**: Modify cron schedules for security/dependency scans
4. **Add Notifications**: Integrate Slack/Discord/email notifications
5. **Change Node Version**: Update `node-version` in workflow files
6. **Add Test Database**: Configure additional services in CI workflow

Example: Adding Slack Notifications
```yaml
- name: Notify deployment success
  if: success()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "Deployment to production succeeded! 🚀"
      }
```

---

### Workflow Best Practices

From `.claude/rules/ci-cd.md`:
- **Fail fast**: Stop pipeline on first failure
- **Cache dependencies**: Use actions/cache for node_modules
- **Parallel jobs**: Run independent jobs in parallel
- **Matrix testing**: Test against multiple Node.js versions
- **Security**: Pin action versions, use least privilege permissions
- **Secrets**: Never log secrets, use GitHub secrets
- **Artifacts**: Upload build artifacts for debugging
- **Notifications**: Alert team on deployment success/failure

---

### Monitoring Workflows

**View Workflow Runs**:
- Go to **Actions** tab in GitHub repository
- Click on workflow name to see run history
- Click on individual run to see job details and logs

**Common Issues**:
- **Secret not found**: Ensure secrets are added to correct environment
- **SSH connection failed**: Verify SSH key and server access
- **Tests failing**: Check test logs in CI workflow
- **Coverage below threshold**: Increase test coverage to ≥60%

**Debugging Failed Workflows**:
1. Click on failed job to see logs
2. Expand failed step to see error details
3. Re-run workflow with debug logging: Enable "Re-run jobs" → "Enable debug logging"
4. Check secrets and environment configuration

---

## Integration with Guidelines

These templates are tightly integrated with the project's guideline system (`.claude/` directory):

### Issue Templates Reference
- **Bug Reports** → `.claude/rules/quality-management.md` (incident response)
- **Feature Requests** → `.claude/rules/product-development.md` (RICE scoring)
- **Documentation** → `.claude/rules/documentation-guide.md` (standards)

### PR Template References
- **Code Quality** → `.claude/rules/coding-standards.md` (hierarchy, checklists)
- **Architecture** → `.claude/CLAUDE.md` (patterns)
- **Testing** → `.claude/rules/testing.md` (coverage requirements)
- **Security** → `.claude/rules/security.md` (validation, auth)
- **Commits** → `.claude/rules/commit-policy.md` (conventional commits)

### Workflow References
- **CI/CD Setup** → `.claude/rules/ci-cd.md` (complete guide)
- **Deployment** → `.claude/rules/ci-cd.md` (strategies, rollback)
- **Security Scanning** → `.claude/rules/security.md` + `.claude/rules/ci-cd.md`

---

## Usage Examples

### Creating an Issue

1. Go to repository Issues tab
2. Click "New Issue"
3. Choose template: Bug Report, Feature Request, or Documentation
4. Fill out all required fields
5. Submit

GitHub will guide you through structured form fields.

### Creating a Pull Request

1. Push your branch to remote
2. Open PR on GitHub
3. PR template automatically loads
4. Fill out all checklist sections
5. Request reviewers
6. Ensure CI/CD passes

**Tip**: Use the PR template as a pre-submission checklist.

### Customizing Templates

To modify templates:
1. Edit the `.yml` files in `ISSUE_TEMPLATE/`
2. Test changes by creating a new issue
3. Commit and push changes
4. Templates update automatically

**Note**: Changes to templates only affect new issues/PRs, not existing ones.

---

## Template Maintenance

### When to Update Templates

**Update immediately when**:
- New required fields needed
- Process changes (e.g., new security requirements)
- Guidelines updated (e.g., new coverage threshold)
- Links broken or outdated

**Review quarterly**:
- Ensure alignment with `.claude/` guidelines
- Remove unused fields
- Add fields for common issues/questions
- Update examples and placeholders

### Testing Templates

Before committing template changes:
1. Create test issue/PR using the template
2. Verify all fields render correctly
3. Check dropdown options are complete
4. Test required vs. optional fields
5. Verify markdown rendering

---

## Standards Hierarchy

Templates enforce the project's standards hierarchy from `.claude/rules/coding-standards.md`:

1. **Security** (Non-Negotiable) - Required checklist items
2. **Correctness** (No Broken Code) - Test requirements
3. **Code Quality** (Maintainability) - Coverage, JSDoc, ESLint
4. **Git Conventions** (Traceability) - Conventional commits
5. **Documentation** (Knowledge Sharing) - Docs updates
6. **Style & Conventions** (Consistency) - Automated checks

Templates help ensure nothing is forgotten before submission.

---

## FAQ

### Q: Can I skip sections of the PR template?
**A**: Mark checkboxes if sections aren't applicable (e.g., "No database changes"). Don't delete sections - they serve as reminders.

### Q: What if my PR is just documentation?
**A**: Still fill out the template. Mark "Documentation update" as type and check relevant boxes. Skip testing sections if truly not applicable.

### Q: How do I report a security vulnerability?
**A**: Use the Security Advisories link (don't create public issues). See `.claude/rules/security.md` for security protocols.

### Q: Can I create issues without templates?
**A**: No, blank issues are disabled (`config.yml`). Use Discussions for questions or conversations.

### Q: My issue doesn't fit any template
**A**: Choose the closest template. Use "Additional Context" section to explain why it's different. Or start a Discussion instead.

### Q: Do I need to fill out every field?
**A**: Required fields are marked and enforced by GitHub. Optional fields help but can be skipped if not applicable.

---

## Related Documentation

- **Development Guidelines**: `.claude/CLAUDE.md` - Main development guide
- **Standards Hierarchy**: `.claude/rules/coding-standards.md` - Priority and compliance
- **Quality Management**: `.claude/rules/quality-management.md` - Incident response
- **Product Development**: `.claude/rules/product-development.md` - Feature prioritization
- **CI/CD Guide**: `.claude/rules/ci-cd.md` - Workflow examples
- **System Overview**: `.claude/README.md` - Complete guide index

---

## Contributing

To improve these templates:
1. Create an issue using the Documentation template
2. Propose specific changes with examples
3. Reference relevant guidelines from `.claude/`
4. Test proposed changes before submitting PR

Thank you for helping maintain high-quality processes!