# Agent Team Patterns Guide

How to use the Task tool to orchestrate multiple agents for parallel analysis, batch processing, and complex workflows.

## Core Concepts

Claude Code's Task tool launches subagents that work independently and return results. Agent teams combine multiple subagents to tackle complex tasks from different angles simultaneously.

### Why Use Agent Teams?

- **Speed**: Parallel agents complete faster than sequential analysis
- **Depth**: Each agent focuses on one dimension, producing deeper results
- **Cost efficiency**: Use cheaper models (Haiku) for straightforward tasks, expensive models (Sonnet/Opus) only where needed
- **Consistency**: Structured patterns produce predictable, mergeable outputs

## Patterns

### 1. Fan-Out / Fan-In

Launch N agents in parallel, each analysing a different dimension. Merge results into a unified output.

```
                 ┌─ Agent 1 (Dimension A) ─┐
Input ──────────►├─ Agent 2 (Dimension B) ─├──────► Merged Output
                 └─ Agent 3 (Dimension C) ─┘
```

**When to use**: Multi-dimensional analysis where each dimension is independent.

**Example**: `/impact-analysis` launches 4 agents:

| Agent                 | Model  | Dimension                                    |
| --------------------- | ------ | -------------------------------------------- |
| Technical Impact      | Sonnet | Code changes, dependencies, breaking changes |
| Organisational Impact | Haiku  | Team workflows, training, communication      |
| Financial Impact      | Haiku  | Cost estimates, ROI projections              |
| Risk Assessment       | Sonnet | Risk matrix, mitigation strategies           |

**Implementation pattern in skills**:

```markdown
## Agent Team

Launch these agents in parallel using the Task tool:

### Agent 1: Technical Analysis

- **Model**: sonnet
- **Task**: Analyse technical impact of {topic}
- **Output format**: Markdown with severity ratings

### Agent 2: Cost Analysis

- **Model**: haiku
- **Task**: Estimate costs related to {topic}
- **Output format**: Table with cost breakdown

## Merge Strategy

Combine outputs into unified report with:

1. Executive summary (synthesise all agents)
2. Per-dimension sections (one per agent)
3. Cross-cutting concerns (identified across agents)
```

**Skills using this pattern**:

- `/impact-analysis` (4 agents)
- `/scenario-compare` (3 agents)
- `/nfr-review` (3 agents)
- `/architecture-report` (5 agents)
- `/cost-analysis` (3 agents)
- `/code-quality-report` (5 agents)
- `/broken-references` (3 agents)
- `/dead-code-finder` (4 agents)
- `/sprint-summary` (5 agents)
- `/project-report` (4 agents)
- `/meeting-notes` (3 agents)
- `/diagram-review` (4 agents)
- `/score-document` (4 agents)
- `/research-notes` (3 agents)

### 2. Batch Processing

Process multiple items using the same agent template. Each item gets its own agent instance.

```
Item 1 ──► Agent Instance 1 ──┐
Item 2 ──► Agent Instance 2 ──├──► Collected Results
Item 3 ──► Agent Instance 3 ──┘
```

**When to use**: Same analysis applied to many items (files, components, dependencies).

**Example**: `/auto-document` processes files in batches:

1. Scan codebase for undocumented files
2. Group into batches of 5-10
3. Launch one Haiku agent per batch
4. Each agent generates JSDoc/README content
5. Collect and apply all results

**Skills using this pattern**:

- `/auto-document` (batch JSDoc generation)
- `/auto-categorize` (batch file classification)
- `/dependency-checker` (batch dependency analysis)

### 3. Triage + Selective Deep-Dive

Quick assessment of many items, then deep analysis only on the most relevant.

```
All Items ──► N Haiku Agents (score relevance) ──► Top K items ──► Sonnet Deep Analysis
```

**When to use**: Large input set where only a subset needs detailed analysis.

**Example**: `/video-digest` processes multiple videos:

1. N Haiku agents each score a video segment for relevance (1-10)
2. Segments scoring above threshold get Sonnet deep analysis
3. Final output focuses on the most valuable content

**Skills using this pattern**:

- `/video-digest` (triage video segments)

### 4. Sequential Pipeline

Each stage feeds into the next. Used when later stages depend on earlier results.

```
Input ──► Stage 1 ──► Stage 2 ──► Stage 3 ──► Output
```

**When to use**: Tasks with clear dependencies between steps.

**Example**: `/nfr-capture`:

1. Read existing documentation and codebase
2. Identify NFR categories (ISO 25010)
3. Draft measurable requirements per category
4. Generate traceability matrix

**Skills using this pattern**:

- `/adr` (research → draft → refine)
- `/nfr-capture` (discover → categorise → specify)
- `/pdf-extract` (extract → structure → summarise)
- `/pptx-extract` (extract → structure → summarise)
- `/youtube-analyze` (fetch → transcribe → analyse)
- `/voice-meeting` (correct → extract → structure)
- `/dependency-graph` (scan → analyse → render)

## Model Selection Guide

| Model      | Cost   | Speed  | Best For                                           |
| ---------- | ------ | ------ | -------------------------------------------------- |
| **Haiku**  | Low    | Fast   | Counting, categorising, simple extraction, scoring |
| **Sonnet** | Medium | Medium | Analysis, synthesis, code review, writing          |
| **Opus**   | High   | Slow   | Complex reasoning, architecture decisions          |

### Rules of Thumb

- **Haiku** for agents that scan/count/categorise (e.g., "count lint errors", "list unused imports")
- **Sonnet** for agents that analyse/synthesise (e.g., "assess risk", "find patterns", "review code")
- **Opus** only when you need deep reasoning about complex trade-offs
- When in doubt, start with Sonnet — it handles most tasks well

## Designing Agent Teams

### Step 1: Identify Dimensions

Break the task into independent analysis dimensions:

```
Code Quality Report:
├── Complexity Analysis    (independent)
├── Test Coverage         (independent)
├── Lint & Style          (independent)
├── Dependency Health     (independent)
└── Build & Bundle        (independent)
```

### Step 2: Assign Models

Match model capability to dimension complexity:

```
├── Complexity Analysis    → Haiku  (counting/measuring)
├── Test Coverage         → Haiku  (reading coverage reports)
├── Lint & Style          → Haiku  (running/parsing linter)
├── Dependency Health     → Sonnet (assessing vulnerability impact)
└── Build & Bundle        → Haiku  (measuring sizes)
```

### Step 3: Define Output Format

Each agent must return a consistent, mergeable format:

```markdown
### [Dimension Name]

**Score**: X/100
**Status**: GREEN | AMBER | RED

**Findings**:

- Finding 1
- Finding 2

**Recommendations**:

- Recommendation 1
- Recommendation 2
```

### Step 4: Define Merge Strategy

How to combine agent outputs into a final deliverable:

- **Concatenation**: Simply join sections (most common)
- **Synthesis**: Write a new summary that draws from all agents
- **Scoring**: Compute aggregate scores from individual scores
- **Matrix**: Cross-reference findings across dimensions

## Practical Tips

### Prompt Engineering for Agents

Each agent prompt should include:

1. **Role**: "You are a security analyst reviewing..."
2. **Scope**: "Focus ONLY on authentication and authorization..."
3. **Input**: "Analyse the following files: ..."
4. **Output format**: "Return your analysis as a markdown section with..."
5. **Constraints**: "Do not suggest changes outside the auth module..."

### Error Handling

- If an agent fails, the orchestrator should note the gap and continue
- Set reasonable timeouts — don't let one slow agent block the whole team
- For critical agents (e.g., security review), consider retry logic

### Parallel vs Sequential

Use parallel when:

- Agents don't need each other's output
- Speed matters more than cross-referencing
- Each agent has a clear, bounded scope

Use sequential when:

- Later agents need earlier results
- The task has natural phases (research → plan → execute)
- Order matters for correctness

### Keeping Costs Down

- Use Haiku for 60-70% of agents in a team
- Only promote to Sonnet when analysis quality noticeably suffers with Haiku
- Batch small items together instead of one agent per item
- Use triage pattern to avoid deep analysis on irrelevant items

## Creating New Agent Teams

Use the `/skill-creator` skill to generate new skills with agent teams. It supports all four patterns and will scaffold the correct structure.

Alternatively, copy an existing skill from `.claude/skills/` and modify:

1. Update the YAML frontmatter (`description`, `model`)
2. Adjust the agent team section (agents, models, prompts)
3. Update the merge strategy
4. Test with a real input

## Reference: Skills by Pattern

### Fan-Out / Fan-In (14 skills)

| Skill                  | Agents | Models            |
| ---------------------- | ------ | ----------------- |
| `/impact-analysis`     | 4      | 2 Sonnet, 2 Haiku |
| `/scenario-compare`    | 3      | 2 Sonnet, 1 Haiku |
| `/nfr-review`          | 3      | 2 Sonnet, 1 Haiku |
| `/architecture-report` | 5      | 2 Sonnet, 3 Haiku |
| `/cost-analysis`       | 3      | 1 Sonnet, 2 Haiku |
| `/code-quality-report` | 5      | 1 Sonnet, 4 Haiku |
| `/broken-references`   | 3      | 1 Sonnet, 2 Haiku |
| `/dead-code-finder`    | 4      | 2 Sonnet, 2 Haiku |
| `/sprint-summary`      | 5      | 1 Sonnet, 4 Haiku |
| `/project-report`      | 4      | 2 Sonnet, 2 Haiku |
| `/meeting-notes`       | 3      | 1 Sonnet, 2 Haiku |
| `/diagram-review`      | 4      | 4 Sonnet          |
| `/score-document`      | 4      | 4 Haiku           |
| `/research-notes`      | 3      | 1 Sonnet, 2 Haiku |

### Batch Processing (3 skills)

| Skill                 | Agent Template  | Model          |
| --------------------- | --------------- | -------------- |
| `/auto-document`      | JSDoc generator | Haiku          |
| `/auto-categorize`    | File classifier | Haiku          |
| `/dependency-checker` | Dep analyser    | Sonnet + Haiku |

### Triage + Deep-Dive (1 skill)

| Skill           | Triage Model | Deep-Dive Model |
| --------------- | ------------ | --------------- |
| `/video-digest` | Haiku        | Sonnet          |

### Sequential (7 skills)

| Skill               | Stages                          |
| ------------------- | ------------------------------- |
| `/adr`              | Research → Draft → Refine       |
| `/nfr-capture`      | Discover → Categorise → Specify |
| `/pdf-extract`      | Extract → Structure → Summarise |
| `/pptx-extract`     | Extract → Structure → Summarise |
| `/youtube-analyze`  | Fetch → Transcribe → Analyse    |
| `/voice-meeting`    | Correct → Extract → Structure   |
| `/dependency-graph` | Scan → Analyse → Render         |

### Simple (12 skills)

Single-agent skills without team orchestration:

`/adr`, `/diagram`, `/c4-diagram`, `/weblink`, `/article`, `/document-extract`, `/email-capture`, `/exec-summary`, `/summarize`, `/find-related`, `/find-decisions`, `/timeline`, `/skill-creator`
