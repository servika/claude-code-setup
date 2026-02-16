---
description: Create Architecture Decision Records with structured context, rationale, and consequences
model: sonnet
---

# Architecture Decision Record (ADR)

Create well-structured Architecture Decision Records that capture the context, rationale, and consequences of significant architectural decisions in the project.

## When to Use This Skill

- A significant technical decision needs to be documented
- Choosing between competing technologies, patterns, or approaches
- Making a decision that will be difficult or expensive to reverse
- Stakeholders need to understand why a particular approach was chosen
- Onboarding new team members who need decision history

## Usage

`/adr topic="Use PostgreSQL as primary database"`

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| topic | Yes | The decision topic or question being addressed |
| context | No | Additional background information or constraints |
| options | No | Specific options to evaluate (comma-separated) |

## Instructions

### Phase 1: Gather Context

1. Read the project's existing architecture documentation in `docs/architecture/` if it exists
2. Scan the codebase to understand current technology choices and patterns
3. Identify the stakeholders affected by this decision
4. Research the options being considered, including:
   - Current industry best practices
   - Compatibility with existing tech stack defined in CLAUDE.md
   - Team expertise and learning curve
5. Check for existing ADRs to ensure consistency and avoid contradictions

### Phase 2: Structure the ADR

Using the project's ADR template from `.claude/rules/architecture.md`, structure the record:

1. **Assign ADR number** - Check existing ADRs in `docs/architecture/decisions/` and use the next sequential number
2. **Set status** - Default to "Proposed" unless instructed otherwise
3. **Write Context** - Clearly explain the problem or need driving this decision. Include:
   - Business requirements motivating the change
   - Technical constraints
   - Current pain points or limitations
4. **State the Decision** - Concise statement of what is being decided
5. **Document Rationale** - For each option considered:
   - Description of the approach
   - Pros (with specifics relevant to the project)
   - Cons (with specifics relevant to the project)
   - Why it was or was not selected
6. **List Consequences** - Separate into:
   - Positive consequences
   - Negative consequences
   - Risks with mitigation strategies
7. **Add References** - Links to relevant documentation, discussions, or research

### Phase 3: Output

1. Generate the ADR as a markdown file following the exact template format
2. Suggest the file path: `docs/architecture/decisions/NNNN-kebab-case-title.md`
3. If a README index exists in the decisions directory, suggest an update to include the new ADR

## Output Format

```markdown
# ADR-NNN: [Title]

## Status
Proposed

## Date
YYYY-MM-DD

## Context
[Clear explanation of the problem and motivating factors]

## Decision
[Concise statement of the decision]

## Rationale

### Options Considered

1. **Option A**: [Description]
   - Pros: ...
   - Cons: ...

2. **Option B**: [Description]
   - Pros: ...
   - Cons: ...

## Consequences

### Positive
- ...

### Negative
- ...

### Risks
- ...

## References
- [Links]
```

## Examples

**Basic usage:**
```
/adr topic="Authentication strategy for API"
```

**With context and options:**
```
/adr topic="State management approach" context="Application has complex forms with server-synced data and minimal client-only UI state" options="Redux, Zustand, React Query + Context"
```

**Infrastructure decision:**
```
/adr topic="Container orchestration platform" context="Currently using Docker Compose in production, need to support auto-scaling" options="Kubernetes, ECS, Docker Swarm"
```
