---
title: Security Patterns
type: concept
created: 2026-06-14
tags:
  - concept
  - security
  - authentication
  - authorization
  - system-design
---

# Security Patterns

Security is not a feature added later — it is the foundation built in from the start. In distributed systems, security must operate at every layer: network, transport, identity, permissions, data, and audit. No single pattern provides sufficient protection; defense in depth is the operating principle.

## Defense in Depth

A secure system uses multiple independent security layers so that failure of any one layer does not expose the system. The layers, from outermost to innermost:

1. **Network Security**: Firewalls, DDoS protection, VPNs, network ACLs.
2. **Transport Security**: TLS/HTTPS, mTLS, certificate management.
3. **Authentication**: Verifying identity — proving who the requester is.
4. **Authorization**: Verifying permissions — what the requester is allowed to do.
5. **Data Encryption**: Encryption at rest and in transit.
6. **Audit Logging**: Immutable record of who did what, when.

## Authentication Patterns

Authentication answers one question: "Are you who you claim to be?"

### Session-Based Authentication

The traditional model: server creates a session on login, stores session state (in memory, Redis, or database), and returns a session cookie to the client.

**Flow:** Client sends credentials → Server validates → Creates session → Returns cookie → Client includes cookie on each request → Server looks up session.

**Pros:** Simple, server controls all sessions, immediate revocation by deleting session.
**Cons:** Server must store session state (not horizontally scalable without shared session store), not suitable for microservices.
**Session store sizing:** Redis-based sessions need careful memory monitoring. A 2 KB session × 1M active users = 2 GB. Expiry policies and session cleanup are critical.

### JWT (JSON Web Tokens)

JWT makes authentication stateless. The server signs a token containing user claims; the client presents the token; the server validates the signature without any server-side storage.

**Structure:** `header.payload.signature` (base64url-encoded JSON).

**Critical rules:**
- Never store sensitive data in the payload — it is base64-encoded, not encrypted.
- Use short expiration (15–60 minutes). Pair with refresh tokens for long-lived sessions.
- Validate the signature on every request. Never accept tokens with `alg: none`.
- Use a proper secret management system for signing keys. Rotate keys periodically.
- Implement token blacklisting for logout in high-security applications.

**Refresh token pattern:** Short-lived access token (15 min) + long-lived refresh token (7 days). The refresh token is stored server-side or as an opaque handle. On expiry, the client exchanges the refresh token for a new access token. Requires the refresh endpoint to be rate-limited and monitored.

### OAuth 2.0

OAuth 2.0 delegates authentication to trusted providers (Google, GitHub, etc.). The **Authorization Code** flow is the standard:

1. User clicks "Login with Google" → redirected to Google.
2. User authenticates on Google's domain (credentials never touch your app).
3. Google redirects back with an authorization code.
4. Your server exchanges the code for an access token (server-to-server, secure).
5. Your server fetches user info with the token and creates a local session/JWT.

**Security considerations:** Always use PKCE (Proof Key for Code Exchange) for public clients. Validate the `iss` and `aud` claims in ID tokens. Never log tokens or authorization codes.

### OAuth 2.0 Grant Type Decision Tree

Choosing the wrong OAuth 2.0 grant type is a common security mistake. The decision depends on who the client is:

```
Is the client a public app (cannot keep a secret)?
  ├─ Yes → Is it a browser-based SPA?
  │         ├─ Yes → Authorization Code with PKCE (no client secret)
  │         └─ No  → Authorization Code with PKCE (native/mobile)
  └─ No  → Is the client a server-side web app?
            ├─ Yes → Authorization Code with client secret
            └─ No  → Is it machine-to-machine?
                      ├─ Yes → Client Credentials (no user context)
                      └─ No  → Resource Owner Password (legacy only, avoid)
```

**Key rules:**
- Never use Implicit flow (deprecated by OAuth 2.1). PKCE replaces it.
- Client Credentials is for server-to-server with no user — no refresh token needed.
- Resource Owner Password flow exposes user credentials to the client app. It is a last resort for legacy migration.
- PKCE (Proof Key for Code Exchange) is mandatory for all public clients, not optional.

### API Key Rotation Mechanics

API keys are long-lived secrets that accumulate risk over time. A rotation policy reduces the blast window of a leaked key.

#### Overlapping Rotation Pattern

Never delete the old key immediately — active clients may still be using it:

```
Week 1:    [Key v1 issued]
Week 26:   [Key v2 issued] → both v1 and v2 are valid
Week 27:   [v1 decommissioned] → only v2 is valid
Week 52:   [Key v3 issued] → both v2 and v3 are valid
Week 53:   [v2 decommissioned] → only v3 is valid
```

**Implementation:**
1. Generate new key and store hash. Mark as `active`.
2. Clients get the new key through a secure distribution channel (secrets manager, not email).
3. Overlap period: 1–2 weeks depending on client update cadence.
4. Check `last_used_at` on old key — if a client still uses it, extend the overlap.
5. Send alerts when `last_used_at` timestamp approaches the decommission date.

#### Key Hash vs. Raw Key

```
# Server stores: bcrypt_hash(api_key)
# Client stores: api_key (raw)
# On request:
#   Client includes api_key in Authorization header
#   Server re-computes hash and compares
```

Never store raw keys in the database. A database leak should not expose all active API keys.

### TLS Termination Decisions

TLS termination can happen at different points in the infrastructure, each with tradeoffs:

| Termination Point | Pros | Cons |
|---|---|---|
| **Load balancer** | Central certificate management, hardware acceleration, offloads CPU from app servers | Internal traffic (LB → app) is unencrypted unless mTLS is also configured |
| **Application server** | End-to-end encryption, no plaintext inside the network | Every server handles TLS termination, certificate distribution to all nodes |
| **CDN edge** | DDoS protection, geo-distributed termination, HTTP/2 termination | CDN sees plaintext (trust boundary), CDN outage blocks all traffic |

**Recommendation**: terminate TLS at the load balancer for most applications. Use mTLS between load balancer and application if internal traffic crosses trust boundaries (different VPCs, shared infrastructure).

### Cloudflare Tunnel for Ingress Security

Services behind Cloudflare Tunnel (Argo Tunnel) eliminate public-facing IPs entirely:

```
User → [Cloudflare Edge] ← encrypted tunnel → [Cloudflare Tunnel]
                                                      ↓
                                            [Application Server]
                                                      ↓
                                            [No public IP, no open ports]
```

Instead of opening firewall ports, the service initiates an outbound tunnel to Cloudflare's edge. Cloudflare proxies traffic through this tunnel:

- **No public IP**: the server does not need a public-facing IP or open inbound firewall rules.
- **DDoS protection**: all traffic passes through Cloudflare's edge before reaching the service.
- **Access policies**: enforce authentication at the edge with Cloudflare Access (Zero Trust) before traffic reaches the tunnel.
- **Health monitoring**: Cloudflare monitors tunnel health and routes around failures.

This is ideal for services that should never be directly reachable — internal dashboards, admin panels, staging environments.

### Multi-Factor Authentication

MFA adds a second factor (TOTP, SMS, hardware key) beyond the password. Implementation patterns:
- **TOTP**: Time-based one-time passwords (Google Authenticator, Authy). Secret key shared at enrollment.
- **WebAuthn/FIDO2**: Hardware-bound public-key cryptography. Phishing-resistant.
- **Backup codes**: One-time use codes for recovery when the second factor is unavailable.

## Authorization Patterns

Authorization answers: "What can you do?" It is logically separate from authentication.

### RBAC (Role-Based Access Control)

Users are assigned roles. Roles have permissions. Simple and effective for most applications.

```
User: alice@example.com
  ├─ Role: EDITOR
  │    ├─ Permission: READ_POST
  │    ├─ Permission: WRITE_POST
  │    └─ Permission: EDIT_POST
  └─ Role: VIEWER
       └─ Permission: READ_POST

Can alice DELETE_POST? → No (neither role has the permission)
```

**Best practices:**
- Prefer coarse roles (3–5) over fine-grained. Too many roles create management overhead.
- Assign roles, not individual permissions, to users.
- Implement role hierarchy: ADMIN → MODERATOR → USER.
- Cache permission lookups with short TTL (1–5 minutes).

### ABAC (Attribute-Based Access Control)

ABAC evaluates policies against attributes of the user, resource, action, and environment context.

**Example rules:**
- A user can edit a document if `user.id == document.owner_id`.
- A user can delete a post within 24 hours of creation.
- A manager can view reports for their department.
- Access is granted only during business hours (9:00–17:00 local time).

**ABAC vs. RBAC:** ABAC is more flexible but harder to audit. Use RBAC for coarse access control and ABAC for resource-level, context-sensitive rules. Most production systems use both: RBAC for broad roles, ABAC for fine-grained resource checks.

### API Key Authentication

For machine-to-machine communication:
- Generate a unique API key per consumer.
- Store the hash of the key, never the raw key.
- Rate-limit per key.
- Support key rotation with overlapping validity periods.
- Log all authentication failures.

## Secure Communication Patterns

### TLS Everywhere

- Enforce HTTPS for all production traffic. Redirect HTTP to HTTPS.
- Use HSTS (Strict-Transport-Security) headers to prevent downgrade attacks.
- Set secure cookie flags: `HttpOnly`, `Secure`, `SameSite=Strict/Lax`.
- mTLS for service-to-service communication in zero-trust environments.

### Request Signing

Prevent request tampering between services by signing each request with HMAC:

```
signature = HMAC-SHA256(secret, method + path + body + timestamp)
```

The receiving service recomputes the signature and rejects mismatches. Include a timestamp to prevent replay attacks — reject requests older than 5 minutes.

### CORS Configuration

- Set `Access-Control-Allow-Origin` to specific origins, never `*` with credentials.
- Limit `Access-Control-Allow-Methods` to required methods only.
- Do not reflect the `Origin` header blindly (reflect-cors vulnerability).

## Data Protection

### Encryption at Rest

- Encrypt sensitive fields (PII, credentials) at the application layer before storing in the database.
- Use envelope encryption: a data encryption key (DEK) encrypts data; a key encryption key (KEK) encrypts the DEK.
- Rotate encryption keys periodically. Maintain key version history.
- Database-level encryption (TDE) protects against storage theft but not application-layer leaks.

### Secrets Management

- Never hardcode secrets or store them in environment variables in CI logs.
- Use a secrets manager (Vault, AWS Secrets Manager, GCP Secret Manager).
- Short-lived, dynamically generated secrets are better than static long-lived secrets.
- Audit all secret access.

## Security Checklist for Production

**Authentication:**
- Use bcrypt or scrypt for password hashing (never MD5, SHA1, or unsalted hashes).
- Implement account lockout after N failed attempts.
- Use refresh tokens with JWT; never issue access tokens with lifetime > 24 hours.
- Implement logout (token blacklist for high-security apps).

**Authorization:**
- Check permissions on every request — never trust client-side checks.
- Apply least privilege: each service/user gets only the permissions it needs.
- Log all authorization failures. Alert on unusual patterns.

**Communication:**
- HTTPS only. HSTS preload for user-facing domains.
- Validate and sanitize ALL inputs (SQL injection, XSS, command injection).
- Set CORS to specific origins only.
- Rate-limit authentication endpoints aggressively.
- Set `Content-Security-Policy` headers.

**Data Protection:**
- Encrypt sensitive data at rest. Encrypt PII at the application layer.
- Never log passwords, tokens, secrets, or PII.
- Use parameterized queries everywhere.
- Implement audit logging with immutable, append-only storage.
- Run security scanning in CI (SAST, dependency scanning, secrets scanning).

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/api-management|API Management]]
- Source: [[sources/latency-gambler-day-20|Security Patterns]]
- Source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
- Source: [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]]
- Source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
