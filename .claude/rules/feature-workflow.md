# Feature Development Workflow (Constitution-Driven)

A comprehensive 7-phase, constitution-driven workflow for structured feature development from principles to production code. Combines spec-kit methodology with EARS requirements and Node.js/Express/React/MUI best practices.

---

## Overview

Transform feature ideas into production-ready code through a disciplined, constitution-driven process:

**Phase 0**: Constitution - Establish foundational principles (project-level, one-time)
**Phase 1**: Specify - Define functional requirements using EARS format
**Phase 2**: Clarify - Resolve ambiguities through structured Q&A
**Phase 3**: Plan - Design technical architecture and components
**Phase 4**: Tasks - Create dependency-ordered implementation tasks
**Phase 5**: Analyze - Validate cross-artifact consistency
**Phase 6**: Implement - Execute tasks incrementally with reviews

**Key Principles**:
- Constitution establishes project-wide principles (created once)
- Each feature progresses through phases 1-6
- Explicit user approval required between phases
- No phase skipping, no combined steps
- All decisions align with constitutional principles

---

## File Structure

```
.claude/
├── PROJECT_CONSTITUTION.md        # Project principles (Phase 0)
├── specs/
│   ├── 001-user-authentication/   # Feature 001
│   │   ├── spec.md                # Requirements (Phase 1)
│   │   ├── clarifications.md      # Q&A (Phase 2)
│   │   ├── plan.md                # Design (Phase 3)
│   │   ├── tasks.md               # Implementation tasks (Phase 4)
│   │   └── analysis.md            # Validation report (Phase 5)
│   ├── 002-payment-integration/   # Feature 002
│   │   └── ...
│   └── 003-user-dashboard/        # Feature 003
│       └── ...
└── scripts/                       # Automation scripts
    ├── new-feature.sh
    └── detect-phase.sh
```

**Feature Naming**: Three-digit number + kebab-case name (e.g., `001-user-authentication`)

---

## Phase 0: Constitution (Project-Level)

### Objective
Establish foundational principles, technical standards, and decision-making frameworks for the entire project. **Created once, referenced by all features.**

### When to Create
- Starting a new project
- Major architectural pivot
- Team alignment needed on principles
- Onboarding new team members

### When to Skip
- Project already has established guidelines in `.claude/`
- Small features in well-understood codebase
- Guidelines are clear and documented

### Output
Create `.claude/PROJECT_CONSTITUTION.md`

### Constitution Template

```markdown
# Project Constitution

**Last Updated**: 2026-01-11
**Version**: 1.0

---

## I. Project Values & Mission

### Mission Statement
[Brief statement of what this project aims to achieve]

**Example**: Build a secure, scalable e-commerce platform that enables small businesses to compete with enterprise retailers through intuitive tools and transparent pricing.

### Core Values
1. **Security First**: Never compromise on user data protection
2. **Performance Matters**: Sub-200ms API responses, <2s page loads
3. **Accessibility for All**: WCAG 2.1 AA compliance minimum
4. **Developer Experience**: Clear patterns, excellent documentation
5. **Pragmatic Excellence**: Ship quality code, not perfect code

---

## II. Technical Standards

### Technology Stack

**Backend**:
- Runtime: Node.js 18+ (LTS)
- Framework: Express.js 4.x
- Language: Modern JavaScript (ES6+) with ESM modules
- Database: PostgreSQL 15+
- Caching: Redis 7+
- Testing: Jest 29+

**Frontend**:
- Library: React 18+
- UI Framework: Material-UI (MUI) 5+
- State: React Query for server state, Context for UI state
- Forms: react-hook-form with Zod validation
- Testing: React Testing Library

**DevOps**:
- Version Control: Git with conventional commits
- CI/CD: GitHub Actions
- Deployment: Blue-green deployment strategy
- Monitoring: [Your monitoring solution]

### Architecture Patterns

**Backend Architecture**:
```
Request → Route → Controller → Service → Data Access → Database
          ↓         ↓            ↓           ↓
       Validation  Response   Business    Queries
                   Format      Logic
```

**Frontend Architecture**:
```
Pages → Layouts → Features → UI Components → MUI Base Components
  ↓        ↓          ↓             ↓
Routes  Structure  Logic      Presentation
```

### Code Quality Standards

**Coverage Requirements**:
- Overall project: ≥60%
- Per file: ≥20%
- No exceptions

**Documentation Requirements**:
- JSDoc on all functions (required)
- README for each major feature
- API documentation for all endpoints
- Inline comments for complex logic only

**Security Requirements**:
- Input validation on all endpoints
- Authentication on protected routes
- Authorization checks in service layer
- No secrets in code or logs
- HTTPS in production
- Rate limiting on API endpoints

**Performance Requirements**:
- API response time: <200ms (p95)
- Page load time: <2s (p95)
- Database query optimization (no N+1)
- React component memoization where appropriate

---

## III. Decision-Making Frameworks

### When to Choose Technology

**Add New Dependency When**:
- ✅ Solves specific, well-defined problem
- ✅ Active maintenance (updated in last 3 months)
- ✅ Strong community (>1000 GitHub stars)
- ✅ MIT/Apache 2.0 license
- ✅ <50KB added to bundle (frontend)
- ✅ Team consensus achieved

**Avoid Adding Dependency When**:
- ❌ Can implement in <100 lines
- ❌ Abandoned project (no updates in 12+ months)
- ❌ Duplicate functionality exists
- ❌ Adds significant bundle size for minor benefit

### When to Refactor

**Refactor When**:
- Code repeated in 3+ places (DRY violation)
- Function exceeds 50 lines
- Cyclomatic complexity >10
- Test coverage <20%
- Performance bottleneck identified

**Don't Refactor When**:
- Code works and is tested
- No clear benefit to maintainability
- Feature freeze in effect
- Time better spent on new features

### When to Write Tests

**Always Write Tests For**:
- Business logic functions
- API endpoints (integration tests)
- Utility functions
- React components with interactions
- Database queries

**Tests Optional For**:
- Simple UI components (presentational only)
- Configuration files
- Type definitions
- One-time migration scripts

### API Design Principles

**RESTful Conventions**:
- `GET /resource` - List (paginated)
- `GET /resource/:id` - Retrieve single
- `POST /resource` - Create
- `PUT /resource/:id` - Update (full)
- `PATCH /resource/:id` - Update (partial)
- `DELETE /resource/:id` - Delete

**Response Format**:
```json
{
  "success": true,
  "data": { ... },
  "pagination": { "page": 1, "total": 100 }
}
```

**Error Format**:
```json
{
  "success": false,
  "message": "User-friendly error message",
  "errors": { "field": "Specific error" }
}
```

### React Component Guidelines

**Component Structure**:
1. Functional components only (no classes)
2. Use hooks for state and effects
3. Props destructuring in function signature
4. Early returns for loading/error states
5. Main render at bottom

**File Organization**:
```
src/components/features/UserProfile/
├── UserProfile.jsx          # Main component
├── UserProfile.test.jsx     # Tests
├── UserProfileForm.jsx      # Sub-component
├── useUserProfile.js        # Custom hook
└── index.js                 # Exports
```

---

## IV. Development Workflow

### Git Workflow

**Branch Strategy**:
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/NNN-feature-name` - Feature branches
- `bugfix/NNN-bug-description` - Bug fixes
- `hotfix/NNN-critical-fix` - Production hotfixes

**Commit Convention**:
```
<type>(<scope>): <subject>

<body>

Co-authored-by: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

### Code Review Standards

**Review Checklist**:
1. Security: No secrets, input validated, auth checked
2. Correctness: Tests pass, logic sound, edge cases handled
3. Quality: Coverage ≥60%, JSDoc present, ESLint passes
4. Architecture: Follows patterns, proper separation of concerns
5. Documentation: README updated, API docs current

**Review Response**:
- Be respectful and constructive
- Provide specific, actionable feedback
- Explain the "why" behind suggestions
- Approve when standards met

### Deployment Process

**Staging Deployment**:
- Automatic on push to `develop`
- Smoke tests must pass
- Manual QA recommended

**Production Deployment**:
- Tag-triggered (`v1.0.0`)
- Blue-green deployment
- Requires approval
- Rollback plan mandatory

---

## V. Exceptions & Overrides

### When to Deviate from Constitution

**Valid Reasons**:
- Performance optimization (with benchmarks)
- Security vulnerability mitigation
- Legal/compliance requirements
- Technical limitations of dependencies
- Temporary workaround (documented with TODO and issue)

**Process for Deviation**:
1. Document reason in code comments
2. Create issue for proper solution
3. Get team/lead approval
4. Add to technical debt backlog

**Invalid Reasons**:
- "Faster to do it this way"
- "Just this once"
- "No one will notice"
- "Too hard to do it right"

---

## VI. Constitution Updates

### Amendment Process

1. **Propose Change**: Create issue with rationale
2. **Team Discussion**: Minimum 3 days for feedback
3. **Approval**: Requires team consensus
4. **Document**: Update constitution with version bump
5. **Communicate**: Announce change to team

### Review Schedule

- **Quarterly Review**: Every 3 months
- **Major Release**: Before each major version
- **Tech Change**: When adopting new major technology
- **Retrospective**: After significant incidents

---

## VII. Onboarding Checklist

New team members should:
- [ ] Read this constitution
- [ ] Read `.claude/CLAUDE.md` (development guidelines)
- [ ] Review coding standards (`.claude/rules/coding-standards.md`)
- [ ] Set up local development environment
- [ ] Complete "hello world" feature following workflow
- [ ] Pair program with experienced team member
- [ ] Shadow code review process

---

## VIII. References

**Internal Documentation**:
- `.claude/CLAUDE.md` - Main development guidelines
- `.claude/rules/coding-standards.md` - Standards hierarchy
- `.claude/rules/security.md` - Security requirements
- `.claude/rules/testing.md` - Testing practices
- `.claude/README.md` - Complete guide index

**External Resources**:
- [Conventional Commits](https://www.conventionalcommits.org/)
- [React Documentation](https://react.dev/)
- [Material-UI Documentation](https://mui.com/)
- [Express.js Guide](https://expressjs.com/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Signature**: This constitution represents our team's commitment to building quality software with clear principles and consistent practices.
```

### Process

1. **Draft Constitution**: Create initial document based on project needs
2. **Team Review**: Share with all team members for feedback
3. **Iterate**: Refine based on discussions (max 3 rounds)
4. **Finalize**: Get team consensus and sign off
5. **Communicate**: Make accessible to all team members

**Critical**: Constitution is created once per project, not per feature. All features reference this constitution.

---

## Phase 1: Specify Requirements

### Objective
Define functional requirements using EARS (Easy Approach to Requirements Syntax) format without specifying technology implementation.

### Output
Create `.claude/specs/NNN-feature-name/spec.md`

### EARS Format

Structure requirements using these patterns:

**Ubiquitous Requirements** (always active):
```
The [system] SHALL [capability]
```

**Event-Driven Requirements**:
```
WHEN [trigger event]
THEN the [system] SHALL [response]
```

**State-Driven Requirements**:
```
WHILE [system state]
the [system] SHALL [response]
```

**Conditional Requirements**:
```
IF [condition]
THEN the [system] SHALL [response]
```

**Optional Feature Requirements**:
```
WHERE [feature is included]
the [system] SHALL [capability]
```

**Unwanted Behavior**:
```
IF [condition]
THEN the [system] SHALL NOT [response]
```

### Specification Template

```markdown
# Feature Specification: [Feature Name]

**Feature Number**: [001, 002, 003, ...]
**Created**: 2026-01-11
**Status**: Draft | In Clarification | Approved
**Constitutional Alignment**: ✓ Aligns with Section II.A (Technical Standards)

---

## Overview

Brief description of the feature and its business value (2-3 paragraphs).

**Problem Statement**: What problem does this solve?

**Success Criteria**: How do we know this feature succeeds?

---

## User Stories

### Story 1: [Title]
**As a** [user role]
**I want to** [action]
**So that** [benefit]

**Priority**: High | Medium | Low
**Constitutional Reference**: [Which section of constitution this supports]

### Story 2: [Title]
...

---

## Functional Requirements

### FR-1: [Requirement Name]
WHEN [event]
THEN the system SHALL [response]

**Priority**: Must Have | Should Have | Nice to Have
**Acceptance Criteria**:
- [ ] Criterion 1 (testable)
- [ ] Criterion 2 (testable)
- [ ] Criterion 3 (testable)

**Constitutional Alignment**: Section II.C (Security Requirements)

### FR-2: [Requirement Name]
IF [condition]
THEN the system SHALL [response]

...

---

## Non-Functional Requirements

### NFR-1: Performance
The system SHALL respond to API requests within 200ms for 95% of requests.

**Measurement**: p95 latency <200ms
**Constitutional Reference**: Section II.D (Performance Requirements)

### NFR-2: Security
The system SHALL validate all user inputs against XSS and SQL injection attacks.

**Constitutional Reference**: Section II.C (Security Requirements)

### NFR-3: Scalability
The system SHALL support up to 10,000 concurrent users without degradation.

### NFR-4: Accessibility
The system SHALL comply with WCAG 2.1 AA standards.

**Constitutional Reference**: Section I.B (Core Values - Accessibility)

### NFR-5: Test Coverage
The system SHALL maintain ≥60% overall test coverage and ≥20% per file.

**Constitutional Reference**: Section II.C (Code Quality Standards)

---

## Constraints

- Must integrate with existing authentication system
- Must maintain backward compatibility with API v1
- Must deploy without downtime (blue-green deployment)
- Database migration must complete in <10 minutes
- No new major dependencies without team approval

**Constitutional References**:
- Section IV.B (Git Workflow - Deployment Process)
- Section III.A (When to Choose Technology)

---

## Dependencies

**External**:
- Payment processor API (Stripe v2023-10-16)
- Email service (SendGrid API v3)

**Internal**:
- User service v2.3+
- Authentication middleware v1.5+
- Database: PostgreSQL 15+

**Constitutional Compliance**: All dependencies meet Section III.A criteria

---

## Out of Scope

- Mobile app integration (future phase)
- Advanced analytics dashboard (separate project #234)
- Internationalization (planned for v2.0)
- Real-time notifications (separate feature #003)

---

## Assumptions

- Users have basic understanding of the interface
- Authentication tokens are valid for 1 hour (existing system)
- Database supports required transaction isolation level (SERIALIZABLE)
- Network latency between services <50ms

---

## Open Questions

*(Will be resolved in Clarify phase)*

1. Question about specific behavior?
2. Clarification needed on edge case?
3. Technical constraint unclear?

---

## References

- Issue: #123
- Product Requirements Document: [link]
- Market Research: [link]
- User Feedback: [link]
- Constitutional Sections: I.B, II.C, II.D, III.A, IV.B
```

### Process

1. **Generate Initial Spec**: Create comprehensive first draft
2. **No Sequential Questioning**: Present complete spec, not question-by-question
3. **Iterate Based on Feedback**: Refine based on user input
4. **Identify Open Questions**: List items needing clarification
5. **Obtain Explicit Approval**: User must approve to advance to Clarify

**Critical**: Do NOT proceed to Clarify phase without explicit user approval.

---

## Phase 2: Clarify Ambiguities

### Objective
Resolve all ambiguities, edge cases, and open questions through structured Q&A before technical design begins.

### Output
Create `.claude/specs/NNN-feature-name/clarifications.md` OR append to `spec.md`

### Clarification Rules

1. **Maximum 5 questions per round** - Focus on highest priority ambiguities
2. **Specific and focused** - Each question addresses one specific ambiguity
3. **Provide context** - Explain why clarification needed
4. **Suggest options** - Offer 2-3 possible interpretations
5. **Reference requirements** - Link to specific FR-X or NFR-X

### Clarification Template

```markdown
# Clarifications: [Feature Name]

**Feature Number**: [001]
**Clarification Round**: 1 of N
**Status**: Questions Pending | Answered | Approved

---

## Round 1 Questions

### Q1: User Permission Scope (FR-3)

**Context**: FR-3 states "users can manage their own data" but doesn't specify if this includes deletion.

**Ambiguity**: Can users permanently delete their account and all associated data?

**Options**:
A) Yes, users can delete their account (GDPR compliance)
B) No, users can only deactivate (soft delete)
C) Admins must approve deletion requests

**Impact**: Affects database design and GDPR compliance

**Constitutional Reference**: Section II.C (Security - data protection)

---

### A1: [User's Answer]

**Decision**: Option A - Users can delete their account

**Rationale**: GDPR compliance requirement

**Updated Requirements**:
- FR-3 updated to: "WHEN user requests account deletion THEN system SHALL permanently delete user data within 30 days"
- Added NFR-6: "System SHALL comply with GDPR right to deletion"

---

## Round 2 Questions

*(If needed after Round 1 answers)*

### Q2: Payment Retry Logic (FR-7)

...

---

## Resolution Summary

**Total Questions**: 5
**Total Rounds**: 2
**Clarifications Complete**: ✓
**Spec Updated**: ✓
**Ready for Plan Phase**: ✓

**Updated Requirements**:
- FR-3: Added permanent deletion capability
- FR-7: Specified 3 retry attempts with exponential backoff
- NFR-6: Added GDPR compliance requirement

**Constitutional Alignment Verified**: All clarifications align with Section II.C
```

### Process

1. **Identify Ambiguities**: Review spec for unclear items
2. **Prioritize Questions**: Focus on blockers and high-impact items
3. **Ask Maximum 5 Questions**: Keep rounds focused
4. **Document Answers**: Record decisions with rationale
5. **Update Spec**: Incorporate clarifications into spec.md
6. **Repeat if Needed**: Maximum 3 rounds recommended
7. **Obtain Explicit Approval**: User confirms all ambiguities resolved

**Critical**: Continue clarification rounds until no ambiguities remain. Get explicit approval before Plan phase.

---

## Phase 3: Plan Technical Design

### Objective
Design technical architecture and components based on clarified requirements. Research existing codebase patterns before creating plan.

### Output
Create `.claude/specs/NNN-feature-name/plan.md`

### Research-Driven Approach

Before creating plan:
1. **Research existing patterns** (use Grep, Glob, Read)
   - Authentication mechanisms
   - API endpoint patterns
   - Database models
   - React component structure
   - Error handling approaches

2. **Review similar features** (use Read, Grep)
   - Previous implementations
   - Established conventions
   - Reusable components

3. **Check external dependencies**
   - Library versions
   - API documentation
   - Breaking changes

4. **Summarize findings** in plan with citations

### Plan Template

```markdown
# Technical Plan: [Feature Name]

**Feature Number**: [001]
**Created**: 2026-01-11
**Status**: Draft | In Review | Approved

**References**:
- Specification: `.claude/specs/001-feature-name/spec.md`
- Clarifications: `.claude/specs/001-feature-name/clarifications.md`
- Constitution: `.claude/PROJECT_CONSTITUTION.md`

---

## Constitutional Compliance

This plan adheres to:
- ✓ Section II.A: Tech stack (Node.js/Express/React/MUI)
- ✓ Section II.B: Architecture patterns (Routes→Controllers→Services→Data)
- ✓ Section II.C: Code quality (≥60% coverage, JSDoc required)
- ✓ Section II.C: Security (input validation, auth/authz)
- ✓ Section II.D: Performance (<200ms p95 API, <2s page load)

---

## Research Summary

### Existing Patterns Analyzed

**Authentication** (`src/middleware/auth.middleware.js`):
- JWT-based with `authenticate` middleware
- Token validation extracts `req.user`
- Authorization via `authorize(...roles)` middleware
- Pattern established in PR #45

**API Endpoints** (`src/routes/*.routes.js`):
- RESTful conventions followed
- Middleware chain: auth → validation → controller
- asyncHandler wrapper for error handling
- Pattern documented in `.claude/rules/express.md`

**Database Models** (`src/models/*.model.js`):
- PostgreSQL with parameterized queries
- CRUD methods: create, findById, update, delete
- Soft delete pattern for user data
- Migration script convention in `migrations/`

**React Components** (`src/components/`):
- Functional components with hooks
- React Query for data fetching (5min stale time)
- react-hook-form + Zod validation
- MUI components with sx prop styling

### Similar Features Reviewed

**Password Reset Flow** (PR #234):
- Email service integration pattern
- Token generation and validation
- Time-limited links (24h expiry)
- Similar user interaction flow

**Profile Management** (`src/components/user/UserProfile.jsx`):
- Form handling pattern to reuse
- Edit/save flow UX
- Optimistic updates with React Query
- Error handling with Snackbar

### External Dependencies

**No new dependencies required** - using existing stack:
- `jsonwebtoken` (v9.0.2) for tokens
- `bcrypt` (v5.1.1) for hashing
- `zod` (v3.22.4) for validation
- `react-hook-form` (v7.49.0) for forms
- All meet constitutional criteria (Section III.A)

---

## Architecture Overview

### System Context

```
┌──────────────┐         ┌────────────────┐         ┌──────────────┐
│   Client     │────────▶│   API Gateway  │────────▶│   Feature    │
│  (React)     │   HTTPS │   (Express)    │   Auth  │   Service    │
└──────────────┘         └────────────────┘         └───────┬──────┘
                                                             │
                                                             ▼
                         ┌────────────────┐         ┌──────────────┐
                         │  Email Service │◀────────│   Database   │
                         │   (SendGrid)   │         │ (PostgreSQL) │
                         └────────────────┘         └──────────────┘
```

### Component Architecture

**Backend Flow**:
```
HTTP Request
    │
    ▼
Route (feature.routes.js)
    │
    ├─▶ authenticate middleware
    ├─▶ authorize middleware
    ├─▶ validateFeature middleware
    │
    ▼
Controller (feature.controller.js)
    │
    ├─▶ Request parsing
    ├─▶ Response formatting
    │
    ▼
Service (feature.service.js)
    │
    ├─▶ Business logic
    ├─▶ Validation (Zod)
    ├─▶ Authorization checks
    │
    ▼
Data Access (feature.model.js)
    │
    ├─▶ Database queries
    ├─▶ Transactions
    │
    ▼
PostgreSQL Database
```

**Frontend Flow**:
```
User Interaction
    │
    ▼
Page Component (FeaturePage.jsx)
    │
    ├─▶ Layout (MainLayout.jsx)
    │
    ▼
Feature Component (FeatureManager.jsx)
    │
    ├─▶ useFeatures hook (React Query)
    ├─▶ FeatureList component
    ├─▶ FeatureForm component
    │
    ▼
UI Components (MUI)
    │
    ├─▶ Card, TextField, Button
    ├─▶ Theme-based styling (sx prop)
    │
    ▼
API Client (axios/fetch)
```

---

## Component Specifications

### Backend Components

#### 1. Routes: `src/routes/feature.routes.js`

**Endpoints** (Maps to FR-1 through FR-5):
```javascript
POST   /api/feature           // Create (FR-1)
GET    /api/feature           // List (FR-2)
GET    /api/feature/:id       // Retrieve (FR-3)
PUT    /api/feature/:id       // Update (FR-4)
DELETE /api/feature/:id       // Delete (FR-5)
```

**Middleware Chain**:
```javascript
router.post('/feature',
  authenticate,                    // JWT validation
  authorize('user', 'admin'),      // Role check
  validateFeatureCreate,           // Zod schema
  asyncHandler(createFeature)      // Controller
);
```

**Rate Limiting**: Use existing `apiLimiter` (100 req/15min per IP)

**Constitutional Compliance**: Section IV.B (RESTful conventions)

#### 2. Controller: `src/controllers/feature.controller.js`

**Functions**:
```javascript
createFeature(req, res)    // FR-1: Create new feature
listFeatures(req, res)     // FR-2: List user's features (paginated)
getFeature(req, res)       // FR-3: Get single feature
updateFeature(req, res)    // FR-4: Update feature
deleteFeature(req, res)    // FR-5: Delete feature (soft delete)
```

**Response Format** (Constitutional Section III.C):
```javascript
// Success
{ success: true, data: { ... }, pagination: { ... } }

// Error
{ success: false, message: "...", errors: { field: "..." } }
```

**Error Handling**: Use existing error classes:
- `ValidationError` (400)
- `UnauthorizedError` (401)
- `ForbiddenError` (403)
- `NotFoundError` (404)

#### 3. Service: `src/services/feature.service.js`

**Business Logic**:
```javascript
async function createFeature(userId, data) {
  // 1. Validate input (Zod schema)
  const validated = featureSchema.parse(data);

  // 2. Check business rules
  await checkUserFeatureLimit(userId); // Max 100 per user

  // 3. Create in database
  const feature = await FeatureModel.create({
    userId,
    ...validated,
    status: 'active'
  });

  // 4. Emit event for audit log
  eventBus.emit('feature.created', { userId, featureId: feature.id });

  // 5. Return result
  return feature;
}
```

**Validation Schema** (Zod):
```javascript
const featureSchema = z.object({
  name: z.string().min(1).max(255),
  description: z.string().max(2000).optional(),
  metadata: z.record(z.any()).optional()
});
```

**Business Rules** (Maps to requirements):
- FR-1.AC1: Name required (1-255 chars)
- FR-1.AC2: User can have max 100 features
- FR-5.AC1: Only owner can delete
- NFR-2: Validate all inputs

**Constitutional Compliance**: Section II.B (Service layer patterns)

#### 4. Data Model: `src/models/feature.model.js`

**Database Schema** (PostgreSQL):
```sql
CREATE TABLE features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,  -- Soft delete

  CONSTRAINT features_name_user_unique UNIQUE (user_id, name),
  INDEX idx_features_user_id (user_id),
  INDEX idx_features_status (status),
  INDEX idx_features_created_at (created_at DESC)
);
```

**Model Methods**:
```javascript
class FeatureModel {
  static async create(data)              // Insert new record
  static async findById(id)              // Retrieve by ID
  static async findByUserId(userId, opts) // List with pagination
  static async update(id, data)          // Update record
  static async softDelete(id)            // Soft delete
  static async hardDelete(id)            // Hard delete (admin only)
}
```

**Query Optimization** (NFR-1: Performance):
- Indexes on `user_id`, `status`, `created_at`
- Pagination with limit/offset
- Connection pooling (max 20)
- Prepared statements (SQL injection prevention)

**Constitutional Compliance**: Section II.B (Data access patterns)

#### 5. Migration: `migrations/20260111_create_features_table.sql`

**Up Migration**:
```sql
-- Create table, indexes, constraints
-- Add foreign keys
-- Grant permissions
```

**Down Migration**:
```sql
-- Drop indexes
-- Drop table
```

**Rollback Strategy**: Down migration must complete in <1 minute

**Constitutional Compliance**: Section I.C (Deployment constraints)

---

### Frontend Components

#### 1. Page: `src/pages/FeaturesPage.jsx`

**Route**: `/features`

**Layout**: Uses `MainLayout` with sidebar navigation

**Components**:
```jsx
<MainLayout>
  <FeatureManager userId={currentUser.id} />
</MainLayout>
```

**Constitutional Compliance**: Section II.B (Frontend architecture)

#### 2. Feature Manager: `src/components/features/FeatureManager.jsx`

**Purpose**: Main container for feature management

**State Management**:
```javascript
const { data: features, isLoading, error } = useFeatures(userId);
const [dialogOpen, setDialogOpen] = useState(false);
const [selectedFeature, setSelectedFeature] = useState(null);
```

**UI Structure**:
```jsx
<Box sx={{ p: 3 }}>
  <FeatureHeader onCreateClick={() => setDialogOpen(true)} />

  {isLoading && <CircularProgress />}
  {error && <Alert severity="error">{error.message}</Alert>}
  {features && <FeatureList features={features} onEdit={...} onDelete={...} />}

  <FeatureDialog
    open={dialogOpen}
    feature={selectedFeature}
    onClose={() => setDialogOpen(false)}
    onSave={handleSave}
  />
</Box>
```

#### 3. Feature List: `src/components/features/FeatureList.jsx`

**Props**:
```typescript
interface FeatureListProps {
  features: Feature[];
  onEdit: (feature: Feature) => void;
  onDelete: (featureId: string) => void;
}
```

**UI**: Grid of `FeatureCard` components

```jsx
<Grid container spacing={3}>
  {features.map(feature => (
    <Grid item xs={12} sm={6} md={4} key={feature.id}>
      <FeatureCard
        feature={feature}
        onEdit={() => onEdit(feature)}
        onDelete={() => onDelete(feature.id)}
      />
    </Grid>
  ))}
</Grid>
```

**Empty State**:
```jsx
{features.length === 0 && (
  <Box sx={{ textAlign: 'center', py: 8 }}>
    <Typography variant="h6" color="text.secondary">
      No features yet
    </Typography>
    <Button variant="contained" onClick={onCreateClick} sx={{ mt: 2 }}>
      Create First Feature
    </Button>
  </Box>
)}
```

#### 4. Feature Card: `src/components/features/FeatureCard.jsx`

**Props**:
```typescript
interface FeatureCardProps {
  feature: Feature;
  onEdit: () => void;
  onDelete: () => void;
}
```

**UI** (MUI Card):
```jsx
<Card sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
  <CardContent sx={{ flexGrow: 1 }}>
    <Typography variant="h6" gutterBottom>
      {feature.name}
    </Typography>
    <Typography variant="body2" color="text.secondary">
      {feature.description}
    </Typography>
    <Chip
      label={feature.status}
      color={feature.status === 'active' ? 'success' : 'default'}
      size="small"
      sx={{ mt: 2 }}
    />
  </CardContent>
  <CardActions>
    <IconButton onClick={onEdit} aria-label="edit feature">
      <EditIcon />
    </IconButton>
    <IconButton onClick={onDelete} aria-label="delete feature">
      <DeleteIcon />
    </IconButton>
  </CardActions>
</Card>
```

**Accessibility** (NFR-4):
- Proper aria-labels
- Keyboard navigation support
- Color contrast meets WCAG 2.1 AA

**Constitutional Compliance**: Section I.B (Accessibility for All)

#### 5. Feature Form: `src/components/features/FeatureForm.jsx`

**Props**:
```typescript
interface FeatureFormProps {
  feature?: Feature;  // For editing
  onSubmit: (data: FeatureData) => Promise<void>;
  onCancel: () => void;
}
```

**Form Handling** (react-hook-form + Zod):
```javascript
const schema = z.object({
  name: z.string().min(1, 'Name required').max(255, 'Name too long'),
  description: z.string().max(2000, 'Description too long').optional()
});

const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
  resolver: zodResolver(schema),
  defaultValues: feature || {}
});
```

**UI** (MUI Form):
```jsx
<form onSubmit={handleSubmit(onSubmit)}>
  <TextField
    {...register('name')}
    label="Feature Name"
    fullWidth
    required
    error={!!errors.name}
    helperText={errors.name?.message}
    margin="normal"
  />

  <TextField
    {...register('description')}
    label="Description"
    fullWidth
    multiline
    rows={4}
    error={!!errors.description}
    helperText={errors.description?.message}
    margin="normal"
  />

  <Box sx={{ display: 'flex', gap: 2, mt: 3 }}>
    <Button
      type="submit"
      variant="contained"
      disabled={isSubmitting}
      fullWidth
    >
      {isSubmitting ? 'Saving...' : 'Save'}
    </Button>
    <Button onClick={onCancel} variant="outlined" fullWidth>
      Cancel
    </Button>
  </Box>
</form>
```

#### 6. Hook: `src/hooks/useFeatures.js`

**Purpose**: Manage feature data with React Query

**Implementation**:
```javascript
export function useFeatures(userId) {
  return useQuery({
    queryKey: ['features', userId],
    queryFn: () => api.get(`/api/feature?userId=${userId}`).then(r => r.data),
    staleTime: 5 * 60 * 1000,  // 5 minutes
    enabled: !!userId
  });
}

export function useCreateFeature() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data) => api.post('/api/feature', data).then(r => r.data),
    onSuccess: (data, variables) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['features', data.userId] });
      // Or optimistic update
      queryClient.setQueryData(['features', data.userId], (old) => [...old, data]);
    }
  });
}

export function useUpdateFeature() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }) => api.put(`/api/feature/${id}`, data).then(r => r.data),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['features', data.userId] });
    }
  });
}

export function useDeleteFeature() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id) => api.delete(`/api/feature/${id}`),
    onSuccess: (_, id, context) => {
      queryClient.invalidateQueries({ queryKey: ['features'] });
    }
  });
}
```

**Constitutional Compliance**: Section II.A (React Query for server state)

---

## Data Models

### Feature Entity

**Properties**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK | Unique identifier |
| userId | UUID | FK, NOT NULL | Owner reference |
| name | VARCHAR(255) | NOT NULL | Feature name |
| description | TEXT | NULL | Optional description |
| status | VARCHAR(50) | NOT NULL, DEFAULT 'active' | Feature status |
| metadata | JSONB | NULL | Flexible JSON data |
| createdAt | TIMESTAMP | NOT NULL | Creation time |
| updatedAt | TIMESTAMP | NOT NULL | Last update |
| deletedAt | TIMESTAMP | NULL | Soft delete time |

**Validation Rules** (enforced in service layer):
- Name: 1-255 characters, required
- Description: 0-2000 characters, optional
- Status: enum('active', 'inactive', 'archived')
- User must exist (FK constraint)
- Unique name per user

**Relationships**:
- Belongs to User (many-to-one)
- Has many FeatureEvents (one-to-many, audit log)

---

## API Specifications

### POST /api/feature

**Purpose**: Create new feature (FR-1)

**Authentication**: Required (JWT)

**Request**:
```json
{
  "name": "Feature name",
  "description": "Optional description",
  "metadata": { "key": "value" }
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "name": "Feature name",
    "description": "Optional description",
    "status": "active",
    "metadata": { "key": "value" },
    "createdAt": "2026-01-11T10:00:00Z",
    "updatedAt": "2026-01-11T10:00:00Z"
  }
}
```

**Errors**:
- `400` Validation error (name missing/too long, description too long)
- `401` Unauthorized (no/invalid token)
- `409` Conflict (duplicate name for user)
- `429` Too many requests (rate limit)

**Performance Target** (NFR-1): <200ms p95

**Constitutional Reference**: Section III.C (API Response Format)

### GET /api/feature

**Purpose**: List user's features (FR-2)

**Authentication**: Required

**Query Parameters**:
- `page` (integer, default: 1)
- `limit` (integer, default: 20, max: 100)
- `status` (string, optional: 'active', 'inactive', 'archived')
- `sort` (string, default: '-createdAt')

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    { "id": "...", "name": "...", ... },
    { "id": "...", "name": "...", ... }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

**Errors**:
- `401` Unauthorized
- `400` Invalid query parameters

**Performance Target**: <150ms p95 (indexed query)

### GET /api/feature/:id

**Purpose**: Retrieve single feature (FR-3)

**Authentication**: Required

**Authorization**: User must own feature OR be admin

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "name": "Feature name",
    ...
  }
}
```

**Errors**:
- `401` Unauthorized
- `403` Forbidden (not owner)
- `404` Not found

### PUT /api/feature/:id

**Purpose**: Update feature (FR-4)

**Authentication**: Required

**Authorization**: User must own feature

**Request**:
```json
{
  "name": "Updated name",
  "description": "Updated description",
  "status": "inactive"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": { ... }  // Updated feature
}
```

**Errors**:
- `400` Validation error
- `401` Unauthorized
- `403` Forbidden (not owner)
- `404` Not found
- `409` Conflict (duplicate name)

### DELETE /api/feature/:id

**Purpose**: Delete feature (FR-5, soft delete)

**Authentication**: Required

**Authorization**: User must own feature OR be admin

**Response** (204 No Content): Empty body

**Errors**:
- `401` Unauthorized
- `403` Forbidden (not owner)
- `404` Not found

**Implementation**: Soft delete (sets `deletedAt` timestamp)

**Constitutional Reference**: GDPR compliance (Section II.C)

---

## Security Considerations

### Authentication (NFR-2)

**JWT Token Validation**:
- All endpoints require valid JWT in Authorization header
- Token validated by `authenticate` middleware
- Expiry: 1 hour (refresh required)
- Secret: Strong random key from environment variable

**Implementation**:
```javascript
// middleware/auth.middleware.js (existing)
function authenticate(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) throw new UnauthorizedError();

  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  req.user = decoded;  // { id, email, role }
  next();
}
```

### Authorization (NFR-2)

**Ownership Checks**:
- Service layer verifies userId matches req.user.id
- Admin role bypasses ownership check
- 403 Forbidden if unauthorized

**Implementation**:
```javascript
// services/feature.service.js
async function getFeature(requestingUserId, featureId) {
  const feature = await FeatureModel.findById(featureId);
  if (!feature) throw new NotFoundError();

  // Check ownership (unless admin)
  if (feature.userId !== requestingUserId && !isAdmin(requestingUserId)) {
    throw new ForbiddenError('Not authorized to access this feature');
  }

  return feature;
}
```

### Input Validation (NFR-2)

**Validation Strategy**:
1. Route-level: Zod schema validation middleware
2. Service-level: Business rule validation
3. Database-level: Constraints and triggers

**XSS Prevention**:
- React escapes by default
- No `dangerouslySetInnerHTML` used
- Content Security Policy headers

**SQL Injection Prevention**:
- Parameterized queries only
- No string concatenation in SQL
- ORM/query builder with prepared statements

**Rate Limiting** (NFR-2):
- 100 requests per 15 minutes per IP
- Existing `apiLimiter` middleware
- 429 status code when exceeded

**Constitutional Reference**: Section II.C (Security Requirements)

---

## Error Handling Strategy

### Backend Error Flow

```
Error Thrown in Service
    │
    ▼
Caught by asyncHandler
    │
    ▼
Express Error Middleware
    │
    ├─▶ Log error (winston)
    ├─▶ Determine status code
    ├─▶ Format error response
    │
    ▼
Send to Client
```

**Error Response Format**:
```json
{
  "success": false,
  "message": "User-friendly error message",
  "errors": {
    "field": "Specific field error"
  },
  "stack": "..." // Only in development
}
```

**Error Classes** (existing):
- `ValidationError` (400) - Invalid input
- `UnauthorizedError` (401) - Missing/invalid auth
- `ForbiddenError` (403) - Insufficient permissions
- `NotFoundError` (404) - Resource not found
- `ConflictError` (409) - Duplicate resource
- `InternalError` (500) - Server error

### Frontend Error Handling

**React Query Error Handling**:
```javascript
const { data, error, isError } = useFeatures(userId);

if (isError) {
  return (
    <Alert severity="error">
      {error.response?.data?.message || 'Failed to load features'}
    </Alert>
  );
}
```

**Global Error Boundary**:
```javascript
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <FeatureManager />
</ErrorBoundary>
```

**User Feedback** (Snackbar):
```javascript
const { mutate: createFeature } = useCreateFeature();

const handleCreate = (data) => {
  createFeature(data, {
    onSuccess: () => {
      showSnackbar('Feature created successfully', 'success');
    },
    onError: (error) => {
      showSnackbar(error.response?.data?.message || 'Failed to create feature', 'error');
    }
  });
};
```

**Constitutional Reference**: Section II.B (Error Handling)

---

## Performance Optimization

### Database Performance (NFR-1)

**Query Optimization**:
- Indexes on frequently queried columns (user_id, status, created_at)
- EXPLAIN ANALYZE for slow queries
- Pagination prevents full table scans
- Connection pooling (max 20 connections)

**Caching Strategy**:
- React Query client-side cache (5min stale time)
- No server-side cache initially (add Redis if needed)
- ETags for conditional requests

**Measurement**:
- Log query times in development
- Monitor p95 latency in production
- Alert if >200ms

### Frontend Performance (NFR-1)

**React Optimization**:
```javascript
// Memoize expensive components
export const FeatureCard = memo(function FeatureCard({ feature, onEdit, onDelete }) {
  // Only re-render if feature changes
}, (prevProps, nextProps) => prevProps.feature.id === nextProps.feature.id);

// Memoize callbacks
const handleEdit = useCallback((feature) => {
  setSelectedFeature(feature);
  setDialogOpen(true);
}, []);

// Memoize computed values
const activeFeatures = useMemo(() =>
  features.filter(f => f.status === 'active'),
  [features]
);
```

**Code Splitting**:
```javascript
// Lazy load feature management page
const FeaturesPage = lazy(() => import('./pages/FeaturesPage'));

// In router
<Suspense fallback={<LoadingSpinner />}>
  <Route path="/features" element={<FeaturesPage />} />
</Suspense>
```

**Bundle Size**:
- Tree shaking enabled
- MUI icons imported individually
- No unnecessary dependencies

**Measurement**:
- Lighthouse performance score >90
- Time to Interactive <2s
- First Contentful Paint <1s

**Constitutional Reference**: Section II.D (Performance Requirements)

---

## Testing Strategy

### Backend Testing (≥60% coverage)

**Unit Tests** (`src/services/__tests__/feature.service.test.js`):
```javascript
describe('FeatureService.createFeature', () => {
  it('should create feature with valid data', async () => {
    // Given
    const userId = 'user-123';
    const data = { name: 'Test Feature', description: 'Test' };

    // When
    const feature = await createFeature(userId, data);

    // Then
    expect(feature).toMatchObject({
      userId,
      name: 'Test Feature',
      status: 'active'
    });
    expect(feature.id).toBeDefined();
  });

  it('should throw ValidationError for invalid name', async () => {
    // Given
    const userId = 'user-123';
    const data = { name: '', description: 'Test' };

    // When/Then
    await expect(createFeature(userId, data))
      .rejects
      .toThrow(ValidationError);
  });

  it('should enforce max 100 features per user', async () => {
    // Given user already has 100 features
    jest.spyOn(FeatureModel, 'countByUserId').mockResolvedValue(100);

    // When/Then
    await expect(createFeature('user-123', { name: 'Feature' }))
      .rejects
      .toThrow('Maximum features reached');
  });
});
```

**Integration Tests** (`src/routes/__tests__/feature.routes.test.js`):
```javascript
import request from 'supertest';
import app from '../app';

describe('POST /api/feature', () => {
  it('should create feature with valid auth', async () => {
    // Given
    const token = generateTestToken({ id: 'user-123', role: 'user' });

    // When
    const response = await request(app)
      .post('/api/feature')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Test Feature', description: 'Test' })
      .expect(201);

    // Then
    expect(response.body.success).toBe(true);
    expect(response.body.data).toMatchObject({
      name: 'Test Feature',
      status: 'active'
    });
  });

  it('should return 401 without auth token', async () => {
    await request(app)
      .post('/api/feature')
      .send({ name: 'Test' })
      .expect(401);
  });

  it('should return 400 for invalid data', async () => {
    const token = generateTestToken({ id: 'user-123' });

    const response = await request(app)
      .post('/api/feature')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: '' })  // Invalid: empty name
      .expect(400);

    expect(response.body.success).toBe(false);
    expect(response.body.errors).toHaveProperty('name');
  });
});
```

**Database Tests** (`src/models/__tests__/feature.model.test.js`):
- Test CRUD operations
- Test constraints (unique name per user)
- Test soft delete
- Test pagination

### Frontend Testing

**Component Tests** (`src/components/features/__tests__/FeatureCard.test.jsx`):
```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FeatureCard } from '../FeatureCard';

describe('FeatureCard', () => {
  const mockFeature = {
    id: '123',
    name: 'Test Feature',
    description: 'Test description',
    status: 'active'
  };

  it('should render feature details', () => {
    render(<FeatureCard feature={mockFeature} />);

    expect(screen.getByText('Test Feature')).toBeInTheDocument();
    expect(screen.getByText('Test description')).toBeInTheDocument();
    expect(screen.getByText('active')).toBeInTheDocument();
  });

  it('should call onEdit when edit button clicked', async () => {
    const user = userEvent.setup();
    const onEdit = jest.fn();

    render(<FeatureCard feature={mockFeature} onEdit={onEdit} />);

    await user.click(screen.getByLabelText('edit feature'));

    expect(onEdit).toHaveBeenCalledTimes(1);
  });

  it('should be accessible', () => {
    const { container } = render(<FeatureCard feature={mockFeature} />);

    // Check aria-labels present
    expect(screen.getByLabelText('edit feature')).toBeInTheDocument();
    expect(screen.getByLabelText('delete feature')).toBeInTheDocument();
  });
});
```

**Hook Tests** (`src/hooks/__tests__/useFeatures.test.js`):
```javascript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useFeatures } from '../useFeatures';

describe('useFeatures', () => {
  it('should fetch features for user', async () => {
    // Given
    const queryClient = new QueryClient();
    const wrapper = ({ children }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );

    // Mock API
    jest.spyOn(api, 'get').mockResolvedValue({
      data: [{ id: '1', name: 'Feature 1' }]
    });

    // When
    const { result } = renderHook(() => useFeatures('user-123'), { wrapper });

    // Then
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(1);
    expect(result.current.data[0].name).toBe('Feature 1');
  });

  it('should handle API errors', async () => {
    // Given
    const queryClient = new QueryClient();
    const wrapper = ({ children }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );

    // Mock API error
    jest.spyOn(api, 'get').mockRejectedValue(new Error('Network error'));

    // When
    const { result } = renderHook(() => useFeatures('user-123'), { wrapper });

    // Then
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error.message).toBe('Network error');
  });
});
```

**E2E Tests** (if E2E framework exists):
- Create feature flow
- Edit feature flow
- Delete feature flow
- Error handling
- Authentication flow

**Constitutional Reference**: Section II.C (Test Coverage Requirements)

---

## Migration & Deployment Plan

### Database Migration

**Migration File**: `migrations/20260111_create_features_table.sql`

**Up Migration**:
```sql
-- Create features table
CREATE TABLE features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,
  CONSTRAINT features_name_user_unique UNIQUE (user_id, name)
);

-- Create indexes
CREATE INDEX idx_features_user_id ON features(user_id);
CREATE INDEX idx_features_status ON features(status);
CREATE INDEX idx_features_created_at ON features(created_at DESC);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON features TO app_user;
```

**Down Migration**:
```sql
-- Drop indexes
DROP INDEX IF EXISTS idx_features_created_at;
DROP INDEX IF EXISTS idx_features_status;
DROP INDEX IF EXISTS idx_features_user_id;

-- Drop table
DROP TABLE IF EXISTS features;
```

**Testing**:
1. Run up migration in test database
2. Verify schema matches design
3. Test down migration (rollback)
4. Verify clean state after rollback

**Execution Time**: <1 minute (estimated)

### Deployment Strategy

**Blue-Green Deployment** (Constitutional Section IV.B):

1. **Pre-Deploy**:
   - Run database migration in production
   - Verify migration success
   - No downtime expected

2. **Deploy**:
   - Deploy backend to green slot
   - Health check: GET /health
   - Deploy frontend to green slot
   - Health check: Navigate to /features

3. **Switch Traffic**:
   - Update load balancer to green
   - Monitor error rates
   - Keep blue slot running for 1 hour

4. **Post-Deploy**:
   - Smoke tests (create/read/update/delete)
   - Monitor logs for errors
   - Monitor performance metrics
   - Decommission blue slot if stable

**Rollback Procedure**:
1. Switch load balancer back to blue
2. Verify application working
3. Run down migration if needed
4. Investigate failure, fix, redeploy

**Constitutional Reference**: Section IV.B (Deployment Process)

---

## Open Questions for Tasks Phase

1. Should we implement real-time updates (WebSocket) or is polling acceptable?
2. Do we need feature versioning (track changes over time)?
3. Should features support tagging/categorization?
4. Do we need export functionality (CSV, JSON)?
5. Should we implement feature templates?

*(These will be addressed in Tasks phase if needed)*

---

## References

**Internal**:
- Specification: `.claude/specs/001-feature-name/spec.md`
- Clarifications: `.claude/specs/001-feature-name/clarifications.md`
- Constitution: `.claude/PROJECT_CONSTITUTION.md`
- Guidelines: `.claude/CLAUDE.md`
- Express Patterns: `.claude/rules/express.md`
- React Patterns: `.claude/rules/react.md`
- MUI Guidelines: `.claude/rules/mui.md`
- Security: `.claude/rules/security.md`
- Testing: `.claude/rules/testing.md`

**External**:
- JWT Best Practices: https://tools.ietf.org/html/rfc8725
- React Query Docs: https://tanstack.com/query/latest
- MUI Documentation: https://mui.com/
- PostgreSQL Documentation: https://www.postgresql.org/docs/

---

**Plan Approval**: This plan requires explicit user approval before proceeding to Tasks phase.
```

### Process

1. **Research Existing Code**: Use Grep, Glob, Read to understand patterns
2. **Draft Technical Plan**: Create comprehensive design document
3. **Map Requirements**: Link all FR-X and NFR-X to components
4. **Verify Constitutional Alignment**: Ensure all decisions follow constitution
5. **Iterate on Feedback**: Refine design based on user input
6. **Obtain Explicit Approval**: User must approve before Tasks phase

**Critical**: Design must be technically sound and constitutionally aligned. Get explicit approval before proceeding.

---

## Phase 4: Tasks - Implementation Breakdown

### Objective
Convert approved plan into dependency-ordered, actionable implementation tasks with clear acceptance criteria.

### Output
Create `.claude/specs/NNN-feature-name/tasks.md`

### Task Structure

**Two-Level Hierarchy**:
- Tasks (1, 2, 3, ...) - Major implementation areas
- Sub-tasks (1.1, 1.2, 2.1, ...) - Specific actionable steps

**Maximum Depth**: Two levels only

**Parallel Tasks**: Mark with `[P]` if can be done concurrently

### Task Requirements

Each task must:
1. **Reference Requirements**: Map to specific FR-X or NFR-X
2. **Reference Plan**: Link to design components
3. **List Dependencies**: What must be done first
4. **Be Self-Contained**: Completable independently (after dependencies)
5. **Have Clear Acceptance**: Testable "done" criteria
6. **Estimate Complexity**: High/Medium/Low (1-4 hours per task)

### Tasks Template

```markdown
# Implementation Tasks: [Feature Name]

**Feature Number**: [001]
**Created**: 2026-01-11
**Status**: Ready for Implementation

**References**:
- Specification: `.claude/specs/001-feature-name/spec.md`
- Clarifications: `.claude/specs/001-feature-name/clarifications.md`
- Plan: `.claude/specs/001-feature-name/plan.md`
- Constitution: `.claude/PROJECT_CONSTITUTION.md`

**Constitutional Compliance**:
All tasks follow Section II.B (Architecture), II.C (Code Quality), II.D (Performance)

---

## Task Dependency Graph

```
1 (Database)
    │
    ├──▶ 2 (Backend)
    │       │
    │       ├──▶ 3 (API Tests)
    │       │
    │       └──▶ 4 (Frontend) [P]
    │               │
    │               └──▶ 5 (Integration)
    │
    └──▶ 6 (Documentation) [P]
```

**Legend**: [P] = Can run in parallel with sibling tasks

---

## Task 1: Database Schema and Migration

**Requirement Mapping**: All FR requirements (foundation)
**Plan Reference**: Section "Data Model" and "Migration Plan"
**Dependencies**: None (first task)
**Estimated Complexity**: Medium
**Parallel**: No

### 1.1 Create database migration file

**Action**:
- Create `migrations/20260111_create_features_table.sql`
- Define features table schema per plan
- Add indexes for `user_id`, `status`, `created_at`
- Include up and down migration scripts

**Acceptance Criteria**:
- [ ] Migration file created with correct naming
- [ ] Schema matches plan exactly (all columns, types, constraints)
- [ ] Three indexes defined as specified
- [ ] Down migration reverses up migration completely
- [ ] Migration documented with comments

**Constitutional Reference**: Section II.B (Data patterns), I.C (Deployment)

---

### 1.2 Test migration in development

**Action**:
- Run up migration: `npm run migrate:up`
- Verify table created: `\d features` in psql
- Verify indexes: `\di features*`
- Run down migration: `npm run migrate:down`
- Verify clean rollback

**Acceptance Criteria**:
- [ ] Up migration completes without errors
- [ ] Table structure matches specification
- [ ] All indexes present
- [ ] Down migration removes everything
- [ ] Can run up/down multiple times

---

### 1.3 Create database model

**Action**:
- Create `src/models/feature.model.js`
- Implement CRUD methods: `create`, `findById`, `findByUserId`, `update`, `softDelete`
- Use parameterized queries (SQL injection prevention)
- Add JSDoc comments to all functions
- Export model class/object

**Acceptance Criteria**:
- [ ] Model file created in correct location
- [ ] All 5 CRUD methods implemented
- [ ] Parameterized queries used (no string concatenation)
- [ ] JSDoc comments on all methods (@param, @returns, @throws)
- [ ] Error handling for database errors

**Constitutional Reference**: Section II.C (Security - SQL injection), II.C (JSDoc required)

---

### 1.4 Write model unit tests

**Action**:
- Create `src/models/__tests__/feature.model.test.js`
- Test all CRUD operations with test database
- Test error scenarios (not found, constraint violations)
- Test pagination in `findByUserId`
- Achieve ≥60% coverage for model file

**Acceptance Criteria**:
- [ ] Test file created with proper structure
- [ ] All CRUD methods tested (happy path)
- [ ] Error cases covered (not found, duplicate, invalid data)
- [ ] Pagination tested (page, limit, total)
- [ ] Coverage ≥60% for feature.model.js
- [ ] All tests passing

**Constitutional Reference**: Section II.C (Test coverage ≥60%)

---

## Task 2: Backend Service Layer

**Requirement Mapping**: FR-1 through FR-5, NFR-2 (Security)
**Plan Reference**: Section "Service Layer"
**Dependencies**: Task 1 (needs database model)
**Estimated Complexity**: High
**Parallel**: No

### 2.1 Create validation schema

**Action**:
- Create `src/validation/feature.schema.js`
- Define Zod schema for feature creation
- Define Zod schema for feature update
- Validate name (1-255 chars, required)
- Validate description (optional, max 2000 chars)
- Validate metadata (object, optional)
- Export schemas

**Acceptance Criteria**:
- [ ] Schema file created
- [ ] `createFeatureSchema` defined (FR-1 requirements)
- [ ] `updateFeatureSchema` defined (FR-4 requirements)
- [ ] All validation rules match requirements
- [ ] Schema documented with JSDoc

**Constitutional Reference**: Section II.C (Security - input validation)

---

### 2.2 Implement service functions [P]

**Action**:
- Create `src/services/feature.service.js`
- Implement `createFeature(userId, data)` (FR-1)
  - Validate with Zod
  - Check business rules (max 100 per user)
  - Call model.create()
  - Return feature
- Implement `listFeatures(userId, options)` (FR-2)
  - Support pagination
  - Support filtering by status
  - Call model.findByUserId()
- Implement `getFeature(userId, featureId)` (FR-3)
  - Verify ownership
  - Call model.findById()
- Implement `updateFeature(userId, featureId, data)` (FR-4)
  - Validate with Zod
  - Verify ownership
  - Call model.update()
- Implement `deleteFeature(userId, featureId)` (FR-5)
  - Verify ownership
  - Call model.softDelete()
- Add JSDoc to all functions

**Acceptance Criteria**:
- [ ] Service file created
- [ ] All 5 functions implemented
- [ ] Zod validation integrated
- [ ] Business rules enforced (max 100 features)
- [ ] Authorization checks (ownership) in get/update/delete
- [ ] JSDoc comments complete (@param, @returns, @throws)
- [ ] Uses error classes (ValidationError, NotFoundError, ForbiddenError)

**Constitutional Reference**: Section II.B (Service patterns), II.C (JSDoc, authorization)

---

### 2.3 Write service unit tests [P]

**Action**:
- Create `src/services/__tests__/feature.service.test.js`
- Test each function's happy path
- Test validation failures (invalid input)
- Test authorization failures (not owner)
- Test business rule violations (max 100)
- Mock database calls
- Achieve ≥60% coverage

**Acceptance Criteria**:
- [ ] Test file created
- [ ] All functions tested (happy path + errors)
- [ ] Validation errors tested
- [ ] Authorization errors tested
- [ ] Business rules tested
- [ ] Database methods mocked
- [ ] Coverage ≥60% for feature.service.js
- [ ] All tests passing

**Parallel Note**: Can work on 2.2 and 2.3 simultaneously with TDD approach

---

## Task 3: API Routes and Controllers

**Requirement Mapping**: FR-1 through FR-5, NFR-1 (Performance), NFR-2 (Security)
**Plan Reference**: Section "Routes" and "Controllers"
**Dependencies**: Task 2 (needs service layer)
**Estimated Complexity**: Medium
**Parallel**: No

### 3.1 Implement controllers

**Action**:
- Create `src/controllers/feature.controller.js`
- Implement `createFeature(req, res)` controller
  - Extract data from req.body
  - Call service.createFeature()
  - Return 201 with created feature
- Implement `listFeatures(req, res)` controller
  - Extract pagination params from req.query
  - Call service.listFeatures()
  - Return 200 with features and pagination
- Implement `getFeature(req, res)` controller
  - Extract id from req.params
  - Call service.getFeature()
  - Return 200 with feature
- Implement `updateFeature(req, res)` controller
  - Extract id and data
  - Call service.updateFeature()
  - Return 200 with updated feature
- Implement `deleteFeature(req, res)` controller
  - Extract id
  - Call service.deleteFeature()
  - Return 204 (no content)
- Use asyncHandler wrapper for all
- Add JSDoc to all functions

**Acceptance Criteria**:
- [ ] Controller file created
- [ ] All 5 controllers implemented
- [ ] Correct HTTP status codes (201, 200, 204)
- [ ] Response format matches constitutional standard
- [ ] asyncHandler used for error handling
- [ ] JSDoc comments complete
- [ ] req.user.id passed to service functions

**Constitutional Reference**: Section III.C (API response format)

---

### 3.2 Define API routes

**Action**:
- Create `src/routes/feature.routes.js`
- Define POST /api/feature route
  - Middleware: authenticate, authorize, validateFeatureCreate
  - Controller: createFeature
- Define GET /api/feature route
  - Middleware: authenticate
  - Controller: listFeatures
- Define GET /api/feature/:id route
  - Middleware: authenticate
  - Controller: getFeature
- Define PUT /api/feature/:id route
  - Middleware: authenticate, validateFeatureUpdate
  - Controller: updateFeature
- Define DELETE /api/feature/:id route
  - Middleware: authenticate, authorize
  - Controller: deleteFeature
- Use existing rate limiter middleware
- Export router

**Acceptance Criteria**:
- [ ] Routes file created
- [ ] All 5 endpoints defined
- [ ] Correct HTTP methods
- [ ] Middleware chain correct (auth → validation → controller)
- [ ] asyncHandler wrapper used
- [ ] Rate limiter applied

---

### 3.3 Mount routes in app

**Action**:
- Edit `src/app.js`
- Import feature routes
- Mount at `/api/feature`
- Verify middleware order (should be after auth middleware setup)

**Acceptance Criteria**:
- [ ] Feature routes imported
- [ ] Routes mounted at correct path
- [ ] Positioned correctly in middleware chain
- [ ] App still starts without errors

---

### 3.4 Write integration tests

**Action**:
- Create `src/routes/__tests__/feature.routes.test.js`
- Test all endpoints with supertest
- Test authentication requirement (401 without token)
- Test authorization (403 for not-owner)
- Test validation errors (400 for invalid data)
- Test success responses
- Test pagination
- Test rate limiting (429)

**Acceptance Criteria**:
- [ ] Integration test file created
- [ ] All 5 endpoints tested
- [ ] Authentication tested (401 cases)
- [ ] Authorization tested (403 cases)
- [ ] Validation tested (400 cases)
- [ ] Success cases tested (201, 200, 204)
- [ ] Pagination tested
- [ ] All tests passing

**Constitutional Reference**: Section II.C (Test coverage)

---

## Task 4: Frontend Components [P]

**Requirement Mapping**: FR-1 through FR-5, NFR-4 (Accessibility)
**Plan Reference**: Section "Frontend Components"
**Dependencies**: Task 3 (needs API endpoints) for integration, but can build UI in parallel
**Estimated Complexity**: High
**Parallel**: Yes (with Task 3.4)

### 4.1 Create useFeatures hook [P]

**Action**:
- Create `src/hooks/useFeatures.js`
- Implement `useFeatures(userId)` with React Query
- Implement `useCreateFeature()` mutation
- Implement `useUpdateFeature()` mutation
- Implement `useDeleteFeature()` mutation
- Configure 5-minute stale time
- Add optimistic updates for mutations
- Add JSDoc comments

**Acceptance Criteria**:
- [ ] Hook file created
- [ ] Query hook implemented with React Query
- [ ] All 3 mutation hooks implemented
- [ ] Stale time configured (5min)
- [ ] Cache invalidation on mutations
- [ ] JSDoc comments added
- [ ] TypeScript types or PropTypes defined

**Constitutional Reference**: Section II.A (React Query), Section II.C (JSDoc)

**Parallel Note**: Can implement while API is being built (mock API calls in tests)

---

### 4.2 Create FeatureCard component [P]

**Action**:
- Create `src/components/features/FeatureCard.jsx`
- Accept props: feature, onEdit, onDelete
- Display: name, description, status (Chip)
- Add Edit and Delete IconButtons
- Use MUI Card, Typography, CardContent, CardActions
- Responsive design with sx prop
- Add aria-labels for accessibility
- Add PropTypes or TypeScript types

**Acceptance Criteria**:
- [ ] Component file created
- [ ] Props properly typed
- [ ] MUI components used (Card, Typography, IconButton, Chip)
- [ ] Theme values used (no hardcoded colors)
- [ ] Responsive design (sx prop)
- [ ] Accessibility labels present (aria-label)
- [ ] Keyboard navigation works
- [ ] PropTypes/TypeScript defined

**Constitutional Reference**: Section II.A (MUI patterns), Section I.B (Accessibility), NFR-4

---

### 4.3 Create FeatureForm component [P]

**Action**:
- Create `src/components/features/FeatureForm.jsx`
- Accept props: feature (optional, for editing), onSubmit, onCancel
- Use react-hook-form for form management
- Add Zod validation (matches backend schema)
- TextField for name (required, max 255)
- TextField for description (optional, multiline, max 2000)
- Submit and Cancel buttons
- Show validation errors
- Handle loading state during submission
- Add PropTypes/TypeScript

**Acceptance Criteria**:
- [ ] Form component created
- [ ] react-hook-form integrated
- [ ] Zod schema defined (matches backend)
- [ ] Name field: required, max 255, error display
- [ ] Description field: optional, multiline, max 2000
- [ ] Buttons: Submit (with loading state), Cancel
- [ ] Validation errors displayed
- [ ] onSubmit called with validated data
- [ ] PropTypes/TypeScript defined

**Constitutional Reference**: Section II.A (Form handling)

---

### 4.4 Create FeatureList component [P]

**Action**:
- Create `src/components/features/FeatureList.jsx`
- Accept props: features, onEdit, onDelete, loading, error
- Display loading state (CircularProgress)
- Display error state (Alert)
- Display empty state (helpful message + create button)
- Map features to FeatureCard components
- Use MUI Grid for responsive layout
- Add "Create New Feature" button

**Acceptance Criteria**:
- [ ] List component created
- [ ] Loading state handled (CircularProgress)
- [ ] Error state handled (Alert with error message)
- [ ] Empty state handled (message + button)
- [ ] Features mapped to FeatureCard
- [ ] MUI Grid used (responsive: xs=12, sm=6, md=4)
- [ ] Create button present
- [ ] PropTypes/TypeScript defined

---

### 4.5 Create FeatureManager container [P]

**Action**:
- Create `src/components/features/FeatureManager.jsx`
- Use useFeatures hook to fetch data
- Use mutation hooks for create/update/delete
- Manage dialog state (open/close, selected feature)
- Handle create/edit/delete actions
- Show success/error Snackbar notifications
- Integrate FeatureList and FeatureForm (in Dialog)
- Add error boundary

**Acceptance Criteria**:
- [ ] Manager component created
- [ ] useFeatures hook integrated
- [ ] Mutation hooks integrated
- [ ] Dialog state managed (create vs edit)
- [ ] Snackbar notifications (success/error)
- [ ] FeatureList rendered with data
- [ ] FeatureForm in Dialog (MUI Dialog component)
- [ ] Error boundary wraps content
- [ ] PropTypes/TypeScript defined

**Constitutional Reference**: Section II.B (Component hierarchy)

---

### 4.6 Write component tests [P]

**Action**:
- Create `src/components/features/__tests__/FeatureCard.test.jsx`
- Create `src/components/features/__tests__/FeatureForm.test.jsx`
- Create `src/components/features/__tests__/FeatureList.test.jsx`
- Create `src/components/features/__tests__/FeatureManager.test.jsx`
- Test rendering with different props
- Test user interactions (click, type, submit)
- Mock API calls with MSW
- Query by accessibility roles
- Achieve ≥60% coverage

**Acceptance Criteria**:
- [ ] All 4 component test files created
- [ ] Rendering tested (various props/states)
- [ ] User interactions tested (userEvent)
- [ ] API calls mocked (MSW or jest.mock)
- [ ] Queries use accessibility roles/labels
- [ ] Loading/error/empty states tested
- [ ] Coverage ≥60% for all components
- [ ] All tests passing

**Constitutional Reference**: Section II.C (Test coverage), Section II.A (Query by role)

---

## Task 5: Integration and Polish [P]

**Requirement Mapping**: NFR-1 (Performance), NFR-3 (Scalability), NFR-4 (Accessibility)
**Plan Reference**: Various sections (Performance, Security, Accessibility)
**Dependencies**: Tasks 1-4 (needs everything implemented)
**Estimated Complexity**: Medium
**Parallel**: Yes (with final testing)

### 5.1 Performance optimization

**Action**:
- Add React.memo to FeatureCard
- Implement useMemo for filtered/sorted lists
- Implement useCallback for event handlers
- Verify database queries use indexes
- Check bundle size impact (<50KB added)
- Run Lighthouse audit (score >90)

**Acceptance Criteria**:
- [ ] FeatureCard memoized
- [ ] Expensive computations memoized
- [ ] Callbacks memoized where appropriate
- [ ] Database EXPLAIN ANALYZE shows index usage
- [ ] Bundle size increase <50KB
- [ ] Lighthouse performance score >90
- [ ] No unnecessary re-renders

**Constitutional Reference**: Section II.D (Performance), Section III.A (Bundle size)

---

### 5.2 Accessibility audit [P]

**Action**:
- Run axe DevTools on feature pages
- Verify keyboard navigation works
- Verify screen reader compatibility (test with NVDA/JAWS)
- Ensure color contrast meets WCAG 2.1 AA
- Add aria-labels where missing
- Test focus management (Dialog, forms)

**Acceptance Criteria**:
- [ ] axe DevTools reports 0 violations
- [ ] All interactive elements keyboard-accessible
- [ ] Tab order logical
- [ ] Screen reader announces content correctly
- [ ] Color contrast ≥4.5:1 for normal text
- [ ] Focus visible on all interactive elements
- [ ] Dialog traps focus appropriately

**Constitutional Reference**: Section I.B (Accessibility for All), NFR-4

---

### 5.3 Security review [P]

**Action**:
- Verify all inputs validated (backend + frontend)
- Verify authorization checks in place
- Verify no secrets in frontend code
- Run `npm audit` and fix vulnerabilities
- Verify rate limiting works (test with curl)
- Check CSP headers configured
- Review error messages (no sensitive data leaked)

**Acceptance Criteria**:
- [ ] Input validation verified on all endpoints
- [ ] Authorization verified (ownership checks)
- [ ] No hardcoded secrets found
- [ ] `npm audit` shows 0 high/critical vulnerabilities
- [ ] Rate limiting tested (429 after limit)
- [ ] CSP headers present
- [ ] Error messages user-friendly (no stack traces in prod)

**Constitutional Reference**: Section II.C (Security)

---

### 5.4 Error handling and user feedback

**Action**:
- Implement global Snackbar for notifications
- Add Error Boundary for React errors
- Improve error messages (user-friendly)
- Add loading indicators for all async operations
- Test error scenarios (network failure, validation, etc.)

**Acceptance Criteria**:
- [ ] Snackbar implemented (success/error/info)
- [ ] Error Boundary added to app root
- [ ] All error messages user-friendly
- [ ] Loading indicators on all async actions
- [ ] Network errors handled gracefully
- [ ] Validation errors displayed clearly

---

### 5.5 Documentation updates [P]

**Action**:
- Update API documentation with new endpoints
- Verify JSDoc complete on all functions
- Update README if user-facing changes
- Update CHANGELOG.md with feature details
- Add inline comments for complex logic

**Acceptance Criteria**:
- [ ] API docs updated (endpoints, request/response formats)
- [ ] JSDoc verified on all functions
- [ ] README updated (if needed)
- [ ] CHANGELOG.md entry added
- [ ] Complex logic commented

**Constitutional Reference**: Section II.C (Documentation)

---

## Task 6: Testing and Deployment Preparation

**Requirement Mapping**: All requirements (final verification)
**Plan Reference**: Testing Strategy, Migration & Deployment
**Dependencies**: Tasks 1-5 (needs complete implementation)
**Estimated Complexity**: Medium
**Parallel**: No (final verification)

### 6.1 Run full test suite

**Action**:
- Run `npm test -- --coverage`
- Verify ≥60% overall coverage
- Verify ≥20% per file coverage
- Fix any failing tests
- Verify no flaky tests (run 3 times)

**Acceptance Criteria**:
- [ ] All tests passing
- [ ] Coverage ≥60% overall
- [ ] Coverage ≥20% per file (all files)
- [ ] No test failures
- [ ] Tests stable (passed 3 consecutive runs)

**Constitutional Reference**: Section II.C (Coverage requirements)

---

### 6.2 Code quality checks

**Action**:
- Run `npm run lint` and fix all issues
- Run `npm run format` to format code
- Run `npm run type-check` (if TypeScript)
- Review code for constitutional compliance
- Run `npm run build` and verify success

**Acceptance Criteria**:
- [ ] ESLint passing (0 errors, 0 warnings)
- [ ] Code formatted (Prettier)
- [ ] Type check passing (if TS)
- [ ] Code follows constitutional patterns
- [ ] Build succeeds without errors

**Constitutional Reference**: Section II.C (Code quality)

---

### 6.3 Manual testing

**Action**:
- Test create feature flow (happy path)
- Test edit feature flow (happy path)
- Test delete feature flow (happy path)
- Test validation errors (empty name, too long, etc.)
- Test authorization (try accessing other user's features)
- Test pagination (create 30+ features, verify pages)
- Test on different browsers (Chrome, Firefox, Safari)
- Test responsive design (mobile, tablet, desktop)

**Acceptance Criteria**:
- [ ] Create flow works end-to-end
- [ ] Edit flow works end-to-end
- [ ] Delete flow works end-to-end
- [ ] Validation errors displayed correctly
- [ ] Authorization prevents unauthorized access
- [ ] Pagination works correctly
- [ ] Cross-browser compatible
- [ ] Responsive on all screen sizes

---

### 6.4 Database migration testing

**Action**:
- Test migration in staging database
- Verify migration completes in <10 minutes
- Test rollback (down migration)
- Verify data integrity after migration
- Document migration steps

**Acceptance Criteria**:
- [ ] Migration tested in staging
- [ ] Migration time <10 minutes
- [ ] Rollback tested successfully
- [ ] No data loss or corruption
- [ ] Migration steps documented

**Constitutional Reference**: Section I.C (Migration <10min)

---

### 6.5 Prepare deployment

**Action**:
- Create deployment checklist
- Document environment variables (if any)
- Prepare rollback procedure
- Create smoke test script
- Schedule deployment window

**Acceptance Criteria**:
- [ ] Deployment checklist created
- [ ] Environment variables documented
- [ ] Rollback procedure documented
- [ ] Smoke tests scripted
- [ ] Deployment scheduled with team

**Constitutional Reference**: Section IV.B (Deployment process)

---

## Completion Criteria

Feature is ready for deployment when:

- ✅ All tasks completed (checkboxes checked)
- ✅ All tests passing with ≥60% coverage
- ✅ ESLint passing with 0 errors
- ✅ Code review approved
- ✅ Constitutional compliance verified
- ✅ Documentation complete
- ✅ Migration tested in staging
- ✅ Rollback procedure documented
- ✅ User approval obtained

**Constitutional References**:
- Section II.B: Architecture patterns followed
- Section II.C: Code quality standards met
- Section II.D: Performance targets achieved
- Section IV.B: Deployment process followed

---

## Notes

- Each task should take 1-4 hours
- Tasks marked [P] can be done in parallel
- Stop after each task for user review
- Update this document if scope changes
- All decisions align with constitution

**Task Execution**: Proceed to Phase 6 (Implement) with user approval.
```

### Process

1. **Break Down Plan**: Convert design into specific coding tasks
2. **Map Requirements**: Link each task to FR-X, NFR-X, and plan sections
3. **Identify Dependencies**: Determine task order
4. **Mark Parallel Tasks**: Identify concurrent work with [P]
5. **Verify Constitutional Alignment**: Ensure all tasks follow constitution
6. **Iterate on Feedback**: Refine task breakdown
7. **Obtain Explicit Approval**: User must approve before Analyze phase

**Critical**: Tasks must be actionable, testable, and properly sequenced. Get explicit approval before proceeding.

---

## Phase 5: Analyze - Cross-Artifact Validation

### Objective
Perform read-only validation of cross-artifact consistency before implementation begins. Catch inconsistencies, gaps, and conflicts early.

### Output
Create `.claude/specs/NNN-feature-name/analysis.md`

### Validation Checks

1. **Requirement Coverage**: Every FR-X and NFR-X maps to tasks
2. **Task Coverage**: Every task references requirements
3. **Dependency Integrity**: No circular dependencies, valid sequences
4. **Constitutional Compliance**: All decisions align with constitution
5. **Plan-Task Alignment**: Tasks implement plan components
6. **Specification Completeness**: No ambiguities remain
7. **Test Coverage**: Test tasks exist for all implemented tasks

### Analysis Template

```markdown
# Cross-Artifact Analysis: [Feature Name]

**Feature Number**: [001]
**Analysis Date**: 2026-01-11
**Status**: ✓ Passed | ⚠ Warnings | ❌ Failed

**Artifacts Analyzed**:
- Specification: `.claude/specs/001-feature-name/spec.md`
- Clarifications: `.claude/specs/001-feature-name/clarifications.md`
- Plan: `.claude/specs/001-feature-name/plan.md`
- Tasks: `.claude/specs/001-feature-name/tasks.md`
- Constitution: `.claude/PROJECT_CONSTITUTION.md`

---

## 1. Requirement Coverage Analysis

### Functional Requirements

| Requirement | Mapped to Tasks | Status |
|-------------|-----------------|--------|
| FR-1: Create feature | Task 2.2, 3.1, 4.3 | ✓ |
| FR-2: List features | Task 2.2, 3.1, 4.1, 4.4 | ✓ |
| FR-3: Retrieve feature | Task 2.2, 3.1 | ✓ |
| FR-4: Update feature | Task 2.2, 3.1, 4.3 | ✓ |
| FR-5: Delete feature | Task 2.2, 3.1 | ✓ |

**Result**: ✓ All functional requirements covered

### Non-Functional Requirements

| Requirement | Mapped to Tasks | Status |
|-------------|-----------------|--------|
| NFR-1: Performance <200ms | Task 5.1, 6.3 | ✓ |
| NFR-2: Security validation | Task 2.1, 3.4, 5.3 | ✓ |
| NFR-3: Scalability 10K users | Task 1.1 (indexes), 5.1 | ✓ |
| NFR-4: Accessibility WCAG 2.1 | Task 4.2, 5.2 | ✓ |
| NFR-5: Test coverage ≥60% | Task 1.4, 2.3, 3.4, 4.6, 6.1 | ✓ |

**Result**: ✓ All non-functional requirements covered

---

## 2. Task Coverage Analysis

### Tasks Without Requirement Mapping

**None found** - All tasks reference specific requirements

### Requirements Without Task Mapping

**None found** - All requirements have implementing tasks

**Result**: ✓ Complete bidirectional traceability

---

## 3. Dependency Analysis

### Dependency Graph Validation

```
1 (Database) → 2 (Backend) → 3 (API Tests)
                            → 4 (Frontend) [P]
                            → 5 (Integration)
             → 6 (Documentation) [P]
```

**Circular Dependencies**: None found ✓

**Invalid Dependencies**: None found ✓

**Parallel Task Conflicts**: None found ✓

**Critical Path**: 1 → 2 → 3 → 5 (4 and 6 can run in parallel)

**Estimated Timeline**:
- Sequential: ~32 hours
- With parallelization: ~26 hours
- Per developer at 4h/day: 6.5 days

**Result**: ✓ Dependency graph is valid and optimized

---

## 4. Constitutional Compliance Analysis

### Architecture Compliance

**Backend Pattern** (Section II.B):
- ✓ Routes → Controllers → Services → Data Access (Tasks 1-3)
- ✓ Middleware chain correct (Task 3.2)
- ✓ Error handling centralized (Tasks 2.2, 3.1)

**Frontend Pattern** (Section II.B):
- ✓ Pages → Layouts → Features → UI Components (Task 4)
- ✓ React Query for server state (Task 4.1)
- ✓ MUI component usage (Tasks 4.2-4.5)

**Result**: ✓ Architecture patterns followed

### Code Quality Compliance

**JSDoc** (Section II.C):
- ✓ Required for all functions (Tasks 1.3, 2.2, 3.1, 4.1)

**Test Coverage** (Section II.C):
- ✓ ≥60% overall (Task 6.1)
- ✓ ≥20% per file (Tasks 1.4, 2.3, 3.4, 4.6)

**ESLint** (Section II.C):
- ✓ Checked in Task 6.2

**Result**: ✓ Code quality standards planned

### Security Compliance

**Input Validation** (Section II.C):
- ✓ Zod schemas (Task 2.1)
- ✓ Route-level validation (Task 3.2)
- ✓ SQL injection prevention (Task 1.3 - parameterized queries)

**Authentication** (Section II.C):
- ✓ JWT middleware (Task 3.2)
- ✓ All protected routes use authenticate

**Authorization** (Section II.C):
- ✓ Ownership checks (Task 2.2)
- ✓ Service-layer enforcement

**Rate Limiting** (Section II.C):
- ✓ Applied to API routes (Task 3.2)

**Result**: ✓ Security requirements satisfied

### Performance Compliance

**API Response Time** (Section II.D):
- ✓ <200ms target (Task 5.1)
- ✓ Database indexes (Task 1.1)
- ✓ Caching strategy (Task 4.1 - React Query)

**Page Load Time** (Section II.D):
- ✓ <2s target (Task 5.1)
- ✓ Component memoization (Task 5.1)
- ✓ Bundle size check (Task 5.1)

**Result**: ✓ Performance targets addressed

### Deployment Compliance

**Migration** (Section I.C):
- ✓ <10 minute target (Task 6.4)
- ✓ Rollback procedure (Task 6.4)

**Blue-Green Deployment** (Section IV.B):
- ✓ Deployment strategy documented (Task 6.5)
- ✓ Rollback procedure included

**Result**: ✓ Deployment requirements met

---

## 5. Plan-Task Alignment

### Plan Components vs Tasks

| Plan Component | Implementing Tasks | Status |
|----------------|-------------------|--------|
| Database Schema | Task 1.1, 1.2, 1.3 | ✓ |
| Validation Schema | Task 2.1 | ✓ |
| Service Layer | Task 2.2 | ✓ |
| Controllers | Task 3.1 | ✓ |
| Routes | Task 3.2, 3.3 | ✓ |
| React Hooks | Task 4.1 | ✓ |
| UI Components | Tasks 4.2-4.5 | ✓ |
| Testing | Tasks 1.4, 2.3, 3.4, 4.6, 6.1 | ✓ |
| Performance | Task 5.1 | ✓ |
| Security | Tasks 2.1, 5.3 | ✓ |
| Accessibility | Tasks 4.2, 5.2 | ✓ |
| Documentation | Task 5.5 | ✓ |
| Deployment | Tasks 6.4, 6.5 | ✓ |

**Result**: ✓ All plan components have implementing tasks

---

## 6. Specification Completeness

### Open Questions Status

From spec.md:
1. Real-time updates? → Clarified: Not in v1
2. Feature versioning? → Clarified: Future enhancement
3. Tagging/categorization? → Clarified: Not in v1
4. Export functionality? → Clarified: Future enhancement
5. Feature templates? → Clarified: Not in v1

**Result**: ✓ All ambiguities resolved

### Missing Details

**None found** - Specification is complete

---

## 7. Test Coverage Analysis

### Test Tasks vs Implementation Tasks

| Implementation Task | Test Task | Coverage |
|-------------------|-----------|----------|
| 1.3: Database model | 1.4: Model tests | ✓ |
| 2.2: Service layer | 2.3: Service tests | ✓ |
| 3.1-3.3: API | 3.4: Integration tests | ✓ |
| 4.1-4.5: Frontend | 4.6: Component tests | ✓ |
| All tasks | 6.1: Full test suite | ✓ |

**Test-to-Code Ratio**: ~30% of tasks are testing (industry standard: 25-40%)

**Result**: ✓ Adequate test coverage planned

---

## 8. Risk Analysis

### High-Risk Areas

1. **Database Migration**
   - Risk: Migration takes >10 minutes
   - Mitigation: Task 6.4 tests in staging first
   - Status: ✓ Mitigated

2. **Performance NFR-1**
   - Risk: API response time >200ms
   - Mitigation: Task 1.1 indexes, Task 5.1 optimization
   - Status: ✓ Mitigated

3. **Test Coverage NFR-5**
   - Risk: Coverage falls below 60%
   - Mitigation: Multiple test tasks (1.4, 2.3, 3.4, 4.6, 6.1)
   - Status: ✓ Mitigated

4. **Security**
   - Risk: SQL injection, XSS, missing auth
   - Mitigation: Tasks 1.3, 2.1, 3.2, 5.3
   - Status: ✓ Mitigated

**Result**: ✓ All risks have mitigation strategies

---

## 9. Warnings and Recommendations

### Warnings

**None** - No critical issues found

### Recommendations

1. **Consider adding pagination to clarifications**
   - Not required, but would improve UX for >10 Q&A
   - Severity: Low
   - Action: Optional enhancement for v2

2. **Consider adding feature search/filter**
   - Not in requirements, but common for large lists
   - Severity: Low
   - Action: Log as future enhancement

3. **Monitor bundle size closely**
   - Plan allows <50KB, but MUI can be large
   - Severity: Low
   - Action: Task 5.1 already includes bundle check

---

## 10. Final Validation Summary

| Category | Status | Details |
|----------|--------|---------|
| Requirement Coverage | ✓ Pass | 5/5 FR, 5/5 NFR covered |
| Task Coverage | ✓ Pass | All tasks mapped |
| Dependencies | ✓ Pass | Valid DAG, no cycles |
| Constitution | ✓ Pass | All sections satisfied |
| Plan-Task Alignment | ✓ Pass | All components implemented |
| Specification | ✓ Pass | All ambiguities resolved |
| Test Coverage | ✓ Pass | Adequate test tasks |
| Risk Management | ✓ Pass | All risks mitigated |

---

## Overall Result: ✓ PASSED

**Ready for Implementation**: Yes

**Blocking Issues**: None

**Warnings**: 3 (low severity, optional)

**Recommendation**: Proceed to Phase 6 (Implement) with confidence

---

## Sign-Off

**Analyst**: Claude Sonnet 4.5
**Date**: 2026-01-11
**Next Phase**: Implementation (Phase 6)

**User Approval Required**: Yes

---

**Constitutional References**:
- Section II.B: Architecture patterns
- Section II.C: Code quality, security, documentation
- Section II.D: Performance requirements
- Section IV.B: Deployment process
- All constitutional requirements satisfied ✓
```

### Process

1. **Check Requirement Coverage**: Every FR-X and NFR-X has tasks
2. **Check Task Coverage**: Every task references requirements
3. **Validate Dependencies**: Ensure DAG (no cycles), correct sequence
4. **Verify Constitutional Compliance**: All decisions align with constitution
5. **Check Plan-Task Alignment**: Tasks implement all plan components
6. **Review Specification**: No remaining ambiguities
7. **Validate Test Coverage**: Test tasks exist for all implementation
8. **Identify Risks**: Flag high-risk areas with mitigations
9. **Generate Report**: Document findings with pass/fail/warning
10. **Obtain Explicit Approval**: User must approve before Implement

**Critical**: This is a read-only phase. Do NOT modify any artifacts. Only analyze and report. If issues found, return to appropriate phase to fix.

---

## Phase 6: Implement - Execute Tasks

### Objective
Execute approved tasks incrementally with precision, discipline, and continuous user feedback.

### Execution Protocol

**Before Starting ANY Task**:
1. Read ALL spec documents:
   - `.claude/PROJECT_CONSTITUTION.md`
   - `.claude/specs/NNN-feature-name/spec.md`
   - `.claude/specs/NNN-feature-name/clarifications.md`
   - `.claude/specs/NNN-feature-name/plan.md`
   - `.claude/specs/NNN-feature-name/tasks.md`
   - `.claude/specs/NNN-feature-name/analysis.md`
2. Understand full context and relationships
3. Identify current task to execute
4. Verify dependencies satisfied

**Task Execution Steps**:
1. **Read Spec Documents**: Load full context (all 6 files)
2. **Identify Task**: Confirm which task/sub-task to execute
3. **Execute Task**: Write code, tests, documentation
4. **Verify Completion**: Check ALL acceptance criteria
5. **Test Locally**: Run relevant tests, lint, build
6. **Stop and Review**: Wait for user approval
7. **Update Tasks.md**: Mark task completed (- [x])
8. **Repeat**: Move to next task ONLY after approval

**Single Task Focus**:
- Execute ONE task (or sub-task) at a time
- Complete ALL acceptance criteria for that task
- Stop immediately upon completion
- Do NOT auto-advance to next task
- Wait for explicit user approval to continue

**Constitutional Compliance**:
During execution, follow ALL existing guidelines:

1. **Architecture** (Constitution Section II.B, `.claude/CLAUDE.md`)
   - Backend: Routes → Controllers → Services → Data Access
   - Frontend: Pages → Layouts → Features → UI Components

2. **Code Quality** (Constitution Section II.C, `.claude/rules/coding-standards.md`)
   - JSDoc on all functions (@param, @returns, @throws)
   - ESLint passing (0 errors)
   - Test coverage ≥60% overall, ≥20% per file
   - Conventional commits format

3. **Security** (Constitution Section II.C, `.claude/rules/security.md`)
   - Input validation (Zod schemas)
   - Authentication/authorization checks
   - No hardcoded secrets
   - SQL injection prevention (parameterized queries)
   - Rate limiting

4. **Testing** (Constitution Section II.C, `.claude/rules/testing.md`)
   - Unit tests for business logic
   - Integration tests for API endpoints
   - Component tests for React
   - Query by role/label (accessibility)

5. **Performance** (Constitution Section II.D)
   - API response <200ms (p95)
   - Page load <2s (p95)
   - Database indexes on frequently queried columns
   - React memoization where appropriate

6. **Tech Stack** (Constitution Section II.A):
   - Express patterns (`.claude/rules/express.md`)
   - React patterns (`.claude/rules/react.md`)
   - MUI usage (`.claude/rules/mui.md`)
   - Node.js best practices (`.claude/rules/nodejs.md`)

### Verification Before Completion

Before marking ANY task complete:

✓ **All acceptance criteria checked** - Every checkbox in task
✓ **Tests passing** - `npm test` succeeds
✓ **Linting passing** - `npm run lint` succeeds
✓ **Build succeeds** - `npm run build` completes
✓ **Coverage maintained** - Still ≥60% overall, ≥20% per file
✓ **JSDoc complete** - All new functions documented
✓ **Security verified** - No obvious vulnerabilities
✓ **Constitutional compliance** - Follows all standards

If verification fails, FIX issues before marking complete.

### Execution Example

```
User: Execute task 1.1 - Create database migration file