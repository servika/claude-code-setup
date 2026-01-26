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

## E2E Testing (Playwright)

### Project Setup

```bash
# Install Playwright
npm init playwright@latest

# Project structure
tests/
├── e2e/
│   ├── auth.spec.ts        # Authentication tests
│   ├── users.spec.ts       # User management tests
│   └── checkout.spec.ts    # Checkout flow tests
├── fixtures/
│   └── test-data.ts        # Test data factories
├── pages/
│   ├── LoginPage.ts        # Page Object: Login
│   ├── DashboardPage.ts    # Page Object: Dashboard
│   └── BasePage.ts         # Base page class
└── playwright.config.ts    # Configuration
```

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

### Page Object Model

```typescript
// tests/pages/BasePage.ts
import { Page, Locator, expect } from '@playwright/test';

export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async navigate(path: string): Promise<void> {
    await this.page.goto(path);
  }

  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  async getToastMessage(): Promise<string | null> {
    const toast = this.page.locator('[role="alert"]');
    if (await toast.isVisible()) {
      return toast.textContent();
    }
    return null;
  }
}
```

```typescript
// tests/pages/LoginPage.ts
import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: /sign in/i });
    this.errorMessage = page.getByRole('alert');
  }

  async goto(): Promise<void> {
    await this.navigate('/login');
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoggedIn(): Promise<void> {
    await expect(this.page).toHaveURL(/dashboard/);
  }
}
```

```typescript
// tests/pages/DashboardPage.ts
import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class DashboardPage extends BasePage {
  readonly welcomeMessage: Locator;
  readonly userMenu: Locator;
  readonly logoutButton: Locator;

  constructor(page: Page) {
    super(page);
    this.welcomeMessage = page.getByRole('heading', { level: 1 });
    this.userMenu = page.getByRole('button', { name: /user menu/i });
    this.logoutButton = page.getByRole('menuitem', { name: /logout/i });
  }

  async goto(): Promise<void> {
    await this.navigate('/dashboard');
  }

  async logout(): Promise<void> {
    await this.userMenu.click();
    await this.logoutButton.click();
  }

  async expectWelcome(name: string): Promise<void> {
    await expect(this.welcomeMessage).toContainText(name);
  }
}
```

### E2E Test Examples

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { DashboardPage } from '../pages/DashboardPage';

test.describe('Authentication', () => {
  test('user can login with valid credentials', async ({ page }) => {
    // Given
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // When
    await loginPage.login('user@example.com', 'password123');

    // Then
    await loginPage.expectLoggedIn();
    const dashboard = new DashboardPage(page);
    await dashboard.expectWelcome('Welcome');
  });

  test('shows error for invalid credentials', async ({ page }) => {
    // Given
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // When
    await loginPage.login('user@example.com', 'wrongpassword');

    // Then
    await loginPage.expectError('Invalid credentials');
  });

  test('user can logout', async ({ page }) => {
    // Given - User is logged in
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');
    
    const dashboard = new DashboardPage(page);
    await dashboard.expectWelcome('Welcome');

    // When
    await dashboard.logout();

    // Then
    await expect(page).toHaveURL(/login/);
  });
});
```

### Test Data Management

```typescript
// tests/fixtures/test-data.ts
export const testUsers = {
  admin: {
    email: 'admin@example.com',
    password: 'admin123',
    name: 'Admin User',
    role: 'admin',
  },
  regular: {
    email: 'user@example.com',
    password: 'user123',
    name: 'Regular User',
    role: 'user',
  },
};

export const testProducts = {
  basic: {
    name: 'Test Product',
    price: 99.99,
    description: 'Test product description',
  },
};
```

### Authentication State Reuse

```typescript
// tests/fixtures/auth.ts
import { test as base, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

// Define authenticated test fixture
export const test = base.extend<{ authenticatedPage: any }>({
  authenticatedPage: async ({ page }, use) => {
    // Perform login
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL(/dashboard/);
    
    // Use the authenticated page
    await use(page);
  },
});

// Or use storage state
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: {
        storageState: 'playwright/.auth/user.json',
      },
    },
  ],
});
```

```typescript
// tests/auth.setup.ts
import { test as setup, expect } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: /sign in/i }).click();
  await expect(page).toHaveURL(/dashboard/);
  
  // Save authentication state
  await page.context().storageState({ path: 'playwright/.auth/user.json' });
});
```

### API Mocking in E2E

```typescript
// tests/e2e/with-mocks.spec.ts
import { test, expect } from '@playwright/test';

test('handles API errors gracefully', async ({ page }) => {
  // Mock API to return error
  await page.route('**/api/users', (route) => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
    });
  });

  await page.goto('/users');

  // Should show error state
  await expect(page.getByText(/error loading users/i)).toBeVisible();
});

test('displays users from API', async ({ page }) => {
  // Mock API response
  await page.route('**/api/users', (route) => {
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        success: true,
        data: [
          { id: '1', name: 'John Doe', email: 'john@example.com' },
          { id: '2', name: 'Jane Doe', email: 'jane@example.com' },
        ],
      }),
    });
  });

  await page.goto('/users');

  await expect(page.getByText('John Doe')).toBeVisible();
  await expect(page.getByText('Jane Doe')).toBeVisible();
});
```

### Visual Regression Testing

```typescript
// tests/e2e/visual.spec.ts
import { test, expect } from '@playwright/test';

test('homepage visual regression', async ({ page }) => {
  await page.goto('/');
  
  // Full page screenshot
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
    maxDiffPixelRatio: 0.01,
  });
});

test('component visual regression', async ({ page }) => {
  await page.goto('/components');
  
  // Specific element screenshot
  const card = page.getByTestId('user-card');
  await expect(card).toHaveScreenshot('user-card.png');
});
```

### Accessibility Testing in E2E

```typescript
// tests/e2e/accessibility.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('homepage has no accessibility violations', async ({ page }) => {
    await page.goto('/');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    expect(results.violations).toEqual([]);
  });

  test('login page has no accessibility violations', async ({ page }) => {
    await page.goto('/login');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .exclude('.third-party-widget') // Exclude external content
      .analyze();

    expect(results.violations).toEqual([]);
  });
});
```

### CI Integration

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npx playwright test
        env:
          BASE_URL: http://localhost:3000

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Test Organization by Priority

```typescript
// tests/e2e/smoke.spec.ts - P0 Critical (run on every PR)
import { test, expect } from '@playwright/test';

test.describe('Smoke Tests @smoke', () => {
  test('app loads', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/App Name/);
  });

  test('login works', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page).toHaveURL(/dashboard/);
  });

  test('API health check', async ({ request }) => {
    const response = await request.get('/api/health');
    expect(response.ok()).toBeTruthy();
  });
});

// Run only smoke tests
// npx playwright test --grep @smoke
```

## Checklist

Before completing tests:

### Unit/Integration Tests
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

### E2E Tests (Playwright)
- [ ] Page Object Model used for reusability
- [ ] Authentication state reused where possible
- [ ] Tests are independent and can run in parallel
- [ ] Proper waiting strategies (no arbitrary sleeps)
- [ ] Screenshots/videos captured on failure
- [ ] Accessibility checks included
- [ ] Cross-browser testing configured
- [ ] CI pipeline integration complete