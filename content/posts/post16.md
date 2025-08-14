---
title: "The 10 Most Common Software Vulnerabilities (and How to Prevent Them)"
date: 2025-04-20T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Attacks", "SQL Injection", "XSS", "Cross Site Forgery", "Vulnerabilities"]
author: "Me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "The 10 Most Common Software Vulnerabilities (and How to Prevent Them)"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---
# The 10 Most Common Software Vulnerabilities (and How to Prevent Them)

Shipping fast is great. Shipping safely is essential. This guide walks through ten high‑impact vulnerabilities developers see again and again (think SQL injection, XSS, and friends), with practical examples and prevention tips you can apply today.

These closely align with the OWASP Top 10 and are written for intermediate developers who want clear, actionable guidance.

---

## 1) Injection (SQL/NoSQL/Command)

What it is: Untrusted input ends up as executable code or commands. Variants include SQL, NoSQL, OS command, LDAP, and template injection.

Why it happens: Concatenating input into queries/commands; using the shell when an API exists.

Impact: Data theft/modification, remote code execution (RCE), full system compromise.

Example (SQL injection – vulnerable)
```python
# BAD: string interpolation into SQL
email = request.args["email"]
sql = f"SELECT * FROM users WHERE email = '{email}'"
cursor.execute(sql)  # attacker can close quote and inject
```

Prevention
- Use parameterized queries/prepared statements everywhere.
- Use high‑level APIs/ORMs that parameterize by default.
- For OS operations, avoid shelling out; use safe library calls.
- Enforce least‑privilege DB accounts (no DROP/ALTER if not needed).
- Validate and allowlist where possible (e.g., expected enums).

Example (parameterized query)
```python
# GOOD: parameterized query
email = request.args["email"]
cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
```

Command injection prevention
```js
// BAD: user input in shell command
// exec(`convert ${userFile} output.png`)

// GOOD: use library APIs with arguments, not shell
const { spawn } = require('child_process');
spawn('convert', [userFile, 'output.png'], { stdio: 'ignore' });
```

---

## 2) Cross-Site Scripting (XSS)

What it is: Attacker injects scripts into pages viewed by other users (stored, reflected, or DOM-based).

Why it happens: Treating user input as HTML/JS without proper output encoding or sanitization.

Impact: Session theft, account takeover, defacement, credential grabbing.

Prevention
- Output encoding per context (HTML, attribute, URL, JS). Most server-side templates do this by default.
- Sanitize untrusted HTML with a robust library (e.g., DOMPurify) before insertion.
- Avoid unsafe sinks (innerHTML, dangerouslySetInnerHTML) unless sanitized.
- Set a strong Content Security Policy (CSP) as defense in depth.
- Use HttpOnly cookies so JS can’t read them; consider SameSite to mitigate CSRF.

Example
```js
// Sanitizing untrusted HTML before inserting into DOM
import DOMPurify from 'dompurify';

const unsafe = userProvidedHtml;
const safe = DOMPurify.sanitize(unsafe);
document.getElementById('comment').innerHTML = safe;
```

CSP example (baseline)
```
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'
```

---

## 3) Broken Access Control (incl. IDOR)

What it is: Users can act outside their privileges (viewing/altering others’ data, bypassing admin-only actions). IDOR = Insecure Direct Object Reference.

Why it happens: Missing or inconsistent checks on the server.

Impact: Data leaks, unauthorized actions.

Prevention
- Enforce authorization on the server for every operation.
- Check object ownership on every object access (not just list endpoints).
- Use policy/permission layers (RBAC/ABAC) consistently.
- Avoid exposing sequential IDs; use UUIDs where helpful (but never as a substitute for checks).
- Protect against mass assignment by allowlisting fields.

Example
```js
// Verify ownership on object read
app.get('/invoices/:id', requireAuth, async (req, res) => {
  const invoice = await Invoice.findById(req.params.id);
  if (!invoice || invoice.ownerId !== req.user.id) return res.sendStatus(404);
  res.json(invoice);
});

// Prevent mass assignment
const allowed = (({ name, email }) => ({ name, email }))(req.body);
await User.update(req.user.id, allowed);
```

---

## 4) Identification & Authentication Failures

What it is: Weak login, poor session handling, insecure password storage, missing MFA, predictable resets.

Impact: Account takeover, lateral movement.

Prevention
- Hash passwords using a modern, adaptive KDF (Argon2id, bcrypt, or scrypt).
- Enforce MFA for sensitive actions.
- Implement login rate limiting and lockouts (with safe UX).
- Use secure session cookies: HttpOnly, Secure, SameSite=Lax/Strict; regenerate on login.
- For JWTs: use short expirations, rotate/refresh securely, and maintain a revocation strategy.

Example
```js
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(plainPassword, 12);
const ok = await bcrypt.compare(inputPassword, hash);

res.cookie('sid', sessionId, {
  httpOnly: true, secure: true, sameSite: 'Lax', path: '/', maxAge: 60*60*1000
});
```

CSRF note
- Use anti-CSRF tokens on state-changing requests.
- Prefer SameSite cookies; still keep CSRF tokens for robust protection.

---

## 5) Cryptographic Failures (Sensitive Data Exposure)

What it is: Data is exposed due to missing or broken crypto (no TLS, weak ciphers, homegrown crypto, keys in code).

Impact: Credential theft, privacy violations, compliance issues.

Prevention
- Always use TLS (HTTPS) in transit; HSTS to enforce it.
- Use vetted libraries and AEAD modes (AES‑GCM/ChaCha20‑Poly1305).
- Never roll your own crypto; avoid outdated algorithms (MD5, SHA‑1, RC4).
- Manage secrets via a vault (e.g., cloud KMS, HashiCorp Vault), not in code or repo.
- Enable encryption at rest where supported; rotate keys regularly.

Example (Node: AES‑GCM via crypto)
```js
import { randomBytes, createCipheriv, createDecipheriv } from 'crypto';
const key = /* 32-byte key from KMS or env */;
const iv = randomBytes(12);
const cipher = createCipheriv('aes-256-gcm', key, iv);
let enc = Buffer.concat([cipher.update(plaintext), cipher.final()]);
const tag = cipher.getAuthTag();
// store { iv, enc, tag }
```

---

## 6) Security Misconfiguration

What it is: Insecure defaults, verbose errors, open S3 buckets, overly permissive CORS, missing headers, debug enabled in prod.

Impact: Information disclosure, easy exploitation of other bugs.

Prevention
- Treat configuration as code (IaC) and scan it (e.g., Checkov, tfsec).
- Harden defaults: disable directory listing, turn off debug, restrict CORS.
- Set common security headers (CSP, X-Content-Type-Options, X-Frame-Options/FRAME-ANCESTORS, Referrer-Policy).
- Keep prod/staging/dev isolated; least-privilege IAM.
- Container hardening: minimal base images, drop capabilities, read-only FS where possible.

Example (Express hardening)
```js
import helmet from 'helmet';
import cors from 'cors';

app.use(helmet());
app.use(cors({ origin: ['https://app.example.com'], methods: ['GET','POST'], credentials: true }));
```

---

## 7) Vulnerable and Outdated Components

What it is: Using libraries, frameworks, or runtimes with known vulnerabilities.

Impact: Anything the vulnerable component can do—often full compromise.

Prevention
- Maintain a dependency update cadence; prefer smaller, actively maintained libs.
- Use Software Composition Analysis (SCA) in CI (e.g., Dependabot, npm audit, pip-audit, osv-scanner).
- Pin versions/lockfiles; track SBOMs (CycloneDX, SPDX).
- Remove unused dependencies.

Example (CI snippet)
```yaml
# GitHub Actions: scan Node and Python deps
jobs:
  deps-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci && npm audit --audit-level=high
      - uses: actions/setup-python@v5
      - run: pip install pip-audit && pip-audit -l
```

---

## 8) Software & Data Integrity Failures (incl. Insecure Deserialization, Supply Chain)

What it is: Trusting unverified updates, CI artifacts, or serialized data. Insecure deserialization can lead to RCE.

Impact: Build system compromise, backdoored releases, remote code execution.

Prevention
- Verify signatures/checksums on dependencies and artifacts.
- Enforce signed commits/tags and protected branches; track provenance (SLSA).
- Lock down CI secrets; prevent untrusted PRs from running privileged workflows.
- Do not deserialize untrusted data; use safe formats (JSON) or strict schemas.

Example (avoid pickle; use JSON/schemas)
```python
# BAD: arbitrary code execution risk
# obj = pickle.loads(untrusted_input)

# GOOD: safe parsing with schema validation
from pydantic import BaseModel, ValidationError

class User(BaseModel):
    id: int
    name: str

user = User.model_validate_json(untrusted_input)
```

---

## 9) Insufficient Logging & Monitoring

What it is: Missing or poor logs and alerts; attacks go unnoticed.

Impact: Delayed detection, longer dwell time, harder forensics.

Prevention
- Log security‑relevant events: logins, privilege changes, data exports, errors.
- Use structured, centralized logging with retention and tamper resistance.
- Monitor with alerts on anomalies (e.g., excessive 401/403, new admin grants).
- Be privacy‑aware: avoid sensitive data in logs; tokenize where needed.

Example (structured logging)
```js
import pino from 'pino';
const logger = pino();

logger.info({ userId, action: 'login_success' }, 'User login');
logger.warn({ ip, path }, 'Excessive 401s from IP');
```

---

## 10) Server-Side Request Forgery (SSRF)

What it is: Server fetches a URL supplied by the user (webhooks, import-by-URL), allowing attackers to pivot into internal networks or cloud metadata services.

Impact: Access internal services, steal credentials/tokens, scan ports.

Prevention
- Default-deny outbound HTTP; allowlist specific domains/paths.
- Block private and link-local IP ranges (127.0.0.0/8, 10.0.0.0/8, 169.254.169.254, ::1, etc.).
- Resolve DNS safely and re-verify after redirects; prefer outbound proxies.
- Short timeouts, small response limits; strip credentials from URLs.
- In cloud, use IMDSv2 (AWS) and block metadata endpoints from app networks.

Example (basic allowlist)
```js
import { URL } from 'url';
import dns from 'dns/promises';
import net from 'net';

const ALLOWED_HOSTS = new Set(['api.example.com']);

async function isSafe(urlStr) {
  const u = new URL(urlStr);
  if (!ALLOWED_HOSTS.has(u.hostname)) return false;
  const addrs = await dns.lookup(u.hostname, { all: true });
  return addrs.every(a => !isPrivate(a.address));
}

function isPrivate(ip) {
  // naive check: block RFC1918, loopback, link-local, etc.
  return /^(10\.|127\.|192\.168\.|169\.254\.)/.test(ip) || ip.startsWith('::1');
}
```

---

## How to Bake Security into Your SDLC

- Threat model early: identify assets, entry points, trust boundaries, and abuse cases.
- Coding standards: adopt security guidelines and linters for your stack.
- Testing:
  - SAST for code (e.g., Semgrep).
  - DAST for running apps.
  - IAST/Runtime protection where applicable.
  - Fuzz testing for parsers/critical endpoints.
- Reviews: security checklists in PRs; pair on risky changes.
- Secrets hygiene: pre-commit hooks and CI scanning (e.g., gitleaks).
- Least privilege: minimize permissions for services, databases, and CI.
- Patch cadence: routine dependency and platform updates.
- Incident readiness: playbooks, alerting, and log retention tested in drills.

---

## Quick Checklist

- Inputs are treated as data, not code (parameterized queries, safe APIs).
- Output is contextually encoded; CSP and security headers are set.
- Auth is robust (MFA, password hashing) and sessions are secure.
- Authorization is enforced on every request and object.
- Crypto uses modern libraries and managed keys.
- Config is hardened; environments and permissions are isolated.
- Dependencies are scanned, pinned, and updated.
- Builds, updates, and data formats are verified and trusted.
- Logging is structured, centralized, and monitored.
- Outbound network is restricted; SSRF defenses in place.

Security is a practice, not a destination. Start with the highest-risk areas in your codebase, automate what you can, and iterate. OWASP resources (Top 10, ASVS, Cheat Sheets) are excellent companions as you harden your applications.