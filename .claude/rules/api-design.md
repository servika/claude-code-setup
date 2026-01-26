# API Design Guidelines

## REST Principles

- **Resource-oriented** - URLs represent resources, not actions
- **Stateless** - Each request contains all information needed
- **Consistent** - Same patterns across all endpoints
- **Self-documenting** - Clear naming and standard responses

## URL Naming Conventions

### Resource Naming

```
# Good - Plural nouns, lowercase, hyphens for multi-word
GET /api/users
GET /api/user-profiles
GET /api/order-items

# Bad - Verbs, camelCase, underscores
GET /api/getUsers
GET /api/userProfiles
GET /api/order_items
```

### URL Structure

```
/api/{version}/{resource}/{id}/{sub-resource}

# Examples
GET  /api/v1/users                    # List users
GET  /api/v1/users/123                # Get user 123
GET  /api/v1/users/123/orders         # Get user 123's orders
GET  /api/v1/users/123/orders/456     # Get order 456 for user 123
POST /api/v1/users/123/orders         # Create order for user 123
```

### Query Parameters

```
# Filtering
GET /api/users?status=active&role=admin

# Sorting (prefix with - for descending)
GET /api/users?sort=name
GET /api/users?sort=-created_at

# Pagination
GET /api/users?page=2&limit=20

# Field selection
GET /api/users?fields=id,name,email

# Search
GET /api/users?search=john

# Combined
GET /api/users?status=active&sort=-created_at&page=1&limit=20
```

## HTTP Methods

| Method | Usage | Idempotent | Request Body | Response Body |
|--------|-------|------------|--------------|---------------|
| GET | Retrieve resource(s) | Yes | No | Yes |
| POST | Create resource | No | Yes | Yes |
| PUT | Replace resource | Yes | Yes | Yes |
| PATCH | Partial update | Yes | Yes | Yes |
| DELETE | Remove resource | Yes | No | Optional |

### Method Examples

```javascript
// GET - Retrieve
GET /api/users/123
Response: 200 OK with user data

// POST - Create
POST /api/users
Body: { "email": "...", "name": "..." }
Response: 201 Created with new user data

// PUT - Full replacement
PUT /api/users/123
Body: { "email": "...", "name": "...", "role": "..." }
Response: 200 OK with updated user data

// PATCH - Partial update
PATCH /api/users/123
Body: { "name": "New Name" }
Response: 200 OK with updated user data

// DELETE - Remove
DELETE /api/users/123
Response: 204 No Content
```

## HTTP Status Codes

### Success Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |

### Client Error Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 400 | Bad Request | Invalid request body, validation error |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource, state conflict |
| 422 | Unprocessable Entity | Semantic validation error |
| 429 | Too Many Requests | Rate limit exceeded |

### Server Error Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 500 | Internal Server Error | Unexpected server error |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Server temporarily unavailable |
| 504 | Gateway Timeout | Upstream service timeout |

## Request/Response Patterns

### Standard Response Format

```javascript
// Success response
{
  "success": true,
  "data": { ... }  // Single object or array
}

// Success with pagination
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}

// Error response
{
  "success": false,
  "error": "Human-readable error message",
  "code": "ERROR_CODE",           // Machine-readable code
  "details": { ... }              // Optional: validation errors, etc.
}
```

### Validation Error Response

```javascript
// 400 Bad Request
{
  "success": false,
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": {
    "email": ["Invalid email format"],
    "password": ["Must be at least 8 characters"]
  }
}
```

### Resource Response

```javascript
// Single resource
{
  "success": true,
  "data": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

## Error Response Format

### Error Codes Convention

```javascript
// Naming: CATEGORY_SPECIFIC_ERROR
const ERROR_CODES = {
  // Authentication errors
  AUTH_INVALID_CREDENTIALS: 'Invalid email or password',
  AUTH_TOKEN_EXPIRED: 'Authentication token has expired',
  AUTH_TOKEN_INVALID: 'Invalid authentication token',

  // Authorization errors
  AUTHZ_FORBIDDEN: 'You do not have permission to perform this action',
  AUTHZ_RESOURCE_DENIED: 'Access to this resource is denied',

  // Validation errors
  VALIDATION_FAILED: 'Request validation failed',
  VALIDATION_INVALID_FORMAT: 'Invalid data format',

  // Resource errors
  RESOURCE_NOT_FOUND: 'The requested resource was not found',
  RESOURCE_ALREADY_EXISTS: 'A resource with this identifier already exists',
  RESOURCE_CONFLICT: 'Resource state conflict',

  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'Too many requests, please try again later',

  // Server errors
  INTERNAL_ERROR: 'An internal server error occurred',
  SERVICE_UNAVAILABLE: 'Service temporarily unavailable',
};
```

### Error Implementation

```javascript
// utils/api-error.js
export class ApiError extends Error {
  constructor(message, statusCode, code, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }

  toJSON() {
    return {
      success: false,
      error: this.message,
      code: this.code,
      ...(this.details && { details: this.details }),
    };
  }
}

// Usage
throw new ApiError(
  'User not found',
  404,
  'RESOURCE_NOT_FOUND'
);

throw new ApiError(
  'Validation failed',
  400,
  'VALIDATION_FAILED',
  { email: ['Invalid format'] }
);
```

## Pagination

### Offset-Based (Simple)

```javascript
// Request
GET /api/users?page=2&limit=20

// Response
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 100,
    "pages": 5,
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Cursor-Based (Large Datasets)

```javascript
// Request
GET /api/users?cursor=eyJpZCI6MTIzfQ&limit=20

// Response
{
  "success": true,
  "data": [...],
  "pagination": {
    "limit": 20,
    "nextCursor": "eyJpZCI6MTQzfQ",
    "prevCursor": "eyJpZCI6MTAzfQ",
    "hasNext": true,
    "hasPrev": true
  }
}
```

## Filtering and Sorting

### Filter Operators

```javascript
// Equality (default)
GET /api/products?status=active

// Comparison (use suffix)
GET /api/products?price_gte=100&price_lte=500

// Multiple values (OR)
GET /api/products?status=active,pending

// Operators:
// _gt   - greater than
// _gte  - greater than or equal
// _lt   - less than
// _lte  - less than or equal
// _ne   - not equal
// _like - contains (for strings)
```

### Sort Implementation

```javascript
// Single field
GET /api/users?sort=name         // ascending
GET /api/users?sort=-name        // descending

// Multiple fields
GET /api/users?sort=-created_at,name

// Implementation
function parseSort(sortParam) {
  if (!sortParam) return { createdAt: -1 }; // default

  return sortParam.split(',').reduce((acc, field) => {
    const isDesc = field.startsWith('-');
    const fieldName = isDesc ? field.slice(1) : field;
    acc[fieldName] = isDesc ? -1 : 1;
    return acc;
  }, {});
}
```

## API Versioning

### URL Path Versioning (Recommended)

```
/api/v1/users
/api/v2/users
```

### Implementation

```javascript
// routes/index.js
import v1Routes from './v1/index.js';
import v2Routes from './v2/index.js';

router.use('/v1', v1Routes);
router.use('/v2', v2Routes);

// Deprecation header for old versions
app.use('/api/v1', (req, res, next) => {
  res.set('Deprecation', 'true');
  res.set('Sunset', 'Sat, 01 Jan 2025 00:00:00 GMT');
  next();
});
```

### Version Migration Strategy

1. **Announce deprecation** - Set deprecation headers, update docs
2. **Overlap period** - Run both versions (minimum 6 months)
3. **Monitor usage** - Track v1 vs v2 traffic
4. **Sunset old version** - Remove after migration complete

## OpenAPI/Swagger Documentation

### OpenAPI Specification

```yaml
openapi: 3.0.3
info:
  title: User API
  version: 1.0.0
  description: User management API

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging

tags:
  - name: Users
    description: User management operations

paths:
  /users:
    get:
      tags: [Users]
      summary: List all users
      operationId: listUsers
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
            minimum: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            minimum: 1
            maximum: 100
        - name: status
          in: query
          schema:
            type: string
            enum: [active, inactive, pending]
        - name: sort
          in: query
          schema:
            type: string
            example: "-created_at"
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'

    post:
      tags: [Users]
      summary: Create a new user
      operationId: createUser
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/Conflict'

  /users/{id}:
    get:
      tags: [Users]
      summary: Get user by ID
      operationId: getUser
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '404':
          $ref: '#/components/responses/NotFound'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
        role:
          type: string
          enum: [user, admin]
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time

    CreateUserRequest:
      type: object
      required:
        - email
        - password
        - name
      properties:
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
        name:
          type: string
          minLength: 2
          maxLength: 100

    UserResponse:
      type: object
      properties:
        success:
          type: boolean
        data:
          $ref: '#/components/schemas/User'

    UserListResponse:
      type: object
      properties:
        success:
          type: boolean
        data:
          type: array
          items:
            $ref: '#/components/schemas/User'
        pagination:
          $ref: '#/components/schemas/Pagination'

    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        total:
          type: integer
        pages:
          type: integer

    ErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
        error:
          type: string
        code:
          type: string
        details:
          type: object

  responses:
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            success: false
            error: "Authentication required"
            code: "AUTH_REQUIRED"

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'

    ValidationError:
      description: Validation error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'

    Conflict:
      description: Resource conflict
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

## HATEOAS (Optional)

```javascript
// Response with links for discoverability
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "links": {
    "self": "/api/v1/users/123",
    "orders": "/api/v1/users/123/orders",
    "profile": "/api/v1/users/123/profile"
  }
}
```

## Checklist

### API Design

- [ ] URLs use plural nouns, lowercase, hyphens
- [ ] Correct HTTP methods for operations
- [ ] Consistent response format across all endpoints
- [ ] Proper status codes for all scenarios
- [ ] Pagination for list endpoints
- [ ] Filtering and sorting implemented
- [ ] Error responses include code and message

### Documentation

- [ ] OpenAPI spec complete and accurate
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Error codes documented
- [ ] Authentication requirements clear
- [ ] Versioning strategy documented
