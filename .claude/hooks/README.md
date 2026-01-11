# Git Hooks for Code Quality

This directory contains git hooks that enforce code quality standards, test coverage, and documentation requirements.

## Available Hooks

### 1. pre-commit.sh
Runs before each commit to validate code quality and auto-generate documentation.

**Actions:**
- 📚 **Auto-generates documentation** from code (runs first)
  - API endpoints from Express routes
  - Component documentation from JSDoc
  - Module/utility documentation from JSDoc
  - Updates README.md with links

**Then checks:**
- ✓ ESLint validation (must pass)
- ✓ Test coverage (minimum 60% overall, 20% per file)
- ✓ JSDoc comments on functions
- ⚠️ console.log statements (warning)
- ⚠️ Documentation updates reminder

**Exit Codes:**
- `0` - All checks passed, commit proceeds with auto-generated docs
- `1` - Checks failed, commit blocked

### 2. commit-msg.sh
Runs after commit message is entered to ensure quality commit messages and remind about documentation.

**Checks:**
- ✓ Commit message length (minimum 10 characters)
- ⚠️ Generic commit messages (wip, test, fix, etc.)
- ⚠️ Documentation update reminder when code files changed

### 3. code-review-prompt.md
Predefined prompt for Claude Code to perform automated code reviews.

**Review Criteria:**
- Code quality and readability
- Security vulnerabilities
- Test coverage
- Documentation (JSDoc)
- React & MUI best practices
- Express/Node.js patterns
- Database query safety

Use with Claude Code's code review feature.

### 4. generate-docs.sh
Automatically generates documentation from your code (called by pre-commit hook).

**What it generates:**
- **docs/API.md** - API endpoints documentation from Express routes
  - Extracts routes (GET, POST, PUT, DELETE, etc.)
  - Includes JSDoc descriptions and parameters
  - Organized by route file

- **docs/COMPONENTS.md** - React component documentation
  - Component descriptions from JSDoc
  - Props documentation with types
  - Usage examples if present in JSDoc

- **docs/MODULES.md** - Utility functions and services
  - Function signatures and descriptions
  - Parameters and return types
  - Organized by module

- **README.md** - Automatically adds documentation links section

**Requirements for best results:**
- Add JSDoc comments to all functions
- Include @description, @param, @returns tags
- Use clear, descriptive route comments
- Document React component props

**Example JSDoc for API route:**
```javascript
/**
 * Retrieves user by ID
 * @param {string} req.params.id - User ID
 * @returns {Object} User object
 */
router.get('/users/:id', asyncHandler(async (req, res) => {
  // ... implementation
}));
```

**Example JSDoc for React component:**
```javascript
/**
 * Displays user profile information
 * @param {Object} props - Component props
 * @param {Object} props.user - User object
 * @param {string} props.user.name - User's full name
 * @param {string} props.user.email - User's email address
 * @param {Function} [props.onEdit] - Optional edit callback
 * @returns {JSX.Element} User profile component
 */
export function UserProfile({ user, onEdit }) {
  // ... implementation
}
```

## Auto-Documentation

The pre-commit hook automatically generates documentation from your code!

### How It Works

1. **Pre-commit triggers** - When you commit code changes
2. **Documentation generator runs** - Scans your codebase for:
   - Express routes in `routes/` or `src/server/routes/`
   - React components in `components/` or `src/components/`
   - Utility modules in `utils/`, `services/`, `helpers/`, or `lib/`
3. **Extracts JSDoc comments** - Parses your JSDoc annotations
4. **Generates markdown files** - Creates structured documentation in `docs/`
5. **Updates README** - Adds/updates documentation section with links
6. **Stages changes** - Automatically includes generated docs in your commit

### Generated Documentation Structure

```
docs/
├── API.md         # REST API endpoints
├── COMPONENTS.md  # React components
└── MODULES.md     # Utility functions
```

### What Gets Documented

**API Endpoints:**
- HTTP method and path
- Description from JSDoc
- Parameters (path, query, body)
- Response format
- Authentication requirements

**React Components:**
- Component purpose/description
- Props with types and descriptions
- Optional vs required props
- Usage examples

**Utility Functions:**
- Function signature
- Purpose/description
- Parameters with types
- Return values
- Error conditions

### Best Practices for Auto-Documentation

1. **Write JSDoc for all exported functions**
   ```javascript
   /**
    * Brief description
    * @param {type} name - Parameter description
    * @returns {type} Return value description
    * @throws {ErrorType} When error occurs
    */
   ```

2. **Document API routes clearly**
   ```javascript
   /**
    * @description Creates a new user account
    * @param {string} req.body.email - User email
    * @param {string} req.body.password - User password
    * @returns {Object} Created user object
    */
   ```

3. **Include prop descriptions for React components**
   ```javascript
   /**
    * UserCard component displays user information
    * @param {Object} props.user - User data object
    * @param {boolean} [props.compact] - Use compact layout
    */
   ```

4. **Add examples in JSDoc when helpful**
   ```javascript
   /**
    * Formats currency value
    * @param {number} amount - Amount to format
    * @returns {string} Formatted currency
    * @example
    * formatCurrency(1234.56) // Returns "$1,234.56"
    */
   ```

### Disabling Auto-Documentation

If you don't want automatic documentation generation:

```bash
# Edit .claude/hooks/pre-commit.sh
# Comment out the documentation generation section:

# # 0. Auto-generate documentation from code
# HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# if [ -f "$HOOKS_DIR/generate-docs.sh" ]; then
#     bash "$HOOKS_DIR/generate-docs.sh"
# fi
```

Or run commit with `--no-verify` to skip all hooks.

## Installation

### Option 1: Automatic Installation (Recommended)

Run the installation script from your project root:

```bash
bash .claude/hooks/install-hooks.sh
```

This will:
- Copy hooks to `.git/hooks/`
- Make them executable
- Configure them to run automatically

### Option 2: Manual Installation

```bash
# From project root
cp .claude/hooks/pre-commit.sh .git/hooks/pre-commit
cp .claude/hooks/commit-msg.sh .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
```

### Option 3: Using Husky (Recommended for Teams)

If you're using Husky for hook management:

```bash
# Install Husky
npm install --save-dev husky
npx husky install

# Add hooks
npx husky add .husky/pre-commit "bash .claude/hooks/pre-commit.sh"
npx husky add .husky/commit-msg "bash .claude/hooks/commit-msg.sh \$1"
```

## Required Package Scripts

Ensure your `package.json` has these scripts:

```json
{
  "scripts": {
    "lint": "eslint src --ext .js,.jsx",
    "test": "jest",
    "test:coverage": "jest --coverage --coverageReporters=text"
  }
}
```

## Coverage Configuration

Configure Jest coverage thresholds in `package.json` or `jest.config.js`:

```json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 60,
        "functions": 60,
        "lines": 60,
        "statements": 60
      }
    }
  }
}
```

## Bypassing Hooks

**Warning:** Only bypass hooks when absolutely necessary.

```bash
# Bypass all hooks
git commit --no-verify -m "Emergency hotfix"

# Or use shorthand
git commit -n -m "Emergency hotfix"
```

## Hook Behavior

### Pre-commit Hook Flow

```
┌─────────────────────────┐
│   Attempt Commit        │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   Run ESLint            │
│   ✓ Pass │ ✗ Fail       │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   Check console.log     │
│   (Warning Only)        │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   Run Tests + Coverage  │
│   ✓ ≥60% │ ✗ <60%      │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   Check JSDoc Comments  │
│   (Warning Only)        │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   Check Docs Updated    │
│   (Reminder Only)       │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│   ✓ Commit Proceeds     │
│   ✗ Commit Blocked      │
└─────────────────────────┘
```

### What Blocks Commits?

**Hard Failures (Commit Blocked):**
- ESLint errors
- Tests failing
- Coverage below 60% overall

**Warnings (Commit Proceeds):**
- Missing JSDoc comments
- console.log statements
- Low per-file coverage (below 20%)
- No documentation updates

## Code Review with Claude

To perform an automated code review before committing:

1. Stage your changes:
   ```bash
   git add .
   ```

2. Ask Claude Code to review:
   ```
   Review my staged changes using the code review checklist in .claude/hooks/code-review-prompt.md
   ```

3. Claude will analyze your changes against all criteria and provide feedback

4. Address any issues found

5. Commit when ready

## Customization

### Adjusting Coverage Thresholds

Edit `.claude/hooks/pre-commit.sh`:

```bash
# Change from 60 to your desired percentage
if [ "$COVERAGE_INT" -lt 60 ]; then
```

### Adding Custom Checks

Add your own checks to `pre-commit.sh`:

```bash
# Example: Check for TODO comments
echo "🔍 Checking for TODO comments..."
if git diff --cached | grep -E "TODO|FIXME"; then
    echo "⚠️  Found TODO/FIXME comments"
fi
```

### Disabling Specific Checks

Comment out sections in the hook scripts:

```bash
# # 2. Check for console.log statements (warning only)
# echo ""
# echo "🔍 Checking for console.log statements..."
# ...
```

## Troubleshooting

### Hook Not Running

```bash
# Verify hook is executable
ls -la .git/hooks/pre-commit

# If not executable, fix with:
chmod +x .git/hooks/pre-commit
```

### Coverage Check Failing

```bash
# Run coverage manually to see details
npm run test:coverage

# Check coverage report
open coverage/lcov-report/index.html
```

### ESLint Errors

```bash
# Run linting manually
npm run lint

# Auto-fix issues
npm run lint -- --fix
```

### Hook Running on Wrong Files

Hooks use `git diff --cached` to only check staged files. Make sure your changes are staged:

```bash
git add <files>
```

## Best Practices

1. **Run hooks locally** - Don't bypass hooks to "save time"
2. **Fix issues immediately** - Don't let lint/test errors accumulate
3. **Write tests as you code** - Maintain coverage as you develop
4. **Document as you go** - Add JSDoc when writing functions
5. **Review before committing** - Use Claude Code's review feature
6. **Keep commits focused** - Small, logical commits are easier to review

## Integration with CI/CD

These hooks complement CI/CD pipelines, not replace them:

**Local (Git Hooks):**
- Fast feedback loop
- Catch issues before push
- Save CI/CD resources

**CI/CD Pipeline:**
- Full test suite
- Cross-environment testing
- Security scanning
- Deployment automation

Both are important for code quality!

## Support

For issues or questions about these hooks:
1. Check this README
2. Review hook scripts for customization options
3. Consult project maintainers
4. Update hooks based on team needs

Remember: Hooks are tools to help maintain quality, not obstacles to productivity!