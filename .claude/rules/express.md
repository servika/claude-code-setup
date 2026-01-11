---
pattern: "{routes,controllers,middleware,app,server}/**/*.{js,ts}"
---

# Express.js API Development Patterns

These rules apply to Express.js backend code including routes, controllers, middleware, and server setup.

## Project Structure

**Recommended Organization**
```
src/
├── app.js              # Express app setup
├── server.js           # Server startup
├── routes/             # Route definitions
│   ├── index.js        # Route aggregation
│   ├── users.routes.js
│   └── auth.routes.js
├── controllers/        # Request handlers
│   ├── users.controller.js
│   └── auth.controller.js
├── middleware/         # Custom middleware
│   ├── auth.middleware.js
│   ├── validation.middleware.js
│   └── error.middleware.js
├── services/           # Business logic
│   └── user.service.js
├── models/             # Data models
│   └── user.model.js
├── utils/              # Utilities
│   ├── logger.js
│   └── async-handler.js
└── config/             # Configuration
    └── database.js
```

## Separation of Concerns

**Routes → Controllers → Services → Data Access**

```javascript
// routes/users.routes.js - Route definitions only
import express from 'express';
import { getUser, createUser, updateUser } from '../controllers/users.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { validateUser } from '../middleware/validation.middleware.js';

const router = express.Router();

router.get('/:id', authenticate, getUser);
router.post('/', authenticate, validateUser, createUser);
router.put('/:id', authenticate, validateUser, updateUser);

export default router;

// controllers/users.controller.js - Request/response handling
import * as userService from '../services/user.service.js';

export async function getUser(req, res) {
  const user = await userService.getUserById(req.params.id);
  res.json(user);
}

export async function createUser(req, res) {
  const user = await userService.createUser(req.body);
  res.status(201).json(user);
}

// services/user.service.js - Business logic
import { User } from '../models/user.model.js';

export async function getUserById(id) {
  const user = await User.findById(id);
  if (!user) {
    throw new NotFoundError(`User ${id} not found`);
  }
  return user;
}

export async function createUser(userData) {
  // Business logic, validation, etc.
  return await User.create(userData);
}
```

## Error Handling

**Async Handler Wrapper**
- Wrap all async route handlers to catch errors automatically
- Pass errors to Express error handling middleware

```javascript
// utils/async-handler.js
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Usage in routes
import { asyncHandler } from '../utils/async-handler.js';

router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    throw new NotFoundError('User not found');
  }
  res.json(user);
}));
```

**Custom Error Classes**
```javascript
// utils/errors.js
export class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404);
  }
}

export class ValidationError extends AppError {
  constructor(message = 'Validation failed', errors = {}) {
    super(message, 400);
    this.errors = errors;
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
```

**Centralized Error Middleware**
```javascript
// middleware/error.middleware.js
export function errorHandler(err, req, res, next) {
  let { statusCode, message } = err;

  // Handle different error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = Object.values(err.errors).map(e => e.message).join(', ');
  }

  if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
  }

  // Log error
  logger.error('Error occurred', {
    message: err.message,
    stack: err.stack,
    statusCode,
    url: req.originalUrl,
    method: req.method,
  });

  // Response
  res.status(statusCode || 500).json({
    success: false,
    message: message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    ...(err.errors && { errors: err.errors })
  });
}

// In app.js - Mount as last middleware
app.use(errorHandler);
```

## Middleware Chain Order

**Critical: Middleware Order Matters**

```javascript
// app.js - Correct middleware order
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';

const app = express();

// 1. Security middleware (first)
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true
}));

// 2. Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api', limiter);

// 3. Compression
app.use(compression());

// 4. Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

// 5. Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 6. Static files (if needed)
app.use('/uploads', express.static('uploads'));

// 7. Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);

// 8. 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// 9. Error handler (must be last)
app.use(errorHandler);

export default app;
```

## Request Validation

**Input Validation Middleware**

```javascript
// Using Zod for validation
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(2).max(100)
});

export function validateUser(req, res, next) {
  try {
    req.body = userSchema.parse(req.body);
    next();
  } catch (error) {
    throw new ValidationError('Invalid user data', error.errors);
  }
}

// Or create a generic validation middleware
export function validate(schema) {
  return (req, res, next) => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      throw new ValidationError('Validation failed', error.errors);
    }
  };
}

// Usage
router.post('/users', validate(userSchema), createUser);
```

## Authentication & Authorization

**JWT Authentication Middleware**

```javascript
// middleware/auth.middleware.js
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

export function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      throw new UnauthorizedError('Authentication required');
    }

    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}

// Usage
router.delete('/users/:id',
  authenticate,
  authorize('admin', 'moderator'),
  deleteUser
);
```

## Response Patterns

**Consistent API Responses**

```javascript
// Success responses
res.status(200).json({
  success: true,
  data: user
});

res.status(201).json({
  success: true,
  data: newUser,
  message: 'User created successfully'
});

// List with pagination
res.status(200).json({
  success: true,
  data: users,
  pagination: {
    page: 1,
    limit: 10,
    total: 100,
    pages: 10
  }
});

// Error responses (handled by error middleware)
throw new ValidationError('Invalid input', { email: 'Email already exists' });
```

## Route Parameters & Query Strings

**Parameter Validation**

```javascript
// Validate URL parameters
router.param('id', (req, res, next, id) => {
  if (!isValidObjectId(id)) {
    throw new ValidationError('Invalid ID format');
  }
  next();
});

// Query string parsing and validation
router.get('/users', asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const sort = req.query.sort || 'createdAt';

  // Validate
  if (limit > 100) {
    throw new ValidationError('Limit cannot exceed 100');
  }

  const users = await userService.getUsers({ page, limit, sort });
  res.json({
    success: true,
    data: users
  });
}));
```

## Database Operations

**Transaction Support**

```javascript
// Example with transaction
export async function transferFunds(fromId, toId, amount) {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    await Account.updateOne(
      { _id: fromId },
      { $inc: { balance: -amount } },
      { session }
    );

    await Account.updateOne(
      { _id: toId },
      { $inc: { balance: amount } },
      { session }
    );

    await session.commitTransaction();
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}
```

## File Uploads

**Handling File Uploads with Multer**

```javascript
// middleware/upload.middleware.js
import multer from 'multer';
import path from 'path';

const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new ValidationError('Invalid file type'));
  }
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// Usage
router.post('/upload',
  authenticate,
  upload.single('file'),
  asyncHandler(async (req, res) => {
    res.json({
      success: true,
      file: req.file
    });
  })
);
```

## Security Best Practices

**Essential Security Middleware**

```javascript
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import xss from 'xss-clean';
import hpp from 'hpp';

// Helmet - Security headers
app.use(helmet());

// Sanitize data against NoSQL injection
app.use(mongoSanitize());

// Prevent XSS attacks
app.use(xss());

// Prevent HTTP parameter pollution
app.use(hpp());

// CORS configuration
app.use(cors({
  origin: function (origin, callback) {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

## Rate Limiting

**Implement Rate Limiting**

```javascript
import rateLimit from 'express-rate-limit';

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests from this IP, please try again later'
});

// Stricter rate limit for auth routes
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
  message: 'Too many login attempts, please try again later'
});

app.use('/api', apiLimiter);
app.use('/api/auth/login', authLimiter);
```

## Testing Express Routes

**Integration Testing**

```javascript
import request from 'supertest';
import app from '../app.js';

describe('POST /api/users', () => {
  it('should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User'
      })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id');
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'invalid-email',
        password: 'password123'
      })
      .expect(400);

    expect(response.body.success).toBe(false);
  });
});
```

## Performance Optimization

**Caching with Redis**

```javascript
import Redis from 'ioredis';
const redis = new Redis(process.env.REDIS_URL);

// Cache middleware
export function cache(duration = 300) {
  return async (req, res, next) => {
    const key = `cache:${req.originalUrl}`;

    try {
      const cached = await redis.get(key);
      if (cached) {
        return res.json(JSON.parse(cached));
      }

      // Store original res.json function
      const originalJson = res.json.bind(res);

      // Override res.json to cache response
      res.json = (data) => {
        redis.setex(key, duration, JSON.stringify(data));
        return originalJson(data);
      };

      next();
    } catch (error) {
      next(); // Continue without cache on error
    }
  };
}

// Usage
router.get('/posts', cache(300), asyncHandler(getPosts));
```

**Database Connection Pooling**
```javascript
// Ensure connection pooling is configured
// For PostgreSQL with pg
const pool = new Pool({
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// For MongoDB with Mongoose
mongoose.connect(process.env.DATABASE_URL, {
  maxPoolSize: 10,
  minPoolSize: 2
});
```