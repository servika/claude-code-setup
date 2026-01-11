# Product Development & Feature Planning

Guidelines for translating product requirements into technical implementation in Node.js/Express/React/MUI projects.

Bridges product thinking with software development, integrating with project-management.md for delivery.

---

## Overview

This guide helps developers:
- **Understand** product requirements and user needs
- **Prioritize** features using data-driven methods
- **Plan** technical implementation aligned with product goals
- **Collaborate** effectively with product managers and designers
- **Deliver** features that solve real user problems

**Target Audience**: Full-stack developers, tech leads, engineering managers working with product teams.

---

## Product Thinking for Developers

### Why Developers Need Product Thinking

**Good developers write code. Great developers solve problems.**

Understanding **why** you're building something is as important as knowing **how**:

**Without product thinking**:
```javascript
// Task: "Add user filtering"
function filterUsers(users, filter) {
  return users.filter(u => u.name.includes(filter));
}
```

**With product thinking**:
```javascript
// User need: "Find users quickly in a list of 10,000"
// Why: Support team wastes 5 min per search
// Solution: Fast search + filters + sorting

function searchUsers(users, query, filters = {}) {
  // 1. Fast text search (indexed)
  let results = searchIndex.query(query);

  // 2. Apply filters (role, status, date range)
  if (filters.role) results = results.filter(u => u.role === filters.role);
  if (filters.status) results = results.filter(u => u.status === filters.status);

  // 3. Sort by relevance
  return results.sort((a, b) => b.score - a.score);
}
```

**Difference**: Understanding the **user problem** (finding users in large lists) leads to better technical decisions (search index, multiple filters, scoring).

### The Developer's Role in Product Development

**You're not just an implementer** - you're a collaborator:

**What Product Brings**:
- User research and insights
- Business goals and priorities
- Feature requirements
- Success metrics

**What You Bring**:
- Technical feasibility assessment
- Implementation complexity estimates
- Alternative technical approaches
- Performance and scalability concerns
- Security and data implications

**Together**: Make better decisions about what to build and how.

---

## Feature Prioritization

### RICE Scoring Framework

**RICE** helps prioritize features objectively:

**Formula**: `Score = (Reach × Impact × Confidence) / Effort`

**Components**:

1. **Reach** - How many users affected per time period?
   - Monthly active users impacted
   - Example: 500 users/month

2. **Impact** - How much does it improve their experience?
   - **3** = Massive impact (solves critical pain point)
   - **2** = High impact (significant improvement)
   - **1** = Medium impact (nice improvement)
   - **0.5** = Low impact (small improvement)
   - **0.25** = Minimal impact (barely noticeable)

3. **Confidence** - How sure are we about the other numbers?
   - **100%** = High confidence (data-backed)
   - **80%** = Medium confidence (some data)
   - **50%** = Low confidence (hypothesis)

4. **Effort** - How much development time?
   - Person-months
   - Example: 2 person-months = 2.0

**Calculation Example**:

```
Feature: Real-time notifications

Reach: 5,000 users/month
Impact: 2 (high - users asked for this)
Confidence: 80% (user interviews confirm need)
Effort: 1 person-month

Score = (5000 × 2 × 0.8) / 1 = 8,000
```

**Compare Features**:

| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| Real-time notifications | 5000 | 2 | 80% | 1 | 8,000 |
| Dark mode | 3000 | 1 | 100% | 0.5 | 6,000 |
| Advanced search | 1000 | 3 | 50% | 2 | 750 |
| Export to PDF | 200 | 1 | 100% | 0.5 | 400 |

**Priority**: Real-time notifications → Dark mode → Advanced search → Export to PDF

### Quick Prioritization for Developers

When product hasn't prioritized, use this quick framework:

**High Priority**:
- Blocks users from core functionality
- Security vulnerability
- Data integrity issue
- Performance severely degraded
- Affects large percentage of users

**Medium Priority**:
- Improves user experience significantly
- Requested by multiple customers
- Reduces support burden
- Technical debt causing issues

**Low Priority**:
- Nice-to-have improvements
- Single customer request
- Cosmetic issues
- Low-usage features

**When in Doubt**: Ask these questions:
1. How many users does this affect?
2. How severely does it impact them?
3. What happens if we don't fix it now?
4. How much effort is required?

---

## Understanding User Stories

### User Story Format

**Template**: "As a [user type], I want to [action] so that [benefit]"

**Good Example**:
```
As a support agent,
I want to search users by email or name,
so that I can quickly find user accounts during support calls.

Acceptance Criteria:
- Search returns results in < 500ms for 10K users
- Supports partial matching (e.g., "john" matches "John Doe")
- Shows most relevant results first
- Displays user: name, email, status, created date
- Clicking result opens user detail page
```

**Bad Example**:
```
As a user,
I want a search feature,
so that I can search.
```
❌ Too vague, no clear benefit, no acceptance criteria

### INVEST Criteria for User Stories

**I - Independent**: Story can be developed independently
- ✓ "Add user search" (standalone)
- ✗ "Add user search (part 1 of 3)" (dependent on parts 2, 3)

**N - Negotiable**: Details can be discussed
- ✓ "Search by name or email" (can discuss: fuzzy search? regex?)
- ✗ "Must use PostgreSQL full-text search with ts_vector" (too prescriptive)

**V - Valuable**: Delivers value to users
- ✓ "Find users quickly" (solves support team pain point)
- ✗ "Refactor search function" (no user value)

**E - Estimable**: Team can estimate effort
- ✓ "Add search endpoint with basic filtering" (clear scope)
- ✗ "Improve user experience" (too broad to estimate)

**S - Small**: Can be completed in one sprint
- ✓ "Basic search (name, email)" (doable in 1 sprint)
- ✗ "Advanced search with ML-powered recommendations" (too large)

**T - Testable**: Clear acceptance criteria
- ✓ "Returns results in < 500ms for 10K users" (measurable)
- ✗ "Search should be fast" (not measurable)

### Converting User Stories to Technical Tasks

**User Story**:
```
As a support agent,
I want to search users by email or name,
so that I can quickly find accounts during support calls.
```

**Technical Task Breakdown** (using TodoWrite):

```
Backend Tasks:
[ pending ] Add user search endpoint: GET /api/users/search
[ pending ] Implement search service with name/email filtering
[ pending ] Add database indexes on email and name columns
[ pending ] Add pagination (limit 20 results)
[ pending ] Add response time logging
[ pending ] Write unit tests for search service
[ pending ] Write integration tests for search endpoint
[ pending ] Add rate limiting (100 req/15min per user)

Frontend Tasks:
[ pending ] Create SearchBar component (MUI TextField with icon)
[ pending ] Implement debounced search (300ms delay)
[ pending ] Show loading state during search
[ pending ] Display results list (UserCard components)
[ pending ] Handle empty state ("No results found")
[ pending ] Handle error state (network error, timeout)
[ pending ] Add keyboard navigation (arrow keys, enter)
[ pending ] Write component tests

Performance Tasks:
[ pending ] Measure search response time (target: <500ms)
[ pending ] Load test with 10K users
[ pending ] Optimize if needed (caching, indexing)

Documentation:
[ pending ] Update API documentation
[ pending ] Add search usage to README
```

---

## Product Requirements Documents (PRDs)

### When You Need a PRD

**Large features** (> 2 weeks effort) should have a PRD before implementation:

**Needs PRD**:
- ✓ User authentication system
- ✓ Payment integration
- ✓ Real-time notifications
- ✓ Advanced search/filtering
- ✓ Third-party API integration

**Doesn't Need PRD**:
- ✗ Fix typo in button label
- ✗ Update color scheme
- ✗ Add logging to endpoint
- ✗ Increase timeout value

### Lightweight PRD Template (for Developers)

```markdown
# Feature: [Name]

## Problem

**User Pain Point**:
[Describe the problem users are experiencing]

**Current Situation**:
[What happens today]

**Desired Outcome**:
[What should happen]

**Impact**:
- Users affected: [number]
- Frequency: [how often they encounter this]
- Business impact: [revenue, support tickets, churn, etc.]

## Solution

**Proposed Approach**:
[High-level description of the solution]

**Why This Solution**:
[Rationale - why not alternative approaches?]

**User Flow**:
1. User lands on [page]
2. User clicks [button/link]
3. System displays [result]
4. User completes [action]

**Key Features**:
- Feature 1: [description]
- Feature 2: [description]
- Feature 3: [description]

## Technical Approach

**Backend**:
- New endpoints: POST /api/notifications/subscribe
- Database changes: Add notifications table
- External dependencies: WebSocket server
- Authentication: Requires JWT token

**Frontend**:
- New components: NotificationBell, NotificationList
- State management: React Query for notification polling
- UI library: MUI components (Badge, Menu, List)

**Architecture Diagram** (optional):
\```
[User Browser] <--> [Express API] <--> [WebSocket Server]
                          |
                          v
                    [PostgreSQL]
\```

## Success Metrics

**How we'll know this works**:
- [Metric 1]: Users enable notifications: >50%
- [Metric 2]: Notification click-through rate: >30%
- [Metric 3]: Response time: <2s from event to notification

## Out of Scope

**Explicitly NOT included** in this version:
- Push notifications (mobile)
- Email notifications
- Notification preferences/settings
- Historical notification archive

(These may be added in future iterations)

## Open Questions

- [ ] Should notifications persist after logout?
- [ ] How long to keep notifications (30 days? 90 days?)
- [ ] Rate limit: max notifications per user per hour?

## Timeline

**Estimated Effort**: 3 weeks (1 backend dev, 1 frontend dev)

**Milestones**:
- Week 1: Backend API + database
- Week 2: Frontend UI + WebSocket integration
- Week 3: Testing + polish + deployment

## Risks

- **Technical**: WebSocket scaling if user base grows rapidly
  - Mitigation: Start with polling, migrate to WebSockets later
- **Product**: Users may find notifications annoying
  - Mitigation: Start with opt-in, not opt-out

## Dependencies

- Requires authentication system (already done)
- Blocks: User preferences feature (waiting on notifications)

## Stakeholders

- **Product Owner**: @sarah-product
- **Engineering Lead**: @john-tech-lead
- **Designer**: @mike-ux
- **QA**: @emily-qa
```

### PRD Review Checklist

Before starting implementation, verify PRD has:

- [ ] Clear problem statement (user pain point)
- [ ] Proposed solution with rationale
- [ ] Success metrics (how to measure success)
- [ ] Out of scope (what's NOT included)
- [ ] Technical approach (backend/frontend/database)
- [ ] Estimated effort
- [ ] Open questions answered or tracked
- [ ] Stakeholder approval

---

## Collaborating with Product & Design

### Developer's Role in Product Discovery

**Product brings**: User research, problem definition, success metrics

**You bring**: Technical feasibility, effort estimates, alternative solutions

**Common Scenarios**:

#### Scenario 1: Feature Request Beyond Current Architecture

**Product**: "We need real-time collaboration (like Google Docs)"

**Your Response**:
```
"Real-time collaboration is technically feasible but significant:

Option 1: Operational Transform (like Google Docs)
- Effort: 3-4 months
- Complexity: Very high
- Pros: True real-time, conflict resolution
- Cons: Complex to maintain, hard to debug

Option 2: Periodic Auto-Save + Lock Mechanism
- Effort: 2 weeks
- Complexity: Low
- Pros: Simple, reliable
- Cons: Not truly real-time, users see changes every 30s

Option 3: Third-party (e.g., Yjs, ShareDB)
- Effort: 3-4 weeks
- Complexity: Medium
- Pros: Battle-tested, feature-rich
- Cons: External dependency, licensing cost

Recommendation: Start with Option 2 to validate user need,
then migrate to Option 3 if real-time is critical."
```

**Key**: Provide options with trade-offs, not just "yes" or "no"

#### Scenario 2: Unrealistic Timeline

**Product**: "Can we ship this in 2 weeks?"

**Your Response**:
```
"Full feature as spec'd: 6 weeks (2 backend, 2 frontend, 2 testing/polish)

To ship in 2 weeks, we could build MVP with:
- Basic functionality only (no advanced filters)
- Desktop only (no mobile optimization)
- Manual testing (no automated tests)

Trade-offs:
- Higher bug risk (no test coverage)
- Technical debt (will need refactoring)
- Limited user value (missing key features)

Alternative: Ship Phase 1 in 3 weeks with core functionality + tests,
Phase 2 in additional 3 weeks with polish + advanced features."
```

**Key**: Show what's possible in their timeline, explain trade-offs

#### Scenario 3: Vague Requirements

**Product**: "Make the dashboard more engaging"

**Your Questions**:
```
Clarifying questions to ask:

1. What specific user feedback led to this?
2. What does "engaging" mean? (faster? prettier? more data?)
3. What actions do we want users to take on dashboard?
4. Which dashboard widgets are most/least used? (check analytics)
5. What's the success metric? (time on dashboard? click-through rate?)

Then propose specific, measurable improvements:
- Add data visualizations (charts/graphs)
- Add real-time updates (WebSocket)
- Improve load time (< 2s target)
- Add personalization (user can configure widgets)
```

**Key**: Ask questions to clarify, propose specific solutions

### Working with Designers

**UX/UI Design → React/MUI Implementation**

#### 1. Design Handoff Review

**When designer shares mockups, check**:

**Feasibility**:
- [ ] All designs use MUI components (or custom components exist)
- [ ] Interactions are technically possible (no impossible animations)
- [ ] Responsive breakpoints defined (mobile, tablet, desktop)
- [ ] Loading and error states designed
- [ ] Empty states designed ("No results found")

**Accessibility**:
- [ ] Color contrast meets WCAG AA standards
- [ ] Focus states visible
- [ ] Touch targets ≥44px for mobile
- [ ] Alt text for images
- [ ] Form labels clear

**Data Requirements**:
- [ ] API data structure understood
- [ ] All fields have data source
- [ ] Loading/error scenarios designed

#### 2. Design → Code Translation

**Design System Mapping** to MUI:

| Design Element | MUI Component | Notes |
|----------------|---------------|-------|
| Button (primary) | `<Button variant="contained" color="primary">` | |
| Button (secondary) | `<Button variant="outlined" color="secondary">` | |
| Input field | `<TextField variant="outlined" fullWidth>` | Add label prop |
| Dropdown | `<Select>` + `<MenuItem>` | Use FormControl wrapper |
| Card | `<Card>` + `<CardContent>` | Add elevation prop |
| Modal | `<Dialog>` + `<DialogTitle>` + `<DialogContent>` | |
| Alert/Toast | `<Alert severity="success">` or `<Snackbar>` | |
| Loading | `<CircularProgress>` or `<LinearProgress>` | |
| Table | `<Table>` + `<TableHead>` + `<TableBody>` | |

**Spacing from Design** → MUI theme:
- 4px → `theme.spacing(0.5)` or `sx={{ p: 0.5 }}`
- 8px → `theme.spacing(1)` or `sx={{ p: 1 }}`
- 16px → `theme.spacing(2)` or `sx={{ p: 2 }}`
- 24px → `theme.spacing(3)` or `sx={{ p: 3 }}`
- 32px → `theme.spacing(4)` or `sx={{ p: 4 }}`

**Colors from Design** → MUI theme:
```javascript
// theme.js
const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2', // From design system
    },
    secondary: {
      main: '#dc004e',
    },
    success: {
      main: '#2e7d32',
    },
    // Add custom colors
    brand: {
      purple: '#6C5CE7',
      orange: '#FD79A8',
    }
  }
});

// Usage
<Box sx={{ bgcolor: 'brand.purple' }}>
```

#### 3. Feedback to Designers

**Provide constructive feedback early**:

**Example: Design uses non-standard component**
```
"This toggle design looks great, but MUI doesn't have this exact style.

Options:
1. Use MUI Switch component (standard, accessible, 1 hour)
2. Build custom component matching design (3 hours)
3. Adjust design to match MUI Switch (0 hours)

Recommendation: Option 1. MUI Switch is accessible and familiar to users.
We can customize colors to match brand if needed."
```

**Example: Design missing states**
```
"Love the happy path design! Can we also design:
- Loading state (while data fetches)
- Error state (if API fails)
- Empty state (no search results)
- Disabled state (button when form invalid)

These states prevent janky user experience during edge cases."
```

---

## From Requirements to Implementation

### The Feature Development Lifecycle

**1. Discovery** (Product/Design lead, Dev input)
- User research
- Problem validation
- Solution ideation
- Technical feasibility check ← Developer input

**2. Planning** (Collaborative)
- PRD created
- Design mockups
- Technical architecture
- Effort estimation ← Developer leads
- Story breakdown ← Developer leads

**3. Implementation** (Developer leads)
- Backend development
- Frontend development
- Testing (unit, integration, E2E)
- Code review

**4. Validation** (Collaborative)
- QA testing
- UAT (User Acceptance Testing)
- Performance testing
- Security review

**5. Launch** (Collaborative)
- Deployment
- Monitoring
- User feedback collection
- Success metric tracking

**6. Iterate** (Collaborative)
- Analyze metrics
- User feedback
- Identify improvements
- Start next cycle

### Example: Full Feature Lifecycle

**Feature**: User Profile Customization

#### Phase 1: Discovery (Week 1)

**Product Research**:
- 60% of users requested profile customization
- Users want: profile picture, bio, social links
- Key pain point: "My profile looks generic"

**Developer Input**:
- Profile pictures: Need file upload (S3), image processing
- Bio: Rich text? Plain text? Character limit?
- Social links: Which platforms? Validation?

**Outcome**: PRD created, design started

#### Phase 2: Planning (Week 2)

**PRD Review**:
- Scope: Profile picture + bio + 3 social links (Twitter, LinkedIn, GitHub)
- Success metric: >40% of users add profile picture within 30 days

**Design Handoff**:
- Upload modal design
- Profile page layout
- Empty states

**Technical Architecture**:
```
Backend:
- POST /api/profile/picture (upload to S3)
- PUT /api/profile (update bio, social links)
- GET /api/profile/:userId (fetch profile)

Frontend:
- ProfileEditModal component
- ImageUpload component
- SocialLinksForm component

Database:
ALTER TABLE users ADD COLUMN profile_picture_url TEXT;
ALTER TABLE users ADD COLUMN bio TEXT(500);
ALTER TABLE users ADD COLUMN social_links JSONB;
```

**Story Breakdown** (12 tasks, see "Converting User Stories to Technical Tasks" above)

**Estimation**: 2 weeks (1 backend, 1 frontend, working in parallel)

#### Phase 3: Implementation (Weeks 3-4)

**Week 3**:
- Backend: File upload endpoint, S3 integration, profile update API
- Frontend: Upload modal UI, bio form
- Tests: Unit tests for upload service

**Week 4**:
- Frontend: Social links form, profile display
- Integration: Connect frontend to backend
- Tests: Integration tests, E2E test for upload flow

**Code Review**: Tech lead reviews, requests changes (error handling, validation)

#### Phase 4: Validation (Week 5)

**QA Testing**:
- Test upload: various file types, sizes
- Test validation: URL format, character limits
- Test error cases: upload fails, network error

**Found Issues**:
- Image preview broken on mobile (fixed)
- Bio allows > 500 characters (fixed)
- No loading state during upload (fixed)

**UAT**: Product team tests, approves

#### Phase 5: Launch (Week 6)

**Deployment**:
- Deploy to staging (Monday)
- Smoke test (Tuesday)
- Deploy to production (Wednesday)
- Monitor error rates, performance

**Metrics Tracking**:
- Profile picture uploads: 0 → tracking
- Bio updates: 0 → tracking
- Page load time: 1.2s (within target)

#### Phase 6: Iterate (Weeks 7-8)

**Week 7 Results**:
- 25% of users uploaded profile picture (below 40% target)
- Users requesting: More social platforms (Instagram, TikTok)

**Iteration Plan**:
- Add Instagram, TikTok links
- Add email reminder to complete profile
- A/B test: Modal vs. inline edit

---

## Product Metrics for Developers

### Understanding Success Metrics

**Developers should know** how their work is measured:

**Common Product Metrics**:

1. **Adoption Rate**
   - % of users who try the feature
   - Example: 60% of users uploaded profile picture

2. **Engagement Rate**
   - % of users who regularly use feature
   - Example: 40% of users edit profile monthly

3. **Completion Rate**
   - % of users who complete flow
   - Example: 80% of users who start upload complete it

4. **Time to Value**
   - How long until user gets value
   - Example: User uploads picture in < 2 minutes

5. **Error Rate**
   - % of attempts that fail
   - Example: 2% of uploads fail (target: < 5%)

6. **Performance**
   - Response time, load time
   - Example: Profile loads in < 500ms (target: < 1s)

### Instrumenting Code for Metrics

**Track user actions**:

```javascript
// Backend: Track feature usage
router.post('/api/profile/picture', authenticate, async (req, res) => {
  try {
    // Upload logic
    const result = await uploadToS3(req.file);

    // Track success
    analytics.track('profile_picture_uploaded', {
      userId: req.user.id,
      fileSize: req.file.size,
      duration: Date.now() - req.startTime
    });

    res.json(result);
  } catch (error) {
    // Track failure
    analytics.track('profile_picture_upload_failed', {
      userId: req.user.id,
      error: error.message
    });

    throw error;
  }
});
```

```javascript
// Frontend: Track user interactions
function ProfileEditModal() {
  const handleUploadClick = () => {
    // Track intent
    analytics.track('profile_picture_upload_started');

    // Open file picker
    fileInputRef.current.click();
  };

  const handleUploadComplete = () => {
    // Track completion
    analytics.track('profile_picture_upload_completed', {
      duration: Date.now() - uploadStartTime
    });
  };

  return (
    <Dialog open={open}>
      <Button onClick={handleUploadClick}>Upload Picture</Button>
    </Dialog>
  );
}
```

**Logging for Product Insights**:

```javascript
// Good: Structured logging with context
logger.info('User completed profile', {
  userId: user.id,
  completionTime: Date.now() - startTime,
  fieldsCompleted: ['picture', 'bio', 'social_links'],
  source: 'onboarding_flow'
});

// Bad: Generic logging
console.log('Profile completed'); // ❌ No context
```

---

## Quick Reference

### Feature Prioritization Checklist

Before building a feature, answer:

- [ ] **User Problem**: What problem does this solve?
- [ ] **User Impact**: How many users affected? How severely?
- [ ] **Business Impact**: Revenue? Retention? Support tickets?
- [ ] **Effort**: How long will this take? (realistic estimate)
- [ ] **Alternatives**: What else could we build instead?
- [ ] **Success Metrics**: How will we know this worked?
- [ ] **Dependencies**: What do we need before starting?
- [ ] **Risks**: What could go wrong?

### User Story Template

```
As a [user type],
I want to [action],
so that [benefit].

Acceptance Criteria:
- [Specific, measurable criterion 1]
- [Specific, measurable criterion 2]
- [Specific, measurable criterion 3]

Technical Notes:
- [Implementation detail]
- [Performance requirement]
- [Security consideration]
```

### Developer Questions for Product

**When requirements are unclear, ask**:

1. **User Problem**: "What user problem are we solving?"
2. **User Research**: "What evidence do we have that users need this?"
3. **Success Metrics**: "How will we measure if this works?"
4. **Priority**: "Why now? What else could we build instead?"
5. **Scope**: "What's the MVP? What can we defer?"
6. **Edge Cases**: "What happens if [edge case]?"
7. **Performance**: "What's acceptable performance?" (load time, etc.)
8. **Data**: "Where does this data come from?"

### Product Collaboration Anti-Patterns

**Avoid these**:

❌ **"That's not my job"**: Developers who refuse to understand product context
❌ **"Just tell me what to build"**: Blindly implementing without questioning
❌ **"That's impossible"**: Saying no without exploring alternatives
❌ **"It's technically correct"**: Building something useless but technically sound
❌ **"Users are stupid"**: Blaming users instead of improving design
❌ **"We'll fix it later"**: Launching known bad UX with no plan to improve
❌ **"I know better than product"**: Ignoring user research in favor of personal opinion

---

## Integration with Existing Guides

### Connects to Project Management (project-management.md)

**project-management.md covers**:
- Task breakdown
- Sprint planning
- Delivery workflow

**This guide adds**:
- Feature prioritization (RICE)
- User story creation
- Product requirements
- Product → Technical translation

**Together**: Complete product-to-delivery lifecycle

### Connects to Quality Management (quality-management.md)

**quality-management.md covers**:
- Incident response
- Root cause analysis

**This guide adds**:
- Proactive quality through user research
- Success metrics validation

**Together**: Build the right thing, build it right

### Connects to Technical Guides

**React/MUI guides** (react.md, mui.md):
- Technical implementation patterns

**This guide adds**:
- Design → Code translation
- UX requirements → React components

**Together**: User-centered technical implementation

---

## Summary

**Core Principles**:

1. **Understand the Why** - Know user problems, not just feature requests
2. **Prioritize Objectively** - Use RICE or similar data-driven methods
3. **Collaborate Actively** - Provide technical input during planning
4. **Measure Success** - Track metrics to validate impact
5. **Iterate Based on Data** - Build, measure, learn, repeat

**Developer's Product Mindset**:
- ✓ Question requirements to understand user needs
- ✓ Propose technical alternatives with trade-offs
- ✓ Instrument code to measure success
- ✓ Work with product/design as collaborative partners
- ✓ Balance user needs with technical excellence

**Remember**: You're not just writing code - you're solving user problems. Understanding product thinking makes you a more effective developer and valuable team member.