---
title: "CORS (Cross-Origin Resource Sharing) "
date: 2025-06-15T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["CORS", "HTTP header", "same-origin policy"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "CORS (Cross-Origin Resource Sharing)"
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
CORS on webMethods API Gateway: How to configure, test, and troubleshoot

CORS is one of those things that’s invisible when it’s right and maddening when it’s wrong. If you’re exposing APIs through IBM’s webMethods API Gateway and serving a browser-based frontend, this guide will show you how to set up CORS correctly, verify it with curl, and fix common issues fast.

TL;DR
- Enable the CORS policy on your API (or as a Global Policy) in API Gateway.
- Explicitly allow the frontend Origin, HTTP methods, and custom headers your app uses.
- Let the gateway handle preflight (OPTIONS) requests and don’t require authentication for them.
- Test with curl using -H "Origin: ..." and use -X OPTIONS for preflight checks.
- Watch out for credentials + "*" mismatch, missing allowed headers, or upstream proxies blocking OPTIONS.

1) What CORS is (and isn’t)
- What it is: A browser-enforced security model that restricts cross-origin HTTP calls made by frontend code (e.g., https://app.example.com calling https://api.example.com).
- What it isn’t: A server-to-server restriction. curl, Postman, and backend services aren’t blocked by CORS.
- Simple vs preflight:
  - Simple requests: GET/HEAD/POST with limited headers may not trigger a preflight.
  - Preflight: For other methods (PUT/PATCH/DELETE), custom headers (Authorization, X-API-Key, etc.), or content types, the browser sends an OPTIONS request first to check what’s allowed.

Key headers
- Request (from browser):
  - Origin
  - Access-Control-Request-Method (preflight)
  - Access-Control-Request-Headers (preflight)
- Response (from API Gateway):
  - Access-Control-Allow-Origin
  - Access-Control-Allow-Methods
  - Access-Control-Allow-Headers
  - Access-Control-Allow-Credentials (optional)
  - Access-Control-Expose-Headers (optional)
  - Access-Control-Max-Age (preflight cache)
  - Vary: Origin (important for caches/CDNs)

2) How webMethods API Gateway handles CORS
webMethods API Gateway has a dedicated Cross-Origin Resource Sharing policy. When enabled:
- The gateway automatically sets the Access-Control-* response headers on simple requests.
- It handles preflight OPTIONS requests at the gateway (recommended), so your backend usually doesn’t need to implement OPTIONS.
- You can allow specific origins, methods, and headers, control whether credentials are allowed, expose headers to JS, and set preflight cache (Max-Age).
- You can configure CORS per API or as a Global Policy that applies to many APIs.

3) Configuring CORS in webMethods API Gateway

Per-API configuration (typical)
1. Open API Gateway UI.
2. Navigate to APIs and select your API.
3. Go to Policies and add the Cross-Origin Resource Sharing policy.
4. Configure:
   - Allowed origins: e.g., https://app.example.com (avoid "*" if you need credentials).
   - Allowed methods: GET, POST, PUT, DELETE, PATCH, OPTIONS (include OPTIONS).
   - Allowed headers: Content-Type, Authorization, X-API-Key, X-Request-Id (include every header your frontend will send).
   - Exposed headers: Location, X-Request-Id, Link, X-RateLimit-Remaining (what the frontend JS can read).
   - Allow credentials: true if you use cookies, Authorization, or private endpoints from the browser.
   - Max age: e.g., 600 (seconds) to cache preflight.
   - Preflight handling: enable gateway handling of OPTIONS so it responds without calling the backend.
5. Save and activate the policy.

Global Policy (for many APIs)
- If you have multiple APIs that share the same frontend and rules, create a Global Policy with the CORS policy and apply it by API tag, name pattern, or other criteria.
- Make sure the policy order places CORS early enough to answer OPTIONS before security enforcement (see next note).

Important notes
- Don’t authenticate preflight: Browsers typically don’t send credentials on preflight, and requiring auth for OPTIONS often breaks CORS. Ensure your policy/order does not force authentication for OPTIONS. If you must run authentication policies, add an exception or condition for OPTIONS.
- Echoing origins vs wildcard: If Allow credentials is true, you cannot return Access-Control-Allow-Origin: *. Configure an explicit origin list (or use dynamic reflection if the gateway supports it) and ensure Vary: Origin is set.
- Clean conflicting headers: If your backend also sets CORS headers, configure the gateway to override or remove them to avoid duplicates/conflicts.

4) Example configuration for a SPA
Scenario: SPA at https://app.example.com calls https://api.company.com/orders with JWT in Authorization and custom header X-Request-Id.

Recommended CORS policy values:
- Allowed origins: https://app.example.com
- Allowed methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Allowed headers: Authorization, Content-Type, X-Request-Id
- Exposed headers: Location, X-Request-Id
- Allow credentials: true (because of Authorization)
- Max age: 600

Expected simple request response headers:
- Access-Control-Allow-Origin: https://app.example.com
- Access-Control-Allow-Credentials: true
- Access-Control-Expose-Headers: Location, X-Request-Id
- Vary: Origin

Expected preflight response headers:
- Access-Control-Allow-Origin: https://app.example.com
- Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE
- Access-Control-Allow-Headers: Authorization, Content-Type, X-Request-Id
- Access-Control-Max-Age: 600
- Access-Control-Allow-Credentials: true
- Vary: Origin, Access-Control-Request-Headers, Access-Control-Request-Method

5) Testing and troubleshooting with curl

Tip: curl doesn’t add Origin by default. You must pass it or you won’t see CORS headers.

Verify simple request
curl -i https://api.company.com/orders \
  -H "Origin: https://app.example.com"

You expect a 200 and:
- Access-Control-Allow-Origin: https://app.example.com
- (And possibly Access-Control-Allow-Credentials / Expose headers)

If missing, check:
- Is CORS policy attached and active?
- Does the Origin match exactly?
- Did you hit the correct stage/environment/host?

Verify preflight (OPTIONS)
curl -i -X OPTIONS https://api.company.com/orders \
  -H "Origin: https://app.example.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Authorization, Content-Type, X-Request-Id"

Expected:
- 200 or 204 status
- Access-Control-Allow-Origin: https://app.example.com
- Access-Control-Allow-Methods: includes POST
- Access-Control-Allow-Headers: includes Authorization, Content-Type, X-Request-Id
- Access-Control-Max-Age: 600 (if configured)
- Vary headers present

If you get 401/403/405:
- 401/403: Likely authentication enforced on OPTIONS. Adjust policy order or exempt OPTIONS in security policies.
- 405: OPTIONS not allowed upstream or blocked by a proxy. Ensure gateway handles preflight, and any load balancer/reverse proxy allows OPTIONS to pass through.
- 2xx but missing headers: CORS policy not triggered (missing Origin in request), wrong API matched, or backend overrode headers.

Testing credentials behavior
- With Allow-Credentials: true, the server must not return "*".
- You can’t truly simulate browser credential mode with curl, but you can verify headers:
curl -i https://api.company.com/orders \
  -H "Origin: https://app.example.com"
Ensure the response includes:
- Access-Control-Allow-Origin: https://app.example.com
- Access-Control-Allow-Credentials: true

Validating Vary for caches/CDNs
curl -i https://api.company.com/orders \
  -H "Origin: https://app.example.com"
Check:
- Vary: Origin
This prevents a CDN from serving one origin’s cached response to another origin.

6) Common mistakes and how to fix them
- Using "*" with credentials: Browsers reject credentialed requests if Access-Control-Allow-Origin is "*". Use explicit origins and allow credentials.
- Missing headers in preflight: If your app sends Authorization, X-API-Key, custom headers, they must be listed in Access-Control-Allow-Headers. Add them to the policy.
- OPTIONS blocked by proxy/LB: Configure your proxy to allow OPTIONS, or terminate preflight at the gateway.
- Auth required on preflight: Configure policy/order to let OPTIONS pass without authentication, or handle CORS before auth.
- Conflicting backend CORS headers: Remove/override backend CORS headers in the gateway so only one coherent set is returned.
- No CORS on curl tests: Remember to include the Origin header in curl; otherwise, the gateway might not add Allow-Origin.
- Preflight not cached: Set Access-Control-Max-Age to reduce the number of OPTIONS calls. Ensure Vary is correct so caches don’t serve invalid results.
- Wrong origin format: Match schemes and ports exactly (https vs http, and :3000 in dev).

7) Operational tips for webMethods API Gateway
- Prefer gateway-handled preflight: It’s faster and keeps backend logic simple.
- Use Global Policies for consistency: Apply standardized CORS settings organization-wide; override at API level only when necessary.
- Keep an “allowed headers” baseline: Authorization, Content-Type, Accept, X-Request-Id, X-API-Key are common.
- Expose only what you need: Add Location, Link, pagination headers, correlation IDs—avoid overexposing.
- Log and trace: Enable request/response logging for OPTIONS and normal calls during debugging to see header flow.
- Document origins per environment: Dev may use http://localhost:3000; staging/prod should use your real frontend domains.

8) Quick configuration checklist
- CORS policy attached (API or Global) and active.
- Allowed origins include your frontend(s).
- Allowed methods include OPTIONS and all used verbs.
- Allowed headers include every custom header sent by the browser.
- Allow credentials set correctly for your auth model.
- Exposed headers limited but sufficient for your UI.
- Max age set to a reasonable value (e.g., 600–3600).
- Authentication/authorization not blocking OPTIONS.
- Upstream proxies/load balancers allow OPTIONS through.
- Vary headers set (at least Vary: Origin).

Conclusion
CORS on webMethods API Gateway is straightforward once you know which knobs to turn: enable the CORS policy, list the origins/methods/headers you actually use, let the gateway handle preflights, and verify with curl. Most production issues come down to missing allowed headers, credentials plus wildcard origin, or OPTIONS being blocked. With the configuration patterns and curl commands here, you should be able to get from “CORS error” to “working” in minutes.