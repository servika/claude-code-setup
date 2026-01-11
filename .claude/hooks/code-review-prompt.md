# Code Review Checklist

You are reviewing code changes before they are committed. Perform a thorough review following these criteria:

## 1. Code Quality

**Readability**
- [ ] Code is self-documenting with clear variable and function names
- [ ] Complex logic has explanatory comments (not obvious comments)
- [ ] Functions are focused and do one thing well
- [ ] No deeply nested code (max 3 levels)

**JavaScript Best Practices**
- [ ] Uses modern ES6+ syntax (const/let, arrow functions, destructuring)
- [ ] No var declarations
- [ ] Proper use of async/await (not mixing with .then())
- [ ] No floating promises (all promises are awaited or returned)
- [ ] Proper error handling with try/catch for async operations

**Performance**
- [ ] No obvious performance issues (N+1 queries, unnecessary loops)
- [ ] React components use memoization where appropriate
- [ ] Large lists are paginated or virtualized
- [ ] API calls are not made in loops
- [ ] Database queries are optimized with proper indexing

## 2. Security

**Input Validation**
- [ ] All user inputs are validated
- [ ] Using validation library (Zod, Joi, etc.) for API endpoints
- [ ] No direct use of user input in queries (SQL/NoSQL injection prevention)
- [ ] File uploads are validated (type, size)

**Authentication & Authorization**
- [ ] Protected routes have authentication middleware
- [ ] Authorization checks are present (user can only access their own data)
- [ ] Passwords are hashed with bcrypt (never plain text)
- [ ] JWT secrets are strong and from environment variables
- [ ] Sensitive data is not logged

**Other Security**
- [ ] No hardcoded secrets or API keys
- [ ] CORS is properly configured
- [ ] Rate limiting on authentication endpoints
- [ ] XSS prevention (React escapes by default, no dangerouslySetInnerHTML without sanitization)
- [ ] Using helmet for security headers

## 3. Testing

**Test Coverage**
- [ ] Overall coverage is at least 60%
- [ ] Each modified file has at least 20% coverage
- [ ] New functions have corresponding tests
- [ ] Tests cover happy path, error cases, and edge cases

**Test Quality**
- [ ] Tests are readable with clear Given-When-Then structure
- [ ] Tests are independent (not relying on other tests)
- [ ] Mocking external dependencies appropriately
- [ ] React components tested with React Testing Library (query by role/label)
- [ ] API endpoints have integration tests

## 4. Documentation

**JSDoc Comments**
- [ ] All functions have JSDoc comments
- [ ] JSDoc includes @param for all parameters
- [ ] JSDoc includes @returns for return values
- [ ] JSDoc includes @throws for exceptions
- [ ] Optional parameters marked with [paramName]

**Project Documentation**
- [ ] README.md updated if public API changed
- [ ] New features documented
- [ ] Breaking changes clearly noted
- [ ] Environment variables documented in .env.example

## 5. React & MUI Specific

**Component Quality**
- [ ] Using functional components (not class components)
- [ ] Props are validated with PropTypes or JSDoc
- [ ] Component is focused and reusable
- [ ] No prop drilling (use Context if needed)

**MUI Best Practices**
- [ ] Using sx prop instead of inline styles
- [ ] Using theme values (not hardcoded colors)
- [ ] Responsive design with breakpoints
- [ ] Accessibility attributes (aria-label, alt text)
- [ ] Icons imported individually (not bulk import)

**Performance**
- [ ] Expensive components wrapped in React.memo()
- [ ] useMemo/useCallback used appropriately
- [ ] No inline function definitions passed as props
- [ ] Large components code-split with React.lazy()

## 6. Express/Node.js Specific

**API Structure**
- [ ] Following Routes → Controllers → Services pattern
- [ ] Centralized error handling
- [ ] Async handlers wrapped (catching errors)
- [ ] Proper HTTP status codes
- [ ] Consistent response format

**Error Handling**
- [ ] Custom error classes with status codes
- [ ] All errors logged with context
- [ ] No sensitive data in error responses
- [ ] Development vs production error details

## 7. Database

**Query Safety**
- [ ] Using parameterized queries (no string concatenation)
- [ ] Proper indexing on frequently queried fields
- [ ] No N+1 queries
- [ ] Transactions for multi-step operations
- [ ] Connection pooling configured

## 8. Common Issues to Flag

**Must Fix (Block Commit)**
- Security vulnerabilities
- Broken tests or failing linting
- Coverage below thresholds (60% overall, 20% per file)
- Missing error handling in async operations
- Hardcoded secrets or credentials
- SQL/NoSQL injection vulnerabilities

**Should Fix (Strong Warning)**
- Missing JSDoc on functions
- No tests for new functionality
- console.log statements (use proper logger)
- Inline styles in React (use sx prop)
- No input validation on API endpoints
- Missing documentation updates

**Consider Improving (Suggestion)**
- Could be more readable
- Could be refactored for reusability
- Performance could be optimized
- Consider adding more edge case tests
- Consider accessibility improvements

## Review Output Format

Provide your review in this format:

**Summary:**
[One paragraph summary of the changes and overall assessment]

**Critical Issues (Must Fix):**
- [Issue 1 with file:line reference]
- [Issue 2 with file:line reference]

**Warnings (Should Fix):**
- [Warning 1]
- [Warning 2]

**Suggestions (Consider):**
- [Suggestion 1]
- [Suggestion 2]

**Positive Observations:**
- [Good practice 1]
- [Good practice 2]

**Recommendation:**
- [ ] Approve - Ready to commit
- [ ] Approve with minor changes
- [ ] Request changes before commit