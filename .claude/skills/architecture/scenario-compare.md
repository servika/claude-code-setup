---
description: Compare architectural scenarios with cost, timeline, complexity, risk, and benefit analysis
model: sonnet
---

# /scenario-compare

Compare 2-4 architectural scenarios side-by-side using parallel analysis agents, producing a weighted comparison matrix with a clear recommendation.

## When to Use This Skill

- Choosing between technology options (e.g., Redis vs Memcached)
- Evaluating build vs buy decisions
- Comparing migration strategies
- Assessing deployment architecture options

## Usage

```
/scenario-compare <scenario-descriptions> [--criteria <custom-criteria>] [--constraints <constraints>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| scenarios | 2-4 scenario descriptions | Yes | — |
| criteria | Custom evaluation criteria | No | Cost, complexity, risk, timeline, scalability |
| constraints | Hard constraints (budget, timeline, team size) | No | — |

## Instructions

### Phase 1: Frame the Comparison

1. Parse scenario descriptions and constraints
2. Define evaluation criteria (use defaults or custom)
3. Assign weights to criteria based on constraints
4. Prepare context for each analysis agent

### Phase 2: Parallel Analysis (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Cost & Financial Analysis** (Haiku)
Task: Evaluate financial aspects of each scenario
- Development cost (person-weeks)
- Infrastructure cost (monthly/annual)
- Licensing and third-party service costs
- Total Cost of Ownership (3-year projection)
- Score each scenario 1-5 per financial criterion
Return: Cost comparison table with scores

**Agent 2: Technical & Complexity Analysis** (Sonnet)
Task: Evaluate technical merits of each scenario
- Implementation complexity (1-5)
- Scalability ceiling and growth path
- Maintainability and developer experience
- Integration with existing stack (React, Express, PostgreSQL)
- Technical debt implications
- Score each scenario 1-5 per technical criterion
Return: Technical comparison table with scores

**Agent 3: Risk & Timeline Analysis** (Sonnet)
Task: Evaluate delivery and operational risk
- Implementation timeline estimate
- Delivery risk (team skills, unknowns, dependencies)
- Operational risk (monitoring, debugging, incident response)
- Vendor/technology risk (maturity, community, longevity)
- Score each scenario 1-5 per risk criterion
Return: Risk comparison table with scores

### Phase 3: Synthesise

1. Collect all agent scores
2. Apply criteria weights to calculate weighted scores
3. Identify the leading scenario and runner-up
4. Note trade-offs and conditions that could change the recommendation
5. Generate final comparison matrix and recommendation

## Output Format

```markdown
# Scenario Comparison: [Topic]

## Scenarios
1. **[Name A]**: [Brief description]
2. **[Name B]**: [Brief description]

## Comparison Matrix

| Criterion (Weight) | Scenario A | Scenario B | Notes |
|---------------------|------------|------------|-------|
| Cost (25%) | 4/5 | 3/5 | A is cheaper long-term |
| Complexity (20%) | 3/5 | 4/5 | B is simpler to implement |
| Risk (20%) | 3/5 | 4/5 | B has lower delivery risk |
| Timeline (15%) | 2/5 | 4/5 | B ships 3 weeks sooner |
| Scalability (20%) | 5/5 | 3/5 | A scales better beyond 10K users |

## Weighted Scores
- **Scenario A**: X.X / 5.0
- **Scenario B**: X.X / 5.0

## Recommendation
[Clear recommendation with rationale and conditions]

## Trade-offs
[Key trade-offs the team should be aware of]
```

## Examples

### Example 1: Caching Strategy
```
/scenario-compare "Redis with sentinel" "Memcached cluster" "Application-level LRU cache" --constraints "budget: $500/mo, team: no Redis experience"
```

### Example 2: Auth Approach
```
/scenario-compare "JWT with refresh tokens" "Session-based with Redis" --criteria "security, complexity, scalability, mobile-support"
```
