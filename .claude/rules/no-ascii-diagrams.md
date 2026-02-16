# No ASCII Diagrams

## Rule

Never use ASCII art or box-drawing characters for diagrams. Always use Mermaid syntax for all diagrams, flowcharts, and visual representations.

## Why

- ASCII diagrams break in different fonts, terminals, and renderers
- Mermaid diagrams are machine-parseable, searchable, and maintainable
- Mermaid renders consistently across GitHub, IDEs, and documentation tools
- Mermaid diagrams can be versioned and diffed meaningfully

## Instead Of

```
┌──────────┐     ┌──────────┐
│  Client   │────▶│  Server  │
└──────────┘     └──────────┘
```

## Use

```mermaid
graph LR
    Client --> Server
```

## Supported Diagram Types

| Type | Use Case | Syntax |
|------|----------|--------|
| `graph` / `flowchart` | System architecture, data flow | `graph TD` or `flowchart LR` |
| `sequenceDiagram` | API calls, request flows | `sequenceDiagram` |
| `erDiagram` | Database schemas | `erDiagram` |
| `stateDiagram-v2` | State machines, workflows | `stateDiagram-v2` |
| `gantt` | Timelines, project plans | `gantt` |
| `C4Context` / `C4Container` | C4 architecture models | `C4Context` |
| `classDiagram` | Class/component relationships | `classDiagram` |

## Applies To

- All Markdown files
- Code comments containing diagrams
- Documentation and ADRs
- PR descriptions
