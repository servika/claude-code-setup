---
description: Extract and catalogue decisions from ADRs, PRs, commits, and documentation
model: sonnet
---

# /find-decisions

Search the project for formal and informal decisions across ADRs, pull requests, commit messages, and documentation, cataloguing them with context and status.

## When to Use This Skill

- Auditing what decisions have been made and when
- Finding the rationale behind a past technical choice
- Preparing for architecture reviews
- Onboarding new team members with decision history

## Usage

```
/find-decisions [--period <date-range>] [--scope adr|pr|commits|docs|all] [--topic <keyword>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| period | Date range to search | No | All time |
| scope | Where to search for decisions | No | all |
| topic | Filter by topic keyword | No | — |

## Instructions

### Phase 1: Search Sources

For each scope, search for decision indicators:

**ADRs**: Scan `docs/architecture/decisions/` or similar directories
- Extract formal decisions with status, date, and rationale

**Pull Requests**: Use `gh pr list --state merged` with date filters
- Search PR titles and descriptions for decision language
- Look for: "decided to", "chosen approach", "going with", "agreed on"

**Commits**: Search git log messages
- Look for: "switch to", "replace", "migrate", "choose", "adopt"
- Focus on commits that change configuration or architecture

**Documentation**: Search README, CLAUDE.md, and docs/ files
- Look for stated conventions and standards
- Find "we use X because Y" patterns

### Phase 2: Classify Decisions

For each decision found:
1. **Type**: Architecture, Technology, Process, Convention, Design
2. **Status**: Active, Superseded, Deprecated, Proposed
3. **Impact**: High (system-wide), Medium (service-level), Low (local)
4. **Confidence**: Formal (ADR/documented), Informal (PR/commit), Inferred (code patterns)

### Phase 3: Generate Decision Catalogue

Compile findings into chronological decision log.

## Output Format

```markdown
# Decision Catalogue

**Period**: [Range] | **Decisions found**: [X]
**Sources**: [ADRs: X, PRs: X, Commits: X, Docs: X]

## Decision Timeline

| Date | Decision | Type | Source | Impact | Status |
|------|----------|------|--------|--------|--------|
| 2025-01-15 | Use JWT with refresh tokens | Architecture | ADR-002 | High | Active |
| 2025-01-10 | Adopt Zod for validation | Technology | PR #45 | Medium | Active |
| 2024-12-20 | Switch from Mongoose to pg | Technology | Commit abc123 | High | Active |

## Detailed Decisions

### Use JWT with Refresh Tokens
**Date**: 2025-01-15 | **Source**: ADR-002 | **Status**: Active
**Context**: Needed stateless auth for microservices
**Rationale**: Scalability, no session storage needed
**Alternatives considered**: Session-based auth, OAuth tokens

## Undocumented Decisions (Inferred)
- [Pattern observed in code that represents an undocumented decision]
- **Recommendation**: Create ADR for these

## Decision Gaps
- [Areas where a decision seems needed but none was found]
```

## Examples

### Example 1: All Decisions
```
/find-decisions
```

### Example 2: Recent Auth Decisions
```
/find-decisions --period "last 3 months" --topic "authentication"
```
