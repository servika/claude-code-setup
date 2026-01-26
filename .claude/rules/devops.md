# DevOps Guidelines (GitHub Actions + Docker)

## CI/CD Philosophy

- **Automate everything** - Manual steps introduce errors and delays
- **Fail fast** - Catch issues early in the pipeline
- **Environment parity** - Dev, staging, and production should be as similar as possible
- **Infrastructure as Code** - Version control all configuration

## Project Structure

```
project/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Continuous Integration
│       ├── cd-staging.yml      # Deploy to staging
│       ├── cd-production.yml   # Deploy to production
│       └── pr-checks.yml       # Pull request validation
├── docker/
│   ├── Dockerfile              # Production image
│   ├── Dockerfile.dev          # Development image
│   └── docker-compose.yml      # Local development
├── scripts/
│   ├── deploy.sh               # Deployment script
│   ├── healthcheck.sh          # Health verification
│   └── seed-db.sh              # Database seeding
└── infra/                      # Infrastructure config (optional)
    └── terraform/
```

## GitHub Actions Workflows

### CI Pipeline (ci.yml)

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test -- --coverage
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          JWT_SECRET: test-secret-minimum-32-characters-long

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: true

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
          retention-days: 7

  docker:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: [lint, test]
    if: github.event_name == 'push'
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix=
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Deployment Pipeline (cd-staging.yml)

```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  deploy:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    concurrency:
      group: staging-deployment
      cancel-in-progress: false

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to staging
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/app
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop
            docker compose -f docker-compose.staging.yml up -d
            docker system prune -f

      - name: Health check
        run: |
          for i in {1..30}; do
            if curl -sf ${{ secrets.STAGING_URL }}/health; then
              echo "Health check passed"
              exit 0
            fi
            echo "Waiting for service... ($i/30)"
            sleep 10
          done
          echo "Health check failed"
          exit 1

      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Staging deployment failed for ${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Production Deployment (cd-production.yml)

```yaml
name: Deploy to Production

on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy (e.g., v1.2.3)'
        required: true

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    environment: production
    concurrency:
      group: production-deployment
      cancel-in-progress: false

    steps:
      - uses: actions/checkout@v4

      - name: Determine version
        id: version
        run: |
          if [ "${{ github.event_name }}" == "release" ]; then
            echo "tag=${{ github.event.release.tag_name }}" >> $GITHUB_OUTPUT
          else
            echo "tag=${{ github.event.inputs.version }}" >> $GITHUB_OUTPUT
          fi

      - name: Deploy to production
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /opt/app
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.version.outputs.tag }}
            docker compose -f docker-compose.prod.yml up -d --no-deps app
            docker system prune -f

      - name: Health check
        run: |
          for i in {1..30}; do
            if curl -sf ${{ secrets.PROD_URL }}/health; then
              echo "Health check passed"
              exit 0
            fi
            sleep 10
          done
          exit 1

      - name: Create deployment record
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.repos.createDeployment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              ref: '${{ steps.version.outputs.tag }}',
              environment: 'production',
              auto_merge: false,
              required_contexts: []
            })
```

## Docker Configuration

### Production Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --only=production=false

# Copy source and build
COPY . .
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# Production stage
FROM node:20-alpine AS production

# Security: run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy only necessary files
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

USER nodejs

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/server.js"]
```

### Development Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source (will be overwritten by volume mount)
COPY . .

ENV NODE_ENV=development
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

### Docker Compose (Local Development)

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app_dev
      - JWT_SECRET=dev-secret-minimum-32-characters-long
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # Optional: Database admin UI
  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db

volumes:
  postgres_data:
  redis_data:
```

### Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    image: ghcr.io/org/app:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=${REDIS_URL}
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Environment Management

### Environment Variables

```bash
# .env.example - Template for developers
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/app_dev

# Authentication
JWT_SECRET=change-this-to-at-least-32-characters
JWT_EXPIRES_IN=1h

# External Services
REDIS_URL=redis://localhost:6379
```

### Secrets Management

| Secret Type | Storage | Access |
|------------|---------|--------|
| Development | `.env` (gitignored) | Local only |
| CI/CD | GitHub Secrets | Workflow only |
| Production | Environment variables | Server only |

**GitHub Secrets to Configure:**

```
# Repository Secrets
CODECOV_TOKEN          # Code coverage
SLACK_WEBHOOK          # Notifications

# Environment: staging
STAGING_HOST           # Server hostname
STAGING_USER           # SSH username
STAGING_SSH_KEY        # Private SSH key
STAGING_URL            # Health check URL
DATABASE_URL           # Database connection

# Environment: production
PROD_HOST
PROD_USER
PROD_SSH_KEY
PROD_URL
DATABASE_URL
JWT_SECRET
```

## Deployment Strategies

### Rolling Deployment (Default)

```yaml
# docker-compose.prod.yml
services:
  app:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 10s
```

### Blue-Green Deployment

```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

CURRENT=$(docker compose ps --format json | jq -r '.Name' | grep -E 'blue|green' | head -1)

if [[ $CURRENT == *"blue"* ]]; then
  NEW="green"
  OLD="blue"
else
  NEW="blue"
  OLD="green"
fi

# Start new version
docker compose -f docker-compose.$NEW.yml up -d

# Wait for health
sleep 30

# Switch traffic (update nginx/load balancer)
sed -i "s/$OLD/$NEW/g" /etc/nginx/conf.d/app.conf
nginx -s reload

# Stop old version
docker compose -f docker-compose.$OLD.yml down
```

## Health Checks

### Application Health Endpoint

```javascript
// src/routes/health.js
import { Router } from 'express';

const router = Router();

/**
 * Basic health check
 */
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

/**
 * Detailed readiness check
 */
router.get('/health/ready', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
  };

  const healthy = Object.values(checks).every(c => c.status === 'ok');

  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'ok' : 'degraded',
    timestamp: new Date().toISOString(),
    checks,
  });
});

async function checkDatabase() {
  try {
    await db.query('SELECT 1');
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

async function checkRedis() {
  try {
    await redis.ping();
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

export default router;
```

## Monitoring & Logging

### Structured Logging

```javascript
// Use JSON format in production for log aggregation
const logFormat = process.env.NODE_ENV === 'production'
  ? JSON.stringify({ level, message, timestamp, ...meta })
  : `[${timestamp}] ${level}: ${message}`;
```

### Key Metrics to Monitor

| Metric | Threshold | Alert |
|--------|-----------|-------|
| Response time (p95) | < 500ms | > 1s |
| Error rate | < 1% | > 5% |
| CPU usage | < 70% | > 90% |
| Memory usage | < 80% | > 95% |
| Disk usage | < 70% | > 85% |

## Checklist

### Before Deployment

- [ ] All tests passing in CI
- [ ] Docker image built successfully
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Health endpoints responding
- [ ] Rollback plan documented

### After Deployment

- [ ] Health check passing
- [ ] Logs showing normal operation
- [ ] No error spikes in monitoring
- [ ] Key user flows verified
- [ ] Performance within thresholds
