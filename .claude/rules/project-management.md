# Software Project Management & Delivery

These guidelines define project planning, feature delivery, and team collaboration practices for Node.js/React/MUI projects.

---

## Project Lifecycle Phases

### Phase 1: Discovery & Planning

**Before Writing Code**

When starting a new feature or project:

1. **Understand the Problem**
   - What user need or business goal does this address?
   - What are the acceptance criteria?
   - What are the technical constraints?
   - Are there dependencies on other systems or teams?

2. **Define Scope Clearly**
   - What's included in this iteration?
   - What's explicitly out of scope?
   - What's the minimum viable implementation?
   - What are the "nice-to-haves" vs "must-haves"?

3. **Identify Technical Approach**
   - Backend architecture (routes, controllers, services, data models)
   - Frontend components (pages, layouts, shared components)
   - Database schema changes
   - API contracts (request/response formats)
   - Third-party integrations
   - Authentication/authorization requirements

**Example: User Authentication Feature**

```markdown
## Problem Statement
Users need secure login/logout functionality with JWT-based sessions.

## In Scope
- User registration with email/password
- Login endpoint with JWT token generation
- Password hashing (bcrypt)
- Protected route middleware
- Frontend login/register forms (MUI)
- Session persistence (httpOnly cookies)

## Out of Scope
- OAuth/social login (future iteration)
- Password reset flow (separate feature)
- Two-factor authentication (future consideration)

## Technical Approach
Backend:
- POST /api/auth/register - Create user account
- POST /api/auth/login - Generate JWT token
- POST /api/auth/logout - Clear session
- Middleware: authenticate() for protected routes
- Validation: Zod schemas for email/password

Frontend:
- /login and /register pages
- AuthContext for user state
- Protected route wrapper component
- MUI TextField, Button components
- Form validation with react-hook-form

Database:
- users table: id, email, password_hash, created_at, role

Dependencies:
- bcrypt for password hashing
- jsonwebtoken for JWT
- express-rate-limit for brute force protection
```

### Phase 2: Task Breakdown

**Converting Features into Actionable Tasks**

Break down features into atomic, testable units. Use TodoWrite tool for tracking.

**Task Sizing Guidelines**
- **Small**: 30 minutes - 2 hours (ideal)
- **Medium**: 2-4 hours (acceptable)
- **Large**: 4+ hours (break down further)

**Task Types**

1. **Backend Tasks**
   - Create database migration
   - Implement data model
   - Create route file
   - Implement controller logic
   - Add validation middleware
   - Write service layer business logic
   - Add error handling
   - Write unit tests
   - Write integration tests

2. **Frontend Tasks**
   - Create page component
   - Implement form with validation
   - Add MUI styling and theme integration
   - Implement state management (Context/Query)
   - Add loading/error states
   - Implement responsive design
   - Add accessibility attributes
   - Write component tests
   - Write user interaction tests

3. **Integration Tasks**
   - Connect frontend to API endpoints
   - Handle authentication flow
   - Implement error handling and user feedback
   - Add loading indicators
   - Test end-to-end flow

4. **Quality Tasks**
   - Add JSDoc comments
   - Verify test coverage (60%+ overall, 20%+ per file)
   - Run ESLint and fix issues
   - Security audit (input validation, XSS, SQL injection)
   - Accessibility audit
   - Performance testing
   - Update documentation

**Example Task Breakdown (Auth Feature)**

```
[ pending ] Database: Create users table migration
[ pending ] Backend: Create User model with password hashing
[ pending ] Backend: Implement POST /api/auth/register endpoint
[ pending ] Backend: Implement POST /api/auth/login endpoint
[ pending ] Backend: Create authenticate() middleware
[ pending ] Backend: Add rate limiting to auth routes
[ pending ] Backend: Write auth service unit tests
[ pending ] Backend: Write auth API integration tests
[ pending ] Frontend: Create AuthContext provider
[ pending ] Frontend: Implement Register page with MUI
[ pending ] Frontend: Implement Login page with MUI
[ pending ] Frontend: Create ProtectedRoute wrapper
[ pending ] Frontend: Add form validation with react-hook-form
[ pending ] Frontend: Write component tests
[ pending ] Integration: Connect login form to API
[ pending ] Integration: Test error handling and edge cases
[ pending ] Quality: Add JSDoc to all functions
[ pending ] Quality: Verify 60%+ test coverage
[ pending ] Quality: Security audit (validation, rate limits)
[ pending ] Documentation: Update API docs with auth endpoints
[ pending ] Documentation: Add authentication guide to README
```

### Phase 3: Implementation

**Development Workflow**

1. **Start with Backend First (if full-stack feature)**
   - Define API contracts
   - Implement and test endpoints
   - Document with JSDoc and API docs
   - Validate with integration tests

2. **Then Implement Frontend**
   - Mock API responses during development
   - Build UI components
   - Connect to real API
   - Add error handling and loading states

3. **Follow the Todo Discipline**
   - Mark ONE task as `in_progress` at a time
   - Complete fully before moving to next
   - Don't batch completions - mark done immediately
   - Update todos if scope changes

4. **Commit Frequently**
   - One logical change per commit
   - Follow conventional commit format
   - Commit after each completed task
   - Don't commit broken code

**Code Review Checkpoints**

Before marking task complete:
- ✅ Code passes ESLint with no errors
- ✅ All functions have JSDoc comments
- ✅ Tests written and passing (60%+ coverage)
- ✅ No console.log or debugger statements
- ✅ Security: inputs validated, no obvious vulnerabilities
- ✅ Accessibility: proper ARIA labels, keyboard navigation
- ✅ Error handling: try/catch on async, user-facing messages
- ✅ MUI patterns: using sx prop, theme values, responsive design

### Phase 4: Testing & Quality Assurance

**Testing Pyramid**

```
       /\
      /E2E\         End-to-End (10%): Critical user flows
     /------\
    /Integration\   Integration (30%): API endpoints, component integration
   /------------\
  / Unit Tests  \  Unit Tests (60%): Business logic, utilities, services
 /----------------\
```

**Test Coverage Requirements**
- Minimum 60% overall coverage
- Minimum 20% per file
- Cover happy path, error cases, edge cases

**Testing Checklist**

Backend:
- [ ] Unit tests for services and utilities
- [ ] Integration tests for API endpoints
- [ ] Test authentication/authorization flows
- [ ] Test validation rules (valid/invalid inputs)
- [ ] Test error handling and status codes
- [ ] Test database transactions and rollbacks

Frontend:
- [ ] Component render tests
- [ ] User interaction tests (click, type, submit)
- [ ] Form validation tests
- [ ] Loading state tests
- [ ] Error state tests
- [ ] Accessibility tests (ARIA, keyboard nav)

Integration:
- [ ] API request/response cycle
- [ ] Error handling (network errors, 4xx, 5xx)
- [ ] Authentication token handling
- [ ] Data persistence and refresh

### Phase 5: Documentation

**Documentation Types**

**1. Code Documentation (Required)**
- JSDoc on all functions with @param, @returns, @throws
- Inline comments for complex logic only (explain "why", not "what")
- Magic numbers explained

**2. API Documentation (Required for Backend Changes)**

```markdown
## POST /api/auth/register

Create a new user account.

**Request Body**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "John Doe"
}
```

**Response 201 Created**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2025-01-11T00:00:00Z"
}
```

**Response 400 Bad Request**
```json
{
  "error": "Validation failed",
  "fields": {
    "email": "Email already exists"
  }
}
```

**Rate Limit**: 5 requests per 15 minutes
```

**3. README Updates (Required for New Features)**

```markdown
## Authentication

This application uses JWT-based authentication with httpOnly cookies.

### User Registration
1. Submit email, password, and name to POST /api/auth/register
2. Password must be at least 8 characters
3. Returns user object and sets session cookie

### Login
1. Submit email and password to POST /api/auth/login
2. Returns user object and sets session cookie
3. Rate limited to 5 attempts per 15 minutes

### Protected Routes
- Use `authenticate` middleware on routes requiring auth
- Frontend uses `ProtectedRoute` component wrapper
- Unauthorized requests return 401 status
```

**4. Architecture Decision Records (ADR) for Major Decisions**

```markdown
# ADR-001: JWT Authentication with httpOnly Cookies

## Status
Accepted

## Context
We need secure authentication for the application. Options considered:
1. JWT in localStorage (vulnerable to XSS)
2. JWT in httpOnly cookies (more secure)
3. Server-side sessions with Redis (more complex)

## Decision
Use JWT tokens stored in httpOnly cookies.

## Rationale
- httpOnly cookies protect against XSS attacks
- Simpler than Redis session store
- Stateless authentication
- Works well for our scale (single server deployment)

## Consequences
- Cannot access token from JavaScript (by design)
- Need CSRF protection for state-changing operations
- Must handle token refresh logic
- Cookie must be sent with credentials: 'include'
```

### Phase 6: Release & Deployment

**Pre-Release Checklist**

Code Quality:
- [ ] All tests passing (`npm test`)
- [ ] ESLint passing (`npm run lint`)
- [ ] Build succeeds (`npm run build`)
- [ ] Coverage meets threshold (60%+ overall)
- [ ] No console.log or debugger statements
- [ ] No commented-out code

Security:
- [ ] Input validation on all endpoints
- [ ] Authentication/authorization checks
- [ ] Rate limiting on sensitive endpoints
- [ ] Secrets in environment variables (not hardcoded)
- [ ] npm audit shows no high/critical vulnerabilities
- [ ] CORS properly configured
- [ ] Security headers configured (helmet)

Documentation:
- [ ] API documentation updated
- [ ] README updated with new features
- [ ] JSDoc comments on all functions
- [ ] Architecture decisions documented (if applicable)
- [ ] Breaking changes noted

Database:
- [ ] Migrations tested and reversible
- [ ] Indexes added for performance
- [ ] Backup plan in place

**Deployment Steps**

1. **Create Release Branch**
   ```bash
   git checkout -b release/v1.2.0
   ```

2. **Update Version**
   ```bash
   npm version minor  # or major, patch
   ```

3. **Run Full Test Suite**
   ```bash
   npm run test:coverage
   npm run lint
   npm run build
   ```

4. **Create Pull Request**
   - Use PR template
   - Include release notes
   - Request code review
   - Ensure CI/CD passes

5. **Merge and Tag**
   ```bash
   git checkout main
   git merge release/v1.2.0
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin main --tags
   ```

6. **Deploy to Staging**
   - Test on staging environment
   - Verify database migrations
   - Test critical user flows

7. **Deploy to Production**
   - Monitor logs during deployment
   - Verify health checks
   - Test smoke tests (login, key features)
   - Monitor error rates

8. **Post-Deployment**
   - Announce in team chat
   - Update issue tracker
   - Monitor performance metrics
   - Watch for error spikes

**Rollback Plan**

If deployment fails:
```bash
# Revert to previous version
git revert <commit-hash>
git push origin main

# Or rollback deployment
./deploy.sh v1.1.0  # Previous stable version
```

---

## Agile Practices (Optional)

### Sprint Planning

**Sprint Duration**: 1-2 weeks recommended

**Sprint Planning Meeting**

1. **Review Sprint Goal**
   - What's the objective for this sprint?
   - What value will we deliver?

2. **Backlog Refinement**
   - Break down features into tasks
   - Estimate effort (small/medium/large)
   - Clarify acceptance criteria
   - Identify dependencies

3. **Commitment**
   - Select tasks for the sprint
   - Ensure team has capacity
   - Account for meetings, reviews, unplanned work

**Capacity Planning**

```
Available hours per person per week:
- 40 hours total
- 8 hours meetings/overhead (20%)
- 32 hours development time

2-week sprint = 64 hours per person
Team of 3 = 192 hours total capacity
Reserve 20% for unexpected work = ~150 hours committed work
```

### Daily Standups (Async or Sync)

**Three Questions**
1. What did you complete yesterday?
2. What will you work on today?
3. Any blockers or help needed?

**Format**

```markdown
## Standup - 2025-01-11 - John Doe

### Yesterday
✅ Completed POST /api/auth/register endpoint
✅ Added validation and tests
✅ Fixed security issue with password hashing

### Today
🚧 Working on POST /api/auth/login endpoint
🚧 Implementing JWT token generation

### Blockers
❌ Need clarification on token expiration policy (1h or 24h?)
```

### Retrospectives

**After Each Sprint or Project**

1. **What Went Well?**
   - Celebrate successes
   - Identify practices to continue

2. **What Didn't Go Well?**
   - Identify problems
   - No blame, focus on process

3. **Action Items**
   - Concrete improvements for next sprint
   - Assign owners
   - Review in next retrospective

**Example Retrospective**

```markdown
## Sprint 12 Retrospective

### What Went Well
- Auth feature completed ahead of schedule
- Test coverage improved to 72%
- Good collaboration on API design

### What Didn't Go Well
- Database migration caused production issue
- Unclear requirements caused rework on login UI
- PR reviews took too long (3+ days)

### Action Items
1. Test migrations on staging before production (@john)
2. Add requirement checklist to feature template (@sarah)
3. Set PR review SLA: 24 hours max (@team)
```

---

## Risk Management

### Identifying Risks

**Common Software Project Risks**

1. **Technical Risks**
   - Third-party API reliability
   - Database performance at scale
   - Browser compatibility issues
   - Security vulnerabilities
   - Technical debt accumulation

2. **Scope Risks**
   - Requirements creep
   - Unclear acceptance criteria
   - Changing priorities
   - Feature complexity underestimated

3. **Resource Risks**
   - Key team member unavailable
   - Lack of expertise in technology
   - Time constraints
   - Budget limitations

4. **External Risks**
   - Vendor outages
   - Regulatory changes
   - Market changes
   - Dependency vulnerabilities

### Risk Register

**Track and Mitigate Risks**

```markdown
## Project Risk Register

| Risk | Impact | Probability | Mitigation | Owner |
|------|--------|-------------|------------|-------|
| Third-party auth provider outage | High | Medium | Implement fallback to local auth | @sarah |
| Database performance under load | High | Medium | Add indexes, implement caching | @john |
| Team member vacation during release | Medium | High | Cross-train on deployment, document process | @mike |
| npm package vulnerability | Medium | Low | Run npm audit weekly, auto-updates | @team |
```

**Risk Response Strategies**
- **Avoid**: Change plan to eliminate risk
- **Mitigate**: Reduce probability or impact
- **Transfer**: Outsource or insure
- **Accept**: Acknowledge and monitor

---

## Technical Debt Management

### Tracking Technical Debt

**What is Technical Debt?**
- Shortcuts taken to meet deadlines
- Outdated dependencies
- Missing tests
- Poor documentation
- Performance issues not yet addressed
- Code duplication
- Complex/unclear code

**Technical Debt Register**

```markdown
## Technical Debt Log

| Item | Type | Impact | Effort | Priority | Created |
|------|------|--------|--------|----------|---------|
| User service has no unit tests | Testing | High | Medium | High | 2025-01-01 |
| Old version of Express (v3) | Dependencies | Medium | Small | Medium | 2024-12-15 |
| No caching on /api/posts endpoint | Performance | Medium | Medium | Low | 2025-01-05 |
| Duplicate validation logic in 3 files | Code Quality | Low | Small | Low | 2024-11-20 |
```

**Prioritization Matrix**

```
High Impact + Low Effort = Do First
High Impact + High Effort = Schedule Soon
Low Impact + Low Effort = Do When Convenient
Low Impact + High Effort = Defer or Avoid
```

### Paying Down Technical Debt

**Allocate Time Each Sprint**
- Reserve 10-20% of sprint capacity for technical debt
- Include debt items in sprint planning
- Balance feature work with quality improvements

**Refactoring Guidelines**
- Refactor when adding new features to that area
- Write tests before refactoring
- Make small, incremental changes
- Commit frequently during refactoring
- Don't refactor just to refactor (must add value)

---

## Stakeholder Communication

### Status Updates

**Weekly Status Report Template**

```markdown
## Project Status - Week of Jan 8-12, 2025

### Completed This Week
- ✅ User authentication API endpoints (100%)
- ✅ Login/Register UI pages (100%)
- ✅ Test coverage increased to 68% (+12%)

### In Progress
- 🚧 Password reset flow (60% complete)
- 🚧 Email verification system (30% complete)

### Coming Next Week
- Protected routes middleware
- User profile page
- Session management

### Blockers
- ❌ Waiting on design approval for password reset email template

### Metrics
- Velocity: 85 story points (vs 80 planned)
- Test Coverage: 68% (target: 70%)
- Open Bugs: 3 (all low priority)

### Risks
- ⚠️ Email service provider pricing may exceed budget - investigating alternatives
```

### Change Requests

**Handling Scope Changes**

When stakeholder requests changes:

1. **Document the Request**
   - What's being requested?
   - Why is it needed?
   - What's the business value?

2. **Assess Impact**
   - How much effort required?
   - Does it affect current sprint/timeline?
   - Are there dependencies?
   - What's the risk?

3. **Present Options**
   - Option A: Add to current sprint (explain impact)
   - Option B: Add to next sprint
   - Option C: Replace existing planned work
   - Option D: Defer or decline (explain why)

4. **Get Approval**
   - Don't proceed without sign-off
   - Update project plan and todos
   - Communicate to team

**Change Request Template**

```markdown
## Change Request - Add OAuth Login

**Requested By**: Product Manager
**Date**: 2025-01-11

**Description**
Add Google OAuth login as alternative to email/password authentication.

**Business Justification**
- Reduces signup friction
- Users expect social login
- Competitor feature parity

**Impact Assessment**
- Effort: 3-4 days (Medium)
- Dependencies: Google OAuth credentials, CORS config
- Risk: Requires security review, unfamiliar API

**Options**
1. Add to current sprint - delays release by 1 week
2. Add to next sprint - no impact on current timeline
3. Replace user profile page work - delivers OAuth sooner

**Recommendation**
Add to next sprint (Option 2) to avoid delaying current release.

**Decision**
Approved for next sprint. Created tasks and updated backlog.
```

---

## Project Templates

### New Feature Template

```markdown
# Feature: [Feature Name]

## Problem Statement
[Describe the user need or business problem]

## Success Criteria
- [ ] User can...
- [ ] System should...
- [ ] Performance meets...

## In Scope
- [List what's included]

## Out of Scope
- [List what's explicitly NOT included]

## Technical Approach

### Backend
- Routes: [List endpoints]
- Database: [Schema changes]
- Services: [Business logic]
- Validation: [Rules]

### Frontend
- Pages: [List pages/views]
- Components: [Shared components]
- State: [Management approach]
- API Integration: [Endpoints called]

### Testing
- Unit tests: [What to test]
- Integration tests: [Scenarios]
- E2E tests: [User flows]

## Task Breakdown
[Use TodoWrite to create task list]

## Dependencies
- [External systems]
- [Other teams]
- [Waiting on]

## Risks
- [Technical risks]
- [Timeline risks]
- [Resource risks]

## Documentation Needs
- [ ] API docs updated
- [ ] README updated
- [ ] User guide created
- [ ] ADR written (if applicable)
```

### Bug Report Template

```markdown
# Bug: [Short Description]

## Severity
- [ ] Critical (system down, data loss)
- [ ] High (major feature broken)
- [ ] Medium (feature partially works)
- [ ] Low (cosmetic, minor annoyance)

## Environment
- Browser/Node version:
- OS:
- Deployment: (local/staging/production)

## Steps to Reproduce
1. Go to...
2. Click on...
3. Enter...
4. Observe...

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Screenshots/Logs
[Attach if applicable]

## Possible Cause
[Hypothesis if known]

## Fix Priority
- [ ] Immediate (critical bug)
- [ ] This sprint
- [ ] Next sprint
- [ ] Backlog
```

---

## Team Collaboration Best Practices

### Code Review Standards

**What to Review**

1. **Correctness**
   - Does code solve the problem?
   - Are edge cases handled?
   - Is error handling present?

2. **Testing**
   - Tests present and passing?
   - Coverage adequate (60%+)?
   - Tests cover error cases?

3. **Security**
   - Input validation?
   - Authentication/authorization?
   - No secrets in code?

4. **Code Quality**
   - Follows project patterns?
   - JSDoc comments present?
   - No unnecessary complexity?

5. **Documentation**
   - API docs updated?
   - README updated if needed?
   - Comments explain "why"?

**Code Review Etiquette**

- ✅ Be constructive and specific
- ✅ Suggest alternatives with rationale
- ✅ Praise good solutions
- ✅ Ask questions, don't make demands
- ✅ Focus on the code, not the person
- ❌ Don't be condescending
- ❌ Don't nitpick style (use automated tools)
- ❌ Don't block on personal preferences

**Review Response Time**
- Small PRs (<100 lines): 4 hours
- Medium PRs (100-500 lines): 24 hours
- Large PRs (500+ lines): Break down or 48 hours

### Pairing & Collaboration

**When to Pair Program**
- Complex problems requiring discussion
- Knowledge transfer (onboarding, new tech)
- Critical features (security, performance)
- Debugging tricky issues

**Pairing Best Practices**
- Rotate driver/navigator every 20-30 minutes
- Take breaks every hour
- Share keyboard and screen
- Discuss approach before coding
- Document decisions made during pairing

---

## Metrics & KPIs

### Development Metrics

**Track to Improve**

1. **Velocity**
   - Story points completed per sprint
   - Trend over time
   - Use for capacity planning

2. **Lead Time**
   - Time from task start to completion
   - Identify bottlenecks
   - Aim to reduce

3. **Cycle Time**
   - Time from commit to production
   - Measure deployment efficiency
   - Faster = better

4. **Code Quality**
   - Test coverage percentage
   - ESLint errors/warnings
   - Code review comments per PR
   - Technical debt ratio

5. **Reliability**
   - Bug count (by severity)
   - Bug fix time
   - Production incidents
   - Uptime percentage

**Don't Track to Punish**
- Lines of code (LOC) - meaningless
- Commits per day - encourages bad commits
- Hours worked - encourages burnout
- Individual velocity - team sport

### Example Dashboard

```markdown
## Team Metrics - Q1 2025

| Metric | Current | Target | Trend |
|--------|---------|--------|-------|
| Test Coverage | 68% | 70% | ↑ |
| Velocity | 85 pts | 80 pts | ↑ |
| Lead Time | 3.2 days | 2.5 days | ↓ |
| Open Bugs | 12 | <10 | ↓ |
| P1 Incidents | 0 | 0 | → |
| Deployment Frequency | 2/week | 3/week | ↑ |
```

---

## Summary: Project Management Checklist

### Before Starting Feature
- [ ] Problem statement clear
- [ ] Success criteria defined
- [ ] Scope documented (in/out)
- [ ] Technical approach planned
- [ ] Tasks broken down in TodoWrite
- [ ] Risks identified
- [ ] Dependencies noted

### During Development
- [ ] One task in_progress at a time
- [ ] Commit after each task completed
- [ ] Follow conventional commit format
- [ ] Write tests as you go
- [ ] Add JSDoc comments
- [ ] Update todos immediately

### Before Marking Complete
- [ ] Code quality checks pass
- [ ] Tests pass (60%+ coverage)
- [ ] Security audit complete
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No console.log/debugger

### Before Release
- [ ] All tests passing
- [ ] Build succeeds
- [ ] Migrations tested
- [ ] API docs updated
- [ ] README updated
- [ ] Security audit complete
- [ ] Staging tested
- [ ] Rollback plan ready

### After Release
- [ ] Deployment monitored
- [ ] Smoke tests passed
- [ ] Team notified
- [ ] Metrics tracked
- [ ] Retrospective scheduled

**Remember**: Good project management enables great code. Plan thoughtfully, execute methodically, communicate transparently.