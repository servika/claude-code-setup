# Security Best Practices

Stack baseline: Node 24 LTS, TypeScript 7, Express 5.2, React 19.3 + MUI v9, PostgreSQL 18, Zod 4.6.
All examples are TypeScript. Where a JavaScript (ESM + JSDoc) project differs meaningfully, a short
note is added.

## OWASP Top 10:2025 Prevention

The 2025 (8th) installment reshuffled the list: SSRF is folded into Broken Access Control, and two
new categories appear - **Software Supply Chain Failures** and **Mishandling of Exceptional
Conditions**.

| #       | Category                                        | Prevention in this stack                                                                                                                                                                                                                                                                                                                                                                                |
| ------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A01** | Broken Access Control (SSRF folded in)          | Deny by default; authorize on the **server** for every route, including nested/sub-resources. Ownership checks against the DB row, never a client-supplied `userId`. Row-level security in PostgreSQL for multi-tenant data. For SSRF: allowlist outbound hosts, resolve DNS and reject private/link-local ranges, disable redirects on server-side fetches, no user-controlled URLs passed to `fetch`. |
| **A02** | Security Misconfiguration                       | `helmet()` with an explicit CSP (nonce-based, no `unsafe-inline`), Permissions-Policy, COOP/CORP, HSTS preload. Zod-validated env at startup - the process refuses to boot on a bad config. No stack traces or framework banners in responses (`app.disable('x-powered-by')`). Separate configs per environment; production defaults are the strict ones.                                               |
| **A03** | **Software Supply Chain Failures (NEW)**        | Committed lockfile, `npm ci`, `--ignore-scripts`, `osv-scanner` + `npm audit` in CI, Dependabot/Renovate, CI actions pinned to full commit SHAs, SBOM + provenance attestation on every build. See the dedicated section below.                                                                                                                                                                         |
| **A04** | Cryptographic Failures                          | TLS 1.3 everywhere, HSTS preload. `node:crypto` primitives only - never hand-rolled crypto. `crypto.randomUUID()` / `randomBytes` for tokens, never `Math.random()`. AES-256-GCM for data at rest; keys from a KMS/secret manager, rotated. `crypto.timingSafeEqual` for secret comparison. Column-level encryption for PII; PostgreSQL TDE/disk encryption for the rest.                               |
| **A05** | Injection                                       | Parameterized SQL only (`pg` placeholders, Drizzle/Kysely, Prisma). Zod at every boundary. No `eval`, `new Function`, or shell string interpolation - use `execFile` with an argument array. Escape/parameterize for every interpreter you touch (SQL, LDAP, shell, template engines). React escapes by default; `dangerouslySetInnerHTML` only with DOMPurify.                                         |
| **A06** | Insecure Design                                 | Threat model before building auth, payments, or multi-tenancy. Abuse cases in the ticket alongside user stories. Rate limits and quotas designed in, not bolted on. Least privilege for service accounts and DB roles. Secure defaults: new endpoints require auth unless explicitly opted out.                                                                                                         |
| **A07** | Authentication Failures                         | argon2id password hashing, generic "invalid credentials" responses, per-account and per-IP throttling with progressive backoff, MFA/passkeys for privileged accounts, session fixation prevention (rotate session id on login), short access tokens + rotating refresh tokens, breached-password checks on registration.                                                                                |
| **A08** | Software or Data Integrity Failures             | Verify artifact attestations before deploy (`gh attestation verify`), Sigstore/cosign keyless image signing, `actions/attest-build-provenance` in CI. No unsigned auto-update channels. Never deserialize untrusted data into live objects - parse via Zod into plain data. Signed, versioned webhooks with replay protection (timestamp + HMAC).                                                       |
| **A09** | Security Logging & Alerting Failures            | pino structured JSON with `redact` paths, correlation via `traceparent`/request id, OpenTelemetry export. **Alerting**, not just logging - see the A09 section for what must page a human. Logs immutable and shipped off-host; retention meets the compliance window.                                                                                                                                  |
| **A10** | **Mishandling of Exceptional Conditions (NEW)** | Fail closed, not open. Typed error taxonomy mapped to status codes; generic client messages, detail only in logs. Timeouts + circuit breakers on every outbound call. Never swallow an error into an empty `catch {}`. Explicit partial-failure semantics. See the dedicated section below.                                                                                                             |

## A03: Software Supply Chain

The dependency tree is production code you did not write. Treat it that way.

### Install discipline

```bash
# Lockfile is committed and authoritative. CI never runs `npm install`.
npm ci

# Lifecycle scripts are arbitrary code execution at install time.
# Default to blocking them; allowlist the few packages that genuinely need one.
npm ci --ignore-scripts
```

```
# .npmrc
ignore-scripts=true
audit-level=high
provenance=true
```

When a package genuinely needs a postinstall (native builds, browser downloads), run it explicitly
and deliberately: `npm rebuild <pkg>` or `npx playwright install --with-deps`, never implicitly.

### Vulnerability scanning

```bash
npm audit --audit-level=high      # advisory database
osv-scanner scan source -r .      # OSV.dev, broader coverage, lockfile-aware
osv-scanner scan image app:latest # container layers too
```

Run both in CI and fail the build on high/critical. `npm audit fix --force` is not a fix strategy -
it silently accepts major version bumps; review the diff.

### Provenance, SBOM and attestation

```yaml
# .github/workflows/release.yml
permissions:
  contents: read
  id-token: write # required for provenance/OIDC
  attestations: write

steps:
  # Pin to a full commit SHA - tags are mutable (CVE-2025-30066, tj-actions/changed-files).
  - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

  - run: npm ci --ignore-scripts
  - run: npm run build

  - name: Generate SBOM
    run: npx @cyclonedx/cyclonedx-npm --output-file sbom.json

  - name: Attest build provenance
    uses: actions/attest-build-provenance@977bb373b6b3a2a6f7b1f0f0e1e6a9b4e60d6f0e # v3.0.0
    with:
      subject-path: "dist/**"

  # For published packages: signed, verifiable link from tarball back to the workflow run.
  - run: npm publish --provenance --access public
```

Consume attestations too - verification is the half everyone skips:

```bash
gh attestation verify ./dist/app.tar.gz --owner my-org
cosign verify ghcr.io/my-org/app:1.4.2 \
  --certificate-identity-regexp '^https://github.com/my-org/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

### Ongoing hygiene

- **Dependabot / Renovate** on a weekly cadence, grouped by ecosystem, with automerge limited to
  patch updates that pass the full test suite. Dependabot also keeps pinned action SHAs fresh.
- **Justify every new direct dependency** in the PR description: what it replaces, its transitive
  count, maintenance signals, and whether 30 lines of local code would do.
- **Watch the transitive count.** `npm ls --all | wc -l` before and after is a review artifact.
- **Cooldown on new versions** (Renovate `minimumReleaseAge: '3 days'`) blunts the window where a
  compromised publish is live before it is caught.
- **Scoped, short-lived publish tokens**; require 2FA/trusted publishing on the registry.
- **Vendor or fork** anything unmaintained that you cannot remove.

## A10: Mishandling of Exceptional Conditions

Most breaches through this category are not exotic - an error path skipped an authorization check,
or leaked internals, or hung forever.

### Fail closed

```ts
// BAD - fails open: an outage in the entitlement service grants access.
async function canAccess(userId: string, docId: string): Promise<boolean> {
  try {
    return await entitlements.check(userId, docId);
  } catch {
    return true; // catastrophic
  }
}

// GOOD - fails closed, and the failure is visible.
async function canAccess(userId: string, docId: string): Promise<boolean> {
  try {
    return await entitlements.check(userId, docId);
  } catch (err) {
    logger.error({ err, userId, docId }, "entitlement check failed");
    metrics.increment("entitlements.check.failed");
    throw new ServiceUnavailableError("Authorization service unavailable");
  }
}
```

The rule generalizes: on error, authentication denies, authorization denies, rate limiters reject,
signature verification rejects, feature flags fall back to the _safe_ value.

### Typed error taxonomy

```ts
// src/errors.ts
// Mirrors the taxonomy in backend.md: `statusCode`, a full problem-type URI, and one
// concrete base class so a single `instanceof AppError` check handles every case.

/** One field-level problem, as carried in the RFC 9457 `errors` member. */
export interface FieldError {
  field: string;
  message: string;
  code?: string;
}

export class AppError extends Error {
  readonly statusCode: number;
  readonly type: string; // RFC 9457 problem type URI
  readonly expose = true; // safe to show the message to a client

  constructor(
    message: string,
    statusCode: number,
    type: string,
    options?: { cause?: unknown },
  ) {
    super(message, options);
    this.name = new.target.name;
    this.statusCode = statusCode;
    this.type = type;
    Error.captureStackTrace(this, new.target);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Authentication required") {
    super(message, 401, "https://api.example.com/problems/unauthorized");
  }
}
export class ForbiddenError extends AppError {
  constructor(message = "Insufficient permissions") {
    super(message, 403, "https://api.example.com/problems/forbidden");
  }
}
export class NotFoundError extends AppError {
  constructor(message = "Resource not found") {
    super(message, 404, "https://api.example.com/problems/not-found");
  }
}
export class ValidationError extends AppError {
  // Schema-invalid input is 422; only unparseable syntax is 400.
  constructor(
    message = "Validation failed",
    readonly errors: FieldError[] = [],
  ) {
    super(message, 422, "https://api.example.com/problems/validation-error");
  }
}
export class ServiceUnavailableError extends AppError {
  constructor(message = "Service unavailable") {
    super(message, 503, "https://api.example.com/problems/service-unavailable");
  }
}
```

### Nothing leaks from the error handler

```ts
import type { ErrorRequestHandler } from "express";
import { ZodError } from "zod";
import { AppError, ValidationError } from "./errors.js";
import { logger } from "./logger.js";

/** Terminal error handler. Must be registered last. */
export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  const requestId = res.locals.requestId as string;

  // Schema-invalid input is 422. A body Express could not parse is 400 - that arrives
  // here as a SyntaxError from express.json(), not as a ZodError.
  if (err instanceof ZodError) {
    logger.warn({ err, requestId }, "validation failed");
    return res.status(422).json({
      type: "https://api.example.com/problems/validation-error",
      title: "Validation failed",
      status: 422,
      instance: requestId,
      errors: err.issues.map((i) => ({
        field: i.path.join("."),
        message: i.message,
        code: i.code,
      })),
    });
  }

  if (err instanceof SyntaxError && "body" in err) {
    logger.warn({ err, requestId }, "malformed request body");
    return res.status(400).json({
      type: "https://api.example.com/problems/bad-request",
      title: "Malformed request body",
      status: 400,
      instance: requestId,
    });
  }

  if (err instanceof AppError) {
    logger.warn({ err, requestId }, err.message);
    return res.status(err.statusCode).json({
      type: err.type,
      title: err.message,
      status: err.statusCode,
      instance: requestId,
      ...(err instanceof ValidationError && { errors: err.errors }),
    });
  }

  // Unknown: log everything, disclose nothing. No stack, no cause, no SQL text.
  logger.error({ err, requestId, path: req.path }, "unhandled error");
  return res.status(500).json({
    type: "https://api.example.com/problems/internal",
    title: "Internal server error",
    status: 500,
    instance: requestId,
  });
};
```

Express 5 forwards rejected promises from async handlers automatically - the old `asyncHandler`
wrapper is no longer needed. Respond with `application/problem+json` (RFC 9457) where the API
contract allows it.

### Timeouts and circuit breakers

Every outbound call gets a deadline. A request with no timeout is a resource exhaustion bug waiting
for a slow dependency.

```ts
const res = await fetch(url, {
  signal: AbortSignal.timeout(3_000),
  redirect: "error", // SSRF: never follow attacker-chosen redirects
});
```

- Postgres: `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout` set on the
  connection; pool `connectionTimeoutMillis` so the app fails fast rather than queueing.
- Wrap flaky dependencies in a circuit breaker (e.g. `opossum`): open after N consecutive failures,
  half-open probe, and a _defined_ fallback that is safe when the breaker is open.
- Bound every retry: jittered exponential backoff, a retry budget, and **only** for idempotent
  operations or requests carrying an idempotency key.

### Never swallow, always decide

```ts
// BAD - silence. The bug is invisible and the caller sees success.
try {
  await auditLog.write(event);
} catch {}

// GOOD - explicit decision, recorded.
try {
  await auditLog.write(event);
} catch (err) {
  logger.error({ err, event: event.type }, "audit log write failed");
  metrics.increment("audit.write.failed");
  throw new ServiceUnavailableError("Audit unavailable"); // audit is mandatory -> fail closed
}
```

Partial failures must be explicit, never averaged into a 200:

```ts
const results = await Promise.allSettled(jobs.map(runJob));
const failed = results.filter((r) => r.status === "rejected");
if (failed.length > 0) {
  logger.error(
    { failed: failed.length, total: results.length },
    "batch partially failed",
  );
  return res
    .status(207)
    .json({ succeeded: results.length - failed.length, failed: failed.length });
}
```

`Promise.all` short-circuits and abandons in-flight work; use `allSettled` when each item's outcome
matters. Register `process.on('unhandledRejection')` and `'uncaughtException'` to log and exit
non-zero - let the orchestrator restart a process in an unknown state rather than serving from one.

## Input Validation (Zod 4)

Validate at every boundary: request bodies, query strings, route params, headers, webhook payloads,
environment variables, and every third-party API response.

```ts
import { z } from "zod";

// z.strictObject() rejects unknown keys - mass-assignment guard (Zod 4 replaces `.strict()`).
export const createUserSchema = z.strictObject({
  email: z.email().max(254).toLowerCase(), // Zod 4: top-level z.email()
  password: z.string().min(12).max(128),
  name: z.string().trim().min(2).max(100),
  role: z.enum(["user", "admin"]).default("user"),
});

export const paginationSchema = z.object({
  cursor: z.string().max(200).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().max(100).optional(),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
```

```ts
import type { RequestHandler } from "express";
import { z, type ZodError, type ZodType } from "zod";

declare global {
  namespace Express {
    interface Locals {
      validated?: unknown;
      requestId: string;
    }
  }
}

/** Zod 4: use the z.flattenError() helper; the old error method was removed. */
function toFieldErrors(error: ZodError): FieldError[] {
  return Object.entries(z.flattenError(error).fieldErrors).flatMap(
    ([field, messages]) =>
      (messages ?? []).map((message) => ({ field, message })),
  );
}

/** Validates the request body and stores the parsed result on res.locals. */
export function validateBody<T>(schema: ZodType<T>): RequestHandler {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return next(
        new ValidationError("Validation failed", toFieldErrors(result.error)),
      );
    }
    res.locals.validated = result.data;
    next();
  };
}

/** Validates query params. Express 5: req.query is a getter - never reassign it. */
export function validateQuery<T>(schema: ZodType<T>): RequestHandler {
  return (req, res, next) => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      return next(
        new ValidationError(
          "Invalid query parameters",
          toFieldErrors(result.error),
        ),
      );
    }
    res.locals.validated = result.data;
    next();
  };
}
```

Key points: `z.strictObject()` for every input object (prevents mass assignment), always consume the
_parsed_ output rather than the raw input, and cap the length of every string so a payload cannot
become a DoS. Body size is capped separately: `express.json({ limit: '100kb' })`.

## Injection: Parameterized SQL Only

```ts
// NEVER - string concatenation or interpolation of user input
const bad = `SELECT * FROM users WHERE email = '${email}'`;

// GOOD - node-postgres placeholders
const { rows } = await pool.query<User>(
  "SELECT id, email, name, role FROM users WHERE email = $1",
  [email],
);

// GOOD - Drizzle ORM (compile-time typed, parameterized)
const user = await db.select().from(users).where(eq(users.email, email));

// GOOD - Drizzle raw fragments: sql`` interpolation is parameterized, sql.raw() is NOT
const active = await db.execute(
  sql`SELECT id FROM users WHERE email = ${email}`,
);

// GOOD - Kysely
const row = await db
  .selectFrom("users")
  .select(["id", "email"])
  .where("email", "=", email)
  .executeTakeFirst();

// GOOD - Prisma
const found = await prisma.user.findUnique({ where: { email } });
```

Identifiers (table/column names, `ORDER BY` targets) cannot be parameterized - map them through an
allowlist, never interpolate user input:

```ts
const SORTABLE = { name: "name", created: "created_at" } as const;
const column = SORTABLE[sort as keyof typeof SORTABLE] ?? "created_at";
const direction = dir === "asc" ? "ASC" : "DESC";
const sql = `SELECT id, name FROM users ORDER BY ${column} ${direction} LIMIT $1`;
```

Same rule for other interpreters: `execFile('git', ['log', ref])` rather than `exec(\`git log ${ref}\`)`.

## Password Security (argon2id)

argon2id is the default. bcrypt at cost ≥ 12 is acceptable for legacy hashes you have not migrated.

```ts
import argon2 from "argon2";

// OWASP-aligned baseline; tune upward until hashing takes ~250-500ms on production hardware.
const ARGON2_OPTIONS = {
  type: argon2.argon2id,
  memoryCost: 19_456, // 19 MiB
  timeCost: 2,
  parallelism: 1,
} as const;

/** Hashes a plaintext password with argon2id. The salt is generated and embedded automatically. */
export function hashPassword(password: string): Promise<string> {
  return argon2.hash(password, ARGON2_OPTIONS);
}

/** Verifies a password against a stored hash. Returns false on any malformed hash. */
export async function verifyPassword(
  hash: string,
  password: string,
): Promise<boolean> {
  try {
    return await argon2.verify(hash, password);
  } catch {
    return false;
  }
}

/** True when a hash was produced with weaker params and should be re-hashed on next login. */
export function needsRehash(hash: string): boolean {
  return argon2.needsRehash(hash, ARGON2_OPTIONS);
}
```

Migrating off bcrypt: detect the `$2b$` prefix, verify with bcrypt, then re-hash with argon2id
inside the successful-login path - the only moment the plaintext is available.

```ts
export async function login(email: string, password: string) {
  const user = await findUserByEmail(email);

  // Constant-ish work regardless of whether the user exists: no user enumeration via timing.
  const hash = user?.passwordHash ?? DUMMY_ARGON2_HASH;
  const ok = await verifyPassword(hash, password);
  if (!user || !ok) throw new UnauthorizedError("Invalid credentials");

  if (needsRehash(user.passwordHash)) {
    await updatePasswordHash(user.id, await hashPassword(password));
  }
  await rotateSessionId(user.id); // session fixation defence
  const { passwordHash, ...safe } = user; // never return the hash
  return safe;
}
```

Policy: minimum 12 characters, maximum 128 (argon2 is not length-limited like bcrypt's 72 bytes),
no forced composition rules or periodic expiry (NIST SP 800-63B), and a check against a breached
password corpus at registration and change time.

## Sessions and Tokens

**Default to opaque session tokens with server-side state.** A random 256-bit identifier in an
httpOnly cookie, with the session record in Postgres or Redis, gives instant revocation, immediate
role changes, and a per-session audit trail. JWTs trade all of that away for stateless verification
you usually do not need at a single-service scale.

Use JWTs when you genuinely need cross-service verification without a shared session store - and
then keep them short-lived. Prefer **`jose`** over `jsonwebtoken`: actively maintained, Web Crypto
based, works on every runtime, and supports EdDSA/JWKS out of the box.

```ts
import { SignJWT, jwtVerify, type JWTPayload } from "jose";

const secret = new TextEncoder().encode(requireEnv("JWT_SECRET")); // >= 32 bytes
const ISSUER = "https://api.example.com";
const AUDIENCE = "https://app.example.com";

export interface AccessClaims extends JWTPayload {
  sub: string;
  role: "user" | "admin";
  sid: string; // session id - enables revocation
}

/** Mints a short-lived access token bound to a server-side session. */
export function signAccessToken(
  claims: Omit<AccessClaims, keyof JWTPayload> & { sub: string },
) {
  return new SignJWT(claims)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuer(ISSUER)
    .setAudience(AUDIENCE)
    .setSubject(claims.sub)
    .setJti(crypto.randomUUID())
    .setIssuedAt()
    .setExpirationTime("15m")
    .sign(secret);
}

/** Verifies a token. Algorithm, issuer and audience are all pinned. */
export async function verifyAccessToken(token: string): Promise<AccessClaims> {
  try {
    const { payload } = await jwtVerify<AccessClaims>(token, secret, {
      algorithms: ["HS256"], // pin: blocks alg-confusion and "alg": "none"
      issuer: ISSUER,
      audience: AUDIENCE,
      clockTolerance: 5,
    });
    return payload;
  } catch (err) {
    throw new UnauthorizedError("Invalid or expired token");
  }
}
```

For asymmetric setups use `EdDSA`/`ES256` with `createRemoteJWKSet()` so verifiers never hold a
signing key. Never accept the algorithm from the token header.

### Revocation strategy

Short expiry alone is not revocation. Pick one and implement it:

1. **Session id in the token (`sid`)** - check a Redis/Postgres denylist or session table on each
   request. Effectively opaque tokens with a cached payload; the usual right answer.
2. **Refresh token rotation with reuse detection** - each refresh issues a new refresh token and
   invalidates the old one. Presentation of an already-used token means theft: revoke the entire
   token family and force re-authentication.
3. **Global `tokensValidAfter` timestamp per user** - bumped on password change, role change, or
   "log out everywhere"; reject any token with `iat` before it.

Refresh tokens live in cookies, never in `localStorage`:

```ts
res.cookie("refresh_token", token, {
  httpOnly: true, // invisible to JS - blunts XSS exfiltration
  secure: true, // HTTPS only
  sameSite: "strict", // CSRF defence; 'lax' if cross-site nav is needed
  path: "/api/auth/refresh", // sent only to the endpoint that needs it
  maxAge: 7 * 24 * 60 * 60 * 1000,
  ...(process.env.NODE_ENV === "production" && { domain: ".example.com" }),
});
```

Store only a hash of the refresh token server-side, so a database leak does not yield usable
credentials. When cookies are used for state-changing requests, add a CSRF defence
(double-submit token or the `Origin` header check) in addition to `SameSite`.

**Batteries-included alternatives.** Rolling your own auth means owning password reset, MFA,
passkeys, session rotation, and account recovery forever. **Better Auth** (TypeScript-first,
self-hosted, own your database) and **Auth.js** (large provider catalogue, framework adapters) both
implement these correctly and are worth preferring over a bespoke implementation for new projects.

## Authorization Middleware

```ts
import type { Request, RequestHandler } from "express";

/** Rejects requests without a valid bearer token; attaches claims to res.locals. */
export const authenticate: RequestHandler = async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer "))
    return next(new UnauthorizedError("No token provided"));

  const claims = await verifyAccessToken(header.slice(7));
  if (await isSessionRevoked(claims.sid))
    return next(new UnauthorizedError("Session revoked"));

  res.locals.user = claims;
  next();
};

/** Restricts a route to the listed roles. */
export function authorize(
  ...roles: ReadonlyArray<"user" | "admin">
): RequestHandler {
  return (req, res, next) => {
    const user = res.locals.user;
    if (!user) return next(new UnauthorizedError("Not authenticated"));
    if (!roles.includes(user.role))
      return next(new ForbiddenError("Insufficient permissions"));
    next();
  };
}

/** Verifies the authenticated user owns the target resource. */
export function requireOwnership(
  getOwnerId: (req: Request) => Promise<string | null>,
): RequestHandler {
  return async (req, res, next) => {
    const user = res.locals.user;
    const ownerId = await getOwnerId(req);
    if (ownerId === null) return next(new NotFoundError("Resource not found"));
    // 404 rather than 403 on a miss: does not confirm the resource exists.
    if (ownerId !== user.sub && user.role !== "admin")
      return next(new NotFoundError("Resource not found"));
    next();
  };
}
```

Authorization is decided server-side against persisted state. A `role` field in a request body, a
hidden form input, or a client-side route guard is a UX affordance, not a control.

## Security Headers

```ts
import helmet from "helmet";
import crypto from "node:crypto";

app.disable("x-powered-by");

// Per-request nonce so the CSP needs no 'unsafe-inline' for scripts.
app.use((req, res, next) => {
  res.locals.cspNonce = crypto.randomBytes(16).toString("base64");
  next();
});

app.use(
  helmet({
    contentSecurityPolicy: {
      useDefaults: false,
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: [
          "'self'",
          (req, res) => `'nonce-${res.locals.cspNonce}'`,
          "'strict-dynamic'",
        ],
        // MUI v9 emits CSS custom properties; with the CSS-variables theme and a nonce on the
        // emotion/style cache, styleSrc needs no 'unsafe-inline'. Fall back to a style nonce
        // rather than a blanket 'unsafe-inline'.
        styleSrc: ["'self'", (req, res) => `'nonce-${res.locals.cspNonce}'`],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'", process.env.API_URL!],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        objectSrc: ["'none'"],
        baseUri: ["'self'"],
        formAction: ["'self'"],
        frameAncestors: ["'none'"],
        upgradeInsecureRequests: [],
      },
    },
    hsts: { maxAge: 63_072_000, includeSubDomains: true, preload: true },
    crossOriginOpenerPolicy: { policy: "same-origin" }, // isolates the browsing context
    crossOriginResourcePolicy: { policy: "same-site" }, // blocks cross-origin embedding
    referrerPolicy: { policy: "strict-origin-when-cross-origin" },
  }),
);

// Not covered by Helmet: disable device APIs the app does not use.
app.use((req, res, next) => {
  res.setHeader(
    "Permissions-Policy",
    "camera=(), microphone=(), geolocation=(), payment=(), usb=(), interest-cohort=()",
  );
  next();
});
```

Pass the nonce into the HTML shell and into the MUI/emotion style cache
(`createCache({ key: 'mui', nonce: res.locals.cspNonce })`). Report-only first
(`Content-Security-Policy-Report-Only` with `report-to`) to find violations before enforcing.

## CORS

```ts
import cors from "cors";

const allowed = new Set(
  (process.env.ALLOWED_ORIGINS ?? "").split(",").filter(Boolean),
);

app.use(
  cors({
    origin(origin, callback) {
      // No Origin header: same-origin, curl, or a native client. Cookies are not at risk here.
      if (!origin) return callback(null, true);
      if (allowed.has(origin)) return callback(null, true);
      callback(new ForbiddenError("Origin not allowed"));
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization", "Idempotency-Key"],
    exposedHeaders: ["RateLimit", "Retry-After"],
    maxAge: 86_400,
  }),
);
```

Never reflect an arbitrary `Origin` back with `credentials: true`, and never combine `origin: '*'`
with credentials - the browser blocks it, and code that "works around" it has a hole. Wildcard
subdomain matching must anchor the pattern (`/^https:\/\/[a-z0-9-]+\.example\.com$/`), or
`evil-example.com.attacker.io` slips through.

## Rate Limiting (express-rate-limit v8)

```ts
import { rateLimit, ipKeyGenerator } from "express-rate-limit";
import { RedisStore } from "rate-limit-redis";

// In-memory counters are per-process: with more than one instance the effective
// limit multiplies by the replica count. Use a shared store in production.
const store = new RedisStore({
  sendCommand: (...args: string[]) => redis.call(...args),
});

export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100, // v8: `limit`, not the deprecated `max`
  standardHeaders: "draft-8", // RateLimit / RateLimit-Policy headers
  legacyHeaders: false,
  store,
});

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 5,
  skipSuccessfulRequests: true, // count failures only
  // Throttle per account as well as per IP: a botnet defeats IP-only limits.
  keyGenerator: (req) =>
    `${ipKeyGenerator(req.ip!)}:${String(req.body?.email ?? "")}`,
  store,
});

app.use("/api", apiLimiter);
app.use(
  ["/api/auth/login", "/api/auth/register", "/api/auth/reset-password"],
  authLimiter,
);
```

Set `app.set('trust proxy', 1)` to the exact number of trusted proxies - `true` lets a client spoof
`X-Forwarded-For` and evade the limit entirely. Return 429 with `Retry-After`. Beyond request
counting, add cost-based quotas for expensive endpoints (search, exports, report generation).

## Secrets Management

```ts
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]),
  DATABASE_URL: z.url(),
  JWT_SECRET: z.string().min(32, "JWT_SECRET must be at least 32 characters"),
  SESSION_SECRET: z.string().min(32),
  ALLOWED_ORIGINS: z.string().optional(),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug"])
    .default("info"),
});

/** Parses and freezes process configuration. Throws at startup on any invalid value. */
function loadEnv() {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    // No logger yet; write to stderr and exit non-zero.
    process.stderr.write(
      `Invalid environment:\n${JSON.stringify(z.flattenError(parsed.error).fieldErrors, null, 2)}\n`,
    );
    process.exit(1);
  }
  return Object.freeze(parsed.data);
}

export const env = loadEnv();
```

- Secrets come from a manager (Vault, AWS/GCP Secret Manager, Doppler) or the platform's encrypted
  environment - never from a committed file. `.env` is for local development only and is gitignored
  alongside `*.pem`, `*.key`, `*.p12`.
- Docker: `--mount=type=secret`, never `--build-arg` (build args persist in image history).
- CI: OIDC federation instead of long-lived cloud credentials; scope the trust policy to the exact
  repository and workflow file.
- Run secret scanning (gitleaks/trufflehog) as a pre-commit hook _and_ in CI. Any secret that ever
  touched a commit is burned - rotate it, do not merely rewrite history.

## A09: Logging, Redaction and Alerting

```ts
import { pino } from "pino";

export const logger = pino({
  level: env.LOG_LEVEL,
  redact: {
    paths: [
      "password",
      "*.password",
      "passwordHash",
      "*.passwordHash",
      "token",
      "*.token",
      "accessToken",
      "refreshToken",
      "secret",
      "apiKey",
      "req.headers.authorization",
      "req.headers.cookie",
      'res.headers["set-cookie"]',
      "user.email", // PII: hash or drop, depending on your retention policy
      "*.creditCard",
      "*.ssn",
      "*.dateOfBirth",
    ],
    censor: "[REDACTED]",
  },
  formatters: { level: (label) => ({ level: label }) },
  // Correlate log lines with traces.
  mixin: () => ({ traceId: trace.getActiveSpan()?.spanContext().traceId }),
});
```

`redact` replaces the hand-rolled sanitize helper: it is applied by the serializer, so it cannot be
forgotten at a call site, and it covers nested and wildcard paths.

### Log these security events

Authentication success and failure (with user id, source IP, user agent), authorization denials,
password and email changes, MFA enrolment and removal, role/permission changes, token and session
revocation, admin actions, data exports, and rate-limit breaches. Every entry carries a request id
and a `traceparent`.

### Alert on these - logging without alerting is A09

| Signal                                     | Threshold                  | Why                                  |
| ------------------------------------------ | -------------------------- | ------------------------------------ |
| Auth failure spike (per account)           | > 10 in 5 min              | Credential stuffing against one user |
| Auth failure spike (global)                | > 5x baseline              | Broad credential stuffing            |
| Authorization denials from one principal   | > 20 in 5 min              | Enumeration / privilege probing      |
| 5xx error rate                             | SLO error-budget burn rate | A10 failures reaching users          |
| New admin role grant                       | any                        | Privilege escalation                 |
| Secret scanner hit in CI                   | any                        | Leaked credential                    |
| New high/critical advisory in dependencies | any                        | A03 exposure                         |
| Logging pipeline gap                       | > 5 min with no events     | Blinded, possibly deliberately       |

Alerts route to an on-call human, not an unread channel. Logs ship off-host to append-only storage
so an attacker with host access cannot erase the trail.

## XSS Prevention (React 19)

```tsx
// SAFE - React escapes interpolated content
<Typography>{user.name}</Typography>
<TextField value={query} onChange={(e) => setQuery(e.target.value)} />

// DANGEROUS - sanitize first, always
import DOMPurify from 'dompurify';

export function RichContent({ html }: { html: string }) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'rel', 'target'],
    ALLOWED_URI_REGEXP: /^(?:https?:|mailto:|\/)/i,
  });
  return <Box dangerouslySetInnerHTML={{ __html: clean }} />;
}

// Never render an unvalidated URL: javascript: and data: URIs execute.
export function SafeLink({ url, children }: { url: string; children: React.ReactNode }) {
  const safe = /^(https?:\/\/|\/)/i.test(url);
  if (!safe) return <span>{children}</span>;
  return <Link href={url} rel="noopener noreferrer" target="_blank">{children}</Link>;
}
```

Also forbidden: user input flowing into `href`/`src`/`style` without validation, into
`<script>`/`<iframe srcdoc>`, into `eval`/`new Function`, or into `Element.innerHTML`. Sanitize on
output (at render), not on input - sanitizing on input loses the original and drifts from the
rules the renderer actually applies.

## File Upload Security

```ts
import multer from "multer";
import { fileTypeFromBuffer } from "file-type";
import crypto from "node:crypto";

const MAX_BYTES = 5 * 1024 * 1024;
const ALLOWED_MIME = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "application/pdf",
]);

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_BYTES, files: 5, fields: 20 },
  fileFilter: (_req, file, cb) => {
    // The client-declared mimetype is a hint, not evidence - re-checked below.
    cb(null, ALLOWED_MIME.has(file.mimetype));
  },
});

/** Verifies real content type by magic bytes and returns a safe, opaque storage key. */
export async function acceptUpload(buffer: Buffer): Promise<string> {
  const detected = await fileTypeFromBuffer(buffer);
  if (!detected || !ALLOWED_MIME.has(detected.mime)) {
    throw new ValidationError("Unsupported file type", [
      { field: "file", message: "Unsupported file type" },
    ]);
  }
  return `${crypto.randomUUID()}.${detected.ext}`; // never reuse the client filename
}
```

Store uploads outside the web root (object storage with private ACLs), serve them from a separate
origin with `Content-Disposition: attachment` and `X-Content-Type-Options: nosniff`, and scan for
malware where users can download each other's files. Rendering user SVGs is script execution -
rasterize or sanitize them.

## Security Checklist

### Backend

- [ ] Zod 4 validation on every body, query, param, header and webhook, with `z.strictObject()`
- [ ] Parameterized SQL only; identifiers allowlisted, never interpolated
- [ ] Passwords hashed with argon2id (bcrypt cost ≥ 12 accepted only as legacy), rehash on login
- [ ] Access tokens ≤ 15 min; refresh tokens rotated with reuse detection; revocation path exists
- [ ] `jose` (not `jsonwebtoken`), algorithm/issuer/audience pinned on verification
- [ ] Authorization checked server-side on every route, including ownership
- [ ] Rate limiting on auth and expensive endpoints, with a shared store across replicas
- [ ] `trust proxy` set to an exact hop count
- [ ] Helmet with nonce-based CSP (no `unsafe-inline`), HSTS preload, COOP/CORP, Permissions-Policy
- [ ] Cookies `httpOnly` + `Secure` + `SameSite`, scoped `path`, refresh tokens stored hashed
- [ ] Env validated by Zod at startup; process exits on invalid config
- [ ] pino `redact` paths cover credentials, tokens and PII
- [ ] Error handler leaks no stack, SQL, or internal identifiers
- [ ] Timeouts on every outbound call and DB statement; circuit breakers on flaky dependencies
- [ ] Fails closed on authz, authn, rate limiting and signature verification
- [ ] File uploads size-capped, magic-byte verified, renamed, stored off-origin
- [ ] No `console.log`; structured logger only

### Frontend

- [ ] No secrets or privileged API keys in client code or the bundle
- [ ] User-supplied HTML sanitized with DOMPurify at render time
- [ ] Auth state in httpOnly cookies, never `localStorage`/`sessionStorage`
- [ ] URLs validated before use in `href`/`src`; external links get `rel="noopener noreferrer"`
- [ ] API responses parsed with Zod before entering component state
- [ ] No `eval`, `new Function`, or `innerHTML` with user data
- [ ] CSP nonce threaded through the MUI/emotion cache; no `unsafe-inline` fallback
- [ ] Dependencies of the client bundle reviewed - client-side supply chain is A03 too

### Infrastructure & Supply Chain

- [ ] TLS 1.3, HSTS preload submitted
- [ ] Lockfile committed; CI runs `npm ci --ignore-scripts`
- [ ] `osv-scanner` + `npm audit` gate the build on high/critical
- [ ] Dependabot/Renovate active, including pinned action SHAs
- [ ] All GitHub Actions pinned to full commit SHAs
- [ ] SBOM generated and build provenance attested; attestations verified before deploy
- [ ] Container images signed (cosign keyless) and signature-verified at deploy
- [ ] OIDC for cloud auth; no long-lived credentials in CI
- [ ] Secret scanning in pre-commit and CI; rotation runbook exists
- [ ] Least-privilege DB roles; row-level security where multi-tenant
- [ ] Security events shipped to immutable off-host storage with alerting configured
- [ ] Incident response runbook current, with named on-call
