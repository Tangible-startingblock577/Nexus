# Security Policy

**NEXUS** takes security seriously. As a platform designed to run locally on your own hardware, we prioritize privacy, data sovereignty, and secure defaults.

---

## Supported Versions

| Version | Supported |
|---|---|
| Latest release | ✅ Active development |
| Previous releases | ❌ Not supported |

At this stage, NEXUS is under active development and not yet publicly released. Only the latest version of the codebase receives security updates.

---

## Vulnerability Disclosure Policy

If you discover a security vulnerability in NEXUS, we appreciate your help in disclosing it responsibly.

### What to Report

We are interested in any security issue that could affect the confidentiality, integrity, or availability of NEXUS, including:

- Remote code execution
- Authentication bypass or session hijacking
- Data exposure (unintended access to user data, tokens, or encryption keys)
- Cross-site scripting (XSS) or injection vulnerabilities
- Insecure direct object references
- Server-Side Request Forgery (SSRF)
- Cryptographically weak implementations

### What NOT to Report

- Features that are intentionally local-only and require physical machine access to exploit (the threat model assumes the attacker already has local access)
- Missing HTTP security headers (NEXUS is designed for local network deployment)
- Rate limiting concerns for local-only deployments
- Self-XSS (requires user to paste malicious input themselves)

### How to Report

**Please do not open public GitHub issues for security vulnerabilities.**

Instead, report security issues via email to the maintainers:

- **Email:** security@saarlabs.in
- **Response time:** We will acknowledge receipt within 48 hours
- **Disclosure timeline:** We aim to issue a fix within 14 days of confirmation

### Disclosure Process

1. **Report:** You send a detailed report to security@saarlabs.in
2. **Acknowledgment:** We confirm receipt within 48 hours
3. **Investigation:** We investigate and confirm the vulnerability
4. **Fix:** We develop and deploy a fix
5. **Release:** We publish a fix and credit the reporter (if desired)
6. **Public disclosure:** After the fix is released, we coordinate public disclosure

---

## Security Architecture

### Local-First Security Model

NEXUS is built on a **local-first architecture**. This is the foundation of our security model:

- **All data stays on your hardware** — SQLite databases, uploaded files, conversation history, and the context graph live on your machine. No data is transmitted to external servers.
- **No telemetry** — NEXUS does not phone home. There are no analytics, crash reports, or usage data sent anywhere.
- **Air-gap capable** — With local LLMs (Ollama) and web search disabled (`DISABLE_WEB_SEARCH=true`), NEXUS requires zero network connectivity.

> **The most secure way to run NEXUS is self-hosted with Ollama, fully air-gapped.** When you run everything locally, there is no data to intercept, no server to breach, and no third-party to trust.

### Encryption at Rest

All sensitive tokens (Slack bot tokens, webhook URLs, OAuth tokens) are encrypted at rest using **AES-256-GCM**.

See `server/src/services/encryption.ts` for the implementation:

- **Algorithm:** AES-256-GCM (Authenticated Encryption with Associated Data)
- **Key derivation:** SHA-256 hash of `NEXUS_ENCRYPTION_KEY` environment variable
- **IV:** Random 128-bit (16 byte) initialization vector per encryption
- **Format:** `enc:<base64 iv>.<base64 authTag>.<base64 ciphertext>`
- **Idempotent:** Encrypting an already-encrypted value returns it unchanged
- **Graceful degradation:** If decryption fails (e.g., corrupted data, key change), the raw value is returned rather than crashing

**For production use, always set a strong `NEXUS_ENCRYPTION_KEY`:**

```bash
openssl rand -hex 32
# Add to .env: NEXUS_ENCRYPTION_KEY=<output>
```

Without this key, the system falls back to a deterministic key derived from a static string. This prevents casual DB-reading attacks but is not cryptographically secure for production.

### Authentication

Authentication is implemented in `server/src/services/auth.ts`:

- **Password hashing:** `Bun.password.hash()` with bcrypt algorithm, cost factor 10
- **Session tokens:** `crypto.randomUUID()` — 128-bit random tokens stored server-side
- **Session expiry:** 7 days after creation
- **OAuth:** Google and GitHub OAuth 2.0 — tokens exchanged server-side, never exposed to the client
- **Password reset:** 6-digit numeric code + UUID, valid for 1 hour, single-use
- **Account enumeration protection:** Password reset endpoints return the same response regardless of whether the email exists

### Slack Integration Security

The OpenClaw bridge and Slack integration implement multiple security layers:

- **API key authentication:** All bridge endpoints require the `X-Nexus-Api-Key` header matching `NEXUS_OPENCLAW_API_KEY`
- **HMAC-SHA256 verification:** Slack slash commands (`/nexus`) are verified using `SLACK_SIGNING_SECRET` with anti-replay protection (5-minute timestamp window)
- **Encrypted storage:** All Slack bot tokens and webhook URLs are encrypted at rest via AES-256-GCM
- **OAuth isolation:** Slack OAuth tokens are exchanged server-side and immediately encrypted. The client never sees raw tokens
- **Multi-workspace isolation:** Each NEXUS user connects their own Slack workspace independently

---

## Best Practices for Self-Hosting

### Environment Variables

| Variable | Purpose | Recommendation |
|---|---|---|
| `NEXUS_ENCRYPTION_KEY` | AES-256-GCM encryption key | **Required for production.** Generate with `openssl rand -hex 32` |
| `NEXUS_OPENCLAW_API_KEY` | Bridge authentication | **Required for Slack integration.** Generate with `openssl rand -hex 32` |
| `SLACK_SIGNING_SECRET` | Slash command verification | **Required for Slack integration.** Copy from Slack App settings |
| `DISABLE_WEB_SEARCH` | Disable web search | Set to `true` for fully air-gapped operation |

### File System Security

- Ensure the `nexus.db` SQLite database file is **not publicly accessible** via your web server
- The `server/data/` directory contains local data files — keep it outside the web root
- Uploaded files in storage should be served through the API, not directly from disk

### Network Security

- When running NEXUS on a local network, use a firewall to restrict access to trusted devices
- For production deployments, run NEXUS behind a reverse proxy (nginx, Caddy) with TLS
- The server listens on port `3001` by default — configure `PORT` in your `.env`
- OAuth callbacks should use HTTPS in production

### Database Security

- NEXUS uses **SQLite by default** — the database file is local and not exposed over the network
- If using Supabase pgvector for vector embeddings, ensure your Supabase credentials are kept secure and use row-level security policies
- The `SUPABASE_SERVICE_ROLE_KEY` has full access to your Supabase project — **never expose it to the client**

### Dependency Management

- Before adding a new npm/Bun dependency, audit it for known vulnerabilities
- Run `npm audit` or `bun audit` periodically on the server and client
- Pin dependency versions in `package.json` to prevent unexpected updates

---

## Data Protection Guidelines

### What NEXUS Stores Locally

- **Conversation history:** User messages and agent responses (SQLite)
- **Context graph:** User profile, preferences, past agent interactions (SQLite + vector embeddings)
- **Uploaded files:** Documents, images, and other files uploaded by users (local file storage)
- **Session tokens:** Authentication tokens (SQLite, hashed server-side)
- **OAuth tokens:** Slack, Google, GitHub tokens (encrypted at rest)

### What NEXUS Does NOT Store or Transmit

- ❌ No telemetry or analytics data
- ❌ No usage statistics sent externally
- ❌ No crash reports sent to third parties
- ❌ No user data written to server logs (only metadata like timestamps and error codes)
- ❌ No API keys logged in plaintext

### Logging Policy

- Server logs contain only metadata: timestamps, route names, error codes, agent names
- **User messages, uploaded file contents, and conversation data are never written to logs**
- Debug logs should never include sensitive tokens or secrets

---

## Incident Response

If you suspect your NEXUS instance has been compromised:

1. **Disconnect the machine from the network** — stop any external connections
2. **Rotate all secrets** — change `NEXUS_ENCRYPTION_KEY`, `NEXUS_OPENCLAW_API_KEY`, OAuth client secrets
3. **Rotate Slack tokens** — regenerate Slack bot tokens from the Slack API dashboard
4. **Reset user sessions** — delete the `nexus.db` sessions table or restart with fresh databases
5. **Audit logs** — check server logs for any suspicious activity
6. **Report** — contact security@saarlabs.in if you believe the vulnerability is in NEXUS code itself

---

## Dependency Vulnerability Reporting

If you discover a vulnerability in a dependency used by NEXUS:

1. Check if the dependency already has a fix available
2. If a fix exists, update the dependency and submit a PR
3. If no fix exists, report the vulnerability to the dependency maintainer
4. For critical dependencies with no fix available, contact security@saarlabs.in for assistance

---

## Contact

- **Security issues:** security@saarlabs.in
- **General inquiries:** hello@saarlabs.in
- **Primary maintainer:** Saar Labs

---

<p align="center">
  <strong>NEXUS</strong> — Run it anywhere. Own everything. Trust nothing but your own hardware.<br />
  <em>Built by Saar Labs</em>
</p>
