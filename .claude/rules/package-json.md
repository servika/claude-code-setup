---
pattern: "**/package.json"
---

# package.json Configuration Guidelines

These rules apply to all package.json files in the project.

## Essential Fields

**Required Metadata**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "description": "Brief description of what this package does",
  "author": "Your Name <email@example.com>",
  "license": "MIT",
  "private": true,
  "type": "module"
}
```

**Field Guidelines**
- `name`: Use kebab-case, all lowercase
- `version`: Follow semantic versioning (major.minor.patch)
- `description`: One-line summary (used by npm search)
- `private: true`: Prevent accidental publishing of application code
- `type: "module"`: Enable ESM (import/export) by default

## Engine Requirements

**Specify Node.js Version**

```json
{
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

This prevents issues with incompatible Node.js versions and documents requirements.

## Entry Points

**Main and Module Fields**

```json
{
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./utils": {
      "import": "./dist/utils.mjs",
      "require": "./dist/utils.js"
    }
  }
}
```

- `main`: CommonJS entry point
- `module`: ESM entry point
- `types`: TypeScript definitions
- `exports`: Modern way to define entry points (supports conditional exports)

## Scripts Organization

**Standard Script Names**

```json
{
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node dist/server.js",
    "build": "tsc",
    "build:watch": "tsc --watch",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src --ext .js,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{js,ts,tsx,json,md}\"",
    "format:check": "prettier --check \"src/**/*.{js,ts,tsx,json,md}\"",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage",
    "prepare": "husky install"
  }
}
```

**Script Naming Conventions**
- `dev`: Development server with hot reload
- `start`: Production server
- `build`: Compile/bundle for production
- `test`: Run test suite
- `lint`: Check code quality
- `format`: Format code
- `type-check`: TypeScript checking without emitting files
- `clean`: Remove build artifacts

**Script Composition**

```json
{
  "scripts": {
    "clean": "rm -rf dist",
    "build": "npm run clean && tsc",
    "prebuild": "npm run clean",
    "postbuild": "npm run type-check",
    "ci": "npm run lint && npm run type-check && npm run test && npm run build"
  }
}
```

## Dependencies Management

**Separate Dependencies by Purpose**

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "react": "^18.2.0",
    "@mui/material": "^5.14.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.8.0",
    "@types/react": "^18.2.0",
    "typescript": "^5.2.0",
    "jest": "^29.7.0",
    "@testing-library/react": "^14.0.0",
    "eslint": "^8.50.0",
    "prettier": "^3.0.0",
    "nodemon": "^3.0.0",
    "husky": "^8.0.0"
  },
  "peerDependencies": {
    "react": ">=17.0.0",
    "react-dom": ">=17.0.0"
  }
}
```

**Dependency Types**
- `dependencies`: Required at runtime
- `devDependencies`: Only needed for development (testing, building, linting)
- `peerDependencies`: Should be provided by the consumer (for libraries)

**Version Ranges**
```json
{
  "dependencies": {
    "critical-lib": "1.2.3",        // Exact version (for critical dependencies)
    "express": "^4.18.0",           // Compatible updates (4.x.x)
    "lodash": "~4.17.21",           // Patch updates only (4.17.x)
    "@mui/material": ">=5.0.0 <6.0.0"  // Range
  }
}
```

- Exact (`1.2.3`): Use for critical dependencies where changes could break functionality
- Caret (`^1.2.3`): Allow minor and patch updates (most common)
- Tilde (`~1.2.3`): Allow patch updates only
- Range: Specify custom range

## Repository & Bugs

**Link to Source Code**

```json
{
  "repository": {
    "type": "git",
    "url": "https://github.com/username/repo.git"
  },
  "bugs": {
    "url": "https://github.com/username/repo/issues"
  },
  "homepage": "https://github.com/username/repo#readme"
}
```

## File Inclusions

**Control Published Files**

```json
{
  "files": [
    "dist",
    "README.md",
    "LICENSE"
  ]
}
```

Only these files/directories will be published to npm (for libraries).

## Browser and Node.js Fields

**Environment-Specific Entry Points**

```json
{
  "main": "./dist/index.js",
  "browser": "./dist/browser.js",
  "react-native": "./dist/native.js"
}
```

## TypeScript Configuration

**TypeScript-Specific Fields**

```json
{
  "types": "./dist/index.d.ts",
  "typings": "./dist/index.d.ts",
  "typescript": {
    "definition": "./dist/index.d.ts"
  }
}
```

## Workspaces (Monorepo)

**Workspace Configuration**

```json
{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "packages/*",
    "apps/*"
  ]
}
```

## ESLint & Prettier Configuration

**Tool Configuration in package.json**

```json
{
  "eslintConfig": {
    "extends": ["react-app", "react-app/jest"]
  },
  "prettier": {
    "semi": true,
    "singleQuote": true,
    "printWidth": 100,
    "tabWidth": 2
  }
}
```

Better: Use separate config files (`.eslintrc.js`, `.prettierrc.json`) for complex configurations.

## Jest Configuration

**Test Configuration**

```json
{
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "coverageDirectory": "coverage",
    "collectCoverageFrom": [
      "src/**/*.{js,ts}",
      "!src/**/*.test.{js,ts}",
      "!src/**/*.spec.{js,ts}"
    ],
    "testMatch": [
      "**/__tests__/**/*.[jt]s?(x)",
      "**/?(*.)+(spec|test).[jt]s?(x)"
    ]
  }
}
```

Better: Use `jest.config.js` for complex configurations.

## Complete Example

**Full-Featured package.json**

```json
{
  "name": "my-fullstack-app",
  "version": "1.0.0",
  "description": "A full-stack application with Node.js, Express, React, and MUI",
  "author": "Your Name <email@example.com>",
  "license": "MIT",
  "private": true,
  "type": "module",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "scripts": {
    "dev": "concurrently \"npm run dev:server\" \"npm run dev:client\"",
    "dev:server": "nodemon --exec node src/server/index.js",
    "dev:client": "vite",
    "start": "node dist/server/index.js",
    "build": "npm run build:client && npm run build:server",
    "build:client": "vite build",
    "build:server": "tsc -p tsconfig.server.json",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src --ext .js,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{js,ts,tsx,json,md}\"",
    "format:check": "prettier --check \"src/**/*.{js,ts,tsx,json,md}\"",
    "type-check": "tsc --noEmit",
    "prepare": "husky install"
  },
  "dependencies": {
    "express": "^4.18.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@mui/material": "^5.14.0",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "react-router-dom": "^6.16.0",
    "axios": "^1.5.0",
    "zod": "^3.22.0",
    "dotenv": "^16.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.8.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@types/express": "^4.17.0",
    "typescript": "^5.2.0",
    "vite": "^4.5.0",
    "@vitejs/plugin-react": "^4.1.0",
    "jest": "^29.7.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.1.0",
    "@testing-library/user-event": "^14.5.0",
    "eslint": "^8.50.0",
    "eslint-config-prettier": "^9.0.0",
    "prettier": "^3.0.0",
    "nodemon": "^3.0.0",
    "concurrently": "^8.2.0",
    "husky": "^8.0.0",
    "lint-staged": "^14.0.0"
  },
  "lint-staged": {
    "*.{js,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

## Security Best Practices

**Lock Files**
- Always commit `package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml`
- Use `npm ci` in CI/CD instead of `npm install` for reproducible builds

**Audit Dependencies**

```json
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix"
  }
}
```

Run regularly and address vulnerabilities.

**Avoid Unnecessary Packages**
- Review dependencies periodically
- Remove unused packages
- Prefer smaller, focused packages
- Check bundle size impact

## Best Practices Summary

✓ Set `private: true` for applications
✓ Specify Node.js version in `engines`
✓ Use semantic versioning
✓ Separate dependencies by purpose (dependencies vs devDependencies)
✓ Use standard script names (dev, build, test, lint)
✓ Commit lock files
✓ Run security audits regularly
✓ Use `type: "module"` for ESM projects
✓ Document scripts with comments if needed
✗ Don't publish application code to npm
✗ Don't use wildcard version ranges (`*`) in production
✗ Don't commit `.env` files (add to .gitignore)