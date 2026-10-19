---
title: "Enterprise Security Explained: From SAML to OAuth 2.0, OpenID Connect and JWT"
date: 2026-10-04T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["JWT", "OpenID", "Tokens","OAuth"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Enterprise Security Explained: From SAML to OAuth 2.0, OpenID Connect and JWT"
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
# Enterprise Security Explained: From SAML to OAuth 2.0, OpenID Connect and JWT

*Understanding modern authentication and authorisation in distributed enterprise architectures.*

## 1. Introduction

Enterprise security has changed dramatically over the last two decades.

In the past, enterprise applications were typically monolithic systems deployed within a single data centre. Authentication, authorisation and business logic were often managed within the same application or infrastructure.

Today, applications are distributed across multiple environments, data centres and cloud providers. A frontend application might run in a user's browser, communicate with REST APIs hosted in another cloud environment, and rely on an external identity provider to authenticate users.

This architectural evolution introduced new security challenges.

How can applications authenticate users without handling their passwords? How can APIs securely expose business functionality? How can one application access another application's resources without sharing credentials? And how can machine-to-machine integrations operate securely without human interaction?

To answer these questions, we need to understand four fundamental technologies:

- **SAML 2.0** — Federated authentication and enterprise Single Sign-On.
- **OAuth 2.0** — Delegated authorisation and secure API access.
- **OpenID Connect (OIDC)** — An identity layer built on OAuth 2.0.
- **JSON Web Tokens (JWT)** — A compact format for securely exchanging claims.

Although these technologies are related, they solve different problems.

Let's explore how they fit together.

---

## 2. The Evolution of Enterprise Security

Enterprise identity management has evolved through three major generations.

### First Generation: Application-Level Identity

Originally, each application maintained its own user repository.

The application was responsible for everything:

- Storing user credentials.
- Authenticating users.
- Managing roles and permissions.
- Authorising access to business functionality.

This architecture was straightforward but introduced significant challenges.

Users needed separate credentials for different applications, password management became increasingly complex, and organisations struggled to enforce consistent security policies.

### Second Generation: Centralised Identity Management

The introduction of centralised directories, such as LDAP and Microsoft Active Directory, improved identity management.

Applications could delegate credential validation to a central directory while continuing to manage authorisation locally.

A typical architecture looked like this:

```text
User
  |
  v
Enterprise Application
  |
  | Username + Password
  v
LDAP / Active Directory
  |
  | Authentication Result
  v
Enterprise Application
```

This approach centralised user management but still required applications to handle user credentials.

Additionally, applications and identity repositories were frequently deployed within the same corporate network.

### Third Generation: Federated Identity

As organisations adopted cloud services and distributed architectures, a new approach became necessary.

Rather than passing credentials through applications, users could authenticate directly with a trusted Identity Provider (IdP).

The application, acting as a Service Provider (SP), would trust the authentication result issued by that Identity Provider.

This is where **SAML 2.0** became particularly important.

---

## 3. Understanding SAML 2.0

Security Assertion Markup Language (SAML) is an XML-based standard commonly used for enterprise federated authentication and Single Sign-On (SSO).

The key concept is simple:

**The application does not need to know the user's password. It only needs to trust the Identity Provider.**

### How SAML Authentication Works

Consider an employee accessing an enterprise application.

```text
             User / Browser
                    |
        1. Access Application
                    |
                    v
             Service Provider
                    |
        2. Redirect to IdP
                    |
                    v
             Identity Provider
                    |
        3. Authenticate User
                    |
        4. Return SAML Response
                    |
                    v
             Service Provider
                    |
        5. Establish Session
                    |
                    v
             Enterprise Application
```

In a typical browser-based SAML flow:

1. The user attempts to access an application.
2. The Service Provider redirects the browser to the Identity Provider.
3. The Identity Provider authenticates the user.
4. The Identity Provider generates a signed SAML assertion.
5. The browser delivers the SAML response to the Service Provider.
6. The Service Provider validates the assertion and establishes an application session.

If the user already has a valid session with the Identity Provider, authentication may occur without another password prompt.

This provides Single Sign-On across multiple enterprise applications.

### Establishing Trust

The Service Provider must be able to verify that the SAML assertion was issued by a trusted Identity Provider.

This is typically achieved using digital signatures and certificates.

The Identity Provider signs the assertion using its private key. The Service Provider validates the signature using the corresponding public key.

This establishes trust without requiring the Service Provider to receive the user's credentials.

### The Limitations of SAML

SAML remains an important enterprise authentication technology.

However, its traditional browser-oriented model is not particularly convenient for modern API-driven architectures.

Consider the following scenarios:

- A Single Page Application running entirely in a browser.
- A mobile application consuming REST APIs.
- A backend service communicating with another microservice.
- A scheduled job invoking an external API.
- An application accessing a third-party platform on behalf of a user.

These scenarios require a mechanism for granting controlled access to APIs.

This is where OAuth 2.0 becomes essential.

---

## 4. Why OAuth 2.0 Was Introduced

Imagine an application that needs permission to publish content to a user's LinkedIn account.

One possible approach would be to ask the user for their LinkedIn username and password.

That would be a serious security problem.

The third-party application would gain access to credentials that could potentially provide much broader access than necessary.

**Applications should never require users to disclose another service's passwords simply to access its APIs.**

OAuth 2.0 solves this problem through delegated authorisation.

Instead of sharing credentials, the user authorises the application to perform specific operations.

The application receives an access token representing the permissions granted.

It then uses that token to invoke the protected API.

### What Is OAuth 2.0?

OAuth 2.0 is an authorisation framework that allows applications to obtain limited access to protected HTTP resources.

This access may be granted on behalf of a user or directly to an application acting on its own behalf.

OAuth introduces a fundamental separation between:

- The application requesting access.
- The system granting access.
- The API exposing protected resources.

This separation is especially useful in distributed architectures and microservices.

---

## 5. The Four OAuth 2.0 Roles

OAuth defines four primary roles.

| Role | Responsibility | Example |
|---|---|---|
| Resource Owner | Entity capable of granting access to a protected resource | A LinkedIn user |
| Client | Application requesting access | A third-party publishing application |
| Authorization Server | Issues access tokens after successful authorisation | An OAuth identity platform |
| Resource Server | Hosts protected resources and validates access tokens | LinkedIn REST API |

In an enterprise architecture, these components may be deployed across different environments.

For example, an integration platform may act as an OAuth client when consuming external APIs and as a resource server when exposing its own APIs.

### OAuth in Enterprise Applications

An important distinction exists between consumer applications and enterprise applications.

In consumer scenarios, the OAuth client may belong to a completely different organisation from the resource server.

In enterprise scenarios, the organisation may own the client application, resource server and authorisation infrastructure.

However, OAuth works in both situations.

The protocol does not require the client to be a third-party application.

Its purpose is to establish a standardised mechanism for granting and enforcing access.

---

## 6. OAuth Client Registration

Before an application can participate in an OAuth flow, it normally needs to be registered with the Authorization Server.

During registration, the application receives a **Client ID** and, where appropriate, a **Client Secret**.

The Client ID identifies the application.

The Client Secret authenticates confidential clients to the Authorization Server.

These values serve different purposes and should not be confused with access tokens.

For enterprise deployments, secrets should be stored securely using solutions such as HashiCorp Vault or CyberArk.

They should never be hardcoded into frontend JavaScript or exposed in source code repositories.

Public applications, such as browser-based Single Page Applications and native mobile applications, cannot reliably protect a shared client secret.

This distinction is fundamental when selecting the appropriate OAuth flow.

---

## 7. Understanding OAuth Access Tokens

Once authorisation succeeds, the client receives an access token.

The client includes this token when calling the protected API.

For example:

```http
GET /api/customers HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

The Resource Server validates the token before allowing access.

The token represents the client's authorisation to perform specific operations.

There are two common access-token formats.

### Opaque Access Tokens

An opaque token is an identifier whose contents are not meaningful to the client or Resource Server.

For example:

```text
7b2f9d83a0e54c17b8e3
```

The Resource Server may need to contact the Authorization Server's introspection endpoint to determine whether the token is active and which permissions it represents.

This approach provides centralised control but introduces additional communication between systems.

### JWT Access Tokens

A JSON Web Token is a structured token containing claims.

A JWT access token might include:

```json
{
  "iss": "https://auth.example.com",
  "sub": "user123",
  "aud": "https://api.example.com",
  "scope": "customers.read",
  "exp": 1790000000
}
```

The Resource Server can validate a signed JWT locally using the issuer's public key.

This can reduce the need for repeated calls to the Authorization Server.

However, local validation must still check the signature, issuer, audience, expiration and other relevant claims.

JWTs are particularly useful in distributed architectures, although their use introduces considerations around token lifetime, revocation and claim exposure.

**Important:** JWT payloads are Base64URL-encoded, not encrypted by default. Anyone possessing the token may be able to decode its contents.

---

## 8. OAuth Scopes: Controlling API Access

OAuth scopes describe the permissions requested by a client.

Consider an API exposing customer information.

An Authorization Server might define:

```text
customers.read
customers.write
customers.admin
```

A client requesting `customers.read` should not automatically gain permission to modify customer information.

The Resource Server must enforce the relevant authorisation rules.

For example:

```text
GET /customers
Required scope: customers.read

POST /customers
Required scope: customers.write

DELETE /customers/{id}
Required scope: customers.admin
```

Scopes are similar to permissions, but they are not necessarily equivalent to enterprise roles.

A scope describes the access granted to a client, whereas a role or group may describe the privileges associated with a user.

Enterprise systems can combine scopes, groups and custom claims to implement fine-grained authorisation.

### Audience

Another important concept is the token audience.

The `aud` claim identifies the intended recipient or recipients of the token.

For example:

```json
{
  "aud": "https://api.example.com",
  "scope": "customers.read"
}
```

An API should reject a token that was issued for a different audience, even if the token has a valid signature.

This prevents tokens intended for one service from being incorrectly accepted by another.

---

## 9. OAuth 2.0 Grant Types

Different applications require different ways of obtaining tokens.

A backend application can securely store credentials.

A browser-based application cannot.

A scheduled integration may not involve a user at all.

OAuth supports different authorisation flows to address these situations.

### Authorization Code

The Authorization Code flow is commonly used by server-side web applications.

It involves two main stages:

1. The client obtains an authorisation code through a browser-based authorisation flow.
2. The client exchanges that code for tokens at the Token Endpoint.

Confidential clients authenticate when exchanging the code.

This separates the browser interaction from the token exchange.

### Authorization Code with PKCE

Proof Key for Code Exchange (PKCE) provides additional protection against authorisation-code interception.

It is essential for public clients and recommended for modern OAuth clients generally.

The client generates a random `code_verifier` and derives a `code_challenge`.

For the recommended S256 method:

```text
code_challenge =
BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
```

The client sends the challenge during the initial authorisation request.

Later, when exchanging the authorisation code, it sends the original verifier.

The Authorization Server calculates the challenge from the verifier and compares it with the original value.

This binds the token request to the application instance that initiated the authorisation request.

### Client Credentials

The Client Credentials flow is designed for machine-to-machine communication.

For example:

```text
Scheduled Job
      |
      | Client Credentials
      v
Authorization Server
      |
      | Access Token
      v
Scheduled Job
      |
      | Bearer Token
      v
Protected REST API
```

No interactive user is involved.

The client authenticates directly to the Authorization Server and requests an access token.

This flow is particularly relevant for enterprise integrations, scheduled jobs and backend services.

### Device Authorization Grant

Some devices have limited input capabilities.

Examples include smart televisions, printers and other connected devices.

The Device Authorization Grant allows users to authorise such devices using a separate browser-enabled device.

The user typically visits a verification URL and enters a short code.

The device then obtains tokens after authorisation succeeds.

### Refresh Tokens

Access tokens generally have limited lifetimes.

A refresh token may allow the client to obtain a new access token without requiring the user to authenticate again.

The client sends the refresh token to the Token Endpoint using the `refresh_token` grant type.

Refresh tokens require careful protection and may be subject to rotation or other security controls.

### Legacy Flows

Two older approaches deserve mention.

The Implicit Grant returned tokens directly through the browser-based authorisation response. It is no longer recommended for modern applications.

The Resource Owner Password Credentials Grant required the client to collect the user's password. It is unsuitable for modern federated identity architectures and has been removed from OAuth 2.1 drafts.

Modern implementations should favour Authorization Code with PKCE or Client Credentials, depending on the application architecture.

---

## 10. OAuth 2.0 Endpoints

An Authorization Server typically exposes several endpoints.

| Endpoint | Purpose |
|---|---|
| Authorization | Initiates user authorisation |
| Token | Issues and refreshes tokens |
| UserInfo | Returns user claims in OpenID Connect |
| Introspection | Provides token status and metadata |
| JWKS | Publishes public keys used for signature verification |
| Revocation | Allows tokens to be revoked |
| Device Authorization | Initiates device-based authorisation |

The client's redirect URI is also important, but it is normally an endpoint hosted by the client application rather than the Authorization Server.

### Endpoint Discovery

OpenID Connect provides a discovery mechanism that allows applications to retrieve provider metadata.

For example, Google's discovery document is available at:

```text
https://accounts.google.com/.well-known/openid-configuration
```

The document contains information such as:

```json
{
  "issuer": "https://accounts.google.com",
  "authorization_endpoint": "https://accounts.google.com/o/oauth2/v2/auth",
  "token_endpoint": "https://oauth2.googleapis.com/token",
  "userinfo_endpoint": "https://openidconnect.googleapis.com/v1/userinfo",
  "jwks_uri": "https://www.googleapis.com/oauth2/v3/certs",
  "revocation_endpoint": "https://oauth2.googleapis.com/revoke"
}
```

This makes integration easier because applications can discover relevant configuration rather than hardcoding every endpoint.

---

## 11. Practical Example: Authorization Code Flow

Let's consider an application integrating with Google's OAuth infrastructure.

The application must first be registered with Google.

Depending on the application type, registration provides a Client ID and possibly a Client Secret.

### Step 1: Construct the Authorization Request

The client redirects the user's browser to the Authorization Endpoint.

For example:

```text
https://accounts.google.com/o/oauth2/v2/auth
```

Typical parameters include:

```text
response_type=code
client_id=YOUR_CLIENT_ID
redirect_uri=https://app.example.com/callback
scope=openid email profile
state=RANDOM_STATE
```

The values must be correctly URL-encoded.

For a PKCE-enabled request, the client also includes:

```text
code_challenge=GENERATED_CHALLENGE
code_challenge_method=S256
```

### Step 2: Receive the Authorization Code

After the user authenticates and grants the requested permissions, Google redirects the browser to the registered redirect URI.

For example:

```text
https://app.example.com/callback?code=AUTH_CODE&state=RANDOM_STATE
```

The client must validate the returned state value before proceeding.

### Step 3: Exchange the Code for Tokens

The client sends a POST request to the Token Endpoint:

```http
POST /token HTTP/1.1
Host: oauth2.googleapis.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&
code=AUTH_CODE&
client_id=YOUR_CLIENT_ID&
client_secret=YOUR_CLIENT_SECRET&
redirect_uri=https%3A%2F%2Fapp.example.com%2Fcallback
```

This example represents a confidential client using client-secret authentication.

A PKCE-enabled request must also include the original `code_verifier`.

### Step 4: Receive the Tokens

A successful response may contain:

```json
{
  "access_token": "ACCESS_TOKEN",
  "expires_in": 3600,
  "token_type": "Bearer",
  "refresh_token": "REFRESH_TOKEN",
  "id_token": "ID_TOKEN"
}
```

The exact response depends on the scopes, grant, provider configuration and applicable policies.

An ID Token is returned when OpenID Connect authentication is performed.

A refresh token is not guaranteed to be issued.

### Step 5: Invoke the Protected API

The client includes the access token in the HTTP Authorization header.

```http
GET /oauth2/v3/userinfo HTTP/1.1
Host: openidconnect.googleapis.com
Authorization: Bearer ACCESS_TOKEN
```

The API validates the token and returns information permitted by the granted scopes.

### Testing with Postman

Postman is useful for exploring OAuth flows.

Collections and environment variables can help organise requests and avoid repeatedly entering configuration.

Google also provides an OAuth testing environment:

https://developers.google.com/oauthplayground/

For supported Google scopes, see:

https://developers.google.com/identity/protocols/oauth2/scopes

---

## 12. OpenID Connect: Adding Identity to OAuth

OAuth 2.0 is fundamentally an authorisation framework.

Its primary purpose is to enable clients to access protected resources.

However, many applications need more than API authorisation.

They need to authenticate users and obtain information about their identities.

For example, consider an application offering:

**Sign in with Google**

The application may not need access to Google Photos, Gmail or any other Google API.

It simply needs to know who the user is.

This is where OpenID Connect becomes relevant.

### What Is OpenID Connect?

OpenID Connect is an identity layer built on OAuth 2.0.

It standardises how clients authenticate users and receive identity information.

An OpenID Connect request includes the `openid` scope.

Additional scopes may request standard claims:

```text
openid profile email
```

The Authorization Server may then issue an ID Token containing information about the authenticated user.

### Access Token vs ID Token

This distinction is critical.

| Access Token | ID Token |
|---|---|
| Used to access protected resources | Used to convey authentication information |
| Intended for the Resource Server | Intended for the client application |
| Contains or represents authorisation information | Contains identity and authentication claims |
| Format depends on implementation | Must be a JWT in OpenID Connect |

An ID Token might contain:

```json
{
  "iss": "https://accounts.google.com",
  "sub": "123456789",
  "aud": "my-client-id",
  "email": "user@example.com",
  "email_verified": true,
  "name": "Example User"
}
```

These claims are illustrative. The claims actually returned depend on the provider and request.

**Never use an ID Token as a substitute for an access token when invoking protected APIs.**

The ID Token proves information about an authentication event to the client.

The access token represents authorisation to access a protected resource.

---

## 13. Understanding JSON Web Tokens

JWT is not an authentication protocol by itself.

It is a standardised token format for representing claims.

A signed JWT consists of three Base64URL-encoded sections separated by dots.

```text
HEADER.PAYLOAD.SIGNATURE
```

### Header

The header identifies the token type and signing algorithm.

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "key-001"
}
```

### Payload

The payload contains claims.

```json
{
  "sub": "user123",
  "iss": "https://auth.example.com",
  "aud": "https://api.example.com",
  "scope": "orders.read",
  "exp": 1790000000
}
```

### Signature

The signature protects the integrity of the header and payload.

With an asymmetric algorithm such as RS256, the issuer signs the token using its private key.

The receiving application validates the signature using the corresponding public key.

The public keys are often published through a JWKS endpoint.

This allows Resource Servers to validate tokens without needing access to the issuer's private signing key.

A valid signature does not automatically mean a token should be accepted. The application must also validate the issuer, audience, lifetime and any other relevant restrictions.

---

## 14. OAuth Client Authentication Methods

OAuth supports several methods for authenticating confidential clients.

### client_secret_basic

The client sends its Client ID and Client Secret using HTTP Basic authentication.

```http
Authorization: Basic BASE64(CLIENT_ID:CLIENT_SECRET)
```

The credentials are encoded, not encrypted, so HTTPS is essential.

### client_secret_post

The client includes its credentials in the form-encoded request body.

```text
client_id=CLIENT_ID
client_secret=CLIENT_SECRET
```

This is different from placing credentials in the URL query string, which should be avoided.

### client_secret_jwt

The client creates a signed JWT assertion using a shared secret.

The Authorization Server validates that assertion to authenticate the client.

### private_key_jwt

The client signs a JWT assertion using its private key.

The Authorization Server verifies the signature using the registered public key.

This provides an alternative to transmitting a shared client secret.

For enterprise integrations, asymmetric client authentication can be particularly useful when managing credentials across distributed systems.

---

## 15. Enterprise OAuth: Groups, Roles and Scopes

Enterprise authorisation is often more complex than granting access to a single API.

Organisations may already maintain user groups in LDAP, Active Directory or another identity platform.

These groups can be mapped to application roles or included as custom token claims.

For example:

```json
{
  "sub": "employee123",
  "groups": [
    "finance",
    "reporting"
  ],
  "scope": "reports.read",
  "aud": "https://reports.example.com"
}
```

The Resource Server can use the claims to make authorisation decisions.

However, groups, roles and scopes should remain conceptually distinct.

- Groups represent organisational membership.
- Roles represent application responsibilities or privileges.
- Scopes represent delegated permissions granted to a client.

An enterprise authorisation model may combine all three.

For example, a token may contain `reports.read`, but the API may additionally require the user to belong to the Finance group.

This enables more granular access control.

---

## 16. OAuth in Enterprise Integration Platforms

Integration platforms can participate in OAuth architectures in several different roles.

Consider Software AG webMethods Integration Server.

Depending on the architecture and supported configuration, it may act as an OAuth client, a protected Resource Server or participate in an authorisation solution.

### Integration Server as an OAuth Client

In this scenario, Integration Server consumes APIs protected by OAuth.

A typical integration might:

1. Authenticate to an Authorization Server.
2. Obtain an access token.
3. Invoke a protected REST API.
4. Refresh the token when necessary.
5. Handle token expiration and authorisation errors.

For maintainability, reusable integration services can encapsulate operations such as:

```text
oauth.getAccessToken
oauth.refreshToken
oauth.revokeToken
oauth.introspectToken
oauth.invokeProtectedAPI
```

The implementation details depend on the selected Authorization Server and supported grant types.

### Integration Server as a Resource Server

Integration Server may expose REST APIs that require OAuth access tokens.

For example:

```text
GET /api/orders
Required scope: orders.read

POST /api/orders
Required scope: orders.write
```

The security layer must validate incoming tokens and enforce the required permissions.

This typically includes signature or introspection-based validation, audience checking and scope enforcement.

### Integration Server and the Authorization Server Role

A third architectural possibility is to integrate Integration Server into a solution responsible for issuing or managing tokens.

However, acting as a standards-compliant OAuth Authorization Server involves substantially more than generating JWTs.

It requires secure implementation of token issuance, client authentication, grant processing, key management, metadata, revocation and other protocol requirements.

Whether Integration Server can fulfil this role natively depends on its product version, capabilities and architecture.

In many enterprise environments, a dedicated identity platform such as Okta is a more appropriate Authorization Server.

---

## 17. Using Okta for Enterprise API Security

Unlike a consumer-focused OAuth provider configured primarily for its own APIs, an enterprise identity platform such as Okta can support custom API authorisation models.

A typical setup involves:

1. Creating or connecting user identities.
2. Configuring groups.
3. Registering client applications.
4. Defining an API audience.
5. Creating custom scopes.
6. Configuring authorisation policies.
7. Discovering the provider endpoints.
8. Configuring the Resource Server to validate tokens.

For example, an enterprise API might define:

```text
Audience:
https://api.company.example

Scopes:
orders.read
orders.write
orders.admin
```

A client application requesting `orders.read` can obtain a token that the API uses to authorise read operations.

This architecture is especially relevant when securing APIs exposed through integration platforms or microservices.

It also separates identity management from application-specific business logic.

---

## 18. Security Best Practices

OAuth and OpenID Connect provide powerful building blocks, but secure implementation requires careful configuration.

Some fundamental practices include:

- **Use HTTPS everywhere.** Tokens and credentials must be protected in transit.
- **Prefer Authorization Code with PKCE.** Avoid legacy browser-based token flows.
- **Use Client Credentials for machine-to-machine integrations.** Do not introduce unnecessary user identities.
- **Store secrets securely.** Use a dedicated secrets manager where appropriate.
- **Validate JWTs properly.** Check signatures, issuer, audience, expiry and relevant claims.
- **Apply least privilege.** Request only the scopes actually required.
- **Protect refresh tokens.** Apply appropriate storage, rotation and lifetime controls.
- **Separate authentication from authorisation.** Knowing who a user is does not automatically establish what they may access.
- **Never trust claims merely because they can be decoded.** Base64URL decoding is not cryptographic validation.
- **Do not place sensitive information unnecessarily in tokens.** Signed JWT payloads are generally readable by token holders.

---

## 19. Putting Everything Together

Modern enterprise security rarely depends on a single protocol.

Different technologies work together to address different requirements.

| Technology | Primary Purpose | Typical Scenario |
|---|---|---|
| SAML 2.0 | Federated authentication | Enterprise Single Sign-On |
| OAuth 2.0 | Delegated authorisation | Securing REST APIs |
| OpenID Connect | User authentication and identity claims | Sign in with Google |
| JWT | Structured claims exchange | Signed access tokens and ID Tokens |
| LDAP / Active Directory | Identity directory services | Centralised enterprise users |

Consider a modern enterprise application.

The user may authenticate through an Identity Provider federated with an enterprise directory.

OpenID Connect can provide the application with identity information.

OAuth can provide access tokens for invoking backend APIs.

Those access tokens may be JWTs that the Resource Servers validate locally.

The Resource Servers can then combine scopes, roles and groups to enforce business-level authorisation.

Each component has a clearly defined responsibility.

This separation makes modern distributed architectures more scalable, maintainable and secure.

---

## 20. Conclusion

The evolution from monolithic applications to distributed systems and microservices fundamentally changed enterprise security.

Traditional application-level authentication gave way to centralised identity management and federated authentication through technologies such as SAML.

The growth of APIs introduced new requirements for delegated access, machine-to-machine communication and fine-grained authorisation.

OAuth 2.0 addresses these requirements.

OpenID Connect extends OAuth with a standardised identity layer, while JWT provides a compact mechanism for exchanging signed claims.

The most important distinctions to remember are:

**SAML is primarily about federated authentication.**

**OAuth 2.0 is about authorisation and access to protected resources.**

**OpenID Connect is about authenticating users and communicating identity information.**

**JWT is a token format, not an authorisation protocol.**

Understanding these distinctions is essential when designing enterprise integration architectures, securing microservices and implementing modern identity solutions.

The goal is not simply to generate access tokens. It is to establish a consistent security architecture in which applications, identities and APIs can interact securely without unnecessary credential sharing.

---

## Further Reading

- [OAuth 2.0 Authorization Framework — RFC 6749](https://www.rfc-editor.org/rfc/rfc6749)
- [OAuth 2.0 Security Best Current Practice — RFC 9700](https://www.rfc-editor.org/rfc/rfc9700)
- [OpenID Connect Core Specification](https://openid.net/specs/openid-connect-core-1_0.html)
- [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)
- [JSON Web Token — RFC 7519](https://www.rfc-editor.org/rfc/rfc7519)
- [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
- [Google OAuth 2.0 Scopes](https://developers.google.com/identity/protocols/oauth2/scopes)