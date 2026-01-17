# Backend Development (Node.js + Express)

## Project Structure

```
src/
├── app.js                 # Express app configuration
├── server.js              # Server startup and graceful shutdown
├── routes/                # Route definitions
│   ├── index.js           # Route aggregator
│   ├── auth.routes.js
│   └── users.routes.js
├── controllers/           # Request handlers
│   ├── auth.controller.js
│   └── users.controller.js
├── services/              # Business logic
│   ├── auth.service.js
│   └── user.service.js
├── middleware/            # Custom middleware
│   ├── auth.middleware.js
│   ├── validate.middleware.js
│   └── error.middleware.js
├── models/                # Data models/schemas
├── utils/                 # Utilities
│   ├── async-handler.js
│   ├── errors.js
│   └── logger.js
├── config/                # Configuration
│   └── index.js
└── validators/            # Zod schemas
    ├── auth.validator.js
    └── user.validator.js
```

## Architecture Pattern

```
Request → Routes → Middleware → Controllers → Services → Data Access → Response
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| Routes | URL mapping, middleware chain |
| Controllers | Request parsing, response formatting |
| Services | Business logic, orchestration |
| Data Access | Database operations |

## Express App Setup

```javascript
// app.js
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { errorHandler, notFoundHandler } from './middleware/error.middleware.js';
import routes from './routes/index.js';
import { logger } from './utils/logger.js';

const app = express();

// 1. Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true,
}));

// 2. Rate limiting
app.use('/api', rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: { error: 'Too many requests, please try again later' },
}));

// 3. Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 4. Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// 5. API routes
app.use('/api', routes);

// 6. Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 7. 404 handler
app.use(notFoundHandler);

// 8. Error handler (MUST be last)
app.use(errorHandler);

export default app;
```

## Server Startup

```javascript
// server.js
import app from './app.js';
import { logger } from './utils/logger.js';
import { validateEnv } from './config/index.js';

const PORT = process.env.PORT || 3001;

// Validate environment variables before starting
validateEnv();

const server = app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});

// Graceful shutdown
const shutdown = async (signal) => {
  logger.info(`${signal} received, shutting down gracefully`);
  server.close(async () => {
    logger.info('HTTP server closed');
    // Close database connections, etc.
    process.exit(0);
  });

  // Force shutdown after 30s
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
```

## Error Handling

### Custom Error Classes

```javascript
// utils/errors.js

/**
 * Base application error
 */
export class AppError extends Error {
  /**
   * @param {string} message - Error message
   * @param {number} statusCode - HTTP status code
   */
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class BadRequestError extends AppError {
  constructor(message = 'Bad request') {
    super(message, 400);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403);
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'Not found') {
    super(message, 404);
  }
}

export class ConflictError extends AppError {
  constructor(message = 'Conflict') {
    super(message, 409);
  }
}

export class ValidationError extends AppError {
  /**
   * @param {string} message - Error message
   * @param {Object} errors - Validation errors object
   */
  constructor(message = 'Validation failed', errors = {}) {
    super(message, 400);
    this.errors = errors;
  }
}
```

### Async Handler

```javascript
// utils/async-handler.js

/**
 * Wraps async route handlers to catch errors
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Express middleware function
 */
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
```

### Error Middleware

```javascript
// middleware/error.middleware.js
import { logger } from '../utils/logger.js';

/**
 * 404 Not Found handler
 */
export function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: `Cannot ${req.method} ${req.path}`,
  });
}

/**
 * Global error handler middleware
 */
export function errorHandler(err, req, res, next) {
  logger.error({
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  // Zod validation errors
  if (err.name === 'ZodError') {
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: err.errors,
    });
  }

  // Known operational errors
  if (err.isOperational) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message,
      ...(err.errors && { details: err.errors }),
    });
  }

  // Unknown errors (don't leak details in production)
  res.status(500).json({
    success: false,
    error: process.env.NODE_ENV === 'development'
      ? err.message
      : 'Internal server error',
  });
}
```

## Routes

```javascript
// routes/index.js
import { Router } from 'express';
import authRoutes from './auth.routes.js';
import userRoutes from './users.routes.js';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);

export default router;
```

```javascript
// routes/users.routes.js
import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { createUserSchema, updateUserSchema } from '../validators/user.validator.js';
import * as userController from '../controllers/users.controller.js';

const router = Router();

router.get('/', authenticate, userController.getUsers);
router.get('/:id', authenticate, userController.getUser);
router.post('/', authenticate, authorize('admin'), validate(createUserSchema), userController.createUser);
router.put('/:id', authenticate, validate(updateUserSchema), userController.updateUser);
router.delete('/:id', authenticate, authorize('admin'), userController.deleteUser);

export default router;
```

## Controllers

```javascript
// controllers/users.controller.js
import { asyncHandler } from '../utils/async-handler.js';
import * as userService from '../services/user.service.js';

/**
 * Get all users
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 */
export const getUsers = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, search } = req.query;
  const result = await userService.getUsers({ page, limit, search });

  res.json({
    success: true,
    data: result.users,
    pagination: {
      page: result.page,
      limit: result.limit,
      total: result.total,
      pages: result.pages,
    },
  });
});

/**
 * Get single user by ID
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 */
export const getUser = asyncHandler(async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  res.json({ success: true, data: user });
});

/**
 * Create new user
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 */
export const createUser = asyncHandler(async (req, res) => {
  const user = await userService.createUser(req.body);
  res.status(201).json({ success: true, data: user });
});

/**
 * Update user
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 */
export const updateUser = asyncHandler(async (req, res) => {
  const user = await userService.updateUser(req.params.id, req.body, req.user);
  res.json({ success: true, data: user });
});

/**
 * Delete user
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 */
export const deleteUser = asyncHandler(async (req, res) => {
  await userService.deleteUser(req.params.id);
  res.status(204).send();
});
```

## Services

```javascript
// services/user.service.js
import { NotFoundError, ConflictError, ForbiddenError } from '../utils/errors.js';
import { User } from '../models/user.model.js';

/**
 * Get paginated users list
 * @param {Object} options - Query options
 * @param {number} options.page - Page number
 * @param {number} options.limit - Items per page
 * @param {string} [options.search] - Search term
 * @returns {Promise<Object>} Paginated users result
 */
export async function getUsers({ page, limit, search }) {
  const skip = (page - 1) * limit;
  const query = search
    ? { name: { $regex: search, $options: 'i' } }
    : {};

  const [users, total] = await Promise.all([
    User.find(query).skip(skip).limit(limit),
    User.countDocuments(query),
  ]);

  return {
    users,
    page: Number(page),
    limit: Number(limit),
    total,
    pages: Math.ceil(total / limit),
  };
}

/**
 * Get user by ID
 * @param {string} id - User ID
 * @returns {Promise<Object>} User object
 * @throws {NotFoundError} When user not found
 */
export async function getUserById(id) {
  const user = await User.findById(id);
  if (!user) {
    throw new NotFoundError(`User ${id} not found`);
  }
  return user;
}

/**
 * Create new user
 * @param {Object} data - User data
 * @returns {Promise<Object>} Created user
 * @throws {ConflictError} When email already exists
 */
export async function createUser(data) {
  const existing = await User.findOne({ email: data.email });
  if (existing) {
    throw new ConflictError('Email already registered');
  }
  return User.create(data);
}

/**
 * Update user
 * @param {string} id - User ID
 * @param {Object} data - Update data
 * @param {Object} requestUser - Requesting user
 * @returns {Promise<Object>} Updated user
 * @throws {NotFoundError} When user not found
 * @throws {ForbiddenError} When not authorized
 */
export async function updateUser(id, data, requestUser) {
  const user = await getUserById(id);

  // Users can only update themselves unless admin
  if (id !== requestUser.id && requestUser.role !== 'admin') {
    throw new ForbiddenError('Not authorized to update this user');
  }

  Object.assign(user, data);
  return user.save();
}

/**
 * Delete user
 * @param {string} id - User ID
 * @throws {NotFoundError} When user not found
 */
export async function deleteUser(id) {
  const user = await User.findByIdAndDelete(id);
  if (!user) {
    throw new NotFoundError(`User ${id} not found`);
  }
}
```

## Validation Middleware

```javascript
// middleware/validate.middleware.js
import { ValidationError } from '../utils/errors.js';

/**
 * Creates validation middleware for Zod schema
 * @param {import('zod').ZodSchema} schema - Zod schema
 * @returns {Function} Express middleware
 */
export function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      throw new ValidationError('Validation failed', result.error.flatten().fieldErrors);
    }
    req.body = result.data;
    next();
  };
}

/**
 * Validates query parameters
 * @param {import('zod').ZodSchema} schema - Zod schema
 * @returns {Function} Express middleware
 */
export function validateQuery(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      throw new ValidationError('Invalid query parameters', result.error.flatten().fieldErrors);
    }
    req.query = result.data;
    next();
  };
}
```

```javascript
// validators/user.validator.js
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2, 'Name must be at least 2 characters').max(100),
  role: z.enum(['user', 'admin']).default('user'),
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
}).refine(data => Object.keys(data).length > 0, {
  message: 'At least one field must be provided',
});
```

## Authentication Middleware

```javascript
// middleware/auth.middleware.js
import jwt from 'jsonwebtoken';
import { UnauthorizedError, ForbiddenError } from '../utils/errors.js';

/**
 * Authenticates JWT token from Authorization header
 * @param {Request} req - Express request
 * @param {Response} res - Express response
 * @param {Function} next - Next middleware
 */
export function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.slice(7);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new UnauthorizedError('Token expired');
    }
    throw new UnauthorizedError('Invalid token');
  }
}

/**
 * Authorizes user roles
 * @param {...string} roles - Allowed roles
 * @returns {Function} Express middleware
 */
export function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      throw new UnauthorizedError('Not authenticated');
    }
    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }
    next();
  };
}
```

## Environment Configuration

```javascript
// config/index.js
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.string().default('3001'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  JWT_EXPIRES_IN: z.string().default('1h'),
  ALLOWED_ORIGINS: z.string().optional(),
});

/**
 * Validates environment variables
 * @throws {Error} When validation fails
 */
export function validateEnv() {
  const result = envSchema.safeParse(process.env);
  if (!result.success) {
    console.error('Environment validation failed:');
    console.error(result.error.flatten().fieldErrors);
    process.exit(1);
  }
}

export const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3001', 10),
  dbUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '1h',
  isDev: process.env.NODE_ENV === 'development',
  isProd: process.env.NODE_ENV === 'production',
};
```

## Logger

```javascript
// utils/logger.js

const levels = { error: 0, warn: 1, info: 2, debug: 3 };
const currentLevel = process.env.LOG_LEVEL || 'info';

/**
 * Simple structured logger
 */
export const logger = {
  error: (message, meta = {}) => log('error', message, meta),
  warn: (message, meta = {}) => log('warn', message, meta),
  info: (message, meta = {}) => log('info', message, meta),
  debug: (message, meta = {}) => log('debug', message, meta),
};

function log(level, message, meta) {
  if (levels[level] > levels[currentLevel]) return;

  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message: typeof message === 'string' ? message : JSON.stringify(message),
    ...meta,
  };

  const output = process.env.NODE_ENV === 'production'
    ? JSON.stringify(entry)
    : `[${entry.timestamp}] ${level.toUpperCase()}: ${entry.message}`;

  if (level === 'error') {
    console.error(output);
  } else {
    console.log(output);
  }
}
```

## Response Patterns

```javascript
// Success responses
res.json({ success: true, data: user });
res.status(201).json({ success: true, data: newUser });
res.json({ success: true, data: users, pagination: { page, limit, total } });
res.status(204).send(); // No content

// Error responses (handled by error middleware)
throw new NotFoundError('User not found');
throw new ValidationError('Invalid data', { email: ['Invalid format'] });
```

## Checklist

Before completing backend work:

- [ ] All routes use asyncHandler wrapper
- [ ] Input validation with Zod on all endpoints
- [ ] JSDoc on all functions
- [ ] Parameterized queries (no SQL injection)
- [ ] JWT secret minimum 32 characters
- [ ] Rate limiting on auth endpoints
- [ ] Error handler is LAST middleware
- [ ] Proper HTTP status codes
- [ ] Consistent response format
- [ ] Environment variables validated at startup
- [ ] Graceful shutdown implemented
- [ ] No `console.log` (use logger)