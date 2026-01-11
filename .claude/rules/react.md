---
pattern: "**/*.{jsx,tsx}"
---

# React Development Patterns

These rules apply to all React components and JSX/TSX files.

## Component Structure

**Functional Components Only**
- Use functional components with hooks, not class components
- Keep components focused and single-purpose
- Extract reusable logic into custom hooks

```javascript
// Good: Functional component with hooks
import { useState, useEffect } from 'react';

export function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>{user.name}</div>;
}

// Bad: Class component
class UserProfile extends React.Component { /* ... */ }
```

**Component Organization**
```
src/
├── components/           # Reusable components
│   ├── ui/              # Pure UI components
│   │   ├── Button.jsx
│   │   └── Card.jsx
│   └── forms/           # Form components
│       └── LoginForm.jsx
├── features/            # Feature-specific components
│   ├── users/
│   │   ├── UserList.jsx
│   │   ├── UserDetail.jsx
│   │   └── useUsers.js  # Custom hook
│   └── posts/
│       └── PostList.jsx
├── pages/               # Page/route components
│   ├── HomePage.jsx
│   └── UserPage.jsx
├── layouts/             # Layout components
│   └── MainLayout.jsx
├── hooks/               # Shared custom hooks
│   ├── useAuth.js
│   └── useFetch.js
└── utils/               # Utilities
    └── api.js
```

## Props & TypeScript

**Always Type Props**

```typescript
// Good: Typed props with TypeScript
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
  };
  onEdit?: (id: string) => void;
  variant?: 'compact' | 'full';
}

export function UserCard({ user, onEdit, variant = 'full' }: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      {variant === 'full' && <p>{user.email}</p>}
      {onEdit && <button onClick={() => onEdit(user.id)}>Edit</button>}
    </div>
  );
}

// Alternative: With PropTypes (JavaScript)
import PropTypes from 'prop-types';

UserCard.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired
  }).isRequired,
  onEdit: PropTypes.func,
  variant: PropTypes.oneOf(['compact', 'full'])
};
```

**Props Destructuring**
- Destructure props in function signature for clarity
- Provide default values when appropriate
- Avoid prop drilling - use Context or state management for deep hierarchies

```javascript
// Good: Clear destructuring with defaults
export function Button({
  children,
  variant = 'primary',
  disabled = false,
  onClick
}) {
  return (
    <button
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}

// Bad: Accessing via props object
export function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>;
}
```

## Hooks Best Practices

**Rules of Hooks**
- Only call hooks at the top level (not in loops, conditions, or nested functions)
- Only call hooks in React function components or custom hooks
- Declare all dependencies in useEffect, useCallback, useMemo arrays

```javascript
// Good: Hooks at top level
function MyComponent({ userId }) {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    if (userId) {
      fetchUser(userId).then(setUser);
    }
  }, [userId]);

  return <div>{user?.name}</div>;
}

// Bad: Conditional hook
function MyComponent({ userId }) {
  if (userId) {
    const [user, setUser] = useState(null); // ❌ Hook in condition
  }
}
```

**useEffect Best Practices**

```javascript
// Good: Proper cleanup
useEffect(() => {
  const controller = new AbortController();

  fetch(`/api/users/${id}`, { signal: controller.signal })
    .then(res => res.json())
    .then(setUser)
    .catch(err => {
      if (err.name !== 'AbortError') {
        console.error(err);
      }
    });

  // Cleanup function
  return () => controller.abort();
}, [id]);

// Good: Multiple focused effects
useEffect(() => {
  // Effect 1: Fetch user
  fetchUser(userId).then(setUser);
}, [userId]);

useEffect(() => {
  // Effect 2: Track analytics
  trackPageView(userId);
}, [userId]);

// Bad: Single effect doing too much
useEffect(() => {
  fetchUser(userId).then(setUser);
  trackPageView(userId);
  updateTitle(userId);
  logActivity(userId);
}, [userId]);
```

**Avoid Unnecessary useEffect**

```javascript
// Bad: useEffect for derived state
function Cart({ items }) {
  const [total, setTotal] = useState(0);

  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0));
  }, [items]);

  return <div>Total: ${total}</div>;
}

// Good: Compute directly
function Cart({ items }) {
  const total = items.reduce((sum, item) => sum + item.price, 0);
  return <div>Total: ${total}</div>;
}
```

**Custom Hooks**
- Prefix with 'use' (useAuth, useFetch, useLocalStorage)
- Extract reusable logic from components
- Return data and functions that components need

```javascript
// Good: Reusable custom hook
function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    setLoading(true);
    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [url]);

  return { data, loading, error };
}

// Usage
function UserList() {
  const { data: users, loading, error } = useFetch('/api/users');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <ul>{users.map(user => <li key={user.id}>{user.name}</li>)}</ul>;
}
```

## Performance Optimization

**React.memo for Expensive Components**

```javascript
import { memo } from 'react';

// Memoize component to prevent unnecessary re-renders
export const ExpensiveList = memo(function ExpensiveList({ items, onItemClick }) {
  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => onItemClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});

// With custom comparison
export const UserCard = memo(
  function UserCard({ user }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

**useMemo for Expensive Calculations**

```javascript
import { useMemo } from 'react';

function DataTable({ data, filters }) {
  // Memoize expensive filtering operation
  const filteredData = useMemo(() => {
    return data.filter(item => {
      return Object.entries(filters).every(([key, value]) =>
        item[key].includes(value)
      );
    });
  }, [data, filters]);

  return <table>{/* render filteredData */}</table>;
}

// Don't overuse - only for expensive operations
// Bad: Memoizing cheap operations
const fullName = useMemo(() => `${firstName} ${lastName}`, [firstName, lastName]); // ❌
// Good: Just compute it
const fullName = `${firstName} ${lastName}`; // ✓
```

**useCallback for Stable Function References**

```javascript
import { useCallback } from 'react';

function TodoList() {
  const [todos, setTodos] = useState([]);

  // Memoize callback to prevent child re-renders
  const handleToggle = useCallback((id) => {
    setTodos(prev => prev.map(todo =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    ));
  }, []);

  return (
    <div>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle} // Stable reference
        />
      ))}
    </div>
  );
}
```

**Code Splitting & Lazy Loading**

```javascript
import { lazy, Suspense } from 'react';

// Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'));
const UserSettings = lazy(() => import('./UserSettings'));

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div>Loading chart...</div>}>
        <HeavyChart />
      </Suspense>
    </div>
  );
}

// Route-based code splitting with React Router
const routes = [
  {
    path: '/',
    element: <Home />
  },
  {
    path: '/dashboard',
    element: (
      <Suspense fallback={<LoadingSpinner />}>
        <Dashboard />
      </Suspense>
    )
  }
];
```

## State Management

**Local State First**
```javascript
// Good: Local state for component-specific data
function Counter() {
  const [count, setCount] = useState(0);
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}
```

**Context for Shared UI State**

```javascript
import { createContext, useContext, useState } from 'react';

// Theme context example
const ThemeContext = createContext();

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Usage
function App() {
  return (
    <ThemeProvider>
      <Header />
      <Main />
    </ThemeProvider>
  );
}

function Header() {
  const { theme, toggleTheme } = useTheme();
  return (
    <header className={theme}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </header>
  );
}
```

**Server State with React Query**

```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch data with caching
function UserProfile({ userId }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(res => res.json()),
    staleTime: 5 * 60 * 1000 // 5 minutes
  });

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <div>{user.name}</div>;
}

// Mutations with cache updates
function UpdateUserForm({ userId }) {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (userData) =>
      fetch(`/api/users/${userId}`, {
        method: 'PUT',
        body: JSON.stringify(userData)
      }),
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['user', userId] });
    }
  });

  return <form onSubmit={e => {
    e.preventDefault();
    mutation.mutate({ name: e.target.name.value });
  }}>
    {/* form fields */}
  </form>;
}
```

## Forms

**Form Handling with react-hook-form**

```javascript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2, 'Name must be at least 2 characters')
});

function SignupForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm({
    resolver: zodResolver(schema)
  });

  const onSubmit = async (data) => {
    await fetch('/api/signup', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} placeholder="Email" />
      {errors.email && <span>{errors.email.message}</span>}

      <input {...register('password')} type="password" placeholder="Password" />
      {errors.password && <span>{errors.password.message}</span>}

      <input {...register('name')} placeholder="Name" />
      {errors.name && <span>{errors.name.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Sign Up'}
      </button>
    </form>
  );
}
```

## Error Boundaries

**Catch React Errors**

```javascript
import { Component } from 'react';

export class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Log to error reporting service
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <h2>Something went wrong</h2>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.toString()}</pre>
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
function App() {
  return (
    <ErrorBoundary>
      <Router>
        <Routes />
      </Router>
    </ErrorBoundary>
  );
}
```

## Accessibility

**Always Consider A11y**

```javascript
// Good: Semantic HTML with proper labels
function LoginForm() {
  return (
    <form>
      <label htmlFor="email">Email</label>
      <input
        id="email"
        type="email"
        aria-required="true"
        aria-describedby="email-error"
      />
      <span id="email-error" role="alert">
        {error && 'Invalid email'}
      </span>

      <button type="submit" aria-label="Sign in to your account">
        Sign In
      </button>
    </form>
  );
}

// Icon buttons need labels
<button aria-label="Close dialog">
  <CloseIcon />
</button>

// Images need alt text
<img src="user.jpg" alt="User profile picture" />
```

## Keys in Lists

**Always Use Stable, Unique Keys**

```javascript
// Good: Stable unique keys
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}

// Bad: Index as key (problematic if list reorders)
{users.map((user, index) => (
  <UserCard key={index} user={user} />
))}

// Bad: Non-unique keys
{users.map(user => (
  <UserCard key={user.role} user={user} />
))}
```

## Common Patterns

**Conditional Rendering**

```javascript
// Good: Logical AND for simple conditionals
{isLoggedIn && <UserMenu />}

// Good: Ternary for if-else
{isLoading ? <Spinner /> : <Content />}

// Good: Early returns for complex conditions
function UserProfile({ user }) {
  if (!user) return <div>Please log in</div>;
  if (user.suspended) return <div>Account suspended</div>;

  return <div>Welcome, {user.name}</div>;
}

// Avoid: Complex nested ternaries
{isLoading ? <Spinner /> : data ? <List data={data} /> : error ? <Error /> : null} // ❌
```

**Prop Spreading**

```javascript
// Good: Spread remaining props
function Button({ variant, children, ...props }) {
  return (
    <button className={`btn-${variant}`} {...props}>
      {children}
    </button>
  );
}

// Usage
<Button variant="primary" onClick={handleClick} disabled>
  Submit
</Button>
```