---
pattern: "**/*.{js,ts,jsx,tsx}"
---

# Security Best Practices

These security guidelines apply to all code in the project, with special attention to backend APIs and user input handling.

## Input Validation

**Always Validate User Input**
- Never trust client-side data
- Validate at API boundaries (route entry points)
- Use validation libraries (Zod, Joi, express-validator)
- Whitelist allowed values, don't blacklist

```javascript
import { z } from 'zod';

// Good: Schema validation
const userSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(128),
  age: z.number().int().min(13).max(120),
  role: z.enum(['user', 'admin', 'moderator'])
});

router.post('/users', async (req, res) => {
  try {
    const validatedData = userSchema.parse(req.body);
    const user = await createUser(validatedData);
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Bad: No validation
router.post('/users', async (req, res) => {
  const user = await createUser(req.body); // ❌ Trusting client data
  res.json(user);
});
```

**Sanitize Input**

```javascript
import validator from 'validator';
import mongoSanitize from 'express-mongo-sanitize';
import xss from 'xss-clean';

// Middleware to prevent NoSQL injection and XSS
app.use(express.json());
app.use(mongoSanitize());
app.use(xss());

// Manual sanitization
function sanitizeEmail(email) {
  return validator.normalizeEmail(email);
}

function sanitizeString(str) {
  return validator.escape(str.trim());
}
```

## SQL Injection Prevention

**Use Parameterized Queries**

```javascript
// Bad: String concatenation (SQL injection vulnerable)
const query = `SELECT * FROM users WHERE email = '${email}'`; // ❌
db.query(query);

// Good: Parameterized queries
const query = 'SELECT * FROM users WHERE email = ?';
db.query(query, [email]);

// Good: With pg (PostgreSQL)
const query = 'SELECT * FROM users WHERE email = $1';
await pool.query(query, [email]);

// Good: ORM with parameterization
const user = await User.findOne({ where: { email } });
```

## NoSQL Injection Prevention

**Validate MongoDB Queries**

```javascript
// Bad: Direct use of user input
const user = await User.findOne({ email: req.body.email }); // ❌

// Vulnerable to: { "email": { "$ne": null } }

// Good: Validate and sanitize
const email = z.string().email().parse(req.body.email);
const user = await User.findOne({ email });

// Use express-mongo-sanitize middleware
import mongoSanitize from 'express-mongo-sanitize';
app.use(mongoSanitize()); // Removes $ and . from user input
```

## Cross-Site Scripting (XSS) Prevention

**Escape Output**

```javascript
// React automatically escapes content
function UserProfile({ user }) {
  // Safe: React escapes by default
  return <div>{user.name}</div>;

  // Dangerous: dangerouslySetInnerHTML bypasses escaping
  return <div dangerouslySetInnerHTML={{ __html: user.bio }} />; // ❌

  // If you must use HTML, sanitize first
  import DOMPurify from 'dompurify';
  const sanitized = DOMPurify.sanitize(user.bio);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />; // ✓
}
```

**Content Security Policy**

```javascript
import helmet from 'helmet';

app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"], // Avoid 'unsafe-inline' in production
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "https:"],
    connectSrc: ["'self'", "https://api.example.com"],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    upgradeInsecureRequests: [],
  }
}));
```

## Authentication & Authorization

**Hash Passwords**

```javascript
import bcrypt from 'bcrypt';

// Good: Hash passwords before storing
async function createUser(userData) {
  const saltRounds = 12;
  const hashedPassword = await bcrypt.hash(userData.password, saltRounds);

  return await db.users.create({
    ...userData,
    password: hashedPassword
  });
}

// Verify password
async function verifyPassword(plainPassword, hashedPassword) {
  return await bcrypt.compare(plainPassword, hashedPassword);
}

// Bad: Storing plain text passwords
async function createUser(userData) {
  return await db.users.create(userData); // ❌ Password in plain text
}
```

**Secure JWT Implementation**

```javascript
import jwt from 'jsonwebtoken';

// Good: Secure JWT configuration
const JWT_SECRET = process.env.JWT_SECRET; // Strong, random secret
const JWT_EXPIRES_IN = '1h'; // Short expiration
const REFRESH_TOKEN_EXPIRES_IN = '7d';

if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}

function generateAccessToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN, algorithm: 'HS256' }
  );
}

function generateRefreshToken(user) {
  return jwt.sign(
    { id: user.id },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
  );
}

// Verify token
function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET, { algorithms: ['HS256'] });
  } catch (error) {
    throw new UnauthorizedError('Invalid token');
  }
}

// Bad: Weak configuration
const token = jwt.sign({ id: user.id }, 'secret123'); // ❌ Weak secret, no expiration
```

**Authorization Checks**

```javascript
// Good: Check authorization at every protected route
router.delete('/users/:id', authenticate, async (req, res) => {
  const requestedUserId = req.params.id;
  const currentUserId = req.user.id;
  const currentUserRole = req.user.role;

  // Users can only delete their own account, admins can delete any
  if (requestedUserId !== currentUserId && currentUserRole !== 'admin') {
    throw new ForbiddenError('Not authorized to delete this user');
  }

  await deleteUser(requestedUserId);
  res.status(204).send();
});

// Bad: No authorization check
router.delete('/users/:id', authenticate, async (req, res) => {
  await deleteUser(req.params.id); // ❌ Any authenticated user can delete any user
  res.status(204).send();
});
```

## Secrets Management

**Environment Variables**

```javascript
// Good: Use environment variables for secrets
import dotenv from 'dotenv';
dotenv.config();

const config = {
  dbUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  apiKey: process.env.API_KEY,
};

// Validate required secrets at startup
const requiredEnvVars = ['DATABASE_URL', 'JWT_SECRET', 'API_KEY'];
const missingVars = requiredEnvVars.filter(key => !process.env[key]);

if (missingVars.length > 0) {
  throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
}

// Bad: Hardcoded secrets
const config = {
  dbUrl: 'postgresql://user:password@localhost:5432/db', // ❌
  jwtSecret: 'my-secret-key', // ❌
  apiKey: 'sk-1234567890' // ❌
};
```

**.env File Management**

```bash
# .env (never commit this file!)
DATABASE_URL=postgresql://user:password@localhost:5432/db
JWT_SECRET=your-super-secret-key-min-32-chars
API_KEY=your-api-key

# .env.example (commit this as a template)
DATABASE_URL=
JWT_SECRET=
API_KEY=
```

```gitignore
# .gitignore
.env
.env.local
.env.*.local
```

**Redact Secrets from Logs**

```javascript
function sanitizeForLogging(obj) {
  const sensitiveKeys = ['password', 'token', 'secret', 'apiKey', 'authorization'];

  return Object.fromEntries(
    Object.entries(obj).map(([key, value]) => {
      if (sensitiveKeys.some(k => key.toLowerCase().includes(k))) {
        return [key, '[REDACTED]'];
      }
      return [key, value];
    })
  );
}

// Usage
logger.info('User created', sanitizeForLogging(userData));
```

## Rate Limiting

**Prevent Brute Force Attacks**

```javascript
import rateLimit from 'express-rate-limit';

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max 100 requests per window
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // Max 5 login attempts
  skipSuccessfulRequests: true, // Don't count successful logins
  message: 'Too many login attempts, please try again later'
});

app.use('/api', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
```

## CORS Configuration

**Configure CORS Properly**

```javascript
import cors from 'cors';

// Bad: Allow all origins
app.use(cors()); // ❌

// Good: Whitelist specific origins
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [
  'http://localhost:3000',
  'https://yourdomain.com'
];

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true, // Allow cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

## Security Headers

**Use Helmet for Security Headers**

```javascript
import helmet from 'helmet';

app.use(helmet()); // Applies sensible defaults

// Or configure individually
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"]
  }
}));
app.use(helmet.hsts({ maxAge: 31536000, includeSubDomains: true }));
app.use(helmet.noSniff());
app.use(helmet.xssFilter());
app.use(helmet.frameguard({ action: 'deny' }));
```

## File Upload Security

**Validate File Uploads**

```javascript
import multer from 'multer';
import path from 'path';

const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1E9)}`;
    cb(null, `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const fileFilter = (req, file, cb) => {
  // Whitelist allowed file types
  const allowedTypes = /jpeg|jpg|png|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, and PDF are allowed.'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max
    files: 1 // Max 1 file per request
  }
});

// Use in route
router.post('/upload', authenticate, upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  // Don't expose server file paths to client
  res.json({
    message: 'File uploaded successfully',
    fileId: req.file.filename // Return only filename, not full path
  });
});
```

## Session Security

**Secure Session Configuration**

```javascript
import session from 'express-session';

app.use(session({
  secret: process.env.SESSION_SECRET, // Strong, random secret
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only in production
    httpOnly: true, // Prevent JavaScript access
    maxAge: 1000 * 60 * 60 * 24, // 24 hours
    sameSite: 'strict' // CSRF protection
  },
  name: 'sessionId' // Don't use default 'connect.sid'
}));
```

## Dependency Security

**Regular Security Audits**

```json
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix",
    "audit:check": "npm audit --audit-level=moderate"
  }
}
```

Run these commands regularly and in CI/CD pipelines.

**Use Tools Like Snyk or Dependabot**
- Enable Dependabot on GitHub for automatic security updates
- Use Snyk for vulnerability scanning
- Review dependency updates before merging

## Error Handling Security

**Don't Leak Information in Errors**

```javascript
// Bad: Exposing sensitive information
app.use((err, req, res, next) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack, // ❌ Exposes server internals
    query: req.query // ❌ Could contain sensitive data
  });
});

// Good: Generic error messages in production
app.use((err, req, res, next) => {
  logger.error('Error occurred', {
    error: err.message,
    stack: err.stack,
    url: req.originalUrl,
    userId: req.user?.id
  });

  const isDevelopment = process.env.NODE_ENV === 'development';

  res.status(err.statusCode || 500).json({
    error: err.isOperational ? err.message : 'Internal server error',
    ...(isDevelopment && { stack: err.stack })
  });
});
```

## Frontend Security

**Prevent Token Exposure**

```javascript
// Bad: Storing JWT in localStorage (vulnerable to XSS)
localStorage.setItem('token', token); // ❌

// Better: HttpOnly cookie (backend sets this)
res.cookie('token', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 3600000
});

// Or use secure session storage with proper CSP
```

**Validate API Responses**

```javascript
// Good: Validate data from API
import { z } from 'zod';

const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email()
});

async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();

  // Validate response matches expected schema
  return userSchema.parse(data);
}
```

## Security Checklist

Backend:
✓ Validate all user input
✓ Use parameterized queries (prevent SQL injection)
✓ Hash passwords with bcrypt (12+ rounds)
✓ Use strong JWT secrets (32+ characters)
✓ Implement rate limiting on auth endpoints
✓ Configure CORS properly
✓ Use helmet for security headers
✓ Validate file uploads (type, size)
✓ Store secrets in environment variables
✓ Never commit .env files
✓ Sanitize data in logs
✓ Run npm audit regularly
✓ Use HTTPS in production

Frontend:
✓ Never store secrets in frontend code
✓ Use HttpOnly cookies for auth tokens
✓ Validate API responses
✓ Sanitize user-generated HTML
✓ Implement CSP headers
✓ Use HTTPS
✓ Keep dependencies updated