# Reference: Context Engineering Principles

These principles are inspired by Manus (acquired by Meta for $2B in December 2025), which achieved $100M revenue in 8 months through exceptional AI agent performance.

---

## The 6 Core Principles

### 1. Filesystem as External Memory

**Principle:** Store large content in files rather than keeping it in context.

**Rationale:**
- Context windows are expensive (token costs)
- Long contexts degrade performance
- Files provide persistent, retrievable storage

**Practice:**
> "Markdown is my 'working memory' on disk."

**Implementation:**
```markdown
# Instead of keeping everything in context
[Long research data, code snippets, findings...]

# Use files as external memory
Write to notes.md → Read specific sections when needed
```

**Benefits:**
- Reduced token costs
- No context degradation
- Persistent across sessions
- Scalable to very large projects

---

### 2. Attention Manipulation Through Repetition

**Principle:** Maintain a task_plan.md file and re-read it throughout execution.

**The Problem:**
After ~50 tool calls, AI agents experience "lost in the middle" effect:
- Original goals fade
- Context becomes cluttered
- Focus drifts from objective

**The Solution:**
```markdown
Before major decisions → Read task_plan.md → Refresh context
```

**Why It Works:**
- Brings goals back to attention window
- Resets focus on original objective
- Combats context degradation
- Maintains alignment with user intent

**Example:**
```
Call 1: Create task_plan.md
Call 10: Read task_plan.md before implementing
Call 25: Read task_plan.md before refactoring
Call 50: Read task_plan.md before final delivery
```

---

### 3. Keep Failure Traces

**Principle:** Document all errors with full context and resolution.

**The Quote:**
> "Error recovery is one of the clearest signals of TRUE agentic behavior."

**Why Document Errors:**
- Errors provide learning signals
- Helps model calibrate understanding
- Prevents repeated mistakes
- Shows reasoning process
- Builds system knowledge

**What to Log:**
```markdown
## Error Template
- Error: [Exact error message]
- Context: [What were you doing?]
- Location: [File, line, function]
- Root Cause: [Why did it happen?]
- Investigation: [What did you check?]
- Resolution: [How did you fix it?]
```

**Don't Do This:**
```
❌ Encounter error → Silently retry → Lose context
```

**Do This:**
```
✅ Encounter error → Log to task_plan.md → Analyze → Plan → Resolve
```

---

### 4. Avoid Few-Shot Overfitting

**Principle:** Introduce controlled variation; don't blindly copy patterns.

**The Problem:**
> "Uniformity breeds fragility."

AI agents trained on repetitive patterns may:
- Copy structure without understanding
- Apply patterns inappropriately
- Lack adaptability
- Miss edge cases

**The Solution:**
- Understand **why** patterns work
- Adapt patterns to context
- Introduce variations when appropriate
- Think critically about each situation

**Example:**

**❌ Overfitting:**
```javascript
// Every function looks exactly the same
async function getUser() { /* ... */ }
async function getPost() { /* ... */ }
async function getComment() { /* ... */ }
```

**✅ Contextual Adaptation:**
```javascript
// Patterns vary based on need
async function getUser(id) { /* Simple lookup */ }
async function getPostsForUser(userId, filters) { /* Complex query */ }
function getCachedComment(id) { /* Synchronous cache check */ }
```

---

### 5. Stable Prefixes for Cache Optimization

**Principle:** Structure content with static information first; use append-only pattern.

**The Ratio:**
Input tokens are read 100 times more often than output tokens are written.

**Implication:**
Optimize for **reading**, not writing.

**Cache Optimization:**
```markdown
# Good Structure (Stable Prefix)

# Task: User Authentication  ← Stable
## Goal: Implement JWT auth   ← Stable

## Phases                     ← Stable prefix
- [ ] Phase 1: Research       ← Stable
- [ ] Phase 2: Implement      ← Stable

## Current Status             ← Variable (append only)
[Updates go here]

## Errors Encountered         ← Append only
[New errors appended]

## Next Steps                 ← Append only
[Updates appended]
```

**Why This Works:**
- Static prefix stays in KV-cache
- Only new content needs processing
- Faster reads on repeated access
- Lower token costs

**Anti-Pattern:**
```markdown
# Bad: Constant Editing
## Current Status
Phase: 1  ← Edited to: Phase: 2  ← Edited to: Phase: 3
# Every edit invalidates cache
```

---

### 6. Append-Only Context

**Principle:** Never modify previous messages—always append new information.

**Why:**
- Preserves KV-cache efficiency
- Maintains history
- No cache invalidation
- Faster processing

**Implementation:**

**❌ Bad: Editing**
```markdown
# task_plan.md (Initial)
Phase: 1
Status: In progress

# task_plan.md (Edited)
Phase: 2  ← Edited line (cache invalidated)
Status: Complete ← Edited line (cache invalidated)
```

**✅ Good: Appending**
```markdown
# task_plan.md (Initial)
Phase: 1
Status: In progress

# task_plan.md (Appended)
Phase: 1
Status: In progress
---
Phase: 2  ← New content (cache preserved)
Status: In progress
```

**In Practice:**
```markdown
## Phase 1 Update
[Content]

## Phase 2 Update
[New content appended]

## Phase 3 Update
[More content appended]
```

---

## The Agent Loop

High-performing agents follow this loop:

```
1. Analyze
   ↓
2. Think
   ↓
3. Select Tool
   ↓
4. Execute
   ↓
5. Observe
   ↓
6. Iterate or Deliver
```

### Tool Operations

**Four core operations:**

1. **`write`** - Create new file
   ```
   Write task_plan.md with initial structure
   ```

2. **`append`** - Add to existing file
   ```
   Append error log to task_plan.md
   ```

3. **`edit`** - Modify specific section (use sparingly)
   ```
   Edit task_plan.md to mark phase complete
   ```

4. **`read`** - Retrieve information
   ```
   Read task_plan.md to refresh context
   ```

**Frequency:**
- `write`: Once per file
- `append`: Multiple times (main pattern)
- `read`: Before major decisions
- `edit`: Rarely (prefer append)

---

## Performance Metrics

### Context Engineering Impact

**Without file-based planning:**
- Success rate: ~60% for complex tasks
- Context loss after: ~30-50 tool calls
- Error recovery: Poor (silent retries)

**With file-based planning:**
- Success rate: ~85% for complex tasks
- Context maintained: 100+ tool calls
- Error recovery: Excellent (documented learning)

### Token Efficiency

**Naive approach:**
```
Context size grows linearly with task complexity
Cost: High token usage
Performance: Degrades over time
```

**File-based approach:**
```
Context stays focused on current phase
Cost: Lower token usage (external memory)
Performance: Stable across task duration
```

---

## Manus Context Engineering

These principles derive from Manus, which achieved exceptional performance through:

1. **Systematic context management**
2. **Persistent working memory (files)**
3. **Error documentation and learning**
4. **Cache-aware content structuring**
5. **Append-only updates**

**Key Insight:**
> The filesystem isn't just storage—it's an extension of the agent's working memory.

**Result:**
- $100M revenue in 8 months
- $2B acquisition by Meta
- Industry-leading agent performance

---

## Applying These Principles

### For Simple Tasks
- Principles 1, 2, 3 are sufficient
- Create task_plan.md
- Store large content externally
- Document errors

### For Complex Tasks
- Apply all 6 principles
- Use append-only pattern
- Optimize cache with stable prefixes
- Read plan frequently

### For Long-Running Projects
- File-based memory is essential
- Re-read plan every 25-50 calls
- Build comprehensive error logs
- Maintain stable content structure

---

## Common Mistakes

### ❌ Mistake 1: Keeping Everything in Context

```
Long research findings in active context
↓
Token limit issues
↓
Context truncation
↓
Lost information
```

**Solution:** Use notes.md as external memory.

### ❌ Mistake 2: Forgetting Original Goal

```
Start with clear objective
↓
50+ tool calls
↓
"What was I doing again?"
↓
Off track
```

**Solution:** Read task_plan.md before decisions.

### ❌ Mistake 3: Silent Error Recovery

```
Error occurs
↓
Retry immediately
↓
Error occurs again
↓
No learning
```

**Solution:** Log to task_plan.md with analysis.

### ❌ Mistake 4: Constant Editing

```
Edit file repeatedly
↓
Cache invalidated
↓
Slower processing
↓
Higher costs
```

**Solution:** Append new content instead.

---

## Quick Reference

### When to Use Each Principle

| Principle | When to Apply | Impact |
|-----------|---------------|--------|
| **Filesystem Memory** | Tasks with large data | Token savings |
| **Attention Repetition** | Multi-phase projects | Context preservation |
| **Failure Traces** | Any errors encountered | Learning & debugging |
| **Avoid Overfitting** | Pattern implementation | Quality & adaptability |
| **Stable Prefixes** | Long-running tasks | Cache efficiency |
| **Append-Only** | All updates | Performance |

### Decision Tree

```
Is task complex? (3+ phases)
    Yes → Create task_plan.md
    No → Direct implementation

Do you have large research data?
    Yes → Use notes.md
    No → Keep in context

Encountered an error?
    Yes → Log to task_plan.md
    No → Continue

Been working for 25+ tool calls?
    Yes → Read task_plan.md
    No → Continue

Making a major decision?
    Yes → Read task_plan.md first
    No → Proceed
```

---

## Further Reading

- **Manus Engineering Blog** - Context management strategies
- **KV-Cache Optimization** - Technical details on caching
- **Agent Loop Patterns** - Advanced agentic workflows

---

## Summary

**The Golden Rules:**

1. **Use files as memory** - Don't overload context
2. **Re-read your plan** - Combat context degradation
3. **Document errors** - Build understanding
4. **Vary your patterns** - Adapt to context
5. **Optimize for cache** - Stable prefixes, append-only
6. **Never edit, always append** - Preserve efficiency

**Remember:**
> Your task_plan.md is your anchor. Your notes.md is your memory. Your error log is your teacher.

---

**These principles transformed Manus into a $2B company. Apply them to transform your agent's performance.**