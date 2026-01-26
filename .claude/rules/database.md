# Database Guidelines (PostgreSQL)

## Database Design Principles

- **Normalize first, denormalize for performance** - Start with 3NF, optimize later
- **Explicit constraints** - Enforce data integrity at the database level
- **Meaningful names** - Clear, consistent naming conventions
- **Document decisions** - Comment complex schemas and constraints

## Naming Conventions

### Tables

```sql
-- Use snake_case, plural nouns
CREATE TABLE users (...);
CREATE TABLE order_items (...);
CREATE TABLE user_preferences (...);

-- Bad: CamelCase, singular, abbreviations
CREATE TABLE User (...);
CREATE TABLE order_item (...);
CREATE TABLE usr_prefs (...);
```

### Columns

```sql
-- Primary keys: id (UUID preferred)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Foreign keys: {table_singular}_id
user_id UUID REFERENCES users(id)

-- Timestamps: created_at, updated_at, deleted_at
created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Booleans: is_{adjective} or has_{noun}
is_active BOOLEAN DEFAULT true
has_verified_email BOOLEAN DEFAULT false

-- Status columns: use descriptive name
status VARCHAR(20) CHECK (status IN ('pending', 'active', 'suspended'))
```

### Indexes

```sql
-- idx_{table}_{column(s)}
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at);

-- Unique indexes: uniq_{table}_{column(s)}
CREATE UNIQUE INDEX uniq_users_email ON users(email);
```

### Constraints

```sql
-- Primary key: pk_{table}
CONSTRAINT pk_users PRIMARY KEY (id)

-- Foreign key: fk_{table}_{referenced_table}
CONSTRAINT fk_orders_users FOREIGN KEY (user_id) REFERENCES users(id)

-- Unique: uniq_{table}_{column(s)}
CONSTRAINT uniq_users_email UNIQUE (email)

-- Check: chk_{table}_{description}
CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

## Schema Design Patterns

### Base Table Template

```sql
CREATE TABLE table_name (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Business columns
    ...

    -- Audit columns
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### Common Trigger Functions

```sql
-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### User Table Example

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uniq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('user', 'admin', 'moderator')),
    CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role) WHERE is_active = true;

CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### One-to-Many Relationship

```sql
-- Orders belong to users
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_orders_users FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT chk_orders_total_positive CHECK (total >= 0)
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
```

### Many-to-Many Relationship

```sql
-- Products can be in many orders, orders can have many products
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_products FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE RESTRICT,
    CONSTRAINT uniq_order_items_order_product UNIQUE (order_id, product_id),
    CONSTRAINT chk_order_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price_positive CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### Soft Delete Pattern

```sql
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    author_id UUID NOT NULL REFERENCES users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,  -- NULL = not deleted
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Partial index for active records
CREATE INDEX idx_posts_author_active ON posts(author_id)
    WHERE deleted_at IS NULL;

-- View for active records only
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;
```

## Migration Patterns

### Migration File Structure

```
migrations/
├── 001_create_users.sql
├── 002_create_products.sql
├── 003_create_orders.sql
├── 004_add_user_preferences.sql
└── 005_add_order_tracking.sql
```

### Migration File Template

```sql
-- Migration: 001_create_users
-- Description: Create users table with authentication fields
-- Author: developer@example.com
-- Date: 2024-01-15

-- Up Migration
BEGIN;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

COMMIT;

-- Down Migration (in separate file or section)
-- DROP TABLE IF EXISTS users;
```

### Adding Columns

```sql
-- Add column with default (safe)
ALTER TABLE users ADD COLUMN is_premium BOOLEAN NOT NULL DEFAULT false;

-- Add column without default (requires backfill)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
UPDATE users SET phone = '' WHERE phone IS NULL;
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

### Renaming Columns (Zero Downtime)

```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);

-- Step 2: Backfill data
UPDATE users SET full_name = name WHERE full_name IS NULL;

-- Step 3: Update application to write to both columns
-- (deploy application change)

-- Step 4: Make new column required
ALTER TABLE users ALTER COLUMN full_name SET NOT NULL;

-- Step 5: Update application to read from new column only
-- (deploy application change)

-- Step 6: Drop old column
ALTER TABLE users DROP COLUMN name;
```

### Index Creation (Non-Blocking)

```sql
-- Use CONCURRENTLY to avoid locking
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- Note: CONCURRENTLY cannot be used in a transaction block
```

## Query Best Practices

### Parameterized Queries (ALWAYS)

```javascript
// Good - Parameterized
const query = 'SELECT * FROM users WHERE email = $1';
const result = await pool.query(query, [email]);

// Bad - String concatenation (SQL INJECTION RISK)
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

### Efficient Pagination

```sql
-- Good - Keyset pagination (fast for large datasets)
SELECT * FROM orders
WHERE created_at < $1
ORDER BY created_at DESC
LIMIT 20;

-- Acceptable - Offset pagination (slow for large offsets)
SELECT * FROM orders
ORDER BY created_at DESC
LIMIT 20 OFFSET 100;
```

### Select Only Needed Columns

```javascript
// Good - Select specific columns
const query = 'SELECT id, name, email FROM users WHERE id = $1';

// Bad - Select all columns
const query = 'SELECT * FROM users WHERE id = $1';
```

### Use EXISTS for Existence Checks

```sql
-- Good - EXISTS (stops at first match)
SELECT EXISTS(SELECT 1 FROM users WHERE email = $1);

-- Bad - COUNT (scans all matches)
SELECT COUNT(*) > 0 FROM users WHERE email = $1;
```

### Batch Operations

```javascript
// Good - Single query for multiple inserts
const query = `
  INSERT INTO order_items (order_id, product_id, quantity, unit_price)
  VALUES
    ($1, $2, $3, $4),
    ($1, $5, $6, $7),
    ($1, $8, $9, $10)
`;

// Bad - Multiple separate queries
for (const item of items) {
  await pool.query('INSERT INTO order_items ...', [item]);
}
```

## Index Optimization

### When to Create Indexes

| Scenario | Index Type |
|----------|------------|
| Equality queries (WHERE x = y) | B-tree (default) |
| Range queries (WHERE x > y) | B-tree |
| Pattern matching (LIKE 'prefix%') | B-tree |
| Full-text search | GIN |
| JSON queries | GIN |
| Geospatial | GiST |

### Composite Index Order

```sql
-- Order matters: most selective first, equality before range
-- Query: WHERE status = 'active' AND created_at > '2024-01-01'
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

-- This index can be used for:
-- 1. WHERE status = 'active'
-- 2. WHERE status = 'active' AND created_at > '...'
-- But NOT for:
-- 3. WHERE created_at > '...' (alone)
```

### Partial Indexes

```sql
-- Index only active records
CREATE INDEX idx_users_email_active ON users(email)
    WHERE is_active = true;

-- Index only pending orders
CREATE INDEX idx_orders_pending ON orders(created_at)
    WHERE status = 'pending';
```

### Covering Indexes

```sql
-- Include columns to avoid table lookup
CREATE INDEX idx_users_email_covering ON users(email)
    INCLUDE (name, role);

-- Query can be satisfied entirely from index
SELECT name, role FROM users WHERE email = 'test@example.com';
```

## Connection Management

### Connection Pool Configuration

```javascript
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                    // Maximum connections
  idleTimeoutMillis: 30000,   // Close idle connections after 30s
  connectionTimeoutMillis: 2000, // Fail fast if can't connect
});

// Handle pool errors
pool.on('error', (err) => {
  logger.error('Unexpected pool error', err);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await pool.end();
});
```

### Transaction Handling

```javascript
/**
 * Executes function within a transaction
 * @param {Function} fn - Function receiving client
 * @returns {Promise<*>} Result of function
 */
async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Usage
const order = await withTransaction(async (client) => {
  const order = await client.query(
    'INSERT INTO orders (user_id, total) VALUES ($1, $2) RETURNING *',
    [userId, total]
  );

  await client.query(
    'INSERT INTO order_items (order_id, product_id, quantity) VALUES ($1, $2, $3)',
    [order.rows[0].id, productId, quantity]
  );

  return order.rows[0];
});
```

## Data Validation

### Database-Level Constraints

```sql
-- Email format
CONSTRAINT chk_users_email CHECK (
    email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
)

-- Positive numbers
CONSTRAINT chk_products_price CHECK (price > 0)
CONSTRAINT chk_order_items_quantity CHECK (quantity > 0)

-- Enum values
CONSTRAINT chk_orders_status CHECK (
    status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')
)

-- Date ranges
CONSTRAINT chk_events_dates CHECK (end_date > start_date)

-- Length constraints
CONSTRAINT chk_users_name_length CHECK (
    length(name) >= 2 AND length(name) <= 100
)
```

### Using Domains for Reusable Types

```sql
-- Create reusable email domain
CREATE DOMAIN email_address AS VARCHAR(255)
    CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Use in tables
CREATE TABLE users (
    email email_address NOT NULL UNIQUE
);

CREATE TABLE contacts (
    email email_address NOT NULL
);
```

## Backup and Recovery

### Backup Commands

```bash
# Full backup
pg_dump -h localhost -U postgres -d myapp -F c -f backup.dump

# Schema only
pg_dump -h localhost -U postgres -d myapp --schema-only -f schema.sql

# Data only
pg_dump -h localhost -U postgres -d myapp --data-only -f data.sql

# Specific tables
pg_dump -h localhost -U postgres -d myapp -t users -t orders -f partial.dump
```

### Restore Commands

```bash
# Restore from custom format
pg_restore -h localhost -U postgres -d myapp -c backup.dump

# Restore from SQL file
psql -h localhost -U postgres -d myapp -f backup.sql
```

## Checklist

### Schema Design

- [ ] Tables use snake_case, plural names
- [ ] Primary keys are UUIDs
- [ ] Foreign keys have appropriate ON DELETE action
- [ ] All columns have appropriate NOT NULL constraints
- [ ] Check constraints validate data integrity
- [ ] Timestamps (created_at, updated_at) on all tables
- [ ] Indexes on foreign keys
- [ ] Indexes on frequently queried columns

### Migrations

- [ ] Migration is reversible (down migration exists)
- [ ] No breaking changes without multi-step process
- [ ] Large data changes are batched
- [ ] Indexes created CONCURRENTLY
- [ ] Migration tested on production-size data

### Queries

- [ ] All queries use parameterized values
- [ ] SELECT specifies columns (no SELECT *)
- [ ] Pagination uses keyset for large datasets
- [ ] Batch operations for multiple inserts/updates
- [ ] Transactions wrap related operations
