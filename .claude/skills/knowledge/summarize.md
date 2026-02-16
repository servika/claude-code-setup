---
description: Summarise any document or codebase area with configurable depth and audience
model: sonnet
---

# /summarize

Generate summaries at different depth levels and for different audiences, from a quick one-liner to a full-page analysis.

## When to Use This Skill

- Creating TL;DRs for long documents
- Summarising code modules for team members
- Generating quick overviews for different stakeholders
- Condensing research findings

## Usage

```
/summarize <source> [--depth one-liner|paragraph|page] [--audience developer|pm|leadership]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| source | File path, URL, directory, or text | Yes | — |
| depth | Summary length | No | paragraph |
| audience | Target audience | No | developer |

## Instructions

### Phase 1: Read Source

1. If file: Read the file content
2. If URL: Fetch with WebFetch
3. If directory: Scan files and build overview
4. If text: Use directly

### Phase 2: Generate Summary

Adjust based on depth:

**one-liner**: Max 120 characters. The single most important point.

**paragraph**: 3-5 sentences covering:
- What it is / what it does
- Why it matters
- Key details (numbers, dates, names)

**page**: Full summary covering:
- Overview and purpose
- Key sections/components
- Important details and data
- Conclusions or recommendations
- Open questions

Adjust based on audience:

| Audience | Emphasise | De-emphasise |
|----------|-----------|-------------|
| **developer** | Technical details, patterns, APIs, trade-offs | Business metrics |
| **pm** | Features, timelines, user impact, dependencies | Implementation details |
| **leadership** | Business impact, cost, risk, strategic alignment | Technical specifics |

### Phase 3: Output

Generate clean summary with source attribution.

## Output Format

### One-liner
```
[Single sentence summary]
```

### Paragraph
```markdown
**Summary**: [Source name]

[3-5 sentence summary tailored to audience]
```

### Page
```markdown
# Summary: [Source Name]

**Source**: [Path/URL] | **Audience**: [Target] | **Date**: [Date]

## Overview
[What this is and why it matters]

## Key Points
- [Point 1]
- [Point 2]
- [Point 3]

## Details
[Important specifics]

## Conclusions
[Takeaways and recommendations]
```

## Examples

### Example 1: Quick Summary
```
/summarize src/services/auth.service.js --depth one-liner
```

### Example 2: Full Summary for PM
```
/summarize docs/architecture/migration-plan.md --depth page --audience pm
```

### Example 3: Directory Overview
```
/summarize src/middleware/ --depth paragraph --audience developer
```
