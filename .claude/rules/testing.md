---
pattern: "**/*.{test,spec}.{js,ts,jsx,tsx}"
---

# Testing Guidelines

These rules apply to all test files in the project.

## Test Structure

**Use BDD-Style Organization**
- Structure tests with Given-When-Then comments
- One logical assertion per test
- Descriptive test names that explain the scenario

```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      // Given
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securepassword123'
      };

      // When
      const user = await userService.createUser(userData);

      // Then
      expect(user).toMatchObject({
        name: 'John Doe',
        email: 'john@example.com'
      });
      expect(user.id).toBeDefined();
      expect(user.password).not.toBe(userData.password); // Should be hashed
    });

    it('should throw ValidationError when email is invalid', async () => {
      // Given
      const userData = {
        name: 'John Doe',
        email: 'invalid-email',
        password: 'securepassword123'
      };

      // When / Then
      await expect(userService.createUser(userData))
        .rejects
        .toThrow(ValidationError);
    });
  });
});
```

## Naming Conventions

**Descriptive Test Names**

```javascript
// Good: Clear, specific test names
it('should return 404 when user does not exist')
it('should hash password before storing in database')
it('should send welcome email after successful registration')
it('should prevent duplicate email registration')

// Bad: Vague test names
it('works') // ❌
it('test user creation') // ❌
it('should work correctly') // ❌
```

## Mocking Best Practices

**Mock External Dependencies, Not the System Under Test**

```javascript
import { jest } from '@jest/globals';
import { UserService } from '../services/user.service';
import { emailService } from '../services/email.service';
import { database } from '../database';

// Mock external dependencies
jest.mock('../services/email.service');
jest.mock('../database');

describe('UserService.register', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
  });

  it('should send welcome email after registration', async () => {
    // Given
    const userData = { name: 'John', email: 'john@example.com' };
    database.users.create.mockResolvedValue({ id: '1', ...userData });

    // When
    await UserService.register(userData);

    // Then
    expect(emailService.sendWelcomeEmail).toHaveBeenCalledWith(
      'john@example.com',
      'John'
    );
  });
});
```

**Reset Mocks Between Tests**

```javascript
beforeEach(() => {
  jest.clearAllMocks(); // Clear call history
  // Or jest.resetAllMocks(); // Also reset implementations
  // Or jest.restoreAllMocks(); // Restore original implementations
});

afterEach(() => {
  jest.clearAllMocks();
});
```

## Coverage Requirements

**Test the Three Paths**
1. Happy path (successful operation)
2. Error cases (validation failures, network errors)
3. Edge cases (null, undefined, empty arrays, boundary values)

```javascript
describe('calculateDiscount', () => {
  // Happy path
  it('should calculate 10% discount for standard members', () => {
    expect(calculateDiscount(100, 'standard')).toBe(10);
  });

  // Edge cases
  it('should return 0 discount for zero amount', () => {
    expect(calculateDiscount(0, 'premium')).toBe(0);
  });

  it('should handle negative amounts', () => {
    expect(calculateDiscount(-100, 'standard')).toBe(0);
  });

  it('should return 0 for null membership', () => {
    expect(calculateDiscount(100, null)).toBe(0);
  });

  // Error cases
  it('should throw error for invalid membership type', () => {
    expect(() => calculateDiscount(100, 'invalid'))
      .toThrow('Invalid membership type');
  });
});
```

## Async Testing

**Always Await or Return Promises**

```javascript
// Good: Using async/await
it('should fetch user data', async () => {
  const user = await fetchUser('123');
  expect(user.name).toBe('John');
});

// Good: Returning promise
it('should fetch user data', () => {
  return fetchUser('123').then(user => {
    expect(user.name).toBe('John');
  });
});

// Bad: Forgetting await (test passes even if promise rejects!)
it('should fetch user data', () => {
  fetchUser('123').then(user => { // ❌ No await or return
    expect(user.name).toBe('John');
  });
});
```

**Test All Async States**

```javascript
describe('useUser hook', () => {
  it('should show loading state initially', () => {
    const { result } = renderHook(() => useUser('123'));
    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBeNull();
  });

  it('should load user data successfully', async () => {
    const { result } = renderHook(() => useUser('123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.data).toEqual({ id: '123', name: 'John' });
      expect(result.current.error).toBeNull();
    });
  });

  it('should handle error state', async () => {
    mockFetch.mockRejectedValueOnce(new Error('Network error'));

    const { result } = renderHook(() => useUser('123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.data).toBeNull();
      expect(result.current.error).toBe('Network error');
    });
  });
});
```

## React Component Testing

**Use React Testing Library**

```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('should submit form with valid credentials', async () => {
    // Given
    const handleSubmit = jest.fn();
    const user = userEvent.setup();

    render(<LoginForm onSubmit={handleSubmit} />);

    // When
    await user.type(screen.getByLabelText(/email/i), 'john@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    // Then
    await waitFor(() => {
      expect(handleSubmit).toHaveBeenCalledWith({
        email: 'john@example.com',
        password: 'password123'
      });
    });
  });

  it('should display error message for invalid email', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={jest.fn()} />);

    await user.type(screen.getByLabelText(/email/i), 'invalid-email');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
  });
});
```

**Query by Accessibility, Not Implementation**

```javascript
// Good: Query by role, label, text
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText(/email/i);
screen.getByText(/welcome/i);
screen.getByPlaceholderText(/search/i);

// Bad: Query by implementation details
screen.getByClassName('submit-button'); // ❌
screen.getByTestId('email-input'); // ❌ Use only as last resort
document.querySelector('.error-message'); // ❌
```

**User Interactions with userEvent**

```javascript
import userEvent from '@testing-library/user-event';

it('should handle user interactions', async () => {
  const user = userEvent.setup();

  render(<SearchForm />);

  // Type in input
  await user.type(screen.getByRole('textbox'), 'React hooks');

  // Click button
  await user.click(screen.getByRole('button', { name: /search/i }));

  // Select option
  await user.selectOptions(screen.getByRole('combobox'), 'option-value');

  // Check checkbox
  await user.click(screen.getByRole('checkbox', { name: /remember me/i }));
});
```

## API Testing

**Test Express Routes with Supertest**

```javascript
import request from 'supertest';
import { app } from '../app';
import { database } from '../database';

describe('POST /api/users', () => {
  beforeEach(async () => {
    await database.users.deleteAll(); // Clean database
  });

  it('should create a new user', async () => {
    // When
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securepassword123'
      })
      .expect(201);

    // Then
    expect(response.body).toMatchObject({
      id: expect.any(String),
      name: 'John Doe',
      email: 'john@example.com'
    });
    expect(response.body.password).toBeUndefined(); // Should not return password
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'John Doe',
        email: 'invalid-email',
        password: 'securepassword123'
      })
      .expect(400);

    expect(response.body.error).toMatch(/email/i);
  });

  it('should return 401 without authentication', async () => {
    await request(app)
      .post('/api/users')
      .send({ name: 'John' })
      .expect(401);
  });
});
```

**Mock HTTP Requests with MSW**

```javascript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(
      ctx.json({
        id: req.params.id,
        name: 'John Doe',
        email: 'john@example.com'
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserProfile', () => {
  it('should display user data', async () => {
    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });

  it('should handle API error', async () => {
    server.use(
      rest.get('/api/users/:id', (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: 'Server error' }));
      })
    );

    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});
```

## Test Organization

**File Structure**

```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx        # Colocate with component
├── services/
│   ├── user.service.ts
│   └── user.service.test.ts
└── __tests__/                  # Or separate test directory
    ├── integration/
    │   └── api.test.ts
    └── e2e/
        └── user-flow.test.ts
```

**Setup and Teardown**

```javascript
describe('UserService', () => {
  let mockDb;

  // Runs once before all tests in this describe block
  beforeAll(async () => {
    mockDb = await setupTestDatabase();
  });

  // Runs before each test
  beforeEach(async () => {
    await mockDb.clear();
    await mockDb.seed();
  });

  // Runs after each test
  afterEach(() => {
    jest.clearAllMocks();
  });

  // Runs once after all tests
  afterAll(async () => {
    await mockDb.close();
  });

  it('test 1', () => { /* ... */ });
  it('test 2', () => { /* ... */ });
});
```

## Snapshot Testing

**Use Sparingly**

```javascript
import { render } from '@testing-library/react';
import { UserCard } from './UserCard';

it('should match snapshot', () => {
  const { container } = render(
    <UserCard user={{ id: '1', name: 'John', email: 'john@example.com' }} />
  );

  expect(container.firstChild).toMatchSnapshot();
});

// Better: Test specific behavior instead
it('should display user information', () => {
  render(<UserCard user={{ id: '1', name: 'John', email: 'john@example.com' }} />);

  expect(screen.getByText('John')).toBeInTheDocument();
  expect(screen.getByText('john@example.com')).toBeInTheDocument();
});
```

## Test Isolation

**Tests Should Be Independent**

```javascript
// Bad: Tests depend on each other
describe('Counter', () => {
  let counter = 0;

  it('should increment', () => {
    counter++; // ❌ Mutating shared state
    expect(counter).toBe(1);
  });

  it('should increment again', () => {
    counter++; // ❌ Depends on previous test
    expect(counter).toBe(2);
  });
});

// Good: Each test is independent
describe('Counter', () => {
  it('should increment from 0 to 1', () => {
    let counter = 0;
    counter++;
    expect(counter).toBe(1);
  });

  it('should increment from 5 to 6', () => {
    let counter = 5;
    counter++;
    expect(counter).toBe(6);
  });
});
```

## Performance Testing

**Avoid Slow Tests**

```javascript
// Bad: Unnecessary delays
it('should process data', async () => {
  await new Promise(resolve => setTimeout(resolve, 1000)); // ❌ Don't use real delays
  const result = processData();
  expect(result).toBe('processed');
});

// Good: Use fake timers
it('should process data after delay', () => {
  jest.useFakeTimers();

  const callback = jest.fn();
  delayedProcess(callback);

  jest.advanceTimersByTime(1000);

  expect(callback).toHaveBeenCalled();

  jest.useRealTimers();
});
```

## Custom Matchers

**Extend Jest for Domain-Specific Assertions**

```javascript
expect.extend({
  toBeValidEmail(received) {
    const pass = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(received);
    return {
      pass,
      message: () => `expected ${received} to be a valid email`
    };
  }
});

it('should validate email', () => {
  expect('john@example.com').toBeValidEmail();
  expect('invalid-email').not.toBeValidEmail();
});
```

## Testing Best Practices Summary

✓ Use Given-When-Then structure
✓ One logical assertion per test
✓ Descriptive test names
✓ Mock external dependencies, not the system under test
✓ Reset mocks between tests
✓ Test happy path, error cases, and edge cases
✓ Always await or return promises in async tests
✓ Query by accessibility (role, label), not implementation
✓ Use userEvent for realistic user interactions
✓ Keep tests independent and isolated
✓ Fast tests (use fake timers, mock network)
✗ Don't test implementation details
✗ Don't share mutable state between tests
✗ Don't use real delays in tests
✗ Don't overuse snapshot testing