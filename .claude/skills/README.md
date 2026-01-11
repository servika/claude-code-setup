# Claude Code Skills

Specialized skill modules that provide in-depth guidance for specific development scenarios.

---

## What Are Skills?

Skills are focused instruction sets that teach Claude Code how to handle specific patterns, workflows, or best practices. Unlike agents (which generate code), skills provide **knowledge and methodology** for making better decisions.

---

## Available Skills

### 1. Planning with Files 📋

**Directory:** `planning-with-files/`

**Purpose:** File-based planning methodology for complex, multi-step tasks.

**Core Pattern:**
- `task_plan.md` - Track phases and progress
- `notes.md` - Store research findings
- `[deliverable].md` - Final output

**When to Use:**
- Multi-step tasks (3+ phases)
- Research projects
- Complex features
- Work spanning 10+ tool interactions

**Key Principle:**
> Re-read your plan before major decisions to maintain context

**Files:**
- `SKILL.md` - Complete methodology guide
- `examples.md` - Real-world examples with workflows
- `reference.md` - Context engineering principles (Manus-inspired)

**Usage:**
```
Claude, use the planning-with-files skill for this multi-phase project.

Create a task_plan.md to track:
1. Research phase
2. Implementation
3. Testing
4. Documentation
```

---

### 2. Release Documentation 📦

**Directory:** `release-documentation/`

**Purpose:** Automated generation of professional release notes, changelogs, and version documentation from git commits.

**Core Capabilities:**
- Parse Conventional Commits into changelogs
- Generate multiple formats (Markdown, JSON, HTML)
- Create migration guides for breaking changes
- Suggest semantic version bumps
- Separate customer vs developer documentation

**When to Use:**
- Preparing npm package releases
- Creating GitHub release notes
- Documenting breaking changes
- Writing customer update announcements
- Generating weekly product summaries

**Key Principle:**
> Audience-aware documentation - different content for customers vs developers

**Files:**
- `SKILL.md` - Complete release documentation guide
- `examples.md` - Real-world release scenarios
- `anti-patterns.md` - Common mistakes to avoid

**Usage:**
```
Claude, use the release-documentation skill to generate a changelog:

Version: 1.5.0
From: v1.4.2 to HEAD
Format: Markdown
Audience: Customer-facing
Include: Migration guide if breaking changes exist
```

---

## How to Use Skills

### Method 1: Reference During Development

When working on related tasks, mention the skill:

```
Claude, I'm building a complex multi-step feature.
Please apply the planning-with-files skill to help organize the implementation.
```

### Method 2: Ask for Skill Guidance

When unsure about an approach:

```
Claude, I'm building a feature with multiple phases.
Should I use the planning-with-files skill for this?
```

### Method 3: Proactive Application

Claude Code will automatically apply relevant skills when it recognizes patterns:

```
User: I need to build a complex authentication system with multiple steps

Claude: This is a multi-phase task. I'll use the planning-with-files skill.
Let me create a task_plan.md to track:
1. Research OAuth providers
2. Design auth flow
3. Implement backend
4. Create frontend components
5. Test and secure
```

---

## Skills vs Agents

### Agents 🤖
- **Generate code** based on templates
- Create files, components, APIs
- Produce tangible output
- Example: "Backend Generator Agent creates Express routes"

### Skills 📚
- **Provide methodology** and best practices
- Guide decision-making
- Teach patterns and principles
- Example: "Planning with Files skill teaches multi-step task organization"

**Use Together:**
```
1. Use Planning-with-Files skill to plan implementation
2. Use Backend Generator Agent to create API routes
3. Apply technology rules for best practices
4. Use Frontend Generator Agent to create UI components
```

---

## Creating Custom Skills

### Structure

```
.claude/skills/
└── your-skill-name/
    ├── SKILL.md          # Main skill documentation (required)
    ├── examples.md       # Usage examples (recommended)
    ├── anti-patterns.md  # Common mistakes (optional)
    ├── alternatives.md   # Better approaches (optional)
    └── reference.md      # Additional resources (optional)
```

### SKILL.md Template

```markdown
# [Skill Name]

Brief description of what this skill teaches.

---

## When to Use

- Use case 1
- Use case 2
- Use case 3

## When NOT to Use

- When condition 1
- When condition 2

## Core Principles

1. **Principle 1:** Explanation
2. **Principle 2:** Explanation
3. **Principle 3:** Explanation

## Patterns

### Pattern 1: [Name]

**Scenario:** When to use this pattern

**Implementation:**
```javascript
// Code example
```

**Why It Works:**
- Reason 1
- Reason 2

### Pattern 2: [Name]
...

## Quick Reference

| Scenario | Approach |
|----------|----------|
| Scenario 1 | Solution 1 |
| Scenario 2 | Solution 2 |

## Summary

Key takeaways...
```

---

## Skill Development Guidelines

### ✅ Good Skills

1. **Focused** - Cover one concept deeply
2. **Practical** - Include real-world examples
3. **Actionable** - Clear decision frameworks
4. **Comprehensive** - Cover anti-patterns and alternatives
5. **Referenced** - Link to authoritative sources

### ❌ Avoid

1. **Too broad** - "JavaScript best practices" (too general)
2. **No examples** - Theory without practice
3. **No context** - When to use vs when not to use
4. **Outdated** - Based on old patterns/versions
5. **Opinionated** - Without rationale

---

## Skills Roadmap

### Planned Skills

#### React Patterns
- `react-state-management/` - When to use Context vs Redux vs Zustand
- `react-performance/` - Optimization patterns (memo, useMemo, etc.)
- `react-hooks/` - Custom hooks best practices
- `react-testing/` - Component testing strategies

#### Node.js/Express
- `express-error-handling/` - Comprehensive error handling patterns
- `express-validation/` - Input validation strategies
- `express-security/` - Security best practices
- `database-patterns/` - Query optimization, migrations, transactions

#### Architecture
- `api-design/` - RESTful API design principles
- `authentication-strategies/` - JWT, sessions, OAuth patterns
- `caching-strategies/` - Redis, in-memory, CDN caching
- `microservices-communication/` - Service-to-service patterns

#### General Development
- `debugging-techniques/` - Systematic debugging approaches
- `code-review/` - What to look for in code reviews
- `refactoring-patterns/` - Safe refactoring strategies
- `testing-strategies/` - Unit, integration, E2E testing

---

## Integration with Configuration

Skills work seamlessly with the rest of the configuration:

```
.claude/
├── CLAUDE.md              # Main guidelines
├── rules/                 # Technology rules
│   ├── react.md          # → React patterns and best practices
│   ├── nodejs.md         # → Node.js and Express guidelines
│   └── commit-policy.md  # → Git and code comment standards
├── agents/               # Code generators
│   └── backend-generator.md  # → Uses planning skill for complex APIs
└── skills/               # Methodologies
    └── planning-with-files/
```

**Example Workflow:**
1. **Planning skill** - Create task_plan.md for authentication feature
2. **Rules** - Follow Node.js, React, and security patterns
3. **Backend agent** - Generate Express auth routes
4. **Rules** - Apply validation and error handling
5. **Frontend agent** - Generate login UI components

---

## Contributing Skills

To add a new skill to the project:

1. **Identify a gap** - What methodology is missing?
2. **Research thoroughly** - Find authoritative sources
3. **Create structure** - Follow the template above
4. **Add examples** - Real-world scenarios
5. **Document anti-patterns** - What NOT to do
6. **Provide alternatives** - Better approaches
7. **Test with projects** - Verify practical value
8. **Update this README** - Add to available skills list

---

## Best Practices for Using Skills

### 1. Learn the Skill First

Read through the SKILL.md file to understand:
- When to use it
- When NOT to use it
- Core principles
- Key patterns

### 2. Apply Systematically

Don't cherry-pick random parts. Apply the full methodology:

```
# Planning-with-Files Skill

✅ Create task_plan.md
✅ Store research in notes.md
✅ Re-read plan before decisions
✅ Document errors
✅ Update status after phases
```

### 3. Reference During Development

Keep skills in mind as you work:

```
// Starting a complex feature implementation
// 1. Create task_plan.md to track phases
// 2. Document decisions and errors as you go
// 3. Re-read plan before major decisions
```

### 4. Teach Your Team

Skills are valuable team knowledge:

```markdown
# Team Standards

When building complex features:
- Use planning-with-files skill (see .claude/skills/planning-with-files/)
- Create task_plan.md for multi-phase work
- Document all errors and resolutions
- Store research findings in notes.md
```

---

## FAQ

### Q: How are skills different from rules?

**Rules** (in `.claude/rules/`) provide general guidelines for a technology.
**Skills** provide deep methodology for specific scenarios within that technology.

Example:
- **Rule:** `nodejs.md` - "Use async/await for asynchronous operations"
- **Skill:** `planning-with-files/` - "Complete methodology for multi-step task planning"

### Q: When should I create a new skill vs updating rules?

Create a **skill** when:
- Topic needs multiple files (examples, anti-patterns, alternatives)
- Methodology is complex and multi-faceted
- Need decision frameworks and deep examples

Update **rules** when:
- Adding general guidelines
- Brief best practices
- Quick reference information

### Q: Can skills conflict with rules?

No. Skills provide **deeper guidance** within the boundaries set by rules.

Example:
- **Rule:** "Use ESM modules"
- **Skill:** "Planning-with-files: How to organize task files in ESM projects"

### Q: Should I memorize all skills?

No. Skills are **reference material**. Use them when:
- Starting a complex task
- Uncertain about approach
- Want to verify best practices
- Teaching team members

---

## Resources

### Context Engineering
- Manus principles (acquired by Meta for $2B)
- File-based memory patterns
- Agent performance optimization

### Community Resources
- [React Query](https://tanstack.com/query) - Server state management
- [SWR](https://swr.vercel.app/) - Data fetching hooks
- [Zustand](https://github.com/pmndrs/zustand) - Lightweight state management

---

## Summary

**Skills provide:**
- ✅ Deep methodology for specific scenarios
- ✅ Decision frameworks and patterns
- ✅ Anti-patterns to avoid
- ✅ Real-world examples
- ✅ Alternative approaches

**Current Skills:**
1. **Planning with Files** - Multi-step task methodology

**Usage:**
```
Claude, apply the [skill-name] skill to this task
```

---

**Skills transform good code into great code by teaching proven methodologies!** 🎓