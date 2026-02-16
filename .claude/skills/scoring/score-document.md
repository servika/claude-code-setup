---
description: Score documents against customisable rubrics using parallel assessment agents
model: sonnet
---

# /score-document

Score a document (ADR, RFC, design doc, PR description) against a customisable rubric using four parallel assessment agents, producing a detailed scorecard.

## When to Use This Skill

- Reviewing architecture decision records for quality
- Assessing design documents before approval
- Evaluating RFC proposals objectively
- Benchmarking documentation quality

## Usage

```
/score-document <file-path> [--rubric default|adr|rfc|design-doc|custom] [--threshold <min-score>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| file-path | Path to document to score | Yes | — |
| rubric | Scoring rubric to use | No | default |
| threshold | Minimum passing score (0-100) | No | 60 |

## Instructions

### Phase 1: Load and Parse Document

1. Read the document
2. Select rubric criteria based on document type:

**Default rubric**: Clarity, Completeness, Actionability, Structure
**ADR rubric**: Context clarity, Options explored, Rationale depth, Consequences coverage
**RFC rubric**: Problem statement, Proposed solution, Alternatives, Migration plan
**Design doc rubric**: Requirements coverage, Technical depth, Risk assessment, Diagrams

### Phase 2: Parallel Scoring (Agent Team)

Launch 4 agents using the Task tool, one per rubric dimension:

**Scoring Agent** (Haiku, one per dimension)
Task: Score the document on assigned dimension
- Read the document
- Apply scoring criteria (1-5 per sub-criterion)
- Provide specific evidence from the document for each score
- Suggest specific improvements for low-scoring areas
Return: `{ dimension, score: X/5, evidence: [...], improvements: [...] }`

### Phase 3: Synthesise

1. Collect all dimension scores
2. Calculate weighted overall score (0-100)
3. Determine pass/fail against threshold
4. Generate scorecard with specific improvement actions

## Output Format

```markdown
# Document Score: [Document Title]

**Overall**: [X/100] — [PASS/FAIL]
**Rubric**: [rubric name] | **Threshold**: [X]

## Scorecard

| Dimension | Score | Weight | Weighted | Verdict |
|-----------|-------|--------|----------|---------|
| Clarity | 4/5 | 25% | 20/25 | Good |
| Completeness | 3/5 | 30% | 18/30 | Needs work |
| Actionability | 4/5 | 20% | 16/20 | Good |
| Structure | 5/5 | 25% | 25/25 | Excellent |
| **Total** | | **100%** | **79/100** | **PASS** |

## Detailed Feedback

### Clarity (4/5)
**Evidence**: [Specific quotes/sections that demonstrate clarity]
**Improvements**: [What could be clearer]

### Completeness (3/5)
**Evidence**: [What's covered well]
**Gaps**: [What's missing]

## Action Items
1. [ ] [Specific improvement to make]
2. [ ] [Specific improvement to make]
```

## Examples

### Example 1: Score an ADR
```
/score-document docs/architecture/decisions/0005-auth-strategy.md --rubric adr
```

### Example 2: Score with Custom Threshold
```
/score-document docs/design/payment-service.md --rubric design-doc --threshold 80
```
