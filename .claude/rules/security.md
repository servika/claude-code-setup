# Security Best Practices

## OWASP Top 10 Prevention

| Vulnerability | Prevention |
|--------------|------------|
| Injection | Parameterized queries, input validation |
| Broken Auth | Secure password hashing, JWT best practices |
| Sensitive Data Exposure | HTTPS, encryption at rest, no secrets in code |
| XXE | Disable XML external entities |
| Broken Access Control | Middleware authorization, ownership checks |
| Security Misconfiguration | Helmet, secure defaults, env validation |
| XSS | React auto-escaping, sanitize user HTML |
| Insecure Deserialization | Validate and sanitize all input |
| Vulnerable Components | Regular `npm audit`, dependabot |
| Insufficient Logging | Structured logging, no sensitive data in logs |

## Input Validation (Zod)

```javascript
import { z } from 'zod';

// Define strict schemas
const userSchema = z.object({
  email: z.string()
    .email('Invalid email format')
    .max(255, 'Email too long')
    .toLowerCase(),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .max(128, 'Password too long')
    .regex(/[A-Z]/, 'Password must contain uppercase letter')
    .regex(/[0-9]/, 'Password must contain number'),
  name: z.string()
    .min(2, 'Name too short')
    .max(100, 'Name too long')
    .trim(),
  role: z.enum(['user', 'admin']).default('user'),
});

// Validate at API boundary
export function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      throw new ValidationError('Validation failed', result.error.flatten());
    }
    req.body = result.data; // Use parsed data (transformed/sanitized)
    next();
  };
}

// ID validation
const idSchema = z.string().uuid('Invalid ID format');

// Query params validation
const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().max(100).optional(),
});
```

## SQL Injection Prevention

```javascript
// NEVER - String concatenation
const query = `SELECT * FROM users WHERE email = '${email}'`;

// NEVER - Template literals with user input
const query = `SELECT * FROM users WHERE id = ${id}`;

// GOOD - Parameterized queries (node-postgres)
const query = 'SELECT * FROM users WHERE email = $1';
const result = await pool.query(query, [email]);

// GOOD - Parameterized queries (mysql2)
const query = 'SELECT * FROM users WHERE email = ?';
const [rows] = await connection.execute(query, [email]);

// GOOD - ORM (Prisma)
const user = await prisma.user.findUnique({
  where: { email },
});

// GOOD - ORM (Sequelize)
const user = await User.findOne({
  where: { email },
});

// GOOD - Query builder (Knex)
const user = await knex('users').where({ email }).first();
```

## Password Security

```javascript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12; // Minimum 10, recommended 12+

/**
 * Hashes a password securely
 * @param {string} password - Plain text password
 * @returns {Promise<string>} Hashed password
 */
export async function hashPassword(password) {
  return bcrypt.hash(password, SALT_ROUNDS);
}

/**
 * Verifies password against hash
 * @param {string} password - Plain text password
 * @param {string} hash - Stored hash
 * @returns {Promise<boolean>} True if matches
 */
export async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
}

// Usage in registration
async function registerUser(data) {
  const hashedPassword = await hashPassword(data.password);
  const user = await User.create({
    ...data,
    password: hashedPassword,
  });

  // Never return password
  const { password, ...userWithoutPassword } = user.toObject();
  return userWithoutPassword;
}

// Usage in login
async function login(email, password) {
  const user = await User.findOne({ email });

  if (!user) {
    // Use same response to prevent user enumeration
    throw new UnauthorizedError('Invalid credentials');
  }

  const valid = await verifyPassword(password, user.password);

  if (!valid) {
    throw new UnauthorizedError('Invalid credentials');
  }

  return generateToken(user);
}
```

## JWT Security

```javascript
import jwt from 'jsonwebtoken';

// Environment validation
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}

const JWT_CONFIG = {
  accessToken: {
    expiresIn: '15m',  // Short-lived
    algorithm: 'HS256',
  },
  refreshToken: {
    expiresIn: '7d',
    algorithm: 'HS256',
  },
};

/**
 * Generates access token
 * @param {Object} user - User object
 * @returns {string} JWT token
 */
export function generateAccessToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
    },
    process.env.JWT_SECRET,
    JWT_CONFIG.accessToken
  );
}

/**
 * Generates refresh token
 * @param {Object} user - User object
 * @returns {string} JWT token
 */
export function generateRefreshToken(user) {
  return jwt.sign(
    { id: user.id },
    process.env.JWT_REFRESH_SECRET,
    JWT_CONFIG.refreshToken
  );
}

/**
 * Verifies and decodes token
 * @param {string} token - JWT token
 * @returns {Object} Decoded payload
 * @throws {UnauthorizedError} On invalid token
 */
export function verifyToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new UnauthorizedError('Token expired');
    }
    throw new UnauthorizedError('Invalid token');
  }
}
```

## Authentication Middleware

```javascript
/**
 * Authenticates requests via JWT
 */
export function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.slice(7);
  req.user = verifyToken(token);
  next();
}

/**
 * Authorizes specific roles
 * @param {...string} roles - Allowed roles
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

/**
 * Checks resource ownership
 * @param {Function} getOwnerId - Function to get owner ID from request
 */
export function requireOwnership(getOwnerId) {
  return async (req, res, next) => {
    const ownerId = await getOwnerId(req);
    if (ownerId !== req.user.id && req.user.role !== 'admin') {
      throw new ForbiddenError('Not authorized to access this resource');
    }
    next();
  };
}
```

## Security Headers (Helmet)

```javascript
import helmet from 'helmet';

app.use(helmet());

// Custom CSP for React apps
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"], // MUI needs inline styles
    imgSrc: ["'self'", "data:", "https:"],
    connectSrc: ["'self'", process.env.API_URL],
    fontSrc: ["'self'", "https://fonts.gstatic.com"],
    objectSrc: ["'none'"],
    upgradeInsecureRequests: [],
  },
}));

// Additional headers
app.use(helmet.hsts({
  maxAge: 31536000,
  includeSubDomains: true,
  preload: true,
}));
```

## CORS Configuration

```javascript
import cors from 'cors';

const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];

    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400, // 24 hours
};

app.use(cors(corsOptions));
```

## Rate Limiting

```javascript
import rateLimit from 'express-rate-limit';

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: { error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true, // Only count failures
  message: { error: 'Too many login attempts, please try again later' },
});

// Password reset limit
const resetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3,
  message: { error: 'Too many reset attempts' },
});

app.use('/api', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/api/auth/reset-password', resetLimiter);
```

## Cookie Security

```javascript
// Secure cookie settings
const cookieOptions = {
  httpOnly: true,      // Prevents JavaScript access
  secure: true,        // HTTPS only (set false in development)
  sameSite: 'strict',  // CSRF protection
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  path: '/',
};

// Set refresh token in cookie
res.cookie('refreshToken', refreshToken, cookieOptions);

// Clear cookie on logout
res.clearCookie('refreshToken', {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
});
```

## Secrets Management

```javascript
// config/index.js

// Required environment variables
const requiredEnvVars = [
  'DATABASE_URL',
  'JWT_SECRET',
  'JWT_REFRESH_SECRET',
];

// Validate at startup
export function validateEnv() {
  const missing = requiredEnvVars.filter(key => !process.env[key]);
  if (missing.length) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`);
  }

  if (process.env.JWT_SECRET.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters');
  }
}

// .gitignore
// .env
// .env.local
// .env.*.local
// *.pem
// *.key
```

## Logging (No Sensitive Data)

```javascript
/**
 * Sanitizes object for logging
 * @param {Object} obj - Object to sanitize
 * @returns {Object} Sanitized object
 */
function sanitize(obj) {
  if (!obj || typeof obj !== 'object') return obj;

  const sensitiveFields = [
    'password',
    'token',
    'secret',
    'authorization',
    'cookie',
    'creditCard',
    'ssn',
  ];

  const sanitized = { ...obj };

  for (const field of sensitiveFields) {
    if (field in sanitized) {
      sanitized[field] = '[REDACTED]';
    }
  }

  return sanitized;
}

// Usage
logger.info('User created', sanitize(userData));
logger.error('Login failed', { email: user.email }); // No password
```

## XSS Prevention (React)

```javascript
// React escapes by default - SAFE
<div>{user.name}</div>
<input value={searchQuery} />

// DANGEROUS - Only use with sanitized content
import DOMPurify from 'dompurify';

function RichContent({ html }) {
  const sanitizedHtml = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
    ALLOWED_ATTR: ['href'],
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitizedHtml }} />;
}

// NEVER trust user input in URLs
// Bad
<a href={userProvidedUrl}>Link</a>

// Good
function SafeLink({ url, children }) {
  const isValid = url.startsWith('https://') || url.startsWith('/');
  if (!isValid) return <span>{children}</span>;
  return <a href={url}>{children}</a>;
}
```

## File Upload Security

```javascript
import multer from 'multer';
import path from 'path';

const ALLOWED_TYPES = /jpeg|jpg|png|gif|pdf/;
const MAX_SIZE = 5 * 1024 * 1024; // 5MB

const upload = multer({
  storage: multer.diskStorage({
    destination: './uploads',
    filename: (req, file, cb) => {
      // Generate unique filename
      const uniqueName = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
      const ext = path.extname(file.originalname).toLowerCase();
      cb(null, `${uniqueName}${ext}`);
    },
  }),
  limits: {
    fileSize: MAX_SIZE,
  },
  fileFilter: (req, file, cb) => {
    const extValid = ALLOWED_TYPES.test(path.extname(file.originalname).toLowerCase());
    const mimeValid = ALLOWED_TYPES.test(file.mimetype);

    if (extValid && mimeValid) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  },
});
```

## Dependency Security

```bash
# Check for vulnerabilities
npm audit

# Fix automatically where possible
npm audit fix

# Check outdated packages
npm outdated

# Update packages
npm update
```

```json
// package.json - Use dependabot or renovate
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix"
  }
}
```

## Security Checklist

### Backend
- [ ] Input validation on all endpoints (Zod)
- [ ] Parameterized database queries
- [ ] Passwords hashed with bcrypt (12+ rounds)
- [ ] JWT secret minimum 32 characters
- [ ] Short access token expiry (15m)
- [ ] Rate limiting on auth endpoints
- [ ] Helmet middleware enabled
- [ ] CORS properly configured
- [ ] httpOnly, secure, sameSite cookies
- [ ] No secrets in code or version control
- [ ] Sensitive data excluded from logs
- [ ] File uploads validated and limited
- [ ] Regular `npm audit`

### Frontend
- [ ] No secrets in frontend code
- [ ] User-generated HTML sanitized (DOMPurify)
- [ ] Auth tokens in httpOnly cookies
- [ ] API responses validated
- [ ] Links validated before rendering
- [ ] No eval() or innerHTML with user data

### Infrastructure
- [ ] HTTPS everywhere
- [ ] Security headers configured
- [ ] Environment variables for secrets
- [ ] Database credentials secured
- [ ] Audit logging enabled