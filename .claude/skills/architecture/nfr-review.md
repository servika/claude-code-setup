---
description: Review non-functional requirements for completeness, measurability, and feasibility
model: sonnet
---

# /nfr-review

Review a set of non-functional requirements using three parallel agents to check completeness, measurability, and feasibility, producing a quality assessment with improvement suggestions.

## When to Use This Skill

- After capturing NFRs with `/nfr-capture`
- Before architecture review or sign-off
- When inheriting NFRs from another team
- Periodic NFR health checks

## Usage

```
/nfr-review <nfr-document> [--depth quick|thorough]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| nfr-document | File path to NFR document or inline content | Yes | — |
| depth | Review thoroughness | No | thorough |

## Instructions

### Phase 1: Parse NFRs

1. Read the NFR document
2. Extract individual requirements with their IDs, criteria, and priorities
3. Identify the quality categories covered
4. Prepare context for review agents

### Phase 2: Parallel Review (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Completeness Reviewer** (Sonnet)
Task: Check coverage and gaps
- Verify all ISO 25010 categories are addressed (or explicitly excluded with rationale)
- Check for missing stakeholder perspectives
- Identify NFRs that lack acceptance criteria
- Flag requirements without assigned priority
- Check for cross-cutting concerns (logging, monitoring, error handling)
Return: Completeness score (0-100%) with gap list

**Agent 2: Measurability Reviewer** (Haiku)
Task: Check that NFRs are testable
- Flag vague language ("fast", "secure", "scalable", "user-friendly")
- Verify numeric thresholds exist (response time in ms, uptime in %, etc.)
- Check that verification methods are specified
- Ensure criteria are objectively measurable (not subjective)
Return: Measurability score (0-100%) with list of vague NFRs and suggested rewrites

**Agent 3: Feasibility Reviewer** (Sonnet)
Task: Check that NFRs are achievable
- Identify contradictory requirements (e.g., "zero downtime" + "no redundancy budget")
- Flag unrealistic thresholds for the given tech stack
- Check technology constraints (can React/Express/PostgreSQL meet these?)
- Identify NFRs that require infrastructure not yet in place
Return: Feasibility score (0-100%) with concern list and recommendations

### Phase 3: Synthesise

1. Collect all reviewer results
2. Build per-NFR assessment (pass/warn/fail for each dimension)
3. Calculate overall quality score
4. Generate prioritised improvement list

## Output Format

```markdown
# NFR Review Report

## Overall Score: X/100

| Dimension | Score | Verdict |
|-----------|-------|---------|
| Completeness | X% | [Pass/Warn/Fail] |
| Measurability | X% | [Pass/Warn/Fail] |
| Feasibility | X% | [Pass/Warn/Fail] |

## Per-NFR Assessment

| NFR ID | Complete | Measurable | Feasible | Action |
|--------|----------|------------|----------|--------|
| NFR-P01 | Pass | Pass | Pass | None |
| NFR-S02 | Pass | Warn | Pass | Add threshold |

## Issues Found
### Critical
- [Issues that must be fixed]

### Warnings
- [Issues that should be addressed]

## Suggested Improvements
1. [Specific rewrite suggestion for NFR-XX]
2. [Missing NFR to add]
```

## Examples

### Example 1: Review Captured NFRs
```
/nfr-review docs/nfr-payment-service.md --depth thorough
```
