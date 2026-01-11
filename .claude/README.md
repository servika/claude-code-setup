# Claude Code Guidelines System

Comprehensive development guidelines for Node.js/Express/React/MUI projects.

---

## Quick Start

**For developers**: Read `CLAUDE.md` first, then reference specialized guides as needed.

**For Claude**: All guides are automatically loaded. Use them to provide consistent, high-quality code and advice.

---

## Structure

```
.claude/
├── CLAUDE.md                      # START HERE - Main guidelines
├── README.md                      # This file - system overview
└── rules/                         # Specialized deep-dive guides
    ├── coding-standards.md        # Meta-framework (priorities, checklists)
    ├── nodejs.md                  # Node.js runtime patterns
    ├── express.md                 # Express.js API development
    ├── react.md                   # React development patterns
    ├── mui.md                     # Material-UI components
    ├── testing.md                 # Testing best practices
    ├── security.md                # Security requirements
    ├── ci-cd.md                   # CI/CD pipelines & deployment
    ├── commit-policy.md           # Git conventions & comments
    ├── project-management.md      # Project lifecycle & delivery
    ├── quality-management.md      # Incident response & CAPA
    └── package-json.md            # Package.json configuration
```

---

## Guide Descriptions

### Core Guidelines

**CLAUDE.md** - Main development guidelines (357 lines)
- Core identity and tech stack
- Architecture patterns (Express, React, MUI)
- Tool selection strategy
- Todo management
- Verification checklist
- Communication style

**Start here** for overview, then dive into specialized guides.

### Meta-Framework

**rules/coding-standards.md** - Standards hierarchy and compliance (850 lines)
- **Standards hierarchy**: Security > Correctness > Quality > Git > Docs > Style
- **Communication principles**: Direct, honest, zero fluff
- **Documentation standards**: Structure, formatting, living docs
- **Compliance checklists**: Pre-commit, pre-PR, pre-deployment, post-incident
- **Quick reference cards**: 30-second code review, workflows

Use this to:
- Resolve conflicts between guidelines
- Understand priority when time-constrained
- Quick reference before commits/PRs
- Ensure consistency across guides

### Technology Guides

**rules/nodejs.md** - Node.js runtime (395 lines)
- Module system (ESM vs CommonJS)
- Built-in modules (fs, path, crypto)
- Environment variables
- Error handling patterns
- Process management
- Package management
- Performance optimization

**rules/express.md** - Express.js APIs (632 lines)
- Project structure (routes → controllers → services)
- Middleware chain order
- Error handling patterns
- Request validation
- Authentication & authorization
- Security best practices
- File uploads
- Performance & caching

**rules/react.md** - React development (688 lines)
- Component structure (functional only)
- Props and TypeScript
- Hooks best practices
- Performance optimization (memo, useMemo, useCallback)
- State management (local → Context → Redux)
- Forms with react-hook-form
- Error boundaries
- Accessibility

**rules/mui.md** - Material-UI components (862 lines)
- Theme setup and customization
- sx prop styling (never inline styles)
- Grid layout and responsive design
- Typography, buttons, forms
- Dialogs, snackbars, tables
- Icon optimization
- Performance tips

**rules/package-json.md** - Package configuration (411 lines)
- Essential fields and metadata
- Scripts organization
- Dependencies management
- Version ranges (exact vs caret vs tilde)
- Engine requirements
- Complete examples

### Quality & Process Guides

**rules/testing.md** - Testing practices (579 lines)
- Test structure (Given-When-Then)
- Naming conventions
- Mocking best practices
- Coverage requirements (60% overall, 20% per file)
- Async testing patterns
- React component testing
- API testing with supertest

**rules/security.md** - Security requirements (589 lines)
- Input validation (never trust client)
- SQL/NoSQL injection prevention
- XSS prevention
- Authentication & authorization
- Password hashing (bcrypt)
- JWT implementation
- Secrets management
- CORS configuration
- Rate limiting
- File upload security

**rules/ci-cd.md** - CI/CD pipelines & deployment (850+ lines)
- GitHub Actions workflows (CI, security, deploy)
- Testing in CI (unit, integration, E2E, smoke)
- Deployment strategies (blue-green, rolling, canary)
- Environment management (staging, production)
- Secrets and environment variables
- Rollback procedures
- Monitoring and notifications
- Best practices and security

**rules/commit-policy.md** - Git conventions (702 lines)
- Conventional commits format
- Commit message structure
- Code comments policy (JSDoc required)
- TODO comments policy
- Atomic commits
- Branch naming
- Pull request guidelines

**rules/project-management.md** - Project lifecycle (1006 lines)
- 6-phase lifecycle: Discovery → Tasks → Implementation → Testing → Docs → Release
- Task breakdown methodology
- Sprint planning (optional agile practices)
- Risk management
- Technical debt tracking
- Stakeholder communication
- Templates (feature, bug report, status update)

**rules/quality-management.md** - Incident response (1466 lines)
- Incident classification (P0-P3 severity)
- 5-phase incident response
- Root cause analysis (Five Whys, Fishbone, Fault Tree, etc.)
- Corrective vs preventive actions
- Quality metrics (MTTD, MTTA, MTTR)
- Templates (incident report, PIR, playbooks)
- Continuous improvement

---

## How to Use These Guides

### For New Team Members

**Day 1**: Read CLAUDE.md
- Understand tech stack and architecture
- Learn communication style
- Understand tool selection
- Learn verification checklist

**Week 1**: Scan specialized guides
- Read guides for your primary focus area
- Bookmark for reference
- Note patterns and anti-patterns

**Month 1**: Deep dive as needed
- Reference guides when implementing features
- Learn best practices for your domain
- Use checklists before commits/PRs

### For Experienced Developers

**Before starting a feature**:
1. Review project-management.md (task breakdown)
2. Check relevant technology guides (nodejs, express, react, mui)
3. Review security.md (input validation, auth requirements)

**During development**:
1. Reference guides as needed
2. Use coding-standards.md for quick checks
3. Follow patterns from CLAUDE.md

**Before committing**:
1. Use pre-commit checklist (coding-standards.md)
2. Verify conventional commit format (commit-policy.md)
3. Check test coverage (testing.md)

**Before pull request**:
1. Use pre-PR checklist (coding-standards.md)
2. Update documentation
3. Test in dev environment
4. Verify CI/CD passes (ci-cd.md)

**Before deployment**:
1. Review ci-cd.md (deployment strategies)
2. Verify staging deployment successful
3. Check rollback procedure ready
4. Run smoke tests

**After incidents**:
1. Follow incident response (quality-management.md)
2. Perform RCA
3. Document lessons learned

### For Code Reviewers

**Quick review** (5 minutes):
1. Check pre-commit checklist items (coding-standards.md)
2. Verify tests pass and coverage adequate
3. Check for security issues (hardcoded secrets, validation)
4. Verify conventional commit format

**Thorough review** (15-30 minutes):
1. All quick review items
2. Verify architecture patterns followed (CLAUDE.md)
3. Check code quality (JSDoc, error handling, complexity)
4. Review test coverage and edge cases
5. Verify documentation updated

**Reference guides for**:
- Security concerns → security.md
- Testing patterns → testing.md
- React patterns → react.md
- Express patterns → express.md
- MUI usage → mui.md

---

## Standards Hierarchy

When guidelines conflict or time is limited:

**1. Security** (Non-Negotiable)
- No hardcoded secrets
- Input validation
- Authentication/authorization
- Dependency audits

**2. Correctness** (No Broken Code)
- Tests pass
- Code works as intended
- No regressions
- Error handling present

**3. Code Quality** (Maintainability)
- JSDoc on functions
- Test coverage ≥60%
- ESLint passes
- Follows architecture patterns

**4. Git Conventions** (Traceability)
- Conventional commits
- Atomic commits
- Meaningful messages

**5. Documentation** (Knowledge Sharing)
- README updated
- API docs current
- Comments explain non-obvious code

**6. Style & Conventions** (Consistency)
- Formatting (automated)
- Naming conventions
- Pattern consistency

See `rules/coding-standards.md` for detailed priority guidance.

---

## Quick Reference

### Pre-Commit Checklist

Essential checks before committing:

- [ ] No hardcoded secrets
- [ ] Tests pass (`npm test`)
- [ ] ESLint passes (`npm run lint`)
- [ ] JSDoc on new functions
- [ ] Test coverage ≥60% overall, ≥20% per file
- [ ] Conventional commit message
- [ ] No console.log/debugger

Full checklist: `rules/coding-standards.md`

### Pre-PR Checklist

Additional checks before pull request:

- [ ] All pre-commit items pass
- [ ] Integration tests added
- [ ] Manual testing complete
- [ ] README updated (if needed)
- [ ] API docs updated (if endpoints changed)
- [ ] PR description complete
- [ ] Reviewers assigned

Full checklist: `rules/coding-standards.md`

### Common Commands

```bash
# Run tests
npm test

# Run tests with coverage
npm test -- --coverage

# Lint code
npm run lint

# Fix lint errors
npm run lint -- --fix

# Format code
npm run format

# Build for production
npm run build

# Type check (if TypeScript)
npm run type-check
```

---

## Guide Maintenance

### When to Update Guides

**Update immediately when**:
- Code examples become outdated
- Security vulnerabilities discovered
- Team identifies gaps or errors
- New patterns emerge as best practices

**Review quarterly**:
- Check all code examples still work
- Remove deprecated patterns
- Add new examples from recent work
- Fix broken links

**Update after incidents**:
- Add lessons learned to relevant guides
- Update quality-management.md with new playbooks
- Add preventive patterns to avoid recurrence

### How to Update Guides

1. **Identify what needs updating**
   - Outdated code examples
   - New best practices
   - Missing information
   - Contradictions

2. **Make changes**
   - Edit existing content (don't create duplicates)
   - Test code examples
   - Update cross-references
   - Fix broken links

3. **Commit with clear message**
   ```
   docs(express): update JWT authentication example

   - Use async/await instead of promises
   - Add error handling for expired tokens
   - Update to jsonwebtoken v9.0
   ```

4. **Notify team** (if significant change)
   - Announce in team chat
   - Highlight breaking changes
   - Link to updated guide

### Signs a Guide Needs Updating

- Code examples don't compile/run
- Team asks questions already answered in guide
- New patterns not documented
- Contradictions between guides
- Links return 404
- Examples use deprecated packages

---

## FAQ

### Q: Which guide should I read first?
**A**: Start with `CLAUDE.md` for overview, then `rules/coding-standards.md` for priorities and checklists. Then read guides relevant to your work.

### Q: Do I need to memorize all these guides?
**A**: No. Read `CLAUDE.md` thoroughly, scan specialized guides, bookmark for reference. Use checklists before commits/PRs.

### Q: What if two guides conflict?
**A**: Follow the hierarchy in `rules/coding-standards.md`:
Security > Correctness > Quality > Git > Docs > Style

### Q: How do I know which guide covers my question?
**A**: See guide descriptions above, or search all `.md` files:
```bash
grep -r "your search term" .claude/
```

### Q: Can I suggest improvements to guides?
**A**: Yes! Create PR with changes, or file issue describing the gap/error.

### Q: Are these guidelines mandatory?
**A**: Security is non-negotiable. Correctness and quality are strongly recommended. Other guidelines help maintain consistency but can be adapted for specific situations.

### Q: What if I'm in a hurry?
**A**: Follow minimum checklist from `rules/coding-standards.md`:
1. No hardcoded secrets ✓
2. Tests pass ✓
3. Code works ✓
4. Conventional commit ✓

### Q: How often should I reference these guides?
**A**:
- **Daily**: Pre-commit checklist
- **Weekly**: When implementing new features
- **Monthly**: Deep dive on one specialized guide
- **As needed**: When stuck or unsure

### Q: Can Claude Code access these automatically?
**A**: Yes! Claude automatically loads all `.md` files in `.claude/` directory. You can ask Claude to reference specific guidelines.

---

## Examples of Using These Guides

### Example 1: Implementing Authentication

**Situation**: Need to add user authentication

**Process**:
1. Read `rules/project-management.md` → Break down into tasks
2. Read `rules/express.md` → Learn Express patterns
3. Read `rules/security.md` → Understand auth requirements
4. Read `rules/testing.md` → Know testing approach
5. Implement following patterns from guides
6. Use pre-commit checklist before committing
7. Use pre-PR checklist before creating PR

**Result**: Well-structured, secure, tested authentication system

### Example 2: Fixing Production Bug

**Situation**: Login fails in production, works in dev

**Process**:
1. Follow `rules/quality-management.md` → Incident response
2. Classify severity (P1 - High)
3. Contain issue (rollback or hotfix)
4. Investigate using RCA methodology
5. Fix bug following `rules/express.md` patterns
6. Test thoroughly per `rules/testing.md`
7. Commit using `rules/commit-policy.md` format
8. Complete incident report
9. Verify effectiveness after 1 week

**Result**: Bug fixed, root cause understood, preventive actions in place

### Example 3: Code Review

**Situation**: Reviewing PR for new API endpoint

**Process**:
1. Check pre-commit items from `rules/coding-standards.md`
2. Verify Express patterns from `rules/express.md`
3. Check security from `rules/security.md`
4. Verify tests from `rules/testing.md`
5. Check commit messages from `rules/commit-policy.md`
6. Provide feedback using direct communication style

**Result**: Thorough, consistent review catching issues early

---

## Credits & Maintenance

**Created**: 2025-01-11

**Maintained by**: Engineering Team

**Inspired by**:
- [Conventional Commits](https://www.conventionalcommits.org/)
- CAPA (Corrective and Preventive Action) principles
- Agile software development practices
- Material-UI documentation
- React documentation
- Express.js best practices

**Contributing**:
- Update guides when practices evolve
- Add examples from real work
- Fix errors immediately
- Suggest improvements via PR

**License**: Internal use for this project

---

## Summary

This guidelines system provides:
- ✅ **Consistency**: Common patterns across team
- ✅ **Quality**: High standards for code and processes
- ✅ **Velocity**: Clear guidance speeds decisions
- ✅ **Knowledge**: Documented best practices
- ✅ **Safety**: Security and quality focus

**Key Principle**: Guidelines enable great code, they don't slow you down. When in doubt, follow the hierarchy, use your judgment, and ship working code.

**Remember**: Perfect adherence helps, but shipping secure, working code matters most.