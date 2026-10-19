---
title: "Federated Authentication with OpenID Connect: Integrating IBM webMethods Integration Server 11.1 with WSO2 Identity Server 7.3.0"
date: 2026-10-11T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["JWT", "OpenID", "webmethods","OAuth"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Federated Authentication with OpenID Connect: Integrating IBM webMethods Integration Server 11.1 with WSO2 Identity Server 7.3.0"
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
# Federated Authentication with OpenID Connect: Integrating IBM webMethods Integration Server 11.1 with WSO2 Identity Server 7.3.0

Technical article · Identity Federation · OpenID Connect · webMethods Integration Server · WSO2

## 1. Introduction

Integration platforms traditionally focus on connecting applications, orchestrating services and exposing APIs. Security in these environments is often associated with API authentication and authorisation mechanisms such as OAuth 2.0.

However, there are scenarios in which an integration platform must understand not only whether a request is authorised, but also who the user making the request is.

Consider an enterprise web application that exposes different capabilities depending on the identity of the authenticated employee. Rather than maintaining separate user credentials within the integration platform, the organisation wants to delegate authentication to a central Identity Provider while retaining control over access to its integration services.

This is where OpenID Connect (OIDC) becomes relevant.

OpenID Connect is an identity layer built on OAuth 2.0. It enables an application, known as a Relying Party, to authenticate users through an external OpenID Provider and receive verified information about their identity.

IBM webMethods Integration Server 11.1 supports OIDC authentication and can operate as a Relying Party. It can use claims returned by an OpenID Provider to associate authenticated users with local security identities and determine their access to Integration Server resources.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



In this article, we will implement this capability using:

- IBM webMethods Integration Server 11.1 as the OIDC Relying Party and integration backend.
- WSO2 Identity Server 7.3.0 as the OpenID Provider.
- A lightweight Employee Self-Service Portal as the demonstration web application.

The implementation will cover the Identity Provider configuration, Integration Server configuration, a simple web application, and tests demonstrating authentication and authorisation.

## 2. Business use case: Employee Self-Service Portal

A company wants to provide employees with a simple web portal offering two operations:

- My Profile: available to all authenticated employees.
- Team Report: available only to managers.

The organisation already maintains its users in WSO2 Identity Server and does not want to duplicate their passwords in webMethods Integration Server.

The expected behaviour is straightforward.

When an employee accesses the portal, Integration Server delegates authentication to WSO2 using OpenID Connect. After successful authentication, Integration Server identifies the user from the claims returned by WSO2 and associates that identity with a locally configured OpenID Provider User.

The user can then access services according to the groups and Access Control Lists (ACLs) configured in Integration Server.

### Demonstration users

| User  | WSO2 identity | IS group            | Permissions             |
| ----- | ------------- | ------------------- | ----------------------- |
| Alice | `alice`       | Employees           | My Profile              |
| Bob   | `bob`         | Employees, Managers | My Profile, Team Report |

Neither Alice nor Bob needs a password in Integration Server.

The key principle is that WSO2 authenticates the user, while Integration Server determines which integration services that authenticated user can access.

## 3. Solution architecture

Logical architecture: the browser participates in the OIDC redirects, but Integration Server owns the Relying Party configuration and token processing.

### 3.1 OpenID Connect authentication flow

The authentication sequence is:

1. The employee requests a protected resource on Integration Server.
2. Integration Server redirects the browser to the WSO2 authorisation endpoint.
3. WSO2 authenticates the employee.
4. WSO2 redirects the browser to the Integration Server callback with an authorisation code.
5. Integration Server exchanges that code for tokens directly with WSO2.
6. Integration Server validates the ID Token and evaluates the returned identity claims.
7. Integration Server maps the authenticated identity to an OpenID Provider User and establishes a session.
8. The browser is redirected to the originally requested resource, and Integration Server applies its ACLs.

The IS 11.1 documentation explicitly supports this authentication model. It supports the OIDC Authorization Code Flow, but not the PKCE extension to that flow.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM

+1



### 3.2 Why use OIDC rather than OAuth 2.0 alone?

Although the Authorization Code Flow is based on OAuth 2.0, the purpose of this implementation is different from a typical API authorisation scenario.

| OAuth 2.0 API scenario                 | This OIDC scenario                               |
| -------------------------------------- | ------------------------------------------------ |
| Client obtains an Access Token         | IS receives and validates an ID Token            |
| API validates permissions              | IS establishes the user's authenticated identity |
| Focus on access to protected resources | Focus on identity federation and SSO             |
| Access Token is central                | ID Token and identity claims are central         |
| Resource Server role                   | Relying Party role                               |

The Access Token is still part of the OIDC flow, but it is not the credential that our web application will use to invoke the Integration Server services. Instead, the browser uses the session established after successful OIDC authentication.

## 4. Laboratory prerequisites

The following environment will be used throughout the article.

| Component                          | Example hostname | Port |
| ---------------------------------- | ---------------- | ---- |
| WSO2 Identity Server 7.3.0         | `wso2.lab.local` | 9443 |
| webMethods IS 11.1 — OIDC entry    | `is.lab.local`   | 8443 |
| webMethods IS 11.1 — OIDC callback | `is.lab.local`   | 8444 |
| Employee Portal                    | `is.lab.local`   | 8443 |

The hostnames and Integration Server ports are illustrative laboratory values.

Both systems must be reachable over HTTPS. The browser must resolve both hostnames, and Integration Server must trust the TLS certificate presented by WSO2.

For a local laboratory, DNS records or hosts-file entries can be used:

```
192.168.1.20  wso2.lab.local
192.168.1.21  is.lab.local
```

Replace these example addresses with the actual addresses of the laboratory servers.

The IS requires two HTTPS ports: one configured to delegate authentication to the OpenID Provider and another to receive the callback.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



# Part I — Configuring WSO2 Identity Server 7.3.0

## 5. Create the OpenID Connect application

Access the WSO2 Identity Server Console:

```
https://wso2.lab.local:9443/console
```

Sign in with an administrative account.

Navigate to Applications → New Application and select Traditional Web Application.

Create the application with the following settings:

| Property                      | Value                                                                     |
| ----------------------------- | ------------------------------------------------------------------------- |
| Application name              | `webMethods-OIDC-Demo`                                                    |
| Protocol                      | OpenID Connect                                                            |
| Authorised redirect URL       | `https://is.lab.local:8444/invoke/wm.server.security.openid/codeCallback` |
| Grant type                    | Authorization Code                                                        |
| Client type                   | Confidential                                                              |
| Token endpoint authentication | Client Secret Basic                                                       |

The redirect URL is particularly important. It must point to the internal OIDC callback service provided by Integration Server, not to the demonstration portal.

IBM documents the callback path as:

```
/invoke/wm.server.security.openid/codeCallback
```

The HTTPS port used for this callback must not be configured with Client Authentication = Use Identity Provider.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



After registering the application, record the generated Client ID and Client Secret.

These credentials identify Integration Server as an OIDC client. They are not the credentials of Alice or Bob.

## 6. Configure OIDC scopes and user attributes

The application must request the following scopes:

```
openid profile email
```

The `openid` scope is mandatory for an OpenID Connect authentication request.

The `profile` and `email` scopes request additional identity information. However, requesting a scope does not guarantee that every associated claim will appear in the ID Token. The returned claims depend on the WSO2 application's attribute configuration and release policy.

In the WSO2 application configuration, review User Attributes and make the following attributes available where supported:

| Attribute          | OIDC claim    | Purpose                     |
| ------------------ | ------------- | --------------------------- |
| Subject identifier | `sub`         | Stable user identification  |
| Email              | `email`       | Displaying the user's email |
| Given name         | `given_name`  | Displaying the first name   |
| Family name        | `family_name` | Displaying the surname      |

For the laboratory, we will map the IS identities using the `sub` claim, which is the standard OIDC subject identifier.

This is preferable to relying on email addresses because email addresses can change.

WSO2 provides configuration options for user attributes associated with OIDC applications.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://is.docs.wso2.com\&sz=32)

WSO2 Identity Server

+1



## 7. Create the demonstration users

Navigate to User Management → Users in the WSO2 Console.

Create two local users.

| Property    | Alice               | Bob               |
| ----------- | ------------------- | ----------------- |
| Username    | `alice`             | `bob`             |
| Given name  | Alice               | Bob               |
| Family name | Smith               | Johnson           |
| Email       | `alice@example.com` | `bob@example.com` |

Set distinct laboratory passwords for the users.

Both users must be permitted to sign in to the `webMethods-OIDC-Demo` application. If application-level role restrictions are enabled in WSO2, ensure both users satisfy them.

At this stage, WSO2 does not need to know which Integration Server Flow Services Alice or Bob can invoke. That authorisation decision will be made locally by Integration Server.

## 8. Retrieve the OpenID Provider metadata

WSO2 exposes an OpenID Connect Discovery document containing the endpoints and capabilities required by an OIDC client.

For a default WSO2 deployment, retrieve:

```
curl --fail --show-error \
  https://wso2.lab.local:9443/oauth2/oidcdiscovery/.well-known/openid-configuration \
  -o wso2-openid-configuration.json
```

The exact discovery address should be confirmed from the WSO2 application's OIDC metadata, particularly if the server uses a non-default tenant or organisation configuration.

The returned JSON should contain information such as:

```
{
  "issuer": "https://wso2.lab.local:9443/oauth2/token",
  "authorization_endpoint": "https://wso2.lab.local:9443/oauth2/authorize",
  "token_endpoint": "https://wso2.lab.local:9443/oauth2/token",
  "userinfo_endpoint": "https://wso2.lab.local:9443/oauth2/userinfo",
  "jwks_uri": "https://wso2.lab.local:9443/oauth2/jwks"
}
```

This is an illustrative extract, not a complete discovery document or a claim that these are the exact values returned by every WSO2 7.3.0 installation. Use the actual document returned by your server, including its precise `issuer`.

The discovery metadata is essential because it allows Integration Server to identify the correct WSO2 endpoints and verify the ID Token using the provider's published signing keys.

Do not replace the `issuer` with a manually constructed URL.

## 9. Validate the WSO2 configuration

Before proceeding, verify that:

- The application exists and has a Client ID and Client Secret.
- The Authorization Code grant is enabled.
- The redirect URI matches the Integration Server callback exactly.
- The `openid` scope is permitted.
- Alice and Bob can authenticate.
- The discovery document is accessible from the Integration Server host.
- The required identity claims can be returned by WSO2.

This completes the OpenID Provider configuration.

# Part II — Configuring IBM webMethods Integration Server 11.1

## 10. Register WSO2 as an OpenID Provider

Integration Server 11.1 uses an OpenID Provider configuration document to register the external identity provider.

According to the IBM documentation, the procedure is to retrieve the provider's discovery document, add Integration Server-specific properties and save the resulting JSON file in the Integration Server security configuration directory.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



The directory is:

```
<SoftwareAG>/IntegrationServer/instances/<instance>/config/security/openid/
```

Copy the WSO2 discovery document into this directory, for example:

```
wso2-openid-configuration.json
```

Edit the document and add the Integration Server-specific settings, preserving all the original WSO2 metadata.

An illustrative set of additional properties is:

```
{
  "name": "WSO2-Identity-Server",
  "client_id": "<WSO2_CLIENT_ID>",
  "client_secret": "<WSO2_CLIENT_SECRET>",
  "redirection_endpoint_host": "is.lab.local",
  "max_age": 3600
}
```

These properties are an extract to merge into the complete discovery document, not a standalone replacement for it. Additional Integration Server-specific properties, including redirect-port and token-authentication settings, must be completed according to the 11.1 configuration schema and the values accepted by the WSO2 metadata.

Do not remove fields such as `issuer`, `authorization_endpoint`, `token_endpoint`, `jwks_uri`, `response_types_supported` or `scopes_supported`.

The `client_secret` must be treated as confidential. IBM documents that Integration Server transfers the configured secret into its encrypted outbound password store when it processes the provider configuration.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



### 10.1 Load the OpenID Provider configuration

Open Integration Server Administrator and navigate to:

Security → OpenID

Select Refresh OpenID Providers.

Integration Server parses the JSON files in the OpenID configuration directory.

If the document contains invalid JSON, the Administrator interface reports an error identifying the affected line and column.

Confirm that the `WSO2-Identity-Server` provider is loaded successfully before continuing.

## 11. Configure HTTPS and certificate trust

OIDC authentication requires secure communication between the browser, Integration Server and WSO2.

For this laboratory, create two HTTPS listeners.

### 11.1 OIDC authentication listener

In Integration Server Administrator, navigate to the port configuration section and add an HTTPS port.

| Setting               | Value                 |
| --------------------- | --------------------- |
| Port                  | 8443                  |
| Protocol              | HTTPS                 |
| Client Authentication | Use Identity Provider |
| Identity Provider     | WSO2-Identity-Server  |
| SSL Key               | IS server certificate |

This is the port through which users access protected Integration Server resources.

When a request arrives without a valid authenticated session, Integration Server initiates the OIDC authentication process.

### 11.2 OIDC callback listener

Create a second HTTPS port:

| Setting               | Value                     |
| --------------------- | ------------------------- |
| Port                  | 8444                      |
| Protocol              | HTTPS                     |
| Client Authentication | Not Use Identity Provider |
| Purpose               | OIDC callback             |
| SSL Key               | IS server certificate     |

The callback URL will be:

```
https://is.lab.local:8444/invoke/wm.server.security.openid/codeCallback
```

The callback service must be accessible through this port, but the port should not expose unrelated administrative or application services.

Review the port's service access rules, preferably using Deny By Default with the required callback service explicitly permitted.

IBM documents both the dedicated callback port and the ability to restrict services exposed through an Integration Server port.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM

+1



### 11.3 Configure TLS trust

Ensure that:

- The IS HTTPS certificate is trusted by the browser.
- The IS certificate covers `is.lab.local`.
- The WSO2 certificate is trusted by the JVM/Integration Server TLS configuration used for outbound OIDC requests.
- The WSO2 certificate covers `wso2.lab.local`.

Do not disable TLS certificate validation to make the laboratory work.

## 12. Create the OpenID Provider Users

This is one of the most important steps in the implementation.

Integration Server does not simply accept an arbitrary user returned by WSO2 and automatically grant access to its services.

Instead, it uses claims from the ID Token or UserInfo response to match the authenticated user to a locally configured OpenID Provider User.

These users do not have local passwords and cannot authenticate directly through a username/password request. Their purpose is to represent externally authenticated identities within the Integration Server security model.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



### 12.1 Create the local OIDC identities

Navigate to:

Security → User Management → Add and Remove OpenID Provider Users

Create:

```
OIDC_Alice
OIDC_Bob
```

Associate both users with:

```
WSO2-Identity-Server
```

### 12.2 Configure identity matching

Each OpenID Provider User needs a claim that distinguishes it from other users.

For this example, use the `sub` claim.

| IS OpenID User | Token claim | Expected value              |
| -------------- | ----------- | --------------------------- |
| OIDC_Alice     | `sub`       | Alice's actual WSO2 subject |
| OIDC_Bob       | `sub`       | Bob's actual WSO2 subject   |

The `sub` values must be obtained from real tokens issued by WSO2 after authentication. Do not assume that `sub` equals `alice` or `bob`.

For each user:

1. Select Edit in the Claims column.
2. Select Add ID Token claim.
3. Enter `sub` as the claim name.
4. Enter the corresponding WSO2 subject value.
5. Save the configuration.

The claims must be unique and non-overlapping.

IBM explicitly warns that overlapping claim definitions can produce ambiguous user mappings and inconsistent access privileges.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



### 12.3 How to obtain the subject identifiers

During initial configuration, obtain the subject identifiers from a controlled WSO2 authentication test or a securely inspected ID Token.

A JWT ID Token has three Base64URL-encoded components:

```
header.payload.signature
```

A decoded payload may resemble:

```
{
  "iss": "https://wso2.lab.local:9443/oauth2/token",
  "sub": "a1b2c3-example-subject",
  "aud": "webmethods-client-id",
  "exp": 1790000000,
  "iat": 1789996400,
  "email": "alice@example.com",
  "given_name": "Alice"
}
```

This is illustrative data. Actual claim availability and values depend on WSO2.

Decoding a JWT does not validate its signature. The inspection is useful for understanding claims; token validation remains the responsibility of the OIDC implementation.

## 13. Configure groups and ACLs

We now need to associate the authenticated identities with Integration Server permissions.

### 13.1 Create security groups

Create two local Integration Server groups:

```
Employees
Managers
```

Assign the users as follows:

| User       | Employees | Managers |
| ---------- | --------- | -------- |
| OIDC_Alice | Yes       | No       |
| OIDC_Bob   | Yes       | Yes      |

### 13.2 Create ACLs

Create two Access Control Lists:

```
ACL_EmployeeProfile
ACL_ManagerReport
```

Configure them so that:

- `ACL_EmployeeProfile` allows the `Employees` group.
- `ACL_ManagerReport` allows the `Managers` group.

Avoid adding broad groups such as `Everybody` to these allow lists.

For this laboratory, configure the service Execute ACLs so that they enforce the intended access rules.

The expected authorisation matrix is:

| Service         | Alice   | Bob     |
| --------------- | ------- | ------- |
| `getMyProfile`  | Allowed | Allowed |
| `getTeamReport` | Denied  | Allowed |

Notice that the access decision is not made by the browser. It is enforced by Integration Server.

This distinction is essential: hiding a button in a web application is not an authorisation mechanism.

## 14. Implement the Flow Services

Create an Integration Server package named:

```
OIDCEmployeePortal
```

Inside the package, create a folder:

```
OIDCEmployeePortal.services
```

We will implement two Flow Services.

### 14.1 Service: getMyProfile

Fully qualified name:

```
OIDCEmployeePortal.services:getMyProfile
```

Configure:

```
Execute ACL: ACL_EmployeeProfile
```

The service should:

1. Obtain the current caller identity using `pub.flow:getCallerIdentity`.
2. Read the relevant authenticated user information from the returned pipeline.
3. Construct a small response containing the caller's identity and a welcome message.
4. Return the response as JSON.

The IBM built-in service `pub.flow:getCallerIdentity` can be used to inspect the identity associated with the authenticated Integration Server session, including OIDC-related information.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



For the laboratory, the output can have the following structure:

```
{
  "status": "success",
  "user": "OIDC_Alice",
  "message": "Welcome to the Employee Portal",
  "service": "getMyProfile"
}
```

This is the desired output contract, not an automatic response generated by `pub.flow:getCallerIdentity`. Implement the mapping in the Flow Service and confirm the actual built-in service output fields in Designer.

### 14.2 Service: getTeamReport

Fully qualified name:

```
OIDCEmployeePortal.services:getTeamReport
```

Configure:

```
Execute ACL: ACL_ManagerReport
```

The service can return static demonstration data:

```
{
  "status": "success",
  "department": "IT",
  "employees": 12,
  "activeProjects": 4,
  "service": "getTeamReport"
}
```

The content is deliberately simple. The purpose is to demonstrate that the service can be executed by Bob but not by Alice.

### 14.3 Service exposure

For the demonstration, the services will be invoked through the Integration Server `/invoke` directive:

```
https://is.lab.local:8443/invoke/OIDCEmployeePortal.services/getMyProfile
```

```
https://is.lab.local:8443/invoke/OIDCEmployeePortal.services/getTeamReport
```

Ensure that the OIDC HTTPS port permits these services and that their Execute ACLs are enforced.

The service responses should use `application/json`, with explicit JSON serialisation rather than relying on default pipeline output formatting.

# Part III — Building the Employee Portal Web Application

## 15. Web application design

The web application will be deliberately lightweight. We do not need React, Angular, a separate application server or an additional OIDC library.

Using a simple HTML/JavaScript application allows us to concentrate on the OIDC implementation inside Integration Server.

The portal will provide:

- A Sign In entry point that triggers the IS-managed OIDC authentication flow.
- A My Profile operation available to authenticated employees.
- A Team Report operation restricted to managers.
- A response panel displaying the results returned by Integration Server.

The browser will not store ID Tokens or Access Tokens. It will use the authenticated Integration Server session.

## 16. Deploy the web application

Integration Server supports serving static web documents from the `pub` directory of a package. IBM documents the URL format as `/<PackageName>/<DocumentName>`.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



We will use:

```
OIDCEmployeePortal/
└── pub/
    └── index.html
```

The filesystem location is:

```
<SoftwareAG>/IntegrationServer/instances/<instance>/packages/OIDCEmployeePortal/pub/index.html
```

The portal will be accessible through:

```
https://is.lab.local:8443/OIDCEmployeePortal/index.html
```

This arrangement ensures that the portal and the backend services use the same HTTPS origin, avoiding the need to configure cross-origin requests.

The OIDC listener should only expose the web documents and services required by the demonstration. Do not expose the Integration Server Administrator through this public-facing port.

## 17. Web application implementation

Create `index.html` with the following content.

```

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">
  <title>Employee Self-Service Portal</title>
  <style>
    * { box-sizing: border-box; }

    body {
      margin: 0;
      background: #f4f6fa;
      color: #243047;
      font-family: Arial, sans-serif;
    }

    header {
      background: #182b49;
      color: white;
      padding: 24px 32px;
    }

    header h1 { margin: 0 0 8px; }
    header p { margin: 0; opacity: .8; }

    main {
      max-width: 900px;
      margin: 35px auto;
      padding: 0 20px;
    }

    .panel {
      background: white;
      border-radius: 10px;
      padding: 24px;
      margin-bottom: 20px;
      box-shadow: 0 2px 12px #00000010;
    }

    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
    }

    button {
      border: 0;
      background: #1669ba;
      color: white;
      padding: 12px 18px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: bold;
    }

    button:hover { background: #10518f; }
    button:disabled { opacity: .5; }

    pre {
      background: #101c30;
      color: #d7e7fa;
      padding: 18px;
      border-radius: 8px;
      overflow-x: auto;
      white-space: pre-wrap;
      min-height: 90px;
    }

    .status { color: #496079; }
  </style>
</head>
<body>

<header>
  <h1>Employee Self-Service Portal</h1>
  <p>webMethods IS 11.1 + WSO2 Identity Server 7.3.0</p>
</header>

<main>
  <section class="panel">
    <h2>Federated Authentication</h2>
    <p>
      User authentication is managed by WSO2
      through OpenID Connect.
    </p>
    <p id="status" class="status">
      Authentication status not yet checked.
    </p>
    <div class="actions">
      <button id="loginBtn" onclick="login()">
        Sign In
      </button>
    </div>
  </section>

  <section class="panel">
    <h2>Employee Operations</h2>
    <p>
      Access is controlled by Integration Server ACLs.
    </p>
    <div class="actions">
      <button onclick="callService('getMyProfile')">
        My Profile
      </button>
      <button onclick="callService('getTeamReport')">
        Team Report
      </button>
    </div>
  </section>

  <section class="panel">
    <h2>Integration Server Response</h2>
    <pre id="result">No request executed.</pre>
  </section>
</main>

<script>
  const BASE =
    "/invoke/OIDCEmployeePortal.services/";

  function login() {
    // Full-page navigation is required because
    // the IS OIDC flow redirects the browser.
    window.location.assign(BASE + "getMyProfile");
  }

  async function callService(name) {
    const output = document.getElementById("result");
    const status = document.getElementById("status");

    output.textContent = "Invoking " + name + "...";

    try {
      const response = await fetch(BASE + name, {
        method: "GET",
        credentials: "same-origin",
        headers: {
          "Accept": "application/json"
        },
        redirect: "follow"
      });

      const contentType =
        response.headers.get("content-type") || "";

      // A fetch request is not a suitable way to
      // initiate an interactive OIDC login.
      // The user should use full-page navigation.
      if (response.redirected &&
          !response.url.startsWith(location.origin)) {
        throw new Error(
          "Authentication required. Use Sign In."
        );
      }

      if (contentType.includes("text/html")) {
        throw new Error(
          "Unexpected HTML response. " +
          "Check the OIDC session and service output."
        );
      }

      const body = await response.text();
      let data;

      try {
        data = JSON.parse(body);
      } catch {
        data = body;
      }

      output.textContent =
        typeof data === "string"
          ? data
          : JSON.stringify(data, null, 2);

      if (response.ok) {
        status.textContent =
          "Service executed using the IS session.";
      } else if (response.status === 403) {
        status.textContent =
          "Access denied by Integration Server.";
      } else if (response.status === 401) {
        status.textContent =
          "Authentication required.";
      } else {
        status.textContent =
          "HTTP " + response.status;
      }

    } catch (error) {
      output.textContent = error.message;
      status.textContent =
        "Request could not be completed.";
    }
  }
</script>
</body>
</html>

```

### 17.1 Understanding the Sign In operation

The Sign In button does not invoke WSO2 directly.

Instead, it navigates the browser to:

```
/invoke/OIDCEmployeePortal.services/getMyProfile
```

Because this request arrives through the OIDC-enabled Integration Server listener, Integration Server initiates authentication when no valid session exists.

The user is redirected to WSO2 and, after successful authentication, back to the originally requested service.

This is a deliberate design choice: Integration Server remains the OIDC Relying Party.

For this minimal application, the first successful login returns the JSON response of `getMyProfile`. The user can then navigate back to the portal to use its interface. A more polished implementation could use an IS-hosted landing resource or redirect service to return directly to the portal after authentication.

### 17.2 Understanding service invocation

The portal uses JavaScript `fetch()` to invoke the Integration Server services.

The option:

```
credentials: "same-origin"
```

instructs the browser to include applicable cookies in requests to the same origin.

Following successful OIDC authentication, Integration Server establishes a session and sends a session cookie to the browser. Subsequent requests can reuse that authenticated session.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



The application does not need to process the ID Token directly.

The OIDC exchange and identity mapping are handled by Integration Server.

One important limitation of this minimal implementation is that an expired session should be recovered through a new top-level browser navigation, not by trying to complete an interactive login inside `fetch()`.

### 17.3 Application security

This sample intentionally contains no client secret, token-processing library or hardcoded identity information.

It also does not use a JavaScript variable such as `isManager` to enforce access to the manager service.

Even if a user manually invokes the manager endpoint, Integration Server must still apply `ACL_ManagerReport`.

The browser interface is only a presentation layer.

# Part IV — Testing the End-to-End Authentication Flow

## 18. Test 1: Unauthenticated access

Open a private browser window and navigate to:

```
https://is.lab.local:8443/OIDCEmployeePortal/index.html
```

Click Sign In.

Expected sequence:

1. The browser requests `getMyProfile`.
2. Integration Server detects that OIDC authentication is required.
3. The browser is redirected to the WSO2 login page.
4. WSO2 prompts for credentials.

At this stage, authentication is being performed by WSO2, not by Integration Server.

If the WSO2 login page is not displayed, inspect the Integration Server OIDC configuration, HTTPS listener and browser redirects.

## 19. Test 2: Authentication as Alice

Authenticate with Alice's WSO2 credentials.

WSO2 authenticates Alice and redirects the browser to:

```
https://is.lab.local:8444/invoke/wm.server.security.openid/codeCallback
```

The callback contains an authorisation code and the state information associated with the authentication request.

Integration Server then exchanges the authorisation code with WSO2, processes the ID Token and matches the `sub` claim to `OIDC_Alice`.

If the mapping succeeds, Integration Server establishes an authenticated session.

The original `getMyProfile` request should now succeed.

Expected application response:

```
{
  "status": "success",
  "user": "OIDC_Alice",
  "message": "Welcome to the Employee Portal",
  "service": "getMyProfile"
}
```

Return to the portal and select Team Report.

Because Alice is not a member of the `Managers` group, the request should be denied by the service's Execute ACL.

The exact HTTP error representation depends on the Integration Server configuration, but the protected service must not execute successfully.

## 20. Test 3: Authentication as Bob

Open a new private browser session to avoid reusing Alice's existing session or the WSO2 SSO session.

Authenticate with Bob's WSO2 credentials.

Integration Server should match Bob's subject identifier to `OIDC_Bob`.

Because Bob belongs to both `Employees` and `Managers`, both services should be available.

Expected Team Report response:

```
{
  "status": "success",
  "department": "IT",
  "employees": 12,
  "activeProjects": 4,
  "service": "getTeamReport"
}
```

### Expected test results

| Test                                              | Expected result                 |
| ------------------------------------------------- | ------------------------------- |
| Unauthenticated user requests a protected service | Redirect to WSO2                |
| Alice authenticates                               | OIDC authentication succeeds    |
| Alice invokes My Profile                          | Allowed                         |
| Alice invokes Team Report                         | Denied                          |
| Bob authenticates                                 | OIDC authentication succeeds    |
| Bob invokes My Profile                            | Allowed                         |
| Bob invokes Team Report                           | Allowed                         |
| Unmapped WSO2 user authenticates                  | Rejected by IS identity mapping |

These are acceptance criteria for the laboratory, not results claimed from an executed deployment.

## 21. Inspecting the OIDC exchange

Browser Developer Tools can be used to inspect the redirect sequence.

The relevant requests are:

| Request                     | Purpose                             |
| --------------------------- | ----------------------------------- |
| IS protected resource       | Initiates authentication            |
| WSO2 authorisation endpoint | Authenticates the user              |
| IS OIDC callback            | Receives the authorisation code     |
| IS protected resource       | Processes the authenticated request |

The browser does not normally see the back-channel request made by Integration Server to the WSO2 token endpoint.

That request occurs between Integration Server and WSO2.

For troubleshooting, use Integration Server logs and WSO2 diagnostic logs. Avoid logging raw ID Tokens, Access Tokens, authorisation codes or client secrets.

# Part V — Security Considerations and Troubleshooting

## 22. Important security considerations

### 22.1 ID Token validation

Integration Server must validate the ID Token issued by WSO2, including the cryptographic signature and the relevant protocol claims.

These include the issuer, intended audience, expiration and other applicable OIDC validation requirements.

The public signing keys are advertised through the WSO2 JWKS endpoint.

A successfully decoded JWT is not necessarily a valid JWT.

### 22.2 Identity mapping and ACLs

An authenticated user should not automatically receive access to all Integration Server services.

Create explicit OpenID Provider Users with unambiguous claim matching and assign only the necessary permissions.

Do not create a broad default mapping without understanding its security implications.

### 22.3 Authentication session lifetime

Integration Server maintains an authenticated session after the OIDC exchange.

The session lifetime must be managed independently from the ID Token lifetime.

For example, expiration of an ID Token does not automatically imply that the browser's existing Integration Server session has ended.

Session expiration, reauthentication and logout behaviour should therefore be part of the overall security design.

### 22.4 Authentication timeout

Integration Server stores pending OIDC authentication requests in the `ActiveOpenIDRequests` cache.

IBM documents a default time-to-live of 60 seconds. If authentication takes longer than this, the callback may fail because the original authentication request is no longer available.

For laboratories involving MFA or slow manual authentication, this setting may need adjustment.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



### 22.5 PKCE limitation

Integration Server 11.1 supports OIDC Authorization Code Flow but does not support PKCE for this OIDC implementation.

For this reason, the laboratory uses a confidential OIDC client with client-secret authentication.

This is a relevant architectural limitation when comparing the native IS implementation with modern browser-based OIDC clients.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.ibm.com\&sz=32)

IBM



### 22.6 Logout

A local Integration Server session and the WSO2 SSO session are distinct.

Ending one does not necessarily terminate the other.

This minimal portal does not implement coordinated logout. A production implementation should define how local session termination and WSO2 logout are handled, rather than assuming that closing the browser or removing a local cookie performs a complete federated logout.

## 23. Common troubleshooting scenarios

| Problem                                   | Likely cause                                   | Recommended check                               |
| ----------------------------------------- | ---------------------------------------------- | ----------------------------------------------- |
| No WSO2 login redirect                    | OIDC listener incorrectly configured           | Verify port 8443 and selected provider          |
| Redirect URI rejected                     | Callback mismatch                              | Compare WSO2 URI with IS callback configuration |
| Callback fails                            | Incorrect callback listener or expired request | Verify port 8444 and pending request cache      |
| Token validation fails                    | Issuer, audience, keys or TLS mismatch         | Inspect actual discovery metadata               |
| Login succeeds but access is denied       | No matching OpenID Provider User               | Check `sub` claim mapping                       |
| Alice accesses manager service            | Incorrect group/ACL configuration              | Verify Execute ACL and group membership         |
| JavaScript receives HTML                  | Session expired or login redirect              | Reauthenticate through full-page navigation     |
| Authentication works once but fails later | Session or cache behaviour                     | Inspect session lifetime and OIDC logs          |

# 24. Conclusion

This implementation demonstrates how OpenID Connect can be used in IBM webMethods Integration Server for a purpose that goes beyond traditional API authorisation.

By integrating with WSO2 Identity Server, Integration Server can delegate user authentication to an external identity platform, process the resulting OIDC identity information and associate authenticated users with local security identities.

The key responsibilities remain clearly separated:

WSO2 Identity Server acts as the OpenID Provider. It authenticates users, maintains their credentials and issues identity information through the OpenID Connect protocol.

IBM webMethods Integration Server acts as the Relying Party. It processes the OIDC authentication response, maps the external identity to a local OpenID Provider User and enforces access through its existing group and ACL model.

The Employee Portal acts as the presentation layer. It does not need to manage OIDC tokens directly or duplicate authentication logic.

The resulting architecture provides centralised authentication while allowing the integration platform to retain control over access to its own services.

Most importantly, it illustrates why OpenID Connect is relevant to integration platforms: it allows integration services to operate in the context of an authenticated user identity, rather than relying exclusively on application-level credentials or API access tokens.

## 25. References

The implementation is based on the following official product documentation:

- [IBM — Authenticating Users with OpenID Connect](https://www.ibm.com/docs/en/webmethods-integration/wm-integration-server/11.1.0?topic=authentication-authenticating-users-openid-connect\&utm_source=chatgpt.com)
- [IBM — Configuring OpenID Connect in Integration Server](https://www.ibm.com/docs/en/webmethods-integration/wm-integration-server/11.1.0?topic=authentication-configuring-openid-connect-in-integration-server\&utm_source=chatgpt.com)
- [IBM — Configuring the OpenID Provider on Integration Server](https://www.ibm.com/docs/en/webmethods-integration/wm-integration-server/11.1.0?topic=authentication-configuring-openid-provider-integration-server\&utm_source=chatgpt.com)
- [IBM — Registering Integration Server with the OpenID Provider](https://www.ibm.com/docs/en/webmethods-integration/wm-integration-server/11.1.0?topic=authentication-registering-integration-server-openid-provider\&utm_source=chatgpt.com)
- [WSO2 — Register an OpenID Connect Web Application](https://is.docs.wso2.com/en/7.0.0/guides/applications/register-oidc-web-app/?utm_source=chatgpt.com)
