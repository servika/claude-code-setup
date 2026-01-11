---
pattern: "**/*.{jsx,tsx}"
---

# Material-UI (MUI) Component Guidelines

These rules apply to React components using Material-UI v5+.

## Theme Setup

**Configure Theme Provider**

```javascript
// theme.js - Create custom theme
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
      light: '#42a5f5',
      dark: '#1565c0',
      contrastText: '#fff',
    },
    secondary: {
      main: '#dc004e',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontSize: '2.5rem',
      fontWeight: 500,
    },
  },
  spacing: 8, // Base spacing unit (1 = 8px)
  breakpoints: {
    values: {
      xs: 0,
      sm: 600,
      md: 900,
      lg: 1200,
      xl: 1536,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none', // Remove uppercase transformation
        },
      },
      defaultProps: {
        disableElevation: true,
      },
    },
  },
});

// App.jsx - Apply theme
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from './theme';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline /> {/* Normalize CSS */}
      <YourApp />
    </ThemeProvider>
  );
}
```

**Dark Mode Support**

```javascript
import { useState, useMemo, createContext, useContext } from 'react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { CssBaseline } from '@mui/material';

const ColorModeContext = createContext({ toggleColorMode: () => {} });

export function ThemeProviderWrapper({ children }) {
  const [mode, setMode] = useState('light');

  const colorMode = useMemo(
    () => ({
      toggleColorMode: () => {
        setMode((prevMode) => (prevMode === 'light' ? 'dark' : 'light'));
      },
    }),
    []
  );

  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode,
          ...(mode === 'light'
            ? {
                // Light mode colors
                primary: { main: '#1976d2' },
                background: { default: '#f5f5f5', paper: '#ffffff' },
              }
            : {
                // Dark mode colors
                primary: { main: '#90caf9' },
                background: { default: '#121212', paper: '#1e1e1e' },
              }),
        },
      }),
    [mode]
  );

  return (
    <ColorModeContext.Provider value={colorMode}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </ThemeProvider>
    </ColorModeContext.Provider>
  );
}

export const useColorMode = () => useContext(ColorModeContext);

// Usage
function Header() {
  const { toggleColorMode } = useColorMode();
  return <IconButton onClick={toggleColorMode}>🌙</IconButton>;
}
```

## Styling with sx Prop

**Always Use sx Prop Over Inline Styles**

```javascript
import { Box, Typography } from '@mui/material';

// Good: Using sx prop with theme values
function Card({ title, children }) {
  return (
    <Box
      sx={{
        p: 3,                              // padding: theme.spacing(3)
        bgcolor: 'background.paper',        // Uses theme color
        borderRadius: 2,                    // 16px (2 * 8px)
        boxShadow: 1,                       // theme.shadows[1]
        '&:hover': {
          boxShadow: 3,
        },
      }}
    >
      <Typography variant="h5" sx={{ mb: 2, color: 'primary.main' }}>
        {title}
      </Typography>
      {children}
    </Box>
  );
}

// Bad: Inline styles with hardcoded values
function Card({ title, children }) {
  return (
    <div style={{ padding: '24px', backgroundColor: '#ffffff' }}> {/* ❌ */}
      <h5 style={{ marginBottom: '16px', color: '#1976d2' }}>{title}</h5>
      {children}
    </div>
  );
}
```

**Responsive Styling**

```javascript
import { Box } from '@mui/material';

function ResponsiveBox() {
  return (
    <Box
      sx={{
        // Responsive values using breakpoints
        width: {
          xs: '100%',     // 0-600px
          sm: '80%',      // 600-900px
          md: '60%',      // 900-1200px
          lg: '50%',      // 1200-1536px
          xl: '40%',      // 1536px+
        },
        p: { xs: 2, md: 4 },           // padding changes at md breakpoint
        flexDirection: { xs: 'column', md: 'row' },
      }}
    >
      Content
    </Box>
  );
}
```

**Common sx Shortcuts**

```javascript
// Spacing
sx={{
  m: 2,           // margin: 16px (all sides)
  mt: 2,          // marginTop: 16px
  mb: 2,          // marginBottom: 16px
  ml: 2,          // marginLeft: 16px
  mr: 2,          // marginRight: 16px
  mx: 2,          // marginLeft + marginRight: 16px
  my: 2,          // marginTop + marginBottom: 16px
  p: 3,           // padding: 24px (all sides)
  px: 3,          // paddingLeft + paddingRight: 24px
  py: 3,          // paddingTop + paddingBottom: 24px
}}

// Colors
sx={{
  color: 'primary.main',
  bgcolor: 'background.paper',
  borderColor: 'divider',
}}

// Typography
sx={{
  fontSize: 'h6.fontSize',    // Use theme typography
  fontWeight: 'bold',
  textAlign: 'center',
}}
```

## Grid Layout

**Use Grid2 (New Grid System)**

```javascript
import Grid from '@mui/material/Unstable_Grid2'; // Grid2

function Dashboard() {
  return (
    <Grid container spacing={3}>
      {/* 12 column on xs, 6 columns on md, 4 columns on lg */}
      <Grid xs={12} md={6} lg={4}>
        <StatCard title="Users" value={1234} />
      </Grid>
      <Grid xs={12} md={6} lg={4}>
        <StatCard title="Revenue" value="$50K" />
      </Grid>
      <Grid xs={12} md={6} lg={4}>
        <StatCard title="Orders" value={567} />
      </Grid>

      {/* Full width on xs, half width on md+ */}
      <Grid xs={12} md={6}>
        <RecentActivity />
      </Grid>
      <Grid xs={12} md={6}>
        <Charts />
      </Grid>
    </Grid>
  );
}
```

**Nested Grids**

```javascript
import Grid from '@mui/material/Unstable_Grid2';

function ProductLayout() {
  return (
    <Grid container spacing={2}>
      {/* Sidebar */}
      <Grid xs={12} md={3}>
        <Filters />
      </Grid>

      {/* Main content */}
      <Grid xs={12} md={9}>
        <Grid container spacing={2}>
          {products.map(product => (
            <Grid key={product.id} xs={12} sm={6} lg={4}>
              <ProductCard product={product} />
            </Grid>
          ))}
        </Grid>
      </Grid>
    </Grid>
  );
}
```

## Typography

**Use Typography Component**

```javascript
import { Typography } from '@mui/material';

function Article() {
  return (
    <div>
      <Typography variant="h1" component="h1" gutterBottom>
        Article Title
      </Typography>

      <Typography variant="subtitle1" color="text.secondary" gutterBottom>
        Published on January 9, 2026
      </Typography>

      <Typography variant="body1" paragraph>
        First paragraph of content with proper spacing.
      </Typography>

      <Typography variant="body1" paragraph>
        Second paragraph with consistent styling.
      </Typography>

      <Typography variant="caption" display="block" sx={{ mt: 2 }}>
        * Footnote or small text
      </Typography>
    </div>
  );
}
```

**Typography Variants**
- `h1` through `h6` - Headings
- `subtitle1`, `subtitle2` - Subheadings
- `body1`, `body2` - Body text (body1 is default)
- `button` - Button text
- `caption` - Small text
- `overline` - Overline text

## Buttons

**Button Variants and Usage**

```javascript
import { Button, IconButton, Fab } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';

function ButtonExamples() {
  return (
    <>
      {/* Primary actions */}
      <Button variant="contained" color="primary">
        Save
      </Button>

      {/* Secondary actions */}
      <Button variant="outlined" color="secondary">
        Cancel
      </Button>

      {/* Tertiary actions */}
      <Button variant="text">
        Learn More
      </Button>

      {/* With icons */}
      <Button
        variant="contained"
        startIcon={<DeleteIcon />}
        onClick={handleDelete}
      >
        Delete
      </Button>

      {/* Icon button */}
      <IconButton color="primary" aria-label="delete">
        <DeleteIcon />
      </IconButton>

      {/* Floating action button */}
      <Fab color="primary" aria-label="add">
        <AddIcon />
      </Fab>

      {/* Loading state */}
      <Button variant="contained" disabled={loading}>
        {loading ? 'Saving...' : 'Save'}
      </Button>
    </>
  );
}
```

## Forms with MUI

**TextField Component**

```javascript
import { TextField } from '@mui/material';
import { useForm, Controller } from 'react-hook-form';

function LoginForm() {
  const { control, handleSubmit, formState: { errors } } = useForm();

  const onSubmit = (data) => {
    console.log(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="email"
        control={control}
        defaultValue=""
        rules={{
          required: 'Email is required',
          pattern: {
            value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
            message: 'Invalid email address'
          }
        }}
        render={({ field }) => (
          <TextField
            {...field}
            label="Email"
            type="email"
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
        defaultValue=""
        rules={{ required: 'Password is required' }}
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
        sx={{ mt: 2 }}
      >
        Sign In
      </Button>
    </form>
  );
}
```

**Select, Checkbox, Radio**

```javascript
import {
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Checkbox,
  Radio,
  RadioGroup,
  FormLabel,
} from '@mui/material';

function FormControls() {
  const [role, setRole] = useState('');
  const [agreed, setAgreed] = useState(false);
  const [plan, setPlan] = useState('basic');

  return (
    <>
      {/* Select */}
      <FormControl fullWidth margin="normal">
        <InputLabel id="role-label">Role</InputLabel>
        <Select
          labelId="role-label"
          value={role}
          label="Role"
          onChange={(e) => setRole(e.target.value)}
        >
          <MenuItem value="admin">Admin</MenuItem>
          <MenuItem value="user">User</MenuItem>
          <MenuItem value="guest">Guest</MenuItem>
        </Select>
      </FormControl>

      {/* Checkbox */}
      <FormControlLabel
        control={
          <Checkbox
            checked={agreed}
            onChange={(e) => setAgreed(e.target.checked)}
          />
        }
        label="I agree to the terms and conditions"
      />

      {/* Radio group */}
      <FormControl>
        <FormLabel>Select Plan</FormLabel>
        <RadioGroup value={plan} onChange={(e) => setPlan(e.target.value)}>
          <FormControlLabel value="basic" control={<Radio />} label="Basic" />
          <FormControlLabel value="pro" control={<Radio />} label="Pro" />
          <FormControlLabel value="enterprise" control={<Radio />} label="Enterprise" />
        </RadioGroup>
      </FormControl>
    </>
  );
}
```

## Dialogs & Modals

**Dialog Component**

```javascript
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
} from '@mui/material';

function UserDialog({ open, onClose, onSave }) {
  const [name, setName] = useState('');

  const handleSave = () => {
    onSave({ name });
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>Add User</DialogTitle>
      <DialogContent>
        <TextField
          autoFocus
          margin="dense"
          label="Name"
          fullWidth
          variant="outlined"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button onClick={handleSave} variant="contained">
          Save
        </Button>
      </DialogActions>
    </Dialog>
  );
}

// Usage
function UserList() {
  const [dialogOpen, setDialogOpen] = useState(false);

  return (
    <>
      <Button onClick={() => setDialogOpen(true)}>Add User</Button>
      <UserDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        onSave={handleSave}
      />
    </>
  );
}
```

## Snackbars & Alerts

**Snackbar for Notifications**

```javascript
import { Snackbar, Alert } from '@mui/material';
import { useState } from 'react';

function App() {
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: '',
    severity: 'success'
  });

  const showSnackbar = (message, severity = 'success') => {
    setSnackbar({ open: true, message, severity });
  };

  const handleClose = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  return (
    <>
      <Button onClick={() => showSnackbar('Item saved!', 'success')}>
        Save
      </Button>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={handleClose}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert onClose={handleClose} severity={snackbar.severity}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </>
  );
}
```

## Tables

**Data Table with MUI**

```javascript
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';

function UserTable({ users, onEdit, onDelete }) {
  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Name</TableCell>
            <TableCell>Email</TableCell>
            <TableCell>Role</TableCell>
            <TableCell align="right">Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id} hover>
              <TableCell>{user.name}</TableCell>
              <TableCell>{user.email}</TableCell>
              <TableCell>{user.role}</TableCell>
              <TableCell align="right">
                <IconButton
                  size="small"
                  onClick={() => onEdit(user)}
                  aria-label="edit"
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => onDelete(user.id)}
                  aria-label="delete"
                >
                  <DeleteIcon />
                </IconButton>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}
```

## Icons

**Optimized Icon Usage**

```javascript
// Bad: Import all icons (large bundle)
import * as Icons from '@mui/icons-material';

// Good: Import only needed icons
import HomeIcon from '@mui/icons-material/Home';
import SettingsIcon from '@mui/icons-material/Settings';
import DeleteIcon from '@mui/icons-material/Delete';

// For dynamic icons, use lazy loading
const iconComponents = {
  Home: lazy(() => import('@mui/icons-material/Home')),
  Settings: lazy(() => import('@mui/icons-material/Settings')),
};

function DynamicIcon({ name }) {
  const IconComponent = iconComponents[name];
  return (
    <Suspense fallback={<span>...</span>}>
      <IconComponent />
    </Suspense>
  );
}
```

## Responsive Design

**useMediaQuery Hook**

```javascript
import { useMediaQuery, useTheme } from '@mui/material';

function ResponsiveComponent() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'md'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('md'));

  return (
    <Box>
      {isMobile && <MobileView />}
      {isTablet && <TabletView />}
      {isDesktop && <DesktopView />}
    </Box>
  );
}
```

## AppBar & Navigation

**Standard AppBar Pattern**

```javascript
import {
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Button,
  Drawer,
  List,
  ListItem,
  ListItemText,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import { useState } from 'react';

function Navigation() {
  const [drawerOpen, setDrawerOpen] = useState(false);

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            aria-label="menu"
            onClick={() => setDrawerOpen(true)}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>

          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            My App
          </Typography>

          {/* Desktop menu */}
          <Box sx={{ display: { xs: 'none', md: 'block' } }}>
            <Button color="inherit">Home</Button>
            <Button color="inherit">About</Button>
            <Button color="inherit">Contact</Button>
          </Box>
        </Toolbar>
      </AppBar>

      {/* Mobile drawer */}
      <Drawer
        anchor="left"
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
      >
        <List sx={{ width: 250 }}>
          <ListItem button onClick={() => setDrawerOpen(false)}>
            <ListItemText primary="Home" />
          </ListItem>
          <ListItem button onClick={() => setDrawerOpen(false)}>
            <ListItemText primary="About" />
          </ListItem>
          <ListItem button onClick={() => setDrawerOpen(false)}>
            <ListItemText primary="Contact" />
          </ListItem>
        </List>
      </Drawer>
    </>
  );
}
```

## Performance Tips

**Avoid Inline sx Objects**

```javascript
// Bad: Creates new object on every render
function Card() {
  return <Box sx={{ p: 2, bgcolor: 'white' }}>Content</Box>;
}

// Good: Use useMemo for complex sx
function Card() {
  const cardSx = useMemo(() => ({
    p: 2,
    bgcolor: 'white',
    '&:hover': { boxShadow: 3 }
  }), []);

  return <Box sx={cardSx}>Content</Box>;
}

// Better: For static styles, define outside component
const cardSx = { p: 2, bgcolor: 'white', '&:hover': { boxShadow: 3 } };

function Card() {
  return <Box sx={cardSx}>Content</Box>;
}
```

**Tree Shaking**

```javascript
// Good: Import from specific paths for better tree shaking
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';

// Acceptable: Named imports (requires proper bundler config)
import { Button, TextField } from '@mui/material';
```