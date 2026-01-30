---
title: "27 Development Rules for High-Performance webMethods Solutions"
date: 2025-10-12T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["webMethods", "Code for performance"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "27 Development Rules for High-Performance webMethods Solutions"
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

# 27 Development Rules for High-Performance webMethods Solutions

Integration platforms rarely fail because of a single architectural mistake.
Performance degradation is usually the cumulative effect of **many small design and development decisions**, repeated thousands or millions of times per day.

The following **27 development rules** were established based on real-world analysis of webMethods Integration Server solutions, production incidents, GC investigations, and performance tuning exercises.

They are intended to be used as **development norms**, not optional tips.

---

## Core principles

Before diving into the rules, three principles should guide all development:

* Design with **performance and maintainability from day one**
* Treat **service boundaries** explicitly
* Prefer **clarity and predictability** over cleverness

---

## 1. Drop pipeline variables as early as possible

Variables that are no longer needed should be removed from the pipeline immediately, not only at the end of the service.

Early removal:

* reduces memory consumption during execution,
* lowers GC pressure,
* improves pipeline readability.

This should not be confused with clearing the pipeline at the end of execution, which does not help intermediate memory usage.

---

## 2. Define service signatures first

The service signature should be the second step after naming the service.

A service must:

* expose only what is defined in its output signature,
* never leak internal or temporary structures.

Clear signatures improve:

* reuse,
* testability,
* long-term maintainability.

---

## 3. Avoid `SELECT *` in database queries

Database queries should retrieve **only the required columns**.

Avoiding `SELECT *`:

* reduces I/O,
* lowers memory usage,
* improves query performance,
* prevents accidental coupling to schema changes.

---

## 4. Use Java Services for intensive logic

Java Services generally outperform Flow Services when dealing with:

* CPU-intensive logic,
* deep or frequent loops,
* large document lists,
* high-frequency utility logic.

Flow Services are best suited for orchestration and integration glue.

---

## 5. Prefer Transformers over Invoke steps

Transformers:

* operate on explicitly mapped inputs,
* avoid cloning the full parent pipeline,
* reduce pipeline size and lookup time.

In large pipelines, this can provide measurable performance improvements.

---

## 6. Cache static and reference data

Static or low-mutability data (e.g. reference data) should be cached.

Caching:

* avoids repeated backend calls,
* improves response times,
* reduces load on external systems.

Cache lifecycle (TTL, invalidation) must be clearly defined.

---

## 7. Treat public services as strict boundaries

Public (top-level) services:

* are invoked by triggers or external systems,
* represent clear integration boundaries.

They should:

* implement consistent error handling,
* enable auditing appropriately,
* never expose internal exceptions directly.

---

## 8. Remove disabled Flow steps

Disabled Flow steps still introduce evaluation overhead during execution.

They:

* clutter the flow,
* reduce readability,
* add unnecessary CPU cost.

They do not belong in production code.

---

## 9. Always define timeouts

Timeouts are defined by the consumer.

When Integration Server acts as a client (HTTP, REST, SOAP, JDBC, FTP, etc.), **timeouts must be explicitly configured**, preferably short.

Long or missing timeouts:

* block service threads,
* exhaust thread pools,
* lead to cascading failures.

---

## 10. Use document references in service signatures

Document references:

* promote reuse,
* simplify signature evolution,
* reduce mapping effort for large documents.

They are especially valuable for complex, nested structures.

---

## 11. Choose Flow vs Java consciously

Flow Services:

* are visual,
* easier to read and maintain,
* interpreted at runtime.

Java Services:

* are compiled,
* provide better throughput under load,
* scale better for intensive processing.

Choose based on workload characteristics, not convenience.

---

## 12. Name services like Java methods

Service names should be:

* concise,
* expressive,
* action-oriented.

Good naming improves discoverability and understanding
(e.g. `processPurchaseOrder`, not `service1`).

---

## 13. Always close I/O resources

I/O services and readers are not always closed automatically.

Unclosed resources:

* cause leaks,
* increase memory pressure,
* degrade performance over time.

Ensure streams, readers, and writers are explicitly closed.

---

## 14. Use regular expressions where appropriate

A well-designed regex can:

* simplify logic,
* reduce the number of processing steps,
* improve performance by scanning strings once.

Regex can be used in:

* branches,
* link mappings,
* string services.

---

## 15. Avoid spaghetti flows (anti-pattern)

Keep Flow Services:

* small,
* modular,
* focused on a single responsibility.

Deeply nested, monolithic flows quickly become unmaintainable and inefficient.

---

## 16. Minimise MAP steps

Unnecessary MAP steps:

* increase pipeline size,
* add execution overhead.

Find a balance between:

* readability,
* performance.

Combine MAP steps when possible without harming clarity.

---

## 17. Avoid incremental list appends for large lists

Services such as:

* `appendToDocumentList`
* `appendToStringList`

reallocate and copy arrays on every call.

For large lists, use:

* vectors,
* Java collections,
* then convert to arrays if needed.

This significantly reduces CPU and GC overhead.

---

## 18. Validate documents once per boundary

Input validation should occur:

* once,
* at the service boundary.

Avoid repeated calls to `pub.schema:validate` in:

* loops,
* nested services.

Redundant validation is expensive and unnecessary.

---

## 19. Debugging tools are not for production

The following should only be used temporarily for debugging:

* pipeline debug
* `pub.flow:tracePipeline`
* `pub.flow:savePipeline*`
* `pub.flow:restorePipeline*`

Leaving them enabled in production causes severe overhead and risks data exposure.

---

## 20. Avoid Guaranteed Delivery unless explicitly required

`pub.remote.gd:*` services introduce significant overhead.

Use Guaranteed Delivery only when:

* message durability is a strict requirement,
* asynchronous retry semantics are needed.

Otherwise, prefer standard remote invocation.

---

## 21. Use shared storage carefully

Shared storage:

* uses implicit locking,
* is not designed as a high-performance database.

For frequent access patterns, prefer:

* in-memory cache mechanisms.

---

## 22. Use streaming for large payloads

For large documents:

* use streams,
* avoid buffering entire payloads in memory.

When using HTTP, define `Content-Length` to allow more efficient processing by Integration Server.

---

## 23. Use multithreading with care

Parallel processing can improve throughput, but it:

* increases complexity,
* increases contention risk.

Design first.
Parallelise only when the gain is clear and measurable.

---

## 24. Never validate documents inside loops

Document validation is expensive.

Validating inside loops multiplies overhead and should be avoided entirely.

---

## 25. Use batch operations for database inserts

Batching:

* reduces network round-trips,
* lowers transaction overhead,
* improves throughput significantly.

Always prefer batch inserts when processing large volumes.

---

## 26. Understand JDBC transaction modes

Choose JDBC connection transaction modes deliberately:

* **No Transaction** – auto-commit, no transactional guarantees
* **Local Transaction** – managed by Integration Server
* **XA Transaction** – distributed transactions

Transaction mode must match service boundaries and error-handling strategy.

---

## 27. Design error handling deliberately

Follow the principle:

> **Handle or throw — never both everywhere**

Errors should:

* be handled at service boundaries,
* be propagated in internal services unless recovery is possible.

This results in predictable behaviour and cleaner code.

---

## Final thoughts

High-performance integration solutions are not the result of a single optimisation.
They emerge from **consistent discipline applied across the entire codebase**.

When these rules are followed:

* pipelines stay lean,
* GC behaviour stabilises,
* infrastructure tuning becomes easier,
* production incidents become rarer.

Performance is not accidental.
**It is designed.**

---
