# Team Collaboration & Organization

Guidelines for scaling Node.js/Express/React/MUI development from solo developers to full teams.

Covers roles, responsibilities, workflows, and collaboration patterns.

---

## Overview

This guide helps teams:
- **Define roles** clearly as team grows
- **Establish workflows** for collaboration
- **Scale processes** without losing velocity
- **Maintain quality** with multiple contributors
- **Onboard effectively** as team expands

**Target Audience**: Tech leads, engineering managers, growing teams transitioning from solo/small to larger development teams.

---

## Team Scaling Patterns

### Solo Developer (1 person)

**Reality**: You do everything - frontend, backend, database, deployment, testing, documentation.

**Structure**:
```
You (Fullstack Developer)
├── Frontend: React + MUI
├── Backend: Node.js + Express
├── Database: PostgreSQL
├── DevOps: Deployment, monitoring
├── QA: Testing
└── Docs: Documentation
```

**Best Practices**:
- ✓ Focus on MVP, avoid over-engineering
- ✓ Use frameworks and libraries (don't reinvent)
- ✓ Automate everything possible (CI/CD, tests, linting)
- ✓ Document decisions (you'll forget in 3 months)
- ✓ Keep it simple (no microservices, no complex architecture)

**Your Existing Guides**: Follow CLAUDE.md + all specialized guides as needed

### Small Team (2-4 people)

**Reality**: Still wearing multiple hats, but can start specializing.

**Structure Option A: Fullstack**:
```
2-4 Fullstack Developers
├── Each works on features end-to-end
├── Code review each other's PRs
└── Rotate on-call and DevOps tasks
```

**Structure Option B: Frontend/Backend Split**:
```
1-2 Frontend Developers (React + MUI)
├── Focus on UI/UX
├── Component library
└── State management

1-2 Backend Developers (Node.js + Express)
├── API design
├── Database optimization
└── Authentication/authorization
```

**Best Practices**:
- ✓ Establish code review process (every PR reviewed by 1 person)
- ✓ Define coding standards (use your coding-standards.md)
- ✓ Share on-call rotation
- ✓ Document architecture decisions (ADRs)
- ✓ Regular sync (daily standup or async)

**Communication**:
- Daily: Async standup (what did I do, what am I doing, any blockers)
- Weekly: Planning meeting (sprint planning if doing sprints)
- As needed: Technical discussions (architecture, design)

### Medium Team (5-10 people)

**Reality**: Specialization becomes necessary. Can have dedicated roles.

**Structure**:
```
Tech Lead (1)
├── Architecture decisions
├── Code review oversight
└── Technical mentoring

Frontend Team (2-3)
├── Senior Frontend Developer
├── Frontend Developer
└── Focus: React, MUI, state management, performance

Backend Team (2-3)
├── Senior Backend Developer
├── Backend Developer
└── Focus: Node.js, Express, API design, database

DevOps/Infrastructure (1)
├── CI/CD pipelines
├── Deployment automation
├── Monitoring and alerting
└── Production support

QA (1)
├── Test automation
├── Integration testing
└── Manual testing for edge cases
```

**Best Practices**:
- ✓ Dedicated tech lead for architectural decisions
- ✓ Frontend/backend specialization with clear API contracts
- ✓ Code review by 2 people for critical changes
- ✓ Regular architecture reviews (monthly)
- ✓ Documented API contracts (OpenAPI/Swagger)
- ✓ Automated testing required (60% coverage minimum)

**Communication**:
- Daily: Async standup per team (frontend, backend)
- Weekly: Full team sync, sprint planning
- Bi-weekly: Architecture review
- Monthly: Retrospective

### Large Team (10+ people)

**Reality**: Multiple feature teams, platform teams, need strong processes.

**Structure**:
```
Engineering Manager (1-2)
├── People management
├── Hiring and growth
└── Cross-team coordination

Tech Leads (2-3)
├── Architecture
├── Technical direction
└── Code review and mentoring

Feature Team 1 (3-4)
├── 2 Fullstack or 1 FE + 1 BE + 1 QA
├── Owns specific domain (e.g., authentication, billing)
└── End-to-end ownership

Feature Team 2 (3-4)
├── Similar structure
└── Owns different domain

Platform/Infrastructure Team (2-3)
├── DevOps Engineer
├── Backend Engineer (platform services)
└── Shared services, CI/CD, monitoring

QA Team (1-2)
├── Test automation
├── QA process and standards
└── Support feature teams
```

**Best Practices**:
- ✓ Autonomous feature teams (own frontend + backend + database)
- ✓ Platform team provides shared services
- ✓ Clear ownership (each team owns specific domains)
- ✓ API contracts between teams
- ✓ Automated deployment per team
- ✓ On-call rotation per team
- ✓ Regular cross-team sync

**Communication**:
- Daily: Async standup per feature team
- Weekly: Team planning, feature team syncs
- Bi-weekly: Cross-team architecture review
- Monthly: All-hands engineering meeting

---

## Role Definitions

### Tech Lead

**Responsibilities**:
- Architecture decisions and technical direction
- Code review for complex or risky changes
- Mentoring junior and mid-level developers
- Breaking down large features into tasks
- Technical debt prioritization

**NOT responsible for**:
- People management (that's Engineering Manager)
- Product decisions (that's Product Manager)
- Day-to-day coding (but should still code ~50% of time)

**Expectations**:
- Deep expertise in your stack (Node.js/React/MUI)
- Can make difficult technical trade-offs
- Communicates technical concepts to non-technical stakeholders
- Unblocks team members

**Your Guides**: Master all guides in `.claude/`, especially:
- coding-standards.md (priorities, trade-offs)
- project-management.md (architecture decisions)
- All technical guides (nodejs, express, react, mui)

### Senior Developer

**Responsibilities**:
- Own complex features end-to-end
- Mentor junior developers
- Participate in architecture discussions
- Code review for peers
- Improve team processes and standards

**NOT responsible for**:
- Final architecture decisions (that's Tech Lead)
- Managing people (that's Engineering Manager)

**Expectations**:
- Can work independently on large features
- Strong understanding of your stack
- Considers security, performance, maintainability
- Proactive about technical debt
- Helps define team standards

**Your Guides**: Comfortable with all technical guides, references:
- coding-standards.md for priorities
- security.md, testing.md rigorously
- project-management.md for planning

### Mid-Level Developer

**Responsibilities**:
- Own medium-sized features with guidance
- Write clean, tested code
- Participate in code reviews
- Ask questions when stuck
- Learn from senior developers

**Expectations**:
- Can complete well-defined tasks independently
- Growing understanding of architecture
- Writes tests for own code
- Follows team standards consistently

**Your Guides**: Primary reference material:
- CLAUDE.md for overview
- Specific guides as needed (react.md, express.md)
- coding-standards.md for checklists

### Junior Developer

**Responsibilities**:
- Complete small, well-defined tasks
- Learn the stack and codebase
- Ask questions frequently
- Participate in code reviews (as learner)
- Follow established patterns

**Expectations**:
- Requires guidance on architecture and design
- Learning fundamentals of Node.js/React/MUI
- Writes code that works, learning to write clean code
- Actively learning from team

**Your Guides**: Start with:
- CLAUDE.md (overview)
- One guide at a time (nodejs.md OR react.md)
- coding-standards.md pre-commit checklist

### QA Engineer

**Responsibilities**:
- Test automation framework and strategy
- Integration and E2E tests
- Manual testing for edge cases
- Bug triage and reproduction
- Quality metrics tracking

**Expectations**:
- Understands Node.js/React stack enough to write tests
- Can read and understand code
- Identifies edge cases developers miss
- Advocates for quality in planning

**Your Guides**: Focus on:
- testing.md (primary)
- CLAUDE.md (architecture)
- quality-management.md (incident response)

### DevOps Engineer

**Responsibilities**:
- CI/CD pipelines
- Deployment automation
- Infrastructure as code
- Monitoring and alerting
- Incident response and production support

**Expectations**:
- Understands Node.js deployment (Docker, Kubernetes, etc.)
- Infrastructure automation (Terraform, CloudFormation)
- Security hardening
- Performance monitoring

**Your Guides**: Reference:
- nodejs.md (runtime, process management)
- security.md (production security)
- quality-management.md (incident response)

---

## Collaboration Workflows

### Code Review Process

**Goal**: Maintain code quality, share knowledge, catch bugs early

**Process**:

1. **Developer Creates PR**:
   - Follows pre-PR checklist (coding-standards.md)
   - Writes descriptive PR description (what, why, testing)
   - Links to issue/ticket
   - Adds screenshots for UI changes
   - Requests reviewers

2. **Reviewer Reviews**:
   - Uses coding-standards.md review checklist
   - Checks for security issues (security.md)
   - Verifies tests present and passing
   - Suggests improvements (be constructive)
   - Approves or requests changes

3. **Developer Responds**:
   - Addresses feedback
   - Discusses disagreements respectfully
   - Re-requests review after changes

4. **Merge**:
   - Requires 1 approval (small team) or 2 approvals (large team)
   - CI/CD must pass
   - Squash and merge (or rebase and merge per team preference)

**Review Standards**:
- **Response Time**: Within 24 hours (within 4 hours for small PRs)
- **Size**: Keep PRs small (<400 lines preferred)
- **Focus**: Security > Correctness > Quality > Style

**Review Comments Style**:

✅ Good:
```
"Consider adding null check here. If `user` is undefined, this will crash:

if (!user) {
  throw new NotFoundError('User not found');
}

See security.md > Input Validation"
```

❌ Bad:
```
"Fix this" (not specific)
"This is wrong" (not constructive)
```

### Feature Development Workflow

**Goal**: Deliver features predictably with high quality

**Workflow** (see project-management.md for details):

1. **Planning** (Product + Engineering):
   - PRD created (product-development.md)
   - Technical design discussed
   - Tasks broken down (TodoWrite)
   - Estimation provided

2. **Implementation**:
   - Developer picks up task
   - Creates feature branch
   - Writes code + tests
   - Self-reviews (coding-standards.md checklist)
   - Creates PR

3. **Review**:
   - Code review by peer(s)
   - Address feedback
   - Approval obtained

4. **Deploy**:
   - Merge to main/dev
   - CI/CD runs
   - Deploy to staging
   - Smoke test
   - Deploy to production (if approved)

5. **Verify**:
   - Monitor metrics
   - Check error rates
   - Verify feature works
   - Gather user feedback

**Parallel Work**:
- Frontend and backend can work in parallel if API contract defined
- Multiple features can be developed simultaneously
- Coordinate through API contracts and regular syncs

### On-Call Rotation

**Goal**: 24/7 support for production issues

**Structure** (Medium/Large Teams):

**Primary On-Call**: Responds first
- Acknowledges incidents within 15 minutes
- Investigates and mitigates
- Escalates if needed

**Secondary On-Call**: Backup
- Responds if primary doesn't respond in 30 minutes
- Available for consultation

**Rotation**:
- Weekly rotation (Monday 9am - Monday 9am)
- Minimum 2 people in rotation
- No more than 1 week per person per month

**Process** (see quality-management.md):
1. Incident detected (monitoring alert or user report)
2. On-call acknowledges via PagerDuty/phone
3. Follow incident response process (quality-management.md)
4. Mitigate (rollback, disable feature, hotfix)
5. Document incident
6. Post-mortem after resolution

**On-Call Preparation**:
- [ ] Access to production systems
- [ ] VPN configured
- [ ] PagerDuty/alerting configured
- [ ] Know escalation contacts
- [ ] Reviewed recent incidents
- [ ] Know rollback procedures

---

## Communication Patterns

### Daily Standup (Async or Sync)

**Format** (see project-management.md):

```markdown
## Standup - 2025-01-11 - John Doe

### Yesterday
- Completed authentication API endpoint
- Fixed bug in user search
- Code review for Sarah's PR

### Today
- Implementing JWT token refresh
- Write tests for auth flow
- Architecture meeting at 2pm

### Blockers
- Need design review for login page
- Waiting on product decision about token expiration
```

**Guidelines**:
- Keep it brief (< 2 minutes per person if sync)
- Focus on work, not activities
- Mention blockers early
- Don't solve problems in standup (take offline)

### Technical Discussions

**When to Discuss**:
- Architecture decisions
- Complex technical problems
- Trade-off analysis
- New technology evaluation

**Format**:
- **Async**: Write proposal (RFC/ADR), gather feedback, decide
- **Sync**: Schedule meeting, share context beforehand, timebox discussion

**Example: Async RFC (Request for Comments)**:

```markdown
# RFC: Real-time Notifications Architecture

## Problem
Users want instant notifications for important events.

## Proposed Solution
Use WebSockets for real-time push notifications.

## Alternatives Considered
1. Polling (simple but inefficient)
2. Server-Sent Events (one-way only)
3. WebSockets (full-duplex, complex)

## Trade-offs
**Pros**:
- True real-time (<1s latency)
- Efficient (no polling overhead)
- Standard protocol

**Cons**:
- More complex than polling
- Requires persistent connections (scaling concern)
- Need graceful fallback for old browsers

## Implementation
- Backend: socket.io on Node.js
- Frontend: socket.io-client in React
- Database: Store notifications in PostgreSQL
- Scale: Use Redis pub/sub for multi-server

## Open Questions
1. Authentication: JWT in WebSocket handshake?
2. Fallback: Polling for browsers without WebSocket?
3. Rate limiting: Max notifications per second per user?

## Decision Needed By
2025-01-15 (need to start implementation Week 3)

**Please review and provide feedback by EOD Jan 13**
```

### Sprint Planning (If Using Agile)

**Goal**: Plan work for next sprint (1-2 weeks)

**Process**:
1. **Review last sprint**: What was completed? Velocity?
2. **Prioritize backlog**: Product ranks features (RICE scoring, product-development.md)
3. **Select work**: Team pulls items into sprint (based on velocity)
4. **Break down**: Large items broken into tasks
5. **Estimate**: Team estimates effort (planning poker or t-shirt sizes)
6. **Commit**: Team commits to sprint goal

**Output**:
- Sprint goal (1-sentence objective)
- Sprint backlog (list of features/stories)
- Tasks created in TodoWrite

### Retrospectives

**Goal**: Continuous improvement

**Format** (see project-management.md):

**What went well?**
- Celebrate successes
- Identify practices to continue

**What didn't go well?**
- Identify problems
- No blame, focus on process

**Action items**
- Concrete improvements
- Assign owners
- Review in next retro

**Example**:
```markdown
## Sprint 5 Retrospective

### What Went Well
- Deployed 3 features without incidents
- Code review turnaround improved (< 12 hours)
- New team member ramped up quickly

### What Didn't Go Well
- Testing took longer than expected (found bugs in QA)
- API contract changed mid-sprint (caused rework)
- Documentation lagging behind code

### Action Items
1. Add integration tests to pre-PR checklist [@john]
2. Lock API contracts at sprint start [@sarah]
3. Update docs alongside code (not after) [@team]
```

---

## Onboarding New Team Members

### First Day

**Setup**:
- [ ] Laptop/equipment
- [ ] Email and accounts
- [ ] GitHub access
- [ ] Development environment
- [ ] Access to staging/dev servers
- [ ] Slack/communication tools

**Introductions**:
- [ ] Welcome meeting with team
- [ ] 1:1 with manager
- [ ] 1:1 with tech lead
- [ ] Buddy assigned (mentor for first 2 weeks)

**Reading**:
- [ ] Read `.claude/README.md` (start here)
- [ ] Read `.claude/CLAUDE.md` (main guidelines)
- [ ] Scan specialized guides in `.claude/rules/`

### First Week

**Learning**:
- [ ] Set up local dev environment
- [ ] Run the application locally
- [ ] Make a small change (fix typo, update docs)
- [ ] Create first PR (simple change)
- [ ] Attend standup and meetings

**Pair Programming**:
- [ ] Pair with buddy on small task
- [ ] Watch code review process
- [ ] Observe how team collaborates

### First Month

**Contributions**:
- [ ] Complete 2-3 small features independently
- [ ] Participate in code reviews
- [ ] Ask questions in standups
- [ ] Learn team processes

**Growing**:
- [ ] Deeper dive into relevant guides (react.md, express.md, etc.)
- [ ] Understand architecture
- [ ] Know deployment process
- [ ] Comfortable with team workflow

### Onboarding Checklist for New Developer

```markdown
# Onboarding Checklist - [Name]

## Day 1
- [ ] Laptop setup complete
- [ ] Access to GitHub, Slack, email
- [ ] Met the team
- [ ] Read README.md and CLAUDE.md
- [ ] Development environment running

## Week 1
- [ ] Created first PR (docs or small fix)
- [ ] Attended standup daily
- [ ] Paired with buddy
- [ ] Read coding-standards.md
- [ ] Understand git workflow (commit-policy.md)

## Week 2
- [ ] Completed first feature task
- [ ] Did first code review
- [ ] Understand testing requirements (testing.md)
- [ ] Know security basics (security.md)

## Week 3-4
- [ ] Completed 2-3 features independently
- [ ] Comfortable with React/MUI patterns
- [ ] Comfortable with Node.js/Express patterns
- [ ] Understand deployment process
- [ ] Participating actively in planning

## Month 2-3
- [ ] Owning medium-sized features
- [ ] Mentoring newer team members
- [ ] Contributing to architecture discussions
- [ ] Improving team processes
```

---

## Scaling Challenges & Solutions

### Challenge 1: Too Many Meetings

**Symptom**: Developers spend >50% of time in meetings

**Solution**:
- Async by default (standup, updates)
- Timebox sync meetings (30 min max)
- Optional meetings (only required if you contribute)
- Meeting-free days (e.g., "Focus Fridays")
- Cancel meetings if no agenda

### Challenge 2: Slow Code Review

**Symptom**: PRs sit for days waiting for review

**Solution**:
- Set SLA: 24 hours for review (4 hours for small PRs)
- Reviewers rotate (scheduled reviewer each day)
- Smaller PRs (< 400 lines)
- Auto-assign reviewers in GitHub
- Block PR merge on stale reviews

### Challenge 3: Knowledge Silos

**Symptom**: Only one person knows critical systems

**Solution**:
- Pair programming on complex features
- Rotate ownership of systems
- Document architecture (ADRs)
- Code review across teams
- Regular knowledge sharing sessions

### Challenge 4: Inconsistent Standards

**Symptom**: Every developer codes differently

**Solution**:
- Use your `.claude/` guidelines religiously
- Automated linting and formatting (ESLint, Prettier)
- Pre-commit hooks enforce standards
- Code review checklist (coding-standards.md)
- Tech lead reviews for consistency

### Challenge 5: Technical Debt Growing

**Symptom**: Codebase becoming unmaintainable

**Solution**:
- Reserve 20% sprint capacity for tech debt
- Track debt in backlog (prioritize like features)
- Boy Scout Rule: Leave code better than you found it
- Refactor alongside feature work
- Quarterly tech debt sprint

### Challenge 6: Deployment Fear

**Symptom**: Team afraid to deploy, releases infrequent

**Solution**:
- Automate deployment (CI/CD)
- Comprehensive test coverage (60%+)
- Staged rollout (deploy to 10% users first)
- Quick rollback procedure
- Post-deployment monitoring
- Deploy frequently (reduces risk per deploy)

---

## Metrics for Healthy Teams

### Velocity Metrics

**Sprint Velocity** (if using sprints):
- Track story points completed per sprint
- Use to forecast future capacity
- Don't use to compare developers (team metric, not individual)

**Lead Time**:
- Time from task start to production
- Target: < 1 week for small features
- Measure to find bottlenecks

**Cycle Time**:
- Time from first commit to production
- Target: < 3 days
- Indicates deployment efficiency

### Quality Metrics

**Test Coverage**:
- Target: 60% overall, 20% per file
- Trend matters more than absolute number
- Track in CI/CD

**Code Review Time**:
- Target: < 24 hours from PR creation to merge
- Indicates team collaboration health

**Bug Rate**:
- Bugs found in production per sprint
- Track trend (should decrease over time)
- Target: < 5 P1/P2 bugs per sprint

**Incident Frequency**:
- Production incidents per month
- Track MTTR (Mean Time to Recovery)
- Target: < 2 P0/P1 incidents per month

### Team Health Metrics

**On-Call Burden**:
- Hours on-call per week
- Target: < 5 hours of active incident response per week
- If higher, focus on reliability

**Meeting Time**:
- % of developer time in meetings
- Target: < 30%
- Anything >50% is concerning

**Team Satisfaction**:
- Regular surveys (quarterly)
- Questions: Workload reasonable? Learning opportunities? Team collaboration good?
- Act on feedback

---

## Integration with Existing Guides

### Relates to Project Management (project-management.md)

**project-management.md provides**:
- Feature planning process
- Sprint mechanics
- Task breakdown

**This guide adds**:
- Team structure and roles
- Collaboration workflows
- Onboarding process
- Scaling patterns

**Together**: Complete workflow from solo to team

### Relates to Coding Standards (coding-standards.md)

**coding-standards.md provides**:
- Code quality standards
- Review checklist
- Pre-commit/PR requirements

**This guide adds**:
- How teams enforce standards
- Code review process
- Knowledge sharing
- Consistency across team members

**Together**: Standards + process to enforce them

### Relates to All Technical Guides

**Technical guides provide**:
- How to write code (patterns, best practices)

**This guide adds**:
- How teams work together to write code
- Roles and responsibilities
- Collaboration and communication

**Together**: What to build + how to build it as a team

---

## Quick Reference

### Team Structure by Size

**Solo (1)**: You do everything, follow all guides
**Small (2-4)**: Fullstack or FE/BE split, code review, standups
**Medium (5-10)**: Specialization, tech lead, dedicated QA/DevOps
**Large (10+)**: Feature teams, platform team, engineering manager

### Key Roles

- **Tech Lead**: Architecture, mentoring, code review
- **Senior Dev**: Own complex features, mentor, improve processes
- **Mid-Level**: Own medium features, growing autonomy
- **Junior**: Small tasks, learning, following patterns
- **QA**: Test automation, quality advocacy
- **DevOps**: CI/CD, deployment, infrastructure

### Essential Processes

- **Code Review**: Every PR reviewed, 24-hour SLA
- **Standup**: Daily async or 15-min sync
- **Sprint Planning**: Prioritize and plan work (if using sprints)
- **Retrospective**: Continuous improvement (bi-weekly or monthly)
- **On-Call**: 24/7 production support (medium+ teams)

### Scaling Checklist

When growing from N to N+1 developers:

**Adding 1st Developer** (Solo → 2):
- [ ] Establish code review process
- [ ] Define coding standards (your `.claude/` guides)
- [ ] Set up daily sync (async or 15-min call)
- [ ] Document architecture basics

**Growing to 5**:
- [ ] Add tech lead role
- [ ] Consider FE/BE specialization
- [ ] Implement sprint planning
- [ ] Add QA or DevOps focus

**Growing to 10**:
- [ ] Split into feature teams
- [ ] Dedicated DevOps/infrastructure
- [ ] Formal onboarding process
- [ ] Engineering manager for people management

**Growing to 20+**:
- [ ] Multiple feature teams (3-4 people each)
- [ ] Platform team for shared services
- [ ] Regular architecture reviews
- [ ] Cross-team coordination meetings

---

## Summary

**Core Principles**:

1. **Clear Roles**: Everyone knows their responsibilities
2. **Consistent Standards**: `.claude/` guides followed by all
3. **Effective Communication**: Async default, sync when needed
4. **Quality Focus**: Code review, testing, security non-negotiable
5. **Continuous Improvement**: Regular retrospectives and iteration

**Scaling Wisdom**:
- Start simple, add process only when needed
- Automate ruthlessly (CI/CD, testing, linting)
- Document decisions (ADRs, runbooks)
- Invest in onboarding (pays off quickly)
- Keep teams small (3-5 people per team)

**Remember**: Process should enable productivity, not hinder it. When in doubt, start with less process and add more only when pain points emerge. Your `.claude/` guides provide the technical foundation - this guide provides the team structure to scale effectively.