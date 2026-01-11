# Development Documentation Generator Agent

## Purpose
Generate technical development documentation including coding standards, testing guidelines, debugging guides, and development workflows.

## When to Invoke
- Creating development guidelines
- Documenting coding standards
- Writing testing documentation
- Creating debugging guides
- Documenting CI/CD processes
- Writing contribution guidelines

## Documentation Types

### 1. CONTRIBUTING.md

```markdown
# Contributing Guide

## Getting Started

Thank you for considering contributing to this project! This guide will help you get started.

### Prerequisites

- Node.js 18+
- Git
- Basic understanding of JavaScript, React, and Express

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/project-name.git`
3. Install dependencies: `npm install`
4. Create a feature branch: `git checkout -b feature/amazing-feature`
5. Make your changes
6. Run tests: `npm test`
7. Commit your changes: `git commit -m 'Add amazing feature'`
8. Push to your fork: `git push origin feature/amazing-feature`
9. Open a Pull Request

## Development Guidelines

### Code Style

We use ESLint and Prettier for code formatting. Configuration is automatic.

```bash
# Check linting
npm run lint

# Auto-fix issues
npm run lint -- --fix

# Format code
npm run format
```

### Coding Standards

#### JavaScript
- Use ESM modules (import/export)
- Use async/await (no callbacks)
- Use destructuring where appropriate
- Use template literals for string interpolation
- Prefer const over let, never use var

```javascript
// Good
const users = await User.find({ active: true });
const { name, email } = user;
const message = `Welcome, ${name}!`;

// Bad
var users = User.find({ active: true }, function(err, users) {});
const name = user.name;
const email = user.email;
const message = 'Welcome, ' + name + '!';
```

#### React
- Use functional components with hooks
- Use MUI components consistently
- Follow accessibility guidelines
- Implement responsive design

```javascript
// Good
function UserProfile({ user }) {
  const [loading, setLoading] = useState(false);

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4">{user.name}</Typography>
    </Box>
  );
}

// Bad
class UserProfile extends React.Component {
  render() {
    return <div style={{ padding: '24px' }}>...</div>;
  }
}
```

#### Express
- Follow layered architecture (Routes → Controllers → Services)
- Always validate inputs
- Use centralized error handling
- Implement proper authentication

```javascript
// Good - Layered approach
router.post('/users', authenticate, validate, asyncHandler(userController.create));

// Bad - Everything in route
router.post('/users', (req, res) => {
  const user = new User(req.body);
  user.save();
  res.json(user);
});
```

### Documentation

#### JSDoc Requirements

All functions must have JSDoc comments:

```javascript
/**
 * Creates a new user account
 * @param {Object} userData - User data
 * @param {string} userData.email - User email address
 * @param {string} userData.password - User password (plain text)
 * @param {string} userData.name - User full name
 * @returns {Promise<Object>} Created user object (without password)
 * @throws {ValidationError} When email is invalid or already exists
 * @throws {DatabaseError} When database operation fails
 */
async function createUser(userData) {
  // Implementation
}
```

#### React Component Documentation

```javascript
/**
 * UserCard component displays user information in a card format
 * @param {Object} props - Component props
 * @param {Object} props.user - User object
 * @param {string} props.user.id - User ID
 * @param {string} props.user.name - User full name
 * @param {string} props.user.email - User email
 * @param {string} [props.user.avatar] - User avatar URL (optional)
 * @param {Function} [props.onEdit] - Callback when edit button clicked
 * @param {Function} [props.onDelete] - Callback when delete button clicked
 * @returns {JSX.Element} Rendered user card
 */
export function UserCard({ user, onEdit, onDelete }) {
  // Implementation
}
```

### Testing

#### Coverage Requirements

- Overall coverage: Minimum 60%
- Per-file coverage: Minimum 20%
- All new features must include tests

#### Writing Tests

Use BDD-style (Given-When-Then) structure:

```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with hashed password', async () => {
      // Given
      const userData = {
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User',
      };

      // When
      const user = await createUser(userData);

      // Then
      expect(user).toHaveProperty('id');
      expect(user.email).toBe(userData.email);
      expect(user.password).not.toBe(userData.password);
    });

    it('should throw error when email already exists', async () => {
      // Given
      const userData = { email: 'existing@example.com' };
      await createUser(userData);

      // When/Then
      await expect(createUser(userData)).rejects.toThrow('Email already exists');
    });
  });
});
```

#### React Component Testing

```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import UserCard from './UserCard';

describe('UserCard', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  };

  it('should display user information', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByText(mockUser.name)).toBeInTheDocument();
    expect(screen.getByText(mockUser.email)).toBeInTheDocument();
  });

  it('should call onEdit when edit button clicked', () => {
    const onEdit = jest.fn();
    render(<UserCard user={mockUser} onEdit={onEdit} />);

    fireEvent.click(screen.getByRole('button', { name: /edit/i }));
    expect(onEdit).toHaveBeenCalledWith(mockUser.id);
  });
});
```

### Git Commit Guidelines

#### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

#### Examples

```
feat(auth): add JWT authentication

Implement JWT-based authentication with refresh tokens.
- Add login endpoint
- Add token refresh endpoint
- Add authentication middleware

Closes #123
```

```
fix(users): prevent duplicate email registration

Check for existing email before creating new user account.

Fixes #456
```

### Pull Request Guidelines

#### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass (`npm test`)
- [ ] Test coverage is maintained (≥60%)
- [ ] JSDoc comments added to new functions
- [ ] No ESLint errors
- [ ] Documentation updated if needed
- [ ] Git hooks pass

#### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issue
Closes #(issue number)

## Testing
Describe how to test the changes

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No new warnings
```

### Code Review Checklist

When reviewing PRs, check:

**Functionality**
- [ ] Code does what it's supposed to do
- [ ] Edge cases handled
- [ ] Error handling implemented

**Code Quality**
- [ ] Follows coding standards
- [ ] No code duplication
- [ ] Clear variable/function names
- [ ] JSDoc comments present

**Security**
- [ ] Input validation present
- [ ] No SQL/NoSQL injection risks
- [ ] Authentication/authorization checked
- [ ] No sensitive data exposed

**Testing**
- [ ] Tests included for new features
- [ ] Tests cover edge cases
- [ ] Coverage requirements met

**Performance**
- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] No unnecessary re-renders (React)

## Development Workflow

### Feature Development

1. Create feature branch from `main`
2. Implement feature with tests
3. Ensure all checks pass
4. Push and create PR
5. Address review feedback
6. Merge after approval

### Bug Fixes

1. Create bug branch from `main`
2. Write test that reproduces bug
3. Fix bug
4. Ensure test passes
5. Create PR with bug description
6. Merge after approval

### Release Process

1. Update version in package.json
2. Update CHANGELOG.md
3. Create release branch
4. Test thoroughly
5. Create release PR
6. Tag release after merge
7. Deploy to production

## Getting Help

- Read existing documentation in `docs/`
- Check closed issues/PRs for similar problems
- Ask in discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the project's license.
```

### 2. TESTING.md

```markdown
# Testing Guide

## Overview

We use Jest for unit and integration testing, and React Testing Library for component testing.

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- path/to/test.js

# Run tests matching pattern
npm test -- --testNamePattern="user"
```

## Test Structure

### File Organization

```
tests/
├── unit/              # Unit tests
│   ├── services/
│   ├── utils/
│   └── models/
├── integration/       # Integration tests
│   ├── api/
│   └── database/
└── e2e/              # End-to-end tests
```

### Naming Convention

- Test files: `*.test.js` or `*.spec.js`
- Match source file name: `userService.js` → `userService.test.js`

### BDD Structure (Given-When-Then)

```javascript
describe('Feature/Module Name', () => {
  describe('Specific Functionality', () => {
    it('should do something when condition', () => {
      // Given - Setup
      const input = 'test';

      // When - Execute
      const result = doSomething(input);

      // Then - Assert
      expect(result).toBe('expected');
    });
  });
});
```

## Backend Testing

### Testing Services

```javascript
import { createUser, getUserById } from '../services/userService';
import { User } from '../models/User';

// Mock database
jest.mock('../models/User');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    it('should create user with hashed password', async () => {
      // Given
      const userData = {
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User',
      };

      User.create.mockResolvedValue({
        id: '1',
        ...userData,
        password: 'hashed_password',
      });

      // When
      const user = await createUser(userData);

      // Then
      expect(User.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: userData.email,
          name: userData.name,
        })
      );
      expect(user.password).not.toBe(userData.password);
    });
  });
});
```

### Testing API Endpoints

```javascript
import request from 'supertest';
import app from '../app';
import { User } from '../models/User';

jest.mock('../models/User');

describe('User API', () => {
  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      // Given
      const userData = {
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User',
      };

      // When
      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      // Then
      expect(response.body).toHaveProperty('success', true);
      expect(response.body.data).toHaveProperty('email', userData.email);
    });

    it('should return 400 for invalid email', async () => {
      // Given
      const userData = { email: 'invalid', password: 'Password123' };

      // When
      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(400);

      // Then
      expect(response.body).toHaveProperty('success', false);
      expect(response.body.error).toContain('email');
    });
  });
});
```

## Frontend Testing

### Testing React Components

```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserForm } from './UserForm';

describe('UserForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('should render form fields', () => {
    render(<UserForm onSubmit={mockOnSubmit} />);

    expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /submit/i })).toBeInTheDocument();
  });

  it('should validate required fields', async () => {
    const user = userEvent.setup();
    render(<UserForm onSubmit={mockOnSubmit} />);

    // When - Submit empty form
    await user.click(screen.getByRole('button', { name: /submit/i }));

    // Then - Show validation errors
    expect(await screen.findByText(/name is required/i)).toBeInTheDocument();
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('should submit form with valid data', async () => {
    const user = userEvent.setup();
    render(<UserForm onSubmit={mockOnSubmit} />);

    // Given - Fill form
    await user.type(screen.getByLabelText(/name/i), 'John Doe');
    await user.type(screen.getByLabelText(/email/i), 'john@example.com');

    // When - Submit
    await user.click(screen.getByRole('button', { name: /submit/i }));

    // Then
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        name: 'John Doe',
        email: 'john@example.com',
      });
    });
  });
});
```

### Testing Custom Hooks

```javascript
import { renderHook, waitFor } from '@testing-library/react';
import { useUsers } from './useUsers';
import { fetchUsers } from '../api/users';

jest.mock('../api/users');

describe('useUsers', () => {
  it('should fetch users on mount', async () => {
    // Given
    const mockUsers = [{ id: '1', name: 'John' }];
    fetchUsers.mockResolvedValue({ data: mockUsers });

    // When
    const { result } = renderHook(() => useUsers());

    // Then
    expect(result.current.loading).toBe(true);

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.users).toEqual(mockUsers);
  });
});
```

## Mocking

### Mocking Modules

```javascript
// Mock entire module
jest.mock('../utils/logger');

// Mock with implementation
jest.mock('../services/emailService', () => ({
  sendEmail: jest.fn().mockResolvedValue(true),
}));

// Partial mock
jest.mock('../utils/helpers', () => ({
  ...jest.requireActual('../utils/helpers'),
  someFunction: jest.fn(),
}));
```

### Mocking Fetch/API Calls

```javascript
// Using jest
global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({ data: 'test' }),
  })
);

// Using MSW (Mock Service Worker)
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([{ id: '1', name: 'John' }]));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Coverage Requirements

- Overall coverage: ≥60%
- Per-file coverage: ≥20%
- Branches: ≥60%
- Functions: ≥60%
- Lines: ≥60%

### Viewing Coverage

```bash
# Generate coverage report
npm run test:coverage

# Open HTML report
open coverage/lcov-report/index.html
```

## Best Practices

✅ Write tests alongside code
✅ Test behavior, not implementation
✅ Use descriptive test names
✅ Keep tests simple and focused
✅ Mock external dependencies
✅ Test edge cases and error scenarios
✅ Use beforeEach/afterEach for setup/cleanup
✅ Avoid testing implementation details

## Anti-Patterns

❌ Testing implementation details
❌ Large, complex test cases
❌ No test isolation (shared state)
❌ Ignoring failed tests
❌ Low test coverage
❌ Not testing error cases
❌ Slow tests (unmocked external calls)
```

### 3. DEBUGGING.md

```markdown
# Debugging Guide

## Backend Debugging

### VSCode Debug Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Server",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/server/server.js",
      "restart": true,
      "runtimeExecutable": "node",
      "env": {
        "NODE_ENV": "development"
      }
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand", "--no-cache", "${file}"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    }
  ]
}
```

### Node.js Debugging

```bash
# Start with inspect flag
node --inspect src/server/server.js

# Or with breakpoint at start
node --inspect-brk src/server/server.js

# Chrome DevTools
# Open chrome://inspect
```

### Logging

```javascript
import logger from './utils/logger';

// Different log levels
logger.error('Error message', { error });
logger.warn('Warning message');
logger.info('Info message');
logger.debug('Debug message');

// Structured logging
logger.info('User created', {
  userId: user.id,
  email: user.email,
  timestamp: new Date(),
});
```

## Frontend Debugging

### React DevTools

- Install React DevTools extension
- Inspect component props and state
- Profile component performance
- View component hierarchy

### Browser DevTools

```javascript
// Breakpoints
debugger; // Pauses execution

// Console debugging
console.log('Value:', value);
console.table(arrayOfObjects);
console.trace(); // Stack trace
console.time('operation');
// ... code
console.timeEnd('operation');
```

### Redux DevTools

```javascript
// Enable in development
const store = createStore(
  rootReducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);
```

## Common Issues

### Backend

**Port already in use**
```bash
lsof -i :3000
kill -9 <PID>
```

**Database connection errors**
- Check DATABASE_URL
- Verify database is running
- Test connection manually

**Authentication errors**
- Verify JWT_SECRET is set
- Check token expiration
- Validate middleware order

### Frontend

**Component not updating**
- Check state updates
- Verify useEffect dependencies
- Check for mutation instead of immutable updates

**API calls failing**
- Check network tab in DevTools
- Verify CORS configuration
- Check API endpoint URL
- Verify authentication token

## Performance Debugging

### Backend

```javascript
// Timing middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info(`${req.method} ${req.url} - ${duration}ms`);
  });
  next();
});
```

### Frontend

```javascript
// React Profiler
import { Profiler } from 'react';

function onRender(id, phase, actualDuration) {
  console.log({ id, phase, actualDuration });
}

<Profiler id="App" onRender={onRender}>
  <App />
</Profiler>
```

## Tools

- **Node.js**: Built-in debugger, Chrome DevTools
- **VSCode**: Integrated debugger
- **React**: React DevTools, Profiler
- **Network**: Chrome DevTools Network tab
- **Performance**: Chrome Lighthouse, React Profiler
- **Logging**: Winston, Pino, Morgan
```

## Generation Process

1. **Identify Documentation Needs**
   - What aspects of development need documentation?
   - What are developers struggling with?
   - What questions are frequently asked?

2. **Generate Relevant Sections**
   - Focus on practical, actionable content
   - Include code examples
   - Provide troubleshooting tips

3. **Keep Updated**
   - Update when processes change
   - Add new sections as needed
   - Remove outdated information

## Best Practices

✅ Provide concrete examples
✅ Include command-line snippets
✅ Add troubleshooting sections
✅ Keep language clear and simple
✅ Include screenshots where helpful
✅ Link to related documentation

## Anti-Patterns to Avoid

❌ Overly abstract guidelines
❌ No code examples
❌ Outdated information
❌ Too technical without context
❌ Missing troubleshooting guidance