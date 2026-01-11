# Commit Policy & Code Comments Guidelines

These rules define standards for git commits, commit messages, and code comments in your Node.js/React/MUI project.

---

## Commit Message Format

### Use Conventional Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

**Required prefix for all commits:**

- `feat:` - New feature for the user
- `fix:` - Bug fix for the user
- `docs:` - Documentation changes only
- `style:` - Formatting, missing semicolons, etc. (no code change)
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `build:` - Changes to build system or dependencies
- `ci:` - Changes to CI/CD configuration
- `chore:` - Other changes that don't modify src or test files
- `revert:` - Reverts a previous commit

### Scope (Optional)

Specify what part of the codebase is affected:

- `(api)` - Backend API changes
- `(auth)` - Authentication/authorization
- `(ui)` - User interface components
- `(db)` - Database-related changes
- `(config)` - Configuration files
- `(deps)` - Dependency updates

**Examples:**
```
feat(auth): add password reset functionality
fix(api): resolve race condition in user creation
docs(readme): update installation instructions
```

### Subject Line Rules

1. **Use imperative mood** - "add feature" not "added feature"
2. **Don't capitalize first letter** - "add feature" not "Add feature"
3. **No period at the end** - "add feature" not "add feature."
4. **Maximum 72 characters** - Keep it concise
5. **Be specific** - "fix login button" not "fix bug"

**Good Examples:**
```
feat: add user profile editing
fix: resolve memory leak in event listeners
refactor: extract validation logic to separate module
```

**Bad Examples:**
```
Fixed stuff                    ❌ Vague, past tense
Added new feature.             ❌ Capitalized, has period
feat: updated the codebase     ❌ Not specific enough
WIP                            ❌ Not descriptive
```

### Body (Optional but Recommended)

- Separate from subject with blank line
- Explain **what** and **why**, not **how**
- Wrap at 72 characters
- Use bullet points for multiple changes

**Example:**
```
feat(api): add pagination to user list endpoint

- Implement cursor-based pagination for better performance
- Add query parameters: limit (default 20, max 100) and cursor
- Return pagination metadata in response headers
- Update API documentation with pagination examples

Closes #123
```

### Footer (Optional)

- Reference issue numbers: `Closes #123` or `Fixes #456`
- Breaking changes: `BREAKING CHANGE: description`
- Co-authors: `Co-authored-by: Name <email>`

**Example:**
```
feat(auth)!: change JWT expiration to 1 hour

BREAKING CHANGE: JWT tokens now expire after 1 hour instead of 24 hours.
Clients must implement token refresh logic.

Closes #234
```

---

## Code Comments Policy

### When to Comment

**DO comment when:**
- ✅ Explaining **why** code exists (intent, business logic, constraints)
- ✅ Complex algorithms or non-obvious logic
- ✅ Workarounds for bugs in dependencies
- ✅ Performance optimizations that aren't obvious
- ✅ Security-related decisions
- ✅ Public APIs (use JSDoc)
- ✅ Regex patterns (explain what they match)
- ✅ Magic numbers (explain their significance)

**DON'T comment when:**
- ❌ Code is self-explanatory
- ❌ Repeating what the code already says
- ❌ Commenting out code (delete it instead)
- ❌ TODO comments without context (use issue tracker)

### Comment Style

#### 1. JSDoc for Functions (REQUIRED)

All functions must have JSDoc comments:

```javascript
/**
 * Fetches user by ID from the database
 * @param {string} userId - The unique identifier of the user
 * @returns {Promise<Object>} The user object with id, name, and email
 * @throws {NotFoundError} When user with given ID doesn't exist
 * @throws {DatabaseError} When database connection fails
 */
async function getUserById(userId) {
  if (!userId) {
    throw new ValidationError('User ID is required');
  }

  const user = await db.users.findOne({ id: userId });

  if (!user) {
    throw new NotFoundError(`User ${userId} not found`);
  }

  return user;
}
```

**Required JSDoc tags:**
- `@param` - Parameter description with type
- `@returns` - Return value description with type
- `@throws` - Exceptions that can be thrown

**Optional JSDoc tags:**
- `@example` - Usage examples
- `@deprecated` - Mark deprecated functions
- `@see` - Reference related functions
- `@since` - When the function was added

#### 2. Inline Comments for Complex Logic

**Good inline comments:**

```javascript
// Use binary search for O(log n) performance on sorted array
const index = binarySearch(sortedArray, target);

// Timeout after 30 seconds to prevent hanging requests
const TIMEOUT_MS = 30000;

// Workaround: axios doesn't properly handle 204 responses
// See: https://github.com/axios/axios/issues/1143
if (response.status === 204) {
  return null;
}

// Rate limit: 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
```

**Bad inline comments:**

```javascript
// Increment counter ❌ (obvious)
counter++;

// Set user name ❌ (obvious)
user.name = 'John';

// Call API ❌ (not helpful)
await fetch('/api/users');

// Loop through users ❌ (obvious)
users.forEach(user => {
  // Process user ❌ (doesn't add value)
  processUser(user);
});
```

#### 3. Magic Numbers

Always explain magic numbers:

```javascript
// Good: Explain the number
const MAX_UPLOAD_SIZE = 5 * 1024 * 1024; // 5MB in bytes
const RETRY_DELAY = 2000; // 2 seconds
const MIN_PASSWORD_LENGTH = 8; // OWASP recommendation

// Bad: No explanation
const timeout = 30000; // What unit? Why 30000?
const limit = 100; // Limit of what?
```

#### 4. Regex Patterns

Always explain complex regex:

```javascript
// Good: Explain what it matches
// Matches email format: username@domain.extension
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Matches phone: (123) 456-7890 or 123-456-7890
const phoneRegex = /^(\(\d{3}\)\s?|\d{3}[-\s]?)\d{3}[-\s]?\d{4}$/;

// Bad: No explanation
const pattern = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/; // What does this match?
```

#### 5. React Component Comments

**Component-level JSDoc:**

```javascript
/**
 * UserProfile component displays user information and edit controls
 * @param {Object} props - Component props
 * @param {Object} props.user - User data object
 * @param {string} props.user.id - User unique identifier
 * @param {string} props.user.name - User's full name
 * @param {string} props.user.email - User's email address
 * @param {Function} [props.onEdit] - Optional callback when edit button clicked
 * @param {boolean} [props.readonly] - Whether the profile is read-only
 * @returns {JSX.Element} Rendered user profile component
 */
export function UserProfile({ user, onEdit, readonly = false }) {
  // Memoize expensive formatting to prevent re-renders
  const formattedDate = useMemo(
    () => formatDate(user.createdAt),
    [user.createdAt]
  );

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4">{user.name}</Typography>
      <Typography variant="body1">{user.email}</Typography>
      {!readonly && onEdit && (
        <Button onClick={() => onEdit(user.id)}>Edit</Button>
      )}
    </Box>
  );
}
```

#### 6. Express Route Comments

**Route-level JSDoc:**

```javascript
/**
 * GET /api/users/:id
 * Retrieves a single user by ID
 * @param {string} req.params.id - User ID
 * @returns {Object} 200 - User object
 * @returns {Object} 404 - User not found
 * @returns {Object} 500 - Server error
 */
router.get('/users/:id', authenticate, asyncHandler(async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  res.json(user);
}));

/**
 * POST /api/users
 * Creates a new user account
 * @param {string} req.body.email - User email (required)
 * @param {string} req.body.password - User password (min 8 chars)
 * @param {string} req.body.name - User full name (required)
 * @returns {Object} 201 - Created user object
 * @returns {Object} 400 - Validation error
 * @returns {Object} 409 - Email already exists
 */
router.post('/users', validateUser, asyncHandler(async (req, res) => {
  const user = await userService.createUser(req.body);
  res.status(201).json(user);
}));
```

---

## TODO Comments Policy

### Use Issue Tracker, Not TODO Comments

**Bad:**
```javascript
// TODO: Add validation ❌
// TODO: Fix this later ❌
// TODO: Refactor ❌
// FIXME: This is broken ❌
```

**Good:**
Create a GitHub issue and reference it:

```javascript
// See issue #123: Add email validation
// Temporary workaround for issue #456 - remove after API fix
```

**Only acceptable TODO:**
```javascript
// TODO(username): [Issue #123] Add pagination after v2.0 API is ready
```

Must include:
- Author username
- Issue number
- Specific reason/context

---

## Git Commit Best Practices

### Atomic Commits

**One logical change per commit:**

```bash
# Good: Separate commits
git commit -m "feat(auth): add JWT token generation"
git commit -m "feat(auth): add token refresh endpoint"
git commit -m "test(auth): add token tests"

# Bad: Everything together
git commit -m "Add authentication feature" # Too broad
```

### Commit Frequency

- Commit **after** completing a logical unit of work
- Commit **before** switching tasks
- Commit **before** risky refactoring
- **Don't** commit broken code
- **Don't** commit work-in-progress to main/master

### What NOT to Commit

**Never commit:**
- ❌ Secrets (API keys, passwords, tokens)
- ❌ Environment files (.env)
- ❌ Personal config files (IDE settings)
- ❌ Large binary files (images, videos) without LFS
- ❌ Dependencies (node_modules/)
- ❌ Build artifacts (dist/, build/)
- ❌ Commented-out code
- ❌ Console.log statements
- ❌ Debugger statements

### Commit Checklist

Before committing, verify:

✅ Code passes linting (`npm run lint`)
✅ Tests pass (`npm test`)
✅ Coverage meets threshold (60% minimum)
✅ JSDoc comments added for new functions
✅ No console.log or debugger statements
✅ No secrets or .env files
✅ Commit message follows convention
✅ Code is formatted (`npm run format`)

---

## Co-Authoring Commits

When pair programming or working with AI assistants:

```bash
git commit -m "feat(api): add user search endpoint

Implement fuzzy search with pagination.

Co-authored-by: Partner Name <partner@email.com>
Co-authored-by: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**For AI-assisted development:**
Always credit the AI assistant in commits where it contributed significantly:

```
Co-authored-by: Claude Sonnet 4.5 <noreply@anthropic.com>
Co-authored-by: GitHub Copilot <noreply@github.com>
```

---

## Branch Naming Convention

**Format:** `<type>/<issue-number>-<short-description>`

**Examples:**
```bash
feature/123-user-authentication
bugfix/456-memory-leak-fix
hotfix/789-critical-security-patch
refactor/321-extract-validation-logic
docs/654-update-api-documentation
```

**Rules:**
- Lowercase only
- Use hyphens, not underscores
- Keep it short but descriptive
- Include issue number if available

---

## Branch Completion Workflow

When you've finished development on a feature branch, follow this structured workflow to ensure quality and proper cleanup.

### Step 1: Verify Tests Pass

**Before considering any completion option, verify all tests pass:**

```bash
npm test
```

If tests fail:
- ❌ DO NOT proceed with merge or PR
- Fix failing tests first
- Re-run verification

Only proceed to Step 2 when all tests pass.

### Step 2: Run Pre-Commit Checklist

Verify all quality checks pass:

```bash
# Linting
npm run lint

# Type checking (if TypeScript)
npm run type-check

# Test coverage
npm test -- --coverage

# Build succeeds
npm run build
```

**Verify:**
- ✅ No linting errors
- ✅ All tests pass (100%)
- ✅ Coverage ≥60% overall, ≥20% per file
- ✅ Build succeeds without errors
- ✅ No console.log or debugger statements
- ✅ JSDoc comments on new functions
- ✅ Conventional commit messages

If any checks fail, fix issues before proceeding.

### Step 3: Choose Completion Path

Select one of four options based on your workflow:

#### Option 1: Merge Locally

**When to use:**
- Small, straightforward changes
- Solo developer workflow
- Changes don't need review
- Working on personal project

**Process:**
```bash
# Ensure you're on feature branch
git status

# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge feature/123-your-feature

# Verify tests still pass on merged code
npm test

# Push to remote
git push origin main

# Delete feature branch
git branch -d feature/123-your-feature
```

**Critical:** Always run tests after merging to catch integration issues.

#### Option 2: Push and Create Pull Request (Recommended)

**When to use:**
- Team collaboration
- Changes need review
- Working on shared codebase
- Want feedback before merging

**Process:**
```bash
# Push feature branch to remote
git push -u origin feature/123-your-feature

# Create PR using GitHub CLI
gh pr create --title "feat(api): add user search" \
  --body "$(cat <<'EOF'
## Summary
Adds user search functionality with pagination and filtering.

## Changes
- Implement search endpoint with fuzzy matching
- Add pagination (limit/offset)
- Add filters (role, status, created date)
- Write integration tests for search

## Type of Change
- [x] New feature

## Testing
- [x] Unit tests added
- [x] Integration tests added
- [x] Manual testing completed
- [x] Coverage remains above 60%

## Checklist
- [x] Code follows project style guidelines
- [x] Self-review completed
- [x] JSDoc comments added
- [x] Documentation updated
- [x] Tests pass locally
- [x] Linting passes

Closes #123
EOF
)"
```

See "Pull Request Guidelines" section below for detailed PR template.

#### Option 3: Keep Branch As-Is

**When to use:**
- Work in progress (not ready for review or merge)
- Need to switch context temporarily
- Waiting for dependent changes
- Need feedback before proceeding

**Process:**
```bash
# Push to remote for backup (optional)
git push -u origin feature/123-your-feature

# Note current status
echo "Branch feature/123-your-feature: Work in progress, paused for review"

# Switch to another branch
git checkout main
```

**Remember:** Come back to this branch later and complete with Option 1 or 2.

#### Option 4: Discard Work

**When to use:**
- Experimental work that didn't pan out
- Approach was wrong, starting over
- Requirements changed, work no longer needed

**Process:**
```bash
# Verify you want to delete this work
git log feature/123-your-feature --oneline

# Switch to main branch
git checkout main

# Delete local branch (use -D to force delete)
git branch -D feature/123-your-feature

# Delete remote branch if it exists
git push origin --delete feature/123-your-feature
```

**⚠️ Warning:** This permanently deletes your work. Make sure this is what you want.

**Safety check before discarding:**
1. Review commits: `git log feature/123-your-feature --oneline`
2. Check diff: `git diff main...feature/123-your-feature`
3. Confirm no valuable code will be lost
4. Type the full branch name to confirm deletion

### Step 4: Post-Completion Verification

**After Option 1 (Merged Locally):**
```bash
# Verify main branch is clean
git status

# Verify tests still pass
npm test

# Verify build succeeds
npm run build

# Verify feature branch is deleted
git branch -a | grep feature/123
```

**After Option 2 (Created PR):**
- Monitor PR for review comments
- Address feedback promptly
- Merge when approved
- Delete branch after merge (GitHub does this automatically)

**After Option 3 (Kept As-Is):**
- Add task to comeback to this branch
- Document current status in issue/notes
- Set reminder if time-sensitive

**After Option 4 (Discarded):**
- Close related issue with explanation
- Document reason for discarding
- Update team if relevant

### Common Issues

**Tests pass locally but fail in CI:**
- Check for environment-specific dependencies
- Verify all files are committed
- Check for hardcoded paths or environment variables
- Review CI logs for specific failures

**Merge conflicts:**
```bash
# Update feature branch with latest main
git checkout feature/123-your-feature
git fetch origin
git rebase origin/main

# Resolve conflicts in your editor
# After resolving each file:
git add <resolved-file>

# Continue rebase
git rebase --continue

# Force push to update PR (if already pushed)
git push --force-with-lease origin feature/123-your-feature
```

**Accidentally committed to wrong branch:**
```bash
# Save your changes
git stash

# Switch to correct branch
git checkout correct-branch

# Apply changes
git stash pop
```

---

## Pull Request Guidelines

### PR Title

Follow same format as commits:

```
feat(api): add user search with pagination
```

### PR Description Template

```markdown
## Summary
Brief description of what this PR does.

## Changes
- Bullet list of changes made
- Each change on a new line
- Be specific and clear

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] Coverage remains above 60%

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No console.log or debugger statements
- [ ] Tests pass locally
- [ ] Linting passes

## Related Issues
Closes #123
Related to #456

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Additional Notes
Any other context or information reviewers should know.

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Commit Message Examples

### Feature Addition

```
feat(auth): add OAuth 2.0 Google authentication

- Implement Google OAuth strategy with Passport.js
- Add callback route for OAuth redirect
- Store OAuth tokens securely in database
- Update user model to support OAuth providers

Closes #234
```

### Bug Fix

```
fix(api): resolve race condition in user creation

When multiple requests to create a user arrived simultaneously,
duplicate users were being created despite unique email constraint.

Solution: Added database transaction with explicit lock to serialize
user creation requests.

Fixes #456
```

### Refactoring

```
refactor(validation): extract validation logic to separate module

- Create validation/ directory with schema definitions
- Move Zod schemas from routes to validation/schemas.js
- Add validateRequest middleware for reuse
- Update all routes to use new validation system

No functional changes, improves code organization and reusability.
```

### Performance Improvement

```
perf(api): optimize user list query with database indexing

Added composite index on (created_at, email) columns to speed up
user list queries with sorting and filtering.

Before: 2.3s average
After: 0.12s average

Benchmark results included in #789
```

### Documentation

```
docs(readme): add Docker setup instructions

- Add Docker installation requirements
- Include docker-compose.yml configuration
- Document environment variable setup
- Add troubleshooting section for common Docker issues
```

### Security Fix

```
fix(security): prevent SQL injection in search endpoint

Replaced string concatenation with parameterized queries
in user search functionality.

SECURITY: This patch addresses CVE-2024-XXXXX.
All users should upgrade immediately.

Fixes #999
```

---

## Anti-Patterns to Avoid

### ❌ Vague Commit Messages

```bash
# Bad
git commit -m "fix bug"
git commit -m "update code"
git commit -m "changes"
git commit -m "WIP"
git commit -m "stuff"
```

### ❌ Multiple Unrelated Changes

```bash
# Bad: Mixing concerns
git commit -m "Add user auth, fix CSS, update README, refactor utils"

# Good: Separate commits
git commit -m "feat(auth): add JWT authentication"
git commit -m "fix(ui): correct button alignment in header"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(utils): extract date formatting to utility"
```

### ❌ Committing Everything at Once

```bash
# Bad: Giant commit
git add .
git commit -m "Implement entire feature"

# Good: Break into logical commits
git add src/auth/
git commit -m "feat(auth): add authentication service"
git add src/routes/auth.routes.js
git commit -m "feat(auth): add authentication routes"
git add tests/auth.test.js
git commit -m "test(auth): add authentication tests"
```

### ❌ Meaningless Comments

```javascript
// Bad comments
let x = 5; // Set x to 5 ❌
user.save(); // Save the user ❌
if (isValid) { // Check if valid ❌
  return true; // Return true ❌
}
```

---

## Code Review Comments

When reviewing code:

**Be specific and constructive:**

✅ Good:
```
Consider using `useMemo` here to prevent re-computation on every render.
This calculation runs on every state change but only depends on `userId`.
```

❌ Bad:
```
Optimize this
```

**Suggest alternatives:**

✅ Good:
```
This works, but consider using Zod for validation instead of manual checks.
It provides better type safety and clearer error messages.
Example: z.string().email().min(5)
```

❌ Bad:
```
Don't do it this way
```

---

## Summary

### Commit Messages
- ✅ Use conventional commits format
- ✅ Be specific and descriptive
- ✅ Use imperative mood
- ✅ Keep subject under 72 characters
- ✅ Include issue references
- ✅ Credit co-authors (including AI assistants)

### Code Comments
- ✅ JSDoc for all functions (required)
- ✅ Explain **why**, not **what**
- ✅ Comment complex logic and magic numbers
- ✅ Explain workarounds and hacks
- ✅ No commented-out code
- ❌ No TODO without issue reference

### What to Commit
- ✅ Clean, working code
- ✅ With tests and documentation
- ✅ Formatted and linted
- ❌ No secrets or .env files
- ❌ No debug statements
- ❌ No commented code

**Remember:** Good commits and comments are documentation for your future self and your team!