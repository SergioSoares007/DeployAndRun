---
title: "JSON-RPC"
date: 2025-08-17T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["AI", "JSON-RPC", "API"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "JSON-RPC: A Complete and In-Depth Guide to the Lightweight Remote Procedure Call Protocol"
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

# **JSON-RPC: A Complete and In-Depth Guide to the Lightweight Remote Procedure Call Protocol**

Remote Procedure Call (RPC) systems have been part of software engineering for decades, long before REST, GraphQL, or gRPC entered the scene. Among the many RPC variants, **JSON-RPC** stands out for its simplicity, language neutrality, and minimal overhead. In an increasingly interconnected digital landscape, where microservices, distributed back ends, IoT platforms and blockchain ecosystems depend on clean and efficient interfaces, JSON-RPC has seen a strong resurgence.

This article provides **a comprehensive, deep, and highly detailed exploration of JSON-RPC**, covering:

* What JSON-RPC is and what it is not
* The specification and its fundamental elements
* Message formats, data structures, and transport mechanisms
* Error handling
* Notifications vs requests
* Batch operations
* Version differences (1.0, 2.0, and informal extensions)
* Security considerations
* Tooling, libraries, and ecosystem usage
* Comparisons with other API styles (REST, gRPC, GraphQL, SOAP, etc.)
* A **historical timeline** of APIs and how JSON-RPC fits into their evolution
* Strengths, weaknesses, and recommended usage contexts

This is not a surface-level overview: it is a deep technical examination aimed at architects, engineers, and developers seeking a detailed understanding.

---

# **1. What Is JSON-RPC?**

JSON-RPC is a **lightweight Remote Procedure Call protocol** encoded in JSON, defined by a minimal specification that focuses on clarity and extensibility. The core idea is straightforward:

> *A client sends a JSON object that represents a method call. The server performs the method and returns a JSON object containing the result or an error.*

Unlike REST—which is resource-oriented and built around HTTP conventions—JSON-RPC is **operation-oriented**: the client directly calls a named method on a remote system.

---

## **1.1 Key Characteristics**

JSON-RPC has several distinctive properties:

* **Transport-agnostic**: it can run over HTTP, WebSockets, TCP sockets, pipes, or even embedded transports.
* **Stateless by design**, unless layered on top of a stateful transport.
* **No predefined verbs** such as GET/POST; the protocol focuses on method calls.
* **Lightweight and minimal**: the specification defines only what is strictly necessary.
* **Language-agnostic** thanks to JSON encoding.
* **Supports both synchronous responses and notifications** (no reply expected).
* **Supports batch calls** (multiple operations in a single payload).

---

# **2. Why JSON-RPC Exists: The Motivation Behind Its Design**

Historically, RPC systems—such as ONC RPC, XML-RPC, and CORBA—were seen as powerful but heavy, tightly coupled, or difficult to interoperate with across languages. XML-RPC simplified this but suffered from XML verbosity.

JSON-RPC appeared with a clearer goal:

* Reduce boilerplate
* Make RPC web-friendly without relying on XML
* Provide deterministic structures
* Enable use cases like browsers, JavaScript apps, embedded devices, and blockchain clients

JSON-RPC thrives where **low overhead**, **consistent schema**, and **simple integration** matter.

---

# **3. The JSON-RPC Specification Explained**

The latest and most widely used version is **JSON-RPC 2.0**. Its specification defines the exact shape of valid messages.

---

## **3.1 Core Message Structure**

A request must contain:

```json
{
  "jsonrpc": "2.0",
  "method": "subtract",
  "params": [42, 23],
  "id": 1
}
```

A response must contain either:

A **result**:

```json
{
  "jsonrpc": "2.0",
  "result": 19,
  "id": 1
}
```

Or an **error**:

```json
{
  "jsonrpc": "2.0",
  "error": {
    "code": -32601,
    "message": "Method not found"
  },
  "id": 1
}
```

---

## **3.2 The `jsonrpc` Field**

This value **must** be `"2.0"` in the 2.0 specification. It keeps compatibility explicit.

---

## **3.3 Methods**

Methods are strings naming the remote operation, such as:

* `"getUser"`
* `"file.upload"`
* `"math.divide"`

The specification allows dot notation but does not define semantics; it's up to implementers.

---

## **3.4 Parameters**

Parameters can be:

* **Positional**: an array of arguments
* **Named**: an object with keyed arguments

Both are legal:

Positional:

```json
"params": ["Alice", 30]
```

Named:

```json
"params": { "name": "Alice", "age": 30 }
```

---

## **3.5 The `id` Field**

The `id` identifies which request the response belongs to.

* Can be a string, number, or null
* Must be present for responses
* Notifications use **no `id`**

---

# **4. Notifications: Fire-and-Forget RPC**

A notification is a method call where the client **does not expect a response**.

Example:

```json
{
  "jsonrpc": "2.0",
  "method": "logActivity",
  "params": { "event": "login", "user": 123 }
}
```

Notifications are ideal for:

* Logging events
* Streaming metrics
* Triggering asynchronous work
* Pub/sub-like patterns

Because the server must not reply to them, error reporting happens out of band.

---

# **5. Batch Requests**

A batch is an array of requests:

```json
[
  { "jsonrpc": "2.0", "method": "add", "params": [1,2], "id": 1 },
  { "jsonrpc": "2.0", "method": "subtract", "params": [5,3], "id": 2 }
]
```

Responses are returned in an array.
Batches may contain a mix of requests and notifications.

Batching improves throughput and can reduce network overhead significantly.

---

# **6. Error Handling**

JSON-RPC defines **standard error codes**, for example:

| Code           | Meaning                  |
| -------------- | ------------------------ |
| -32700         | Parse error              |
| -32600         | Invalid request          |
| -32601         | Method not found         |
| -32602         | Invalid params           |
| -32603         | Internal error           |
| -32000..-32099 | Server errors (reserved) |

The error object:

```json
{
  "code": -32600,
  "message": "Invalid Request",
  "data": { "field": "params" }
}
```

The `data` field is optional but useful for debugging.

---

# **7. Transport Layer Considerations**

Although often used over **HTTP POST**, JSON-RPC is fundamentally **transport-independent**.

### Common transports:

* **HTTP**
* **WebSockets**
* **TCP or Unix sockets**
* **Named pipes**
* **Message brokers (e.g., RabbitMQ)**
* **Blockchain P2P protocols**

REST strongly binds itself to HTTP semantics; JSON-RPC does not. This makes JSON-RPC viable in environments where HTTP is suboptimal or impossible.

---

# **8. Security: What JSON-RPC Does and Does Not Provide**

JSON-RPC:

❌ **Does not define authentication**
❌ **Does not define authorisation**
❌ **Does not define encryption**
❌ **Does not define rate-limiting**

These are considered **transport-level or application-level responsibilities**.

Security recommendations include:

* Use HTTPS or secure WebSockets
* Implement API keys, JWT, OAuth2 or custom tokens
* Validate input rigorously
* Restrict method exposure

JSON-RPC is minimal, and this is intentional.

---

# **9. JSON-RPC Versions**

### **9.1 JSON-RPC 1.0**

* No named parameters
* No batch requests
* `id` required
* Much less standardised
* Very small adoption today

### **9.2 JSON-RPC 2.0 (most used)**

* Formalised specification
* Named + positional params
* Batch requests
* Notifications
* Error object standardisation

### **9.3 Informal Extensions**

Some communities introduce optional fields, e.g.:

* `"jsonrpc": "2.1"` (not official)
* extra metadata
* server streaming conventions

However, these are **not part of the formal spec**.

---

# **10. Real-World Uses of JSON-RPC**

JSON-RPC is widely used across:

### **10.1 Blockchain Ecosystems**

Many blockchain nodes expose JSON-RPC interfaces:

* Ethereum
* Bitcoin
* Monero
* Avalanche
* Polygon
* Arbitrum / Optimism L2 nodes

### **10.2 Microservices**

JSON-RPC is lighter than REST and easier than gRPC in:

* embedded devices
* internal service-to-service calls
* low-overhead environments

### **10.3 Desktop Applications / Browser Add-ons**

Because JSON is native to JavaScript, JSON-RPC suits:

* browser extensions
* Electron apps
* local integration bridges

### **10.4 Databases and Servers**

Some databases offer JSON-RPC endpoints for control or admin operations.

---

# **11. A Chronological History of APIs and How JSON-RPC Fits In**

To appreciate JSON-RPC, it helps to understand the wider evolution of API styles.

---

## **11.1 Early Days: RPC in the 1970s–1980s**

The original RPC systems (SunRPC / ONC RPC, later CORBA):

* tightly coupled
* strongly typed
* used binary protocols
* required IDL files
* difficult cross-platform portability

They solved distributed computing but were rarely web-friendly.

---

## **11.2 The 1990s: SOAP and XML-RPC**

### **XML-RPC (1998)**

Lightweight, simpler RPC with XML encoding. Inspired JSON-RPC directly.

### **SOAP (1999–2005 peak)**

Enterprise-grade, verbose, with WSDL and schemas. Powerful but extremely heavy.

Strengths:

* strongly typed
* broad tool support
* formal contracts

Weaknesses:

* bloated XML
* slow parsing
* friction for web/mobile

---

## **11.3 Early 2000s: REST Takes Over**

REST (Representational State Transfer), conceptualised in 2000, exploded with the rise of APIs like:

* Twitter API
* Stripe API
* Facebook Graph API (conceptually REST-ish)

Strengths:

* simple
* leverages HTTP verbs
* easy caching

Weaknesses:

* resource-oriented, not action-oriented
* sometimes verbose
* poor at real-time interactions
* no standard for errors or metadata

---

## **11.4 Late 2010s: GraphQL and gRPC**

### **GraphQL (2015)**

Query-based, flexible, strongly typed schema.

Strengths:

* client-driven queries
* single endpoint
* avoids over/under-fetching

Weaknesses:

* server complexity
* over-fetching not always eliminated
* caching and HTTP semantics weaker

### **gRPC (2016)**

Binary, fast, contract-first.

Strengths:

* ultra-fast
* streaming support
* strongly typed

Weaknesses:

* complicated tooling
* learning curve
* not ideal for browser apps

---

## **11.5 JSON-RPC Through This History**

JSON-RPC emerged (informally early 2000s, later formalised as 2.0) as a reaction to:

* XML verbosity
* REST overload for simple RPC use cases
* heavy enterprise systems
* lack of standardisation in many lightweight RPC mechanisms

It occupies a “sweet spot” between:

* the **simplicity of REST**,
* the **directness of RPC**, and
* the **developer friendliness of JSON**.

---

# **12. Comparing JSON-RPC With Other API Paradigms**

## **12.1 JSON-RPC vs REST**

| Aspect                | JSON-RPC                                     | REST                        |
| --------------------- | -------------------------------------------- | --------------------------- |
| Style                 | Operation-based                              | Resource-based              |
| Methods               | Arbitrary names                              | GET/POST/PUT/DELETE         |
| Transport             | Any                                          | Primarily HTTP              |
| Flexibility           | High                                         | Medium                      |
| Ease of documentation | Medium                                       | High                        |
| Standardisation       | Medium                                       | Medium-High                 |
| Ideal for             | Internal services, blockchain, microservices | Public APIs, CRUD resources |

REST is better for public web APIs; JSON-RPC is better for internal or specialised operational APIs.

---

## **12.2 JSON-RPC vs GraphQL**

| Aspect            | JSON-RPC         | GraphQL               |
| ----------------- | ---------------- | --------------------- |
| Query flexibility | Fixed methods    | Client-driven queries |
| Payload size      | Lean             | May be heavy          |
| Learning curve    | Low              | Medium-High           |
| Ideal for         | Known operations | Complex data fetching |

GraphQL is far more expressive but far more complex.

---

## **12.3 JSON-RPC vs gRPC**

| Aspect          | JSON-RPC    | gRPC                 |
| --------------- | ----------- | -------------------- |
| Encoding        | JSON (text) | Protobuf (binary)    |
| Speed           | Moderate    | Very high            |
| Browser support | Native      | Requires web proxies |
| Streaming       | Not native  | First-class          |
| Contracts       | Loose       | Strong               |

gRPC wins in performance; JSON-RPC wins in simplicity and compatibility.

---

## **12.4 JSON-RPC vs SOAP**

JSON-RPC is essentially the opposite of SOAP:

* simple vs complex
* lightweight vs heavyweight
* human-readable vs verbose XML

SOAP still dominates some enterprise sectors, but JSON-RPC is preferred for modern, lean API design.

---

# **13. Capabilities, Strengths, and Advantages of JSON-RPC**

### **13.1 Core Strengths**

* Extremely simple
* Low overhead
* Highly interoperable
* Ideal for distributed systems
* Works well with JavaScript environments
* Easy to debug (text-based JSON)
* Decouples logic from transport

### **13.2 Performance Advantages**

JSON parsing is fast and ubiquitous. Unlike REST, JSON-RPC avoids:

* multiple endpoints
* HTTP verb semantics
* redundant headers
* resource modelling

The result is **efficient, direct remote calls**.

---

# **14. Weaknesses and Limitations**

JSON-RPC is not a universal solution. Weaknesses include:

* No built-in authentication
* No schema/contract enforcement
* No standard type system
* Harder to document than OpenAPI/REST
* Verbose compared to gRPC
* Not optimised for streaming workflows

For large public APIs, REST or GraphQL often provide a more structured experience.

---

# **15. When to Use JSON-RPC**

### **Ideal Scenarios**

* Internal microservices
* Robotics and hardware with lightweight interfaces
* Distributed systems with many method calls
* Blockchain node communication
* Real-time apps using WebSockets
* Embedded systems or IoT devices

### **Less Suitable Scenarios**

* Public consumer-facing APIs
* Scenarios requiring strong type contracts
* Environments requiring schema evolution support
* Use cases with heavy data streaming

---

# **16. Best Practices for Implementing JSON-RPC**

### **16.1 Use Named Parameters Whenever Possible**

It improves clarity and forwards compatibility.

### **16.2 Provide Strong Documentation**

Even though the spec is minimal, documentation should not be.

### **16.3 Validate Inputs Thoroughly**

JSON-RPC gives you full responsibility for validation.

### **16.4 Use Transport-Level Security**

Always prefer:

* HTTPS
* Secure WebSockets

### **16.5 Consider Adding Your Own Contract Layer**

E.g., JSON Schema, OpenRPC (an emerging spec), or language-specific metadata.

---

# **17. JSON-RPC in Modern Software Architecture**

JSON-RPC fits into:

* internal mesh networks
* blockchain clients (its most prominent use today)
* high-performance control systems
* server extension APIs

Its minimalism remains relevant even as new paradigms emerge.

---

# **18. Conclusion**

JSON-RPC is an elegant, minimal, and powerful protocol that continues to thrive in areas where:

* low overhead
* direct method invocation
* language neutrality
* transport flexibility

are essential.

While REST, GraphQL, and gRPC each dominate in their well-defined domains, JSON-RPC remains a perfect tool for the right scenarios—especially in distributed, internal, or specialised systems where simplicity, performance, and developer friendliness come first.

JSON-RPC is not a full API ecosystem on its own; rather, it is a **precise instrument**. For architects and developers who understand its strengths and limitations, it offers a robust foundation for remote method invocation in the modern computing landscape.

If you need help generating diagrams, examples, tutorial code, or a condensed version of this article, just let me know.
