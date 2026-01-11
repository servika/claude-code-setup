# Release Documentation Generator

Automated generation of professional release notes, changelogs, and version documentation from git commits.

---

## What This Skill Does

Transforms raw git commit history into polished, multi-format release documentation:

1. **Smart Commit Analysis** - Parses Conventional Commits and extracts meaningful changes
2. **Multi-Format Output** - Generates Markdown, JSON, and HTML changelogs
3. **Audience Targeting** - Creates customer-facing, developer, and internal documentation
4. **Semantic Versioning** - Automatically suggests version bumps based on changes
5. **Breaking Changes Detection** - Highlights and documents API changes
6. **Contributor Attribution** - Acknowledges all contributors with proper credit
7. **Release Validation** - Checks for required documentation and patterns

---

## When to Use This Skill

### Use This Skill When:
- ✅ Preparing release notes for npm packages
- ✅ Creating GitHub releases with changelogs
- ✅ Generating customer-facing update announcements
- ✅ Writing app store update descriptions
- ✅ Documenting API changes between versions
- ✅ Creating internal release documentation
- ✅ Generating weekly/monthly update summaries
- ✅ Preparing migration guides for breaking changes

### When NOT to Use:
- ❌ Single commit or trivial changes
- ❌ Pre-alpha/experimental versions without releases
- ❌ Internal feature branches (use regular commit messages)

---

## Core Principles

### 1. Conventional Commits Foundation

This skill requires Conventional Commits format:
```
type(scope): description

[optional body]

[optional footer]
```

**Supported Types:**
- `feat` → New Features
- `fix` → Bug Fixes
- `perf` → Performance Improvements
- `docs` → Documentation
- `style` → Code Style Changes
- `refactor` → Code Refactoring
- `test` → Tests
- `build` → Build System
- `ci` → CI/CD
- `chore` → Maintenance

**Breaking Changes:**
- `BREAKING CHANGE:` in footer
- `!` after type/scope: `feat!:` or `feat(api)!:`

### 2. Audience-Aware Content

Generate different documentation for different audiences:

**Customer-Facing:**
- Focus on user benefits
- Non-technical language
- What changed, why it matters
- Migration steps for breaking changes

**Developer Documentation:**
- Technical implementation details
- API changes with code examples
- Deprecation notices
- New dependencies

**Internal Release Notes:**
- All changes including refactors
- Performance metrics
- Infrastructure updates
- Team acknowledgments

### 3. Semantic Versioning Integration

Automatically determine version bump:
- **MAJOR (X.0.0)**: Breaking changes
- **MINOR (0.X.0)**: New features
- **PATCH (0.0.X)**: Bug fixes only

---

## Usage Patterns

### Pattern 1: Standard Release Changelog

**Scenario:** Creating changelog for next release

```
Claude, use the release-documentation skill to generate a changelog.

Generate changelog from commits since v1.2.3 to HEAD.
Format: Markdown
Audience: Customer-facing
Include: Migration guide for breaking changes
```

**Output:**
- CHANGELOG.md with categorized changes
- Suggested version number (1.3.0)
- Migration guide if needed
- Contributors list

### Pattern 2: Multiple Format Output

**Scenario:** Need changelog in multiple formats for different platforms

```
Claude, generate release documentation for v2.0.0:
- Markdown for GitHub release
- JSON for API consumers
- HTML for website changelog page
```

**Output:**
- `CHANGELOG.md` - GitHub release notes
- `changelog.json` - Structured data
- `changelog.html` - Styled HTML for website

### Pattern 3: Breaking Changes Focus

**Scenario:** Major version with API changes

```
Claude, create migration documentation for v2.0.0:
- List all breaking changes
- Generate upgrade guide
- Include code examples for migrations
- Highlight deprecated features
```

**Output:**
- `MIGRATION_v2.md` with detailed upgrade instructions
- Code examples showing before/after
- Timeline for deprecations

### Pattern 4: Weekly Release Summary

**Scenario:** Regular product updates

```
Claude, generate weekly release summary:
- Commits from last 7 days
- Group by team/component
- Customer-friendly language
- Include screenshots for UI changes
```

**Output:**
- Weekly update blog post draft
- Social media announcement snippets
- Email newsletter content

---

## Output Formats

### Markdown (CHANGELOG.md)

```markdown
# Changelog

## [2.1.0] - 2026-01-09

### 🎉 New Features

- **Authentication**: Add social login with Google and GitHub ([#123](link))
  - Users can now sign in with their Google or GitHub accounts
  - Improved onboarding experience with OAuth 2.0
  - Contributed by @username

- **API**: New real-time notifications endpoint ([#125](link))
  - WebSocket support for instant updates
  - Reduces polling and improves performance
  - Breaking: Requires Socket.IO client update

### 🐛 Bug Fixes

- **UI**: Fix responsive layout on mobile devices ([#126](link))
  - Resolved navbar collapse issue on iPhone
  - Improved touch targets for better accessibility

### ⚡ Performance

- **Backend**: Optimize database queries for user dashboard ([#127](link))
  - 60% faster page load (3.2s → 1.2s)
  - Added Redis caching for frequent queries

### 📚 Documentation

- Add API migration guide for v2.0 breaking changes
- Update installation instructions for Node.js 18+

### 🔧 Internal

- Refactor authentication middleware for better testability
- Upgrade dependencies (Express 4.18 → 4.19)

### 👥 Contributors

Thank you to all contributors who made this release possible:
@username1, @username2, @username3

**Full Changelog**: [v2.0.0...v2.1.0](link)
```

### JSON Format

```json
{
  "version": "2.1.0",
  "releaseDate": "2026-01-09",
  "changes": {
    "features": [
      {
        "scope": "authentication",
        "description": "Add social login with Google and GitHub",
        "impact": "customer-facing",
        "pr": 123,
        "author": "username"
      }
    ],
    "fixes": [
      {
        "scope": "ui",
        "description": "Fix responsive layout on mobile devices",
        "impact": "customer-facing",
        "pr": 126
      }
    ],
    "breaking": [],
    "performance": [
      {
        "scope": "backend",
        "description": "Optimize database queries",
        "metrics": {
          "before": "3.2s",
          "after": "1.2s",
          "improvement": "60%"
        }
      }
    ]
  },
  "contributors": ["username1", "username2"],
  "versionBump": "minor"
}
```

---

## Integration with Commit Policy

This skill works seamlessly with `.claude/rules/commit-policy.md`:

**Commit Policy Ensures:**
- All commits follow Conventional Commits format
- Commits have proper scope and description
- Breaking changes are marked correctly
- Co-authoring is attributed

**Release Documentation Uses:**
- Commit types to categorize changes
- Scopes to group related changes
- Breaking change markers to generate migration guides
- Co-author tags for contributor attribution

---

## Quick Decision Guide

| Scenario | Command | Output |
|----------|---------|--------|
| Regular release | "Generate changelog for v1.5.0" | CHANGELOG.md |
| Major version | "Create migration guide for v2.0.0" | MIGRATION.md + CHANGELOG.md |
| Weekly update | "Weekly summary since last Monday" | Blog post draft |
| Hotfix release | "Changelog for patch v1.4.1" | Brief changelog |
| API documentation | "Document API changes in v2.0" | API_CHANGES.md |
| NPM package | "Generate package.json release notes" | Release notes + version bump |

---

## Best Practices

### ✅ Do

1. **Run from Repository Root**
   ```bash
   cd /path/to/project
   # Then ask Claude to generate changelog
   ```

2. **Specify Version Range Clearly**
   ```
   Good: "Generate changelog from v1.2.3 to HEAD"
   Good: "Changelog for all commits since last Friday"
   Bad: "Make a changelog" (ambiguous)
   ```

3. **Review Before Publishing**
   - Check for sensitive information
   - Verify breaking changes are documented
   - Ensure customer-friendly language
   - Add screenshots for UI changes

4. **Use Semantic Versioning**
   - Breaking changes → MAJOR bump
   - New features → MINOR bump
   - Bug fixes only → PATCH bump

5. **Include Migration Guides**
   - Document all breaking changes
   - Provide code examples
   - Set deprecation timelines

### ❌ Don't

1. **Don't Include Internal Commits**
   - Filter out refactoring (unless significant)
   - Exclude test-only commits
   - Skip dependency updates (unless they affect users)

2. **Don't Use Developer Jargon**
   ```
   Bad: "Refactored UserRepository to use DAO pattern"
   Good: "Improved user data loading performance"
   ```

3. **Don't Forget Breaking Changes**
   - Always highlight API changes
   - Provide upgrade paths
   - Include deprecation notices

4. **Don't Skip Version Numbering**
   - Always suggest appropriate version
   - Follow semantic versioning
   - Link to previous version

---

## Examples

### Example 1: Standard NPM Package Release

**Input:**
```
Claude, generate changelog for my Express API package:
- Version: 2.3.0
- From: v2.2.1 to HEAD
- Format: Markdown
- Audience: Developer
```

**Claude Creates:**

1. Analyzes commits using Conventional Commits
2. Groups by type (feat, fix, perf, etc.)
3. Extracts technical details
4. Generates CHANGELOG.md

**Output in CHANGELOG.md:**
```markdown
## [2.3.0] - 2026-01-09

### Added
- JWT refresh token support (#145)
- Rate limiting middleware with Redis (#147)
- Health check endpoint for load balancers (#149)

### Fixed
- Memory leak in WebSocket connections (#146)
- CORS preflight handling for OPTIONS requests (#148)

### Changed
- Update Express to 4.19.0 for security fixes
- Improve error handling with custom error classes

### Deprecated
- `app.use(oldMiddleware)` - Use `app.use(newMiddleware)` instead
  Will be removed in v3.0.0

### Breaking Changes
None
```

### Example 2: Customer-Facing Release Notes

**Input:**
```
Claude, create user-friendly release announcement:
- Version: 2.0.0
- Include breaking changes migration
- Target: Non-technical users
- Format: Blog post style
```

**Claude Creates:**

Customer-friendly announcement with:
- Plain English descriptions
- Benefits-focused language
- Visual examples
- Clear migration steps

**Output:**
```markdown
# What's New in Version 2.0 🎉

We're excited to announce version 2.0 with powerful new features!

## Sign in with Social Accounts

You can now log in using your Google or GitHub account! No need to
remember another password - just click and go.

**How to use it:**
1. Click "Sign in with Google" on the login page
2. Approve the connection
3. You're in!

## Real-Time Notifications

Get instant updates without refreshing the page. See new messages,
mentions, and activity as they happen.

## Faster Performance

We've made the app 60% faster! Pages now load in under 2 seconds,
even with lots of data.

## Important: Action Required

If you're using our API, you'll need to update your integration.
Check out our [Migration Guide](link) for step-by-step instructions.

## What's Next

We're working on dark mode and mobile apps. Stay tuned!
```

### Example 3: Migration Guide for Breaking Changes

**Input:**
```
Claude, create detailed migration guide for v2.0.0:
- List all breaking changes
- Provide code examples
- Estimate migration time
```

**Claude Creates:**

Comprehensive migration documentation:

**Output in MIGRATION_v2.md:**
```markdown
# Migration Guide: v1.x to v2.0

## Overview

Version 2.0 introduces several breaking changes to improve API consistency
and performance. Migration should take 1-2 hours for most applications.

## Breaking Changes

### 1. Authentication API Changes

**What Changed:**
The authentication endpoint now returns tokens in a different format.

**Before (v1.x):**
```javascript
POST /api/auth/login
Response:
{
  "token": "jwt-token-here"
}
```

**After (v2.0):**
```javascript
POST /api/auth/login
Response:
{
  "accessToken": "jwt-token-here",
  "refreshToken": "refresh-token-here",
  "expiresIn": 3600
}
```

**Migration Steps:**
1. Update your login handler:
```javascript
// Old
const { token } = await login(credentials);
localStorage.setItem('token', token);

// New
const { accessToken, refreshToken } = await login(credentials);
localStorage.setItem('accessToken', accessToken);
localStorage.setItem('refreshToken', refreshToken);
```

2. Update authorization headers:
```javascript
// Old
headers: { 'Authorization': `Bearer ${token}` }

// New (no change, but use accessToken)
headers: { 'Authorization': `Bearer ${accessToken}` }
```

**Estimated Time:** 15 minutes

### 2. WebSocket Events Renamed

**What Changed:**
Event names now follow consistent naming convention.

**Before:**
```javascript
socket.on('user-update', handler);
socket.on('message_received', handler);
```

**After:**
```javascript
socket.on('user:update', handler);
socket.on('message:received', handler);
```

**Migration Script:**
```bash
# Run this find-replace across your codebase
find . -name "*.js" -exec sed -i 's/user-update/user:update/g' {} \;
find . -name "*.js" -exec sed -i 's/message_received/message:received/g' {} \;
```

**Estimated Time:** 5 minutes

## Testing Your Migration

1. Update dependencies:
   ```bash
   npm install @yourapp/api@2.0.0
   ```

2. Run tests:
   ```bash
   npm test
   ```

3. Check for deprecation warnings in console

4. Verify authentication flow works

## Rollback Plan

If you encounter issues:

1. Revert to v1.x:
   ```bash
   npm install @yourapp/api@1.9.0
   ```

2. Report issues: [GitHub Issues](link)

3. Contact support: support@example.com

## Support

- Migration support available in our [Discord](link)
- Documentation: [docs.example.com/v2](link)
- Timeline: v1.x supported until June 2026
```

---

## Error Prevention

### Common Issues

**Issue 1: Missing Commits**
```
Problem: "Changelog is missing recent changes"
Solution: Ensure you're on the latest branch
git fetch origin
git checkout main
git pull
```

**Issue 2: Unclear Commit Messages**
```
Problem: "Commits like 'fix stuff' generate poor changelog"
Solution: Follow commit-policy.md for Conventional Commits
```

**Issue 3: Too Many Internal Changes**
```
Problem: "Changelog includes too many refactoring commits"
Solution: Specify audience and filter criteria
"Generate customer-facing changelog (exclude refactoring)"
```

---

## Advanced Usage

### Custom Categorization

```
Claude, generate changelog with custom categories:
- "Frontend Changes" for (scope:ui OR scope:components)
- "Backend Changes" for (scope:api OR scope:server)
- "Infrastructure" for (scope:ci OR scope:docker)
```

### Performance Metrics

```
Claude, include performance metrics in changelog:
- Extract "X% faster" from commit messages
- Highlight performance improvements
- Add before/after benchmarks
```

### Contributor Highlighting

```
Claude, create changelog with contributor spotlight:
- Group changes by contributor
- Highlight first-time contributors
- Add GitHub profile links
```

---

## Summary

**This Skill Generates:**
- ✅ Professional changelogs in multiple formats
- ✅ Customer-friendly release announcements
- ✅ Detailed migration guides
- ✅ Semantic version recommendations
- ✅ Contributor attribution

**Requirements:**
- Conventional Commits format
- Git repository
- Meaningful commit messages

**Best Results:**
- Run from repository root
- Specify version range clearly
- Review before publishing
- Include migration guides for breaking changes

**Integration:**
- Works with commit-policy.md
- Supports semantic versioning
- Multi-format output
- Audience-aware content