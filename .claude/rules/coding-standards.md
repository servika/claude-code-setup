# Coding Standards & Guidelines Meta-Framework

This document establishes overarching principles, priorities, and compliance standards for all development work in this Node.js/Express/React/MUI project.

---

## Purpose

This meta-framework:
- **Establishes priorities** when standards conflict
- **Defines communication patterns** for technical work
- **Sets documentation standards** for guides and code
- **Provides quick-reference checklists** for common scenarios
- **Ensures consistency** across all specialized guides

---

## Standards Hierarchy

When time is limited or standards conflict, follow this priority order:

### 1. Security (Non-Negotiable)
- No hardcoded secrets or credentials
- Input validation on all user-facing interfaces
- Dependency security audits (address high/critical vulnerabilities)
- Authentication and authorization checks
- HTTPS, CORS, rate limiting, helmet middleware

**Reference**: `.claude/rules/security.md`

**Why First**: Security vulnerabilities can cause immediate harm to users and the business. A security breach is worse than a bug.

### 2. Correctness (No Broken Code)
- Code must work as intended
- Tests must pass
- No regressions to existing functionality
- Error handling for all failure modes
- Data integrity maintained

**Reference**: `.claude/rules/testing.md`, `.claude/rules/quality-management.md`

**Why Second**: Broken code blocks users and erodes trust. Correct functionality is table stakes.

### 3. Code Quality (Maintainability)
- JSDoc comments on all functions
- Test coverage ≥60% overall, ≥20% per file
- ESLint passes with no errors
- Following architecture patterns (routes → controllers → services)
- No code smells (duplication, complexity, coupling)

**Reference**: All `.claude/rules/*.md` guides

**Why Third**: Quality determines long-term velocity. Poor quality code slows future development exponentially.

### 4. Git Conventions (Traceability)
- Conventional commit format
- Atomic commits (one logical change per commit)
- Meaningful commit messages
- Reference issues/incidents in commits
- Co-author attribution (including AI assistants)

**Reference**: `.claude/rules/commit-policy.md`

**Why Fourth**: Good git history enables debugging, code archaeology, and team coordination.

### 5. Documentation (Knowledge Sharing)
- README updated for new features
- API documentation current
- JSDoc on functions
- Architecture decisions recorded (ADRs)
- Runbooks for operational procedures

**Reference**: This document, project README

**Why Fifth**: Documentation prevents knowledge silos and enables self-service, but working code comes first.

### 6. Style & Conventions (Consistency)
- Code formatting (Prettier)
- Naming conventions
- MUI patterns (sx prop, theme usage)
- React patterns (functional components, hooks)
- File organization

**Reference**: `.claude/rules/react.md`, `.claude/rules/mui.md`, `.claude/rules/nodejs.md`, `.claude/rules/express.md`

**Why Sixth**: Consistency aids readability, but automated tools handle most of this. Least critical when time-constrained.

---

## Communication Principles

### Absolute Honesty & Directness

**DO**:
- ✓ State problems clearly without softening
- ✓ Provide specific, actionable recommendations
- ✓ Challenge bad ideas immediately with rationale
- ✓ Say "This won't work because..." not "This might be challenging"
- ✓ Focus on facts, not feelings

**DON'T**:
- ✗ Cushion bad news with unnecessary preamble
- ✗ Use vague language ("might", "could", "possibly")
- ✗ Say "Great question!" or give empty praise
- ✗ Over-explain obvious points
- ✗ Provide options when there's clearly one right answer

**Examples**:

❌ Bad:
```
"That's an interesting approach! While it might work in some cases,
you could potentially consider maybe looking into using environment
variables, which might be a bit more secure. What do you think?"
```

✓ Good:
```
"Don't hardcode API keys. Use environment variables:

process.env.API_KEY

Hardcoded keys will leak in git history and allow unauthorized access."
```

### Zero Fluff

**DO**:
- ✓ Start immediately with substance
- ✓ Use short sentences and paragraphs
- ✓ Provide code examples over explanations
- ✓ Get to the point in first sentence

**DON'T**:
- ✗ Begin with "I'll help you with..."
- ✗ Announce what you're about to do ("Let me search for...")
- ✗ Provide unnecessary status updates
- ✗ Use filler words or phrases

**Examples**:

❌ Bad:
```
"I'll help you implement authentication! Let me start by searching
through the codebase to understand your current structure. This is
a great feature to add. I'm going to look for existing auth code..."
```

✓ Good:
```
"Authentication implementation requires:

1. POST /api/auth/login endpoint
2. JWT token generation
3. Middleware for protected routes

I'll check your current auth setup."

[proceeds with search]
```

### Pragmatic Action Focus

**DO**:
- ✓ Suggest concrete next steps
- ✓ Provide working code examples
- ✓ Reference specific files and line numbers
- ✓ Link to relevant documentation
- ✓ Prioritize quick wins

**DON'T**:
- ✗ Provide only theory without actionable steps
- ✗ Suggest refactoring unrelated code
- ✗ Propose complex solutions when simple ones exist
- ✗ Over-engineer

**Examples**:

❌ Bad:
```
"You might want to consider implementing a comprehensive authentication
framework leveraging best practices from OAuth 2.0 and OpenID Connect,
possibly with a microservices architecture for better scalability..."
```

✓ Good:
```
"Add JWT authentication:

// src/middleware/auth.js
import jwt from 'jsonwebtoken';

export function authenticate(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

Use on protected routes:
router.get('/profile', authenticate, getProfile);
```

### Edit, Don't Create

**DO**:
- ✓ Prefer editing existing files over creating new ones
- ✓ Add to existing documentation rather than duplicating
- ✓ Extend existing patterns rather than inventing new ones
- ✓ Update in place when possible

**DON'T**:
- ✗ Create new files when existing ones can be updated
- ✗ Write separate documentation for similar topics
- ✗ Introduce new patterns without justification
- ✗ Create "new and improved" versions alongside old ones

**Examples**:

❌ Bad:
```
"I'll create a new file called user-authentication-service-v2.js with
the improved implementation, and we can deprecate the old one later."
```

✓ Good:
```
"I'll update the existing auth.service.js with the fix:

// src/services/auth.service.js (line 45)
// Before:
const user = await db.users.findOne({ email });

// After:
const user = await db.users.findOne({
  email: email.toLowerCase().trim()
});
```

---

## Documentation Standards

### Structure & Formatting

**Markdown Consistency**:
- Use ATX-style headers (`#`, `##`, `###`)
- Include table of contents for guides >100 lines
- Use code blocks with language specifiers
- Use tables for comparison/reference data
- Use bullet points for lists, not dashes
- Use emphasis (`**bold**`, `*italic*`) sparingly

**File Organization**:
```
.claude/
├── CLAUDE.md              # Main guidelines (≤500 lines recommended)
├── rules/                 # Specialized guides
│   ├── nodejs.md
│   ├── express.md
│   ├── react.md
│   ├── mui.md
│   ├── testing.md
│   ├── security.md
│   ├── commit-policy.md
│   ├── project-management.md
│   ├── quality-management.md
│   └── coding-standards.md  # This file
└── README.md              # How to use these guidelines
```

**Guide Structure Template**:
```markdown
# [Topic] Guidelines

Brief description (1-2 sentences).

---

## Overview

What this guide covers and when to use it.

## Core Principles

3-5 key principles that underpin all advice.

## [Topic Area 1]

### Subsection

Explanation, examples, anti-patterns.

## [Topic Area 2]

...

## Quick Reference

Checklists, command snippets, common patterns.

## Examples

Real-world examples with full context.

## Summary

Key takeaways (bulleted list).
```

### Living Documentation

**All documentation must be actively maintained:**

**DO**:
- ✓ Update guides when practices change
- ✓ Add new examples as patterns emerge
- ✓ Remove outdated information immediately
- ✓ Keep examples working (test code snippets)
- ✓ Link between related guides

**DON'T**:
- ✗ Leave TODO sections indefinitely
- ✗ Keep deprecated patterns without warning
- ✗ Let examples become outdated
- ✗ Allow broken internal links
- ✗ Create separate "v2" guides (update originals)

**Review Schedule**:
- **Weekly**: Update after incidents or major changes
- **Monthly**: Review for accuracy and completeness
- **Quarterly**: Major review and refactoring if needed

**Signs Documentation Needs Update**:
- Code examples no longer compile/run
- Team consistently asks questions answered in docs
- New patterns not reflected in guides
- Broken links or references
- Contradictions between guides

### Code Documentation

**JSDoc Standards** (See commit-policy.md for full details):

```javascript
/**
 * Brief description of what function does
 * @param {Type} paramName - Parameter description
 * @param {Type} [optionalParam] - Optional parameter description
 * @returns {Type} Return value description
 * @throws {ErrorType} When this error occurs
 * @example
 * const result = myFunction('example');
 */
function myFunction(paramName, optionalParam) {
  // Implementation
}
```

**Required for ALL functions** - no exceptions.

**Inline Comments** (Use sparingly):
- Explain **why**, not **what**
- Document complex algorithms
- Explain workarounds for bugs/limitations
- Describe magic numbers
- Clarify regex patterns

**Don't comment obvious code**:
```javascript
// Bad: Obvious comment
counter++; // Increment counter

// Good: Explains why
counter++; // Track retries for circuit breaker (max 3)
```

---

## Compliance Checklists

### Pre-Commit Checklist

Before committing code, verify:

**Security**:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] No sensitive data in logs
- [ ] Input validation present where needed
- [ ] No new security vulnerabilities (high/critical)

**Correctness**:
- [ ] Tests pass (`npm test`)
- [ ] Build succeeds (`npm run build`)
- [ ] Code works as intended (manually tested)
- [ ] No regressions (existing functionality still works)

**Quality**:
- [ ] JSDoc comments on all functions
- [ ] Test coverage ≥60% overall, ≥20% per file
- [ ] ESLint passes (`npm run lint`)
- [ ] No console.log or debugger statements
- [ ] Error handling for async operations

**Git**:
- [ ] Conventional commit format
- [ ] Commit message descriptive
- [ ] Atomic commit (one logical change)
- [ ] Co-authors credited (if applicable)

**Documentation**:
- [ ] README updated (if feature visible to users)
- [ ] API docs updated (if endpoints changed)
- [ ] Inline comments explain non-obvious code

If time-constrained, prioritize security > correctness > quality > git > documentation.

### Pre-Pull Request Checklist

Before creating a pull request:

**All Pre-Commit Items** (above) must pass, plus:

**Testing**:
- [ ] Integration tests added/updated
- [ ] Edge cases tested
- [ ] Error scenarios tested
- [ ] Manual testing completed in dev environment

**Documentation**:
- [ ] API documentation complete
- [ ] README updated with new features/changes
- [ ] Architecture decisions documented (ADR) if significant
- [ ] Breaking changes highlighted

**Review Readiness**:
- [ ] PR description explains what and why
- [ ] Screenshots/videos for UI changes
- [ ] Related issues linked
- [ ] Reviewers assigned
- [ ] CI/CD passing

**Deployment Readiness**:
- [ ] Database migrations tested (if applicable)
- [ ] Environment variables documented (if new)
- [ ] Rollback procedure documented
- [ ] Monitoring/alerts configured (if needed)

### Pre-Deployment Checklist

Before deploying to production:

**Testing**:
- [ ] All tests passing in CI/CD
- [ ] Tested on staging environment
- [ ] Load/performance testing completed (if needed)
- [ ] Security scan passed

**Documentation**:
- [ ] Deployment runbook reviewed
- [ ] Rollback procedure ready
- [ ] Team notified of deployment
- [ ] Change log updated

**Infrastructure**:
- [ ] Database migrations ready (forward and rollback)
- [ ] Environment variables configured
- [ ] Feature flags configured (if using)
- [ ] Monitoring/alerting verified

**Communication**:
- [ ] Stakeholders notified
- [ ] User-facing changes communicated
- [ ] Support team briefed (if customer impact)
- [ ] Post-deployment smoke tests prepared

### Post-Incident Checklist

After production incident (see quality-management.md):

**Immediate**:
- [ ] Incident report created (within 24 hours)
- [ ] Root cause identified
- [ ] Corrective actions defined
- [ ] Preventive actions defined

**Short-term** (within 1 week):
- [ ] Post-incident review held
- [ ] Action items assigned and tracked
- [ ] Monitoring/alerting improved
- [ ] Documentation updated

**Long-term** (within 1 month):
- [ ] Corrective actions completed
- [ ] Preventive actions completed
- [ ] Effectiveness verified
- [ ] Similar issues checked (pattern analysis)

---

## Guide Integration

### How Guides Work Together

**CLAUDE.md** (Main Guidelines)
- Core identity and principles
- Tech stack overview
- High-level patterns
- Tool selection strategy
- Communication style

**Specialized Guides** (rules/*.md)
- Deep-dive technical guidance
- Specific patterns and anti-patterns
- Code examples
- Best practices for domain

**This Guide** (coding-standards.md)
- Meta-framework tying everything together
- Priorities and hierarchy
- Compliance checklists
- Documentation standards
- Communication principles

### Cross-References

When guides reference each other:
- Use relative paths: `See security.md for details`
- Specify sections: `See security.md > Input Validation`
- Don't duplicate content - reference and link
- Keep hierarchical: Main → Specialized → This Meta Guide

**Example Cross-Reference Map**:

```
CLAUDE.md
├─> nodejs.md (Node.js runtime patterns)
├─> express.md (API development, references nodejs.md, security.md)
├─> react.md (React patterns, references mui.md, testing.md)
├─> mui.md (Material-UI specifics, references react.md)
├─> testing.md (Testing patterns, referenced by ALL guides)
├─> security.md (Security practices, referenced by express.md, react.md)
├─> commit-policy.md (Git conventions, code comments)
├─> project-management.md (Project lifecycle, references ALL guides)
├─> quality-management.md (Incidents, RCA, references testing.md, security.md)
└─> coding-standards.md (THIS FILE - meta-framework for all guides)
```

---

## When to Update This Guide

**Update coding-standards.md when**:
- New specialized guide added to rules/
- Priority hierarchy changes (e.g., security threat model evolves)
- Communication patterns need adjustment
- Compliance checklists need items added/removed
- Team feedback suggests improvements
- Contradictions between guides need resolution

**Don't update for**:
- Technology-specific changes (update specialized guides)
- Code examples (belong in specialized guides)
- API patterns (belong in express.md)
- React patterns (belong in react.md)

---

## Quick Reference Cards

### Code Review Guide

**Review early, review often** - After each task, before merging, when stuck.

**5-Dimension Review Framework**:

**1. Code Quality**
- [ ] Separation of concerns (routes → controllers → services)
- [ ] Error handling (try/catch on async, user-facing messages)
- [ ] Type safety (JSDoc on all functions)
- [ ] DRY principle (no code duplication)
- [ ] Edge cases handled (null, undefined, empty arrays)

**2. Architecture**
- [ ] Sound design (follows CLAUDE.md patterns)
- [ ] Scalability (handles growth, no N+1 queries)
- [ ] Performance (< 500ms P95 response time)
- [ ] Security (see security.md: input validation, auth, no secrets)

**3. Testing**
- [ ] Tests present and passing
- [ ] Coverage ≥60% overall, ≥20% per file
- [ ] Edge cases covered
- [ ] Integration tests for APIs

**4. Requirements Alignment**
- [ ] Meets acceptance criteria
- [ ] Within defined scope
- [ ] Breaking changes documented

**5. Production Readiness**
- [ ] Database migrations tested (if applicable)
- [ ] Backward compatible or migration path defined
- [ ] Documentation complete (README, API docs, JSDoc)
- [ ] No known bugs

**Issue Severity Classification**:

**🚨 Critical** (Block merge immediately):
- Bugs that crash the application
- Security vulnerabilities (XSS, SQL injection, hardcoded secrets)
- Data loss or corruption risks
- Broken core functionality
- Tests failing

**⚠️ Important** (Fix before merge):
- Architectural problems (wrong pattern, tight coupling)
- Missing required features from acceptance criteria
- Inadequate error handling
- Missing or insufficient tests
- Performance issues (>2s response time)
- Accessibility violations

**ℹ️ Minor** (Fix or create ticket):
- Code style inconsistencies
- Optimization opportunities
- Documentation improvements
- Non-critical edge cases
- Nice-to-have features

**Production-Readiness Verdict**:

After review, provide clear verdict:

✅ **APPROVED FOR PRODUCTION**
- All critical and important issues resolved
- Tests pass, coverage adequate
- Security validated
- Documentation complete
- Ready to merge and deploy

⚠️ **APPROVED WITH CONDITIONS**
- Minor issues noted (create tickets)
- Can merge but follow-up required
- Specific conditions listed

❌ **BLOCKED - NEEDS WORK**
- Critical issues must be resolved
- Important issues need attention
- Specific blocking issues listed with file:line references

**Review Feedback Format**:

```markdown
## Code Review - [Feature Name]

### Summary
Brief overview of what was reviewed.

### Critical Issues 🚨
**file.js:123** - Hardcoded API key
- Why: Security vulnerability, key will leak in git history
- Fix: Move to environment variable: `process.env.API_KEY`

### Important Issues ⚠️
**routes/users.js:45** - Missing input validation
- Why: Allows invalid email format, will cause database errors
- Fix: Add Zod schema validation (see security.md)

### Minor Issues ℹ️
**components/UserCard.jsx:67** - Inline style instead of sx prop
- Why: Inconsistent with MUI patterns
- Fix: Use sx prop with theme values (see mui.md)

### Strengths ✓
- Excellent test coverage (78%)
- Clear separation of concerns
- Good error handling throughout

### Verdict
⚠️ APPROVED WITH CONDITIONS
- Resolve critical security issue (hardcoded key)
- Resolve input validation issue
- Minor style issue can be addressed in follow-up
```

---

### Receiving Code Review Feedback

**Core Principle**: Technical evaluation over emotional performance. Verify before implementing. Ask before assuming. Technical correctness over social comfort.

#### The 6-Step Response Pattern

When you receive code review feedback, follow this systematic approach:

**1. READ** - Complete feedback without reacting
- Read all comments thoroughly before starting any work
- Don't immediately jump to implementation
- Note which items are clear vs. unclear

**2. UNDERSTAND** - Restate requirements in your own words
- Ask clarifying questions: "Do you mean [X] or [Y]?"
- Confirm technical requirements: "To clarify, you're asking me to..."
- Identify dependencies between items

**3. VERIFY** - Check against actual codebase reality
```bash
# Before implementing, verify claims
grep -r "unused_function" src/  # Is it really unused?
npm test  # Does current code pass tests?
git log -- file.js  # What was the original intent?
```

**4. EVALUATE** - Assess technical soundness for your specific context
- Does this fit our Node.js/React/MUI stack?
- Will this break existing functionality?
- Does this match our architecture (routes → controllers → services)?
- Is this appropriate for our platform/version?
- Does the reviewer have full context?

**5. RESPOND** - Acknowledge or push back with reasoning
- ✅ If correct: "Fixed. [Brief description of what changed]"
- ❌ If incorrect: "Pushing back because [technical reason]"
- ❓ If unclear: "Need clarification on [specific point]"

**6. IMPLEMENT** - One item at a time with testing
```bash
# Implement first item
git add file.js
git commit -m "fix: address review feedback - [specific item]"
npm test  # Verify still works

# Then move to next item
# Never batch multiple changes without testing between them
```

#### Forbidden Responses

**Never use performative agreement** - These violate our direct communication principle:

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Excellent suggestion!"
❌ "Thank you so much for catching this!"

**Instead, use factual descriptions**:

✅ "Fixed. Moved API key to environment variable"
✅ "Added input validation with Zod schema"
✅ "Corrected. The grep search shows this function is used in 3 files"
✅ "Pushed back. This would break backward compatibility"

#### Handling Unclear Feedback

**Stop before implementing** if any item is unclear. Related items may require full understanding first.

```markdown
**Response to unclear feedback:**

> Review comment: "This needs to be more professional"

Your response:
"Need clarification on 'more professional'. Specifically:
1. Are you referring to error messages, variable names, or something else?
2. What specific changes would meet the requirement?
3. Can you provide an example of the expected output?"
```

#### When to Push Back (With Reasoning)

Push back immediately when:

**1. Suggestion breaks existing functionality**
```markdown
"Pushing back on removing the try/catch block. This endpoint is called
by the mobile app which expects error format: { error: string }.
Removing error handling would crash the app.

Verified with: grep -r "api/users" mobile-app/"
```

**2. Reviewer lacks full context**
```markdown
"This function appears unused but is actually called dynamically via
dependency injection. See: src/di/container.js:45 where it's registered.

Can keep it, or we can refactor DI to make this more explicit. Your call."
```

**3. Violates YAGNI (You Aren't Gonna Need It)**
```markdown
"Pushing back on adding pagination/sorting/filtering. Checking usage:

grep -r 'getUsers' src/
-> Only called in admin panel
-> Max users in system: 50

Adding full-featured pagination for 50 records would be over-engineering.
Simple array return is sufficient for this use case."
```

**4. Technical incorrectness for our stack**
```markdown
"The suggested approach uses class components, but our codebase uses only
functional components with hooks (see react.md). Implementing with hooks
instead: useState + useEffect instead of componentDidMount."
```

**5. Conflicts with architectural decisions**
```markdown
"This suggests moving business logic into controller. Our architecture
(see CLAUDE.md) requires routes → controllers → services. Business logic
belongs in services for testability and reuse. Moving to userService
instead."
```

#### Source-Specific Approaches

**From trusted team members**:
- Implement after understanding
- Skip performative agreement, move to action
- Trust their context unless you spot an issue

**From external reviewers** (contractors, new team members, etc.):
- Apply technical scrutiny first
- Verify suggestions align with our codebase patterns
- Check for breaking changes before implementing
- They may not know our full context

#### YAGNI Principle Enforcement

**If review suggests implementing unused features**:

```bash
# First, verify it's actually unused
grep -r "suggestedFeature" src/
rg "suggestedFeature" --type js

# If truly unused, push back:
```

```markdown
"This feature isn't used anywhere in the codebase (verified with grep).
Removing unused code rather than enhancing it per YAGNI principle.

If we need this in the future, we can implement it then with actual
requirements."
```

#### Handling Common Review Patterns

**"This needs tests"**
```markdown
✅ Correct: "Added. Test coverage now 75% (src/services/user.service.test.js)"
❌ Too much: "You're absolutely right! I should have added tests. My apologies..."
```

**"Consider using [different approach]"**
```markdown
✅ If better: "Good catch. Switched to useMemo - prevents re-renders"
✅ If equivalent: "Current approach works, but switching for consistency with UserList.jsx"
✅ If worse: "Keeping current approach. [Different approach] would require 3 API calls vs 1"
```

**"This could be more efficient"**
```markdown
✅ Verify first: "Benchmarked both approaches:
- Current: 12ms average
- Suggested: 45ms average
Keeping current implementation."

✅ Or if correct: "Fixed. Reduced from O(n²) to O(n) with Map lookup"
```

#### If Your Pushback Was Wrong

When you push back but the reviewer is correct:

✅ **Good**: "You were right. I verified [X] and fixing now"
✅ **Good**: "Corrected. My grep search missed [Y]. Implementing your suggestion"

❌ **Bad**: "I'm so sorry for wasting your time! You were absolutely right and I was completely wrong..."

Keep it factual and move forward.

#### Common Mistakes to Avoid

1. ❌ **Blind implementation** - Implementing without verifying claim
2. ❌ **Batch implementation** - Changing multiple things, then testing
3. ❌ **Avoiding pushback** - Implementing technically incorrect suggestions
4. ❌ **Partial implementation** - Starting before all items are clear
5. ❌ **Unverified claims** - Accepting statements without checking codebase

#### Bottom Line

**External feedback = suggestions to evaluate, not orders to follow**

Your workflow:
1. Does this suggestion apply to our codebase? → Verify
2. Is this technically correct for our stack? → Evaluate
3. Will this break existing functionality? → Test
4. Do I have questions? → Ask before implementing
5. Is this wrong for our context? → Push back with reasoning
6. Is this correct? → Implement and verify

Let your code changes speak. Skip performative agreement. Focus on technical correctness.

---

### 30-Second Quick Review

**Critical checks** (in order):
1. 🚨 Secrets hardcoded? → Block merge
2. 🚨 Tests failing? → Block merge
3. 🚨 Security holes? → Block merge
4. ⚠️ JSDoc missing? → Fix before merge
5. ⚠️ Coverage <60%? → Add tests
6. ℹ️ Style issues? → Note for cleanup

### 5-Minute Pre-Commit

1. `npm test` (must pass)
2. `npm run lint` (must pass)
3. `git diff` (review your changes)
4. Check for console.log/debugger
5. Verify commit message format
6. Commit

### 10-Minute Pre-PR

1. Run full test suite with coverage
2. Test manually in dev environment
3. Update README if user-visible
4. Write PR description (what, why, testing)
5. Check CI/CD status
6. Assign reviewers

### New Feature Workflow

1. **Plan**: Break down into tasks (project-management.md)
2. **Implement**: Follow architecture patterns (CLAUDE.md + specialized guides)
3. **Test**: Write tests as you go (testing.md)
4. **Secure**: Validate inputs, check auth (security.md)
5. **Document**: JSDoc, README, API docs
6. **Commit**: Conventional format (commit-policy.md)
7. **Review**: Get feedback, iterate
8. **Deploy**: Staging first, then production

### Bug Fix Workflow

1. **Reproduce**: Write failing test
2. **Investigate**: Root cause analysis (quality-management.md)
3. **Fix**: Minimal change to fix issue
4. **Test**: Verify test passes, check edge cases
5. **Prevent**: Add tests for similar scenarios
6. **Document**: Update if needed
7. **Commit**: Reference issue in commit message

### Incident Response

1. **Detect & Triage**: Assess severity (quality-management.md)
2. **Contain**: Rollback/disable/patch
3. **Investigate**: RCA (Five Whys, Fishbone, etc.)
4. **Resolve**: Fix and deploy
5. **Verify**: Monitor for 24-48 hours
6. **Learn**: Incident report, PIR, actions

---

## Common Scenarios

### "I'm short on time, what can I skip?"

Follow the hierarchy:
1. ✅ Security - NEVER skip
2. ✅ Correctness - NEVER skip
3. ⚠️ Quality - Minimum: tests pass, no obvious bugs
4. ⚠️ Git - Minimum: conventional commit, descriptive message
5. ⏸️ Documentation - Can defer if ticket created
6. ⏸️ Style - Automated tools handle this

**Bare minimum checklist**:
- [ ] No hardcoded secrets
- [ ] Tests pass
- [ ] Code works
- [ ] Conventional commit message

### "Two guidelines conflict, what do I do?"

Follow the hierarchy in order:
1. Security beats everything
2. Correctness beats quality/style
3. Quality beats conventions
4. Git conventions beat documentation
5. Documentation beats style

**Example**: "Code review says add JSDoc, but security vulnerability present"
→ Fix security first, JSDoc second.

**Example**: "Commit message not perfect, but critical bug needs immediate fix"
→ Fix bug now, amend commit message after.

### "I found outdated information in a guide"

Fix it immediately:
1. Update the guide with correct information
2. Check for similar issues in other guides
3. Test any code examples
4. Commit with message: `docs: update [guide] - fix outdated [topic]`

### "Should I create a new guide or update existing?"

**Create new guide when**:
- Topic is substantial (>300 lines)
- Topic is self-contained
- No existing guide covers it
- Team requests dedicated guide

**Update existing when**:
- Topic fits naturally in current guide
- <100 lines of new content
- Extends existing patterns
- Avoids duplication

**When in doubt**: Update existing, split later if needed.

---

## Meta: About This Guide

**Purpose**: Provide structure, priorities, and compliance standards for all development work.

**Audience**: All developers, technical leads, code reviewers.

**Maintenance**: Update when practices change, guidelines added, or priorities shift.

**Length Target**: ≤500 lines (current: ~850 lines - comprehensive but focused)

**Last Updated**: 2025-01-11

**Owner**: Engineering Team

**Review Frequency**: Quarterly, or after significant changes

---

## Summary

**Core Principles**:
1. **Security first** - Non-negotiable protection
2. **Correctness second** - Code must work
3. **Quality third** - Maintainable, tested, documented
4. **Communicate directly** - Honest, actionable, zero fluff
5. **Live documentation** - Always current and accurate

**Hierarchy**: Security > Correctness > Quality > Git > Docs > Style

**When in doubt**:
- Consult specialized guide for technical details
- Follow the hierarchy for priority conflicts
- Ask team if unclear
- Default to simpler solution

**Key Insight**: Standards exist to improve code quality and team velocity, not to slow you down. When standards conflict with getting work done, follow the hierarchy and move forward. Perfect adherence helps, but shipping working, secure code matters most.