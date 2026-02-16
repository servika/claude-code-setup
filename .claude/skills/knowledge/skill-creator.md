---
description: Generate new Claude Code skill files following the standard template with agent team patterns
model: sonnet
---

# /skill-creator

Generate a new Claude Code skill file with proper structure, following the project's skill template conventions and optionally including agent team patterns.

## When to Use This Skill

- Creating a new custom skill for the project
- Standardising skill file format across the team
- Bootstrapping a skill with agent team boilerplate
- Converting an ad-hoc workflow into a reusable skill

## Usage

```
/skill-creator <skill-name> --purpose <description> [--pattern simple|fan-out|batch|triage] [--category <category>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| skill-name | Name for the skill (kebab-case) | Yes | — |
| purpose | What the skill does | Yes | — |
| pattern | Agent team pattern to use | No | simple |
| category | Skill category folder | No | knowledge |

## Instructions

### Phase 1: Define Skill Structure

Based on the pattern:

**simple**: Sequential execution, no sub-agents
- 2-3 phases: Gather → Execute → Output
- Single model (Haiku for fast/cheap, Sonnet for quality)

**fan-out**: Parallel agents analysing different dimensions
- Phase 1: Prepare context
- Phase 2: Launch 3-5 agents with distinct tasks
- Phase 3: Synthesise results
- Best for: multi-dimensional analysis, comprehensive reviews

**batch**: Parallel agents processing items in batches
- Phase 1: Collect items, create batches (10-15 per batch)
- Phase 2: Launch N agents (one per batch)
- Phase 3: Merge and deduplicate results
- Best for: processing many items (files, records, entries)

**triage**: Fast scoring then selective deep analysis
- Phase 1: Haiku agents score all items quickly
- Phase 2: Rank and select top items
- Phase 3: Sonnet agents deeply analyse selected items
- Best for: filtering large sets to find the valuable items

### Phase 2: Generate Skill File

Create the skill file with all standard sections:

1. YAML frontmatter (description, model)
2. Heading with `/command-name`
3. Purpose paragraph
4. "When to Use This Skill" section (3-4 bullet points)
5. "Usage" section with command syntax and parameters table
6. "Instructions" with phases matching the chosen pattern
7. "Output Format" with template
8. "Examples" with 2 concrete examples

### Phase 3: Write File

Save to `.claude/skills/{category}/{skill-name}.md`

## Output Format

The generated skill file follows this template:

```markdown
---
description: [One-line description]
model: [haiku|sonnet]
---

# /[skill-name]

[Purpose paragraph]

## When to Use This Skill
- [Use case 1]
- [Use case 2]

## Usage
/[skill-name] <param> [--option value]

### Parameters
| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|

## Instructions

### Phase 1: [Gather/Prepare]
[Steps]

### Phase 2: [Execute/Analyse]
[Steps or agent definitions]

### Phase 3: [Synthesise/Output]
[Steps]

## Output Format
[Template]

## Examples
### Example 1
[Usage example]
```

## Examples

### Example 1: Simple Skill
```
/skill-creator code-explainer --purpose "Explain a code file or function in plain English" --pattern simple
```

### Example 2: Fan-Out Skill
```
/skill-creator security-audit --purpose "Audit codebase for security vulnerabilities across OWASP categories" --pattern fan-out --category codebase-health
```

### Example 3: Batch Skill
```
/skill-creator batch-rename --purpose "Batch rename files following naming conventions" --pattern batch
```
