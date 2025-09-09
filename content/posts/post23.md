---
title: "Identity and Federation"
date: 2025-06-08T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Identity", "Federation", "SSO"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Identity and Federation"
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
# Identity and Federation: A Practical Guide for Developers

Identity and federation sit at the heart of modern authentication and Single Sign-On (SSO). Whether you’re integrating with an enterprise IdP, adding social login, or securing APIs, understanding how identities flow across systems will save you time and prevent subtle security bugs.

This article gives you a clear mental model, practical implementation tips, and code examples you can adapt today.

## Why identity and federation matter

- Users want one login across apps (SSO).
- Organizations need central policy, governance, and audit.
- Developers want to avoid storing passwords and reinventing auth.
- Security depends on well-understood trust boundaries and token handling.

Identity federation lets one domain (the Identity Provider, or IdP) authenticate a user, then assert that identity to another domain (the Service Provider/Relying Party) using standard protocols and signed tokens.

## Core concepts

- Authentication vs Authorization
  - Authentication: who are you? (login, MFA)
  - Authorization: what can you do? (scopes, roles)
- Principal/Subject: the user or service account being authenticated.
- Credentials: secrets used to prove identity (password, private key, OTP).
- Claims: attributes about the subject (email, groups, roles).
- Tokens: signed data packets conveying authentication and authorization.
  - ID Token (OpenID Connect): who the user is.
  - Access Token (OAuth 2.0): what the client can access.
  - SAML Assertion (SAML 2.0): XML-based identity assertion.
- Issuer and Audience: who created the token, and who should accept it.
- Trust: established through keys/certificates and metadata discovery.

## Federation 101

- Identity Provider (IdP): Authenticates the user and issues tokens/assertions.
- Service Provider (SP) / Relying Party (RP): Your app that consumes them.
- Metadata: Documents describing endpoints, certificates, and capabilities.
  - SAML: XML metadata.
  - OIDC: JSON at `/.well-known/openid-configuration`.
- Certificates/Keys: Sign and verify tokens; rotate regularly (JWKS for OIDC).

Analogy: Think of the IdP as a passport office and your app as border control. The passport (token) carries a signed assertion you can verify without calling the passport office each time.

## Protocols at a glance

- SAML 2.0
  - Mature enterprise SSO; XML assertions; browser POST/Redirect bindings.
  - Great for B2B SSO with legacy and enterprise IdPs.
- OAuth 2.0
  - Authorization framework; issues access tokens for APIs.
  - Flows for confidential/public clients, machine-to-machine, devices.
- OpenID Connect (OIDC)
  - Identity layer on top of OAuth 2.0; issues ID tokens (JWT).
  - Modern web/mobile login; simpler than SAML; easy discovery/JWKS.
- WS-Federation
  - Legacy Microsoft ecosystem; still encountered in some enterprises.

Rule of thumb: Use OIDC for user login in new apps; SAML when required by enterprise partners; OAuth 2.0 for API authorization.

## Common flows you’ll implement

- OIDC Authorization Code with PKCE (recommended)
  1. App sends user to the IdP’s authorize endpoint with `response_type=code`, `code_challenge`, `state`, `nonce`.
  2. User authenticates at the IdP (MFA, etc.).
  3. IdP redirects back with an authorization code.
  4. App exchanges code for tokens (ID/Access/Refresh) via the token endpoint using `code_verifier`.
- Client Credentials (OAuth 2.0)
  - Machine-to-machine. No user; the client authenticates and gets an access token.
- Device Authorization (OAuth 2.0)
  - TVs/CLI tools: user completes login on another device.
- SAML SP-initiated SSO
  1. User hits your app; you send SAML AuthnRequest to IdP.
  2. IdP authenticates and POSTs a signed SAML Response to your ACS URL.

Avoid the Implicit Flow for SPAs; prefer code+PKCE or a Backend-for-Frontend (BFF) pattern.

## Implementing OIDC quickly (Node.js example)

Use the openid-client library to handle discovery, PKCE, and token exchange.

```bash
npm install express openid-client express-session
```

```js
// server.js
const express = require('express');
const session = require('express-session');
const { Issuer, generators } = require('openid-client');

const app = express();
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false }));

let client; // OIDC client
(async () => {
  const issuer = await Issuer.discover(process.env.OIDC_ISSUER); // e.g. https://your-idp/.well-known/openid-configuration
  client = new issuer.Client({
    client_id: process.env.OIDC_CLIENT_ID,
    client_secret: process.env.OIDC_CLIENT_SECRET, // omit for public/SPAs
    redirect_uris: [process.env.OIDC_REDIRECT_URI], // e.g. https://app.example.com/callback
    response_types: ['code'],
  });
})();

app.get('/login', (req, res) => {
  const state = generators.state();
  const nonce = generators.nonce();
  const codeVerifier = generators.codeVerifier();
  const codeChallenge = generators.codeChallenge(codeVerifier);

  req.session.oidc = { state, nonce, codeVerifier };
  const authUrl = client.authorizationUrl({
    scope: 'openid profile email',
    state,
    nonce,
    code_challenge: codeChallenge,
    code_challenge_method: 'S256',
  });
  res.redirect(authUrl);
});

app.get('/callback', async (req, res, next) => {
  try {
    const { state, codeVerifier, nonce } = req.session.oidc || {};
    const params = client.callbackParams(req);
    const tokenSet = await client.callback(process.env.OIDC_REDIRECT_URI, params, { state, nonce, code_verifier: codeVerifier });
    req.session.user = tokenSet.claims();
    req.session.tokens = tokenSet;
    res.redirect('/me');
  } catch (err) {
    next(err);
  }
});

app.get('/me', (req, res) => {
  if (!req.session?.user) return res.status(401).send('Not logged in');
  res.json({ user: req.session.user });
});

app.listen(3000, () => console.log('Listening on http://localhost:3000'));
```

Tips:
- Always validate `state` (CSRF) and `nonce` (replay).
- Prefer short-lived Access Tokens and Refresh Token rotation.
- Store tokens server-side; for SPAs, consider a BFF to avoid storing tokens in the browser.

## Validating JWTs (ID/Access Tokens)

Validate signature and critical claims: `iss`, `aud`, `exp`, `iat`, `nonce` (ID token), `azp` (if needed), and `scope`/`roles` for authorization.

Python example using PyJWT and JWKS:

```python
import requests, jwt, time
from jwt import algorithms

ISSUER = "https://your-idp"
AUD = "api://your-api"
jwks = requests.get(f"{ISSUER}/.well-known/jwks.json").json()

def get_key(header):
    for k in jwks["keys"]:
        if k["kid"] == header["kid"]:
            return algorithms.RSAAlgorithm.from_jwk(k)
    raise Exception("Key not found")

def verify(token):
    header = jwt.get_unverified_header(token)
    key = get_key(header)
    claims = jwt.decode(
        token,
        key=key,
        algorithms=["RS256"],
        audience=AUD,
        issuer=ISSUER,
        options={"require": ["exp", "iat", "iss", "aud"]}
    )
    # Additional checks (time skew, custom claims)
    now = int(time.time())
    if claims["exp"] < now:
        raise Exception("Token expired")
    return claims
```

Common pitfalls:
- Not checking `iss` or `aud` leads to token confusion/mix-up attacks.
- Assuming JWTs are encrypted; by default they are only signed (JWS), readable by anyone holding them.
- Clock skew: allow a few seconds of leeway if needed.

## SAML implementation notes

- Use a library (e.g., passport-saml, python3-saml, or your framework’s SAML middleware).
- Validate:
  - XML signature on the entire assertion/response.
  - `AudienceRestriction` matches your SP entity ID.
  - `SubjectConfirmationData` (Recipient, NotOnOrAfter).
- Ensure your Assertion Consumer Service (ACS) URL exactly matches IdP config.
- Prefer signed and, if possible, encrypted assertions for high-sensitivity data.
- Map `NameID` and attributes (email, groups) to your user model.

## Federation patterns

- Enterprise SSO (B2B): Your SaaS federates with customer IdPs (SAML or OIDC). Support multiple connections (per-tenant metadata).
- Social login (B2C): Federate with providers like Google, Apple, Microsoft via OIDC. Provide account linking to existing users.
- Multi-tenant SaaS: Route users to the right IdP using domain discovery (email domain), `hd`/`domain_hint`, or tenant subdomain.
- Brokered identity: Use an identity gateway (e.g., Keycloak, Auth0, Okta) to connect many upstream IdPs and normalize tokens.
- Token Exchange (RFC 8693): Exchange one token for another audience (microservices, external APIs).

## Provisioning users and groups

- Just-In-Time (JIT): Create/update users on first login based on claims.
- SCIM 2.0: Standard API for lifecycle management (create, update, deactivate) from the IdP to your app.
- Keep roles/entitlements in your app; map external groups to internal roles.

## Sessions, logout, and lifetimes

- Web apps
  - Maintain an app session (cookie) separate from tokens.
  - Use HTTP-only, Secure, SameSite cookies. Regenerate session IDs after login.
  - Consider BFF pattern for SPAs to avoid exposing tokens to JS.
- APIs
  - Validate JWTs per request; do not store server-side API sessions.
- Logout
  - App logout clears your session.
  - Global SSO logout is protocol-specific:
    - OIDC: frontchannel/backchannel logout specs.
    - SAML: Single Logout (SLO) with signed requests/responses.
- Token lifetimes
  - Short-lived Access Tokens (5–15 minutes).
  - Refresh Tokens with rotation and automatic revocation on theft.
  - Re-authentication or step-up (MFA) for sensitive actions.

## Security hardening checklist

- Use Authorization Code + PKCE for public clients (SPAs, mobile).
- Validate issuer, audience, nonce/state, and token timestamps.
- Pin exact redirect URIs; avoid wildcard redirects.
- Enforce TLS everywhere; set HSTS.
- Key rotation:
  - Use JWKS endpoint; cache keys by `kid` and handle rotation.
- Prevent token theft:
  - Prefer HTTPS-only, HTTP-only cookies.
  - Consider Proof-of-Possession (DPoP) or mTLS for high-security APIs.
- Limit scopes and claims to least privilege; avoid overbroad roles.
- Monitor and alert on anomalies (impossible travel, MFA challenges).
- Protect against session fixation; regenerate cookies after login.

## Troubleshooting tips and tools

- Tools:
  - jwt.io (decode), OIDC debugger, browser SAML tracers, OAuth tools (curl/Postman), device flow testers.
- Common errors:
  - `invalid_grant`: code reused/expired, PKCE mismatch, clock skew.
  - `invalid_client`: bad client secret or auth method.
  - SAML `AuthnFailed` or `Responder`: attribute/ACS mismatch, signature validation issues.
- Logs:
  - Correlate requests across front/back channels with a request ID.
  - Log token `jti` (if present) and `sub` to trace sessions (avoid logging full tokens).

## Minimal end-to-end example (client credentials with curl)

Obtain a token and call an API:

```bash
# Get a token
curl -s -X POST https://issuer.example.com/oauth2/token \
  -u "$CLIENT_ID:$CLIENT_SECRET" \
  -d 'grant_type=client_credentials&scope=api.read' | tee token.json

# Use the access token
ACCESS_TOKEN=$(jq -r .access_token token.json)
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://api.example.com/data
```

Server validates `iss`, `aud`, `exp`, and signature using JWKS as shown earlier.

## Glossary

- IdP: Identity Provider that authenticates users.
- SP/RP: Service Provider/Relying Party (your app).
- JWKS: JSON Web Key Set; publishes signing keys.
- PKCE: Proof Key for Code Exchange; protects public clients.
- SCIM: System for Cross-domain Identity Management; provisioning standard.
- DPoP: Demonstration of Proof-of-Possession; binds tokens to a key.

## When to choose what

- Building new SSO for web/mobile users: OIDC (Auth Code + PKCE).
- Integrating with enterprise customers that mandate SSO: support SAML 2.0 and OIDC.
- Securing service-to-service APIs: OAuth 2.0 client credentials; consider mTLS/DPoP for high assurance.
- Legacy Microsoft-only environments: you may encounter WS-Fed; plan migrations to OIDC.

## Final thoughts

Identity and federation are about clear boundaries, strong cryptography, and disciplined validation. Pick the right protocol for the job, lean on mature libraries, and build with defense-in-depth. With a solid foundation, adding SSO, social login, or multi-tenant federation becomes predictable—and secure.