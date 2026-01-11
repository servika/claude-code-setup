# Planning with Files

A workflow methodology for handling complex, multi-step tasks using persistent markdown files as working memory.

---

## Overview

For non-trivial projects, use a **3-file pattern** to maintain context and track progress:

1. **`task_plan.md`** - Tracks phases and progress
2. **`notes.md`** - Stores research findings and discoveries
3. **`[deliverable].md`** - Contains the final output

This approach is inspired by [Manus context engineering principles](./reference.md).

---

## When to Use This Skill

**Use for:**
- ✅ Multi-step tasks (3+ phases)
- ✅ Research projects requiring information gathering
- ✅ Building deliverables (documentation, architecture designs)
- ✅ Work spanning multiple tool interactions (>10)
- ✅ Complex features requiring planning

**Skip for:**
- ❌ Quick questions
- ❌ Simple single-file edits
- ❌ Trivial bug fixes
- ❌ One-line changes

---

## The Core Principle

> **Before any major decision, read the plan file. This keeps goals in your attention window.**

After ~50 tool calls, AI agents experience "lost in the middle" effect where context degrades. Re-reading the plan file combats this by refreshing your understanding of the original goal.

---

## The 3-File Pattern

### 1. task_plan.md

**Purpose:** Track phases, progress, and errors

**Template:**

```markdown
# Task: [Brief Description]

## Goal
[What are we trying to accomplish?]

## Phases
- [ ] Phase 1: [Description]
- [ ] Phase 2: [Description]
- [ ] Phase 3: [Description]
- [ ] Phase 4: [Description]

## Current Status
Phase: [Current phase number and name]
Last Action: [What was just completed]

## Decisions Made
- [Decision 1 with rationale]
- [Decision 2 with rationale]

## Errors Encountered
- [Error 1: description and how it was resolved]
- [Error 2: description and how it was resolved]

## Next Steps
1. [Immediate next action]
2. [Following action]
3. [Then what]
```

**Key practices:**
- Create this file **first** for any non-trivial task
- Update status after **each** completed phase
- Log **all errors** with resolutions
- Re-read before major decisions

### 2. notes.md

**Purpose:** Store research findings, code snippets, and discoveries

**Template:**

```markdown
# Research Notes

## Findings
### [Topic 1]
- Key point 1
- Key point 2
- Code example:
  ```javascript
  // Example code
  ```

### [Topic 2]
- Discovery 1
- Discovery 2

## References
- [Source 1](URL)
- [Source 2](URL)

## Open Questions
- [ ] Question 1
- [ ] Question 2
```

**Key practices:**
- Store **large content** here, not in active context
- Append findings as you research
- Include code examples and snippets
- Link to external resources

### 3. [deliverable].md

**Purpose:** The final output (documentation, specification, etc.)

**Examples:**
- `api_documentation.md` - API endpoint docs
- `architecture_design.md` - System design
- `feature_spec.md` - Feature specification
- `bug_report.md` - Detailed bug analysis

---

## The Workflow Loop

```
1. Create task_plan.md
   ↓
2. Research → Write to notes.md
   ↓
3. Read notes.md to inform decisions
   ↓
4. Implement/Build → Update task_plan.md
   ↓
5. Deliver → Write to [deliverable].md
   ↓
6. Update task_plan.md with final status
```

**Critical:** Read `task_plan.md` before each major decision to refresh context.

---

## Examples

### Example 1: Research Task

**User:** "Research the benefits of morning exercise and compile findings"

**Agent workflow:**

1. **Loop 1 - Create Plan:**
   - Creates `task_plan.md` with phases:
     - [ ] Research sources on morning exercise
     - [ ] Analyze benefits
     - [ ] Compile findings
     - [ ] Write summary

2. **Loop 2 - Gather Sources:**
   - Searches for sources
   - Appends to `notes.md`:
     ```markdown
     ## Sources
     - Study 1: Increased metabolism...
     - Study 2: Better sleep patterns...
     ```
   - Updates `task_plan.md` - Phase 1 complete ✓

3. **Loop 3 - Synthesize:**
   - **Reads `task_plan.md`** to refresh context
   - Reads `notes.md` to review findings
   - Creates `exercise_benefits.md` with analysis

4. **Loop 4 - Deliver:**
   - Completes deliverable
   - Updates `task_plan.md` - All phases complete ✓

### Example 2: Bug Fix Task

**User:** "Fix the login authentication issue"

**`task_plan.md` content:**

```markdown
# Task: Fix Login Authentication Issue

## Goal
Resolve the login failure when users try to authenticate with valid credentials.

## Phases
- [x] Phase 1: Reproduce the issue
- [x] Phase 2: Investigate root cause
- [ ] Phase 3: Implement fix
- [ ] Phase 4: Test and verify

## Current Status
Phase: 2 (Investigation)
Last Action: Identified file: src/auth/login.ts

## Decisions Made
- Will use JWT token refresh instead of session-based auth
- Tokens will expire after 1 hour (security requirement)

## Errors Encountered
- Error 1: `TypeError: Cannot read property 'token' of undefined`
  - Cause: Missing null check for user object
  - Resolution: Added validation before token access

## Next Steps
1. Add null check in login.ts line 45
2. Implement token refresh logic
3. Add tests for edge cases
```

### Example 3: Feature Development

**User:** "Add dark mode to the application"

**Files created:**

1. **task_plan.md** - Track implementation phases
2. **notes.md** - Store research on MUI theming, color palettes
3. **dark_mode_feature.md** - Final feature documentation

**Workflow:**
- Phase 1: Research MUI dark mode implementation → Store in notes.md
- Phase 2: Design theme structure → Update task_plan.md with decisions
- Phase 3: Implement components → Read notes.md for patterns
- Phase 4: Test and document → Write to dark_mode_feature.md

---

## Best Practices

### ✅ Do

1. **Create `task_plan.md` first** for non-trivial work
2. **Re-read `task_plan.md`** before major decisions
3. **Log all errors** in task_plan.md with resolutions
4. **Store large content** in notes.md, not in active context
5. **Update status** after each phase completion
6. **Be specific** in next steps (actionable items)

### ❌ Don't

1. **Don't skip the plan** - Even if task seems simple
2. **Don't edit old entries** - Append new information instead
3. **Don't rely on memory** - Write everything down
4. **Don't delete error logs** - They're valuable for learning
5. **Don't combine phases** - Keep them atomic and trackable

---

## Anti-Patterns

### ❌ Silent Retry Pattern

**Bad:**
```
Error occurs → Agent immediately retries without documenting
```

**Good:**
```
Error occurs → Log to task_plan.md → Analyze → Plan solution → Retry
```

### ❌ Context Overload

**Bad:**
```
Keeping all research in active context → Token limit issues
```

**Good:**
```
Write research to notes.md → Read specific sections when needed
```

### ❌ Lost Goals

**Bad:**
```
After 50 tool calls → "What was I trying to do again?"
```

**Good:**
```
Before each decision → Read task_plan.md → Refresh understanding
```

---

## Advanced Patterns

### Error Recovery with Context

When an error occurs:

1. **Document in task_plan.md:**
   ```markdown
   ## Errors Encountered
   - Error: `ENOENT: no such file or directory`
     - Context: Trying to read src/config/database.js
     - Root cause: File moved to src/db/config.js in refactor
     - Resolution: Updated import path
   ```

2. **Update next steps:**
   ```markdown
   ## Next Steps
   1. ✅ Update import path in all files
   2. Run tests to verify fix
   3. Continue with original task
   ```

### Multi-Deliverable Projects

For projects with multiple outputs:

```markdown
# Task: Build User Authentication System

## Deliverables
- [ ] api_endpoints.md - API documentation
- [ ] architecture.md - System design
- [ ] tests.md - Test plan
- [ ] deployment.md - Deployment guide
```

Create separate files for each deliverable, but maintain one `task_plan.md`.

### Read-Before-Decide Pattern

**The golden rule:**

```markdown
Before:
- Making architectural decisions
- Implementing complex logic
- Changing core functionality
- Starting a new phase

Always:
- Read task_plan.md
- Review current status
- Check decisions made
- Verify you're on track
```

---

## Integration with Claude Code

### Using with TodoWrite Tool

Combine file-based planning with TodoWrite:

1. **Create `task_plan.md`** for detailed planning
2. **Use TodoWrite** for active task tracking
3. **Keep both in sync** - TodoWrite reflects current phase from task_plan.md

Example:
```markdown
# task_plan.md
## Phases
- [x] Phase 1: Setup
- [ ] Phase 2: Implementation ← Current
- [ ] Phase 3: Testing
```

TodoWrite tasks:
```
[ in_progress ] Implementing user authentication (Phase 2)
[ pending ] Write unit tests (Phase 3)
```

### Using with Agents

When invoking agents:

```
Claude, use the backend generator agent to create user authentication.

First, create a task_plan.md to track:
1. Route creation
2. Controller implementation
3. Service layer logic
4. Database integration
5. Testing

Store any research findings in notes.md.
```

---

## Why This Works

### Principle: Filesystem as External Memory

- **Problem:** Context windows degrade after many tool calls
- **Solution:** Store information in files, re-read when needed
- **Benefit:** Consistent performance across long tasks

### Principle: Attention Manipulation

- **Problem:** "Lost in the middle" effect after ~50 tool calls
- **Solution:** Re-read task_plan.md to keep goals front-of-mind
- **Benefit:** Stay aligned with original objectives

### Principle: Failure Traces

- **Problem:** Errors are often silently retried without learning
- **Solution:** Document every error with context and resolution
- **Benefit:** Build understanding, avoid repeated mistakes

See [reference.md](./reference.md) for full context engineering principles.

---

## Quick Reference

**Starting a task:**
```bash
1. Create task_plan.md with phases
2. Create notes.md for research
3. Begin first phase
```

**During execution:**
```bash
1. Research → Append to notes.md
2. Before decisions → Read task_plan.md
3. After phases → Update task_plan.md
4. Errors → Log in task_plan.md
```

**Completing a task:**
```bash
1. Write deliverable
2. Update task_plan.md final status
3. Mark all phases complete ✓
```

---

**Remember:** Your plan file is your anchor. Read it often, update it always, trust it completely.