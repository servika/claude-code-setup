# Technical Documentation Guide

Guidelines for creating and maintaining high-quality technical documentation in Node.js/Express/React/MUI projects.

---

## Overview

Good documentation:
- **Enables self-service** - Answers questions without requiring human intervention
- **Speeds onboarding** - New team members can contribute faster
- **Reduces support burden** - Fewer questions, more productivity
- **Preserves knowledge** - Prevents bus factor issues
- **Facilitates debugging** - Helps trace decisions and changes

This guide covers documentation standards beyond code comments (see commit-policy.md for JSDoc and inline comments).

---

## Types of Documentation

### 1. README Files

**Purpose**: Project overview and quick start guide

**Location**:
- Root: `README.md` (project overview)
- Modules: `src/module/README.md` (module-specific)

**Structure**:

```markdown
# Project Name

One-sentence description of what this project does.

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Prerequisites

- Node.js >= 18.0.0
- PostgreSQL >= 14
- Redis (optional, for caching)

## Quick Start

\```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
npm run migrate

# Start development server
npm run dev
\```

Visit http://localhost:3000

## Project Structure

\```
src/
├── routes/        # Express route definitions
├── controllers/   # Request handlers
├── services/      # Business logic
├── models/        # Data models
└── utils/         # Utilities
\```

## Configuration

See `.env.example` for required environment variables:

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret for JWT signing (min 32 chars)
- `PORT` - Server port (default: 3000)

## Development

\```bash
npm run dev          # Start dev server with hot reload
npm test             # Run test suite
npm run test:watch   # Run tests in watch mode
npm run lint         # Check code quality
npm run format       # Format code
\```

## Testing

\```bash
npm test                # Run all tests
npm test -- --coverage  # Run with coverage report
npm test auth.test.js   # Run specific test file
\```

Coverage requirement: 60% overall, 20% per file

## API Documentation

See `docs/API.md` for detailed endpoint documentation, or visit `/api-docs` when server is running (Swagger UI).

## Deployment

See `docs/DEPLOYMENT.md` for production deployment instructions.

## Contributing

1. Create feature branch from `dev`
2. Make changes following guidelines in `.claude/`
3. Write tests (coverage >= 60%)
4. Create PR targeting `dev`
5. Wait for review and approval

See `CONTRIBUTING.md` for detailed guidelines.

## Troubleshooting

### Database connection fails

Ensure PostgreSQL is running and DATABASE_URL is correct:
\```bash
psql $DATABASE_URL
\```

### Tests failing

Clear test database:
\```bash
npm run test:db:reset
\```

### Port already in use

Change PORT in .env or kill process using the port:
\```bash
lsof -ti:3000 | xargs kill -9
\```

## License

MIT

## Credits

Built with:
- [Express.js](https://expressjs.com/)
- [React](https://reactjs.org/)
- [Material-UI](https://mui.com/)
```

**README Best Practices**:
- ✓ Start with one-sentence description
- ✓ Include quick start (< 5 minutes)
- ✓ Show project structure
- ✓ Document all environment variables
- ✓ Include troubleshooting section
- ✓ Keep it updated (living document)
- ✗ Don't include detailed API docs (separate file)
- ✗ Don't duplicate information from other docs
- ✗ Don't let it grow beyond 200 lines (split into separate docs)

### 2. API Documentation

**Purpose**: Comprehensive endpoint reference

**Location**: `docs/API.md` or auto-generated (Swagger/OpenAPI)

**Format Options**:

**Option A: Manual Markdown**

```markdown
# API Documentation

Base URL: `https://api.example.com/v1`

Authentication: All endpoints require JWT token in `Authorization: Bearer <token>` header unless marked [Public].

## Authentication

### POST /api/auth/register

Create a new user account.

**Request Body**:
\```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "John Doe"
}
\```

**Validation**:
- `email`: Valid email format, max 255 chars
- `password`: Min 8 chars, max 128 chars
- `name`: Min 2 chars, max 100 chars

**Response 201 Created**:
\```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2025-01-11T00:00:00Z"
}
\```

**Response 400 Bad Request**:
\```json
{
  "error": "Validation failed",
  "fields": {
    "email": "Email already exists"
  }
}
\```

**Response 429 Too Many Requests**:
\```json
{
  "error": "Too many registration attempts, try again in 15 minutes"
}
\```

**Rate Limit**: 5 requests per 15 minutes per IP

**Example**:
\```bash
curl -X POST https://api.example.com/v1/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123",
    "name": "John Doe"
  }'
\```

---

### POST /api/auth/login

Authenticate and receive JWT token.

**Request Body**:
\```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
\```

**Response 200 OK**:
\```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
\```

Sets httpOnly cookie: `token=<jwt>; HttpOnly; Secure; SameSite=Strict`

**Response 401 Unauthorized**:
\```json
{
  "error": "Invalid credentials"
}
\```

**Rate Limit**: 5 requests per 15 minutes per IP (resets on success)

---

## Users

### GET /api/users/:id

Retrieve user by ID.

**Authentication**: Required

**Parameters**:
- `id` (path, string, required) - User's UUID

**Response 200 OK**:
\```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2025-01-11T00:00:00Z"
}
\```

**Response 401 Unauthorized**:
\```json
{
  "error": "Authentication required"
}
\```

**Response 403 Forbidden**:
\```json
{
  "error": "Not authorized to view this user"
}
\```

**Response 404 Not Found**:
\```json
{
  "error": "User not found"
}
\```

**Authorization**: Users can only view their own profile, admins can view any user.

---

### PUT /api/users/:id

Update user profile.

**Authentication**: Required

**Parameters**:
- `id` (path, string, required) - User's UUID

**Request Body** (all fields optional):
\```json
{
  "name": "Jane Doe",
  "email": "newemail@example.com"
}
\```

**Response 200 OK**:
\```json
{
  "id": "uuid-here",
  "email": "newemail@example.com",
  "name": "Jane Doe",
  "updatedAt": "2025-01-11T01:00:00Z"
}
\```

**Response 400 Bad Request**:
\```json
{
  "error": "Validation failed",
  "fields": {
    "email": "Email already in use"
  }
}
\```

**Authorization**: Users can only update their own profile.

---

## Error Responses

All error responses follow this format:

\```json
{
  "error": "Human-readable error message",
  "fields": {
    "fieldName": "Field-specific error"
  }
}
\```

**Common HTTP Status Codes**:
- `200 OK` - Request succeeded
- `201 Created` - Resource created
- `204 No Content` - Success with no response body
- `400 Bad Request` - Validation error
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Rate Limiting

**Authentication endpoints**: 5 requests per 15 minutes per IP
**General API**: 100 requests per 15 minutes per IP

Rate limit headers:
\```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1641938400
\```

## Pagination

List endpoints support pagination:

**Query Parameters**:
- `page` (number, default: 1) - Page number
- `limit` (number, default: 20, max: 100) - Items per page

**Response**:
\```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
\```
```

**Option B: OpenAPI/Swagger** (Recommended)

```javascript
// swagger.config.js
import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'My API',
      version: '1.0.0',
      description: 'API documentation',
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Development' },
      { url: 'https://api.example.com', description: 'Production' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./src/routes/*.js'], // Path to API routes
};

export const specs = swaggerJsdoc(options);
```

```javascript
// routes/users.routes.js
/**
 * @swagger
 * /api/users/{id}:
 *   get:
 *     summary: Get user by ID
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User UUID
 *     responses:
 *       200:
 *         description: User found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       404:
 *         description: User not found
 */
router.get('/:id', authenticate, getUser);
```

### 3. Architecture Decision Records (ADRs)

**Purpose**: Document significant architectural decisions

**Location**: `docs/adr/` or `.claude/decisions/`

**Format**: (Already covered in project-management.md)

```markdown
# ADR-001: JWT Authentication with httpOnly Cookies

## Status
Accepted

## Context
We need secure authentication for the application. Options:
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
### Positive
- Better security than localStorage
- No session store to manage
- Horizontal scaling easier

### Negative
- Cannot access token from JavaScript (by design)
- Need CSRF protection for state-changing operations
- Must handle token refresh logic
- Cookie must be sent with credentials: 'include'

## Alternatives Considered
- **localStorage**: Rejected due to XSS vulnerability
- **Redis sessions**: Rejected due to added complexity

## Date
2025-01-11

## Author
@john-doe

## Reviewers
@sarah-tech-lead, @mike-security
```

**ADR Guidelines**:
- ✓ Number sequentially (ADR-001, ADR-002, etc.)
- ✓ Record when decision made (even if seems obvious)
- ✓ Include alternatives considered
- ✓ Document consequences (both positive and negative)
- ✓ Never delete or modify (immutable record)
- ✓ Create new ADR to supersede old one if decision changes

### 4. Runbooks & Operational Docs

**Purpose**: Step-by-step operational procedures

**Location**: `docs/runbooks/`

**Example: Deployment Runbook**

```markdown
# Deployment Runbook

## Prerequisites

- [ ] Access to production environment
- [ ] Database backup completed
- [ ] Rollback procedure documented
- [ ] Team notified of deployment window
- [ ] Monitoring dashboard open

## Pre-Deployment Checklist

- [ ] All tests passing in CI/CD
- [ ] Code reviewed and approved
- [ ] Staging tested successfully
- [ ] Database migrations tested
- [ ] Environment variables updated
- [ ] Feature flags configured (if using)

## Deployment Steps

### 1. Database Migrations

```bash
# Connect to production database
ssh production-db-host

# Backup database
pg_dump myapp_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Run migrations
npm run migrate

# Verify migrations
psql myapp_production -c "SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 5;"
```

### 2. Deploy Application

```bash
# Deploy to production
git checkout main
git pull origin main
./deploy.sh production

# Or using CI/CD
# Merge PR to main, deployment runs automatically
```

### 3. Verify Deployment

```bash
# Health check
curl https://api.example.com/health

# Verify version
curl https://api.example.com/version

# Check recent logs
tail -f /var/log/myapp/production.log

# Monitor error rate in DataDog/New Relic
# Should remain < 0.1%
```

### 4. Smoke Tests

- [ ] Visit homepage: https://example.com
- [ ] Login with test account
- [ ] Create test item
- [ ] Update test item
- [ ] Delete test item
- [ ] Logout

### 5. Monitor (30 minutes post-deployment)

- [ ] Error rate normal (< 0.1%)
- [ ] Response time normal (P95 < 500ms)
- [ ] CPU/Memory within normal range
- [ ] No new alerts triggered
- [ ] User reports normal

## Rollback Procedure

If issues detected:

```bash
# Rollback deployment
git checkout <previous-version-tag>
./deploy.sh production

# Rollback database (if needed)
psql myapp_production < backup_YYYYMMDD_HHMMSS.sql

# Verify rollback
curl https://api.example.com/version
```

## Post-Deployment

- [ ] Update deployment log
- [ ] Notify team of successful deployment
- [ ] Close deployment ticket
- [ ] Document any issues encountered
- [ ] Update runbook if process changed

## Emergency Contacts

- On-call Engineer: [PagerDuty / Phone]
- DevOps Lead: [Contact]
- Database Admin: [Contact]
- Product Owner: [Contact]

## Related Documentation

- Deployment architecture: `docs/ARCHITECTURE.md`
- Database schema: `docs/DATABASE.md`
- Monitoring dashboards: [Links]
```

**Example: Incident Response Runbook**

See quality-management.md > Incident Playbook Template (already comprehensive)

### 5. Code Examples & Tutorials

**Purpose**: Teach common patterns and workflows

**Location**: `docs/examples/` or `examples/`

**Example: Authentication Tutorial**

```markdown
# Tutorial: Adding Authentication

This tutorial walks through implementing JWT authentication in the app.

## What You'll Build

- User registration endpoint
- Login endpoint with JWT token
- Protected route middleware
- Frontend login form

**Time**: ~2 hours

## Prerequisites

- Completed quick start guide
- Familiar with Express and React

## Step 1: Install Dependencies

\```bash
npm install bcrypt jsonwebtoken zod
\```

## Step 2: Create User Model

Create `src/models/user.model.js`:

\```javascript
import bcrypt from 'bcrypt';

export class User {
  constructor(data) {
    this.id = data.id;
    this.email = data.email;
    this.passwordHash = data.password_hash;
    this.name = data.name;
    this.createdAt = data.created_at;
  }

  static async create({ email, password, name }) {
    const passwordHash = await bcrypt.hash(password, 12);

    const result = await db.query(
      'INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING *',
      [email, passwordHash, name]
    );

    return new User(result.rows[0]);
  }

  async verifyPassword(password) {
    return bcrypt.compare(password, this.passwordHash);
  }

  toJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      createdAt: this.createdAt,
    };
  }
}
\```

## Step 3: Create Auth Routes

Create `src/routes/auth.routes.js`:

\```javascript
import express from 'express';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { User } from '../models/user.model.js';

const router = express.Router();

const registerSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(128),
  name: z.string().min(2).max(100),
});

router.post('/register', async (req, res) => {
  try {
    const data = registerSchema.parse(req.body);
    const user = await User.create(data);

    res.status(201).json(user);
  } catch (error) {
    if (error.code === '23505') { // Unique constraint violation
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(400).json({ error: error.message });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findByEmail(email);
  if (!user || !(await user.verifyPassword(password))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  res.cookie('token', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 3600000, // 1 hour
  });

  res.json(user);
});

export default router;
\```

## Step 4: Create Auth Middleware

Create `src/middleware/auth.middleware.js`:

\```javascript
import jwt from 'jsonwebtoken';

export function authenticate(req, res, next) {
  const token = req.cookies.token || req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}
\```

## Step 5: Mount Routes

Update `src/app.js`:

\```javascript
import authRoutes from './routes/auth.routes.js';

app.use('/api/auth', authRoutes);
\```

## Step 6: Test with curl

\```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Access protected route
curl http://localhost:3000/api/profile \
  -H "Authorization: Bearer <token-from-login>"
\```

## Next Steps

- Add password reset flow
- Implement token refresh
- Add OAuth providers (Google, GitHub)
- Add two-factor authentication

## Related Documentation

- Security guidelines: `.claude/rules/security.md`
- Testing authentication: `.claude/rules/testing.md`
```

### 6. Troubleshooting Guides

**Purpose**: Common problems and solutions

**Location**: `docs/TROUBLESHOOTING.md` or in README

```markdown
# Troubleshooting Guide

## Database Issues

### Connection Refused

**Symptom**: `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Cause**: PostgreSQL not running or wrong connection string

**Solution**:
\```bash
# Check if PostgreSQL is running
pg_isready

# Start PostgreSQL (macOS)
brew services start postgresql

# Verify connection string
echo $DATABASE_URL
\```

### Migration Fails

**Symptom**: `Error: relation "users" already exists`

**Cause**: Database already has the table

**Solution**:
\```bash
# Reset database (development only!)
npm run db:reset

# Or manually drop tables
psql $DATABASE_URL -c "DROP TABLE IF EXISTS users CASCADE;"
\```

## Authentication Issues

### JWT Token Invalid

**Symptom**: `401 Unauthorized - Invalid token`

**Causes**:
1. Token expired (default: 1 hour)
2. JWT_SECRET changed
3. Token format incorrect

**Solutions**:
\```bash
# Check token expiration
node -e "console.log(JSON.parse(Buffer.from('PASTE_TOKEN_PAYLOAD_HERE', 'base64')))"

# Verify JWT_SECRET set
echo $JWT_SECRET

# Login again to get fresh token
curl -X POST http://localhost:3000/api/auth/login ...
\```

### CORS Error in Browser

**Symptom**: `Access to fetch at 'http://localhost:3000' from origin 'http://localhost:5173' has been blocked by CORS policy`

**Cause**: Frontend and backend on different ports

**Solution**:

Update `src/app.js`:
\```javascript
app.use(cors({
  origin: 'http://localhost:5173', // Vite dev server
  credentials: true
}));
\```

## Test Issues

### Tests Timeout

**Symptom**: `Timeout - Async callback was not invoked within the 5000 ms timeout`

**Cause**: Forgot to `await` or return promise

**Solution**:
\```javascript
// Bad
it('should fetch user', () => {
  fetchUser('123'); // ❌ No await
});

// Good
it('should fetch user', async () => {
  await fetchUser('123'); // ✓
});
\```

### Test Database Conflicts

**Symptom**: Tests fail with "unique constraint violation"

**Cause**: Test data not cleaned between tests

**Solution**:
\```javascript
afterEach(async () => {
  await db.query('TRUNCATE TABLE users CASCADE');
});
\```

## Performance Issues

### Slow API Responses

**Symptom**: Requests take > 2 seconds

**Debug Steps**:

1. Check database queries:
\```javascript
// Add logging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(`${req.method} ${req.url} - ${Date.now() - start}ms`);
  });
  next();
});
\```

2. Check for N+1 queries:
\```javascript
// Bad: N+1 query
for (const user of users) {
  user.posts = await db.posts.find({ userId: user.id });
}

// Good: Single query with join
const usersWithPosts = await db.query(`
  SELECT u.*, json_agg(p.*) as posts
  FROM users u
  LEFT JOIN posts p ON p.user_id = u.id
  GROUP BY u.id
`);
\```

3. Add database indexes:
\```sql
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_users_email ON users(email);
\```

## Build Issues

### Module Not Found

**Symptom**: `Error: Cannot find module 'express'`

**Solution**:
\```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
\```

### ESLint Errors

**Symptom**: Build fails with linting errors

**Solution**:
\```bash
# See all errors
npm run lint

# Auto-fix
npm run lint -- --fix

# Disable for specific line (use sparingly)
// eslint-disable-next-line no-console
console.log('Debug info');
\```

## Getting Help

If you can't find solution here:

1. Search existing GitHub issues
2. Check logs: `tail -f logs/development.log`
3. Enable debug mode: `DEBUG=* npm run dev`
4. Ask in team chat with error message and steps to reproduce
5. Create GitHub issue with reproduction steps
```

---

## Documentation Maintenance

### Living Documentation Principle

**All documentation must be actively maintained**:

**Update immediately when**:
- Code patterns change
- APIs change (endpoints, parameters, responses)
- Configuration requirements change
- Environment variables added/changed
- New features added
- Old features deprecated

**Signs documentation needs updating**:
- Code examples don't run
- Team asks questions answered in docs
- Contradictions between docs and code
- Broken links
- Outdated screenshots
- Deprecated patterns still documented

### Documentation Review Schedule

**Weekly** (during sprint):
- Check for outdated examples
- Fix broken links
- Update API docs for new endpoints

**Monthly**:
- Review all documentation for accuracy
- Test all code examples
- Update version numbers and dates

**Quarterly**:
- Major documentation refactoring if needed
- Review documentation structure
- Gather team feedback on docs

### Documentation in Pull Requests

**Documentation changes required for**:
- New features → Update README, API docs
- API changes → Update API docs, examples
- Configuration changes → Update README, .env.example
- Architecture changes → Create/update ADR
- Bug fixes → Update troubleshooting guide (if applicable)

**PR Checklist includes**:
- [ ] README updated (if user-visible change)
- [ ] API docs updated (if endpoints changed)
- [ ] Examples still work
- [ ] .env.example updated (if new variables)
- [ ] Troubleshooting guide updated (if relevant)

---

## Documentation Tools

### Recommended Tools

**API Documentation**:
- Swagger/OpenAPI (auto-generated from code)
- Postman Collections (for testing)

**Code Documentation**:
- JSDoc (required - see commit-policy.md)
- TypeDoc (if using TypeScript)

**Static Site Generators** (for complex projects):
- Docusaurus
- VitePress
- MkDocs

**Diagram Tools**:
- Mermaid (diagrams as code in Markdown)
- Excalidraw (hand-drawn style diagrams)
- draw.io (detailed diagrams)

### Example: Mermaid Diagrams in Docs

```markdown
## Authentication Flow

\```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Backend
    participant Database

    User->>Frontend: Enter credentials
    Frontend->>Backend: POST /api/auth/login
    Backend->>Database: Query user
    Database-->>Backend: User data
    Backend->>Backend: Verify password
    Backend->>Backend: Generate JWT
    Backend-->>Frontend: Set cookie, return user
    Frontend-->>User: Redirect to dashboard
\```

## Database Schema

\```mermaid
erDiagram
    USERS ||--o{ POSTS : creates
    USERS {
        uuid id PK
        string email UK
        string password_hash
        string name
        timestamp created_at
    }
    POSTS {
        uuid id PK
        uuid user_id FK
        string title
        text content
        timestamp created_at
    }
\```
```

---

## Documentation Style Guide

### Writing Style

**DO**:
- ✓ Use active voice ("Click the button" not "The button should be clicked")
- ✓ Use present tense ("The function returns" not "The function will return")
- ✓ Be concise and direct
- ✓ Use code examples liberally
- ✓ Use bullet points for lists
- ✓ Include concrete examples

**DON'T**:
- ✗ Use passive voice unnecessarily
- ✗ Use future tense
- ✗ Be vague or ambiguous
- ✗ Assume knowledge
- ✗ Use jargon without explanation

### Code Examples

**Good code example**:
```javascript
// Good: Complete, runnable example
import express from 'express';

const app = express();

app.get('/api/users', async (req, res) => {
  const users = await db.users.findAll();
  res.json(users);
});

app.listen(3000);
```

**Bad code example**:
```javascript
// Bad: Incomplete, won't run
app.get('/api/users', (req, res) => {
  // ... fetch users somehow
  res.json(users);
});
```

### Formatting Conventions

**Code blocks**: Always specify language
```javascript
// ✓ Good
\```javascript
const foo = 'bar';
\```

// ✗ Bad (no language)
\```
const foo = 'bar';
\```
```

**File paths**: Use code formatting
- ✓ `src/routes/users.routes.js`
- ✗ src/routes/users.routes.js

**Environment variables**: Use code formatting
- ✓ `DATABASE_URL`
- ✗ DATABASE_URL

**Commands**: Use code blocks
```bash
npm install
npm test
```

**UI elements**: Use bold
- ✓ Click the **Save** button
- ✗ Click the Save button

---

## Summary

**Documentation Types**:
1. README - Project overview and quick start
2. API Docs - Endpoint reference (manual or auto-generated)
3. ADRs - Architecture decisions (immutable record)
4. Runbooks - Operational procedures
5. Tutorials - Teaching common patterns
6. Troubleshooting - Common problems and solutions

**Core Principles**:
- Living documentation (always current)
- Code examples must work
- Update docs with code changes
- Test examples regularly
- Keep docs close to code

**When to Document**:
- New features → README, API docs
- Architecture decisions → ADR
- Complex procedures → Runbook
- Common issues → Troubleshooting guide

**Remember**: Good documentation is code. Treat it with the same care and rigor as production code.