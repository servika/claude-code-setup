# Backend Code Generator Agent

## Purpose
Generate production-ready Node.js/Express backend code following best practices, security standards, and architectural patterns.

## When to Invoke
- Creating new API endpoints
- Building new Express routes, controllers, services
- Implementing middleware
- Setting up authentication/authorization
- Creating database models and queries
- Building validation schemas
- Implementing error handling

## Generation Principles

### 1. Architecture Pattern
Follow layered architecture:
```
Routes → Controllers → Services → Data Access → Database
         ↓
    Middleware (auth, validation, error handling)
```

### 2. Code Quality Standards
- ESM modules (import/export)
- JSDoc on all functions
- Input validation at route level
- Error handling with try/catch
- Async/await (no callbacks)
- Security-first approach

### 3. Security Requirements
- Input sanitization
- SQL/NoSQL injection prevention
- Authentication & authorization
- Rate limiting on sensitive endpoints
- CORS configuration
- Helmet security headers
- No secrets in code

## Generation Templates

### API Endpoint (Full Stack)

#### 1. Route Definition
```javascript
/**
 * User management routes
 * Handles all user-related API endpoints
 */
import express from 'express';
import { body, param, query } from 'express-validator';
import { asyncHandler } from '../middleware/asyncHandler.js';
import { authenticate } from '../middleware/auth.js';
import { validate } from '../middleware/validation.js';
import * as userController from '../controllers/user.controller.js';

const router = express.Router();

/**
 * @route   GET /api/users
 * @desc    Get all users with pagination
 * @access  Private (Admin only)
 */
router.get(
  '/',
  authenticate,
  authorizeRoles('admin'),
  [
    query('page').optional().isInt({ min: 1 }).toInt(),
    query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
    query('search').optional().trim().escape(),
  ],
  validate,
  asyncHandler(userController.getUsers)
);

/**
 * @route   GET /api/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
router.get(
  '/:id',
  authenticate,
  [param('id').isMongoId()],
  validate,
  asyncHandler(userController.getUserById)
);

/**
 * @route   POST /api/users
 * @desc    Create new user
 * @access  Private (Admin only)
 */
router.post(
  '/',
  authenticate,
  authorizeRoles('admin'),
  [
    body('email').isEmail().normalizeEmail(),
    body('name').trim().isLength({ min: 2, max: 100 }),
    body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
    body('role').optional().isIn(['user', 'admin']),
  ],
  validate,
  asyncHandler(userController.createUser)
);

/**
 * @route   PUT /api/users/:id
 * @desc    Update user
 * @access  Private (Self or Admin)
 */
router.put(
  '/:id',
  authenticate,
  [
    param('id').isMongoId(),
    body('email').optional().isEmail().normalizeEmail(),
    body('name').optional().trim().isLength({ min: 2, max: 100 }),
  ],
  validate,
  asyncHandler(userController.updateUser)
);

/**
 * @route   DELETE /api/users/:id
 * @desc    Delete user
 * @access  Private (Admin only)
 */
router.delete(
  '/:id',
  authenticate,
  authorizeRoles('admin'),
  [param('id').isMongoId()],
  validate,
  asyncHandler(userController.deleteUser)
);

export default router;
```

#### 2. Controller
```javascript
/**
 * User controller
 * Handles user-related request processing
 */
import * as userService from '../services/user.service.js';
import { AppError } from '../utils/errors.js';
import logger from '../utils/logger.js';

/**
 * Get all users with pagination and filtering
 * @param {Object} req - Express request object
 * @param {Object} req.query - Query parameters
 * @param {number} [req.query.page=1] - Page number
 * @param {number} [req.query.limit=10] - Items per page
 * @param {string} [req.query.search] - Search term
 * @param {Object} res - Express response object
 * @returns {Promise<void>}
 */
export async function getUsers(req, res) {
  const { page = 1, limit = 10, search } = req.query;

  const result = await userService.getUsers({
    page: parseInt(page),
    limit: parseInt(limit),
    search,
  });

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
}

/**
 * Get user by ID
 * @param {Object} req - Express request object
 * @param {Object} req.params - Route parameters
 * @param {string} req.params.id - User ID
 * @param {Object} res - Express response object
 * @returns {Promise<void>}
 * @throws {AppError} When user not found
 */
export async function getUserById(req, res) {
  const { id } = req.params;

  const user = await userService.getUserById(id);

  if (!user) {
    throw new AppError('User not found', 404);
  }

  res.json({
    success: true,
    data: user,
  });
}

/**
 * Create new user
 * @param {Object} req - Express request object
 * @param {Object} req.body - Request body
 * @param {string} req.body.email - User email
 * @param {string} req.body.name - User name
 * @param {string} req.body.password - User password
 * @param {string} [req.body.role='user'] - User role
 * @param {Object} res - Express response object
 * @returns {Promise<void>}
 * @throws {AppError} When email already exists
 */
export async function createUser(req, res) {
  const { email, name, password, role } = req.body;

  // Check if user already exists
  const existingUser = await userService.getUserByEmail(email);
  if (existingUser) {
    throw new AppError('Email already registered', 409);
  }

  const user = await userService.createUser({
    email,
    name,
    password,
    role: role || 'user',
  });

  logger.info(`User created: ${user.id} by ${req.user.id}`);

  res.status(201).json({
    success: true,
    data: user,
  });
}

/**
 * Update user
 * @param {Object} req - Express request object
 * @param {Object} req.params - Route parameters
 * @param {string} req.params.id - User ID
 * @param {Object} req.body - Update data
 * @param {Object} res - Express response object
 * @returns {Promise<void>}
 * @throws {AppError} When user not found or unauthorized
 */
export async function updateUser(req, res) {
  const { id } = req.params;
  const updates = req.body;

  // Check authorization (can only update self unless admin)
  if (req.user.id !== id && req.user.role !== 'admin') {
    throw new AppError('Not authorized to update this user', 403);
  }

  const user = await userService.updateUser(id, updates);

  if (!user) {
    throw new AppError('User not found', 404);
  }

  logger.info(`User updated: ${id} by ${req.user.id}`);

  res.json({
    success: true,
    data: user,
  });
}

/**
 * Delete user
 * @param {Object} req - Express request object
 * @param {Object} req.params - Route parameters
 * @param {string} req.params.id - User ID
 * @param {Object} res - Express response object
 * @returns {Promise<void>}
 * @throws {AppError} When user not found
 */
export async function deleteUser(req, res) {
  const { id } = req.params;

  const deleted = await userService.deleteUser(id);

  if (!deleted) {
    throw new AppError('User not found', 404);
  }

  logger.info(`User deleted: ${id} by ${req.user.id}`);

  res.json({
    success: true,
    message: 'User deleted successfully',
  });
}
```

#### 3. Service Layer
```javascript
/**
 * User service
 * Business logic for user operations
 */
import bcrypt from 'bcrypt';
import { User } from '../models/user.model.js';
import { AppError } from '../utils/errors.js';

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
    ? {
        $or: [
          { name: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
        ],
      }
    : {};

  const [users, total] = await Promise.all([
    User.find(query)
      .select('-password')
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })
      .lean(),
    User.countDocuments(query),
  ]);

  return {
    users,
    page,
    limit,
    total,
    pages: Math.ceil(total / limit),
  };
}

/**
 * Get user by ID
 * @param {string} userId - User ID
 * @returns {Promise<Object|null>} User object or null
 */
export async function getUserById(userId) {
  const user = await User.findById(userId).select('-password').lean();
  return user;
}

/**
 * Get user by email
 * @param {string} email - User email
 * @returns {Promise<Object|null>} User object or null
 */
export async function getUserByEmail(email) {
  const user = await User.findOne({ email }).lean();
  return user;
}

/**
 * Create new user
 * @param {Object} userData - User data
 * @param {string} userData.email - User email
 * @param {string} userData.name - User name
 * @param {string} userData.password - Plain text password
 * @param {string} userData.role - User role
 * @returns {Promise<Object>} Created user (without password)
 * @throws {AppError} When creation fails
 */
export async function createUser(userData) {
  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(userData.password, salt);

  const user = await User.create({
    ...userData,
    password: hashedPassword,
  });

  // Return user without password
  const userObj = user.toObject();
  delete userObj.password;

  return userObj;
}

/**
 * Update user
 * @param {string} userId - User ID
 * @param {Object} updates - Update data
 * @returns {Promise<Object|null>} Updated user or null
 */
export async function updateUser(userId, updates) {
  // Don't allow password updates through this method
  delete updates.password;
  delete updates.role; // Role changes should be separate

  const user = await User.findByIdAndUpdate(
    userId,
    { $set: updates },
    { new: true, runValidators: true }
  )
    .select('-password')
    .lean();

  return user;
}

/**
 * Delete user
 * @param {string} userId - User ID
 * @returns {Promise<boolean>} True if deleted, false if not found
 */
export async function deleteUser(userId) {
  const result = await User.findByIdAndDelete(userId);
  return !!result;
}
```

#### 4. Middleware Examples

**Async Handler**
```javascript
/**
 * Wraps async route handlers to catch errors
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Express middleware
 */
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
```

**Authentication Middleware**
```javascript
/**
 * Authenticate user via JWT
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Next middleware
 * @returns {Promise<void>}
 * @throws {AppError} When authentication fails
 */
export async function authenticate(req, res, next) {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      throw new AppError('Authentication required', 401);
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password');

    if (!user) {
      throw new AppError('User not found', 401);
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      next(new AppError('Invalid token', 401));
    } else if (error.name === 'TokenExpiredError') {
      next(new AppError('Token expired', 401));
    } else {
      next(error);
    }
  }
}

/**
 * Authorize user by roles
 * @param {...string} roles - Allowed roles
 * @returns {Function} Express middleware
 */
export function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AppError('Access denied', 403));
    }

    next();
  };
}
```

**Validation Middleware**
```javascript
/**
 * Validate request using express-validator results
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Next middleware
 * @throws {AppError} When validation fails
 */
export function validate(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map((err) => ({
      field: err.param,
      message: err.msg,
    }));

    throw new AppError('Validation failed', 400, formattedErrors);
  }

  next();
}
```

**Error Handler**
```javascript
/**
 * Centralized error handling middleware
 * @param {Error} err - Error object
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Next middleware
 */
export function errorHandler(err, req, res, next) {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.error(err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map((e) => e.message);
    error = new AppError('Validation Error', 400, message);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    error = new AppError(`${field} already exists`, 409);
  }

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    error = new AppError('Resource not found', 404);
  }

  res.status(error.statusCode || 500).json({
    success: false,
    error: error.message || 'Server Error',
    ...(error.errors && { errors: error.errors }),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}
```

## Code Generation Checklist

When generating backend code, ensure:

- [ ] JSDoc comments on all functions
- [ ] Input validation with express-validator
- [ ] Authentication & authorization checks
- [ ] Async/await with try/catch or asyncHandler
- [ ] Proper HTTP status codes
- [ ] Sanitized inputs (escape, trim, normalize)
- [ ] No SQL/NoSQL injection vulnerabilities
- [ ] Rate limiting on sensitive endpoints
- [ ] Logging for important operations
- [ ] Error responses follow consistent format
- [ ] Passwords hashed with bcrypt (10+ rounds)
- [ ] No secrets in code (use environment variables)
- [ ] Database queries use indexes where appropriate
- [ ] Pagination for list endpoints
- [ ] Tests for all endpoints (unit + integration)

## Best Practices

1. **Layered Architecture**: Keep concerns separated (routes/controllers/services)
2. **DRY Principle**: Extract common logic into utilities/middleware
3. **Security First**: Validate all inputs, authenticate all private routes
4. **Consistent Responses**: Use standard response format across all endpoints
5. **Error Handling**: Use centralized error handler, custom error classes
6. **Logging**: Log important operations, errors, security events
7. **Testing**: Write tests alongside code, aim for 60%+ coverage
8. **Documentation**: JSDoc + auto-generated API docs

## Anti-Patterns to Avoid

❌ Mixing business logic in routes
❌ Direct database queries in controllers
❌ Missing input validation
❌ Hardcoded values (use config/env)
❌ Synchronous operations in async context
❌ console.log for production logging
❌ Exposing sensitive data in responses
❌ Missing error handling
❌ Callback hell (use async/await)
❌ No rate limiting on auth endpoints