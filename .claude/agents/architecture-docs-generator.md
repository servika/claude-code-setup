# Architecture Documentation Generator Agent

## Purpose
Generate comprehensive architecture documentation including system design, data flow diagrams, component architecture, database schemas, and technical decision records.

## When to Invoke
- Creating initial architecture documentation
- Documenting major architectural decisions
- Creating system design diagrams
- Documenting database schemas
- Writing API architecture docs
- Creating component architecture documentation

## Documentation Types

### 1. ARCHITECTURE.md

```markdown
# System Architecture

## Overview

This document describes the high-level architecture of the application, including system components, data flow, and technical decisions.

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Browser    │  │   Mobile     │  │   Desktop    │     │
│  │   (React)    │  │   (React     │  │   (Electron) │     │
│  │              │  │   Native)    │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │     HTTPS/WSS    │     HTTPS/WSS    │     HTTPS/WSS
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼─────────────┐
│                      API Gateway / Load Balancer             │
│                         (Nginx / AWS ALB)                     │
└────────────────────────────┬──────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼───────┐   ┌───────▼───────┐   ┌───────▼───────┐
│  API Server 1 │   │  API Server 2 │   │  API Server N │
│  (Node.js/    │   │  (Node.js/    │   │  (Node.js/    │
│   Express)    │   │   Express)    │   │   Express)    │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼─────────┐  ┌─────▼────────┐  ┌──────▼────────┐
│   PostgreSQL    │  │    Redis     │  │   S3 Storage  │
│   (Primary DB)  │  │   (Cache/    │  │  (File Store) │
│                 │  │   Sessions)  │  │               │
└─────────────────┘  └──────────────┘  └───────────────┘
```

## Technology Stack

### Backend
- **Runtime**: Node.js 18+ with Express.js 4.x
- **Language**: Modern JavaScript (ES6+) with ESM modules
- **Database**: PostgreSQL 14+ (primary), Redis (cache/sessions)
- **Authentication**: JWT with refresh tokens
- **Validation**: express-validator
- **Security**: Helmet, CORS, rate limiting
- **Logging**: Winston with structured logging
- **Testing**: Jest for unit/integration tests

### Frontend
- **Framework**: React 18+
- **UI Library**: Material-UI (MUI) 5.x
- **Routing**: React Router 6.x
- **Forms**: React Hook Form
- **State Management**: React Context / Zustand
- **Data Fetching**: React Query
- **Testing**: React Testing Library, Jest

### DevOps
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions / GitLab CI
- **Hosting**: AWS / DigitalOcean / Heroku
- **Monitoring**: PM2, New Relic, Sentry
- **Version Control**: Git with GitHub

## Architecture Patterns

### Backend Architecture

We follow a layered architecture pattern:

```
┌─────────────────────────────────────────────┐
│              API Routes Layer               │
│  (HTTP endpoints, routing, OpenAPI specs)   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           Middleware Layer                  │
│  (Auth, Validation, Error Handling, CORS)   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           Controller Layer                  │
│  (Request handling, response formatting)    │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           Service Layer                     │
│  (Business logic, orchestration)            │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Data Access Layer                   │
│  (Database queries, ORM interactions)       │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              Database                       │
│  (PostgreSQL, Redis)                        │
└─────────────────────────────────────────────┘
```

#### Layer Responsibilities

**Routes Layer**
- Define API endpoints
- Apply middleware (auth, validation)
- Route requests to controllers
- Input validation rules

**Middleware Layer**
- Authentication & authorization
- Request validation
- Error handling
- Rate limiting
- CORS configuration
- Request logging

**Controller Layer**
- Handle HTTP requests
- Extract request data
- Call service layer
- Format responses
- Handle HTTP status codes

**Service Layer**
- Business logic implementation
- Transaction management
- Orchestrate multiple data operations
- Third-party API integrations
- Domain-specific operations

**Data Access Layer**
- Database queries
- ORM/Query builder usage
- Data mapping
- Caching logic

### Frontend Architecture

```
┌─────────────────────────────────────────────┐
│                 Pages Layer                 │
│  (Route-level components, page layouts)     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│            Feature Components               │
│  (Complex components with business logic)   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              UI Components                  │
│  (Reusable, presentational components)      │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│            Custom Hooks                     │
│  (Reusable logic, API calls, state)         │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│          Services / API Layer               │
│  (HTTP client, API endpoints)               │
└─────────────────────────────────────────────┘
```

## Data Flow

### Request Flow (Backend)

```
1. Client Request
   ↓
2. Nginx/Load Balancer
   ↓
3. Express Server
   ↓
4. Middleware Pipeline
   ├── Logger
   ├── CORS
   ├── Body Parser
   ├── Authentication
   ├── Authorization
   └── Validation
   ↓
5. Route Handler
   ↓
6. Controller
   ├── Extract request data
   ├── Call service layer
   └── Format response
   ↓
7. Service Layer
   ├── Business logic
   ├── Database operations
   └── Cache operations
   ↓
8. Data Access Layer
   ├── Query database
   └── Cache results
   ↓
9. Response to Client
   ├── Success (200, 201, etc.)
   └── Error (400, 401, 500, etc.)
```

### Authentication Flow

```
1. User Login Request
   ├── Email/Password
   └── POST /api/auth/login
   ↓
2. Validate Credentials
   ├── Check user exists
   ├── Verify password (bcrypt)
   └── Check account status
   ↓
3. Generate Tokens
   ├── Access Token (JWT, 15min expiry)
   └── Refresh Token (JWT, 7d expiry)
   ↓
4. Store Refresh Token
   └── Redis (with user ID)
   ↓
5. Return Tokens to Client
   ├── Access Token (in response body)
   └── Refresh Token (httpOnly cookie)
   ↓
6. Subsequent Requests
   ├── Include Access Token in Authorization header
   ├── Verify token in auth middleware
   └── Attach user to request
   ↓
7. Token Refresh Flow
   ├── Access Token expires
   ├── POST /api/auth/refresh with Refresh Token
   ├── Validate Refresh Token
   ├── Generate new Access Token
   └── Return new Access Token
```

## Database Schema

### Users Table

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'user',
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  avatar_url VARCHAR(500),
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,

  CONSTRAINT check_role CHECK (role IN ('user', 'admin', 'moderator')),
  CONSTRAINT check_status CHECK (status IN ('active', 'inactive', 'suspended'))
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

### Sessions Table (if using database sessions)

```sql
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token_hash VARCHAR(255) NOT NULL,
  user_agent VARCHAR(500),
  ip_address INET,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,

  CONSTRAINT check_expires CHECK (expires_at > created_at)
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);
```

### Entity Relationships

```
┌─────────────┐
│    Users    │
│─────────────│
│ id (PK)     │
│ email       │
│ name        │
│ role        │
└─────┬───────┘
      │
      │ 1:N
      │
┌─────▼───────┐
│  Sessions   │
│─────────────│
│ id (PK)     │
│ user_id (FK)│
│ token_hash  │
└─────────────┘
```

## API Design

### RESTful Principles

- Use nouns for resources: `/api/users`, `/api/posts`
- Use HTTP methods appropriately:
  - GET: Retrieve resources
  - POST: Create resources
  - PUT: Full update
  - PATCH: Partial update
  - DELETE: Remove resources

### API Versioning

```
/api/v1/users
/api/v1/posts
```

### Response Format

```json
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe"
  },
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10
  }
}
```

### Error Response Format

```json
{
  "success": false,
  "error": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

## Security Architecture

### Security Layers

1. **Network Layer**
   - HTTPS/TLS encryption
   - Firewall rules
   - DDoS protection

2. **Application Layer**
   - Input validation (express-validator)
   - Output encoding
   - CORS configuration
   - Security headers (Helmet)
   - Rate limiting
   - SQL injection prevention

3. **Authentication Layer**
   - JWT tokens
   - Password hashing (bcrypt)
   - Session management
   - MFA (optional)

4. **Authorization Layer**
   - Role-based access control (RBAC)
   - Resource-level permissions
   - API key authentication (for services)

### Security Best Practices Implemented

✅ Password hashing with bcrypt (10+ rounds)
✅ JWT with short expiry (15min access, 7d refresh)
✅ httpOnly cookies for refresh tokens
✅ CSRF protection
✅ Rate limiting on auth endpoints
✅ Input validation and sanitization
✅ Parameterized database queries
✅ Security headers (Helmet)
✅ CORS whitelist
✅ Audit logging for sensitive operations

## Scalability Considerations

### Horizontal Scaling

- **Stateless servers**: No session state in memory
- **Load balancing**: Nginx/AWS ALB distributes traffic
- **Database connection pooling**: Efficient connection management
- **Caching**: Redis for session and data caching

### Vertical Scaling

- **Database optimization**: Indexes, query optimization
- **Memory management**: Efficient data structures
- **CPU optimization**: Async operations, worker threads

### Caching Strategy

```
┌──────────────────────────────────────┐
│         Cache Strategy               │
├──────────────────────────────────────┤
│ Cache Layer: Redis                   │
│                                      │
│ Cache TTL:                           │
│ - User sessions: 7 days              │
│ - API responses: 5 minutes           │
│ - Static data: 1 hour                │
│                                      │
│ Invalidation:                        │
│ - Time-based (TTL)                   │
│ - Event-based (on update/delete)     │
│ - Manual (admin action)              │
└──────────────────────────────────────┘
```

## Monitoring & Observability

### Logging Strategy

- **Levels**: Error, Warn, Info, Debug
- **Structured logging**: JSON format
- **Log aggregation**: ELK Stack / CloudWatch
- **Sensitive data**: Never log passwords, tokens

### Metrics to Monitor

- Request rate (req/sec)
- Response time (avg, p95, p99)
- Error rate (4xx, 5xx)
- Database query time
- Cache hit rate
- Memory usage
- CPU usage

### Alerting

- High error rate (>5% 5xx errors)
- Slow response time (>1s p95)
- High CPU/memory usage (>80%)
- Database connection pool exhausted
- Low disk space (<20%)

## Deployment Architecture

### Production Environment

```
┌─────────────────────────────────────────┐
│           AWS / Cloud Provider          │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Route 53 (DNS)                   │ │
│  └────────────┬──────────────────────┘ │
│               │                         │
│  ┌────────────▼──────────────────────┐ │
│  │  CloudFront (CDN)                 │ │
│  └────────────┬──────────────────────┘ │
│               │                         │
│  ┌────────────▼──────────────────────┐ │
│  │  ALB (Load Balancer)              │ │
│  └────────────┬──────────────────────┘ │
│               │                         │
│  ┌────────────▼──────────────────────┐ │
│  │  ECS / EC2 (App Servers)          │ │
│  │  ┌──────────┐  ┌──────────┐      │ │
│  │  │ Server 1 │  │ Server 2 │      │ │
│  │  └──────────┘  └──────────┘      │ │
│  └────────────┬──────────────────────┘ │
│               │                         │
│  ┌────────────▼──────────────────────┐ │
│  │  RDS (PostgreSQL)                 │ │
│  │  + Read Replica                   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  ElastiCache (Redis)              │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  S3 (File Storage)                │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Technical Decision Records

### ADR-001: Use PostgreSQL over MongoDB

**Status**: Accepted

**Context**: Need to choose primary database

**Decision**: Use PostgreSQL

**Rationale**:
- Strong ACID compliance
- Better for relational data
- Excellent JSON support for flexibility
- Mature ecosystem and tooling
- Team expertise

**Consequences**:
- Must manage schema migrations
- Need to learn SQL if not familiar

### ADR-002: JWT for Authentication

**Status**: Accepted

**Context**: Need authentication mechanism

**Decision**: Use JWT with refresh tokens

**Rationale**:
- Stateless authentication
- Scales horizontally
- Industry standard
- Good security with proper implementation

**Consequences**:
- Cannot revoke tokens immediately
- Need refresh token mechanism
- Must secure token storage

## Future Considerations

### Microservices Migration

When to consider:
- Team grows beyond 10 developers
- Clear bounded contexts emerge
- Independent scaling needs
- Different tech stack requirements

### Event-Driven Architecture

Consider adding:
- Message queue (RabbitMQ, Kafka)
- Event sourcing for audit trail
- CQRS pattern for complex domains

### GraphQL API

Consider when:
- Mobile app needs flexible queries
- Multiple clients with different needs
- Over-fetching/under-fetching problems
```

### 2. DATABASE.md

```markdown
# Database Architecture

## Schema Design

### Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    Users    │──────<│   Posts     │>──────│  Comments   │
│─────────────│  1:N  │─────────────│  1:N  │─────────────│
│ id          │       │ id          │       │ id          │
│ email       │       │ user_id     │       │ post_id     │
│ name        │       │ title       │       │ user_id     │
│ role        │       │ content     │       │ content     │
└─────────────┘       └─────────────┘       └─────────────┘
```

## Indexing Strategy

```sql
-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role) WHERE role IN ('admin', 'moderator');
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Posts table indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_status ON posts(status) WHERE status = 'published';
CREATE INDEX idx_posts_title_search ON posts USING gin(to_tsvector('english', title));

-- Comments table indexes
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
```

## Query Optimization

### Connection Pooling

```javascript
const pool = new Pool({
  max: 20, // Maximum connections
  min: 5,  // Minimum connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Prepared Statements

```javascript
// Use parameterized queries
const result = await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);
```

## Migration Strategy

```bash
# Create migration
npm run migrate:create add_users_table

# Run migrations
npm run migrate

# Rollback
npm run migrate:rollback
```

## Backup Strategy

- Daily automated backups
- Retention: 30 days
- Point-in-time recovery enabled
- Test restore monthly
```

## Generation Process

1. **Analyze System**
   - Review codebase structure
   - Identify architectural patterns
   - Document tech stack
   - Map data flow

2. **Create Diagrams**
   - System architecture
   - Component diagrams
   - Data flow
   - Deployment architecture

3. **Document Decisions**
   - Why certain technologies chosen
   - Trade-offs considered
   - Alternative approaches

4. **Keep Updated**
   - Update when architecture changes
   - Add ADRs for major decisions
   - Version architecture docs

## Best Practices

✅ Use diagrams liberally
✅ Document the "why" not just the "what"
✅ Include decision rationale
✅ Show data flow clearly
✅ Document security considerations
✅ Include scalability plans

## Anti-Patterns to Avoid

❌ Only documenting current state (include future plans)
❌ No diagrams (visual aids are essential)
❌ Missing decision rationale
❌ Outdated documentation
❌ Too much detail (keep high-level)