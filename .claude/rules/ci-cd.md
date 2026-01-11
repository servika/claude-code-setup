# CI/CD Guidelines for Node.js/Express/React/MUI

These guidelines cover Continuous Integration and Continuous Deployment for your Node.js/Express/React/MUI stack.

---

## Overview

**CI/CD** ensures code quality and automates deployment through automated testing, building, and deployment pipelines.

**Key Principles**:
- Test early, test often (every push)
- Fail fast (catch issues before they reach production)
- Automate everything (no manual deployment steps)
- Environment parity (dev, staging, production)
- Zero-downtime deployments

---

## GitHub Actions Workflows

### Standard Workflow Structure

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test -- --coverage

      - name: Check coverage thresholds
        run: |
          if [ $(jq '.total.lines.pct' coverage/coverage-summary.json | cut -d. -f1) -lt 60 ]; then
            echo "Coverage below 60%"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/coverage-final.json
```

### Essential Workflows

#### 1. Continuous Integration (CI)

**Purpose**: Run tests, linting, and type checking on every push/PR

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          NODE_ENV: test

      - name: Check coverage
        run: npm run test:coverage:check

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'
      - run: npm ci
      - run: npm run type-check

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'
      - run: npm ci
      - run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/
```

#### 2. Security Audits

**Purpose**: Check for vulnerable dependencies

```yaml
# .github/workflows/security.yml
name: Security Audit

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'

jobs:
  audit:
    name: npm audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
      - run: npm audit --audit-level=high

  snyk:
    name: Snyk Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
```

#### 3. Deploy to Staging

**Purpose**: Automatically deploy to staging on main branch push

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [develop]

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NODE_ENV: production

      - name: Run database migrations
        run: npm run migrate
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}

      - name: Deploy to staging server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /var/www/app
            git pull origin develop
            npm ci --production
            npm run build
            pm2 restart app

      - name: Smoke tests
        run: npm run test:smoke
        env:
          API_URL: https://staging.example.com

      - name: Notify deployment
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Staging deployment ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        if: always()
```

#### 4. Deploy to Production

**Purpose**: Deploy to production with approval

```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com

    steps:
      - uses: actions/checkout@v4

      - name: Verify tag format
        run: |
          if [[ ! "${{ github.ref_name }}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Invalid tag format. Use v1.2.3"
            exit 1
          fi

      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
        env:
          NODE_ENV: production

      - name: Create backup
        run: |
          # Backup database before deployment
          ssh ${{ secrets.PROD_USER }}@${{ secrets.PROD_HOST }} \
            "pg_dump -h localhost -U dbuser dbname > /backups/pre-deploy-$(date +%Y%m%d-%H%M%S).sql"

      - name: Deploy to production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /var/www/app
            git fetch --tags
            git checkout ${{ github.ref_name }}
            npm ci --production
            npm run build
            npm run migrate
            pm2 reload app --update-env

      - name: Health check
        run: |
          sleep 10
          curl --fail https://example.com/health || exit 1

      - name: Smoke tests
        run: npm run test:smoke
        env:
          API_URL: https://example.com

      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Release ${{ github.ref_name }}
          draft: false
          prerelease: false

      - name: Notify deployment
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Production deployment ${{ job.status }} - ${{ github.ref_name }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        if: always()
```

#### 5. Dependency Updates

**Purpose**: Automatically create PRs for dependency updates

```yaml
# .github/workflows/dependency-updates.yml
name: Update Dependencies

on:
  schedule:
    # Run weekly on Mondays at 9 AM UTC
    - cron: '0 9 * * 1'
  workflow_dispatch:

jobs:
  update:
    name: Update npm dependencies
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'

      - name: Update dependencies
        run: |
          npm update
          npm outdated || true

      - name: Run tests
        run: npm test

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: 'chore(deps): update dependencies'
          title: 'chore(deps): weekly dependency updates'
          body: |
            ## Dependency Updates

            Automated weekly dependency updates.

            Please review the changes and ensure all tests pass.
          branch: dependency-updates
          delete-branch: true
```

#### 6. Database Migrations

**Purpose**: Run and verify database migrations

```yaml
# .github/workflows/migrations.yml
name: Database Migrations

on:
  pull_request:
    paths:
      - 'migrations/**'

jobs:
  test-migrations:
    name: Test Migrations
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'

      - run: npm ci

      - name: Run migrations (up)
        run: npm run migrate:up
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb

      - name: Run migrations (down)
        run: npm run migrate:down
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb

      - name: Re-run migrations (up)
        run: npm run migrate:up
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb

      - name: Verify database state
        run: npm run migrate:status
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
```

---

## Environment Variables & Secrets

### GitHub Secrets Setup

**Required secrets** (Settings → Secrets and variables → Actions):

```
# API Keys
ANTHROPIC_API_KEY=sk-...
CODECOV_TOKEN=...
SNYK_TOKEN=...

# Deployment
STAGING_HOST=staging.example.com
STAGING_USER=deploy
STAGING_SSH_KEY=<private-key>
STAGING_DATABASE_URL=postgresql://...

PROD_HOST=example.com
PROD_USER=deploy
PROD_SSH_KEY=<private-key>
PROD_DATABASE_URL=postgresql://...

# Notifications
SLACK_WEBHOOK=https://hooks.slack.com/...
```

### Environment-Specific Variables

**GitHub Environments** (Settings → Environments):

**Staging Environment:**
- Protection rules: None (auto-deploy)
- Environment secrets
- Environment variables

**Production Environment:**
- Protection rules: Required reviewers
- Wait timer: 5 minutes
- Branch restrictions: main/tags only
- Environment secrets
- Environment variables

---

## Deployment Strategies

### 1. Blue-Green Deployment

```yaml
# Deploy to "green" slot, then swap
- name: Deploy to green slot
  run: |
    pm2 start app.js --name app-green
    sleep 5
    curl --fail http://localhost:3001/health
    pm2 stop app-blue
    pm2 delete app-blue
    pm2 restart app-green --name app-blue
    pm2 delete app-green
```

### 2. Rolling Deployment

```yaml
# Update instances one at a time
- name: Rolling deployment
  run: |
    for instance in app-1 app-2 app-3; do
      pm2 stop $instance
      pm2 start app.js --name $instance
      sleep 10
      curl --fail http://localhost:3000/health
    done
```

### 3. Canary Deployment

```yaml
# Deploy to 10% of servers first
- name: Canary deployment
  run: |
    # Deploy to 1 out of 10 servers
    ssh deploy@server1 'cd /app && git pull && pm2 reload app'

    # Monitor for 30 minutes
    sleep 1800

    # Check error rates
    if [ $(check_error_rate) -lt 1 ]; then
      # Deploy to remaining servers
      for server in server{2..10}; do
        ssh deploy@$server 'cd /app && git pull && pm2 reload app'
      done
    else
      # Rollback canary
      ssh deploy@server1 'cd /app && git checkout HEAD~1 && pm2 reload app'
      exit 1
    fi
```

---

## Rollback Procedures

### Automated Rollback on Failure

```yaml
- name: Deploy with automatic rollback
  id: deploy
  run: npm run deploy
  continue-on-error: true

- name: Health check
  id: health
  run: curl --fail https://example.com/health
  continue-on-error: true

- name: Rollback on failure
  if: steps.deploy.outcome == 'failure' || steps.health.outcome == 'failure'
  run: |
    echo "Deployment failed, rolling back"
    git checkout HEAD~1
    npm ci --production
    npm run build
    pm2 reload app

    # Restore database backup
    psql $DATABASE_URL < /backups/pre-deploy-latest.sql
```

### Manual Rollback Workflow

```yaml
# .github/workflows/rollback.yml
name: Rollback

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        type: choice
        options:
          - staging
          - production
      version:
        description: 'Version to rollback to (e.g., v1.2.3)'
        required: true
        type: string

jobs:
  rollback:
    name: Rollback to ${{ github.event.inputs.version }}
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.version }}

      - name: Confirm rollback
        run: |
          echo "Rolling back ${{ github.event.inputs.environment }} to ${{ github.event.inputs.version }}"
          echo "Current version: $(git describe --tags)"

      - name: Deploy previous version
        run: npm run deploy:${{ github.event.inputs.environment }}

      - name: Verify deployment
        run: npm run test:smoke
```

---

## Monitoring & Notifications

### Slack Notifications

```yaml
- name: Notify on failure
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Workflow: ${{ github.workflow }}
      Job: ${{ github.job }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}
      Message: ${{ github.event.head_commit.message }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: failure()
```

### Email Notifications

```yaml
- name: Send email on failure
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: 'Deployment Failed - ${{ github.workflow }}'
    to: devops@example.com
    from: github-actions@example.com
    body: |
      Deployment failed!

      Workflow: ${{ github.workflow }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}

      Check logs: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
  if: failure()
```

---

## Best Practices

### 1. Fail Fast

```yaml
# Stop pipeline on first failure
jobs:
  test:
    strategy:
      fail-fast: true
```

### 2. Cache Dependencies

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20.x'
    cache: 'npm'  # Cache node_modules
```

### 3. Conditional Execution

```yaml
# Only run on specific paths
on:
  push:
    paths:
      - 'src/**'
      - 'package.json'
      - 'package-lock.json'

# Skip CI with commit message
if: "!contains(github.event.head_commit.message, '[skip ci]')"
```

### 4. Parallel Jobs

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    # Runs in parallel

  test:
    runs-on: ubuntu-latest
    # Runs in parallel

  build:
    needs: [lint, test]  # Runs after both complete
    runs-on: ubuntu-latest
```

### 5. Matrix Testing

```yaml
strategy:
  matrix:
    node-version: [18.x, 20.x]
    os: [ubuntu-latest, windows-latest]
```

---

## Common Issues & Solutions

### Issue: npm ci fails with lockfile out of sync

**Solution:**
```yaml
- name: Verify lockfile
  run: npm ci --prefer-offline --no-audit
```

### Issue: Flaky tests in CI

**Solution:**
```yaml
- name: Run tests with retry
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    command: npm test
```

### Issue: Secrets not available in forked PRs

**Solution:**
```yaml
# Use pull_request_target carefully
on:
  pull_request_target:
    types: [opened, synchronize]

# Only run on trusted branches
if: github.event.pull_request.head.repo.full_name == github.repository
```

### Issue: Deployment takes too long

**Solution:**
```yaml
# Use deployment slots and health checks
- name: Deploy without downtime
  run: |
    pm2 reload app --update-env
    # pm2 gracefully reloads without downtime
```

---

## Testing in CI

### Unit Tests

```yaml
- name: Run unit tests
  run: npm test -- --selectProjects=unit
```

### Integration Tests

```yaml
- name: Run integration tests
  run: npm test -- --selectProjects=integration
  env:
    DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
```

### E2E Tests

```yaml
- name: Run E2E tests
  run: npm run test:e2e
  env:
    BASE_URL: http://localhost:3000
```

### Smoke Tests (Post-Deployment)

```yaml
- name: Smoke tests
  run: |
    curl --fail https://example.com/health
    curl --fail https://example.com/api/status
    npm run test:smoke
```

---

## Performance Optimization

### 1. Use Actions Cache

```yaml
- name: Cache node_modules
  uses: actions/cache@v3
  with:
    path: node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### 2. Skip Redundant Steps

```yaml
- name: Check if tests needed
  id: check
  run: |
    if git diff --name-only ${{ github.event.before }} ${{ github.sha }} | grep -E '\.test\.js$'; then
      echo "run_tests=true" >> $GITHUB_OUTPUT
    fi

- name: Run tests
  if: steps.check.outputs.run_tests == 'true'
  run: npm test
```

### 3. Optimize Docker Builds

```yaml
- name: Build Docker image with cache
  uses: docker/build-push-action@v4
  with:
    context: .
    push: true
    cache-from: type=registry,ref=myapp:latest
    cache-to: type=inline
```

---

## Security Considerations

### 1. Never Log Secrets

```yaml
# Bad - secret will appear in logs
- run: echo "API_KEY=${{ secrets.API_KEY }}"

# Good - use secret as environment variable
- run: npm run deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
```

### 2. Use Least Privilege

```yaml
permissions:
  contents: read      # Only read access
  pull-requests: write  # Write PRs only
```

### 3. Pin Action Versions

```yaml
# Bad - uses latest (security risk)
- uses: actions/checkout@main

# Good - pinned to specific version
- uses: actions/checkout@v4

# Better - pinned to commit SHA
- uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab
```

---

## Summary

**Essential Workflows**:
- ✅ CI (lint, test, type-check, build) on every push/PR
- ✅ Security audits daily
- ✅ Deploy to staging on develop branch
- ✅ Deploy to production on tags with approval
- ✅ Dependency updates weekly

**Best Practices**:
- Fail fast, test early
- Cache dependencies
- Parallel jobs where possible
- Matrix testing for compatibility
- Health checks and smoke tests
- Automated rollback on failure
- Notifications on important events

**Security**:
- Use GitHub Secrets for sensitive data
- Pin action versions
- Least privilege permissions
- Never log secrets
- Audit dependencies regularly

**Remember**: CI/CD should catch issues before they reach production. If your pipeline is green, you should be confident deploying.