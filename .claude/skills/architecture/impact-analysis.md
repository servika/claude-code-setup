---
description: Analyse cascading impact of architectural changes across technical, organisational, financial, and risk dimensions
model: sonnet
---

# /impact-analysis

Analyse the ripple effects of a proposed architectural change using four parallel analysis agents, then synthesise findings into an impact matrix.

## When to Use This Skill

- Before making significant architectural changes
- When evaluating migration or refactoring proposals
- During technology selection or replacement decisions
- For change advisory board (CAB) submissions

## Usage

```
/impact-analysis <change-description> [--scope system|service|component] [--depth surface|deep]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| change-description | What is changing and why | Yes | — |
| scope | Blast radius of the change | No | system |
| depth | Analysis thoroughness | No | deep |

## Instructions

### Phase 1: Gather Context

1. Read the change description and clarify scope
2. Identify the affected systems, services, or components
3. Scan the codebase for direct dependencies on the affected area
4. Prepare context summaries for each analysis agent

### Phase 2: Parallel Impact Analysis (Agent Team)

Launch 4 agents using the Task tool:

**Agent 1: Technical Impact** (Sonnet)
Task: Analyse technical consequences of the change
- Identify all affected components, modules, and APIs
- Assess data migration requirements and schema changes
- Evaluate performance implications (latency, throughput, resource usage)
- Check compatibility with current tech stack (React, Express, PostgreSQL)
- Map upstream and downstream dependency changes
Return: Structured list of technical impacts with severity (Critical/High/Medium/Low)

**Agent 2: Organisational Impact** (Haiku)
Task: Assess team and process implications
- Identify teams that need to be involved or informed
- Assess skill gaps or training needs
- Evaluate process changes (deployment, testing, monitoring)
- Estimate communication overhead and coordination needs
Return: Structured list of organisational impacts with effort estimates

**Agent 3: Financial Impact** (Haiku)
Task: Estimate cost implications
- Development effort (person-days) for implementation
- Infrastructure cost changes (compute, storage, licensing)
- Opportunity cost of delayed features
- ROI timeline and break-even point
Return: Cost breakdown table with estimates and confidence levels

**Agent 4: Risk Assessment** (Sonnet)
Task: Identify and rate risks
- Technical risks (data loss, downtime, performance degradation)
- Operational risks (monitoring gaps, runbook updates, on-call impact)
- Security risks (new attack surfaces, auth changes, data exposure)
- For each risk: likelihood, impact, and mitigation strategy
Return: Risk register with severity matrix

### Phase 3: Synthesise

1. Collect all agent results
2. Build unified impact matrix
3. Identify cross-dimensional dependencies (e.g., technical risk driving financial cost)
4. Generate recommendation (Proceed / Proceed with caution / Defer / Reject)

## Output Format

```markdown
# Impact Analysis: [Change Description]

## Summary
[2-3 sentence executive summary with recommendation]

## Impact Matrix

| Dimension | Severity | Key Concerns | Mitigation |
|-----------|----------|--------------|------------|
| Technical | High | [Top concern] | [Mitigation] |
| Organisational | Medium | [Top concern] | [Mitigation] |
| Financial | Low | [Top concern] | [Mitigation] |
| Risk | High | [Top concern] | [Mitigation] |

## Technical Impact
[Detailed findings from Agent 1]

## Organisational Impact
[Detailed findings from Agent 2]

## Financial Impact
[Detailed findings from Agent 3]

## Risk Register
[Detailed findings from Agent 4]

## Recommendation
[Proceed / Proceed with caution / Defer / Reject with rationale]

## Next Steps
- [ ] [Action item 1]
- [ ] [Action item 2]
```

## Examples

### Example 1: Database Migration
```
/impact-analysis "Migrate from MongoDB to PostgreSQL for the user service" --scope service --depth deep
```

### Example 2: Framework Upgrade
```
/impact-analysis "Upgrade React from v17 to v18 with concurrent features" --scope system
```
