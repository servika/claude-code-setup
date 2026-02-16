---
description: Quick-capture articles from URLs with summary and relevance scoring
model: haiku
---

# /article

Fast article capture with AI-generated summary, key points, and optional relevance scoring against your current research context. Uses Haiku for speed and cost efficiency.

## When to Use This Skill

- Quickly capturing an article during research
- Building a reading list with summaries
- Scoring articles for relevance to a specific topic
- Creating shareable article summaries for the team

## Usage

```
/article <url> [--context <what-you-are-researching>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| url | Article URL | Yes | — |
| context | Research context for relevance scoring | No | — |

## Instructions

### Phase 1: Fetch Article

1. Use WebFetch to retrieve the article
2. Extract: title, author, publication date, estimated reading time

### Phase 2: Analyse

1. Generate one-line summary
2. Extract 3-5 key takeaways
3. Identify the main argument or thesis
4. If context provided, score relevance (1-5) with justification

### Phase 3: Output

Generate quick-reference capture.

## Output Format

```markdown
# [Article Title]

**Author**: [author] | **Date**: [date] | **Read time**: ~[X] min
**URL**: [url]

## TL;DR
[One-line summary]

## Key Takeaways
1. [Takeaway 1]
2. [Takeaway 2]
3. [Takeaway 3]

## Main Argument
[2-3 sentences on the article's thesis]

## Relevance: [X/5]
[Why this is/isn't relevant to your context — only if context provided]
```

## Examples

### Example 1: With Context
```
/article https://example.com/blog/microservices-patterns --context "migrating monolith to microservices"
```

### Example 2: Quick Capture
```
/article https://example.com/blog/react-19-features
```
