---
description: Analyse existing architecture diagrams for completeness, readability, and accuracy
model: sonnet
---

# Review Architecture Diagrams

Analyse existing Mermaid architecture diagrams for quality across four dimensions: readability, completeness, accuracy, and standards compliance. Produces a structured review report with scores and actionable improvements.

## When to Use This Skill

- Reviewing diagrams before including them in architecture documentation or ADRs
- Validating that diagrams accurately reflect the current codebase state
- Improving diagram clarity before presenting to stakeholders or new team members
- Checking C4 model correctness and notation consistency
- Ensuring diagrams in pull requests meet documentation standards

## Usage

| Parameter   | Required | Description                                                              | Default |
|-------------|----------|--------------------------------------------------------------------------|---------|
| diagram     | Yes      | File path to a Markdown file containing a Mermaid diagram, or inline Mermaid code | -       |
| review-type | No       | Focus area: `readability`, `completeness`, `accuracy`, `all`             | `all`   |

## Instructions

### Phase 1: Parse and Understand the Diagram

1. Read the diagram source (from file path or inline).
2. Identify the diagram type (flowchart, sequence, erDiagram, C4Context, C4Container, C4Component, stateDiagram, classDiagram).
3. Extract all nodes, edges, labels, subgraphs, and styling directives.
4. Determine the apparent subject and scope of the diagram.

### Phase 2: Parallel Analysis

Run four analysis agents simultaneously. If `review-type` specifies a single dimension, still run that analysis thoroughly but skip the others.

#### Agent 1: Readability Analyst

Evaluate how easily a developer or stakeholder can understand the diagram:

- **Layout quality**: Is the flow direction logical (TD for hierarchies, LR for processes)? Are related nodes grouped together?
- **Label clarity**: Are node labels descriptive and concise? Do edge labels explain the relationship purpose? Are abbreviations defined?
- **Visual hierarchy**: Is there a clear primary flow? Do subgraph boundaries help or clutter?
- **Complexity assessment**: Count nodes, edges, and subgraphs. Flag if the diagram exceeds recommended limits (more than 15 nodes, more than 20 edges, more than 4 nesting levels).
- **Edge crossing analysis**: Identify overlapping or crossing edges that reduce readability. Suggest reordering node declarations to minimise crossings.
- **Consistency**: Are node shapes used consistently (e.g., all databases use cylinder shape, all external systems use a distinct style)?

Score 1-5 where: 1 = confusing, unreadable; 3 = understandable with effort; 5 = immediately clear.

#### Agent 2: Completeness Checker

Evaluate whether the diagram captures all relevant elements:

- **Missing components**: Based on the diagram's scope, are there components that should be shown? For a web app: frontend, API, database, cache, external services, load balancer.
- **Undocumented relationships**: Are there connections between shown components that are missing edges? Check for common patterns: frontend-to-API, API-to-database, API-to-cache, API-to-external-services.
- **Boundary gaps**: For C4 diagrams, are system/container boundaries properly drawn? Are external vs internal elements distinguished?
- **Missing metadata**: Does the diagram have a title? Are technology labels present on containers? Do edges specify protocol or technology where appropriate?
- **Legend/key**: If colours or special styles are used, is there a legend explaining them?
- **Error paths**: For sequence diagrams, are error/failure paths shown or noted?

Score 1-5 where: 1 = critically incomplete; 3 = covers main elements; 5 = comprehensive.

#### Agent 3: Accuracy Validator

Cross-reference the diagram against the actual codebase:

- **Component names**: Do the named services, modules, or tables actually exist in the project? Check against `src/` directory structure, `package.json`, Docker Compose files, and database migrations.
- **Relationship directions**: Do data flows match the actual call patterns? Verify that arrows point in the correct direction (e.g., frontend calls API, not the reverse for REST).
- **Technology labels**: Are technology versions and names correct? Check `package.json` for library versions, Dockerfiles for base images.
- **Missing recent changes**: Has the codebase evolved since the diagram was created? Look for new routes, services, or database tables not reflected in the diagram.
- **Structural accuracy**: Does the layering match the actual architecture? For Express apps: routes -> controllers -> services -> data access.

Score 1-5 where: 1 = significantly inaccurate; 3 = mostly correct with some drift; 5 = fully accurate.

#### Agent 4: Standards Compliance

Check adherence to diagramming standards and project conventions:

- **C4 model correctness** (if applicable): Are the correct C4 elements used for the diagram level? Context diagrams should not show internal containers. Container diagrams should not show component-level detail.
- **Notation consistency**: Are Mermaid syntax features used correctly? No mixing of arrow styles without reason. Consistent use of quotes on labels.
- **Naming conventions**: Do node IDs follow a consistent pattern? Are labels in Title Case or sentence case consistently?
- **Colour usage**: If styles are applied, do they follow a logical scheme (e.g., blue for internal, grey for external, red for critical paths)?
- **Project conventions**: Does the diagram follow the project's documentation standards (see `documentation.md` and `architecture.md` rules)?
- **Mermaid validity**: Is the syntax valid and will it render without errors?

Score 1-5 where: 1 = violates standards; 3 = partially compliant; 5 = fully compliant.

### Phase 3: Synthesise Review Report

Combine the four agent analyses into a single structured report:

1. Aggregate scores per dimension.
2. Calculate an overall score (weighted average: readability 30%, completeness 25%, accuracy 30%, standards 15%).
3. Prioritise improvement suggestions: critical issues first, then enhancements.
4. If the overall score is below 3, provide a corrected version of the diagram.
5. If the overall score is 3 or above, provide targeted suggestions as inline comments in the Mermaid code.

## Output Format

```markdown
# Diagram Review: [Diagram Title or Subject]

## Summary

| Dimension     | Score (1-5) | Key Finding                          |
|---------------|-------------|--------------------------------------|
| Readability   | X           | Brief one-line summary               |
| Completeness  | X           | Brief one-line summary               |
| Accuracy      | X           | Brief one-line summary               |
| Standards     | X           | Brief one-line summary               |
| **Overall**   | **X.X**     | **Weighted average**                 |

## Detailed Findings

### Readability
- Finding 1
- Finding 2

### Completeness
- Finding 1
- Finding 2

### Accuracy
- Finding 1
- Finding 2

### Standards Compliance
- Finding 1
- Finding 2

## Improvement Suggestions

| Priority | Suggestion                              | Dimension    |
|----------|-----------------------------------------|--------------|
| High     | Description of critical fix             | Accuracy     |
| Medium   | Description of improvement              | Completeness |
| Low      | Description of enhancement              | Readability  |

## Corrected Diagram (if applicable)

[Mermaid code block with fixes applied and comments explaining changes]
```

## Examples

### Example 1: Review a Container Diagram

```
/diagram-review diagram=docs/architecture/container-diagram.md review-type=all
```

Produces a full review checking whether the container diagram in the specified file accurately reflects the project's Docker Compose services, whether all API-to-database relationships are shown, and whether C4 notation is used correctly.

### Example 2: Review Inline Sequence Diagram

```
/diagram-review diagram="sequenceDiagram
    participant F as Frontend
    participant A as API
    F->>A: GET /users
    A-->>F: 200 OK" review-type=completeness
```

Produces a completeness-focused review noting missing elements such as: database participant, authentication middleware, error response paths, and request/response payload descriptions.

### Example 3: Accuracy Check After Refactor

```
/diagram-review diagram=docs/architecture/system-overview.md review-type=accuracy
```

Cross-references the system overview diagram against the current codebase to identify components that have been added, removed, or renamed since the diagram was last updated. Flags any stale references.
