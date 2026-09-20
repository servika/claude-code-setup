# DevOps Guidelines (GitHub Actions + Docker)

## CI/CD Philosophy

- **Automate everything** - Manual steps introduce errors and delays
- **Fail fast** - Cheap checks first, expensive ones after
- **Least privilege** - Every job declares the narrowest `permissions:` it needs
- **Nothing unpinned, nothing unsigned** - Actions pinned to SHAs, images signed, provenance attested
- **No long-lived cloud credentials** - OIDC federation instead of stored keys
- **Environment parity** - Dev, staging and production differ in scale and secrets, not in shape
- **Infrastructure as Code** - Version control all configuration

## Stack

| Concern         | Choice                                              |
| --------------- | --------------------------------------------------- |
| Runtime         | Node.js 24 LTS (target `>=22`)                      |
| Package manager | Detect from the lockfile; pnpm via corepack         |
| CI              | GitHub Actions, reusable workflows                  |
| Containers      | Docker + BuildKit, `docker compose` v2              |
| Base image      | `node:24-alpine`, or distroless for the final stage |
| Supply chain    | SHA-pinned actions, SBOM, SLSA provenance, cosign   |
| Observability   | OpenTelemetry + pino, SLO burn-rate alerting        |

## Project Structure

```
project/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                  # Lint, test, build, image
│   │   ├── cd-staging.yml          # Deploy to staging
│   │   ├── cd-production.yml       # Deploy to production
│   │   └── _node-setup.yml         # Reusable workflow
│   └── dependabot.yml              # Keeps action SHAs and deps fresh
├── docker/
│   ├── Dockerfile                  # Multi-stage production image
│   └── Dockerfile.dev
├── compose.yaml                    # Local development (no `version:` key)
├── compose.prod.yaml
├── scripts/
│   ├── deploy.sh
│   └── canary-promote.sh
└── infra/
```

## Pipeline Shape

```mermaid
flowchart LR
    A[Push / PR] --> B[Lint + Typecheck]
    A --> C[Unit + Integration tests]
    A --> D[Supply-chain scan]
    B --> E[Build image]
    C --> E
    D --> E
    E --> F[SBOM + SLSA provenance + cosign sign]
    F --> G[Deploy staging]
    G --> H[Smoke + E2E]
    H --> I{Manual approval}
    I --> J[Canary 5%]
    J --> K{SLO burn OK?}
    K -->|Yes| L[Promote 100%]
    K -->|No| M[Automated rollback]
```

## Supply-Chain Hardening

### Pin Actions to Full Commit SHAs

Tags are mutable: in March 2025 an attacker rewrote every `tj-actions/changed-files` tag to point at
a commit that dumped CI memory - including secrets - into build logs (CVE-2025-30066), affecting
tens of thousands of repositories that had pinned only `@v35`.

```yaml
# Good: immutable SHA, human-readable version in a comment
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

# Bad: a tag can be repointed at any commit at any time
- uses: actions/checkout@v4
```

Dependabot updates the SHA and rewrites the comment, so pinning costs nothing on an ongoing basis.

> **The SHAs in this repository's examples are illustrative, not verified pins.** Never copy one
> into a real workflow. Resolve the current commit for the tag you want and pin that:
>
> ```bash
> gh api repos/actions/checkout/commits/v4.2.2 --jq .sha
> ```
>
> Then let Dependabot or Renovate keep it fresh. A stale or wrong SHA fails loudly; a copied one
> from documentation may quietly pin an action version nobody chose.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule: { interval: weekly }
  - package-ecosystem: npm
    directory: /
    schedule: { interval: weekly }
    groups:
      minor-and-patch:
        update-types: [minor, patch]
```

Renovate is an equivalent choice and handles SHA pinning plus grouping with more control.

### Least-Privilege Permissions

Set a read-only default at the workflow level and widen it per job:

```yaml
permissions: {} # deny everything by default

jobs:
  test:
    permissions:
      contents: read # only what this job needs
```

Never grant `write-all`. A job that does not touch the repo needs no `contents: write`. A job that
does not comment on PRs needs no `pull-requests: write`. Jobs handling untrusted input (forked PRs)
must never receive secrets - keep `pull_request_target` out of the repo unless you fully understand
the checkout implications.

### OIDC Instead of Stored Cloud Credentials

Exchange a short-lived GitHub-signed token for cloud credentials; nothing long-lived is stored.

```yaml
jobs:
  deploy:
    permissions:
      id-token: write # required to mint the OIDC token
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4.0.2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/gh-deploy-production
          aws-region: eu-west-1
```

Restrict the trust policy to the **exact workflow file and ref** - a `repo:org/app:*` subject lets
any branch or any workflow in the repo assume the role:

```json
{
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
      "token.actions.githubusercontent.com:sub": "repo:org/app:environment:production"
    }
  }
}
```

Scoping by `environment:production` combines with environment protection rules, so the role is
assumable only from a run that passed the required reviewers. Scoping by
`job_workflow_ref:org/app/.github/workflows/cd-production.yml@refs/heads/main` pins it to one file.

### Provenance, SBOM and Signing

```yaml
attest:
  needs: [docker]
  permissions:
    id-token: write
    attestations: write
    packages: write
    contents: read
  steps:
    - name: Attest build provenance (SLSA)
      uses: actions/attest-build-provenance@977bb373b6b3a2a6f7b1f0f0e1e6a9b4e60d6f0e # v3.0.0
      with:
        subject-name: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        subject-digest: ${{ needs.docker.outputs.digest }}
        push-to-registry: true

    - name: Generate SBOM
      uses: anchore/sbom-action@f325610c9f50a54015d37c8d16cb3b0e2c8f4de0 # v0.17.0
      with:
        image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ needs.docker.outputs.digest }}
        format: spdx-json
        output-file: sbom.spdx.json

    - uses: sigstore/cosign-installer@4959ce089c160fddf62f7b42464195ba1a56d382 # v3.6.0
    - name: Sign image (keyless, Sigstore)
      run: cosign sign --yes ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ needs.docker.outputs.digest }}
    - name: Attach SBOM attestation
      run: |
        cosign attest --yes --predicate sbom.spdx.json --type spdxjson \
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ needs.docker.outputs.digest }}
```

Keyless signing uses the workflow's OIDC identity and the public Rekor transparency log - no private
key to store or rotate. Verify at deploy time, by digest, and refuse to run an unsigned image:

```bash
cosign verify "$IMAGE@$DIGEST" \
  --certificate-identity-regexp '^https://github.com/org/app/\.github/workflows/ci\.yml@refs/heads/main$' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

### Dependency Scanning

```yaml
supply-chain:
  permissions:
    contents: read
    security-events: write
  steps:
    - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
    - name: OSV scanner
      uses: google/osv-scanner-action@6fc714450122bda9d00e4ad5d639ad6a39eedb1f # v1.9.0
      with:
        scan-args: |-
          --lockfile=./pnpm-lock.yaml
          --format=sarif
          --output=results.sarif
    - uses: github/codeql-action/upload-sarif@eb055d739abdc2e8de2e5f4ba1a8b246daa779aa # v3.26.6
      with: { sarif_file: results.sarif }
    - run: pnpm audit --audit-level=high
```

Install with `--frozen-lockfile` (pnpm) / `npm ci` so CI can never resolve a different tree than the
committed lockfile, and prefer `--ignore-scripts` where the build tolerates it - postinstall scripts
are the main npm supply-chain execution vector.

## GitHub Actions Workflows

### CI Pipeline (ci.yml)

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions: {}

concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint & typecheck
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Enable corepack
        run: corepack enable # activates the packageManager field's pnpm/yarn version
      - uses: actions/setup-node@0a44ba7841725637a19e28fa30b79a866c81b0a6 # v4.0.4
        with:
          node-version: 24
          cache: pnpm # use npm/yarn here if that is the committed lockfile
      - run: pnpm install --frozen-lockfile
      - run: pnpm run lint
      - run: pnpm run typecheck

  test:
    name: Test (Node ${{ matrix.node }})
    runs-on: ubuntu-latest
    permissions:
      contents: read
    strategy:
      fail-fast: false
      matrix:
        node: [22, 24] # 24 = Active LTS, 22 = Maintenance LTS floor
    services:
      postgres:
        image: postgres:18-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready --health-interval 10s
          --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - run: corepack enable
      - uses: actions/setup-node@0a44ba7841725637a19e28fa30b79a866c81b0a6 # v4.0.4
        with: { node-version: "${{ matrix.node }}", cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm run test -- --coverage
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          JWT_SECRET: test-secret-minimum-32-characters-long
      - uses: actions/upload-artifact@50769540e7f4bd5e21e526ee35c689e35e0d6874 # v4.4.0
        if: ${{ !cancelled() && matrix.node == 24 }}
        with: { name: coverage, path: coverage/, retention-days: 7 }

  docker:
    name: Build & push image
    runs-on: ubuntu-latest
    needs: [lint, test]
    if: github.event_name == 'push'
    permissions:
      contents: read
      packages: write
      id-token: write
    outputs:
      digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: docker/setup-buildx-action@988b5a0280414f521da01fcc63a27aeeb4b104db # v3.6.1
      - uses: docker/login-action@9780b0c442fbb1117ed29e0efdff1e18412f7567 # v3.3.0
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@8e5442c4ef9f78752691e2d8f8d19755c6f78e81 # v5.5.1
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,format=long
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}
      - id: build
        uses: docker/build-push-action@5cd11c3a4ced054e52742c5fd54dca954e0edd85 # v6.7.0
        with:
          context: .
          file: docker/Dockerfile
          push: true
          provenance: mode=max
          sbom: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Reusable Workflow

Extract repeated setup so a change lands in one place. Called workflows must declare their inputs
and secrets explicitly - nothing is inherited implicitly.

```yaml
# .github/workflows/_node-setup.yml
on:
  workflow_call:
    inputs:
      node-version: { type: string, default: "24" }
      command: { type: string, required: true }
    secrets:
      DATABASE_URL: { required: false }

permissions: {}

jobs:
  run:
    runs-on: ubuntu-latest
    permissions: { contents: read }
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - run: corepack enable
      - uses: actions/setup-node@0a44ba7841725637a19e28fa30b79a866c81b0a6 # v4.0.4
        with: { node-version: "${{ inputs.node-version }}", cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: ${{ inputs.command }}
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

```yaml
jobs:
  lint:
    uses: ./.github/workflows/_node-setup.yml
    with: { command: pnpm run lint }
```

### Deploy to Staging (cd-staging.yml)

```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]
  workflow_dispatch:

permissions: {}

env:
  IMAGE: ghcr.io/${{ github.repository }}

concurrency:
  group: deploy-staging # never two deploys at once
  cancel-in-progress: false # let an in-flight deploy finish

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: ${{ vars.STAGING_URL }}
    permissions:
      contents: read
      id-token: write
      packages: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4.0.2
        with:
          role-to-assume: ${{ vars.STAGING_DEPLOY_ROLE }}
          aws-region: ${{ vars.AWS_REGION }}

      - uses: docker/login-action@9780b0c442fbb1117ed29e0efdff1e18412f7567 # v3.3.0
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Resolve the digest CI pushed for this commit
        # ci.yml tags every build `sha-<full sha>` (type=sha,format=long)
        run: |
          DIGEST=$(docker buildx imagetools inspect "${IMAGE}:sha-${{ github.sha }}" \
            --format '{{ .Manifest.Digest }}')
          echo "DIGEST=$DIGEST" >> "$GITHUB_ENV"

      - name: Verify image signature before deploying
        run: |
          cosign verify "${IMAGE}@${DIGEST}" \
            --certificate-identity-regexp '^https://github.com/${{ github.repository }}/' \
            --certificate-oidc-issuer https://token.actions.githubusercontent.com

      - name: Deploy
        run: ./scripts/deploy.sh staging "${DIGEST}"

      - name: Wait for readiness
        run: |
          for i in $(seq 1 30); do
            if curl -fsS --max-time 5 "${{ vars.STAGING_URL }}/health/ready"; then
              echo "ready"; exit 0
            fi
            echo "waiting ($i/30)"; sleep 10
          done
          exit 1

      - name: Smoke tests
        run: pnpm exec playwright test --grep @smoke
        env:
          BASE_URL: ${{ vars.STAGING_URL }}
```

### Deploy to Production (cd-production.yml)

```yaml
name: Deploy to Production

on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      digest:
        description: "Image digest to deploy (sha256:...)"
        required: true

permissions: {}

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production # required reviewers + wait timer + branch rule live here
      url: ${{ vars.PROD_URL }}
    permissions:
      contents: read
      id-token: write
      deployments: write
      packages: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4.0.2
        with:
          role-to-assume: ${{ vars.PROD_DEPLOY_ROLE }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Verify provenance attestation
        run: gh attestation verify "oci://${IMAGE}@${DIGEST}" --repo ${{ github.repository }}
        env:
          GH_TOKEN: ${{ github.token }}

      - name: Canary 5%
        run: ./scripts/deploy.sh production "${DIGEST}" --canary 5

      - name: Watch error budget for 10 minutes
        run: ./scripts/canary-promote.sh --window 10m --max-burn 2

      - name: Promote to 100%
        run: ./scripts/deploy.sh production "${DIGEST}" --promote

      - name: Rollback on failure
        if: failure()
        run: ./scripts/deploy.sh production --rollback
```

**Environment protection rules** (configured in repo settings, not YAML) give you required
reviewers, a wait timer, deployment branch restrictions, and environment-scoped secrets - and they
gate the OIDC subject, so an unapproved run cannot even obtain cloud credentials.

## Docker

### Production Dockerfile

```dockerfile
# syntax=docker/dockerfile:1.10
FROM node:24-alpine AS deps
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
# Cache mount: the store survives between builds and is NOT baked into a layer
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm config set store-dir /pnpm/store && \
    pnpm install --frozen-lockfile --ignore-scripts

FROM node:24-alpine AS build
WORKDIR /app
RUN corepack enable
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Build secret: available only during this RUN, never in a layer or in `docker history`
RUN --mount=type=secret,id=npm_token,env=NPM_TOKEN \
    --mount=type=cache,target=/app/.cache \
    pnpm run build
RUN pnpm prune --prod

FROM node:24-alpine AS production
RUN addgroup -g 1001 -S nodejs && adduser -S -u 1001 -G nodejs nodejs
WORKDIR /app

COPY --from=build --chown=nodejs:nodejs /app/dist ./dist
COPY --from=build --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nodejs:nodejs /app/package.json ./

USER nodejs
ENV NODE_ENV=production PORT=3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "dist/server.js"]
```

Build with the secret mounted - never with `--build-arg`:

```bash
# Good: the value never enters a layer
docker build --secret id=npm_token,env=NPM_TOKEN -f docker/Dockerfile .

# NEVER: build args are visible in `docker history` and in image metadata forever
docker build --build-arg NPM_TOKEN=... .
```

**Cache mounts** (`--mount=type=cache`) keep the package store, build cache and compiler cache
outside the image: rebuilds are fast and the final image stays small, unlike copying a cache
directory into a layer.

**Distroless** for the final stage when you want the smallest attack surface (no shell, no package
manager). The trade-off: no shell means no `docker exec sh` debugging, and `HEALTHCHECK` must be a
`node -e` invocation as above rather than `curl`/`wget`.

```dockerfile
FROM gcr.io/distroless/nodejs24-debian12 AS production
WORKDIR /app
COPY --from=build --chown=nonroot:nonroot /app/dist ./dist
COPY --from=build --chown=nonroot:nonroot /app/node_modules ./node_modules
USER nonroot
CMD ["dist/server.js"]
```

Also: `.dockerignore` covering `node_modules`, `.git`, `.env*`, `coverage`; pin the base image by
digest in production; run `docker scout cves` or Trivy on the built image in CI.

### Compose (Local Development)

The `version:` key is obsolete - Compose v2 ignores it and warns. Do not include it.

```yaml
# compose.yaml
name: app

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile.dev
    ports: ["3000:3000"]
    volumes:
      - .:/app
      - /app/node_modules # keep the container's install
    environment:
      NODE_ENV: development
      DATABASE_URL: postgresql://postgres:postgres@db:5432/app_dev
      JWT_SECRET: dev-secret-minimum-32-characters-long
      REDIS_URL: redis://redis:6379
      OTEL_EXPORTER_OTLP_ENDPOINT: http://otel-collector:4318
    depends_on:
      db: { condition: service_healthy }
      redis: { condition: service_started }

  db:
    image: postgres:18-alpine
    ports: ["5432:5432"]
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
    volumes: [redis_data:/data]

volumes:
  postgres_data:
  redis_data:
```

Always `docker compose` (v2, a space) - `docker-compose` is the unsupported Python v1.

```bash
docker compose up -d --wait      # blocks until healthchecks pass
docker compose logs -f app
docker compose down -v
```

### Compose (Production)

```yaml
# compose.prod.yaml
name: app

services:
  app:
    image: ghcr.io/org/app@sha256:${IMAGE_DIGEST} # deploy by digest, never by tag
    restart: unless-stopped
    ports: ["3000:3000"]
    environment:
      NODE_ENV: production
      DATABASE_URL: ${DATABASE_URL}
      JWT_SECRET: ${JWT_SECRET}
      OTEL_EXPORTER_OTLP_ENDPOINT: ${OTEL_EXPORTER_OTLP_ENDPOINT}
      OTEL_SERVICE_NAME: app
    read_only: true
    tmpfs: ["/tmp"]
    security_opt: ["no-new-privileges:true"]
    cap_drop: [ALL]
    healthcheck:
      test:
        [
          "CMD",
          "node",
          "-e",
          "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))",
        ]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 15s
    deploy:
      replicas: 3
      resources:
        limits: { cpus: "1", memory: 512M }
        reservations: { cpus: "0.25", memory: 128M }
      # NOTE: `update_config`, `rollback_config` and `failure_action` are **Swarm-only**.
      # `docker compose up` parses and then silently ignores them - it does not do rolling
      # updates or automatic rollback. On Swarm/Kubernetes/ECS use that orchestrator's rollout
      # primitive; on plain Compose use blue-green - see "Deployment Strategies" below.
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }
```

Without `logging` options a container's JSON log file grows until it fills the disk - this is the
single most common self-inflicted production outage on a Docker host.

## Environment & Secrets

```bash
# .env.example - committed; real .env is gitignored
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/app_dev
JWT_SECRET=change-this-to-at-least-32-characters
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
LOG_LEVEL=info
```

| Secret type         | Storage                                 | Access                   |
| ------------------- | --------------------------------------- | ------------------------ |
| Development         | `.env` (gitignored)                     | Local only               |
| CI, non-cloud       | GitHub environment secrets              | Approved runs only       |
| Cloud credentials   | **None - OIDC federation**              | Minted per run, minutes  |
| Runtime app secrets | Cloud secret manager, injected at start | The workload's role only |
| Image build secrets | `--mount=type=secret`                   | One `RUN` step           |

Secrets belong to _environments_, not to the repository, so `production` values are unreachable from
a `develop` run. Validate every required variable at startup (Zod) and crash immediately if one is
missing - a half-configured process that starts is worse than one that does not.

## Deployment Strategies

```mermaid
flowchart TD
    A{Change risk} -->|Low, backward compatible| B[Rolling]
    A -->|Needs instant rollback| C[Blue-green]
    A -->|High risk / user-visible| D[Canary]
    B --> E[start-first, one replica at a time]
    C --> F[Deploy idle colour, switch router, keep old warm]
    D --> G[5% → watch SLO burn → 25% → 100%]
    G --> H{Burn rate > threshold?}
    H -->|Yes| I[Automated rollback]
    H -->|No| J[Promote]
```

### Rolling (default)

One replica at a time with `order: start-first`, so capacity never dips - but only an **orchestrator**
delivers this. On Swarm, add the `update_config` / `rollback_config` keys to the `deploy:` block of
`compose.prod.yaml` (they take effect only there) and drive rollout and rollback explicitly:

```yaml
deploy:
  update_config:
    { parallelism: 1, delay: 15s, order: start-first, failure_action: rollback }
  rollback_config: { parallelism: 1, delay: 10s }
```

```bash
docker stack deploy -c compose.prod.yaml app          # Swarm honours update_config/rollback_config
docker service update --image "ghcr.io/org/app@${DIGEST}" app_app
docker service rollback app_app                       # if the rollout misbehaves
```

Kubernetes (`kubectl rollout status/undo deployment/app`) and ECS rolling deployments give the same
guarantee.

Plain `docker compose up -d` has **no rolling primitive**: it recreates the service's containers, so
a single-host Compose deploy takes a short outage even with `replicas: 3`. Where that is
unacceptable, do not fake it with `deploy.update_config` - run the blue-green script below behind a
reverse proxy, which is the zero-downtime path Compose actually supports.

Either way, rolling requires backward-compatible schema and API changes - old and new versions serve
traffic simultaneously (this is exactly what expand/contract migrations buy you).

### Blue-Green

```bash
#!/usr/bin/env bash
# scripts/blue-green.sh - deploy the idle colour, then switch the router
set -euo pipefail

CURRENT=$(cat /opt/app/.active 2>/dev/null || echo blue)
NEW=$([ "$CURRENT" = blue ] && echo green || echo blue)

docker compose -p "app-$NEW" -f "compose.$NEW.yaml" up -d --wait

for i in $(seq 1 30); do
  curl -fsS "http://localhost:${PORT_NEW}/health/ready" && break
  [ "$i" -eq 30 ] && { docker compose -p "app-$NEW" down; exit 1; }
  sleep 5
done

./scripts/switch-router.sh "$NEW"
echo "$NEW" > /opt/app/.active
sleep 300                                  # keep the old colour warm for instant rollback
docker compose -p "app-$CURRENT" down
```

Rollback is a router switch back - seconds, no rebuild. Cost: double the infrastructure during the
overlap, and a shared database that both colours must tolerate.

### Canary with Automated Rollback

Route a small slice of traffic to the new version and let the **error budget burn rate** decide.
Burn rate = the rate at which you are consuming the error budget relative to the SLO window: at
burn rate 1 you exhaust exactly the budget over the window; at 14.4 you burn 2% of a 30-day budget
in one hour.

```bash
#!/usr/bin/env bash
# scripts/canary-promote.sh - abort if the canary burns the budget too fast
set -euo pipefail
WINDOW=${WINDOW:-10m}; MAX_BURN=${MAX_BURN:-2}; SLO=0.999

QUERY="(
  sum(rate(http_requests_total{job=\"app\",deploy=\"canary\",status=~\"5..\"}[$WINDOW]))
  / sum(rate(http_requests_total{job=\"app\",deploy=\"canary\"}[$WINDOW]))
) / (1 - $SLO)"

for _ in $(seq 1 10); do
  BURN=$(curl -fsS --get "$PROM_URL/api/v1/query" --data-urlencode "query=$QUERY" \
    | jq -r '.data.result[0].value[1] // "0"')
  echo "burn rate: $BURN (max $MAX_BURN)"
  if (( $(echo "$BURN > $MAX_BURN" | bc -l) )); then
    echo "error budget burning too fast - rolling back"
    ./scripts/deploy.sh production --rollback
    exit 1
  fi
  sleep 60
done
```

Also abort on latency regression and on a rise in a key business metric's failure rate - availability
alone misses "it returns 200 with the wrong body".

## Health Checks

Liveness and readiness are different questions. Liveness = "is this process wedged, should the
orchestrator kill it?" Readiness = "should this instance receive traffic right now?" A dependency
outage must fail readiness, never liveness - otherwise a database blip triggers a restart storm.

```typescript
// src/routes/health.routes.ts
import { Router } from "express";
import { pool } from "../db/index.js";
import { redis } from "../cache/index.js";

const router = Router();
let shuttingDown = false;

/** Liveness: the event loop is responsive. No dependency checks. */
router.get("/health", (_req, res) => {
  res.status(shuttingDown ? 503 : 200).json({
    status: shuttingDown ? "shutting_down" : "ok",
    version: process.env.APP_VERSION,
  });
});

/** Readiness: every hard dependency answers within budget. */
router.get("/health/ready", async (_req, res) => {
  const checks = Object.fromEntries(
    await Promise.all([
      probe("database", () => pool.query("SELECT 1")),
      probe("redis", () => redis.ping()),
    ]),
  );
  const healthy =
    !shuttingDown && Object.values(checks).every((c) => c.status === "ok");
  res
    .status(healthy ? 200 : 503)
    .json({ status: healthy ? "ok" : "degraded", checks });
});

/** Runs one dependency probe with a hard timeout so readiness never hangs. */
async function probe(
  name: string,
  fn: () => Promise<unknown>,
): Promise<[string, { status: string; error?: string }]> {
  try {
    await Promise.race([
      fn(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error("timeout")), 1_000),
      ),
    ]);
    return [name, { status: "ok" }];
  } catch (error) {
    return [name, { status: "error", error: (error as Error).message }];
  }
}

/** Fails readiness first, drains in-flight requests, then exits. */
export function beginShutdown(): void {
  shuttingDown = true;
}

export default router;
```

Graceful shutdown order on `SIGTERM`: flip readiness to 503 → wait for the load balancer to
deregister (typically 5-15s) → stop accepting connections → finish in-flight requests → close the
pool → exit. Skipping the wait drops requests that were already routed to the instance.

## Observability

### OpenTelemetry

One SDK for traces, metrics and logs; export OTLP to a collector, and let the collector fan out to
whatever backend you use. Auto-instrumentation covers HTTP, Express and `pg` without code changes.

```typescript
// src/otel.ts - imported first, before any instrumented module
import { NodeSDK } from "@opentelemetry/sdk-node";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter(),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter(),
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      "@opentelemetry/instrumentation-fs": { enabled: false }, // too noisy to be useful
    }),
  ],
});

sdk.start();
process.on("SIGTERM", () => void sdk.shutdown());
```

```bash
OTEL_SERVICE_NAME=app
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1          # sample 10%; tail-sample errors at the collector
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=${APP_VERSION}
```

Context propagates via the W3C `traceparent` header, so a trace spans frontend → API → database
without manual plumbing. Sample head-based at 10% but configure the collector to tail-sample every
errored or slow trace - those are the ones you will actually open.

### Structured Logging with pino

```typescript
// src/utils/logger.ts
import pino from "pino";
import { trace } from "@opentelemetry/api";

export const logger = pino({
  level: process.env.LOG_LEVEL ?? "info",
  redact: {
    paths: [
      "req.headers.authorization",
      "req.headers.cookie",
      "*.password",
      "*.passwordHash",
      "*.token",
      "*.refreshToken",
      "creditCard",
    ],
    censor: "[REDACTED]",
  },
  // Correlate every line with its trace
  mixin() {
    const span = trace.getActiveSpan()?.spanContext();
    return span ? { trace_id: span.traceId, span_id: span.spanId } : {};
  },
  formatters: { level: (label) => ({ level: label }) },
  // Pretty output in dev only; production emits newline-delimited JSON to stdout
  transport:
    process.env.NODE_ENV === "development"
      ? { target: "pino-pretty" }
      : undefined,
});
```

Log JSON to stdout and let the platform ship it - never write log files from the application, never
`console.log`. `redact` runs on the serializer, so a secret cannot leak through a nested field
someone forgot about.

### SLO-Based Alerting

Threshold alerts ("CPU > 90%") page for things that may not affect anyone and stay silent for things
that do. Define SLIs and SLOs, then alert on **burn rate** - how fast you are consuming the error
budget - using multiple windows so you catch both fast and slow burns without flapping.

| SLI                    | SLO (30-day)            |
| ---------------------- | ----------------------- |
| Availability (non-5xx) | 99.9%                   |
| Latency (p95 read)     | < 300ms for 99% of reqs |
| Latency (p95 write)    | < 500ms for 99% of reqs |
| Job success rate       | 99.5%                   |

| Severity | Burn rate | Long window | Short window | Budget consumed | Action            |
| -------- | --------- | ----------- | ------------ | --------------- | ----------------- |
| Page     | 14.4x     | 1h          | 5m           | 2% in 1h        | Wake someone      |
| Page     | 6x        | 6h          | 30m          | 5% in 6h        | Wake someone      |
| Ticket   | 3x        | 1d          | 2h           | 10% in 1d       | Next business day |
| Ticket   | 1x        | 3d          | 6h           | 10% in 3d       | Backlog           |

The short window prevents a long-resolved incident from holding the alert open; both windows must
breach for the alert to fire.

```yaml
# Prometheus: fast-burn page
- alert: ErrorBudgetFastBurn
  expr: |
    (
      sum(rate(http_requests_total{job="app",status=~"5.."}[1h]))
      / sum(rate(http_requests_total{job="app"}[1h]))
    ) > (14.4 * 0.001)
    and
    (
      sum(rate(http_requests_total{job="app",status=~"5.."}[5m]))
      / sum(rate(http_requests_total{job="app"}[5m]))
    ) > (14.4 * 0.001)
  for: 2m
  labels: { severity: page }
  annotations:
    summary: "Burning the 99.9% availability budget 14.4x too fast"
    runbook: https://runbooks.example.com/app/error-budget
```

Keep raw thresholds as a **starting point** for resource saturation - they are diagnostic signals
that belong on a dashboard, and at most a ticket, not a page:

| Resource metric | Watch         | Investigate   |
| --------------- | ------------- | ------------- |
| CPU usage       | > 70%         | > 90%         |
| Memory usage    | > 80%         | > 95%         |
| Disk usage      | > 70%         | > 85%         |
| DB connections  | > 70% of pool | > 90%         |
| Queue depth     | rising 5m     | > SLA backlog |

Every alert links a runbook. An alert with no documented action is noise and should be deleted.

## Checklists

### Workflow Review

- [ ] Every action pinned to a full commit SHA with a version comment
- [ ] `permissions: {}` at workflow level, widened per job
- [ ] `concurrency` group set on deploy workflows (`cancel-in-progress: false`)
- [ ] Cloud auth via OIDC; trust policy scoped to the exact environment/workflow ref
- [ ] No long-lived cloud credentials in secrets
- [ ] Secrets attached to environments, not the repository
- [ ] `npm ci` / `--frozen-lockfile`; lockfile committed
- [ ] `osv-scanner` and `npm audit` run; SARIF uploaded
- [ ] SBOM generated, provenance attested, image signed with cosign
- [ ] Node 24 LTS in the matrix; package manager matches the lockfile
- [ ] Shared setup extracted into a reusable workflow

### Container Review

- [ ] No `version:` key in any compose file
- [ ] `docker compose` (v2) spelling everywhere
- [ ] Multi-stage build; production stage has no build toolchain
- [ ] BuildKit cache mounts for the package store and build cache
- [ ] Build secrets via `--mount=type=secret`, never `--build-arg`
- [ ] Runs as a non-root user; `cap_drop: [ALL]`, `no-new-privileges`
- [ ] `node:24-alpine` or distroless base, pinned by digest in production
- [ ] `HEALTHCHECK` defined and exercised
- [ ] Resource limits and reservations set
- [ ] Log rotation configured (`max-size`, `max-file`)
- [ ] `.dockerignore` excludes `node_modules`, `.git`, `.env*`
- [ ] Image scanned for CVEs in CI

### Before Deployment

- [ ] CI green; image signature and provenance verified by digest
- [ ] Database migrations are expand/contract safe for the running version
- [ ] Environment variables validated at startup
- [ ] `/health` and `/health/ready` correct and distinct
- [ ] Graceful shutdown drains before exit
- [ ] Rollback path tested, not just documented
- [ ] Deployment strategy matches the change's risk

### After Deployment

- [ ] Readiness passing on every replica
- [ ] Error budget burn rate flat
- [ ] Latency p95/p99 within SLO
- [ ] Traces show no new error spans or dependency regressions
- [ ] Logs free of new error patterns
- [ ] Key user flows verified
- [ ] Deployment recorded and annotated on dashboards
