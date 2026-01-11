# Frontend Code Generator Agent

## Purpose
Generate production-ready React components with Material-UI (MUI), following best practices for performance, accessibility, and user experience.

## When to Invoke
- Creating new React components
- Building forms with MUI
- Implementing data tables/lists
- Creating layouts and navigation
- Building authentication UI
- Implementing state management
- Creating custom hooks

## Generation Principles

### 1. Component Architecture
```
Pages → Layouts → Features → UI Components → Atoms
```

### 2. Code Quality Standards
- Functional components with hooks
- JSDoc on all components
- PropTypes or JSDoc type annotations
- Accessibility (ARIA labels, keyboard navigation)
- Responsive design (mobile-first)
- Performance optimization (memo, useMemo, useCallback)

### 3. MUI Best Practices
- Use theme values (colors, spacing, breakpoints)
- sx prop over inline styles
- Consistent component composition
- Proper Grid2 usage for layouts
- Accessibility patterns

## Generation Templates

### 1. Page Component

```javascript
/**
 * UserListPage - Displays paginated list of users with search
 * @returns {JSX.Element} User list page component
 */
import { useState, useEffect } from 'react';
import {
  Box,
  Container,
  Typography,
  Paper,
  TextField,
  InputAdornment,
  CircularProgress,
  Alert,
} from '@mui/material';
import { Search as SearchIcon } from '@mui/icons-material';
import { useUsers } from '../hooks/useUsers';
import UserTable from '../components/UserTable';
import PageHeader from '../components/PageHeader';

export default function UserListPage() {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const { users, loading, error, pagination, refetch } = useUsers({ page, search });

  const handleSearchChange = (event) => {
    setSearch(event.target.value);
    setPage(1); // Reset to first page on search
  };

  const handlePageChange = (newPage) => {
    setPage(newPage);
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ py: 4 }}>
        <PageHeader
          title="Users"
          subtitle="Manage user accounts and permissions"
        />

        <Paper sx={{ mt: 3, p: 3 }}>
          <TextField
            fullWidth
            placeholder="Search users..."
            value={search}
            onChange={handleSearchChange}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 3 }}
          />

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error.message}
            </Alert>
          )}

          {loading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : (
            <UserTable
              users={users}
              pagination={pagination}
              onPageChange={handlePageChange}
              onRefresh={refetch}
            />
          )}
        </Paper>
      </Box>
    </Container>
  );
}
```

### 2. Feature Component with State

```javascript
/**
 * UserTable - Displays users in a sortable, paginated table
 * @param {Object} props - Component props
 * @param {Array} props.users - Array of user objects
 * @param {Object} props.pagination - Pagination metadata
 * @param {number} props.pagination.page - Current page
 * @param {number} props.pagination.pages - Total pages
 * @param {number} props.pagination.total - Total items
 * @param {Function} props.onPageChange - Page change callback
 * @param {Function} props.onRefresh - Refresh callback
 * @returns {JSX.Element} User table component
 */
import { useState } from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Avatar,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  MoreVert as MoreIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  PersonOff as DeactivateIcon,
} from '@mui/icons-material';

export default function UserTable({ users, pagination, onPageChange, onRefresh }) {
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedUser, setSelectedUser] = useState(null);

  const handleMenuOpen = (event, user) => {
    setAnchorEl(event.currentTarget);
    setSelectedUser(user);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setSelectedUser(null);
  };

  const handleEdit = () => {
    // TODO: Implement edit
    console.log('Edit user:', selectedUser);
    handleMenuClose();
  };

  const handleDelete = () => {
    // TODO: Implement delete
    console.log('Delete user:', selectedUser);
    handleMenuClose();
  };

  const handlePageChange = (event, newPage) => {
    onPageChange(newPage + 1); // MUI uses 0-based, API uses 1-based
  };

  return (
    <>
      <TableContainer>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>User</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Role</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users.map((user) => (
              <TableRow
                key={user.id}
                hover
                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
              >
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar src={user.avatar} alt={user.name}>
                      {user.name.charAt(0)}
                    </Avatar>
                    {user.name}
                  </Box>
                </TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>
                  <Chip
                    label={user.role}
                    size="small"
                    color={user.role === 'admin' ? 'primary' : 'default'}
                  />
                </TableCell>
                <TableCell>
                  <Chip
                    label={user.status}
                    size="small"
                    color={user.status === 'active' ? 'success' : 'default'}
                  />
                </TableCell>
                <TableCell align="right">
                  <IconButton
                    onClick={(e) => handleMenuOpen(e, user)}
                    aria-label={`Actions for ${user.name}`}
                  >
                    <MoreIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <TablePagination
        component="div"
        count={pagination.total}
        page={pagination.page - 1}
        onPageChange={handlePageChange}
        rowsPerPage={10}
        rowsPerPageOptions={[10]}
      />

      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
      >
        <MenuItem onClick={handleEdit}>
          <ListItemIcon>
            <EditIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>Edit</ListItemText>
        </MenuItem>
        <MenuItem onClick={handleDelete}>
          <ListItemIcon>
            <DeleteIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>Delete</ListItemText>
        </MenuItem>
      </Menu>
    </>
  );
}
```

### 3. Form Component with Validation

```javascript
/**
 * UserForm - Form for creating/editing users
 * @param {Object} props - Component props
 * @param {Object} [props.user] - User object for editing (optional)
 * @param {Function} props.onSubmit - Form submit callback
 * @param {Function} props.onCancel - Cancel callback
 * @returns {JSX.Element} User form component
 */
import { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormHelperText,
  Grid,
} from '@mui/material';
import { useForm, Controller } from 'react-hook-form';

const ROLES = [
  { value: 'user', label: 'User' },
  { value: 'admin', label: 'Admin' },
];

export default function UserForm({ user, onSubmit, onCancel }) {
  const [loading, setLoading] = useState(false);

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm({
    defaultValues: {
      name: user?.name || '',
      email: user?.email || '',
      role: user?.role || 'user',
      password: '',
    },
  });

  const onSubmitForm = async (data) => {
    setLoading(true);
    try {
      await onSubmit(data);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit(onSubmitForm)}
      noValidate
    >
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Controller
            name="name"
            control={control}
            rules={{
              required: 'Name is required',
              minLength: {
                value: 2,
                message: 'Name must be at least 2 characters',
              },
            }}
            render={({ field }) => (
              <TextField
                {...field}
                fullWidth
                label="Name"
                error={!!errors.name}
                helperText={errors.name?.message}
                autoFocus
              />
            )}
          />
        </Grid>

        <Grid item xs={12}>
          <Controller
            name="email"
            control={control}
            rules={{
              required: 'Email is required',
              pattern: {
                value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                message: 'Invalid email address',
              },
            }}
            render={({ field }) => (
              <TextField
                {...field}
                fullWidth
                label="Email"
                type="email"
                error={!!errors.email}
                helperText={errors.email?.message}
              />
            )}
          />
        </Grid>

        {!user && (
          <Grid item xs={12}>
            <Controller
              name="password"
              control={control}
              rules={{
                required: 'Password is required',
                minLength: {
                  value: 8,
                  message: 'Password must be at least 8 characters',
                },
                pattern: {
                  value: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
                  message: 'Password must contain uppercase, lowercase, and number',
                },
              }}
              render={({ field }) => (
                <TextField
                  {...field}
                  fullWidth
                  label="Password"
                  type="password"
                  error={!!errors.password}
                  helperText={errors.password?.message}
                />
              )}
            />
          </Grid>
        )}

        <Grid item xs={12}>
          <Controller
            name="role"
            control={control}
            rules={{ required: 'Role is required' }}
            render={({ field }) => (
              <FormControl fullWidth error={!!errors.role}>
                <InputLabel>Role</InputLabel>
                <Select {...field} label="Role">
                  {ROLES.map((role) => (
                    <MenuItem key={role.value} value={role.value}>
                      {role.label}
                    </MenuItem>
                  ))}
                </Select>
                {errors.role && (
                  <FormHelperText>{errors.role.message}</FormHelperText>
                )}
              </FormControl>
            )}
          />
        </Grid>

        <Grid item xs={12}>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
            <Button
              onClick={onCancel}
              disabled={loading}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="contained"
              disabled={loading}
            >
              {loading ? 'Saving...' : user ? 'Update' : 'Create'}
            </Button>
          </Box>
        </Grid>
      </Grid>
    </Box>
  );
}
```

### 4. Custom Hook for Data Fetching

```javascript
/**
 * useUsers - Custom hook for fetching and managing users
 * @param {Object} options - Hook options
 * @param {number} [options.page=1] - Page number
 * @param {string} [options.search=''] - Search term
 * @returns {Object} Users data and state
 * @returns {Array} return.users - Array of users
 * @returns {boolean} return.loading - Loading state
 * @returns {Error|null} return.error - Error object or null
 * @returns {Object} return.pagination - Pagination metadata
 * @returns {Function} return.refetch - Function to refetch data
 */
import { useState, useEffect, useCallback } from 'react';
import { fetchUsers } from '../api/users';

export function useUsers({ page = 1, search = '' } = {}) {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [pagination, setPagination] = useState({
    page: 1,
    pages: 1,
    total: 0,
  });

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetchUsers({ page, search });
      setUsers(response.data);
      setPagination(response.pagination);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [page, search]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return {
    users,
    loading,
    error,
    pagination,
    refetch: fetchData,
  };
}
```

### 5. Responsive Layout Component

```javascript
/**
 * AppLayout - Main application layout with responsive navigation
 * @param {Object} props - Component props
 * @param {React.ReactNode} props.children - Child components
 * @returns {JSX.Element} App layout component
 */
import { useState } from 'react';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material';
import { useNavigate, useLocation } from 'react-router-dom';

const DRAWER_WIDTH = 240;

const MENU_ITEMS = [
  { path: '/', label: 'Dashboard', icon: <DashboardIcon /> },
  { path: '/users', label: 'Users', icon: <PeopleIcon /> },
  { path: '/settings', label: 'Settings', icon: <SettingsIcon /> },
];

export default function AppLayout({ children }) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleNavigate = (path) => {
    navigate(path);
    if (isMobile) {
      setMobileOpen(false);
    }
  };

  const drawer = (
    <Box>
      <Toolbar>
        <Typography variant="h6" noWrap>
          My App
        </Typography>
      </Toolbar>
      <List>
        {MENU_ITEMS.map((item) => (
          <ListItem key={item.path} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => handleNavigate(item.path)}
            >
              <ListItemIcon>{item.icon}</ListItemIcon>
              <ListItemText primary={item.label} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${DRAWER_WIDTH}px)` },
          ml: { md: `${DRAWER_WIDTH}px` },
        }}
      >
        <Toolbar>
          {isMobile && (
            <IconButton
              color="inherit"
              edge="start"
              onClick={handleDrawerToggle}
              sx={{ mr: 2 }}
            >
              <MenuIcon />
            </IconButton>
          )}
          <Typography variant="h6" noWrap component="div">
            Dashboard
          </Typography>
        </Toolbar>
      </AppBar>

      <Box
        component="nav"
        sx={{ width: { md: DRAWER_WIDTH }, flexShrink: { md: 0 } }}
      >
        {/* Mobile drawer */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{ keepMounted: true }}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': { width: DRAWER_WIDTH },
          }}
        >
          {drawer}
        </Drawer>

        {/* Desktop drawer */}
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': { width: DRAWER_WIDTH },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${DRAWER_WIDTH}px)` },
          mt: 8,
        }}
      >
        {children}
      </Box>
    </Box>
  );
}
```

## Code Generation Checklist

When generating frontend code, ensure:

- [ ] JSDoc comments on all components and hooks
- [ ] Accessibility (ARIA labels, keyboard navigation, semantic HTML)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] MUI theme values used (no hardcoded colors/spacing)
- [ ] sx prop for styling (not inline styles)
- [ ] Loading states handled
- [ ] Error states handled
- [ ] Empty states handled
- [ ] Form validation with helpful error messages
- [ ] Performance optimization (memo, useMemo, useCallback)
- [ ] Prop validation (PropTypes or JSDoc)
- [ ] Tests for components (React Testing Library)
- [ ] No console.log in production code
- [ ] Consistent naming conventions

## Best Practices

1. **Component Composition**: Build small, reusable components
2. **Custom Hooks**: Extract reusable logic into hooks
3. **Theme Consistency**: Always use theme values
4. **Accessibility First**: ARIA labels, keyboard nav, semantic HTML
5. **Mobile First**: Design for mobile, enhance for desktop
6. **Error Handling**: Always handle loading, error, empty states
7. **Performance**: Memoize expensive operations, lazy load routes
8. **Testing**: Write tests alongside components

## Anti-Patterns to Avoid

❌ Inline styles instead of sx prop
❌ Hardcoded colors/spacing (use theme)
❌ Missing accessibility attributes
❌ No loading/error states
❌ Prop drilling (use Context or state management)
❌ Unnecessarily complex state
❌ Missing form validation
❌ Not responsive on mobile
❌ Performance issues (unnecessary re-renders)
❌ Mixing business logic in components (use hooks/services)