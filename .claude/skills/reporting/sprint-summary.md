---
description: Generate sprint/weekly summary reports from git history, PRs, and issues
model: sonnet
---

# /sprint-summary

Generate a comprehensive sprint or weekly summary using five parallel agents to analyse commits, pull requests, issues, decisions, and project metrics.

## When to Use This Skill

- Sprint retrospectives and reviews
- Weekly status reports for stakeholders
- Generating release notes
- Tracking team velocity and progress

## Usage

```
/sprint-summary [--period <date-range>] [--format detailed|brief]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| period | Date range (e.g., "2025-01-06..2025-01-17" or "last 2 weeks") | No | Last 2 weeks |
| format | Report detail level | No | detailed |

## Instructions

### Phase 1: Gather Data

1. Determine date range for the sprint
2. Collect git log for the period
3. List PRs merged in the period (via `gh pr list`)
4. List issues closed/opened (via `gh issue list`)

### Phase 2: Parallel Analysis (Agent Team)

Launch 5 agents using the Task tool:

**Agent 1: Commit Analyser** (Haiku)
Task: Summarise development activity
- Group commits by feature/area
- Count commits per author
- Identify major changes vs minor fixes
- Calculate lines added/removed
Return: Development activity summary

**Agent 2: PR Analyser** (Haiku)
Task: Summarise pull request activity
- List merged PRs with descriptions
- Note review turnaround times
- Identify PRs with extensive discussion (potential concerns)
- Flag PRs still open/in review
Return: PR activity summary

**Agent 3: Issue Tracker** (Haiku)
Task: Summarise issue activity
- Issues closed (bugs fixed, features completed)
- Issues opened (new work, bug reports)
- Issues by label/priority
- Oldest open issues (potential blockers)
Return: Issue activity summary

**Agent 4: Decision Tracker** (Sonnet)
Task: Extract decisions made during the period
- Scan PR descriptions and comments for decisions
- Check for new ADRs or architecture changes
- Identify technical direction changes
- Note any process changes
Return: Decision log for the period

**Agent 5: Metrics Calculator** (Haiku)
Task: Calculate sprint metrics
- Velocity (stories/issues completed)
- Bug rate (bugs found vs fixed)
- Code churn (lines changed)
- Test coverage changes (if available)
Return: Metrics dashboard

### Phase 3: Compile Report

1. Merge all agent outputs
2. Generate executive summary (3-5 sentences)
3. Highlight accomplishments and blockers
4. List carry-over items and next sprint priorities

## Output Format

```markdown
# Sprint Summary: [Period]

## Highlights
- [Top accomplishment 1]
- [Top accomplishment 2]
- [Top accomplishment 3]

## Metrics

| Metric | Value | Trend |
|--------|-------|-------|
| PRs Merged | X | — |
| Issues Closed | X | — |
| Commits | X | — |
| Lines Changed | +X / -X | — |

## Completed Work
### Features
- [Feature 1] (PR #XX)
- [Feature 2] (PR #XX)

### Bug Fixes
- [Fix 1] (Issue #XX)

### Improvements
- [Improvement 1]

## Decisions Made
- [Decision 1]

## Carry-Over / Blockers
- [ ] [Item still in progress]
- [ ] [Blocked item with reason]

## Next Sprint Priorities
1. [Priority 1]
2. [Priority 2]
```

## Examples

### Example 1: Last Sprint
```
/sprint-summary --period "last 2 weeks"
```

### Example 2: Specific Dates
```
/sprint-summary --period "2025-01-06..2025-01-17" --format brief
```
