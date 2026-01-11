# Contributing Guide

Thank you for contributing to this project! This guide will help you get started.

---

## Quick Start

1. **Read the guidelines**: Start with `.claude/CLAUDE.md`
2. **Set up your environment**: Follow README.md
3. **Find an issue**: Check [open issues](../../issues) or create one
4. **Create a branch**: Use naming convention from `.claude/rules/commit-policy.md`
5. **Make changes**: Follow our coding standards
6. **Submit PR**: Use the PR template

---

## Development Workflow

### 1. Before You Start

**Read the guidelines**:
- `.claude/CLAUDE.md` - Main development guidelines
- `.claude/rules/coding-standards.md` - Standards and priorities
- Relevant tech guides (`.claude/rules/nodejs.md`, `.claude/rules/react.md`, etc.)

**Check existing work**:
- Search [issues](../../issues) for duplicates
- Review [pull requests](../../pulls) for similar work
- Check [discussions](../../discussions) for ongoing conversations

**Clarify the scope**:
- Comment on the issue to claim it
- Ask questions if requirements are unclear
- Get approval for significant changes

### 2. Set Up Development Environment

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO

# Install dependencies
npm ci

# Verify everything works
npm test
npm run lint
npm run build

# Set up environment variables
cp .env.example .env
# Edit .env with your local configuration
```

### 3. Create a Branch

Follow branch naming convention from `.claude/rules/commit-policy.md`:

```bash
git checkout -b feature/123-user-authentication
git checkout -b bugfix/456-memory-leak
git checkout -b docs/789-update-readme
```

Format: `<type>/<issue-number>-<short-description>`

### 4. Make Changes

**Follow the architecture**:
- Backend: Routes → Controllers → Services → Data Access
- Frontend: Pages → Layouts → Features → UI Components
- See `.claude/CLAUDE.md` for patterns

**Write quality code**:
- Add JSDoc comments to all functions
- Follow ESLint rules (`npm run lint`)
- Use TypeScript types or PropTypes
- Handle errors properly
- See `.claude/rules/coding-standards.md`

**Add tests**:
- Minimum 60% overall coverage, 20% per file
- Test happy path, errors, and edge cases
- See `.claude/rules/testing.md`
- Run: `npm test -- --coverage`

**Update documentation**:
- Update README if user-facing changes
- Update API docs if endpoints changed
- Add/update code comments
- See `.claude/rules/documentation-guide.md`

### 5. Commit Your Changes

**Follow conventional commits** (`.claude/rules/commit-policy.md`):

```bash
# Format: <type>(<scope>): <subject>
git commit -m "feat(auth): add JWT token generation"
git commit -m "fix(api): resolve race condition in user creation"
git commit -m "docs(readme): update installation instructions"
```

**Pre-commit checklist** (`.claude/rules/coding-standards.md`):
- [ ] No hardcoded secrets
- [ ] Tests pass (`npm test`)
- [ ] ESLint passes (`npm run lint`)
- [ ] JSDoc on new functions
- [ ] Coverage ≥60% overall, ≥20% per file
- [ ] Conventional commit message
- [ ] No console.log/debugger

### 6. Push and Create PR

```bash
# Push your branch
git push -u origin feature/123-user-authentication

# Create PR on GitHub
# PR template will load automatically
```

**Fill out the PR template completely**:
- Describe what changed and why
- Check all relevant checklist items
- Include test coverage output
- Add screenshots for UI changes
- Link related issues

See `.github/pull_request_template.md` for full checklist.

### 7. Code Review Process

**What reviewers check** (`.claude/rules/coding-standards.md`):
1. **Security**: No secrets, input validation, auth checks
2. **Correctness**: Tests pass, no regressions
3. **Quality**: JSDoc, coverage, architecture patterns
4. **Documentation**: Docs updated, comments added

**Responding to feedback** (`.claude/rules/coding-standards.md`):
- Verify suggestions before implementing
- Ask clarifying questions if unclear
- Push back with technical reasoning if needed
- Implement changes one at a time with testing
- Use factual responses (no performative agreement)

Example responses:
- ✅ "Fixed. Moved API key to environment variable"
- ✅ "Pushing back. This would break backward compatibility with mobile app"
- ✅ "Need clarification. Do you mean [X] or [Y]?"

### 8. After Your PR Merges

- Monitor CI/CD pipeline
- Watch for production issues (if deployed)
- Respond to any follow-up questions
- Close related issues
- Update project board

---

## Contribution Types

### Bug Fixes

1. **Create bug report** using the Bug Report template (`.github/ISSUE_TEMPLATE/bug_report.yml`)
2. **Reproduce the bug** locally
3. **Write failing test** that demonstrates the bug
4. **Fix the bug** with minimal changes
5. **Verify test passes** and no regressions
6. **Submit PR** with fix and test

See `.claude/rules/quality-management.md` for incident response if it's a production bug.

### New Features

1. **Create feature request** using Feature Request template (`.github/ISSUE_TEMPLATE/feature_request.yml`)
2. **Wait for approval** - Features are prioritized using RICE scoring (`.claude/rules/product-development.md`)
3. **Plan implementation** - Break down into tasks (`.claude/rules/project-management.md`)
4. **Implement following guidelines** - Architecture from `.claude/CLAUDE.md`
5. **Add comprehensive tests** - Unit + integration tests
6. **Update documentation** - README, API docs, JSDoc
7. **Submit PR** with feature

### Documentation Improvements

1. **Create documentation issue** using Documentation template (`.github/ISSUE_TEMPLATE/documentation.yml`)
2. **Identify what needs fixing** - Missing, incorrect, outdated, or unclear
3. **Follow documentation standards** - See `.claude/rules/documentation-guide.md`
4. **Update the docs** - README, guides, code comments, API docs
5. **Test examples** - Ensure code examples work
6. **Submit PR** with documentation changes

### Refactoring

Refactoring requires **extra care**:
- Discuss major refactoring in an issue first
- Keep changes focused (one refactoring per PR)
- Maintain existing behavior (tests should still pass)
- Add tests if coverage gaps exist
- Update documentation if architecture changes

See `.claude/rules/coding-standards.md` for when to refactor.

---

## Code Style

### JavaScript / TypeScript

**Follow our stack**:
- ESM modules (`import`/`export`)
- Modern ES6+ syntax
- Async/await (not `.then()`)
- Functional components (React)
- No `var`, use `const`/`let`

**Automated tools**:
```bash
npm run lint        # Check code quality
npm run lint -- --fix  # Auto-fix issues
npm run format      # Format with Prettier
```

**Manual checks**:
- JSDoc on all functions (required)
- Meaningful variable names
- Max 3 levels of nesting
- Functions do one thing well

See tech-specific guides:
- `.claude/rules/nodejs.md`
- `.claude/rules/express.md`
- `.claude/rules/react.md`
- `.claude/rules/mui.md`

### React / MUI

**Required patterns**:
- Functional components only (no class components)
- Use hooks (useState, useEffect, useCallback, useMemo)
- Use `sx` prop (not inline styles)
- Use theme values (not hardcoded colors)
- Query by role/label in tests (not implementation)

**Example**:
```jsx
import { Box, Button } from '@mui/material';

export function UserCard({ user }) {
  return (
    <Box sx={{ p: 3, bgcolor: 'background.paper' }}>
      <Button variant="contained" color="primary">
        Edit
      </Button>
    </Box>
  );
}
```

See `.claude/rules/react.md` and `.claude/rules/mui.md`.

### Express / Node.js

**Required patterns**:
- Routes → Controllers → Services → Data Access
- Centralized error handling
- Input validation at route entry
- Async wrapper for error catching
- Parameterized queries (no string concatenation)

**Example**:
```javascript
// routes/users.routes.js
router.get('/:id', authenticate, asyncHandler(getUserById));

// controllers/users.controller.js
export async function getUserById(req, res) {
  const user = await userService.getUser(req.params.id);
  res.json(user);
}

// services/user.service.js
export async function getUser(id) {
  const user = await User.findById(id);
  if (!user) throw new NotFoundError('User not found');
  return user;
}
```

See `.claude/rules/express.md` and `.claude/rules/nodejs.md`.

---

## Security Requirements

**Never commit**:
- API keys, passwords, tokens
- `.env` files
- Credentials of any kind

**Always validate**:
- User input (use Zod, Joi, or express-validator)
- File uploads (type, size)
- Query parameters

**Always authenticate/authorize**:
- Protected routes have auth middleware
- Users can only access their own data
- Admin functions check role

**Use secure practices**:
- Hash passwords with bcrypt (12+ rounds)
- Use strong JWT secrets from environment
- Implement rate limiting on auth endpoints
- Configure CORS properly
- Use helmet for security headers

See `.claude/rules/security.md` for complete security guide.

---

## Testing Requirements

**Coverage thresholds**:
- Overall project: ≥60%
- Per file: ≥20%
- No exceptions

**Test structure**:
```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Given
      const userData = { email: 'test@example.com', password: 'pass123' };

      // When
      const user = await userService.createUser(userData);

      // Then
      expect(user).toMatchObject({ email: 'test@example.com' });
      expect(user.id).toBeDefined();
    });
  });
});
```

**What to test**:
- Happy path (expected usage)
- Error cases (invalid input, failures)
- Edge cases (null, empty, boundary values)

See `.claude/rules/testing.md` for complete testing guide.

---

## Standards Hierarchy

When time is limited or standards conflict, follow this priority:

1. **Security** (Non-Negotiable)
2. **Correctness** (No Broken Code)
3. **Code Quality** (Maintainability)
4. **Git Conventions** (Traceability)
5. **Documentation** (Knowledge Sharing)
6. **Style & Conventions** (Consistency)

See `.claude/rules/coding-standards.md` for details.

---

## Getting Help

**Questions about the project**:
- Check `.claude/README.md` for guide index
- Search existing issues and discussions
- Create a discussion (not an issue)

**Questions about guidelines**:
- Read `.claude/CLAUDE.md` first
- Check specific guide in `.claude/rules/`
- Ask in PR comments if unsure

**Technical questions**:
- Check tech-specific guides (nodejs, express, react, mui)
- Review examples in the codebase
- Ask maintainers in issue comments

**Stuck on something**:
- Explain what you've tried
- Share relevant code/errors
- Be specific about the problem
- Maintainers are here to help!

---

## Recognition

Contributors are recognized in:
- CHANGELOG.md (for significant contributions)
- Commit co-authors (using `Co-authored-by`)
- Special thanks in release notes

All contributions are valued, from typo fixes to major features!

---

## Code of Conduct

Be respectful, professional, and constructive:
- Focus on technical merit, not personal preferences
- Be direct and honest, not harsh or dismissive
- Provide specific, actionable feedback
- Assume good intent
- No harassment, discrimination, or unprofessional behavior

---

## Additional Resources

**Essential Reading**:
- `.claude/CLAUDE.md` - Main development guidelines
- `.claude/README.md` - Guide system overview
- `.claude/rules/coding-standards.md` - Standards and priorities

**Process Guides**:
- `.claude/rules/commit-policy.md` - Git conventions
- `.claude/rules/project-management.md` - Project lifecycle
- `.claude/rules/quality-management.md` - Incident response

**Technical Guides**:
- `.claude/rules/nodejs.md` - Node.js patterns
- `.claude/rules/express.md` - Express API development
- `.claude/rules/react.md` - React patterns
- `.claude/rules/mui.md` - Material-UI components
- `.claude/rules/testing.md` - Testing practices
- `.claude/rules/security.md` - Security requirements

**External Resources**:
- [Conventional Commits](https://www.conventionalcommits.org/)
- [React Documentation](https://react.dev/)
- [Material-UI Documentation](https://mui.com/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)

---

## Summary

1. **Read** `.claude/CLAUDE.md` and relevant guides
2. **Create** issue using appropriate template
3. **Branch** following naming convention
4. **Code** following architecture and standards
5. **Test** with ≥60% coverage
6. **Commit** with conventional commits format
7. **PR** using template and checklist
8. **Review** respond to feedback professionally
9. **Merge** and monitor deployment

**Key Principle**: Quality over speed. Take time to do it right. Follow the guidelines. Ask questions if unsure.

Thank you for contributing!