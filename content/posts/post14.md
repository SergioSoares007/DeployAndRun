---
title: "REST vs. gRPC Part2"
date: 2025-04-06T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["REST", "gRPC"]
author: "Me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "REST vs. gRPC: Understanding the Differences and Choosing the Right Protocol"
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
# REST vs gRPC: The Pragmatic, Developer-Friendly Guide

TL;DR
- REST is universal, human-friendly, cacheable, and ideal for public APIs and browser clients. It uses HTTP semantics with resource-oriented design and JSON by default.
- gRPC is fast, strongly typed, and streaming-friendly—great for internal microservices and low-latency mobile/IoT. It uses HTTP/2 (or HTTP/3 in some stacks) and Protocol Buffers (Protobuf).
- Use REST for broad reach, compatibility, and simple CRUD; use gRPC for high-throughput, low-latency, streaming, or strongly typed interfaces across polyglot services.
- Hybrid patterns—REST for public, gRPC internally—often deliver the best of both worlds.

Contents
- What are REST and gRPC?
- Mental Models: Resources vs RPC
- Transports: HTTP/1.1, HTTP/2, HTTP/3
- Data Formats: JSON vs Protobuf (and JSON with gRPC)
- Streaming, Real-time, and Backpressure
- API Design: URLs vs RPC methods, versioning, pagination
- Errors, Retries, and Timeouts
- Caching and CDNs
- Security and Auth
- Tooling and Developer Experience
- Observability: Logs, Metrics, Traces
- Platform Support: Browsers, Mobile, Cloud, and Meshes
- Performance & Cost Considerations
- Migration and Hybrid Architectures
- Best Practices and Common Pitfalls
- Decision Checklist
- FAQs
- Summary

What are REST and gRPC?
- REST (Representational State Transfer) is an architectural style layered onto HTTP. You expose resources (users, orders, posts) with URLs and standard HTTP methods (GET, POST, PUT, PATCH, DELETE). Responses are typically JSON. REST’s superpower is universality: it works practically everywhere, especially on the web.
- gRPC is an RPC framework created at Google. It uses Protocol Buffers (but can support other encodings) with an Interface Definition Language (IDL) to generate client and server code. It runs over HTTP/2 (and in several stacks HTTP/3) and supports streaming in all directions. Its superpower is efficiency, strong typing, and first-class streaming.

Mental Models: Resources vs RPC
- REST: Resource-oriented
  - Identify nouns/resources (e.g., /users/123/orders).
  - Use HTTP verbs to express actions (GET to read, POST to create).
  - Embrace HTTP semantics (status codes, caching, content negotiation).
  - Pros: self-descriptive, cache-friendly, easy for browsers, widely understood.
  - Trade-offs: mapping complex workflows or streaming can be awkward.

- gRPC: Procedure/method-oriented
  - Define services and methods (UserService.GetUser, OrderService.CreateOrder).
  - Strongly typed requests/responses using Protobuf schemas.
  - Unary and streaming calls as first-class citizens.
  - Pros: compact, fast, codegen-powered DX, great for microservices and streaming.
  - Trade-offs: weaker browser-native support, tooling is different, caching/CDN less natural.

Transports: HTTP/1.1, HTTP/2, HTTP/3
- REST
  - Typically HTTP/1.1, but also works over HTTP/2 and HTTP/3 transparently via standard web servers/CDNs.
  - Benefits from HTTP/2 multiplexing and header compression where available.
  - Easily goes through proxies, gateways, and CDNs.

- gRPC
  - Standard gRPC uses HTTP/2 for multiplexed, bidirectional streams.
  - Many ecosystems now support gRPC over HTTP/3 (QUIC), improving head-of-line blocking and mobility; check your language/runtime’s current support.
  - Not natively supported by browsers due to streaming and header constraints; grpc-web bridges this gap via a proxy and HTTP/1.1/2 friendly semantics.

Data Formats: JSON vs Protobuf (and JSON with gRPC)
- REST payloads
  - Commonly JSON; also XML, YAML, or binary for special cases.
  - Human-readable; excellent for debugging and public API docs.
  - Larger on-the-wire size vs Protobuf; more CPU to parse at scale.

- gRPC payloads
  - Default is Protobuf: compact binary encoding, fast encoding/decoding.
  - Strong schemas with backward/forward-compatible design (field numbers, optional fields, oneof).
  - Unknown fields are usually ignored on parse—great for gradual rollout.

- JSON in gRPC?
  - gRPC can be used with JSON via transcoding gateways (e.g., Envoy + grpc-json-transcoder or grpc-gateway). This lets you expose REST/JSON endpoints that internally call gRPC.
  - Some stacks support gRPC-JSON directly for ease of interop at the edge.

Streaming, Real-time, and Backpressure
- gRPC has first-class streaming:
  - Unary: single request -> single response (most REST-like).
  - Server streaming: single request -> stream of responses (e.g., logs, events).
  - Client streaming: stream of requests -> single response (e.g., batch upload).
  - Bidirectional streaming: both sides stream concurrently (e.g., chat, telemetry, ML inference pipelines).
- REST equivalents:
  - Server-sent events (SSE): server -> client stream over HTTP. Easy in browsers; unidirectional.
  - WebSockets: full-duplex channel over a single TCP; great for real-time, but not REST semantics and requires different infra and protocols.
  - Chunked transfer and long polling: workarounds, but not as clean as gRPC streaming.

Backpressure and flow control:
- gRPC/HTTP/2 provide built-in flow control and framing to handle backpressure more gracefully.
- REST with SSE or WebSockets requires you to design your own flow control patterns and congestion/backpressure strategies.

API Design: URLs vs RPC methods, versioning, pagination
- REST design tips
  - Use plural nouns and resource hierarchies: GET /users/{id}/orders.
  - HTTP status codes (200, 201, 204, 400, 401, 403, 404, 409, 422, 429, 500).
  - Partial updates with PATCH and JSON Patch/JSON Merge Patch.
  - Versioning strategies: URI (/v1/), header-based, or default + backward-compatible evolution.
  - Pagination: limit/offset, or cursor/page_token. Cursor is preferred at scale.
  - Conditional requests: ETag/If-None-Match for concurrency and caching.
  - Filtering/sorting: query params (e.g., ?status=active&sort=-created_at).

- gRPC design tips
  - Services and RPCs should be business-action oriented but cohesive (UserService, OrderService).
  - Design request/response messages explicitly; include page_size and page_token in requests, and next_page_token in responses.
  - Use field numbers carefully; never reuse removed numbers; prefer additive changes (new optional fields).
  - Represent partial updates with FieldMask where applicable.
  - Consider error detail messages using google.rpc.Status and google.rpc.ErrorInfo for structured errors.
  - Versioning: package name and service name (my.app.v1) to separate new versions while allowing coexistence.

Code examples

REST (curl + Node.js/Express)
```bash
# Create a user
curl -X POST https://api.example.com/v1/users \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@example.com","name":"Doe"}'
```

```js
// app.js (Express)
const express = require('express');
const app = express();
app.use(express.json());

app.get('/v1/users/:id', async (req, res) => {
  const user = await db.getUser(req.params.id);
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json(user);
});

app.post('/v1/users', async (req, res) => {
  const user = await db.createUser(req.body);
  res.status(201).json(user);
});

app.listen(3000);
```

gRPC (proto + Go server + grpcurl)
```proto
// user.proto
syntax = "proto3";
package example.user.v1;

option go_package = "example.com/user/gen;userv1";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {}
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {}
  rpc StreamUsers(StreamUsersRequest) returns (stream GetUserResponse) {}
}

message GetUserRequest { string id = 1; }
message GetUserResponse { string id = 1; string email = 2; string name = 3; }

message CreateUserRequest { string email = 1; string name = 2; }
message CreateUserResponse { string id = 1; }

message StreamUsersRequest { int32 page_size = 1; string page_token = 2; }
```

```go
// server.go (Go gRPC)
type userServer struct {
  userv1.UnimplementedUserServiceServer
}

func (s *userServer) GetUser(ctx context.Context, req *userv1.GetUserRequest) (*userv1.GetUserResponse, error) {
  u, err := dbGet(req.Id)
  if err == sql.ErrNoRows {
    return nil, status.Error(codes.NotFound, "user not found")
  } else if err != nil {
    return nil, status.Error(codes.Internal, "db error")
  }
  return &userv1.GetUserResponse{Id: u.ID, Email: u.Email, Name: u.Name}, nil
}
```

```bash
# Call gRPC with grpcurl (no client code needed)
grpcurl -plaintext localhost:50051 example.user.v1.UserService/GetUser \
  -d '{"id":"123"}'
```

Errors, Retries, and Timeouts
- REST error model
  - HTTP status codes convey coarse categories. Include a JSON body with machine-readable codes and human-readable messages.
  - Typical mapping:
    - 400 Bad Request: validation errors
    - 401 Unauthorized: auth required
    - 403 Forbidden: not allowed
    - 404 Not Found
    - 409 Conflict: duplicate or state conflict
    - 422 Unprocessable: semantic validation failed
    - 429 Too Many Requests: rate limiting
    - 500/502/503/504: server/network errors
  - Retries: safe and idempotent methods (GET, HEAD) can be retried. POST requires idempotency keys if retried.

- gRPC error model
  - gRPC status codes (codes.*) and rich error details through google.rpc.Status:
    - InvalidArgument, NotFound, AlreadyExists, Unauthenticated, PermissionDenied
    - ResourceExhausted (rate limit), FailedPrecondition, Aborted (conflicts), OutOfRange
    - Unimplemented, Internal, Unavailable (retryable), DeadlineExceeded
  - Retries: baked into gRPC service config and proxies (e.g., Envoy) with per-method policies and idempotency awareness.
  - Deadlines and cancellation are first-class: clients set deadlines; servers can observe ctx.Done() to stop work. Cancellation propagates over the wire.

Practical mapping between models (guidance):
- gRPC NotFound ↔ HTTP 404
- InvalidArgument ↔ 400
- AlreadyExists ↔ 409
- ResourceExhausted ↔ 429
- Unauthenticated ↔ 401; PermissionDenied ↔ 403
- Unavailable ↔ 503; DeadlineExceeded ↔ 504
- Internal ↔ 500; Unimplemented ↔ 501
- Aborted/FailedPrecondition ↔ 409/400 depending on semantics

Timeouts and deadlines:
- REST: use server-side timeouts and client request timeouts; communicate Retry-After when applicable.
- gRPC: clients set explicit deadlines per call; servers should respect them and return DeadlineExceeded when exceeded.

Caching and CDNs
- REST
  - Strong out-of-the-box support: Cache-Control, ETag/If-None-Match, Last-Modified/If-Modified-Since, Vary.
  - CDNs and browsers understand HTTP semantics; static and dynamic GETs can be cached with fine-grained control.
  - Conditional requests reduce bandwidth and enable optimistic concurrency.

- gRPC
  - Proxies generally don’t cache gRPC by default. You can add custom caching (e.g., via Envoy filters, application caches) but it requires deliberate design.
  - For public content and global distribution, REST + CDN is typically the simplest, cheapest path.

Security and Auth
- Transport security
  - REST: HTTPS (TLS) is standard. mTLS is common in zero-trust/internal environments.
  - gRPC: also uses TLS; mTLS is common within service meshes. HTTP/2 uses ALPN to negotiate h2.

- AuthN/AuthZ
  - REST: OAuth 2.0 and OpenID Connect for delegated access, JWT bearer tokens, API keys for simple cases. CORS for browser access control.
  - gRPC: send tokens via metadata (authorization: Bearer <token>) or dedicated headers. Integrates with OIDC/JWT, mTLS-based identity, and service meshes for policy (e.g., Istio, Linkerd).
  - Browser specifics: grpc-web uses standard HTTP requests under the hood, so CORS applies.

- CSRF/Clickjacking
  - REST: use same-site cookies, CSRF tokens for cookie-backed auth.
  - gRPC: typically token-based headers; CSRF less of a concern when not using cookies.

Tooling and Developer Experience
- REST tools
  - Specification: OpenAPI (Swagger), JSON Schema.
  - Docs/portals: Swagger UI, Redoc, Stoplight.
  - Testing: curl, httpie, Postman, Insomnia, Newman.
  - Mocking/contract tests: Prism, WireMock, Pact.
  - Client generation: openapi-generator, Swagger Codegen.

- gRPC tools
  - Specification: .proto files (IDL). Code generation for clients/servers in many languages.
  - CLI: grpcurl, evans, ghz (load testing).
  - Ecosystem: Buf (lint/build/breaking-change checks), Prototool, protoc plugins.
  - Gateways: Envoy gRPC-JSON transcoder, grpc-gateway.
  - GUI clients: BloomRPC, Kreya, Insomnia gRPC.

Developer ergonomics
- REST: zero-code clients (curl) and easy browser testing. JSON is human-readable.
- gRPC: strong typing, auto-generated stubs, streaming APIs, better for polyglot microservices. Requires proto discipline and tooling setup.

Observability: Logs, Metrics, Traces
- REST
  - Use structured logs (method, path, status, duration, request-id).
  - Metrics: request rate, latency, error rates, by endpoint and verb.
  - Tracing: OpenTelemetry instrumentation, propagate traceparent header (W3C Trace Context).
  - Correlation IDs: X-Request-ID or trace context headers.

- gRPC
  - Logs: include method name (Service/Method), peer info, status codes.
  - Metrics: per-method latency, message counts (for streams).
  - Tracing: OpenTelemetry with gRPC interceptors automatically capturing spans. Propagate metadata (e.g., grpc-trace-bin, or W3C headers where supported).
  - Deadlines, retries, and cancellations show up in spans—great for troubleshooting.

Platform Support: Browsers, Mobile, Cloud, and Meshes
- Browsers
  - REST: native. CORS handled by server.
  - gRPC: not natively supported due to HTTP/2 and binary framing; use grpc-web via a proxy (Envoy, gRPC-Web) to translate between browser-friendly HTTP and backend gRPC.

- Mobile
  - Both REST and gRPC work. gRPC’s smaller payloads and multiplexing can save battery and data; REST may be simpler if you also need caching/CDN and offline sync with HTTP caches.

- Cloud load balancers and gateways
  - REST: works with any gateway/CDN (CloudFront, Cloudflare, Fastly, API Gateway).
  - gRPC: widely supported by modern L7 proxies (Envoy, NGINX, HAProxy) and managed LBs on major clouds. Some API gateways now forward gRPC and even support transcoding. Verify feature parity (e.g., retries, H/2 keepalives, connection limits).

- Service meshes
  - Both REST and gRPC benefit. gRPC + mesh (e.g., Istio/Envoy) unlocks rich policies (mTLS, retries, timeouts) and telemetry with minimal app code.

Performance & Cost Considerations
- Latency and throughput
  - gRPC with Protobuf is typically faster to parse and smaller over the wire than REST+JSON, especially at scale and with chatty internal services.
  - HTTP/2 multiplexing reduces head-of-line blocking and connection overhead.
  - With HTTP/3 (QUIC), gRPC can further reduce tail latency on lossy networks.
  - REST benefits from CDNs and caching, sometimes dwarfing serialization wins for public reads.

- CPU and memory
  - Protobuf serialization is efficient; big savings under high QPS and large payloads.
  - JSON parsing is CPU-heavy; compression helps bandwidth but not CPU.
  - Consider message compression (gzip, zstd) for both; measure the trade-offs.

- Bandwidth and egress costs
  - Protobuf’s compactness lowers egress costs for internal service-to-service traffic.
  - For public content, CDN caching with REST often saves the most.

- File upload/download
  - REST: multipart/form-data for uploads; range requests for partial downloads; CDNs excel here.
  - gRPC: typically send binary chunks via streaming or use a signed URL with REST/HTTP for the actual transfer; many teams pair gRPC control-plane with HTTP data-plane.

- N+1 and chattiness
  - gRPC’s multiplexing and streaming can mitigate chattiness; batch requests with client streaming or design batch RPCs.
  - REST should minimize round-trips with proper endpoints and query design; consider HTTP/2 to pipeline requests where supported.

API Compatibility and Schema Evolution
- REST
  - Backward compatibility is maintained via additive changes (new optional fields).
  - Removing fields requires deprecation windows; beware breaking clients that assume fields.
  - OpenAPI enables contract checks; use semantic versioning and changelogs.

- gRPC/Protobuf
  - Field numbers are forever; never reuse them after removal.
  - Add fields as optional; reserve removed fields to prevent reuse.
  - oneof for mutually exclusive fields; enums can add values, but default behavior must be safe.
  - Use buf or similar tools to detect breaking changes.

Migration and Hybrid Architectures
- Common patterns
  - Public REST + Internal gRPC: expose REST/JSON to the outside, run gRPC inside the mesh; add a transcoding layer at the edge (Envoy/grpc-gateway).
  - Dual-stack APIs: offer both REST and gRPC endpoints backed by a shared core service/component.
  - Incremental migration: introduce gRPC alongside REST endpoints; route low-risk internal traffic first; keep REST stable for public clients.

- Strategies
  - API gateway with JSON transcoding: keep clients on REST while services speak gRPC.
  - Client libraries: provide gRPC SDKs for trusted partners while keeping REST for general users.
  - Contract-first: define .proto as the source of truth, generate REST via annotations/transcoding rules.

- Pitfalls to avoid
  - Divergent behaviors: ensure REST and gRPC paths enforce the same auth, validation, and rate limits.
  - Error mismatch: map gRPC status codes to HTTP consistently.
  - Shadow fields: keep schemas aligned; generate OpenAPI from proto where possible or vice versa.

Best Practices and Common Pitfalls
- REST best practices
  - Embrace HTTP semantics: status codes, methods, caching.
  - Keep resource modeling consistent; avoid verbs in URLs.
  - Provide rich error bodies with machine-readable codes.
  - Rate limit and provide Retry-After headers; use idempotency keys for unsafe retries.
  - Write clear, versioned docs; publish OpenAPI specs.

- REST pitfalls
  - Overloading POST for everything; ignoring caching; inconsistent pagination.
  - Designing chatty endpoints that require many round-trips when a single purpose-built endpoint would suffice.

- gRPC best practices
  - Set deadlines/timeouts in every client call; enforce server-side timeouts.
  - Use interceptors/middleware for auth, logging, tracing.
  - Define clear package versions (my.app.v1); use FieldMask for updates.
  - Document services; generate client SDKs; lint with buf.
  - Plan streaming semantics carefully; implement backpressure-aware processing.

- gRPC pitfalls
  - Exposing gRPC directly to browsers without grpc-web.
  - Forgetting to propagate cancellations and deadlines.
  - Reusing Protobuf field numbers or making breaking changes without coordination.
  - Overusing fine-grained RPCs causing chattiness; batch where appropriate.

Security Best Practices
- Use TLS everywhere; prefer mTLS in internal networks.
- Validate JWTs/auth tokens at the edge; enforce least-privilege scopes.
- Encrypt sensitive fields at rest and in transit; avoid logs leaking PII.
- For REST: implement CORS carefully; use same-site cookies and CSRF tokens if using cookies.
- For gRPC: use metadata for tokens; standardize on an authorization interceptor.

Testing and Quality Gates
- REST
  - Unit tests for handlers; contract tests using OpenAPI schemas.
  - Integration tests with Postman/Newman or httpie; fuzzing for input validation.
  - Load test with k6, Locust, or JMeter.

- gRPC
  - Unit tests for services; golden tests for protobuf messages.
  - grpcurl-based integration tests; ghz for load testing.
  - Backward-compat checks with buf; reflection enabled in dev/test.

Deployment Notes
- Proxies
  - Envoy is a strong default for gRPC and REST; supports retries, circuit breaking, observability, and JSON transcoding.
  - NGINX and HAProxy can proxy gRPC and REST; verify HTTP/2 settings and keepalive.
- Kubernetes
  - Use readiness/liveness probes; for gRPC consider gRPC health checking protocol.
  - Service meshes add mTLS, routing, and telemetry with minimal code changes.
- Gateways
  - Public edge often terminates TLS and handles rate limiting, WAF, and quotas. Ensure it’s gRPC-aware if you expose gRPC externally.
- Quotas and rate limiting
  - Enforce centrally in the gateway/mesh; expose clear error codes (429 or ResourceExhausted).

File Uploads and Large Messages
- REST
  - Use multipart/form-data for uploads; presigned URLs with object storage to offload servers.
  - Range and resumable uploads supported by many storage services.
- gRPC
  - Prefer streaming chunks with size limits and checksums.
  - For very large files, pair gRPC control with storage-backed HTTP uploads/downloads.

Edge Scenarios
- Partial failures and circuit breaking
  - Implement in the client and via the proxy/mesh. For gRPC, leverage service config/xDS; for REST, gateway policies and client libraries.
- Idempotency
  - REST: idempotency keys for POST; PUT is idempotent by definition.
  - gRPC: use request-idempotency tokens in request messages; configure retry policies only for idempotent methods.
- Ordering and delivery
  - gRPC streams preserve ordering within a single stream. For cross-stream ordering, design explicit sequence semantics.
  - REST doesn’t guarantee ordering across requests; design with version/sequence numbers.

Decision Checklist: REST or gRPC?
Choose REST if:
- You’re building a public API for third-party developers.
- You need first-class browser and CDN support.
- You want to lean on HTTP caching and content negotiation.
- Your workloads are CRUD-heavy without complex streaming.

Choose gRPC if:
- You’re building internal microservices or a polyglot service mesh.
- You need low latency, high throughput, and compact payloads.
- You need bidirectional or client/server streaming.
- You want strict schemas with code generation and strong typing.

Choose a hybrid if:
- You need public developer reach and internal performance.
- You can place a transcoding gateway at the edge.
- You’re migrating without breaking existing clients.

Practical Example: gRPC with REST Transcoding (Envoy)
- You define .proto services and annotate methods with HTTP options (google.api.http) to describe how they map to REST routes.
- Envoy’s grpc-json-transcoder reads the proto descriptors and exposes REST endpoints that translate to gRPC under the hood.
- Benefits: single source of truth (proto), both REST and gRPC clients work, consistent business logic.

Example proto with HTTP annotations
```proto
import "google/api/annotations.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/v1/users/{id}"
    };
  }

  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (google.api.http) = {
      post: "/v1/users"
      body: "*"
    };
  }
}
```

Then configure Envoy to load the proto descriptors and expose the REST paths. REST clients see JSON; backend services keep using gRPC+Protobuf.

Common Questions (FAQs)
- Can I use gRPC from the browser?
  - Not directly. Use grpc-web with a proxy (Envoy or gRPC-Web server) that translates browser-friendly requests into gRPC.

- Is gRPC always faster than REST?
  - It often is for service-to-service traffic due to Protobuf and HTTP/2 multiplexing. But for public APIs, CDN caching and simpler infra can make REST perform better overall. Always measure in your context.

- Does gRPC support HTTP/3?
  - Several language runtimes and proxies support gRPC over HTTP/3. Verify support in your stack and test end-to-end, especially with middleboxes.

- Can I use JSON with gRPC?
  - Yes, via transcoding/gateways or some libraries’ JSON marshalling. Protobuf remains the on-the-wire default for standard gRPC.

- What about GraphQL?
  - GraphQL solves a different problem: flexible client-driven data fetching. It often complements REST and gRPC rather than replacing them, and typically runs over HTTP.

- How do I version gRPC APIs?
  - Use package/service versioning (my.app.v1). Keep field additions backward-compatible; avoid removing/renumbering fields.

- How do I handle long-running operations?
  - REST: return 202 Accepted and expose operation status endpoints; use webhooks or SSE for updates.
  - gRPC: use server streaming to push progress, or return an operation ID and poll via unary RPC; deadlines and cancellation help control execution.

- Can I expose both REST and gRPC on the same service?
  - Yes. Either run two listeners or use a gateway/transcoder to bridge. Keep behavior consistent across both.

Hands-on Performance Tips
- Enable compression (gzip or zstd) for large payloads on both REST and gRPC; set thresholds to avoid compressing tiny messages.
- Reuse connections; for gRPC, maintain channels; for REST, enable keep-alives and HTTP/2.
- Tune timeouts and retries conservatively to avoid retry storms; apply jittered exponential backoff.
- Validate and bound inputs; guard against huge JSON or Protobuf messages; set max message sizes.
- For streaming, implement flow control and backpressure-awareness.

Choosing: A Simple Heuristic
- Public web, partners, and browsers first? Start REST. Consider adding gRPC later for SDKs/internal services.
- Internal microservices, ML inference, or real-time streams? Start gRPC. Add REST via transcoding where needed.
- Mixed needs? Proto-first with Envoy transcoding offers a strong center of gravity.

Summary
REST and gRPC aren’t adversaries—they’re tools for different jobs. REST’s universality, human-friendliness, and HTTP semantics make it the default for public APIs and anything browser-facing. gRPC’s compact, strongly typed, streaming-friendly model shines for internal microservices, high-performance systems, and polyglot environments.

You don’t have to pick one forever. Many successful architectures use a hybrid: gRPC inside for speed and schema rigor, REST/JSON at the edge for reach and simplicity. Start with your constraints—clients, latency, bandwidth, tooling, and team expertise—then choose the protocol that reduces total system complexity.

If you remember just three things:
1) REST maximizes reach and cacheability; gRPC maximizes efficiency and streaming.
2) Strong schemas pay off: OpenAPI for REST, Protobuf for gRPC—automate codegen, docs, and breaking-change checks.
3) Measure in production-like conditions; let data, not dogma, guide your choice.