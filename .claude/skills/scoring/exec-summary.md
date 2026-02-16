---
description: Generate executive summaries tailored to specific audiences with BLUF structure
model: sonnet
---

# /exec-summary

Generate a Bottom Line Up Front (BLUF) executive summary of any document or topic, tailored to a specific audience (CEO, CTO, Board, PM, Engineering).

## When to Use This Skill

- Preparing stakeholder-specific briefings
- Condensing technical documents for leadership
- Creating sprint review summaries for different audiences
- Summarising project status for board meetings

## Usage

```
/exec-summary <source> [--audience ceo|cto|board|pm|engineering] [--length short|medium]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| source | File path, URL, or topic description | Yes | — |
| audience | Target audience for tone and focus | No | cto |
| length | Summary length | No | medium |

## Instructions

### Phase 1: Ingest Source

1. Read/fetch the source material
2. Identify the core topic, decisions, and data points
3. Note any metrics, timelines, or financial figures

### Phase 2: Tailor for Audience

Adjust focus based on audience:

| Audience | Focus On | Avoid |
|----------|----------|-------|
| **CEO** | Business impact, revenue, strategic alignment, risks | Technical details, implementation specifics |
| **CTO** | Architecture implications, tech debt, scalability, team impact | Business financials, marketing |
| **Board** | ROI, competitive position, risk exposure, milestones | All technical detail |
| **PM** | Timeline, scope, dependencies, user impact, acceptance criteria | Deep technical architecture |
| **Engineering** | Technical approach, trade-offs, patterns, testing strategy | Business strategy, financials |

### Phase 3: Generate BLUF Summary

Structure:
1. **Bottom Line**: The single most important thing (1 sentence)
2. **Context**: Why this matters right now (2-3 sentences)
3. **Key Points**: 3-5 bullet points with the essential information
4. **Recommendation**: What action to take (1-2 sentences)
5. **Details Available**: Where to find the full information

## Output Format

```markdown
# Executive Summary: [Topic]

**Audience**: [Target] | **Source**: [Reference] | **Date**: [Date]

## Bottom Line
[Single most important takeaway — 1 sentence]

## Context
[Why this matters now — 2-3 sentences]

## Key Points
- **[Point 1]**: [Brief explanation]
- **[Point 2]**: [Brief explanation]
- **[Point 3]**: [Brief explanation]

## Recommendation
[What should be done — 1-2 sentences]

## Supporting Details
[Reference to full document/source for those who want more depth]
```

## Examples

### Example 1: Technical Doc for CEO
```
/exec-summary docs/architecture/migration-plan.md --audience ceo --length short
```

### Example 2: Sprint Results for PM
```
/exec-summary "Sprint 14 results: completed auth refactor, 3 bugs fixed, 1 story carried over" --audience pm
```
