---
description: Discover related code, docs, and patterns using multiple search signals
model: sonnet
---

# /find-related

Find content related to a given file, function, or concept by searching across five signals: imports, shared dependencies, naming patterns, temporal proximity, and architectural layer.

## When to Use This Skill

- Understanding what code is affected by a change
- Finding similar patterns elsewhere in the codebase
- Discovering undocumented relationships between modules
- Exploring a new codebase by following connections

## Usage

```
/find-related <source> [--signals all|imports|deps|patterns|temporal|layer] [--depth 1|2|3]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| source | File path, function name, or concept | Yes | — |
| signals | Which search signals to use | No | all |
| depth | How many hops to follow | No | 1 |

## Instructions

### Phase 1: Identify Source

1. If file path: Read the file, extract its purpose, imports, exports
2. If function name: Find its definition, callers, and callees
3. If concept: Search for files and functions related to the concept

### Phase 2: Search Across Signals

For each signal, search for related content:

**Signal 1: Import Graph**
- What does the source import?
- What imports the source?
- Shared imports (files that import the same dependencies)

**Signal 2: Shared Dependencies**
- Files that use the same npm packages
- Files that call the same services or APIs
- Files that access the same database tables

**Signal 3: Naming Patterns**
- Files with similar naming conventions (e.g., all `*.service.js`)
- Functions with similar names or prefixes
- Test files that correspond to the source

**Signal 4: Temporal Proximity**
- Files commonly changed together (git log analysis)
- Files changed in the same PRs
- Files modified by the same authors

**Signal 5: Architectural Layer**
- Files in the same architectural layer (route → controller → service → model)
- Files serving the same feature area
- Files with the same role in different features

### Phase 3: Rank and Present

1. Score each related item by relevance (how many signals match)
2. Group by relationship type
3. Suggest potential missing connections

## Output Format

```markdown
# Related to: [Source]

## Strongest Connections (3+ signals)

| File | Signals | Relationship |
|------|---------|-------------|
| src/controllers/users.controller.js | Import, Layer, Temporal | Direct consumer |
| src/routes/users.routes.js | Layer, Temporal, Naming | Route definition |

## By Signal

### Import Graph
- [File]: imports [what]

### Shared Dependencies
- [Files] both use [dependency]

### Naming Patterns
- [Similar files]

### Changed Together (git)
- [Files frequently co-modified]

### Same Layer
- [Files serving similar roles]

## Suggested Connections
- [Source] might benefit from using [related utility]
- Consider extracting shared logic between [source] and [similar file]
```

## Examples

### Example 1: Find Related to a Service
```
/find-related src/services/user.service.js
```

### Example 2: Find Related by Concept
```
/find-related "authentication" --signals patterns,layer
```
