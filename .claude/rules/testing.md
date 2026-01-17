# Testing Guidelines

## Testing Philosophy

- **Test behavior, not implementation** - Tests should verify what code does, not how it does it
- **Given-When-Then structure** - Clear test organization
- **Independent tests** - Each test runs in isolation
- **Fast feedback** - Unit tests should run in milliseconds

## Coverage Requirements

| Scope | Minimum Coverage |
|-------|------------------|
| Overall project | 60% |
| Per file | 20% |

```javascript
// jest.config.js
export default {
  coverageThreshold: {
    global: {
      branches: 60,
      functions: 60,
      lines: 60,
      statements: 60,
    },
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx}',
    '!src/**/*.test.{js,jsx}',
    '!src/**/index.js',
  ],
};
```

## Test Structure (Given-When-Then)

```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Given - Setup preconditions
      const userData = {
        email: 'john@example.com',
        password: 'password123',
        name: 'John Doe',
      };

      // When - Execute the action
      const user = await userService.createUser(userData);

      // Then - Verify results
      expect(user).toMatchObject({
        email: 'john@example.com',
        name: 'John Doe',
      });
      expect(user.id).toBeDefined();
      expect(user.password).toBeUndefined(); // Password not returned
    });

    it('should throw ValidationError for invalid email', async () => {
      // Given
      const invalidData = { email: 'invalid', password: 'password123' };

      // When/Then
      await expect(userService.createUser(invalidData))
        .rejects
        .toThrow(ValidationError);
    });

    it('should throw ConflictError for duplicate email', async () => {
      // Given
      const userData = { email: 'existing@example.com', password: 'pass123' };
      await userService.createUser(userData);

      // When/Then
      await expect(userService.createUser(userData))
        .rejects
        .toThrow(ConflictError);
    });
  });
});
```

## Unit Testing

### Pure Functions

```javascript
// utils/format.js
export function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}

// utils/format.test.js
describe('formatCurrency', () => {
  it('should format USD by default', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56');
  });

  it('should format with specified currency', () => {
    expect(formatCurrency(1234.56, 'EUR')).toBe('€1,234.56');
  });

  it('should handle zero', () => {
    expect(formatCurrency(0)).toBe('$0.00');
  });

  it('should handle negative numbers', () => {
    expect(formatCurrency(-50)).toBe('-$50.00');
  });
});
```

### Services with Dependencies

```javascript
// services/user.service.test.js
import { userService } from './user.service.js';
import { User } from '../models/user.model.js';
import { NotFoundError } from '../utils/errors.js';

// Mock the model
jest.mock('../models/user.model.js');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getUserById', () => {
    it('should return user when found', async () => {
      // Given
      const mockUser = { id: '123', name: 'John', email: 'john@example.com' };
      User.findById.mockResolvedValue(mockUser);

      // When
      const result = await userService.getUserById('123');

      // Then
      expect(result).toEqual(mockUser);
      expect(User.findById).toHaveBeenCalledWith('123');
    });

    it('should throw NotFoundError when user not found', async () => {
      // Given
      User.findById.mockResolvedValue(null);

      // When/Then
      await expect(userService.getUserById('999'))
        .rejects
        .toThrow(NotFoundError);
    });
  });
});
```

### Async Testing

```javascript
describe('async operations', () => {
  // Always use async/await
  it('should fetch user data', async () => {
    const user = await fetchUser('123');
    expect(user.name).toBe('John');
  });

  // Test rejected promises
  it('should handle fetch errors', async () => {
    await expect(fetchUser('invalid'))
      .rejects
      .toThrow('User not found');
  });

  // Test with fake timers
  it('should debounce search', async () => {
    jest.useFakeTimers();
    const onSearch = jest.fn();

    search('test', onSearch);
    search('test2', onSearch);

    jest.advanceTimersByTime(300);

    expect(onSearch).toHaveBeenCalledTimes(1);
    expect(onSearch).toHaveBeenCalledWith('test2');

    jest.useRealTimers();
  });
});
```

## Integration Testing

### API Endpoint Testing (Supertest)

```javascript
// routes/users.routes.test.js
import request from 'supertest';
import app from '../app.js';
import { User } from '../models/user.model.js';
import { generateToken } from '../utils/auth.js';

describe('Users API', () => {
  let authToken;
  let testUser;

  beforeAll(async () => {
    // Create test user and get token
    testUser = await User.create({
      email: 'admin@test.com',
      password: 'hashedpassword',
      name: 'Admin',
      role: 'admin',
    });
    authToken = generateToken(testUser);
  });

  afterAll(async () => {
    await User.deleteMany({});
  });

  describe('GET /api/users', () => {
    it('should return paginated users list', async () => {
      // When
      const response = await request(app)
        .get('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      // Then
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.pagination).toMatchObject({
        page: expect.any(Number),
        limit: expect.any(Number),
        total: expect.any(Number),
      });
    });

    it('should return 401 without auth token', async () => {
      await request(app)
        .get('/api/users')
        .expect(401);
    });
  });

  describe('POST /api/users', () => {
    it('should create user with valid data', async () => {
      // Given
      const newUser = {
        email: 'new@example.com',
        password: 'password123',
        name: 'New User',
      };

      // When
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send(newUser)
        .expect(201);

      // Then
      expect(response.body.success).toBe(true);
      expect(response.body.data.email).toBe(newUser.email);
      expect(response.body.data.password).toBeUndefined();
    });

    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: 'invalid', password: 'pass123', name: 'Test' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toContain('Validation');
    });

    it('should return 409 for duplicate email', async () => {
      const existingEmail = testUser.email;

      await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: existingEmail, password: 'pass123', name: 'Test' })
        .expect(409);
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by id', async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.data.id).toBe(testUser.id);
    });

    it('should return 404 for non-existent user', async () => {
      await request(app)
        .get('/api/users/nonexistent-id')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });
});
```

## React Component Testing

### Basic Component Test

```javascript
// components/UserProfile.test.jsx
import { render, screen } from '@testing-library/react';
import { UserProfile } from './UserProfile';

describe('UserProfile', () => {
  const mockUser = {
    id: '123',
    name: 'John Doe',
    email: 'john@example.com',
  };

  it('should render user name', () => {
    render(<UserProfile user={mockUser} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });

  it('should render user email', () => {
    render(<UserProfile user={mockUser} />);

    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('should not render edit button when onEdit not provided', () => {
    render(<UserProfile user={mockUser} />);

    expect(screen.queryByRole('button', { name: /edit/i })).not.toBeInTheDocument();
  });

  it('should render edit button when onEdit provided', () => {
    render(<UserProfile user={mockUser} onEdit={jest.fn()} />);

    expect(screen.getByRole('button', { name: /edit/i })).toBeInTheDocument();
  });
});
```

### User Interaction Tests

```javascript
// components/LoginForm.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('should submit form with valid data', async () => {
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
        password: 'password123',
      });
    });
  });

  it('should show validation error for invalid email', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={jest.fn()} />);

    await user.type(screen.getByLabelText(/email/i), 'invalid');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
  });

  it('should disable submit button while loading', async () => {
    const user = userEvent.setup();
    const slowSubmit = () => new Promise(resolve => setTimeout(resolve, 1000));

    render(<LoginForm onSubmit={slowSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'john@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(screen.getByRole('button', { name: /sign in/i })).toBeDisabled();
  });
});
```

### Query Priority (Accessibility First)

```javascript
// Best - queries accessible to everyone
screen.getByRole('button', { name: /submit/i });
screen.getByRole('textbox', { name: /email/i });
screen.getByRole('checkbox', { name: /remember/i });

// Good - accessible to screen readers
screen.getByLabelText(/email address/i);
screen.getByPlaceholderText(/search/i);
screen.getByText(/welcome/i);

// Last resort - only when nothing else works
screen.getByTestId('custom-dropdown');
```

### Testing Async Components

```javascript
// components/UserList.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserList } from './UserList';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json({
      success: true,
      data: [
        { id: '1', name: 'John', email: 'john@example.com' },
        { id: '2', name: 'Jane', email: 'jane@example.com' },
      ],
    }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserList', () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  const renderWithQuery = (ui) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {ui}
      </QueryClientProvider>
    );
  };

  it('should show loading state initially', () => {
    renderWithQuery(<UserList />);

    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('should render users after loading', async () => {
    renderWithQuery(<UserList />);

    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument();
      expect(screen.getByText('Jane')).toBeInTheDocument();
    });
  });

  it('should show error state on API failure', async () => {
    server.use(
      rest.get('/api/users', (req, res, ctx) => {
        return res(ctx.status(500));
      })
    );

    renderWithQuery(<UserList />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});
```

### Testing Hooks

```javascript
// hooks/useUser.test.js
import { renderHook, waitFor } from '@testing-library/react';
import { useUser } from './useUser';

describe('useUser', () => {
  it('should return loading state initially', () => {
    const { result } = renderHook(() => useUser('123'));

    expect(result.current.loading).toBe(true);
    expect(result.current.user).toBeNull();
  });

  it('should return user data after fetch', async () => {
    const { result } = renderHook(() => useUser('123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.user).toMatchObject({
        id: '123',
        name: 'John',
      });
    });
  });

  it('should return error on fetch failure', async () => {
    const { result } = renderHook(() => useUser('invalid'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeTruthy();
    });
  });
});
```

## Mocking Patterns

### Module Mocks

```javascript
// Mock entire module
jest.mock('../services/email.service');

import { emailService } from '../services/email.service';

beforeEach(() => {
  jest.clearAllMocks();
});

it('should send welcome email', async () => {
  await userService.register({ email: 'john@example.com' });

  expect(emailService.sendWelcome).toHaveBeenCalledWith('john@example.com');
});
```

### Partial Mocks

```javascript
// Mock specific exports
jest.mock('../utils/helpers', () => ({
  ...jest.requireActual('../utils/helpers'),
  generateId: jest.fn(() => 'mock-id'),
}));
```

### Mock Implementations

```javascript
// Different return values
mockFn.mockResolvedValueOnce({ id: '1' })
      .mockResolvedValueOnce({ id: '2' })
      .mockRejectedValueOnce(new Error('Failed'));

// Custom implementation
mockFn.mockImplementation((id) => {
  if (id === 'invalid') throw new NotFoundError();
  return { id, name: 'Test' };
});
```

## Test Isolation

```javascript
describe('Database tests', () => {
  beforeAll(async () => {
    await db.connect();
  });

  afterAll(async () => {
    await db.disconnect();
  });

  beforeEach(async () => {
    // Clean slate for each test
    await db.query('TRUNCATE TABLE users CASCADE');
  });

  afterEach(() => {
    jest.clearAllMocks();
  });
});
```

## Test Naming Conventions

```javascript
// Good - describes behavior
it('should return 404 when user not found')
it('should hash password before storing')
it('should prevent duplicate email registration')
it('should display error message on invalid input')

// Bad - describes implementation
it('calls the database')
it('uses bcrypt')
it('checks the array')
```

## Checklist

Before completing tests:

- [ ] Given-When-Then structure used
- [ ] One logical assertion per test (or closely related)
- [ ] Tests are independent (no shared mutable state)
- [ ] Async operations properly awaited
- [ ] Mocks reset between tests
- [ ] Query by role/label, not test IDs (React)
- [ ] userEvent over fireEvent (React)
- [ ] No real delays (use fake timers)
- [ ] Error scenarios tested
- [ ] Edge cases covered
- [ ] Coverage meets thresholds (60%/20%)