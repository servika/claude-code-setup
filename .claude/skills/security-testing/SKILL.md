# Security Testing & Auditing for Web Applications

Comprehensive security testing methodology for Node.js/Express/React applications.

---

## What This Skill Does

Provides systematic security testing and auditing practices for modern web applications:

1. **OWASP Top 10 Testing** - Validate protection against common vulnerabilities
2. **API Security Auditing** - Review Express.js endpoints for security flaws
3. **Frontend Security Testing** - Audit React components for XSS and data exposure
4. **Authentication & Authorization** - Verify JWT, session, and permission systems
5. **Dependency Scanning** - Identify vulnerable packages and outdated libraries
6. **Security Code Review** - Manual review of security-critical code paths
7. **Penetration Testing** - Simulate attacks to find weaknesses
8. **Security Documentation** - Generate security reports and remediation guides

---

## When to Use This Skill

### Use This Skill When:
- ✅ Preparing for production deployment
- ✅ After implementing authentication/authorization features
- ✅ Before major releases or security-sensitive updates
- ✅ Onboarding new team members (security training)
- ✅ After dependency updates
- ✅ Conducting regular security audits (quarterly recommended)
- ✅ Investigating potential security incidents
- ✅ Implementing payment processing or sensitive data handling

### When NOT to Use:
- ❌ During initial prototyping (focus on functionality first)
- ❌ For non-security code reviews (use general code review practices)
- ❌ When you need functional testing (use integration tests instead)

---

## Core Principles

### 1. Defense in Depth

Multiple layers of security controls:
- Input validation at every entry point
- Authentication AND authorization checks
- Data encryption at rest and in transit
- Rate limiting and DDoS protection
- Security headers and CSP
- Regular security updates

### 2. Least Privilege

Users and services should have minimum necessary permissions:
- Role-based access control (RBAC)
- API endpoints require specific permissions
- Database users with limited privileges
- Service accounts with scoped access
- Frontend hides unauthorized features

### 3. Fail Securely

When errors occur, default to secure state:
- Authentication failures → deny access
- Authorization errors → 403 Forbidden
- Validation failures → reject request
- Never expose internal errors to users
- Log security events for investigation

### 4. Security by Design

Build security into development process:
- Threat modeling during design phase
- Security requirements in user stories
- Security testing in CI/CD pipeline
- Regular security training for team
- Security champions on each team

---

## OWASP Top 10 Testing Checklist

### A01:2021 - Broken Access Control

**Test:**
```javascript
// Test horizontal privilege escalation
// User A tries to access User B's data

// Bad: No authorization check
GET /api/users/123/profile  // Any authenticated user can access

// Good: Check ownership
if (req.user.id !== req.params.userId && req.user.role !== 'admin') {
  throw new ForbiddenError('Not authorized');
}
```

**Audit Points:**
- [ ] All endpoints verify user authorization
- [ ] Role-based access control implemented
- [ ] Hidden routes still require authentication
- [ ] File uploads restricted by user permissions
- [ ] API rate limiting prevents enumeration attacks

### A02:2021 - Cryptographic Failures

**Test:**
```javascript
// Verify password hashing
import bcrypt from 'bcrypt';

// Bad: Weak hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// Good: Strong hashing with salt
const hash = await bcrypt.hash(password, 12);

// Verify sensitive data encryption
// Bad: Storing credit cards in plain text
user.creditCard = req.body.creditCard;

// Good: Encrypt before storing
user.creditCard = await encrypt(req.body.creditCard);
```

**Audit Points:**
- [ ] Passwords hashed with bcrypt (12+ rounds)
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced in production
- [ ] Secrets not in version control
- [ ] JWT secrets are strong (32+ characters)

### A03:2021 - Injection

**Test SQL Injection:**
```javascript
// Bad: String concatenation
const query = `SELECT * FROM users WHERE email = '${email}'`;
// Vulnerable to: ' OR '1'='1

// Good: Parameterized queries
const query = 'SELECT * FROM users WHERE email = $1';
await pool.query(query, [email]);
```

**Test NoSQL Injection:**
```javascript
// Bad: Direct use of user input
const user = await User.findOne({ email: req.body.email });
// Vulnerable to: { "$ne": null }

// Good: Validate and sanitize
const email = z.string().email().parse(req.body.email);
const user = await User.findOne({ email });
```

**Audit Points:**
- [ ] All database queries use parameterized statements
- [ ] Input validation with Zod/Joi
- [ ] NoSQL injection prevention (sanitize $, .)
- [ ] Command injection prevention (avoid exec/spawn with user input)
- [ ] Template injection prevention

### A04:2021 - Insecure Design

**Test:**
```javascript
// Bad: Password reset without rate limiting
router.post('/forgot-password', async (req, res) => {
  await sendResetEmail(req.body.email);
  // Attacker can enumerate valid emails
});

// Good: Rate limiting + same response for all cases
const resetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 3
});

router.post('/forgot-password', resetLimiter, async (req, res) => {
  await sendResetEmail(req.body.email);
  // Always return same message
  res.json({ message: 'If email exists, reset link sent' });
});
```

**Audit Points:**
- [ ] Threat modeling completed for key features
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout after failed login attempts
- [ ] Email enumeration prevented
- [ ] Business logic flaws identified

### A05:2021 - Security Misconfiguration

**Test:**
```javascript
// Check security headers
import helmet from 'helmet';

// Bad: No security headers
app.use(express.json());

// Good: Helmet with CSP
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  }
}));
```

**Audit Points:**
- [ ] Helmet configured with strict CSP
- [ ] CORS properly configured
- [ ] Error messages don't leak sensitive info
- [ ] Debug mode disabled in production
- [ ] Default credentials changed
- [ ] Unnecessary features disabled

### A06:2021 - Vulnerable Components

**Test:**
```bash
# Check for vulnerable dependencies
npm audit

# Check for outdated packages
npm outdated

# Use Snyk or similar
npx snyk test
```

**Audit Points:**
- [ ] All dependencies up to date
- [ ] No critical/high vulnerabilities
- [ ] Automated dependency scanning in CI/CD
- [ ] Package lock file committed
- [ ] Regular dependency updates scheduled

### A07:2021 - Authentication Failures

**Test:**
```javascript
// Test weak password policy
const passwordSchema = z.string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain uppercase')
  .regex(/[a-z]/, 'Password must contain lowercase')
  .regex(/[0-9]/, 'Password must contain number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain special character');

// Test session management
// Bad: Session never expires
res.cookie('token', token);

// Good: Short-lived tokens with refresh
res.cookie('token', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 15 * 60 * 1000 // 15 minutes
});
```

**Audit Points:**
- [ ] Strong password policy enforced
- [ ] Multi-factor authentication available
- [ ] Session timeout implemented
- [ ] Credential stuffing protection
- [ ] Brute force protection (rate limiting)
- [ ] Password reset flow secure

### A08:2021 - Data Integrity Failures

**Test:**
```javascript
// Verify file upload integrity
import crypto from 'crypto';

// Bad: No validation
app.post('/upload', upload.single('file'), (req, res) => {
  // Accept any file
});

// Good: Validate file type and hash
app.post('/upload', upload.single('file'), async (req, res) => {
  // Check file type
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
  if (!allowedTypes.includes(req.file.mimetype)) {
    throw new ValidationError('Invalid file type');
  }

  // Verify file hash if provided
  if (req.body.expectedHash) {
    const hash = crypto.createHash('sha256')
      .update(req.file.buffer)
      .digest('hex');

    if (hash !== req.body.expectedHash) {
      throw new ValidationError('File integrity check failed');
    }
  }
});
```

**Audit Points:**
- [ ] File uploads validated by type and size
- [ ] Deserialization attacks prevented
- [ ] Digital signatures for critical data
- [ ] Integrity checks for downloads
- [ ] CI/CD pipeline integrity verified

### A09:2021 - Logging & Monitoring Failures

**Test:**
```javascript
// Good: Structured security logging
import logger from './logger';

// Log authentication attempts
router.post('/login', async (req, res) => {
  try {
    const user = await authenticate(req.body);
    logger.info('Login successful', {
      userId: user.id,
      ip: req.ip,
      userAgent: req.get('user-agent')
    });
  } catch (error) {
    logger.warn('Login failed', {
      email: req.body.email,
      ip: req.ip,
      reason: error.message
    });
    throw new UnauthorizedError('Invalid credentials');
  }
});

// Log suspicious activity
if (failedAttempts > 5) {
  logger.security('Possible brute force attack', {
    email: req.body.email,
    ip: req.ip,
    attempts: failedAttempts
  });
}
```

**Audit Points:**
- [ ] Security events logged (auth, authz, errors)
- [ ] Logs include user, IP, timestamp, action
- [ ] Sensitive data not logged (passwords, tokens)
- [ ] Log monitoring and alerting configured
- [ ] Logs retained for appropriate period
- [ ] Incident response plan exists

### A10:2021 - Server-Side Request Forgery (SSRF)

**Test:**
```javascript
// Bad: User-controlled URL
router.post('/fetch-url', async (req, res) => {
  const response = await fetch(req.body.url);
  // Can access internal services: http://localhost:6379
});

// Good: Whitelist allowed domains
const allowedDomains = ['api.github.com', 'api.stripe.com'];

router.post('/fetch-url', async (req, res) => {
  const url = new URL(req.body.url);

  if (!allowedDomains.includes(url.hostname)) {
    throw new ValidationError('Domain not allowed');
  }

  // Additional check for private IPs
  if (isPrivateIP(url.hostname)) {
    throw new ValidationError('Private IPs not allowed');
  }

  const response = await fetch(url.href);
});
```

**Audit Points:**
- [ ] URL validation and whitelisting
- [ ] Private IP range blocking
- [ ] Network segmentation
- [ ] Webhook validation

---

## Frontend Security Testing (React)

### XSS Prevention

**Test:**
```javascript
// Bad: dangerouslySetInnerHTML without sanitization
function UserBio({ bio }) {
  return <div dangerouslySetInnerHTML={{ __html: bio }} />;
}

// Good: Sanitize HTML
import DOMPurify from 'dompurify';

function UserBio({ bio }) {
  const sanitized = DOMPurify.sanitize(bio);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// Better: Use React's default escaping
function UserBio({ bio }) {
  return <div>{bio}</div>; // React escapes automatically
}
```

**Audit Points:**
- [ ] All user content properly escaped
- [ ] dangerouslySetInnerHTML used sparingly with sanitization
- [ ] CSP headers prevent inline scripts
- [ ] Event handlers don't use user data directly

### Sensitive Data Exposure

**Test:**
```javascript
// Bad: Exposing API keys in frontend
const API_KEY = 'sk_live_1234567890'; // Visible in bundle

// Good: API calls through backend
const fetchData = async () => {
  // Backend adds API key
  const response = await fetch('/api/data');
};

// Bad: Storing sensitive data in localStorage
localStorage.setItem('creditCard', cardNumber);

// Good: Never store sensitive data in frontend
// Send to backend immediately
```

**Audit Points:**
- [ ] No secrets in frontend code
- [ ] No sensitive data in localStorage/sessionStorage
- [ ] API responses don't include unnecessary data
- [ ] Console.log removed from production builds

### Authentication State

**Test:**
```javascript
// Bad: Role-based rendering without backend verification
function AdminPanel() {
  const user = JSON.parse(localStorage.getItem('user'));

  if (user.role === 'admin') {
    return <AdminDashboard />; // Anyone can modify localStorage
  }
}

// Good: Backend verifies permissions
function AdminPanel() {
  const { data: user, isLoading } = useUser();
  const { data: permissions } = usePermissions();

  if (!permissions?.includes('admin')) {
    return <Forbidden />;
  }

  return <AdminDashboard />; // Backend still validates all API calls
}
```

**Audit Points:**
- [ ] Authentication state managed securely
- [ ] Protected routes verify auth status
- [ ] Backend always validates permissions
- [ ] Tokens stored in httpOnly cookies (not localStorage)

---

## API Security Audit Checklist

### Authentication
- [ ] All protected endpoints require valid JWT/session
- [ ] Token expiration enforced (15 min for access, 7 days for refresh)
- [ ] Refresh token rotation implemented
- [ ] Bearer token validation strict

### Authorization
- [ ] Every endpoint checks user permissions
- [ ] Role-based access control (RBAC) implemented
- [ ] Resource ownership verified
- [ ] Horizontal privilege escalation prevented

### Input Validation
- [ ] All inputs validated with Zod/Joi
- [ ] Request body size limited (10MB default)
- [ ] File upload restrictions (type, size)
- [ ] Query parameters sanitized

### Rate Limiting
- [ ] Authentication endpoints: 5 requests/15 min
- [ ] General API: 100 requests/15 min
- [ ] IP-based rate limiting
- [ ] Distributed rate limiting (Redis) for scaled apps

### Error Handling
- [ ] Generic error messages for users
- [ ] Detailed errors logged server-side
- [ ] No stack traces in production
- [ ] Error codes don't leak info

### Security Headers
- [ ] Helmet configured
- [ ] CSP with strict policies
- [ ] HSTS enabled
- [ ] X-Frame-Options: DENY
- [ ] X-Content-Type-Options: nosniff

---

## Dependency Security Audit

### Automated Scanning

```bash
# Run npm audit
npm audit

# Fix automatically
npm audit fix

# Check for specific severity
npm audit --audit-level=moderate

# Use Snyk
npx snyk test
npx snyk monitor

# Use OWASP Dependency Check
dependency-check --project "My App" --scan ./
```

### Manual Review Process

1. **Identify Critical Dependencies**
   - Authentication libraries (passport, jsonwebtoken)
   - Database drivers (pg, mongoose)
   - Validation libraries (zod, joi)
   - Security libraries (helmet, bcrypt)

2. **Check Each Dependency**
   - Last update date (abandoned projects?)
   - Known vulnerabilities (CVE database)
   - Maintainer reputation
   - Download statistics
   - License compatibility

3. **Version Pinning Strategy**
   ```json
   {
     "dependencies": {
       "express": "4.18.2",        // Exact version for critical
       "react": "^18.2.0",          // Caret for active libraries
       "lodash": ">=4.17.21 <5.0.0" // Range when needed
     }
   }
   ```

### Dependency Audit Checklist
- [ ] No critical vulnerabilities
- [ ] No high vulnerabilities (or documented exceptions)
- [ ] All dependencies actively maintained
- [ ] License compliance verified
- [ ] Automated scanning in CI/CD
- [ ] Monthly dependency review scheduled

---

## Security Testing Tools

### Automated Tools

**Static Analysis:**
- ESLint with security plugins
- SonarQube / SonarCloud
- Snyk Code
- GitHub Advanced Security

**Dependency Scanning:**
- npm audit
- Snyk
- OWASP Dependency-Check
- WhiteSource Bolt

**Dynamic Analysis:**
- OWASP ZAP
- Burp Suite Community
- Nikto
- SQLMap (for SQL injection testing)

**Container Security:**
- Trivy
- Snyk Container
- Anchore

### Manual Testing

**Burp Suite Workflow:**
1. Configure browser to proxy through Burp
2. Browse application normally
3. Review HTTP history for:
   - Unencrypted sensitive data
   - Weak session tokens
   - Missing security headers
   - CSRF tokens

4. Use Intruder for:
   - Brute force testing
   - SQL injection fuzzing
   - XSS payload testing

5. Use Repeater for:
   - Testing authorization bypass
   - Parameter tampering
   - Request manipulation

---

## Security Code Review Guidelines

### Authentication Code Review

```javascript
// Check 1: Password handling
async function login(email, password) {
  const user = await User.findByEmail(email);

  // ✓ Uses timing-safe comparison
  const isValid = await bcrypt.compare(password, user.passwordHash);

  // ✓ Doesn't reveal whether email exists
  if (!user || !isValid) {
    throw new UnauthorizedError('Invalid credentials');
  }

  // ✓ Generates secure random tokens
  const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
    expiresIn: '15m'
  });

  // ✓ HttpOnly cookies prevent XSS
  res.cookie('token', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  });
}
```

### Authorization Code Review

```javascript
// Check 2: Resource access control
async function getDocument(req, res) {
  const doc = await Document.findById(req.params.id);

  // ✗ Missing: Check if user can access this document
  // ✓ Should verify ownership or permissions
  if (doc.ownerId !== req.user.id && !req.user.permissions.includes('admin')) {
    throw new ForbiddenError('Not authorized');
  }

  res.json(doc);
}
```

### Input Validation Code Review

```javascript
// Check 3: Validation completeness
const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().min(13).max(120),
  role: z.enum(['user', 'admin', 'moderator']),
  // ✓ Whitelist approach
  // ✓ Strict types
  // ✓ Reasonable limits
});

// ✗ Missing: Sanitization for special characters
// ✓ Should use validator.escape() for output
```

---

## Security Report Template

```markdown
# Security Audit Report

**Project:** [Project Name]
**Date:** [Audit Date]
**Auditor:** [Name]
**Severity Scale:** Critical | High | Medium | Low

---

## Executive Summary

- Total vulnerabilities found: X
- Critical: X
- High: X
- Medium: X
- Low: X

**Overall Risk Rating:** [Critical/High/Medium/Low]

---

## Vulnerabilities

### 1. [Vulnerability Title] - [CRITICAL]

**Category:** OWASP A01:2021 - Broken Access Control

**Description:**
User authorization is not checked on `/api/users/:id/delete` endpoint, allowing any authenticated user to delete other users' accounts.

**Impact:**
- Unauthorized account deletion
- Data loss
- Service disruption

**Affected Components:**
- `src/routes/users.routes.js:45`
- `src/controllers/users.controller.js:123`

**Proof of Concept:**
```bash
# User A (id: 1) can delete User B (id: 2)
curl -X DELETE http://api.example.com/api/users/2 \
  -H "Authorization: Bearer <user-a-token>"
```

**Remediation:**
```javascript
// Add authorization check
router.delete('/:id', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    throw new ForbiddenError('Not authorized to delete this user');
  }

  await deleteUser(req.params.id);
  res.status(204).send();
});
```

**Priority:** Immediate (fix within 24 hours)

---

## Recommendations

### Immediate Actions (0-7 days)
1. Fix all critical vulnerabilities
2. Implement rate limiting on authentication endpoints
3. Enable Helmet with strict CSP

### Short-term (1-4 weeks)
1. Implement comprehensive input validation
2. Add security testing to CI/CD pipeline
3. Conduct security training for team

### Long-term (1-3 months)
1. Implement automated security scanning
2. Establish security review process
3. Create incident response plan

---

## Testing Methodology

- Static code analysis
- Dependency vulnerability scanning
- Manual code review
- Penetration testing
- OWASP ZAP automated scan

---

## Sign-off

**Auditor:** _______________
**Date:** _______________
```

---

## Best Practices

### Security Testing in CI/CD

```yaml
# .github/workflows/security.yml
name: Security Tests

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run npm audit
        run: npm audit --audit-level=moderate

      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Run ESLint security plugin
        run: npm run lint:security

      - name: OWASP ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'http://localhost:3000'
```

### Regular Security Reviews

**Monthly:**
- Review npm audit results
- Update dependencies
- Check security advisories

**Quarterly:**
- Full security audit
- Penetration testing
- Review access controls

**Annually:**
- Comprehensive security assessment
- Update security policies
- Security training for team

---

## Summary

**This Skill Provides:**
- ✅ OWASP Top 10 testing methodology
- ✅ API security audit checklist
- ✅ Frontend security testing (React)
- ✅ Dependency vulnerability scanning
- ✅ Security code review guidelines
- ✅ Security report templates
- ✅ CI/CD integration patterns

**Requirements:**
- Node.js/Express/React application
- Basic security knowledge
- Testing tools installed (npm audit, Snyk, etc.)

**Best Results:**
- Run security tests before each release
- Automate scanning in CI/CD pipeline
- Conduct regular code reviews
- Keep dependencies updated
- Train team on security practices

**Integration:**
- Works with `.claude/rules/security.md`
- Complements testing guidelines
- Supports CI/CD workflows