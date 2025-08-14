---
title: "Security, Security and... Security"
date: 2025-04-13T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["SSL", "PGP", "OpenSSL", "RBAC" ]
author: "Me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Practical Security for Developers: A Field Guide"
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
Practical Security for Developers: A Field Guide
================================================

Security is a broad, moving target. This guide focuses on core concepts you’ll actually use: keys, hashes, signatures, certificates, TLS/SSL, authentication and authorization (including OAuth), firewalls, and practical tooling with OpenSSL and PGP. It’s aimed at intermediate developers who build and operate networked applications.

Contents
- Security fundamentals (CIA, threat model)
- Cryptography building blocks
- Symmetric keys and ciphers
- Public-key cryptography
- Hashing and HMAC
- Digital signatures
- Digital certificates, Root CAs, and the chain of trust
- SSL/TLS and the TLS handshake
- Secure network protocols
- Authentication vs Authorization (OAuth, OIDC, RBAC)
- Firewalls and network security
- PGP and the web of trust
- Key management and secret handling
- Threats and mitigations
- OpenSSL and GPG quick recipes
- Checklists and common pitfalls

Security fundamentals
---------------------

- CIA triad:
  - Confidentiality: prevent unauthorized disclosure (encryption).
  - Integrity: prevent unauthorized modification (MACs, signatures).
  - Availability: keep systems usable (redundancy, rate limits, DDoS protection).
- Threat modeling: identify assets, adversaries, entry points, trust boundaries, and mitigations (STRIDE: Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation).

Cryptography building blocks
----------------------------

- Randomness: Use cryptographically secure RNGs for keys/nonces (e.g., /dev/urandom, crypto libraries).
- Keys: Symmetric (one key) vs Asymmetric (public/private pair).
- Primitives:
  - Encryption: confidentiality.
  - MAC/HMAC: integrity with shared secret.
  - Signatures: integrity + origin with private key.
  - Hash: fixed-size digest; no secret.

Symmetric keys (how they work)
------------------------------

- You and the recipient share the same secret key.
- Fast and suitable for bulk data; used inside TLS after key exchange.

Common algorithms/modes:
- AES-GCM (recommended): authenticated encryption (AEAD) with built-in integrity.
- AES-CTR (stream): requires separate MAC (e.g., HMAC).
- AES-CBC: legacy; avoid unless you add an HMAC and understand padding/oracles.
- ChaCha20-Poly1305: fast, great on mobile/low-CPU.

Key points:
- Never reuse a nonce/IV with the same key (GCM, CTR).
- Use high-level AEAD modes (GCM, ChaCha20-Poly1305).
- Rotate keys periodically; separate keys per purpose/environment.

Example (concept):
- Encrypt with AES-GCM using a random 96-bit nonce; output is nonce + ciphertext + tag.

Public-key cryptography (how it works)
--------------------------------------

- You publish a public key; keep the private key secret.
- Use cases:
  - Key exchange (ECDH/DH) to derive a shared symmetric key.
  - Digital signatures (RSA/ECDSA/Ed25519).
  - Encryption to a public key (RSA-OAEP, ECIES).

Algorithms:
- RSA (2048 or 3072-bit typical).
- ECDSA/ECDH (P-256/P-384).
- Ed25519 (signatures) and X25519 (key exchange): modern, fast, safe defaults.

Hybrid crypto:
- Combine public-key and symmetric crypto: negotiate a symmetric key via ECDH, then encrypt bulk data with AES-GCM/ChaCha20.

Hashing and HMAC
----------------

Hash functions:
- Map any input to a fixed-length digest.
- Properties: preimage resistance, second-preimage resistance, collision resistance.

Use cases:
- Integrity checks, content addressing, signatures (hashed first), password storage (with KDFs).

Algorithms:
- SHA-256/384/512 are standard for general hashing.
- Avoid MD5 and SHA-1.

HMAC (Hash-based MAC):
- Integrity/authenticity with a shared secret.
- HMAC-SHA256 is widely used (e.g., API request signing).

Password hashing (different from general hashing):
- Use Argon2id (preferred), scrypt, or bcrypt.
- Salt every password (random, per-user); optionally add a server-side pepper.

Digital signatures
------------------

- Sign with private key; verify with public key.
- Guarantees: integrity + origin authenticity; non-repudiation in some contexts.
- Algorithms: RSA-PSS, ECDSA (P-256), Ed25519.

Example flow:
- hash = SHA-256(message)
- signature = Sign(private_key, hash)
- is_valid = Verify(public_key, hash, signature)

Digital certificates, Root CAs, and the chain of trust
------------------------------------------------------

- Certificates (X.509) bind a public key to a subject (domain, org) and are signed by a Certificate Authority (CA).
- A client trusts roots preinstalled by OS/browser vendors, and trusts any certificate that chains up to a trusted root.

Chain of Trust (diagram):

  [Root CA (self-signed)]
                |
            signs
                v
  [Intermediate CA (A)]
                |
            signs
                v
  [Server Certificate (example.com)]

- Servers present the leaf (and typically intermediates). Clients use their root store to validate the chain.
- Important fields: Subject Alternative Name (SAN), Key Usage, Extended Key Usage (e.g., serverAuth).
- Revocation: CRLs and OCSP; OCSP stapling reduces privacy and latency issues.

SSL/TLS and the TLS handshake
-----------------------------

- SSL is obsolete; use TLS (1.2+; ideally 1.3).
- Goals:
  - Confidentiality: encrypt records with symmetric ciphers.
  - Integrity: AEAD modes (GCM/ChaCha20-Poly1305).
  - Authentication: server (always) and optional client (mTLS).
  - Perfect Forward Secrecy: ephemeral keys (ECDHE).

TLS 1.3 Handshake (simplified):

Client                              Server
  |---- ClientHello (SNI, ALPN, KeyShare) ---->|
  |<--- ServerHello (KeyShare) ----------------|
  |<--- EncryptedExtensions, Certificate ------|
  |<--- CertificateVerify, Finished -----------|
  |---- Finished ------------------------------>|
  |==== Encrypted application data both ways ===|

Key points:
- Single round-trip; ECDHE for forward secrecy.
- Session resumption and 0-RTT available (beware replay with 0-RTT).
- ALPN negotiates protocols (e.g., h2, http/1.1); SNI indicates target hostname.
- Disable weak ciphers; prefer TLS 1.3 or TLS 1.2 with ECDHE and AES-GCM/ChaCha20.

Secure network protocols
------------------------

- HTTPS: HTTP over TLS.
- HTTP/3: QUIC + TLS 1.3 (in UDP).
- SMTP, IMAP, POP3: use STARTTLS or implicit TLS.
- MQTT over TLS for IoT; gRPC over TLS for microservices.
- SSH: secure remote shell and tunneling (separate from TLS).
- IPsec: network-layer encryption; mTLS: mutual TLS identities between services.
- DNS privacy: DoT (DNS over TLS), DoH (DNS over HTTPS).

Authentication vs Authorization
-------------------------------

- Authentication (AuthN): who you are (password, MFA, passkey).
- Authorization (AuthZ): what you can do (roles, attributes, policies).

Authentication
- Passwords: use strong policy with breach checks; store with Argon2/bcrypt.
- MFA: TOTP, push, FIDO2/WebAuthn passkeys (phishing-resistant).
- Sessions: use HttpOnly, Secure, SameSite cookies; rotate on privilege change.

Authorization
- RBAC: roles map to permissions. Keep it least-privilege and scoped.
- ABAC: decisions based on attributes (user, resource, context).
- ReBAC: relationship-based (e.g., “editor of this document”).

Tokens and JWTs
- Access tokens (AuthZ) vs ID tokens (identity in OIDC).
- Validate iss, aud, exp, nbf; verify signature; apply clock skew; constrain scopes.
- Don’t put secrets/PII in JWT payloads; short TTL; rotate signing keys (kid, JWKS).

OAuth 2.0 and OpenID Connect (OIDC)
-----------------------------------

- OAuth 2.0: delegated authorization (grant access to resources without sharing passwords).
- OIDC: identity layer on top of OAuth 2.0, provides ID tokens.

Common OAuth flows
- Authorization Code with PKCE: recommended for SPAs/native apps.
- Client Credentials: machine-to-machine.
- Device Code: devices without browsers.

Authorization Code with PKCE (diagram):

 Browser/User         Client (App)        Auth Server           Resource API
     |                     |                   |                      |
     |  Login + Consent    |   code + verif    |                      |
     |---> authorize ------>                   |                      |
     |                     |<----- code -------|                      |
     |                     |  code, code_ver   |                      |
     |                     |---- token -------->|                      |
     |                     |<--- tokens -------|                      |
     |                     |-- access token -------------------------> |
     |                     |                   | <-- protected data -- |

Notes:
- PKCE mitigates code interception (code_verifier/code_challenge).
- Use https-only redirects; rotate/refresh tokens securely; store tokens in secure cookies for web.

Firewalls and network security
------------------------------

- L3/L4 firewalls: filter by IP, port, protocol (e.g., cloud Security Groups, iptables). Prefer deny-by-default.
- Stateful vs stateless: stateful tracks connections and allows related return traffic.
- L7 firewalls/WAFs: inspect HTTP semantics; block OWASP Top 10, bots.
- Egress filtering: restrict outbound traffic to reduce data exfiltration.
- Network segmentation: isolate tiers (public, app, data), use private subnets.
- Zero Trust: authenticate and authorize every request; mTLS between services; device posture.

PGP (OpenPGP) and the web of trust
----------------------------------

- PGP secures email/files with public-key crypto; differs from X.509/CA model.
- Users exchange keys and build “web of trust” through signatures rather than relying on CAs.
- Common tools: GnuPG (gpg), key servers; use for encrypted email or file signing.

OpenSSL (library and CLI)
-------------------------

OpenSSL is both:
- A widely used crypto/TLS library (libcrypto/libssl).
- A CLI toolkit for keys, CSRs, certs, hashing, and TLS diagnostics.

Useful OpenSSL commands
- Generate random key material:
  - openssl rand -hex 32
- Generate RSA/ECC private keys:
  - openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -out rsa.key
  - openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out ecdsa.key
- View key parameters:
  - openssl pkey -in ecdsa.key -text -noout
- Create a CSR:
  - openssl req -new -key ecdsa.key -out server.csr -subj "/CN=example.com"
    - Prefer SANs via a config file; CN alone is not enough.
- Self-signed certificate (for dev):
  - openssl req -x509 -new -nodes -key ecdsa.key -days 365 -out server.crt -subj "/CN=localhost"
- Inspect a server’s TLS config:
  - openssl s_client -connect example.com:443 -servername example.com -tls1_3 -showcerts
- Verify a certificate chain:
  - openssl verify -CAfile chain.pem server.crt
- File hashing and HMAC:
  - openssl dgst -sha256 file.bin
  - openssl dgst -sha256 -hmac "secret" file.bin
- Sign and verify data:
  - openssl dgst -sha256 -sign ecdsa.key -out msg.sig message.txt
  - openssl dgst -sha256 -verify <(openssl pkey -in ecdsa.key -pubout) -signature msg.sig message.txt

TLS/SSL handshake deep dive
---------------------------

Where the pieces fit:
- Key exchange: ECDHE (X25519/P-256) derives a shared secret.
- Authentication: server proves identity via X.509 certificate and signature.
- Symmetric keys: derived keys encrypt records (AES-GCM/ChaCha20).
- Integrity: AEAD tags prevent tampering.

Handshake pitfalls and best practices:
- Prefer TLS 1.3; else TLS 1.2 with ECDHE and AES-GCM.
- Enable OCSP stapling; use modern curves (X25519, P-256).
- Use strong DH params if using (at least 2048-bit); avoid static RSA key exchange.
- Implement HSTS; consider certificate pinning where appropriate (mobile apps, internal services).

Key management and secret handling
----------------------------------

- Storage: use a secrets manager (AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault).
- KMS/HSM: store master keys in KMS/HSM; use envelope encryption for data.
- Rotation: plan rotation for keys and tokens; version secrets; short-lived credentials.
- Access control: least privilege with RBAC; audit actions.
- Don’t commit secrets to version control; monitor with secret scanners.
- Environment separation: different keys per environment; deny cross-environment access.

Threats and mitigations
-----------------------

- MITM: enforce TLS, HSTS; verify hostnames; consider pinning in high-security contexts.
- Replay: use nonces/timestamps; rely on TLS; disable 0-RTT where unsafe.
- Downgrade: disable old protocols/ciphers; use TLS_FALLBACK_SCSV; set minimum TLS 1.2/1.3.
- CSRF: SameSite cookies, CSRF tokens; use Authorization header for APIs.
- XSS: output encoding, CSP, input validation.
- SQLi: parameterized queries; ORM safe APIs.
- SSRF: strict egress filtering, metadata protection, allowlists.
- Logging: avoid secrets; structured logs; tamper-evident storage; rate-limit sensitive endpoints.

Secure network protocol principles
----------------------------------

- Identity: prove who is talking (certificates, SSH keys, OIDC).
- Key agreement: ephemeral key exchange for forward secrecy.
- Confidentiality/integrity: AEAD ciphers; replay protection.
- Negotiation safety: avoid downgrade; explicit version and ciphersuite policies.
- Robustness: timeouts, rate limits, graceful failure; constant-time crypto operations.

RBAC in practice
----------------

- Model roles by bounded responsibilities (reader, contributor, admin).
- Map API permissions to fine-grained privileges; bind roles to principals (users, services).
- Support resource scoping (per project/tenant) to avoid global roles.
- Periodically review roles and access (access recertification).

PGP quick usage
---------------

- Generate a key: gpg --quick-generate-key "Your Name <you@example.com>" ed25519 sign 1y
- List keys: gpg --list-keys
- Export public key: gpg --armor --export you@example.com > pubkey.asc
- Encrypt to someone: gpg --encrypt --sign --armor -r recipient@example.com file.txt
- Decrypt: gpg --decrypt file.txt.asc

Diagrams
--------

Chain of Trust:

  [Root CA (self-signed)]
                |
             signs
                v
  [Intermediate CA]
                |
             signs
                v
  [Server Cert: example.com]
                |
          presented to
                v
         [Client validates]
        (builds chain using
         local root store)

TLS 1.3 Handshake (simplified):

 ClientHello(SNI, ALPN, KeyShare) --->
 <--- ServerHello(KeyShare)
 <--- EncryptedExtensions, Certificate
 <--- CertificateVerify, Finished
 Finished --->
 [both sides derive keys]
 <=== encrypted application data ===>

OAuth 2.0 Authorization Code with PKCE:

  SPA/Native App        Authorization Server            Resource Server
       |   code_challenge, redirect_uri, scope               |
       |-------- /authorize -------------------------------> |
       | <----- redirect with code ------------------------- |
       |-- /token: code + code_verifier ------------------> |
       | <----------- access_token (+ id_token) ----------- |
       |----------------- Authorization: Bearer ----------> |
       | <---------------- protected resource ------------- |

Practical checklists
--------------------

TLS server checklist
- Use TLS 1.3 (or 1.2 with ECDHE + AES-GCM/ChaCha20).
- Use modern certs: SANs, 2048+ RSA or ECDSA P-256/EdDSA.
- Enable OCSP stapling; serve full chain; correct SNI.
- Disable weak ciphers/protocols (no SSLv3/TLS 1.0/1.1; no RC4/3DES).
- Use HSTS; consider HTTP/2 or HTTP/3; enable ALPN.
- Automate renewals (e.g., ACME/Let’s Encrypt).

AuthN/AuthZ checklist
- Store passwords with Argon2/bcrypt; require MFA.
- Use OAuth 2.0 with Authorization Code + PKCE; use OIDC for login.
- Validate JWTs strictly; short TTL; rotate keys; narrow scopes.
- Implement RBAC with least privilege; audit and rotate credentials.

Common pitfalls
- Rolling your own crypto; use vetted libraries.
- Reusing nonces/IVs in AEAD modes.
- Trusting CN instead of SAN; misconfigured chains.
- Long-lived static access tokens; storing tokens in localStorage (XSS risk).
- Logging secrets or tokens.
- Treating TLS as “set and forget”; failing to rotate/renew certs.

Code snippets
-------------

Python HMAC example:

```python
import hmac, hashlib

secret = b'super-secret'
message = b'important-payload'

tag = hmac.new(secret, message, hashlib.sha256).hexdigest()

# Verification
def verify(msg, t):
    expected = hmac.new(secret, msg, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, t)

assert verify(message, tag)
```

OpenSSL: simple local TLS test (self-signed; for dev only)

- Generate a self-signed cert:
  - openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 -subj "/CN=localhost"
- Start a TLS server:
  - openssl s_server -key key.pem -cert cert.pem -accept 8443
- Connect as a client:
  - openssl s_client -connect 127.0.0.1:8443 -servername localhost

Final thoughts
--------------

Security is a system property. Strong cryptography won’t save a leaky deployment, and perfect auth won’t help if your keys are exposed. Start with threat modeling, use well-known protocols and libraries, layer defenses (defense in depth), and automate what you can: cert renewals, key rotations, dependency checks, and security tests.

Further learning
- OWASP ASVS and Top 10
- IETF RFCs: TLS 1.3 (RFC 8446), OIDC, OAuth 2.1 drafts
- Mozilla SSL/TLS configuration generator
- NIST SP 800-63 (Digital Identity), SP 800-56/57 (key management)