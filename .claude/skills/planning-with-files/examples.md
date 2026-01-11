# Planning with Files - Examples

Detailed examples demonstrating the file-based planning methodology for real-world development tasks.

---

## Example 1: Building a RESTful User Management API

### Scenario
User requests: "Build a complete user management API with authentication"

### Workflow

#### Loop 1: Create Plan

**Action:** Create `task_plan.md`

```markdown
# Task: User Management API

## Goal
Build a complete RESTful API for user management with JWT authentication.

## Phases
- [ ] Design API endpoints and data models
- [ ] Set up Express server and middleware
- [ ] Implement authentication (register, login, logout)
- [ ] Implement user CRUD operations
- [ ] Add input validation and error handling
- [ ] Write tests
- [ ] Create API documentation

## Current Status
Phase: 1 (Design)
Last Action: Plan created

## Tech Stack
- Node.js + Express
- PostgreSQL with Prisma ORM
- JWT for authentication
- Zod for validation

## Next Steps
1. Define API endpoints structure
2. Design database schema
3. Document in notes.md
```

#### Loop 2: Design Phase

**Action:** Design and append to `notes.md`

```markdown
# User Management API - Design Notes

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create new user account
- `POST /api/auth/login` - Login and receive JWT token
- `POST /api/auth/logout` - Logout (invalidate token)
- `POST /api/auth/refresh` - Refresh access token

### User Management
- `GET /api/users` - List all users (admin only)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user (own account or admin)
- `DELETE /api/users/:id` - Delete user (admin only)
- `GET /api/users/me` - Get current user profile

## Database Schema

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String   // bcrypt hashed
  name      String
  role      Role     @default(USER)
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum Role {
  USER
  ADMIN
}
```

## Request/Response Formats

### Register
Request:
```json
{
  "email": "user@example.com",
  "password": "securePass123",
  "name": "John Doe"
}
```

Response:
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "USER"
  },
  "token": "jwt-token-here"
}
```

## Security Considerations
- Password hashing with bcrypt (12 rounds)
- JWT tokens with 1-hour expiration
- Refresh tokens with 7-day expiration
- Rate limiting on auth endpoints (5 attempts per 15 min)
- Input validation with Zod
- SQL injection prevention (parameterized queries)
```

**Update `task_plan.md`:**

```markdown
## Phases
- [x] Design API endpoints and data models ✓
- [ ] Set up Express server and middleware ← Current
- [ ] Implement authentication (register, login, logout)
- [ ] Implement user CRUD operations
- [ ] Add input validation and error handling
- [ ] Write tests
- [ ] Create API documentation

## Current Status
Phase: 2 (Setup)
Last Action: Completed design, stored in notes.md

## Decisions Made
- Using Prisma ORM for type-safe database access
- JWT with refresh token pattern for security
- Zod for runtime validation
- Express async error handling with custom middleware

## Next Steps
1. Initialize Express app with middleware
2. Set up Prisma schema and migrations
3. Create error handling middleware
```

#### Loop 3: Implementation - Authentication

**Read `task_plan.md`** to refresh context, then read `notes.md` for design specs.

**Create files:**

```javascript
// src/middleware/auth.js
import jwt from 'jsonwebtoken';
import { UnauthorizedError } from '../utils/errors.js';

export function authenticate(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    throw new UnauthorizedError('No token provided');
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

// src/routes/auth.routes.js
import express from 'express';
import { register, login, refresh } from '../controllers/auth.controller.js';
import { validateRegister, validateLogin } from '../middleware/validation.js';

const router = express.Router();

router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);
router.post('/refresh', refresh);

export default router;
```

**Update `task_plan.md`:**

```markdown
## Phases
- [x] Design API endpoints and data models ✓
- [x] Set up Express server and middleware ✓
- [x] Implement authentication (register, login, logout) ✓
- [ ] Implement user CRUD operations ← Current
- [ ] Add input validation and error handling
- [ ] Write tests
- [ ] Create API documentation

## Files Created
- src/server.js ✓
- src/middleware/auth.js ✓
- src/middleware/errorHandler.js ✓
- src/routes/auth.routes.js ✓
- src/controllers/auth.controller.js ✓
- src/services/auth.service.js ✓
- prisma/schema.prisma ✓

## Errors Encountered
- **Error 1: Prisma Client not initialized**
  - Context: First migration attempt
  - Cause: Forgot to run `npx prisma generate`
  - Resolution: Added to setup scripts
  - Status: RESOLVED ✓

## Next Steps
1. Implement user CRUD routes
2. Add authorization checks
3. Test all endpoints
```

#### Loop 4: Testing Phase

**Action:** Write tests and document results

```javascript
// tests/auth.test.js
import request from 'supertest';
import { app } from '../src/server.js';
import { prisma } from '../src/db.js';

describe('Authentication API', () => {
  beforeEach(async () => {
    await prisma.user.deleteMany();
  });

  describe('POST /api/auth/register', () => {
    it('should create new user with valid data', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User'
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.user.email).toBe('test@example.com');
      expect(response.body.token).toBeDefined();
    });

    it('should reject duplicate email', async () => {
      // Create first user
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User'
        });

      // Try to create duplicate
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'password456',
          name: 'Another User'
        })
        .expect(409);

      expect(response.body.error).toMatch(/already exists/i);
    });
  });
});
```

**Update `task_plan.md`:**

```markdown
## Phases
- [x] Design API endpoints and data models ✓
- [x] Set up Express server and middleware ✓
- [x] Implement authentication (register, login, logout) ✓
- [x] Implement user CRUD operations ✓
- [x] Add input validation and error handling ✓
- [x] Write tests ✓
- [ ] Create API documentation ← Current

## Testing Results
- Authentication tests: 15/15 passing ✓
- User CRUD tests: 12/12 passing ✓
- Validation tests: 8/8 passing ✓
- Coverage: 87% (exceeds 60% requirement) ✓

## Next Steps
1. Create API documentation
2. Add usage examples
3. Create Postman collection
```

#### Loop 5: Documentation

**Action:** Create `user_api_documentation.md`

```markdown
# User Management API Documentation

## Overview
RESTful API for user management with JWT authentication.

**Base URL:** `http://localhost:3000/api`
**Authentication:** Bearer token in Authorization header

## Endpoints

### Authentication

#### Register New User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePass123",
  "name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "USER"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePass123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "user": { ... },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### User Management

#### Get Current User
```http
GET /users/me
Authorization: Bearer <token>
```

#### Update User
```http
PUT /users/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Doe",
  "email": "jane@example.com"
}
```

## Error Responses

All errors follow this format:
```json
{
  "success": false,
  "error": "Error message here"
}
```

**Status Codes:**
- `400` - Bad Request (validation error)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate resource)
- `500` - Internal Server Error

## Rate Limits
- Authentication endpoints: 5 requests per 15 minutes
- Other endpoints: 100 requests per 15 minutes

## Examples

### JavaScript (fetch)
```javascript
const response = await fetch('http://localhost:3000/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123',
    name: 'John Doe'
  })
});

const data = await response.json();
console.log(data.token);
```

### cURL
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123","name":"John Doe"}'
```
```

**Final `task_plan.md`:**

```markdown
## Phases
- [x] Design API endpoints and data models ✓
- [x] Set up Express server and middleware ✓
- [x] Implement authentication (register, login, logout) ✓
- [x] Implement user CRUD operations ✓
- [x] Add input validation and error handling ✓
- [x] Write tests ✓
- [x] Create API documentation ✓

## Current Status
Complete! All phases finished.

## Final Deliverables
- ✓ Fully functional User Management API
- ✓ JWT authentication with refresh tokens
- ✓ 35 passing tests (87% coverage)
- ✓ Complete API documentation
- ✓ Postman collection included

## Files Created (17 total)
- src/server.js
- src/routes/auth.routes.js
- src/routes/users.routes.js
- src/controllers/auth.controller.js
- src/controllers/users.controller.js
- src/services/auth.service.js
- src/services/users.service.js
- src/middleware/auth.js
- src/middleware/validation.js
- src/middleware/errorHandler.js
- src/utils/errors.js
- prisma/schema.prisma
- tests/auth.test.js
- tests/users.test.js
- user_api_documentation.md ✓
```

---

## Example 2: Bug Fix - Authentication Token Issue

### Scenario
User reports: "Users can't log in even with correct credentials"

### task_plan.md Evolution

**Initial Creation:**

```markdown
# Task: Fix Login Authentication Bug

## Goal
Resolve login failures for users with valid credentials.

## Phases
- [ ] Reproduce the issue
- [ ] Investigate root cause
- [ ] Implement fix
- [ ] Test and verify
- [ ] Deploy fix

## Current Status
Phase: 1 (Reproduction)
Last Action: Plan created

## Environment
- Browser: Chrome 120
- API: Node.js/Express backend
- Auth: JWT tokens
- Database: PostgreSQL

## Next Steps
1. Attempt login with test user credentials
2. Check browser console for errors
3. Review server logs
4. Check network request/response
```

**After Reproduction:**

```markdown
## Phases
- [x] Reproduce the issue ✓
- [ ] Investigate root cause ← Current
- [ ] Implement fix
- [ ] Test and verify
- [ ] Deploy fix

## Current Status
Phase: 2 (Investigation)
Last Action: Successfully reproduced issue

## Findings
- Login request reaches server: ✓
- Server response: 200 OK
- Response body contains user object
- Browser error: "Cannot read property 'token' of undefined"
- Location: src/client/auth/LoginForm.jsx line 23

## Hypothesis
Server is returning user but not including token in response.

## Next Steps
1. Read src/server/routes/auth.routes.js
2. Check auth.controller.js login function
3. Verify token generation logic
4. Check response structure
```

**After Investigation:**

```markdown
## Phases
- [x] Reproduce the issue ✓
- [x] Investigate root cause ✓
- [ ] Implement fix ← Current
- [ ] Test and verify
- [ ] Deploy fix

## Current Status
Phase: 3 (Implementation)
Last Action: Found root cause

## Root Cause
File: `src/controllers/auth.controller.js` line 45
Issue: Token is generated but not awaited before sending response

```javascript
// Current (broken) code:
const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET);
res.json({ success: true, user }); // token not included!
```

## Decisions Made
- Add await to token generation
- Include token in response object
- Add null check for user object before token generation
- Update response format to: `{ success, user, token }`

## Errors Encountered
- **Error 1: Initial fix attempt failed**
  - Problem: Added token to response but still undefined
  - Cause: Async timing issue - response sent before token ready
  - Investigation: Added console.log, confirmed timing problem
  - Resolution: Made login function async and added await
  - Status: RESOLVED ✓

## Next Steps
1. Update auth.controller.js with fix
2. Add test case for token presence
3. Verify fix with manual testing
4. Run full test suite
```

**After Fix:**

```markdown
## Phases
- [x] Reproduce the issue ✓
- [x] Investigate root cause ✓
- [x] Implement fix ✓
- [x] Test and verify ✓
- [ ] Deploy fix ← Current

## Current Status
Phase: 5 (Deployment)
Last Action: All tests passing

## Fix Applied
**File:** `src/controllers/auth.controller.js`

**Changes:**
```javascript
// Before (line 42-48):
export function login(req, res) {
  const user = await userService.authenticate(email, password);
  const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET);
  res.json({ success: true, user });
}

// After:
export async function login(req, res) {
  const user = await userService.authenticate(email, password);

  if (!user) {
    throw new UnauthorizedError('Invalid credentials');
  }

  const token = await jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  res.json({
    success: true,
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    },
    token
  });
}
```

## Testing Results
- ✓ Login with valid credentials: PASS
- ✓ Token included in response: PASS
- ✓ Token is valid JWT: PASS
- ✓ Login with invalid credentials: PASS (proper error)
- ✓ Token stored in localStorage: PASS
- ✓ Authenticated requests work: PASS
- ✓ All existing tests still pass: PASS (42/42)

## Next Steps
1. Create PR: "fix(auth): include JWT token in login response"
2. Add commit message with error details
3. Deploy to staging environment
4. Monitor for 24 hours
5. Deploy to production
```

---

## Example 3: Feature Development - Real-Time Notifications

### Scenario
User requests: "Add real-time notifications to the application using WebSockets"

### File Structure

```
task_plan.md              # Track implementation phases
notes.md                  # Research WebSocket libraries and patterns
notifications_spec.md     # Final feature specification
```

### task_plan.md

```markdown
# Task: Real-Time Notifications with WebSockets

## Goal
Implement real-time notification system using WebSockets for instant user alerts.

## Phases
- [ ] Research WebSocket libraries and architecture
- [ ] Design notification system
- [ ] Implement WebSocket server
- [ ] Create notification service
- [ ] Build frontend notification UI
- [ ] Add persistence layer
- [ ] Test real-time functionality
- [ ] Deploy and monitor

## Current Status
Phase: 1 (Research)

## Requirements
- Real-time push notifications to connected clients
- Support for multiple notification types (info, warning, error, success)
- Notification history and persistence
- Read/unread status tracking
- Connection resilience (auto-reconnect)

## Next Steps
1. Compare Socket.IO vs native WebSockets
2. Research notification patterns
3. Store findings in notes.md
```

### notes.md (After Research)

```markdown
# Real-Time Notifications - Research Notes

## WebSocket Library Comparison

### Socket.IO
**Pros:**
- Auto-reconnection built-in
- Fallback to polling if WebSocket not available
- Room support for broadcasting
- Large community and documentation

**Cons:**
- Larger bundle size (30KB vs 10KB)
- Requires Socket.IO on both client and server

**Verdict:** Choose Socket.IO for reliability and ease of use

## Architecture Design

### Server-Side
```javascript
// WebSocket event structure
{
  event: 'notification',
  data: {
    id: 'uuid',
    type: 'info' | 'warning' | 'error' | 'success',
    title: 'Notification Title',
    message: 'Notification body text',
    userId: 'uuid',
    read: false,
    createdAt: 'timestamp'
  }
}
```

### Client-Side Components
- NotificationProvider (Context)
- NotificationBell (UI component)
- NotificationList (dropdown)
- NotificationItem (individual notification)

### Database Schema
```prisma
model Notification {
  id        String   @id @default(uuid())
  userId    String
  type      NotificationType
  title     String
  message   String
  read      Boolean  @default(false)
  createdAt DateTime @default(now())
  user      User     @relation(fields: [userId], references: [id])
}

enum NotificationType {
  INFO
  WARNING
  ERROR
  SUCCESS
}
```

## Implementation Pattern

1. **Server establishes Socket.IO connection**
2. **Client authenticates via JWT token**
3. **Server joins client to user-specific room**
4. **Events trigger notifications**
5. **Server emits to user's room**
6. **Client receives and displays**
7. **Persist to database for history**

## Security Considerations
- Authenticate WebSocket connections with JWT
- Validate user can only receive their own notifications
- Rate limit notification sends
- Sanitize notification content (XSS prevention)
```

### task_plan.md (Updated After Implementation)

```markdown
## Phases
- [x] Research WebSocket libraries and architecture ✓
- [x] Design notification system ✓
- [x] Implement WebSocket server ✓
- [x] Create notification service ✓
- [x] Build frontend notification UI ✓
- [x] Add persistence layer ✓
- [ ] Test real-time functionality ← Current
- [ ] Deploy and monitor

## Current Status
Phase: 7 (Testing)
Last Action: Completed UI implementation

## Files Created
**Backend:**
- src/websocket/server.js - Socket.IO setup
- src/websocket/handlers.js - Event handlers
- src/services/notification.service.js - Business logic
- src/routes/notifications.routes.js - REST API for history
- prisma/migrations/add_notifications.sql

**Frontend:**
- src/contexts/NotificationContext.jsx - WebSocket connection
- src/components/NotificationBell.jsx - Bell icon with badge
- src/components/NotificationList.jsx - Dropdown list
- src/components/NotificationItem.jsx - Individual notification
- src/hooks/useNotifications.js - Custom hook

## Errors Encountered
- **Error 1: CORS issues with Socket.IO**
  - Context: Client couldn't connect to WebSocket server
  - Cause: CORS not configured for WebSocket handshake
  - Resolution: Added Socket.IO CORS config in server.js
  - Status: RESOLVED ✓

- **Error 2: Notifications not appearing on client**
  - Context: Server emitting but client not receiving
  - Investigation: Checked event names - mismatch found
  - Cause: Server emitting 'notification', client listening for 'notify'
  - Resolution: Standardized event names
  - Status: RESOLVED ✓

## Next Steps
1. Test notification delivery across multiple clients
2. Test auto-reconnection on connection loss
3. Load test with 100+ concurrent connections
4. Verify database persistence
```

### notifications_spec.md (Final Deliverable)

```markdown
# Real-Time Notifications Feature Specification

## Overview
Real-time notification system using Socket.IO for instant user alerts with persistence.

## Architecture

### WebSocket Connection Flow
```
Client connects → Authenticate JWT → Join user room → Ready for notifications
```

### Notification Flow
```
Event occurs → Create notification → Save to DB → Emit to user's room → Client displays
```

## API Endpoints

### REST API (Notification History)
```
GET /api/notifications - Get user's notifications
PUT /api/notifications/:id/read - Mark as read
DELETE /api/notifications/:id - Delete notification
```

### WebSocket Events

**Client → Server:**
- `authenticate` - Send JWT token
- `notification:read` - Mark notification as read
- `notification:delete` - Delete notification

**Server → Client:**
- `notification` - New notification
- `notification:read` - Notification marked as read
- `notification:deleted` - Notification deleted
- `connection:error` - Connection/auth error

## Usage

### Backend - Sending Notification
```javascript
import { notificationService } from './services/notification.service.js';

// Send notification to user
await notificationService.send({
  userId: 'user-uuid',
  type: 'success',
  title: 'Order Confirmed',
  message: 'Your order #1234 has been confirmed'
});
```

### Frontend - Displaying Notifications
```javascript
import { NotificationProvider } from './contexts/NotificationContext';
import { NotificationBell } from './components/NotificationBell';

function App() {
  return (
    <NotificationProvider>
      <Header>
        <NotificationBell />
      </Header>
      <Content />
    </NotificationProvider>
  );
}
```

## Testing Results
- ✓ Single client receives notifications: PASS
- ✓ Multiple clients receive independently: PASS
- ✓ Auto-reconnection after disconnect: PASS
- ✓ Notifications persist in database: PASS
- ✓ Read/unread status syncs: PASS
- ✓ Load test (100 connections): PASS
- ✓ JWT authentication required: PASS

## Performance Metrics
- Connection time: ~50ms
- Notification delivery latency: <100ms
- Memory per connection: ~5KB
- Max tested concurrent connections: 100
- Database query time: <20ms

## Future Enhancements
- Push notifications for mobile
- Notification preferences/settings
- Notification grouping
- Rich media support (images, links)
```

---

## Example 4: Performance Optimization - Database Query

### Scenario
API endpoint is slow - optimize database queries for better performance.

### task_plan.md

```markdown
# Task: Optimize User List API Performance

## Goal
Reduce /api/users endpoint response time from 3.2s to <500ms

## Phases
- [ ] Profile and identify bottlenecks
- [ ] Analyze database queries
- [ ] Implement optimizations
- [ ] Measure improvements
- [ ] Deploy changes

## Current Status
Phase: 1 (Profiling)

## Current Performance
- Response time: 3.2 seconds
- Database queries: 157 queries per request (!!)
- Memory usage: 450MB

## Next Steps
1. Add performance logging
2. Profile database queries
3. Identify N+1 query problems
```

### notes.md (Analysis Findings)

```markdown
# Performance Analysis Notes

## Profiling Results

### Query Analysis
```sql
-- Current implementation executes 157 queries:
SELECT * FROM users;  -- 1 query
SELECT * FROM posts WHERE userId = ?;  -- 100 queries (N+1 problem!)
SELECT * FROM comments WHERE postId = ?;  -- 56 queries (N+1 problem!)
```

**Problem:** N+1 queries loading posts for each user, then comments for each post

### Solution: Use Prisma `include` with eager loading

```javascript
// Before (N+1):
const users = await prisma.user.findMany();
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { userId: user.id } });
  for (const post of user.posts) {
    post.comments = await prisma.comment.findMany({ where: { postId: post.id } });
  }
}

// After (single query with joins):
const users = await prisma.user.findMany({
  include: {
    posts: {
      include: {
        comments: true
      }
    }
  }
});
```

## Additional Optimizations
1. Add database indexes on foreign keys
2. Implement pagination (limit 20 per page)
3. Add caching with Redis (5-minute TTL)
4. Use `select` to return only needed fields
```

### Final task_plan.md

```markdown
## Phases
- [x] Profile and identify bottlenecks ✓
- [x] Analyze database queries ✓
- [x] Implement optimizations ✓
- [x] Measure improvements ✓
- [x] Deploy changes ✓

## Optimizations Implemented

### 1. Fixed N+1 Queries
- Replaced sequential queries with single query + joins
- Queries reduced: 157 → 1

### 2. Added Database Indexes
```sql
CREATE INDEX idx_posts_userId ON posts(userId);
CREATE INDEX idx_comments_postId ON comments(postId);
```

### 3. Implemented Pagination
- Default: 20 items per page
- Max: 100 items per page

### 4. Added Redis Caching
- Cache key: `users:page:{page}`
- TTL: 5 minutes
- Invalidate on user create/update/delete

## Performance Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Response time | 3.2s | 180ms | **94% faster** |
| Database queries | 157 | 1 | **99% reduction** |
| Memory usage | 450MB | 85MB | **81% reduction** |

## Code Changes
- src/services/users.service.js - Added includes and caching
- src/routes/users.routes.js - Added pagination params
- prisma/migrations/add_indexes.sql - Created indexes
- src/utils/cache.js - Redis caching utility

## Testing
- ✓ Functionality unchanged
- ✓ All tests pass
- ✓ Load test with 100 concurrent requests: PASS
- ✓ Cache invalidation works correctly
```

---

## Key Takeaways from Examples

### Pattern Recognition

1. **Always start with task_plan.md** - Even for bugs, plan the investigation
2. **Store research/design in notes.md** - Keep design decisions documented
3. **Read plan before major decisions** - Refresh context to stay aligned
4. **Log all errors with full context** - Build knowledge, prevent repeats
5. **Update status after each phase** - Track progress systematically
6. **Create deliverables last** - Documentation captures final state

### The Read-Before-Decide Loop

```
Major Decision Point
    ↓
Read task_plan.md to refresh goals
    ↓
Read notes.md for design/research context
    ↓
Make informed decision
    ↓
Update task_plan.md with decision and outcome
    ↓
Continue to next phase
```

### Error Documentation Template

```markdown
## Errors Encountered
- **Error N: [Exact error message]**
  - Context: [What were you trying to do?]
  - Location: [File path and line number]
  - Code: [The code that caused the error]
  - Root Cause: [Why did it happen?]
  - Investigation: [What did you check? What helped?]
  - Resolution: [Exact fix applied]
  - Status: RESOLVED ✓ / IN PROGRESS / BLOCKED
```

### When to Use This Methodology

**✅ Use for:**
- Building new features (3+ phases)
- Complex bug investigations
- Performance optimizations
- System integrations
- Architectural changes

**❌ Skip for:**
- Simple one-line fixes
- Typo corrections
- Minor UI tweaks
- Documentation updates

---

Remember: The goal is **persistence of context**. When you document your development journey with task plans, research notes, and error logs, you never lose track of where you are or where you're going.