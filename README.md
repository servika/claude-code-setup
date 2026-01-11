# Claude Code Configuration for Node.js/Express/React/MUI Projects

A comprehensive Claude Code configuration optimized for full-stack JavaScript development with Node.js, Express, React, and Material-UI.

## What's Included

This configuration provides intelligent coding assistance and best practices for:

- **Backend**: Node.js with Express.js REST APIs
- **Frontend**: React with Material-UI (MUI) components
- **Language**: Modern JavaScript (ES6+) with ESM modules
- **Testing**: Jest, React Testing Library with 60% coverage minimum
- **Security**: OWASP best practices, input validation, auth patterns
- **Code Quality**: ESLint, Prettier, JSDoc documentation, automated code review hooks
- **Git Hooks**: Pre-commit linting, coverage checks, documentation reminders

## Features

### Global Guidelines (CLAUDE.md)
- Senior full-stack engineer perspective
- Tech stack-specific patterns and anti-patterns
- Performance optimization strategies
- Security-first development approach
- Todo management and verification checklists

### Path-Scoped Rules

**nodejs.md** - Node.js Runtime Patterns
- ESM vs CommonJS guidance
- Environment variable handling
- Async/await best practices
- Error handling patterns
- Built-in module preferences

**express.md** - Express.js API Development
- Route → Controller → Service architecture
- Centralized error handling
- Authentication & authorization middleware
- Request validation patterns
- Rate limiting and security middleware

**react.md** - React Component Patterns
- Functional components with hooks
- Performance optimization (memo, useMemo, useCallback)
- Custom hooks for reusable logic
- State management strategies
- Code splitting and lazy loading

**mui.md** - Material-UI Best Practices
- Theme configuration and dark mode
- sx prop over inline styles
- Responsive design with Grid2
- Form handling with MUI components
- Accessibility patterns

**testing.md** - Testing Standards
- BDD-style (Given-When-Then) structure
- Mocking best practices
- React Testing Library patterns
- API testing with Supertest
- Coverage requirements

**package-json.md** - Package Configuration
- Essential fields and metadata
- Script organization
- Dependency management
- Workspace configuration (monorepos)

**security.md** - Security Best Practices
- Input validation and sanitization
- SQL/NoSQL injection prevention
- XSS protection
- Authentication and authorization
- Secrets management
- CORS and security headers

### Specialized Agents

**Library Analyzer** - Open Source Library Analysis
- Security and vulnerability assessment
- Maintenance status evaluation
- Bundle size impact analysis
- Alternative recommendations
- Migration guidance

**Backend Generator** - Express/Node.js Code Generation
- Full-stack API endpoint creation
- Route → Controller → Service architecture
- Authentication/authorization implementation
- Database models and queries
- Comprehensive error handling

**Frontend Generator** - React/MUI Code Generation
- Component creation with hooks
- Form implementation with validation
- Responsive layouts and navigation
- Custom hooks for data fetching
- Accessibility-first components

**Project Docs Generator** - Project Documentation
- README generation and updates
- Setup and installation guides
- Deployment documentation
- Contributing guidelines
- User-facing documentation

**Dev Docs Generator** - Development Documentation
- Coding standards and guidelines
- Testing documentation
- Debugging guides
- CI/CD process documentation
- Development workflow guides

**Architecture Docs Generator** - Architecture Documentation
- System architecture diagrams
- Data flow documentation
- Database schema documentation
- API architecture design
- Technical decision records (ADRs)

See `.claude/agents/README.md` for detailed agent documentation and usage examples.

## Installation

### Option 1: Direct Copy (Recommended for Single Project)

Copy the `.claude` directory to your project root:

```bash
# Clone or download this repository
git clone https://github.com/servika/claude-code-setup.git

# Copy the .claude directory to your project
cp -r claude-code-setup/.claude /path/to/your/project/

# Verify installation
ls -la /path/to/your/project/.claude
```

### Option 2: Global Installation

Install globally for use across all projects:

```bash
# Clone to your home directory
git clone https://github.com/servika/claude-code-setup.git ~/.claude-config

# Create symlink in your project
cd /path/to/your/project
ln -s ~/.claude-config/.claude .claude

# Or copy for independent configuration
cp -r ~/.claude-config/.claude .
```

### Option 3: Git Submodule (For Team Projects)

Add as a submodule to version control with your team:

```bash
cd /path/to/your/project

# Add as submodule
git submodule add https://github.com/servika/claude-code-setup.git .claude-config

# Create symlink or copy
ln -s .claude-config/.claude .claude

# Commit the submodule
git add .gitmodules .claude-config
git commit -m "Add Claude Code configuration"
```

Team members can initialize with:
```bash
git submodule update --init --recursive
```

## Git Hooks Installation

After copying the `.claude` directory, install the git hooks:

```bash
cd /path/to/your/project

# Run the installation script
bash .claude/hooks/install-hooks.sh
```

This installs hooks that will:
- **pre-commit**:
  - 📚 **Auto-generate documentation** from JSDoc comments
  - ✓ Run ESLint (must pass)
  - ✓ Check test coverage (60% min)
  - ⚠️ Validate JSDoc comments
- **commit-msg**: Remind about documentation updates, validate commit message quality

### What Gets Auto-Generated

Every commit automatically creates/updates:
- `docs/API.md` - API endpoints from Express routes
- `docs/COMPONENTS.md` - React components from JSDoc
- `docs/MODULES.md` - Utility functions from JSDoc
- `README.md` - Documentation section with links

**No manual documentation updates needed!** Just write JSDoc comments and the hooks handle the rest.

See `.claude/hooks/README.md` for detailed hook documentation.

## Usage

Once installed, Claude Code will automatically apply these rules when working in your project.

### Understanding Rule Scopes

Rules are applied based on file patterns:

- **nodejs.md**: `**/*.{js,mjs,cjs}`
- **express.md**: `{routes,controllers,middleware,app,server}/**/*.{js}`
- **react.md**: `**/*.{jsx}`
- **mui.md**: `**/*.{jsx}`
- **testing.md**: `**/*.{test,spec}.{js,jsx}`
- **package-json.md**: `**/package.json`
- **security.md**: `**/*.{js,jsx}`

### Customization

You can customize rules for your specific needs:

1. **Edit existing rules**: Modify files in `.claude/rules/`
2. **Add new rules**: Create new `.md` files with frontmatter:
   ```markdown
   ---
   pattern: "**/*.your-pattern"
   ---

   # Your Custom Rules
   ```
3. **Override global settings**: Edit `.claude/CLAUDE.md`

### Example Project Structure

```
your-project/
├── .claude/                  # Claude Code configuration
│   ├── CLAUDE.md            # Global instructions
│   ├── rules/               # Path-scoped rules
│   │   ├── nodejs.md
│   │   ├── express.md
│   │   ├── react.md
│   │   ├── mui.md
│   │   ├── testing.md
│   │   ├── package-json.md
│   │   └── security.md
│   ├── agents/              # Specialized agents
│   │   ├── library-analyzer.md
│   │   ├── backend-generator.md
│   │   ├── frontend-generator.md
│   │   ├── project-docs-generator.md
│   │   ├── dev-docs-generator.md
│   │   ├── architecture-docs-generator.md
│   │   └── README.md
│   └── hooks/               # Git hooks
│       ├── pre-commit.sh
│       ├── commit-msg.sh
│       ├── generate-docs.sh
│       ├── install-hooks.sh
│       └── README.md
├── src/
│   ├── server/              # Express backend
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── services/
│   │   └── server.js
│   └── client/              # React frontend
│       ├── components/
│       ├── pages/
│       ├── hooks/
│       └── App.tsx
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
└── tsconfig.json
```

## What Claude Code Will Do

When working with these configurations, Claude Code will:

### Code Generation
- Generate production-ready, type-safe code
- Follow established patterns in your codebase
- Implement proper error handling and validation
- Apply security best practices by default
- Write tests alongside new features

### Code Review
- Catch security vulnerabilities (SQL injection, XSS, etc.)
- Identify performance anti-patterns
- Suggest better TypeScript types
- Flag accessibility issues in React components
- Recommend architectural improvements

### Refactoring
- Modernize code to current best practices
- Extract reusable logic into custom hooks
- Improve type safety and remove `any` types
- Optimize React component rendering
- Implement proper separation of concerns

## Best Practices Enforced

### Code Quality & Documentation
- JSDoc comments on all functions with @param, @returns, @throws
- ESLint validation with no errors
- Self-documenting code with clear naming
- Proper null/undefined handling
- Modern JavaScript (ES6+) patterns

### Security
- Input validation at API boundaries
- Parameterized database queries
- Password hashing with bcrypt
- JWT best practices
- Rate limiting on auth endpoints
- CORS and CSP configuration

### Performance
- React.memo for expensive components
- useMemo/useCallback where appropriate
- Code splitting with React.lazy()
- Database query optimization
- Proper caching strategies

### Testing
- BDD-style test organization
- Comprehensive coverage (happy path, errors, edge cases)
- Proper mocking of external dependencies
- Accessibility testing for components
- API integration tests

### Code Quality
- Self-documenting code (minimal comments)
- Single responsibility principle
- DRY (Don't Repeat Yourself)
- Consistent naming conventions
- Clean architecture patterns

## Verification Checklist

Before marking any task complete, Claude Code will verify:

- ✓ ESLint passes with no errors
- ✓ JSDoc comments on all functions
- ✓ Test coverage ≥60% overall, ≥20% per file
- ✓ Tests pass
- ✓ Build succeeds
- ✓ No security vulnerabilities introduced
- ✓ MUI patterns followed (theme values, sx prop)
- ✓ Error handling implemented
- ✓ Documentation updated
- ✓ No console errors or warnings
- ✓ Git hooks pass

## Tech Stack Compatibility

### Backend
- Node.js 18+
- Express.js 4.x
- Modern JavaScript (ES6+)
- PostgreSQL, MongoDB, or other databases
- Jest for testing

### Frontend
- React 18+
- Material-UI (MUI) 5.x
- React Router 6.x
- React Hook Form
- React Query/SWR for data fetching
- Vite or Create React App

### Development Tools
- ESLint
- Prettier
- Husky (git hooks)
- Jest/Vitest
- JSDoc for documentation

## Examples

### Creating a New API Endpoint

Claude Code will:
1. Create the route with proper validation
2. Implement controller with error handling
3. Add service layer for business logic
4. Write integration tests
5. Verify security (auth, rate limiting, input validation)

### Building a React Component

Claude Code will:
1. Use functional component with TypeScript
2. Integrate MUI components with theme
3. Implement proper props typing
4. Add accessibility attributes
5. Write component tests with React Testing Library
6. Optimize with memo/useMemo as needed

### Adding Authentication

Claude Code will:
1. Implement secure password hashing
2. Generate JWT tokens with proper config
3. Create auth middleware
4. Add rate limiting to auth routes
5. Implement frontend auth context
6. Write auth flow tests

## Troubleshooting

### Rules Not Applying

Check that:
1. `.claude` directory is in your project root
2. Rule patterns match your file paths
3. Restart Claude Code to reload configuration

### Conflicting Rules

If rules conflict:
1. More specific patterns take precedence
2. Edit `.claude/CLAUDE.md` for global overrides
3. Disable specific rules by renaming (e.g., `express.md.disabled`)

### Custom Project Structure

If your project structure differs:
1. Update `pattern:` in rule frontmatter
2. Create custom rules for your specific needs
3. Share feedback to improve default configuration

## Contributing

Improvements and customizations are welcome! This configuration is meant to be adapted to your team's needs.

## License

MIT License - feel free to use and modify for your projects.

---

**Happy coding with Claude Code!** 🚀

For questions or issues, refer to the [Claude Code documentation](https://docs.anthropic.com/claude/docs).