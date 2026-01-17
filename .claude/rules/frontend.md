# Frontend Development (React + MUI)

## Project Structure

```
src/
├── components/
│   ├── ui/              # Reusable UI components (Button, Card, Modal)
│   └── forms/           # Form components (TextField, Select wrappers)
├── features/            # Feature-specific components
│   └── users/
│       ├── UserList.jsx
│       ├── UserProfile.jsx
│       └── useUsers.js  # Feature-specific hooks
├── pages/               # Route page components
├── layouts/             # Layout wrappers (MainLayout, AuthLayout)
├── hooks/               # Shared custom hooks
├── context/             # React Context providers
├── utils/               # Utility functions
├── api/                 # API client and endpoints
└── theme/               # MUI theme configuration
```

## Component Patterns

### Functional Components Only

```javascript
/**
 * User profile display component
 * @param {Object} props - Component props
 * @param {User} props.user - User data object
 * @param {Function} [props.onEdit] - Edit callback
 * @returns {JSX.Element} Rendered component
 */
export function UserProfile({ user, onEdit }) {
  const [loading, setLoading] = useState(false);

  if (loading) return <CircularProgress />;

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4">{user.name}</Typography>
      {onEdit && (
        <Button onClick={() => onEdit(user.id)} variant="outlined">
          Edit
        </Button>
      )}
    </Box>
  );
}
```

### Component Composition

```javascript
// Prefer composition over prop drilling
function UserCard({ children }) {
  return (
    <Card sx={{ p: 2 }}>
      {children}
    </Card>
  );
}

function UserCardHeader({ title, subtitle }) {
  return (
    <Box sx={{ mb: 2 }}>
      <Typography variant="h6">{title}</Typography>
      <Typography variant="body2" color="text.secondary">
        {subtitle}
      </Typography>
    </Box>
  );
}

// Usage
<UserCard>
  <UserCardHeader title={user.name} subtitle={user.email} />
  <UserCardActions user={user} />
</UserCard>
```

## Hooks Best Practices

### Rules of Hooks

```javascript
// Always at top level, never in conditions
function Component({ userId }) {
  // Correct: hooks at top level
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const theme = useTheme();

  // Condition inside hook, not around it
  useEffect(() => {
    if (userId) {
      fetchUser(userId).then(setData).catch(setError);
    }
  }, [userId]);

  // Early returns after all hooks
  if (error) return <Alert severity="error">{error.message}</Alert>;
  if (!data) return <CircularProgress />;

  return <UserProfile user={data} />;
}
```

### Custom Hooks Pattern

```javascript
/**
 * Hook for fetching and managing user data
 * @param {string} userId - User ID to fetch
 * @returns {Object} User state and actions
 */
function useUser(userId) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      try {
        setLoading(true);
        const data = await api.getUser(userId);
        if (!cancelled) setUser(data);
      } catch (err) {
        if (!cancelled) setError(err);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchUser();
    return () => { cancelled = true; };
  }, [userId]);

  return { user, loading, error };
}
```

## MUI Styling

### sx Prop (Primary Method)

```javascript
// Always use theme values
<Box
  sx={{
    p: 2,                      // padding: theme.spacing(2) = 16px
    m: 1,                      // margin: theme.spacing(1) = 8px
    bgcolor: 'primary.main',   // theme.palette.primary.main
    color: 'text.secondary',   // theme.palette.text.secondary
    borderRadius: 1,           // theme.shape.borderRadius * 1
    boxShadow: 2,              // theme.shadows[2]
    '&:hover': {
      bgcolor: 'primary.dark',
    },
  }}
>
```

### Responsive Values

```javascript
<Box
  sx={{
    // Different values per breakpoint
    width: { xs: '100%', sm: '50%', md: '33%' },
    p: { xs: 2, md: 4 },
    flexDirection: { xs: 'column', md: 'row' },
    display: { xs: 'none', md: 'flex' },
  }}
>
```

### Never Use Inline Styles

```javascript
// Bad - hardcoded values, no theme integration
<div style={{ padding: '16px', color: '#1976d2' }}>

// Good - uses theme, responsive, maintainable
<Box sx={{ p: 2, color: 'primary.main' }}>
```

## MUI Theme Configuration

```javascript
// theme/index.js
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
      light: '#42a5f5',
      dark: '#1565c0',
    },
    secondary: {
      main: '#9c27b0',
    },
    error: {
      main: '#d32f2f',
    },
    background: {
      default: '#fafafa',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: { fontSize: '2.5rem', fontWeight: 600 },
    h2: { fontSize: '2rem', fontWeight: 600 },
    h3: { fontSize: '1.75rem', fontWeight: 600 },
  },
  shape: {
    borderRadius: 8,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none', // No uppercase
        },
      },
    },
  },
});

export default theme;
```

### Theme Provider Setup

```javascript
// App.jsx
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AppRoutes />
      </Router>
    </ThemeProvider>
  );
}
```

## Common MUI Patterns

### Layout with Grid

```javascript
import { Grid, Container } from '@mui/material';

function Dashboard() {
  return (
    <Container maxWidth="lg">
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <MainContent />
        </Grid>
        <Grid item xs={12} md={4}>
          <Sidebar />
        </Grid>
      </Grid>
    </Container>
  );
}
```

### Dialogs

```javascript
function ConfirmDialog({ open, onClose, onConfirm, title, message }) {
  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <Typography>{message}</Typography>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button onClick={onConfirm} variant="contained" color="primary">
          Confirm
        </Button>
      </DialogActions>
    </Dialog>
  );
}
```

### Snackbar Notifications

```javascript
function useNotification() {
  const [notification, setNotification] = useState(null);

  const notify = useCallback((message, severity = 'info') => {
    setNotification({ message, severity });
  }, []);

  const close = useCallback(() => setNotification(null), []);

  const NotificationSnackbar = (
    <Snackbar
      open={!!notification}
      autoHideDuration={6000}
      onClose={close}
      anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
    >
      {notification && (
        <Alert severity={notification.severity} onClose={close}>
          {notification.message}
        </Alert>
      )}
    </Snackbar>
  );

  return { notify, NotificationSnackbar };
}
```

## Forms with react-hook-form

```javascript
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Minimum 8 characters'),
});

function LoginForm({ onSubmit }) {
  const {
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm({
    resolver: zodResolver(schema),
    defaultValues: { email: '', password: '' },
  });

  return (
    <Box component="form" onSubmit={handleSubmit(onSubmit)} sx={{ mt: 2 }}>
      <Controller
        name="email"
        control={control}
        render={({ field }) => (
          <TextField
            {...field}
            label="Email"
            fullWidth
            margin="normal"
            error={!!errors.email}
            helperText={errors.email?.message}
          />
        )}
      />
      <Controller
        name="password"
        control={control}
        render={({ field }) => (
          <TextField
            {...field}
            label="Password"
            type="password"
            fullWidth
            margin="normal"
            error={!!errors.password}
            helperText={errors.password?.message}
          />
        )}
      />
      <Button
        type="submit"
        variant="contained"
        fullWidth
        disabled={isSubmitting}
        sx={{ mt: 2 }}
      >
        {isSubmitting ? <CircularProgress size={24} /> : 'Sign In'}
      </Button>
    </Box>
  );
}
```

## State Management

### Local State First

```javascript
// Simple component state
const [open, setOpen] = useState(false);
const [value, setValue] = useState('');
```

### Context for UI State

```javascript
// context/ThemeContext.jsx
const ThemeModeContext = createContext();

export function ThemeModeProvider({ children }) {
  const [mode, setMode] = useState('light');
  const toggle = () => setMode(m => m === 'light' ? 'dark' : 'light');

  return (
    <ThemeModeContext.Provider value={{ mode, toggle }}>
      {children}
    </ThemeModeContext.Provider>
  );
}

export const useThemeMode = () => useContext(ThemeModeContext);
```

### React Query for Server State

```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.getUsers(),
  });
}

function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data) => api.createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

## Performance Optimization

### React.memo for Expensive Components

```javascript
export const UserList = memo(function UserList({ users, onSelect }) {
  return (
    <List>
      {users.map(user => (
        <UserListItem key={user.id} user={user} onSelect={onSelect} />
      ))}
    </List>
  );
});
```

### useMemo for Expensive Calculations

```javascript
const filteredUsers = useMemo(() => {
  return users.filter(u => u.name.includes(search));
}, [users, search]);
```

### useCallback for Stable References

```javascript
const handleSelect = useCallback((id) => {
  setSelected(id);
}, []);
```

### Lazy Loading

```javascript
const UserDashboard = lazy(() => import('./features/users/UserDashboard'));

function App() {
  return (
    <Suspense fallback={<CircularProgress />}>
      <UserDashboard />
    </Suspense>
  );
}
```

## Accessibility

### Always Include ARIA Labels

```javascript
<IconButton aria-label="Delete user">
  <DeleteIcon />
</IconButton>

<IconButton aria-label="Close dialog" onClick={onClose}>
  <CloseIcon />
</IconButton>
```

### Form Accessibility

```javascript
<TextField
  id="email"
  label="Email Address"
  inputProps={{ 'aria-describedby': 'email-helper' }}
/>
<FormHelperText id="email-helper">
  We'll never share your email
</FormHelperText>
```

### Image Alt Text

```javascript
<Avatar alt={`${user.name}'s profile picture`} src={user.avatar} />
```

## Error Boundaries

```javascript
class ErrorBoundary extends Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return (
        <Box sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h5" gutterBottom>
            Something went wrong
          </Typography>
          <Button onClick={() => window.location.reload()}>
            Reload Page
          </Button>
        </Box>
      );
    }
    return this.props.children;
  }
}
```

## Checklist

Before completing frontend work:

- [ ] Functional components only (no classes except ErrorBoundary)
- [ ] Hooks at top level, never in conditions
- [ ] Unique keys on list items (not array index)
- [ ] sx prop for all styling (no inline styles)
- [ ] Theme values for colors/spacing
- [ ] aria-label on all icon buttons
- [ ] Loading and error states handled
- [ ] Forms validated with Zod
- [ ] Responsive design tested
- [ ] Console errors cleared