---
description: Generate comprehensive architecture governance reports across five analysis dimensions
model: sonnet
---

# /architecture-report

Generate a full architecture governance report using five parallel agents to analyse system inventory, integrations, decisions, risks, and costs.

## When to Use This Skill

- Quarterly architecture reviews
- Pre-audit preparation
- New team member onboarding documentation
- Architecture health checks before major initiatives

## Usage

```
/architecture-report [--scope full|component] [--period <timeframe>] [--focus <area>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scope | Report scope | No | full |
| period | Time period for trends | No | Last quarter |
| focus | Specific area to emphasise | No | All dimensions |

## Instructions

### Phase 1: Prepare Context

1. Identify project root and scan for key configuration files (package.json, docker-compose, CI workflows)
2. Locate existing architecture documentation (ADRs, diagrams, README files)
3. Review recent git history for architectural changes
4. Prepare scoped context for each analysis agent

### Phase 2: Parallel Analysis (Agent Team)

Launch 5 agents using the Task tool:

**Agent 1: System Inventory** (Haiku)
Task: Catalogue all system components
- Scan for services, packages, and modules
- Document tech stack versions (Node.js, React, PostgreSQL, etc.)
- List external dependencies and their versions
- Identify infrastructure components (Docker, CI/CD, cloud services)
Return: Component inventory table with versions and ownership

**Agent 2: Integration Analysis** (Sonnet)
Task: Map integration points and patterns
- Identify API contracts (REST endpoints, request/response schemas)
- Map data flows between frontend, backend, and database
- Assess coupling levels between components
- Document integration patterns (sync/async, event-driven, direct)
Return: Integration map with coupling assessment

**Agent 3: Decision Audit** (Haiku)
Task: Review architectural decisions
- Find and catalogue all ADRs
- Identify decisions that are pending or overdue for review
- Check for undocumented decisions (inferred from code patterns)
- Flag stale decisions that may need revisiting
Return: Decision register with status and staleness indicators

**Agent 4: Risk Register** (Sonnet)
Task: Identify architectural risks
- Technical debt hotspots (complexity, test coverage gaps)
- Security concerns (outdated deps, missing validation, exposed endpoints)
- Scalability bottlenecks (database queries, single points of failure)
- Operational risks (monitoring gaps, missing runbooks, manual processes)
Return: Risk register with severity, likelihood, and mitigation suggestions

**Agent 5: Financial Overview** (Haiku)
Task: Summarise cost profile
- Infrastructure costs (hosting, databases, CDN, monitoring)
- Third-party service costs (APIs, SaaS tools, licensing)
- Development cost indicators (team size, velocity trends)
- Cost optimisation opportunities
Return: Cost summary with trends and recommendations

### Phase 3: Synthesise

1. Merge all agent outputs into unified report
2. Generate executive summary with RAG health indicators
3. Create prioritised recommendation list
4. Build action items with owners and timelines

## Output Format

```markdown
# Architecture Report: [Project Name]
**Period**: [Timeframe] | **Generated**: [Date]

## Executive Summary
[3-5 sentence overview with overall health assessment]

## Health Dashboard

| Dimension | Status | Trend | Key Concern |
|-----------|--------|-------|-------------|
| System Inventory | Green | Stable | — |
| Integrations | Amber | Worsening | Tight coupling in user service |
| Decisions | Red | — | 3 ADRs overdue for review |
| Risk | Amber | Improving | 2 high-severity items |
| Cost | Green | Stable | — |

## [Detailed sections from each agent]

## Recommendations
1. [Priority action with owner]
2. [Priority action with owner]

## Next Review: [Date]
```

## Examples

### Example 1: Full Quarterly Review
```
/architecture-report --scope full --period "Q4 2025"
```

### Example 2: Component Focus
```
/architecture-report --scope component --focus "authentication service"
```
