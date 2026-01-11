# Release Documentation - Real-World Examples

Practical examples showing how to generate release documentation in different scenarios.

---

## Example 1: Standard NPM Package Release

### Scenario

Publishing a new version of an Express.js API package with new features and bug fixes.

### Initial Request

```
Claude, generate release documentation for my Express middleware package:

Package: @myorg/express-auth
Current version: 1.4.2
Target version: Determine from commits
From: v1.4.2 to HEAD
Format: Markdown for CHANGELOG.md
Audience: Developers
Include: Breaking changes, migration guide if needed
```

### Workflow

**Phase 1: Analyze Commits**

Claude runs:
```bash
git log v1.4.2..HEAD --oneline --no-merges
```

Finds commits:
```
feat(auth): add JWT refresh token rotation
fix(middleware): resolve CORS preflight issue
perf(cache): implement Redis caching for sessions
docs(readme): update installation instructions
chore(deps): upgrade jsonwebtoken to 9.0.0
test(auth): add refresh token tests
```

**Phase 2: Categorize Changes**

Claude analyzes:
- `feat` → New Features (1)
- `fix` → Bug Fixes (1)
- `perf` → Performance (1)
- `docs` → Documentation (internal, exclude from customer changelog)
- `chore` → Maintenance (internal, exclude)
- `test` → Tests (internal, exclude)

No breaking changes detected → **MINOR** version bump: 1.4.2 → **1.5.0**

**Phase 3: Generate Changelog**

Claude creates `CHANGELOG.md`:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-01-09

### Added

- **JWT Refresh Token Rotation**: Implement automatic refresh token rotation for enhanced security
  - Tokens now automatically rotate on each refresh
  - Configurable rotation policy via `rotationPolicy` option
  - Reduces risk of token theft
  - Example:
    ```javascript
    app.use(authMiddleware({
      refreshTokenRotation: true,
      rotationPolicy: 'on-use' // or 'on-expiry'
    }));
    ```

### Fixed

- **CORS Preflight Handling**: Resolve issue where OPTIONS requests were not handled correctly
  - Fixes 403 errors on cross-origin requests
  - Properly handles preflight for protected routes
  - Addresses issue #142

### Performance

- **Session Caching**: Implement Redis caching for session data
  - 75% reduction in database queries
  - Average response time: 245ms → 61ms
  - Configurable cache TTL
  - Redis connection handled automatically

### Dependencies

- Upgraded `jsonwebtoken` from 8.5.1 to 9.0.0 for security patches

### Contributors

Thanks to @username1 for the refresh token implementation and @username2 for
performance optimizations.

**Full Changelog**: https://github.com/org/repo/compare/v1.4.2...v1.5.0

## [1.4.2] - 2025-12-15
...
```

**Phase 4: Update package.json**

Claude suggests:
```json
{
  "version": "1.5.0"
}
```

**Phase 5: Generate Release Notes**

Claude creates GitHub release notes:
```markdown
## 🎉 New Features

- JWT refresh token rotation for improved security (#145)

## 🐛 Bug Fixes

- Fixed CORS preflight handling (#142)

## ⚡ Performance

- Redis caching reduces response time by 75%

## 📦 Installation

```bash
npm install @myorg/express-auth@1.5.0
```

## 📚 Documentation

See [CHANGELOG.md](link) for full details.
```

**Final Deliverables:**
- ✅ CHANGELOG.md updated
- ✅ package.json version bumped
- ✅ GitHub release notes ready
- ✅ npm publish command ready: `npm publish`

---

## Example 2: Breaking Changes Release (Major Version)

### Scenario

Releasing v2.0.0 with significant API changes that break backward compatibility.

### Initial Request

```
Claude, prepare release documentation for major version 2.0.0:

From: v1.9.2 to HEAD
Include:
- Complete changelog
- Migration guide with code examples
- Breaking changes summary
- Deprecation timeline
```

### Workflow

**Phase 1: Detect Breaking Changes**

Claude scans commits for:
- `BREAKING CHANGE:` in commit footer
- `!` after type: `feat!:`, `fix!:`
- Major API changes in diff

Found commits:
```
feat(api)!: change authentication response format
BREAKING CHANGE: Auth endpoint now returns accessToken and refreshToken separately

refactor(middleware)!: remove deprecated session middleware
BREAKING CHANGE: sessionMiddleware removed, use jwtMiddleware instead

feat(config)!: require explicit configuration object
BREAKING CHANGE: Config now requires explicit options, no more defaults
```

**Phase 2: Generate MIGRATION.md**

```markdown
# Migration Guide: v1.x to v2.0.0

## Overview

Version 2.0.0 introduces breaking changes to improve API consistency, security,
and developer experience. **Estimated migration time: 1-3 hours** depending on
your usage.

## Prerequisites

- Node.js 18+ (v1.x supported Node.js 16+)
- Update all dependent packages to latest v1.x first
- Review deprecation warnings in your current setup

## Breaking Changes Summary

| Area | Impact | Migration Time |
|------|--------|----------------|
| Authentication Response | High | 30 min |
| Middleware Configuration | Medium | 20 min |
| Configuration Object | Low | 10 min |

---

## 1. Authentication Response Format

### What Changed

The `/auth/login` and `/auth/refresh` endpoints now return tokens in separate fields.

### Before (v1.x)

```javascript
// Login response
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { "id": "123", "email": "user@example.com" }
}

// Your code
const { token } = await auth.login(credentials);
localStorage.setItem('token', token);
```

### After (v2.0)

```javascript
// Login response
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600,
  "user": { "id": "123", "email": "user@example.com" }
}

// Your code
const { accessToken, refreshToken } = await auth.login(credentials);
localStorage.setItem('accessToken', accessToken);
localStorage.setItem('refreshToken', refreshToken);
```

### Migration Steps

1. **Update login handler:**
   ```javascript
   // Old
   async function handleLogin(credentials) {
     const { token, user } = await authClient.login(credentials);
     setToken(token);
     setUser(user);
   }

   // New
   async function handleLogin(credentials) {
     const { accessToken, refreshToken, user } = await authClient.login(credentials);
     setTokens({ accessToken, refreshToken });
     setUser(user);
   }
   ```

2. **Update API calls:**
   ```javascript
   // Old
   const token = localStorage.getItem('token');
   fetch('/api/data', {
     headers: { Authorization: `Bearer ${token}` }
   });

   // New
   const accessToken = localStorage.getItem('accessToken');
   fetch('/api/data', {
     headers: { Authorization: `Bearer ${accessToken}` }
   });
   ```

3. **Implement token refresh:**
   ```javascript
   async function refreshAccessToken() {
     const refreshToken = localStorage.getItem('refreshToken');
     const response = await fetch('/auth/refresh', {
       method: 'POST',
       headers: { 'Content-Type': 'application/json' },
       body: JSON.stringify({ refreshToken })
     });

     const { accessToken, refreshToken: newRefreshToken } = await response.json();
     localStorage.setItem('accessToken', accessToken);
     localStorage.setItem('refreshToken', newRefreshToken);
     return accessToken;
   }
   ```

**Testing Checklist:**
- [ ] Login flow works with new token format
- [ ] Token refresh works automatically
- [ ] Protected routes accept new token format
- [ ] Token expiration handled correctly

---

## 2. Session Middleware Removed

### What Changed

`sessionMiddleware` has been removed. Use `jwtMiddleware` instead.

### Before (v1.x)

```javascript
import { sessionMiddleware } from '@myorg/express-auth';

app.use(sessionMiddleware({
  secret: process.env.SESSION_SECRET,
  store: redisStore
}));
```

### After (v2.0)

```javascript
import { jwtMiddleware } from '@myorg/express-auth';

app.use(jwtMiddleware({
  secret: process.env.JWT_SECRET,
  algorithms: ['HS256']
}));
```

### Why This Change?

- JWT-based authentication is more scalable
- No server-side session storage required
- Better support for microservices architecture
- Reduced Redis/database load

### Migration Steps

1. **Replace middleware:**
   ```javascript
   // Remove
   - const { sessionMiddleware } = require('@myorg/express-auth');
   - app.use(sessionMiddleware(options));

   // Add
   + const { jwtMiddleware } = require('@myorg/express-auth');
   + app.use(jwtMiddleware(options));
   ```

2. **Update session access:**
   ```javascript
   // Old - accessing session
   app.get('/profile', (req, res) => {
     const userId = req.session.userId; // ❌ No longer available
     // ...
   });

   // New - accessing JWT payload
   app.get('/profile', (req, res) => {
     const userId = req.user.id; // ✅ From JWT
     // ...
   });
   ```

3. **Remove session store:**
   ```javascript
   // Can remove Redis session store
   - const RedisStore = require('connect-redis')(session);
   - const redisStore = new RedisStore({ client: redisClient });
   ```

**Testing Checklist:**
- [ ] All protected routes use JWT middleware
- [ ] `req.user` is populated correctly
- [ ] No references to `req.session` remain
- [ ] Session store dependencies removed

---

## 3. Configuration Object Required

### What Changed

Configuration must now be explicitly provided - no more default values.

### Before (v1.x)

```javascript
// Defaults were used
const auth = new AuthClient();
```

### After (v2.0)

```javascript
// Must provide configuration
const auth = new AuthClient({
  apiUrl: process.env.API_URL,
  tokenKey: 'accessToken',
  refreshKey: 'refreshToken'
});
```

### Migration Steps

Create configuration object:
```javascript
const authConfig = {
  apiUrl: process.env.API_URL || 'http://localhost:3000',
  tokenKey: 'accessToken',
  refreshKey: 'refreshToken',
  autoRefresh: true,
  refreshThreshold: 300 // Refresh 5 min before expiry
};

const auth = new AuthClient(authConfig);
```

---

## Testing Your Migration

### 1. Run Automated Tests

```bash
npm test
```

### 2. Manual Testing Checklist

- [ ] User can log in
- [ ] User can log out
- [ ] Protected routes work
- [ ] Token refresh works automatically
- [ ] Session persists across page reloads
- [ ] Logout clears all tokens

### 3. Check for Warnings

Run your app in development mode and check console for:
```
⚠️  Deprecation Warning: sessionMiddleware will be removed in v2.0
✅  No warnings = migration complete
```

## Rollback Plan

If you encounter issues:

### Quick Rollback

```bash
npm install @myorg/express-auth@1.9.2
```

### Gradual Migration

You can run v1.x and v2.0 side-by-side:

```javascript
// Support both formats during transition
function getToken(authResponse) {
  // v2.0 format
  if (authResponse.accessToken) {
    return authResponse.accessToken;
  }
  // v1.x format (fallback)
  return authResponse.token;
}
```

## Timeline

- **v2.0.0 Release**: January 9, 2026
- **v1.x Support**: Until July 9, 2026 (6 months)
- **v1.x EOL**: July 10, 2026

## Support

- **Documentation**: https://docs.example.com/v2
- **GitHub Discussions**: https://github.com/org/repo/discussions
- **Discord**: https://discord.gg/yourserver
- **Email**: support@example.com

## Success Stories

> "Migration took only 2 hours for our 50k LOC application. The guide was
> excellent!" - @developer1

> "Token refresh is so much smoother now. Worth the upgrade!" - @developer2
```

**Phase 3: Update CHANGELOG.md**

```markdown
## [2.0.0] - 2026-01-09

### 🚨 Breaking Changes

**⚠️ This release contains breaking changes. See [MIGRATION.md](MIGRATION.md)
for upgrade instructions.**

#### Authentication Response Format

- Changed authentication endpoints to return `accessToken` and `refreshToken`
  separately instead of single `token` field
- **Impact**: All applications using `/auth/login` and `/auth/refresh` endpoints
- **Action Required**: Update token handling code (see migration guide)

#### Session Middleware Removed

- Removed `sessionMiddleware` in favor of `jwtMiddleware`
- **Impact**: Applications using session-based authentication
- **Action Required**: Migrate to JWT middleware (see migration guide)

#### Configuration Object Required

- Configuration object is now required (no defaults)
- **Impact**: Applications using default configuration
- **Action Required**: Provide explicit configuration

### Added

- JWT refresh token rotation for enhanced security
- Automatic token refresh before expiration
- Better TypeScript definitions

### Changed

- Minimum Node.js version: 18.0.0 (was 16.0.0)
- Updated dependencies for security

### Removed

- `sessionMiddleware` (use `jwtMiddleware` instead)
- Default configuration values
- Node.js 16 support

### Migration Guide

See [MIGRATION.md](MIGRATION.md) for detailed upgrade instructions.

**Estimated migration time**: 1-3 hours

**Full Changelog**: https://github.com/org/repo/compare/v1.9.2...v2.0.0
```

**Final Deliverables:**
- ✅ MIGRATION.md with step-by-step guide
- ✅ CHANGELOG.md with breaking changes
- ✅ GitHub release with migration link
- ✅ Version bumped to 2.0.0

---

## Example 3: Weekly Product Update

### Scenario

Creating customer-facing weekly update announcement for SaaS product.

### Initial Request

```
Claude, generate weekly product update for our users:

Time period: Last 7 days (Jan 2-9, 2026)
Format: Blog post + email newsletter
Audience: Non-technical users
Focus: User benefits and improvements
Include: Screenshots placeholders
```

### Workflow

**Phase 1: Gather Customer-Facing Changes**

Claude filters commits for user-facing changes:
```
feat(ui): add dark mode support
fix(dashboard): resolve data loading issue
perf(api): improve response time for analytics
feat(export): add PDF export for reports
fix(mobile): fix touch scrolling on iOS
```

Excludes internal commits:
```
chore(deps): update webpack
refactor(tests): improve test coverage
ci(github): update action workflows
```

**Phase 2: Generate Blog Post**

```markdown
# What's New This Week 🎉

## Dark Mode is Here! 🌙

You asked, we listened! The app now supports dark mode across all screens.

**How to enable:**
1. Click your profile in the top-right
2. Select "Appearance"
3. Choose "Dark" or "Auto" (follows system preference)

[Screenshot: Dark mode toggle]

## Faster Analytics ⚡

We've turbocharged our analytics engine:
- Reports load 3x faster
- Real-time updates without refresh
- Smoother charts and graphs

**What you'll notice:**
- Dashboard loads in under 1 second
- No more "Loading..." spinners
- Instant data updates

## PDF Reports 📄

Export your reports as beautiful PDFs to share with your team.

**New export options:**
- Monthly summaries
- Custom date ranges
- Branded with your logo

**How to use:**
1. Open any report
2. Click "Export" button
3. Select "PDF"
4. Download and share!

[Screenshot: PDF export button]

## Bug Fixes 🐛

We've squashed some annoying bugs:
- Fixed dashboard loading on slow connections
- Improved mobile scrolling on iOS devices
- Resolved email notification delays

## What's Coming Next Week

- Team collaboration features
- Advanced filtering options
- Mobile app updates

## Share Your Feedback

Let us know what you think in our [community forum](link) or email us
at feedback@example.com.

Happy [Product Name]ing! 🚀

---

**P.S.** Want to see what we're building next? Check out our
[public roadmap](link).
```

**Phase 3: Generate Email Newsletter**

```html
Subject: This Week's Updates: Dark Mode + Faster Analytics ✨

[Header Image]

Hi there! 👋

We've been busy this week making [Product] even better for you.

🌙 DARK MODE IS LIVE
Easy on the eyes, especially at night. Try it now in Settings → Appearance.

⚡ 3X FASTER ANALYTICS
Your dashboards and reports now load almost instantly.

📄 PDF EXPORTS
Create beautiful PDF reports with one click.

[View All Updates →]

---

Bug Fixes:
• Fixed dashboard loading
• Improved mobile experience
• Resolved notification delays

---

Coming Next Week:
• Team collaboration
• Advanced filters
• Mobile improvements

Questions? Reply to this email - we read every message!

Best,
The [Product] Team

[Unsubscribe] | [View in Browser]
```

**Phase 4: Social Media Snippets**

```markdown
**Twitter/X:**
This week's updates ✨
🌙 Dark mode
⚡ 3x faster analytics
📄 PDF exports
🐛 Bug fixes

Try dark mode now → [link]

**LinkedIn:**
We've shipped some great improvements this week:

✅ Dark mode support across the entire app
✅ 3x faster analytics and reporting
✅ One-click PDF exports
✅ Multiple bug fixes for better experience

Check out what's new → [link]
```

**Final Deliverables:**
- ✅ Blog post ready for WordPress/CMS
- ✅ Email newsletter (HTML + plain text)
- ✅ Social media posts
- ✅ Screenshot placeholders marked

---

## Example 4: Emergency Hotfix Release

### Scenario

Critical security fix needs immediate release documentation.

### Initial Request

```
Claude, urgent hotfix documentation:

Version: 1.4.3 (patch release)
Previous: 1.4.2
Issue: Critical security vulnerability in JWT validation
Action: Immediate upgrade recommended
```

### Workflow

**Phase 1: Security Advisory**

```markdown
# Security Advisory: JWT Validation Vulnerability

**Severity**: High
**CVE**: CVE-2026-XXXXX
**Affected Versions**: 1.0.0 - 1.4.2
**Fixed in**: 1.4.3
**Published**: 2026-01-09

## Summary

A vulnerability in JWT signature validation could allow authentication bypass
under specific conditions.

## Impact

Attackers could potentially bypass authentication if:
1. Using RS256 algorithm
2. Attacker controls the key header
3. No key pinning configured

## Affected Systems

All applications using @myorg/express-auth versions 1.0.0 through 1.4.2 with:
- RS256 algorithm
- Default configuration
- No custom key validation

## Solution

### Immediate Action Required

Upgrade to version 1.4.3:

```bash
npm install @myorg/express-auth@1.4.3
```

### Verification

After upgrade, verify the fix:
```javascript
const auth = require('@myorg/express-auth');
console.log(auth.version); // Should show 1.4.3
```

### Workaround (if immediate upgrade not possible)

Add explicit algorithm validation:
```javascript
app.use(jwtMiddleware({
  secret: process.env.JWT_SECRET,
  algorithms: ['HS256'], // Explicitly specify allowed algorithms
  verify: {
    algorithms: ['HS256'],
    ignoreNotBefore: false
  }
}));
```

## Timeline

- **Issue Reported**: January 8, 2026
- **Fix Developed**: January 8, 2026 (same day)
- **Released**: January 9, 2026
- **Public Disclosure**: January 9, 2026

## Credits

Thank you to @security-researcher for responsible disclosure.

## References

- [Full Advisory](link)
- [Patch Diff](link)
- [Security Policy](SECURITY.md)
```

**Phase 2: Brief Changelog**

```markdown
## [1.4.3] - 2026-01-09 - SECURITY RELEASE

### Security

- **CRITICAL**: Fix JWT signature validation vulnerability (CVE-2026-XXXXX)
  - Adds strict algorithm validation
  - Prevents authentication bypass
  - **Action Required**: Upgrade immediately

### Changed

- Enhanced JWT verification with algorithm pinning
- Added additional validation checks

**This is a security release. All users should upgrade immediately.**

**Installation:**
```bash
npm install @myorg/express-auth@1.4.3
```

**Full Advisory**: [SECURITY_ADVISORY.md](link)
```

**Phase 3: Notification Templates**

**Email to All Users:**
```
Subject: [URGENT] Security Update Required - @myorg/express-auth

Dear @myorg/express-auth users,

A critical security vulnerability has been discovered and fixed in version 1.4.3.

WHAT YOU NEED TO DO:
1. Upgrade to version 1.4.3 immediately
2. Run: npm install @myorg/express-auth@1.4.3
3. Redeploy your application

WHAT'S AFFECTED:
Versions 1.0.0 through 1.4.2

WHY IT MATTERS:
A vulnerability in JWT validation could allow authentication bypass.

MORE INFORMATION:
[Security Advisory Link]

Questions? Reply to this email.

Security Team
@myorg
```

**GitHub Release Notice:**
```markdown
## 🚨 CRITICAL SECURITY RELEASE

This is a **security release** addressing CVE-2026-XXXXX.

**All users must upgrade immediately.**

### What's Fixed

- Critical JWT signature validation vulnerability

### How to Upgrade

```bash
npm install @myorg/express-auth@1.4.3
```

### More Information

See [SECURITY_ADVISORY.md](link) for complete details.
```

**Final Deliverables:**
- ✅ Security advisory (SECURITY_ADVISORY.md)
- ✅ Changelog entry
- ✅ Email notification draft
- ✅ GitHub release
- ✅ npm publish ready
- ✅ Social media alerts

---

## Key Takeaways

### Example 1 (Standard Release)
- Conventional commits enable automatic categorization
- Semantic versioning determined from commit types
- Developer-focused changelog with technical details

### Example 2 (Breaking Changes)
- Migration guide is essential for major versions
- Code examples show before/after clearly
- Testing checklist ensures smooth transition
- Rollback plan provides safety net

### Example 3 (Product Updates)
- Customer-friendly language focuses on benefits
- Multiple formats for different channels
- Screenshots enhance communication
- Social media snippets extend reach

### Example 4 (Security Hotfix)
- Speed is critical for security releases
- Clear severity and impact assessment
- Immediate action steps highlighted
- Multiple notification channels used