---
description: Create structured research notes from any source material with parallel knowledge extraction
model: sonnet
---

# /research-notes

Create comprehensive research notes from books, papers, talks, or courses using three parallel extraction agents for concepts, patterns, and action items.

## When to Use This Skill

- Processing a technical book or whitepaper
- Summarising a conference talk or workshop
- Creating notes from an online course module
- Extracting knowledge from research papers

## Usage

```
/research-notes <source> [--type book|paper|talk|course]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| source | File path or URL to source material | Yes | — |
| type | Source type (affects extraction strategy) | No | Auto-detect |

## Instructions

### Phase 1: Ingest Source

1. Read the source material (use Read tool for files, WebFetch for URLs)
2. Identify the type if not specified:
   - Book: Long-form, chapters, ISBN
   - Paper: Abstract, methodology, citations
   - Talk: Timestamps, slides, speaker
   - Course: Modules, exercises, prerequisites
3. Extract metadata: title, author(s), date, length

### Phase 2: Parallel Extraction (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Concept Extractor** (Sonnet)
Task: Extract core concepts and mental models
- Key definitions and terminology
- Core concepts explained in your own words
- Mental models and frameworks introduced
- How concepts relate to each other
- Connections to existing knowledge (React, Express, PostgreSQL patterns)
Return: Structured concept list with definitions and relationships

**Agent 2: Pattern Finder** (Haiku)
Task: Identify patterns and practices
- Design patterns and architectural patterns
- Best practices and recommended approaches
- Anti-patterns and common mistakes
- Recurring themes and principles
Return: Categorised pattern list (patterns vs anti-patterns)

**Agent 3: Action Mapper** (Haiku)
Task: Extract actionable items
- Things to try or implement in current projects
- Tools or libraries to evaluate
- Techniques to practice
- Follow-up research topics
- Resources and references mentioned
Return: Prioritised action list with effort estimates

### Phase 3: Synthesise

1. Merge agent outputs into cohesive research note
2. Add cross-references between concepts, patterns, and actions
3. Generate a "key insight" summary (the single most valuable takeaway)
4. Rate overall value: how applicable is this to the current project?

## Output Format

```markdown
# Research Notes: [Title]

**Author**: [Name] | **Type**: [book/paper/talk/course] | **Date**: [Date]
**Source**: [Path or URL]

## Key Insight
[Single most valuable takeaway in 1-2 sentences]

## Concepts
### [Concept 1]
[Explanation and relevance]

### [Concept 2]
[Explanation and relevance]

## Patterns
### Recommended
- **[Pattern]**: [When and how to apply]

### Avoid
- **[Anti-pattern]**: [Why and what to do instead]

## Action Items
- [ ] [High priority action]
- [ ] [Medium priority action]
- [ ] [Follow-up research]

## Notable Quotes
> [Memorable quote with attribution]

## References
- [Referenced materials worth exploring]
```

## Examples

### Example 1: Technical Book
```
/research-notes docs/designing-data-intensive-applications.pdf --type book
```

### Example 2: Conference Talk
```
/research-notes https://youtube.com/watch?v=... --type talk
```
