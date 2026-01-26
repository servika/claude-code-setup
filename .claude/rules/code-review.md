# Code Review Guidelines

## Code Review Philosophy

- **Improve code quality** - Not find fault with the author
- **Share knowledge** - Reviews are learning opportunities
- **Be constructive** - Suggest improvements, don't just criticize
- **Respect time** - Review promptly, be thorough but efficient

## Pull Request Guidelines

### PR Size

| Size | Lines Changed | Review Time | Recommendation |
|------|---------------|-------------|----------------|
| Small | < 200 | < 30 min | Ideal |
| Medium | 200-500 | 30-60 min | Acceptable |
| Large | 500-1000 | 1-2 hours | Split if possible |
| XL | > 1000 | > 2 hours | Must split |

### PR Title Format

```
type(scope): brief description

# Examples
feat(auth): add password reset functionality
fix(api): handle null user in profile endpoint
refactor(orders): extract order validation logic
docs(readme): update installation instructions
test(users): add integration tests for user service
chore(deps): update React to v18.2
```

### PR Description Template

```markdown
## Summary

Brief description of what this PR does and why.

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Refactoring (no functional changes)
- [ ] Documentation update
- [ ] Test update

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

### Test Instructions

Steps to test this PR manually:

1. Step 1
2. Step 2
3. Expected result

## Screenshots (if applicable)

[Add screenshots for UI changes]

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Tests pass locally

## Related Issues

Closes #123
Related to #456
```

## Review Checklist

### General Code Quality

- [ ] **Readability**: Code is clear and self-documenting
- [ ] **Simplicity**: No unnecessary complexity
- [ ] **DRY**: No duplicated code that should be extracted
- [ ] **Naming**: Variables, functions, classes have meaningful names
- [ ] **Comments**: Complex logic is explained, no obvious comments
- [ ] **Dead code**: No commented-out code or unused imports

### Functionality

- [ ] **Requirements**: Code implements the requirements correctly
- [ ] **Edge cases**: Handles null, empty, boundary conditions
- [ ] **Error handling**: Errors are caught and handled appropriately
- [ ] **Validation**: User input is validated
- [ ] **State management**: State changes are handled correctly

### Security

- [ ] **Input validation**: All inputs validated and sanitized
- [ ] **Authentication**: Protected routes require auth
- [ ] **Authorization**: Proper permission checks in place
- [ ] **Secrets**: No hardcoded secrets or credentials
- [ ] **SQL injection**: Parameterized queries used
- [ ] **XSS**: User content properly escaped

### Performance

- [ ] **Efficiency**: No obvious performance issues
- [ ] **Database**: Queries are optimized, N+1 avoided
- [ ] **Caching**: Appropriate caching in place
- [ ] **Memory**: No memory leaks or excessive allocations
- [ ] **Async**: Proper async/await usage

### Testing

- [ ] **Coverage**: New code has appropriate tests
- [ ] **Quality**: Tests are meaningful, not just for coverage
- [ ] **Edge cases**: Tests cover error conditions
- [ ] **Isolation**: Tests don't depend on each other

### Documentation

- [ ] **JSDoc**: Functions have proper documentation
- [ ] **README**: Updated if needed
- [ ] **API docs**: Updated for endpoint changes
- [ ] **Comments**: Complex logic explained

## Review Process

### For Reviewers

#### Before Starting

1. Read the PR description and linked issues
2. Understand the context and requirements
3. Check if PR is appropriately sized

#### During Review

1. **First pass**: Understand the overall approach
2. **Second pass**: Check details, logic, edge cases
3. **Third pass**: Security, performance, maintainability

#### Providing Feedback

```markdown
# Blocking (must fix before merge)
🔴 **[Blocking]** SQL injection vulnerability here. Use parameterized query.

# Suggestion (should consider)
🟡 **[Suggestion]** Consider extracting this to a separate function for reusability.

# Nitpick (optional, low priority)
🟢 **[Nitpick]** Minor: could use const instead of let here.

# Question (seeking clarification)
❓ **[Question]** Why was this approach chosen over X?

# Praise (positive feedback)
✨ **[Nice]** Great error handling here!
```

#### Comment Examples

```markdown
# Good - Specific, actionable, explains why
🔴 **[Blocking]** This query is vulnerable to SQL injection.
Instead of string interpolation, use parameterized queries:
```javascript
// Instead of
const query = `SELECT * FROM users WHERE id = '${id}'`;

// Use
const query = 'SELECT * FROM users WHERE id = $1';
const result = await pool.query(query, [id]);
```

# Bad - Vague, no context
"This is wrong"

# Bad - Just pointing out issue without solution
"SQL injection here"
```

### For Authors

#### Before Requesting Review

- [ ] Self-review your own code first
- [ ] Run linter and tests locally
- [ ] Write clear PR description
- [ ] Keep PR focused and reasonably sized
- [ ] Add reviewers who have context

#### Responding to Feedback

- **Thank reviewers** for their time and feedback
- **Address all comments** - resolve, reply, or explain
- **Don't take it personally** - reviews are about code, not you
- **Ask for clarification** if feedback is unclear
- **Push fixes as new commits** (don't force-push during review)

#### After Approval

- Squash commits if appropriate
- Ensure CI passes
- Merge promptly to avoid conflicts
- Delete branch after merge

## Common Anti-Patterns to Flag

### Code Smells

```javascript
// God function - does too many things
async function handleUserRequest(req, res) {
  // 200 lines of validation, business logic, and response formatting
}
// Suggest: Split into smaller, focused functions

// Magic numbers
if (status === 3) { ... }
// Suggest: Use named constants
const STATUS_APPROVED = 3;

// Nested callbacks
getData(id, (data) => {
  processData(data, (result) => {
    saveData(result, (saved) => {
      // callback hell
    });
  });
});
// Suggest: Use async/await

// Mutating parameters
function processUser(user) {
  user.name = user.name.trim(); // Mutates input
  return user;
}
// Suggest: Return new object or document mutation
```

### Security Issues

```javascript
// SQL Injection
const query = `SELECT * FROM users WHERE email = '${email}'`;
// Fix: Use parameterized queries

// Hardcoded secrets
const API_KEY = 'sk_live_abc123';
// Fix: Use environment variables

// Missing auth check
router.delete('/users/:id', async (req, res) => {
  await User.delete(req.params.id);
});
// Fix: Add authentication and authorization middleware

// Sensitive data in logs
console.log('Login attempt', { email, password });
// Fix: Never log passwords or sensitive data
```

### Performance Issues

```javascript
// N+1 query problem
const users = await User.findAll();
for (const user of users) {
  user.orders = await Order.findByUser(user.id); // Query per user!
}
// Fix: Use eager loading or batch query

// Unnecessary re-renders (React)
function UserList({ users }) {
  const handleClick = () => { ... }; // New function every render
  return users.map(u => <User onClick={handleClick} />);
}
// Fix: Use useCallback

// Synchronous file operations
const data = fs.readFileSync('large-file.json');
// Fix: Use async fs.readFile in server code
```

## Review Turnaround Time

| Priority | Initial Review | Subsequent Reviews |
|----------|---------------|-------------------|
| Critical (bug fix) | < 4 hours | < 2 hours |
| High (feature) | < 1 day | < 4 hours |
| Normal | < 2 days | < 1 day |
| Low (refactor) | < 3 days | < 2 days |

### When You're Blocked

- Comment on the PR that you're waiting
- Reach out directly if urgent
- Consider requesting additional reviewers

## Approval Criteria

### Ready to Merge

- [ ] All blocking comments resolved
- [ ] At least one approval from required reviewer
- [ ] CI/CD pipeline passes
- [ ] No merge conflicts
- [ ] Documentation updated if needed

### Not Ready to Merge

- Has unresolved blocking comments
- Missing required approvals
- CI failures
- Conflicts with target branch
- Missing tests for new functionality

## Checklist Summary

### Reviewer Checklist

- [ ] Understood the context and requirements
- [ ] Checked code quality and readability
- [ ] Verified security considerations
- [ ] Assessed performance implications
- [ ] Confirmed test coverage
- [ ] Provided constructive feedback
- [ ] Responded in timely manner

### Author Checklist

- [ ] Self-reviewed code
- [ ] PR description is complete
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] Addressed all feedback
- [ ] Ready for merge
