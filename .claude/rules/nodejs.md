---
pattern: "**/*.{js,mjs,cjs,ts}"
---

# Node.js Runtime & Core Patterns

These rules apply to all Node.js JavaScript and TypeScript files.

## Module System

**Prefer ESM (ES Modules)**
- Use `import`/`export` syntax for new code
- Set `"type": "module"` in package.json for ESM projects
- Use `.mjs` extension for ESM in CommonJS projects
- Use `.cjs` extension for CommonJS in ESM projects
- Only use CommonJS (`require`/`module.exports`) when necessary for compatibility

```javascript
// Good: ESM
import { readFile } from 'fs/promises';
import express from 'express';
export { app };

// Acceptable: CommonJS when required
const express = require('express');
module.exports = { app };
```

**Top-Level Await**
- Use top-level await in ESM modules when needed
- Keep initialization code clean and sequential

```javascript
// Good: Clean initialization
import { connectDB } from './db.js';
await connectDB();
await loadConfig();
```

## Built-in Node.js Modules

**Prefer Built-ins Over Third-Party**
- Use `fs/promises` for file operations (async by default)
- Use `path` for path manipulation
- Use `crypto` for cryptographic operations
- Use `url` and `querystring` for URL handling
- Use `http`/`https` for simple requests (or `fetch` in Node 18+)

```javascript
// Good: Using built-in modules
import { readFile, writeFile } from 'fs/promises';
import { join, resolve } from 'path';
import { createHash } from 'crypto';

// Good: Node 18+ native fetch
const response = await fetch('https://api.example.com');
const data = await response.json();
```

## Environment Variables

**Configuration via Environment**
- Access via `process.env.VARIABLE_NAME`
- Validate required variables at startup
- Provide defaults for optional variables
- Never commit `.env` files to version control
- Use `.env.example` for documentation

```javascript
// Good: Environment variable handling
const PORT = process.env.PORT || 3000;
const DB_URL = process.env.DATABASE_URL;

if (!DB_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

// Better: Validation helper
function getRequiredEnv(key) {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Required environment variable ${key} is not set`);
  }
  return value;
}

const DB_URL = getRequiredEnv('DATABASE_URL');
```

**Environment-Specific Behavior**
```javascript
const isDevelopment = process.env.NODE_ENV === 'development';
const isProduction = process.env.NODE_ENV === 'production';
const isTest = process.env.NODE_ENV === 'test';

// Use for conditional logic
if (isDevelopment) {
  app.use(morgan('dev'));
}
```

## Error Handling

**Async Error Handling**
- Always use try/catch with async/await
- Handle promise rejections explicitly
- Use error classes for different error types
- Include relevant context in errors

```javascript
// Good: Proper async error handling
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }
    return await response.json();
  } catch (error) {
    logger.error('User fetch failed', { id, error: error.message });
    throw new UserFetchError(`Could not retrieve user ${id}`, { cause: error });
  }
}
```

**Custom Error Classes**
```javascript
// Good: Specific error types
class DatabaseError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = 'DatabaseError';
    this.code = options.code || 'DB_ERROR';
    this.statusCode = 500;
  }
}

class ValidationError extends Error {
  constructor(message, fields = {}) {
    super(message);
    this.name = 'ValidationError';
    this.fields = fields;
    this.statusCode = 400;
  }
}

// Usage
throw new ValidationError('Invalid input', { email: 'Invalid email format' });
```

**Process-Level Error Handlers**
```javascript
// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1); // Exit after logging
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  await cleanup();
  process.exit(0);
});
```

## Package Management

**Lock Files**
- Always commit lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- Lock files ensure consistent installs across environments
- Update lock files deliberately, not accidentally

**Dependency Classification**
- `dependencies`: Required at runtime
- `devDependencies`: Only needed for development (test runners, build tools, linters)
- `peerDependencies`: Should be provided by the consumer
- Use exact versions (`1.2.3`) for critical production dependencies
- Use caret (`^1.2.3`) or tilde (`~1.2.3`) for flexible updates

```json
{
  "dependencies": {
    "express": "^4.18.0",
    "pg": "8.11.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0"
  }
}
```

**Security Audits**
- Run `npm audit` regularly
- Fix vulnerabilities promptly
- Use `npm audit fix` for automatic updates
- Review breaking changes before major updates

## Logging

**Use Proper Logging Libraries**
- Use structured logging (winston, pino, bunyan)
- Never use `console.log` in production code
- Log at appropriate levels (error, warn, info, debug)
- Include context and metadata

```javascript
// Good: Structured logging
import logger from './logger.js';

logger.info('User logged in', { userId: user.id, ip: req.ip });
logger.error('Database connection failed', { error: err.message, retries: 3 });

// Bad: Console logging in production
console.log('User logged in:', user.id); // Don't do this
```

**Log Levels**
- `error`: Errors that need immediate attention
- `warn`: Warning messages, potential issues
- `info`: General informational messages (user actions, system events)
- `debug`: Detailed debug information (development only)

## Performance

**Async Operations**
- Use Promise.all() for concurrent independent operations
- Don't await in loops unless sequential execution is required

```javascript
// Good: Parallel execution
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// Bad: Sequential when parallel would work
const users = await fetchUsers();
const posts = await fetchPosts();
const comments = await fetchComments();
```

**Stream Large Data**
- Use streams for large files and data processing
- Avoid loading entire files into memory

```javascript
// Good: Streaming large file
import { createReadStream } from 'fs';
import { pipeline } from 'stream/promises';

await pipeline(
  createReadStream('large-file.txt'),
  transformStream,
  writeStream
);
```

**Caching**
- Cache expensive operations in memory
- Use Redis for distributed caching
- Implement cache invalidation strategy

## Path Handling

**Use path Module**
- Always use `path.join()` or `path.resolve()` for cross-platform compatibility
- Never manually concatenate paths with `/` or `\\`

```javascript
import { join, resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

// ESM: Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Good: Cross-platform path construction
const configPath = join(__dirname, 'config', 'default.json');
const absolutePath = resolve(process.cwd(), 'uploads', filename);

// Bad: Manual path construction
const configPath = __dirname + '/config/default.json'; // Don't do this
```

## Security

**Input Validation**
- Validate all external inputs (user data, API responses, files)
- Sanitize inputs to prevent injection attacks
- Use validation libraries (Zod, Joi, validator.js)

**Sensitive Data**
- Never log passwords, tokens, or sensitive data
- Redact sensitive fields in logs
- Use environment variables for secrets
- Don't commit secrets to version control

```javascript
// Good: Redact sensitive data in logs
function sanitizeUserForLogging(user) {
  const { password, ssn, ...safeUser } = user;
  return safeUser;
}

logger.info('User created', sanitizeUserForLogging(user));
```

## File System Operations

**Prefer Async Operations**
- Use `fs/promises` for async file operations
- Never use sync operations (`readFileSync`, `writeFileSync`) in request handlers
- Sync operations are acceptable in startup/initialization code

```javascript
// Good: Async file operations
import { readFile, writeFile, access } from 'fs/promises';

async function loadConfig() {
  try {
    const data = await readFile('config.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    if (error.code === 'ENOENT') {
      return defaultConfig;
    }
    throw error;
  }
}

// Acceptable: Sync in startup code (before server starts)
import { readFileSync } from 'fs';
const config = JSON.parse(readFileSync('config.json', 'utf8'));
```

## Process Management

**Graceful Shutdown**
- Listen for SIGTERM and SIGINT signals
- Close server and database connections
- Finish processing in-flight requests
- Exit with appropriate code

```javascript
let server;

async function startServer() {
  server = app.listen(PORT, () => {
    logger.info(`Server running on port ${PORT}`);
  });
}

async function shutdown() {
  logger.info('Shutting down gracefully...');

  // Stop accepting new connections
  server.close(() => {
    logger.info('Server closed');
  });

  // Close database connections
  await db.close();

  // Exit after cleanup
  process.exit(0);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
```

## Testing Considerations

**Environment Separation**
- Use `NODE_ENV=test` for test environment
- Mock external dependencies in tests
- Clean up resources after tests
- Use separate test database

```javascript
// Good: Environment-aware configuration
const config = {
  db: process.env.NODE_ENV === 'test'
    ? 'postgresql://localhost/myapp_test'
    : process.env.DATABASE_URL
};
```