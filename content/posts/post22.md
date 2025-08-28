---
title: "Kafka Protocol, AsyncAPI, and Event‑Driven Architecture"
date: 2025-06-01T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Apache Kafka", "AsyncAPI", "event driven architecture"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Kafka Protocol, AsyncAPI, and Event‑Driven Architecture"
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
# Kafka Protocol, AsyncAPI, and Event‑Driven Architecture: A Practical Guide

If you’re building reactive, loosely-coupled systems, you’ll encounter three recurring themes: event-driven architecture (EDA), Apache Kafka, and AsyncAPI. This article ties them together. We’ll start with EDA fundamentals, peek under Kafka’s hood (protocol, delivery semantics, consumer groups), and show how AsyncAPI helps you design and govern your event contracts—backed by code examples you can run.

## Why Event‑Driven Architecture?

Event-driven architecture is an approach where services communicate by publishing and consuming events (facts about things that happened), instead of making synchronous calls.

- Core concepts:
  - Event: an immutable fact (“OrderCreated”, “PaymentCaptured”).
  - Producer: publishes events.
  - Consumer: reacts to events.
  - Broker: transports and stores events (e.g., Kafka).
- Benefits:
  - Loose coupling: producers and consumers don’t know each other.
  - Scalability: consumers scale horizontally by partition.
  - Resilience: decoupling reduces blast radius of failures.
  - Extensibility: new consumers can subscribe without changing producers.
- Trade-offs:
  - Eventual consistency: reads may lag writes.
  - Complexity: debugging flows and data governance need careful tooling.
  - Delivery semantics: duplicates and reordering must be handled.

Kafka is a natural fit for EDA because it combines a durable, partitioned log with high-throughput networking and mature client libraries.

---

## Kafka in EDA: The Pieces That Matter

- Topics and partitions: A topic is split into partitions for parallelism. Records within a partition are strictly ordered by offset.
- Keys and ordering: Records with the same key land on the same partition, preserving per-key order (e.g., all events for a given orderId).
- Brokers and replication: Leaders serve reads/writes; followers replicate. min.insync.replicas + acks=all protect against data loss.
- Consumer groups: Consumers in the same group share the work; each partition is assigned to exactly one consumer in the group for parallel consumption.
- Offsets: Consumers track progress per partition (committed offsets). Kafka stores them in an internal topic (__consumer_offsets).
- Delivery semantics:
  - At-most-once: commit before processing (fast, risky).
  - At-least-once: process then commit (most common; requires idempotency).
  - Exactly-once: transactional writes and offset commits (Kafka EOS).

---

## Kafka Protocol: What’s Actually on the Wire

Kafka’s protocol is a binary, length‑prefixed, request–response protocol over TCP. You rarely implement it by hand—use official clients—but understanding it helps with performance, debugging, and compatibility.

- Framing: Each request/response starts with a 4‑byte length. Messages are multiplexed by correlationId.
- Versioned APIs: Every API (Produce, Fetch, ListOffsets, Metadata, JoinGroup, etc.) has versions for rolling upgrades and new features.
- Flexible versions: Newer versions use “tagged fields” for extensibility without breaking older clients.
- Authentication & encryption: TLS for encryption; SASL mechanisms (PLAIN, SCRAM, OAUTHBEARER, mTLS) for auth; ACLs for authorization.

Request header (conceptual, simplified for flexible versions):
```
int32  length                     // not part of header field list; framing
int16  api_key                    // e.g., Produce=0, Fetch=1
int16  api_version
int32  correlation_id
string client_id
tagged_fields                     // flexible schema extension
```

Produce/Fetch payloads carry record batches. The record batch format (v2) enables compression and idempotency.

RecordBatch v2 (simplified):
```
int64  baseOffset
int32  batchLength
int32  partitionLeaderEpoch
int8   magic = 2
int32  crc
int16  attributes                 // compression, isTransactional, timestampType
int32  lastOffsetDelta
int64  baseTimestamp
int64  maxTimestamp
int64  producerId
int16  producerEpoch
int32  baseSequence
array  records[]                  // individual records with headers
```

Idempotent producers:
- Each partition append has a monotonic sequence number tracked by broker per (producerId, producerEpoch, partition).
- Retries won’t create duplicates as long as ordering is preserved.

Transactions (EOS):
- APIs like InitProducerId, AddPartitionsToTxn, AddOffsetsToTxn, EndTxn coordinate atomic writes across topics and offset commits, plus transaction markers visible to consumers.

Consumer group coordination:
- JoinGroup, SyncGroup, Heartbeat manage membership and assignments.
- Rebalancing strategies include range, round-robin, and cooperative-sticky (reduces stop-the-world rebalances).

You likely won’t touch these primitives directly—but they explain why Kafka can offer high throughput, idempotency, and compatibility guarantees.

---

## AsyncAPI: Contracts for Event‑Driven Systems

AsyncAPI is to events what OpenAPI is to REST. It’s a specification to describe:
- Servers/brokers (Kafka, MQTT, AMQP, WebSockets)
- Channels (topics/subjects/queues)
- Operations (publish/subscribe semantics)
- Messages (payloads and headers)
- Schemas (JSON Schema/Avro/Protobuf)
- Protocol bindings (Kafka-specific settings)

Why it matters:
- Design-first: Align teams on event names, payloads, and delivery semantics before coding.
- Documentation: Human- and machine-readable specs for discovery.
- Tooling: Generate code, mocks, tests, and docs from a single source of truth.
- Governance: Versioning, validation, and compatibility checks.

---

## Modeling Kafka Events with AsyncAPI

Here’s a compact AsyncAPI 2.6.0 example for Kafka, modeling an OrderCreated event and standard retry/DLQ channels.

```yaml
asyncapi: '2.6.0'
info:
  title: Orders EDA
  version: '1.0.0'
  description: Event contracts for the Orders domain on Kafka.
defaultContentType: application/json
servers:
  prod:
    url: kafka1:9093,kafka2:9093,kafka3:9093
    protocol: kafka-secure
    description: Production Kafka cluster (SASL/SCRAM over TLS)
    security:
      - scramSha256: []
    bindings:
      kafka:
        clientId: orders-service
components:
  securitySchemes:
    scramSha256:
      type: userPassword
      description: SASL/SCRAM-SHA-256 credentials
  messages:
    OrderCreated:
      name: OrderCreated
      title: Order Created
      contentType: application/json
      headers:
        type: object
        properties:
          traceparent:
            type: string
            description: W3C trace context for distributed tracing
      payload:
        type: object
        required: [eventId, occurredAt, orderId, customerId, total, items]
        properties:
          eventId:
            type: string
            format: uuid
          occurredAt:
            type: string
            format: date-time
          orderId:
            type: string
          customerId:
            type: string
          total:
            type: number
            minimum: 0
          items:
            type: array
            minItems: 1
            items:
              type: object
              required: [sku, qty, price]
              properties:
                sku: { type: string }
                qty: { type: integer, minimum: 1 }
                price: { type: number, minimum: 0 }
channels:
  orders.v1:
    description: Main topic for order domain events
    bindings:
      kafka:
        topic: orders.v1
        partitions: 12
    publish:                       # This service publishes to the topic
      operationId: publishOrderCreated
      message:
        $ref: '#/components/messages/OrderCreated'
  orders.retry.v1:
    description: Retry topic for transient failures
    bindings:
      kafka:
        topic: orders.retry.v1
        partitions: 12
    subscribe:                     # This service consumes retries
      operationId: consumeOrderCreatedRetry
      message:
        $ref: '#/components/messages/OrderCreated'
  orders.dlq.v1:
    description: Dead-letter topic for poison messages
    bindings:
      kafka:
        topic: orders.dlq.v1
        partitions: 6
```

Notes:
- channels[].bindings.kafka lets you capture Kafka-specific information (topic, partitions, consumer group, etc.).
- You can add message bindings for Kafka headers and key types. You can also reference Avro/Protobuf schemas if that’s your format of record.
- Version channels (orders.v1) rather than version fields inside payloads when you expect breaking changes.

---

## Implementing Producers and Consumers

Below are concise Java examples using the official Kafka client. The config names are similar across languages if you prefer Python or Node.js.

### Idempotent Producer (Java)

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class OrdersProducer {
  public static void main(String[] args) {
    Properties p = new Properties();
    p.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka1:9093,kafka2:9093");
    p.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    p.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    p.put(ProducerConfig.ACKS_CONFIG, "all");
    p.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
    p.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "lz4");
    p.put(ProducerConfig.LINGER_MS_CONFIG, "10");
    p.put(ProducerConfig.BATCH_SIZE_CONFIG, String.valueOf(64 * 1024));
    // Security example (SASL/SCRAM over TLS)
    // p.put("security.protocol", "SASL_SSL");
    // p.put("sasl.mechanism", "SCRAM-SHA-256");
    // p.put("sasl.jaas.config", "org.apache.kafka.common.security.scram.ScramLoginModule required username='user' password='pass';");

    try (KafkaProducer<String, String> producer = new KafkaProducer<>(p)) {
      String topic = "orders.v1";
      String key = "customer-42"; // ensures per-customer ordering
      String value = """
        {"eventId":"3e3a...","occurredAt":"2025-08-21T12:00:00Z",
         "orderId":"o-123","customerId":"c-42","total":99.95,
         "items":[{"sku":"A1","qty":1,"price":99.95}]}
      """;

      ProducerRecord<String,String> record = new ProducerRecord<>(topic, key, value);
      record.headers().add("traceparent", "00-...".getBytes());

      producer.send(record, (meta, ex) -> {
        if (ex != null) {
          ex.printStackTrace();
        } else {
          System.out.printf("Published to %s-%d@%d%n", meta.topic(), meta.partition(), meta.offset());
        }
      });
      producer.flush();
    }
  }
}
```

For exactly-once across topics or with consume-transform-produce pipelines, add:
- enable.idempotence=true (already set)
- transactional.id=orders-service-tx-1
- Use initTransactions(), beginTransaction(), sendOffsetsToTransaction(), commitTransaction()

### Consumer with Manual Commits (Java)

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class OrdersConsumer {
  public static void main(String[] args) {
    Properties c = new Properties();
    c.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka1:9093,kafka2:9093");
    c.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    c.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    c.put(ConsumerConfig.GROUP_ID_CONFIG, "order-processor-v1");
    c.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
    c.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
    c.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, "100");
    // c.put("security.protocol", "SASL_SSL"); // as needed

    try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(c)) {
      consumer.subscribe(List.of("orders.v1"));
      while (true) {
        ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
        for (ConsumerRecord<String, String> rec : records) {
          try {
            process(rec.key(), rec.value(), rec.headers()); // your logic
          } catch (Exception e) {
            // send to retry or DLQ depending on error type
            // retryProducer.send(...); or buffer for backoff
          }
        }
        consumer.commitSync(); // at-least-once (commit after processing)
      }
    }
  }

  static void process(String key, String value, Headers headers) {
    // idempotent processing keyed by eventId to avoid duplicates
  }
}
```

Tip: If you need exactly-once from input topic to output topic, use a transactional producer and call sendOffsetsToTransaction() with the offsets of the consumed records before commitTransaction().

---

## Delivery Semantics and Reliability Patterns

- Idempotency
  - Producers: enable.idempotence and keep ordering per partition to avoid duplicates on retry.
  - Consumers: deduplicate using a unique eventId and a short-lived store (cache/DB with unique constraint).
- Retries and DLQs
  - Separate retry topics with increasing backoff (e.g., orders.retry.5m, orders.retry.1h).
  - Poison messages (consistently failing) go to DLQ with error metadata.
- Backpressure
  - Tune max.poll.records, max.poll.interval.ms, fetch.min.bytes, and batching to avoid thrashing.
- Ordering
  - Use keys that capture the ordering domain (orderId, customerId).
  - Don’t mix unrelated entities on the same key unless you intentionally need shared order.
- Exactly-once
  - Use transactions end-to-end for Kafka inputs and outputs.
  - External side effects (e.g., calling a REST API) break EOS unless you implement idempotency there too.

---

## Schema Evolution and Contracts

AsyncAPI gives you human/machine-readable contracts; pair it with a schema registry for runtime validation and evolution.

- Formats: JSON Schema, Avro, Protobuf. Avro/Protobuf typically integrate with registries for compact, versioned payloads.
- Compatibility: Prefer backward or full compatibility (new optional fields OK, removing required fields is not).
- Versioning:
  - Non-breaking: keep the same channel (orders.v1), evolve schema.
  - Breaking: create a new channel (orders.v2) and run both until consumers migrate.
- Tooling: Lint AsyncAPI docs in CI, run compatibility checks against the registry, generate SDKs/stubs.

---

## Security Considerations

- Encryption: Use TLS between clients and brokers.
- Authentication: SASL/SCRAM, mTLS, or OAUTHBEARER.
- Authorization: Kafka ACLs or RBAC; principle of least privilege per topic prefix.
- Multi-tenancy: Namespace topics, clientIds, and groupIds; restrict wildcards.
- Data protection: Encrypt sensitive fields at the app layer; Kafka doesn’t encrypt at rest by default.

---

## Observability and Operations

- Tracing: Propagate W3C traceparent in Kafka headers; integrate with OpenTelemetry to stitch spans across async boundaries.
- Metrics:
  - Producer: record-send-rate, request-latency, retries, errors.
  - Consumer: records-lag, records-lag-max, commit-latency, rebalance time.
  - Broker: under-replicated-partitions, offline-partitions, request handler pool usage.
- Lag monitoring: Track per (group, topic, partition) lag and alert on SLOs.
- Rebalancing:
  - Keep processing time < max.poll.interval.ms to avoid unnecessary rebalances.
  - Cooperative-sticky assignor reduces churn for large groups.

---

## Design Workflow: Bringing It All Together

1. Model events with AsyncAPI
   - Name events and channels clearly (domain.prefixed, versioned).
   - Define payloads with JSON Schema/Avro and required/optional fields.
   - Specify bindings for Kafka (topic, partitions) and security.
2. Generate artifacts
   - Produce docs, test stubs, code templates via AsyncAPI Generator/Studio.
3. Implement with Kafka clients
   - Producers with idempotency (and transactions if needed).
   - Consumers with manual commits and retry/DLQ patterns.
4. Govern and evolve
   - Validate changes with linters and schema compatibility checks in CI.
   - Version channels when introducing breaking changes.
5. Operate
   - Secure with TLS + SASL + ACLs.
   - Monitor lag, rebalances, and error rates; propagate trace headers.

---

## Common Pitfalls

- Ignoring keys: Without a good partitioning key, you lose per-entity ordering and overload random partitions.
- Auto-commit defaults: enable.auto.commit=true can commit before processing, causing data loss on failure.
- Over-eager retries: Hot-looping on poison messages without backoff—use retry topics and DLQ.
- Breaking changes in place: Changing required fields or semantics on the same channel without versioning breaks consumers.
- Large messages: Kafka favors small messages; use compression and avoid megabyte-scale payloads, or consider object storage + pointers.

---

## Quick Reference: When Each Thing Matters

- Kafka protocol: Understand it to reason about performance, upgrades, idempotency, and exactly-once semantics.
- AsyncAPI: Use it as your event contract, documentation, and code generation source of truth.
- EDA: Apply the patterns and trade-offs to design systems that are scalable, resilient, and evolvable.

---

## Conclusion

Kafka gives you a fast, durable event backbone; AsyncAPI gives you the contracts and tooling to scale development safely; EDA gives you the architectural pattern to connect it all. Combine the three:

- Design events and topics with AsyncAPI.
- Implement producers/consumers with Kafka clients, leaning on idempotency and transactions where needed.
- Operate with strong security, observability, and evolution practices.

Do this, and your event-driven systems will be both robust and a joy to change.