---
title: "Redis + Kafka not equal to CQRS - Command Query Responsibility Segregation"
date: 2025-09-21T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Redis", "Kafka", "Event Driven", "Cache"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Reference Architecture: Redis + Kafka for Fast Reads and Event Propagation"
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

# Reference Architecture: Redis + Kafka for Fast Reads and Event Propagation

## 1. Purpose

This document describes a **reference architecture** where:

* **Redis** is used to accelerate synchronous read paths
* **Kafka** is used to propagate state changes asynchronously
* The **application layer** is the sole coordinator of state and events

This architecture optimises for:

* Low latency API responses
* Decoupled downstream processing
* Independent scaling of consumers
* Eventual consistency across systems

It does **not** assume microservices, CQRS, or event sourcing by default.

---

## 2. Architecture Responsibilities

### API Gateway

* Entry point only
* Authentication, routing, rate limiting
* **No domain logic**
* **No Redis access for business data**
* **No Kafka publishing**

---

### Application Service

The **only intelligent component**.

Responsibilities:

* Execute business rules
* Read/write Redis
* Read/write the database
* Publish domain events to Kafka

This is the **system boundary** where consistency is decided.

---

### Redis

* In-memory cache
* Stores *current state*
* Data is:

  * derived
  * ephemeral
  * replaceable
* TTL-based eviction
* No guarantees of durability

Redis is an **optimisation**, never a source of truth.

---

### Primary Database

* Source of truth
* Strong consistency
* Transactional writes
* Schema and constraints

---

### Kafka

* Append-only event log
* Durable
* Replayable
* Asynchronous fan-out

Kafka stores **facts**, not state:

> “Something happened” — not “this is the current value”.

---

### Consumer Applications

* Subscribe independently
* Maintain their own state or side effects
* May use Redis, databases, or other stores
* Never call back into the producer synchronously

---

## 3. The Honest Data Flow

### Read Path (Synchronous)

1. Client sends request
2. Application checks Redis
3. Cache hit → immediate response
4. Cache miss → read from DB → populate Redis → respond

Redis accelerates *now*.

---

### Write Path (State Change)

1. Client triggers a write
2. Application writes to DB (transaction)
3. Application publishes a Kafka event
4. Consumers react asynchronously

Kafka propagates *what changed*.

---

## 4. Diagram That Does Not Lie

```
                 ┌──────────────┐
                 │    Client    │
                 └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │ API Gateway  │
                 └──────┬───────┘
                        │
                        ▼
        ┌────────────────────────────────┐
        │        Application Service     │
        │                                │
        │  ┌─────────────┐   ┌────────┐ │
        │  │   Redis     │◄──►│ Logic  │ │
        │  └─────────────┘   └────────┘ │
        │          ▲              │     │
        │          │              ▼     │
        │    Cache read/write   ┌──────┐│
        │                       │  DB  ││
        │                       └──────┘│
        │          │              │     │
        │          └──── publish ─┴───┐ │
        └────────────────────────────┼─┘
                                     ▼
                              ┌──────────┐
                              │  Kafka   │
                              └────┬─────┘
                                   │
                 ┌─────────────────┼─────────────────┐
                 ▼                 ▼                 ▼
        ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
        │  Analytics   │  │   Email      │  │  Audit Log   │
        └──────────────┘  └──────────────┘  └──────────────┘
```

**Key truths this diagram enforces:**

* API Gateway never touches Redis or Kafka
* Redis is only accessed by the application
* Kafka is write-only from the application
* Consumers never synchronously affect the request path

---

## 5. Failure Scenarios (Reality, Not Slides)

### 5.1 Cache Stampede

**Scenario**

* Redis key expires
* Many concurrent requests miss cache
* All hit the database

**Mitigations**

* Request coalescing / mutex keys
* Probabilistic early refresh
* Stale-while-revalidate
* TTL jitter

Redis does not solve this for you — the application must.

---

### 5.2 Cache Inconsistency

**Scenario**

* DB write succeeds
* Redis update fails
* Stale data served

**Reality**

* This is acceptable by design
* Redis is not authoritative

**Mitigations**

* Short TTLs
* Explicit invalidation on write
* Event-driven cache refresh (optional)

---

### 5.3 Duplicate Kafka Events

**Scenario**

* Producer retries
* Consumer rebalances
* Event processed more than once

**This is normal.**

**Required Consumer Properties**

* Idempotency
* Deduplication via event IDs
* Upsert semantics, not blind inserts

Kafka guarantees *at least once*, not *exactly once* in practice.

---

### 5.4 Out-of-Order Consumption

**Scenario**

* Multiple partitions
* Parallel consumers
* Temporal reordering

**Mitigations**

* Keyed partitioning
* Version checks
* Last-write-wins logic

Ordering is a **design constraint**, not a Kafka feature.

---

## 6. Comparison with CQRS

### This Architecture

* Single model
* Redis is a cache, not a read model
* Kafka events are side effects
* Database is the source of truth

### CQRS

* Separate read and write models
* Kafka (or similar) often feeds read models
* Redis may store read projections
* Explicit eventual consistency

**Key difference**

> This architecture *can evolve into CQRS*, but is not CQRS by default.

---

## 7. Comparison with Event Sourcing

### This Architecture

* DB stores current state
* Kafka stores events as notifications
* Events are not authoritative
* Replay is optional

### Event Sourcing

* Event log is the source of truth
* State is rebuilt from events
* Redis stores derived projections
* Replay is mandatory and fundamental

**Key difference**

> Kafka is a messaging backbone here, not the system of record.

---

## 8. What This Architecture Is (and Is Not)

### It *is*

* A pragmatic, production-proven pattern
* Suitable for most CRUD + side-effect systems
* Easy to reason about operationally

### It is *not*

* A CQRS implementation
* Event sourcing
* A “Redis + Kafka platform”
* A magical scalability solution

---

## 9. Final Mental Model

* **Redis** → “What is the value *right now*?”
* **Database** → “What is the correct value?”
* **Kafka** → “Something changed”
* **Application** → “Why and how it changed”

If you remove the application from the centre, the system collapses.

---
