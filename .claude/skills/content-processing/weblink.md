---
description: Capture web page content with AI-generated summary and structured reference
model: haiku
---

# /weblink

Quick-capture a web page into a structured reference with summary, key points, and metadata. Uses Haiku for fast, cost-effective processing.

## When to Use This Skill

- Saving a useful article or documentation page for reference
- Building a research collection on a topic
- Capturing tool/library documentation
- Creating quick references for team sharing

## Usage

```
/weblink <url> [--tags <comma-separated>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| url | Web page URL | Yes | — |
| tags | Categorisation tags | No | Auto-detected |

## Instructions

### Phase 1: Fetch Content

1. Use WebFetch to retrieve the page content
2. Extract metadata: title, author, publication date, domain

### Phase 2: Process

1. Generate one-line summary (max 120 characters)
2. Extract 3-5 key points
3. Pull notable quotes (if any)
4. Auto-detect tags if not provided (e.g., react, performance, security, testing)

### Phase 3: Output

Generate structured reference.

## Output Format

```markdown
# [Page Title]

**URL**: [url]
**Author**: [author] | **Date**: [date] | **Domain**: [domain]
**Tags**: [tags]

## Summary
[One-line summary]

## Key Points
- [Point 1]
- [Point 2]
- [Point 3]

## Notable Quotes
> [Quote if applicable]

## Relevance
[Brief note on why this is useful for the project]
```

## Examples

### Example 1: Documentation Page
```
/weblink https://react.dev/reference/react/useOptimistic --tags react,hooks
```

### Example 2: Blog Post
```
/weblink https://example.com/blog/scaling-postgres
```
