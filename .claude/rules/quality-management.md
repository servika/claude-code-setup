# Software Quality Management & Incident Response

These guidelines define quality assurance, incident management, root cause analysis, and continuous improvement practices for Node.js/React/MUI projects.

Based on CAPA (Corrective and Preventive Action) principles adapted for software development.

---

## Overview

Software quality management ensures reliability, security, and maintainability through systematic processes for:
- **Incident Detection**: Identifying bugs, errors, and performance issues
- **Root Cause Analysis**: Understanding why problems occur
- **Corrective Actions**: Fixing immediate issues
- **Preventive Actions**: Preventing future occurrences
- **Continuous Improvement**: Learning and adapting processes

---

## Incident Classification

### Severity Levels

**P0 - Critical**
- Production system down or unavailable
- Data loss or corruption
- Security breach or vulnerability actively exploited
- Payment/transaction system failure
- User authentication completely broken

**Response Time**: Immediate (within 15 minutes)
**Resolution Target**: 4 hours
**Notification**: All stakeholders, create incident channel

**P1 - High**
- Major feature completely broken
- Significant performance degradation
- Security vulnerability discovered (not yet exploited)
- Data integrity issues affecting multiple users
- API endpoint returning 5xx errors

**Response Time**: 1 hour
**Resolution Target**: 24 hours
**Notification**: Development team, product owner

**P2 - Medium**
- Feature partially working
- Minor performance issues
- UI/UX bugs affecting usability
- Non-critical API errors
- Edge case failures

**Response Time**: 4 hours
**Resolution Target**: 1 week
**Notification**: Development team

**P3 - Low**
- Cosmetic issues
- Minor UI inconsistencies
- Documentation errors
- Non-blocking warnings in logs
- Enhancement requests

**Response Time**: Next business day
**Resolution Target**: Next sprint
**Notification**: Development team

### Incident Types

**1. Bug - Code Defect**
```javascript
// Example: Null pointer causing crash
function getUserName(user) {
  return user.name.toUpperCase(); // ❌ Crashes if user is null
}
```

**2. Configuration Issue**
```javascript
// Example: Wrong environment variable
const API_URL = process.env.API_URL; // ❌ Undefined in production
```

**3. Performance Issue**
```javascript
// Example: N+1 query problem
for (const user of users) {
  const posts = await db.posts.find({ userId: user.id }); // ❌ Slow
}
```

**4. Security Vulnerability**
```javascript
// Example: SQL injection vulnerability
const query = `SELECT * FROM users WHERE email = '${email}'`; // ❌ Unsafe
```

**5. Data Integrity Issue**
```javascript
// Example: Duplicate records created
await createUser(userData); // ❌ No unique constraint check
await createUser(userData); // Creates duplicate
```

**6. Integration Failure**
```javascript
// Example: Third-party API timeout
const response = await fetch(apiUrl); // ❌ No timeout, no retry
```

---

## Incident Response Process

### Phase 1: Detection & Triage (0-15 minutes)

**Detection Sources**
- User reports
- Error monitoring (Sentry, Rollbar, etc.)
- APM alerts (New Relic, DataDog, etc.)
- Log aggregation (CloudWatch, ELK Stack)
- Synthetic monitoring
- User analytics (drop in active users)

**Immediate Actions**

1. **Acknowledge Incident**
   ```markdown
   ## Incident: Production Login Failure

   **Detected**: 2025-01-11 14:32 UTC
   **Severity**: P1 - High
   **Affected**: All users unable to login
   **Status**: Investigating
   **Responder**: @john-doe
   ```

2. **Create Incident Channel/Thread**
   - Slack channel: `#incident-2025-01-11-login`
   - GitHub Issue: `[P1] Production login failure`
   - Status page: Update if user-facing

3. **Gather Initial Information**
   - What is broken?
   - When did it start?
   - How many users affected?
   - Error messages/stack traces?
   - Recent deployments or changes?

**Triage Checklist**
- [ ] Severity level assigned
- [ ] Incident responder assigned
- [ ] Stakeholders notified
- [ ] Communication channel created
- [ ] Initial impact assessed
- [ ] Recent changes reviewed

### Phase 2: Containment & Mitigation (15 minutes - 4 hours)

**Immediate Containment Actions**

**Option 1: Rollback**
```bash
# Revert to last known good version
git revert <commit-hash>
git push origin main

# Or rollback deployment
./deploy.sh v1.2.3  # Previous stable version
```

**Option 2: Feature Flag Disable**
```javascript
// Disable problematic feature
if (featureFlags.newAuth && !incident.active) {
  return <NewAuthFlow />;
}
return <LegacyAuthFlow />; // Fallback to stable version
```

**Option 3: Hot Patch**
```javascript
// Quick fix for critical issue
// Before (broken)
const user = users.find(u => u.id === userId);
return user.name.toUpperCase(); // ❌ Crashes if undefined

// After (hot patch)
const user = users.find(u => u.id === userId);
if (!user) {
  logger.error('User not found', { userId });
  return 'Unknown User'; // ✓ Safe fallback
}
return user.name.toUpperCase();
```

**Option 4: Traffic Routing**
```nginx
# Redirect traffic to backup service
location /api/auth {
  proxy_pass http://backup-auth-service:3000;
}
```

**Containment Checklist**
- [ ] Stop the bleeding (rollback/disable/patch)
- [ ] Verify mitigation effective
- [ ] Monitor for side effects
- [ ] Update stakeholders
- [ ] Document actions taken

### Phase 3: Investigation & Root Cause Analysis (1-48 hours)

**Investigation Protocol**

1. **Reproduce the Issue**
   - Can you trigger it locally?
   - What are the exact steps?
   - Does it happen consistently?

2. **Collect Evidence**
   - Error logs and stack traces
   - Database queries and performance metrics
   - Network requests and responses
   - Browser console errors
   - Server metrics (CPU, memory, disk)
   - Recent code changes (git log, PRs)

3. **Build Timeline**
   ```markdown
   ## Incident Timeline

   - 14:15 UTC - Deployed v1.3.0 to production
   - 14:20 UTC - First error in Sentry: "Cannot read property 'token' of undefined"
   - 14:25 UTC - Error rate spike: 50 errors/minute
   - 14:32 UTC - User report: "Can't login"
   - 14:35 UTC - Incident declared (P1)
   - 14:40 UTC - Identified: JWT middleware bug in new release
   - 14:45 UTC - Rolled back to v1.2.3
   - 14:50 UTC - Verified: Login working, error rate back to normal
   - 15:00 UTC - Incident mitigated, moving to RCA
   ```

4. **Perform Root Cause Analysis**
   (See RCA Methodologies section below)

**Investigation Checklist**
- [ ] Issue reproduced in test environment
- [ ] Logs and metrics collected
- [ ] Timeline documented
- [ ] Root cause identified
- [ ] Contributing factors noted
- [ ] Scope of impact quantified

### Phase 4: Resolution & Verification (4 hours - 1 week)

**Corrective Action Plan**

```markdown
## Corrective Actions - Login Failure Incident

### Root Cause
JWT middleware assumed `req.user` always exists, but new code path
skips user population for certain API endpoints.

### Immediate Fix
- [x] Rolled back to v1.2.3 (completed 14:45 UTC)
- [ ] Write failing test reproducing the bug
- [ ] Fix JWT middleware to handle missing user gracefully
- [ ] Add null checks and error handling
- [ ] Add unit tests for edge cases
- [ ] Add integration test for affected endpoints
- [ ] Code review with security focus
- [ ] Deploy fix to staging
- [ ] Verify fix in staging
- [ ] Deploy to production
- [ ] Monitor for 24 hours

### Preventive Actions
- [ ] Add pre-deployment smoke tests for auth endpoints
- [ ] Implement gradual rollout (canary deployment)
- [ ] Add monitoring alert for auth error spike
- [ ] Update authentication testing guidelines
- [ ] Conduct team retrospective

### Success Criteria
- No auth-related errors in production for 7 days
- Test coverage for auth module increased to 90%
- Monitoring alerts functional and tested
- Deployment runbook updated

**Owner**: @john-doe
**Target Completion**: 2025-01-13
**Verification Date**: 2025-01-20
```

**Resolution Checklist**
- [ ] Fix implemented and tested
- [ ] Code review completed
- [ ] Tests added (reproduce bug, verify fix)
- [ ] Deployed to staging and verified
- [ ] Deployed to production
- [ ] Monitoring confirms resolution
- [ ] Documentation updated

### Phase 5: Verification & Closure (1-4 weeks)

**Effectiveness Verification**

Wait 1-4 weeks depending on severity, then verify:

```markdown
## Incident Verification - Login Failure

**Original Incident**: P1 - Login failure due to JWT middleware bug
**Fixed**: 2025-01-12
**Verification Date**: 2025-01-20 (7 days post-fix)

### Verification Results

✅ **No Recurrence**: Zero auth-related errors since fix deployed
✅ **Metrics Improved**: Auth endpoint error rate: 0.01% (down from 2.5%)
✅ **Monitoring Active**: Alert fired successfully in test (false alarm)
✅ **Tests Passing**: Auth module test coverage: 92% (up from 65%)
✅ **Process Improved**: Canary deployment implemented, 3 successful deploys

### Lessons Learned
- Rollback worked quickly (5 minutes) - good DR process
- Lack of pre-deployment auth tests allowed bug to reach production
- Error monitoring caught issue quickly (8 minutes to detection)
- Need better testing for edge cases in authentication flow

### Recommendations
- Add authentication smoke tests to pre-deployment checklist ✓
- Implement gradual rollout for all deployments ✓
- Schedule quarterly auth security review

**Status**: VERIFIED & CLOSED
**Verified By**: @sarah-tech-lead
**Date**: 2025-01-20
```

**Closure Checklist**
- [ ] Fix verified effective (no recurrence)
- [ ] Metrics confirm improvement
- [ ] Preventive actions completed
- [ ] Lessons learned documented
- [ ] Team retrospective held
- [ ] Knowledge base updated
- [ ] Incident closed in tracking system

---

## Root Cause Analysis Methodologies

### 1. Five Whys Analysis

**Best For**: Straightforward issues with linear cause chains

**Method**: Ask "Why?" five times to drill down to root cause

**Example: API Timeout Issue**

```markdown
## Five Whys: API Timeout on /api/users

**Problem**: Users experiencing timeouts on /api/users endpoint

1. **Why is the API timing out?**
   → Because the database query takes 30+ seconds

2. **Why does the query take so long?**
   → Because it's doing a full table scan on 10M records

3. **Why is it doing a full table scan?**
   → Because there's no index on the email column

4. **Why is there no index?**
   → Because we migrated to a new database schema and forgot to recreate indexes

5. **Why did we forget to recreate indexes?**
   → Because our migration checklist didn't include index verification

**Root Cause**: Migration checklist incomplete - missing index verification step

**Corrective Action**:
- Add index on email column
- Add migration validation script
- Update migration checklist

**Preventive Action**:
- Automate index verification in CI/CD
- Document required indexes in schema files
- Add query performance tests
```

### 2. Fishbone Diagram (Ishikawa)

**Best For**: Complex issues with multiple contributing factors

**Method**: Categorize potential causes

**Categories for Software**:
- **Code**: Logic errors, edge cases, technical debt
- **Environment**: Configuration, infrastructure, dependencies
- **Process**: Testing gaps, review process, deployment procedure
- **People**: Knowledge gaps, communication issues, workload
- **Tools**: Monitoring, testing frameworks, development tools
- **Data**: Schema issues, data quality, migrations

**Example: Production Data Corruption**

```markdown
## Fishbone Diagram: User Profile Data Corrupted

                     Code
                      |
          Missing validation ----
          Race condition --------
                                  \
Environment                        \
     |                              \
Concurrent writes enabled --------  → [USER PROFILE]
No transaction isolation ----------  →  DATA CORRUPTED
                                  /
Process                          /
     |                          /
No integration tests -----------
Manual deployment process -----
                     |
                   People

**Analysis**:
- **Primary Cause**: Race condition in profile update code
- **Contributing**: No validation on concurrent writes
- **Contributing**: Lack of integration tests for concurrent updates
- **Enabling**: Manual deployment allowed buggy code through

**Root Cause**: Insufficient concurrent update handling in code

**Actions**:
- Implement optimistic locking on user profiles
- Add transaction isolation for profile updates
- Write integration tests for concurrent scenarios
- Add deployment checklist for data integrity features
```

### 3. Fault Tree Analysis

**Best For**: Safety-critical or cascading failures

**Method**: Work backward from failure event using logic gates

**Example: Payment Processing Failure**

```
                 [Payment Fails]
                       |
                  (OR gate)
                   /   |   \
                  /    |    \
         [API Down] [Timeout] [Validation Error]
              |         |              |
         (AND gate)  (OR gate)    (OR gate)
           /   \      /   \        /    \
    [Server] [DB] [Network] [Code] [Card] [Amount]
```

**Analysis**:
```markdown
## Fault Tree: Payment Processing Failure

**Top Event**: Payment transaction fails

**Immediate Causes** (OR - any one causes failure):
1. Payment API is down
2. Request times out
3. Validation error

**Analysis of API Down** (AND - both required):
- Web server crashed (memory leak)
- Health check not configured (no auto-restart)

**Analysis of Timeout** (OR - any one):
- Network latency spike
- Database query slow (missing index)

**Root Causes Identified**:
1. Memory leak in payment service (code issue)
2. Missing health check configuration (deployment issue)
3. Missing database index (schema issue)

**Actions**:
- Fix memory leak (profile and patch)
- Configure health checks and auto-restart
- Add database index
- Add timeout retry logic
- Implement circuit breaker pattern
```

### 4. Timeline Analysis

**Best For**: Incident reconstruction, understanding sequence of events

**Method**: Build detailed timeline with all relevant events

**Example: Security Breach**

```markdown
## Timeline Analysis: Unauthorized Data Access

| Time (UTC) | Event | Source | Impact |
|------------|-------|--------|--------|
| 2025-01-10 08:00 | Deployed v2.1.0 with new admin panel | Deploy logs | No immediate impact |
| 2025-01-10 09:15 | First suspicious API calls to /api/admin/users | Access logs | Unknown at time |
| 2025-01-10 09:30 | 500 user records downloaded | DB logs | Data breach |
| 2025-01-10 10:45 | Security monitoring alert triggered | Sentry | Detection |
| 2025-01-10 11:00 | Investigation started | Incident log | Response begins |
| 2025-01-10 11:15 | Discovered: Missing auth check in new admin endpoint | Code review | Root cause identified |
| 2025-01-10 11:30 | Admin panel disabled via feature flag | Deploy | Containment |
| 2025-01-10 12:00 | Fixed auth middleware deployed | Deploy | Resolution |

**Critical Period**: 09:15-10:45 (1.5 hours undetected)

**Root Cause**:
New admin panel endpoint deployed without authentication middleware.
Code review missed this because auth was checked at route level (file above),
but new route was added in separate file without auth import.

**Contributing Factors**:
- Auth not enforced at application level (only per-route)
- Code review checklist didn't include auth verification
- No security testing in CI/CD
- Detection took 1.5 hours (monitoring not sensitive enough)

**Actions**:
- Implement application-level auth middleware (all routes default protected)
- Add security scanning to CI/CD (detect missing auth)
- Update code review checklist with security section
- Improve monitoring to detect unusual access patterns faster (<5 min)
- Notify affected users per security breach protocol
```

### 5. Comparative Analysis

**Best For**: Understanding why issue occurs in some cases but not others

**Method**: Compare working vs. broken scenarios

**Example: Feature Works in Dev, Fails in Production**

```markdown
## Comparative Analysis: Login Works in Dev, Fails in Prod

| Factor | Development (Working) | Production (Broken) | Difference? |
|--------|----------------------|---------------------|-------------|
| Node Version | 18.12.0 | 18.12.0 | ✓ Same |
| Database | PostgreSQL 14 local | PostgreSQL 14 RDS | ✓ Same version |
| Environment Vars | .env.local (all set) | AWS Secrets Manager | ⚠️ Different source |
| Network | localhost | Load balancer + ALB | ⚠️ Different |
| HTTPS | http:// | https:// | ⚠️ Different |
| Cookie Settings | secure: false | secure: true | ⚠️ Different |
| SameSite | 'lax' | 'none' | ⚠️ Different |

**Investigation**:
Testing with `secure: true` and `sameSite: 'none'` in dev environment...
→ Login fails! Reproduced!

**Root Cause**:
SameSite='none' requires Secure flag, but dev uses HTTP.
Production uses HTTPS but SameSite setting incorrect for cross-origin requests.

**Fix**:
- Set sameSite: 'strict' for same-origin deployment
- Or properly configure CORS and use sameSite: 'none' with secure: true
- Update dev environment to use HTTPS (localhost SSL)
```

### 6. Code Review Analysis

**Best For**: Bugs introduced in recent changes

**Method**: Review code changes leading up to the issue

**Example: New Feature Breaks Existing Functionality**

```markdown
## Code Review Analysis: User Search Broken After Profile Update

**Symptom**: User search returns no results after v1.5.0 deployment

**Recent Changes**: Git diff v1.4.0...v1.5.0 affecting user search

**Change 1**: Updated User model
```javascript
// Before (v1.4.0)
const UserSchema = {
  name: String,
  email: String,
  searchable: Boolean
};

// After (v1.5.0)
const UserSchema = {
  name: String,
  email: String,
  profile: {
    bio: String,
    avatar: String
  },
  searchable: Boolean  // ✓ Still present
};
```

**Change 2**: Updated search query
```javascript
// Before (v1.4.0)
const users = await User.find({
  name: { $regex: query, $options: 'i' },
  searchable: true
});

// After (v1.5.0)
const users = await User.find({
  'profile.bio': { $regex: query, $options: 'i' },
  searchable: true  // ✓ Still checked
});
```

**Found It!**: Search now only looks in profile.bio, not in name!

**Root Cause**:
Refactoring changed search field from 'name' to 'profile.bio' without
including 'name' field. Should search both name AND bio.

**Fix**:
```javascript
const users = await User.find({
  $or: [
    { name: { $regex: query, $options: 'i' } },
    { 'profile.bio': { $regex: query, $options: 'i' } }
  ],
  searchable: true
});
```

**Preventive Action**:
- Add integration test for name-based search (was missing)
- Update QA checklist to test existing functionality after refactoring
```

---

## Corrective Actions vs. Preventive Actions

### Corrective Actions (Fix the Issue)

**Purpose**: Address the immediate problem and prevent recurrence

**Examples**:

1. **Bug Fix**
   ```javascript
   // Problem: Null pointer exception
   // Corrective Action: Add null check

   function getUserName(user) {
     if (!user) {
       logger.warn('User is null');
       return 'Unknown';
     }
     return user.name;
   }
   ```

2. **Configuration Fix**
   ```bash
   # Problem: Missing environment variable
   # Corrective Action: Add to deployment

   export JWT_SECRET="generated-secret-key-min-32-chars"
   ```

3. **Data Fix**
   ```sql
   -- Problem: Corrupted user records
   -- Corrective Action: Data cleanup script

   UPDATE users
   SET email = LOWER(TRIM(email))
   WHERE email != LOWER(TRIM(email));
   ```

4. **Infrastructure Fix**
   ```yaml
   # Problem: Insufficient memory causing crashes
   # Corrective Action: Increase container memory

   resources:
     limits:
       memory: "1Gi"  # Increased from 512Mi
   ```

### Preventive Actions (Prevent Future Issues)

**Purpose**: Address systemic issues and prevent similar problems

**Examples**:

1. **Add Tests**
   ```javascript
   // Preventive Action: Add test to catch null scenarios

   describe('getUserName', () => {
     it('should handle null user gracefully', () => {
       expect(getUserName(null)).toBe('Unknown');
     });

     it('should handle undefined user gracefully', () => {
       expect(getUserName(undefined)).toBe('Unknown');
     });
   });
   ```

2. **Add Validation**
   ```javascript
   // Preventive Action: Validate at API boundary

   const configSchema = z.object({
     JWT_SECRET: z.string().min(32),
     DATABASE_URL: z.string().url(),
     PORT: z.number().int().positive()
   });

   // Validate on startup
   const config = configSchema.parse(process.env);
   ```

3. **Add Monitoring**
   ```javascript
   // Preventive Action: Alert on errors

   app.use((err, req, res, next) => {
     logger.error('Uncaught error', { error: err, url: req.url });

     // Alert if error rate > 10/min
     errorRateMonitor.increment();

     res.status(500).json({ error: 'Internal server error' });
   });
   ```

4. **Process Improvement**
   ```markdown
   # Preventive Action: Update deployment checklist

   ## Pre-Deployment Checklist
   - [ ] All tests passing
   - [ ] Environment variables documented
   - [ ] Database migrations tested
   - [ ] Rollback procedure documented
   - [ ] Monitoring alerts configured  ← New
   - [ ] Load testing completed  ← New
   - [ ] Security scan passed  ← New
   ```

5. **Refactoring**
   ```javascript
   // Preventive Action: Reduce complexity

   // Before: Complex nested conditions
   if (user && user.profile && user.profile.settings && user.profile.settings.notifications) {
     // ...
   }

   // After: Optional chaining
   if (user?.profile?.settings?.notifications) {
     // ...
   }
   ```

6. **Documentation**
   ```markdown
   # Preventive Action: Document known gotchas

   ## Authentication Module - Common Issues

   ### JWT Token Expiration
   - Tokens expire after 1 hour
   - Refresh tokens expire after 7 days
   - Always check token validity before use
   - Return 401 with clear message on expiration

   ### Cookie Settings
   - Must use `httpOnly: true` in production
   - Must use `secure: true` with HTTPS
   - SameSite must be 'strict' for same-origin
   ```

---

## Quality Metrics & KPIs

### Incident Metrics

**Track to Improve**

1. **Mean Time to Detect (MTTD)**
   - Time from incident occurrence to detection
   - Target: < 5 minutes for P0/P1
   - Improve with: Better monitoring, alerting, synthetic checks

2. **Mean Time to Acknowledge (MTTA)**
   - Time from detection to acknowledgment
   - Target: < 15 minutes for P0, < 1 hour for P1
   - Improve with: Clear on-call procedures, escalation paths

3. **Mean Time to Resolve (MTTR)**
   - Time from detection to resolution
   - Target: < 4 hours for P0, < 24 hours for P1
   - Improve with: Better rollback procedures, incident playbooks

4. **Incident Recurrence Rate**
   - Percentage of incidents that recur within 30 days
   - Target: < 5%
   - Improve with: Better RCA, thorough preventive actions

5. **First-Time Fix Rate**
   - Percentage of issues fixed correctly on first attempt
   - Target: > 90%
   - Improve with: Better testing, code review, RCA

**Example Metrics Dashboard**

```markdown
## Incident Metrics - Q1 2025

| Metric | Current | Target | Trend | Status |
|--------|---------|--------|-------|--------|
| MTTD (P0/P1) | 3.2 min | < 5 min | ↓ | ✅ Good |
| MTTA (P0) | 8 min | < 15 min | → | ✅ Good |
| MTTR (P0) | 2.1 hrs | < 4 hrs | ↓ | ✅ Good |
| MTTR (P1) | 18 hrs | < 24 hrs | ↓ | ✅ Good |
| Recurrence Rate | 8% | < 5% | ↑ | ⚠️ At Risk |
| First-Time Fix | 87% | > 90% | ↑ | ⚠️ At Risk |

**Analysis**:
- Detection and response times improved with new monitoring
- Recurrence rate increased - need better RCA follow-through
- First-time fix rate below target - inadequate testing before deployment

**Actions**:
- Mandate effectiveness verification for all P0/P1 incidents
- Require test coverage for all bug fixes (no exceptions)
- Add "similar issues check" to RCA process
```

### Code Quality Metrics

**Track Trends, Not Absolutes**

1. **Bug Density**
   - Bugs per 1000 lines of code
   - Track by module, severity
   - Compare pre/post refactoring

2. **Defect Escape Rate**
   - Bugs found in production vs. pre-production
   - Target: < 10% escape to production
   - Improve with: Better testing, code review

3. **Test Coverage**
   - Percentage of code covered by tests
   - Target: 60%+ overall, 20%+ per file
   - Track trend over time

4. **Code Churn**
   - Lines changed repeatedly in short time
   - High churn = instability
   - Focus testing on high-churn areas

5. **Technical Debt Ratio**
   - Estimated time to fix / total dev time
   - Target: < 20%
   - Track progress on debt paydown

### System Reliability Metrics

1. **Uptime**
   - Percentage of time system is available
   - Target: 99.9% (< 43 minutes downtime/month)
   - Track per service/component

2. **Error Rate**
   - Errors per total requests
   - Target: < 0.1%
   - Alert on sudden spikes

3. **Response Time (P95/P99)**
   - 95th/99th percentile response times
   - Target: P95 < 500ms, P99 < 1000ms
   - Track per endpoint

4. **Apdex Score**
   - Application Performance Index (0-1)
   - Target: > 0.9
   - User satisfaction metric

---

## Incident Response Templates

### Incident Report Template

```markdown
# Incident Report: [Brief Description]

## Incident Summary

**Incident ID**: INC-2025-001
**Severity**: P1 - High
**Status**: Resolved
**Detected**: 2025-01-11 14:32 UTC
**Resolved**: 2025-01-11 15:45 UTC
**Duration**: 1 hour 13 minutes

**Impact**:
- Users affected: ~5,000 (20% of active users)
- Functionality: Login completely unavailable
- Revenue impact: $0 (no transactions blocked)
- Data impact: None

**Incident Owner**: @john-doe
**Responders**: @sarah-smith, @mike-jones

## Timeline

| Time (UTC) | Event | Action Taken |
|------------|-------|--------------|
| 14:15 | Deployed v1.3.0 | Routine deployment |
| 14:32 | First user report | Ticket created |
| 14:35 | Sentry alert fired | Investigation started |
| 14:40 | Root cause identified | JWT middleware bug |
| 14:45 | Rolled back to v1.2.3 | Deployment |
| 14:50 | Verified login working | Testing |
| 15:00 | Declared incident mitigated | Status update |
| 15:45 | Fix deployed and verified | Resolution |

## Root Cause Analysis

**Problem Statement**:
JWT authentication middleware in v1.3.0 assumed `req.user` object always
exists, but new API endpoints skip user population for performance optimization.

**5 Whys**:
1. Why did login fail? → JWT middleware crashed with null reference
2. Why did middleware crash? → Accessed req.user.id without null check
3. Why no null check? → Assumed user always populated by prior middleware
4. Why was user not populated? → New route optimization skips user load
5. Why did optimization break auth? → No integration test for new route pattern

**Root Cause**: Missing null safety in JWT middleware combined with
untested code path introduced by performance optimization.

**Contributing Factors**:
- Integration tests didn't cover all authentication scenarios
- Code review didn't catch missing null check
- No pre-deployment smoke test for login functionality

## Corrective Actions

**Immediate Fix** (Completed):
- [x] Rolled back deployment (14:45 UTC)
- [x] Added null check to JWT middleware
- [x] Added integration test for new route pattern
- [x] Re-deployed with fix (15:45 UTC)

**Short-term** (Within 1 week):
- [ ] Audit all middleware for null safety
- [ ] Add TypeScript strict null checks
- [ ] Expand integration test coverage for auth

## Preventive Actions

**Process Improvements**:
- [ ] Add pre-deployment smoke test suite (includes login test)
- [ ] Update code review checklist: "All user object accesses null-checked"
- [ ] Implement gradual rollout (canary deploy 10% first)

**Technical Improvements**:
- [ ] Enable TypeScript strict mode project-wide
- [ ] Add monitoring alert for auth error rate > 1%
- [ ] Implement circuit breaker for auth service

**Documentation**:
- [ ] Document common null safety patterns
- [ ] Update authentication testing guide
- [ ] Create runbook for auth-related incidents

## Verification

**Verification Date**: 2025-01-18 (7 days post-incident)
**Verification Criteria**:
- No auth-related errors in production for 7 days
- Pre-deployment smoke tests executed successfully 3 times
- Canary deployment process functional

**Status**: PENDING (verification scheduled for 2025-01-18)

## Lessons Learned

**What Went Well**:
- Quick detection (Sentry alert within 3 minutes)
- Fast rollback procedure (under 10 minutes)
- Clear communication with stakeholders
- Team collaborated effectively

**What Didn't Go Well**:
- Lack of pre-deployment auth testing allowed bug to reach production
- No gradual rollout meant all users affected simultaneously
- Integration tests had gaps for new code patterns

**Recommendations**:
1. Implement mandatory pre-deployment smoke tests
2. Require gradual rollout for all deployments
3. Expand integration test coverage (target: 80%)
4. Consider TypeScript strict mode to catch null issues at compile time

## Sign-off

**Incident Report Prepared By**: John Doe (@john-doe)
**Date**: 2025-01-11

**Reviewed By**: Sarah Smith (Tech Lead) (@sarah-smith)
**Date**: 2025-01-12

**Approved By**: Mike Jones (Engineering Manager) (@mike-jones)
**Date**: 2025-01-12
```

### Post-Incident Review (PIR) Template

```markdown
# Post-Incident Review: [Incident Name]

**Meeting Date**: 2025-01-12
**Attendees**: Dev Team, Product Owner, QA Lead

## Incident Overview
- **Severity**: P1
- **Duration**: 1h 13m
- **Users Affected**: ~5,000
- **Root Cause**: JWT middleware null reference

## Blameless Retrospective

### What Happened?
[Factual timeline of events - no blame]

### Why Did It Happen?
[Root causes and contributing factors]

### What Did We Learn?

**Technical Lessons**:
- Null safety critical in authentication code
- Integration tests must cover all code paths
- TypeScript strict mode catches these issues

**Process Lessons**:
- Pre-deployment testing insufficient
- Gradual rollout would have limited impact
- Rollback procedure worked well

### What Are We Changing?

**Immediate (This Week)**:
1. Add pre-deployment smoke test suite
2. Enable TypeScript strict mode
3. Audit auth code for null safety

**Short-term (This Month)**:
1. Implement gradual rollout for deployments
2. Expand integration test coverage
3. Add auth error rate monitoring

**Long-term (This Quarter)**:
1. Comprehensive auth security review
2. Chaos engineering for auth failures
3. Disaster recovery drills

### Action Items

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Create smoke test suite | @john-doe | 2025-01-15 | In Progress |
| Enable TS strict mode | @sarah | 2025-01-18 | Not Started |
| Implement canary deploy | @mike | 2025-01-20 | Not Started |
| Auth code audit | @team | 2025-01-25 | Not Started |

### Follow-up Meeting
**Date**: 2025-02-01
**Purpose**: Review completion of action items and verify effectiveness
```

### Incident Playbook Template

```markdown
# Incident Playbook: [Type of Incident]

## Scenario
[Description of when to use this playbook]

## Severity Assessment
- **P0 (Critical)**: [Criteria]
- **P1 (High)**: [Criteria]
- **P2 (Medium)**: [Criteria]
- **P3 (Low)**: [Criteria]

## Initial Response (First 15 Minutes)

### 1. Acknowledge Incident
```bash
# Create incident channel
slack notify "#incident-response" "P1 Incident: [Brief description]"

# Create GitHub issue
gh issue create --title "[P1] [Description]" --label incident
```

### 2. Gather Information
- Check error monitoring (Sentry, Rollbar)
- Check APM (New Relic, DataDog)
- Check logs (CloudWatch, ELK)
- Check recent deployments
- Check user reports

### 3. Quick Diagnostics
```bash
# Check service health
curl https://api.example.com/health

# Check error rate
datadog metric query "sum:api.errors{*}.as_count()"

# Check recent deployments
git log --oneline -10
```

## Containment (15-60 Minutes)

### Option 1: Rollback
```bash
# Identify last good version
git log --oneline

# Deploy previous version
./deploy.sh v1.2.3
```

### Option 2: Disable Feature
```javascript
// Feature flag disable
admin.setFeatureFlag('problematic-feature', false);
```

### Option 3: Traffic Routing
```bash
# Route traffic away from broken service
kubectl scale deployment broken-service --replicas=0
kubectl scale deployment backup-service --replicas=3
```

## Investigation

### Checklist
- [ ] Reproduce issue in test environment
- [ ] Collect error logs
- [ ] Review recent code changes
- [ ] Check third-party services status
- [ ] Perform RCA (5 Whys, Fishbone, etc.)

## Resolution

### Fix Deployment
```bash
# Create hotfix branch
git checkout -b hotfix/incident-fix

# Make fix, commit, and push
git add .
git commit -m "fix: resolve [incident issue]"
git push origin hotfix/incident-fix

# Deploy to staging
./deploy.sh staging hotfix/incident-fix

# Verify fix
npm run test:staging

# Deploy to production
./deploy.sh production hotfix/incident-fix

# Monitor
watch -n 5 'curl https://api.example.com/health'
```

## Communication Template

```markdown
**Status Update**

Incident: [Brief description]
Status: [Investigating/Mitigated/Resolved]
Impact: [Users affected, functionality]
Actions: [What we've done]
Next steps: [What's planned]
ETA: [Expected resolution time]

Last updated: [Timestamp]
```

## Verification

- [ ] Issue resolved in production
- [ ] Monitoring shows normal metrics
- [ ] No error reports for 30 minutes
- [ ] User reports confirmed fixed
- [ ] Stakeholders notified

## Post-Incident

- [ ] Create incident report (within 24 hours)
- [ ] Schedule PIR meeting (within 3 days)
- [ ] Document lessons learned
- [ ] Update playbook if needed
- [ ] Track corrective/preventive actions

## Contacts

- **On-call Engineer**: [Pager Duty / Phone]
- **Tech Lead**: [Contact info]
- **Engineering Manager**: [Contact info]
- **Product Owner**: [Contact info]
- **Customer Support**: [Contact info]
```

---

## Continuous Improvement Process

### Trend Analysis

**Monthly Quality Review**

```markdown
## Quality Metrics Review - January 2025

### Incident Trends

**Total Incidents**: 12 (vs 15 last month)
**By Severity**:
- P0: 0 (vs 1 last month) ✅
- P1: 2 (vs 3 last month) ✅
- P2: 6 (vs 7 last month) →
- P3: 4 (vs 4 last month) →

**By Type**:
- Bugs: 7 (58%)
- Configuration: 2 (17%)
- Performance: 2 (17%)
- Security: 1 (8%)

**By Component**:
- Authentication: 3 incidents ⚠️ Hot spot
- API Gateway: 2 incidents
- Database: 2 incidents
- Frontend: 5 incidents

### Root Cause Patterns

**Top 3 Root Causes**:
1. Missing null checks (4 incidents) ⚠️ Pattern
2. Configuration errors (2 incidents)
3. Race conditions (2 incidents) ⚠️ Pattern

### Recommendations

**Immediate Actions**:
1. Audit codebase for null safety issues
2. Enable TypeScript strict null checks
3. Add concurrency testing to test suite

**Short-term**:
1. Create null safety coding standard
2. Implement configuration validation
3. Add race condition detection in code review

**Long-term**:
1. Consider formal verification for critical paths
2. Implement property-based testing
3. Architecture review for auth module
```

### Quality Improvement Initiatives

**Initiative Template**

```markdown
## Quality Initiative: Reduce Null Reference Errors

**Problem Statement**:
Null reference errors account for 33% of P1 incidents in Q4 2024.

**Goal**:
Reduce null-related incidents by 80% within 3 months.

**Success Metrics**:
- Null-related incidents: < 1 per month
- TypeScript strict mode enabled: 100% of codebase
- Null check coverage: > 95%

**Approach**:

**Phase 1 - Assessment** (Week 1-2):
- [ ] Audit codebase for null reference patterns
- [ ] Identify high-risk areas
- [ ] Estimate effort for fixes

**Phase 2 - Quick Wins** (Week 3-4):
- [ ] Fix top 10 high-risk null issues
- [ ] Add null checks to critical paths
- [ ] Create null safety coding guide

**Phase 3 - Systematic Fix** (Week 5-8):
- [ ] Enable TypeScript strict null checks incrementally
- [ ] Fix compilation errors module by module
- [ ] Add tests for edge cases

**Phase 4 - Prevention** (Week 9-12):
- [ ] Add ESLint rules for null safety
- [ ] Update code review checklist
- [ ] Team training on null safety patterns

**Resources Required**:
- 20% dev time for 3 months (2 engineers)
- Code review time increase: +10%
- Testing time: +5 hours/week

**Timeline**: Q1 2025 (Jan-Mar)

**Owner**: @sarah-tech-lead

**Status**: In Progress (Week 4/12)
```

---

## Integration with Existing Guidelines

### Connects to Testing Guidelines

From your `.claude/rules/testing.md`:
- Use test structure for incident reproduction
- Apply coverage requirements to bug fixes
- Follow testing best practices for preventive tests

```markdown
When fixing a bug:
1. Write failing test that reproduces the issue ✓
2. Implement fix ✓
3. Verify test passes ✓
4. Check coverage increased ✓
5. Add edge case tests (preventive) ← Quality Management adds this
```

### Connects to Security Guidelines

From your `.claude/rules/security.md`:
- Security incidents follow incident response process
- RCA for security vulnerabilities
- Preventive actions include security improvements

```markdown
Security Incident → Incident Response Process
  ↓
Root Cause Analysis (Why was vulnerability introduced?)
  ↓
Corrective Action (Fix the vulnerability)
  ↓
Preventive Action (Security audit, add scanning, training)
```

### Connects to Commit Policy

From your `.claude/rules/commit-policy.md`:
- Hotfixes follow conventional commit format
- Incident fixes include comprehensive commit messages
- Reference incident in commit body

```markdown
fix(auth): resolve null reference in JWT middleware

JWT middleware crashed when req.user was undefined due to
new route optimization that skips user population.

Added null check and fallback handling.

Fixes INC-2025-001
Closes #234
```

### Connects to Project Management

From your `.claude/rules/project-management.md`:
- Incidents create unplanned work in sprint
- Track incident resolution in TodoWrite
- Preventive actions become backlog items

```markdown
Sprint Planning:
- Planned work: 150 hours
- Reserve for incidents: 20 hours (13%)
- Preventive actions: 10 hours (7%)
```

---

## Summary: Quality Management Checklist

### When Incident Occurs
- [ ] Assess severity and declare incident
- [ ] Create incident channel/issue
- [ ] Gather initial information
- [ ] Contain and mitigate
- [ ] Communicate status to stakeholders

### During Investigation
- [ ] Reproduce issue in test environment
- [ ] Perform root cause analysis
- [ ] Identify corrective actions
- [ ] Identify preventive actions
- [ ] Document findings

### During Resolution
- [ ] Write test reproducing the issue
- [ ] Implement fix
- [ ] Verify fix in staging
- [ ] Deploy to production
- [ ] Monitor for 24-48 hours

### Post-Incident
- [ ] Write incident report (within 24 hours)
- [ ] Hold post-incident review (within 3 days)
- [ ] Complete corrective actions
- [ ] Complete preventive actions
- [ ] Verify effectiveness (1-4 weeks later)
- [ ] Update documentation and playbooks

### Continuous Improvement
- [ ] Track metrics (MTTD, MTTA, MTTR, recurrence)
- [ ] Analyze trends monthly
- [ ] Identify systemic issues
- [ ] Launch improvement initiatives
- [ ] Measure effectiveness

**Remember**: The goal isn't zero incidents (impossible), but continuous improvement in how we prevent, detect, respond to, and learn from incidents.