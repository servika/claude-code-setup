---
description: Analyse infrastructure, licensing, and operational costs with breakdown and optimisation recommendations
model: sonnet
---

# /cost-analysis

Analyse system costs across three dimensions using parallel agents, producing a detailed breakdown with optimisation opportunities and projections.

## When to Use This Skill

- Budget planning and forecasting
- Cost optimisation initiatives
- Build vs buy evaluations
- Cloud migration cost assessment

## Usage

```
/cost-analysis <scope> [--period <timeframe>] [--budget <amount>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | infrastructure, licensing, operational, or all | Yes | — |
| period | Analysis period | No | Monthly |
| budget | Budget ceiling for comparison | No | — |

## Instructions

### Phase 1: Gather Cost Data

1. Scan project configuration for infrastructure indicators (Dockerfile, docker-compose, CI/CD workflows)
2. Review package.json for paid dependencies or services
3. Check for cloud provider configuration files
4. Identify external service integrations (payment, email, monitoring, etc.)

### Phase 2: Parallel Analysis (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Infrastructure Costs** (Haiku)
Task: Analyse compute and platform costs
- Compute (servers, containers, serverless functions)
- Storage (databases, file storage, backups)
- Networking (CDN, load balancers, data transfer)
- Caching (Redis, Memcached)
- Monitoring and logging platforms
Return: Infrastructure cost table with monthly/annual estimates

**Agent 2: Licensing & SaaS Costs** (Haiku)
Task: Analyse third-party service costs
- SaaS subscriptions (monitoring, error tracking, analytics)
- API costs (payment processors, email services, SMS)
- Development tools (IDE licenses, CI/CD minutes, code scanning)
- Per-seat costs (team collaboration tools)
Return: Licensing cost table with pricing tiers and scaling thresholds

**Agent 3: Operational Costs** (Sonnet)
Task: Analyse people and process costs
- Engineering time for maintenance and on-call
- Incident response costs (MTTR impact)
- Manual processes that could be automated
- Knowledge silos and bus factor risks
- Training and onboarding overhead
Return: Operational cost analysis with automation opportunities

### Phase 3: Synthesise

1. Aggregate costs across dimensions
2. Compare to budget if provided
3. Identify top 5 optimisation opportunities with estimated savings
4. Project costs at 6-month and 12-month horizons

## Output Format

```markdown
# Cost Analysis: [Scope]

## Summary
| Category | Monthly | Annual | % of Total |
|----------|---------|--------|------------|
| Infrastructure | $X | $X | X% |
| Licensing/SaaS | $X | $X | X% |
| Operational | $X | $X | X% |
| **Total** | **$X** | **$X** | **100%** |

## Optimisation Opportunities
| # | Opportunity | Est. Savings | Effort | Priority |
|---|------------|-------------|--------|----------|
| 1 | [Description] | $X/mo | Low | High |

## Projections
| Timeframe | Projected Cost | Growth Driver |
|-----------|---------------|---------------|
| Current | $X/mo | — |
| 6 months | $X/mo | [Driver] |
| 12 months | $X/mo | [Driver] |
```

## Examples

### Example 1: Full Cost Review
```
/cost-analysis all --period monthly --budget 5000
```

### Example 2: Infrastructure Focus
```
/cost-analysis infrastructure --period annual
```
