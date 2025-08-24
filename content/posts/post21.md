---
title: "Apache Kafka"
date: 2025-05-25T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Apache Kafka", "EDA", "event driven architecture"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Apache Kafka: A Practical Guide for Developers"
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


Apache Kafka: A Practical Guide for Developers
================================================

If you build data-intensive systems, you’ve likely heard of Apache Kafka—a distributed platform for high-throughput, low-latency, fault-tolerant event streaming. This article covers Kafka’s core concepts from topics and partitions to producer/consumer mechanics, leader election, replication, discovery, and the evolution from ZooKeeper to KRaft. It’s written for intermediate developers who want clear, practical explanations with a few code examples.

Note: You wrote “KafkaE”; this article assumes Apache Kafka.

Why Apache Kafka?
-----------------
- Scalability: Horizontal scaling via partitions lets you push millions of messages per second.
- Durability: Messages are written to disk and replicated across brokers.
- Low latency: Efficient batching, zero-copy I/O, and compression keep end-to-end latency low.
- Ecosystem: Kafka Streams, Kafka Connect, and integrations with Flink, Spark, Debezium, and more.
- Versatility: Works for pub/sub, event sourcing, log aggregation, CDC, IoT telemetry, and microservice communication.

Who Created Kafka?
------------------
Kafka was created at LinkedIn by Jay Kreps, Neha Narkhede, and Jun Rao to handle large-scale activity streams and operational metrics. It was open-sourced and donated to the Apache Software Foundation in 2011 under the Apache 2.0 license.

Common Use Cases
----------------
- Event-driven microservices (decoupled producers/consumers)
- Log aggregation and observability pipelines
- CDC from relational databases into data lakes/warehouses
- Real-time analytics and anomaly detection
- IoT telemetry ingestion
- Stream processing (Kafka Streams, Flink) and CQRS/event sourcing

Kafka’s Core Building Blocks
----------------------------

Topics
- A topic is a named, append-only stream of records.
- Producers write to topics; consumers read from topics.
- Topics are divided into partitions to enable parallelism.

Partitions
- Each topic has one or more partitions (e.g., orders-0, orders-1).
- Ordering is guaranteed only within a partition, not across the whole topic.
- Choosing the number of partitions determines maximum parallelism and throughput.
- Producers route records to partitions—by key, custom partitioner, or round-robin.

Offsets
- Each record within a partition has a monotonically increasing offset (0, 1, 2…).
- Offsets are the consumer’s “bookmark” and can be committed to Kafka (in __consumer_offsets).
- Offsets are per consumer group per partition.

Brokers
- A broker is a Kafka server. A cluster typically runs 3+ brokers for redundancy.
- Brokers host partitions and serve read/write requests.

Producers
- Publish records to topics.
- Key features: batching, compression, retries, acks, idempotence, transactions.

Consumers
- Subscribe to topics and poll for records.
- Manage offsets and participate in consumer groups for scalability and fault tolerance.

Consumer Groups
- A consumer group is a set of consumers sharing a group.id.
- Kafka ensures each partition of a topic is assigned to exactly one consumer in the group.
- Rebalancing happens when consumers join/leave or topic metadata changes.
- Delivery semantics depend on offset management and producer config: at-most-once, at-least-once, or exactly-once.

Kafka Message Anatomy
---------------------
A Kafka record contains:
- Topic and partition (destination)
- Offset (assigned by broker on write)
- Key (optional; used for partitioning and semantics like compaction)
- Value (the payload)
- Headers (optional key/value pairs for metadata)
- Timestamp (event-time or log-append-time)

Notes:
- Compression can be per-message batch (gzip, snappy, lz4, zstd).
- Compacted topics keep only the latest record per key (for state snapshots).

Kafka Message Serialization
---------------------------
Kafka transports bytes; clients provide serializers/deserializers (SerDes).
- Built-in: StringSerializer, ByteArraySerializer, LongSerializer, etc.
- Schema-aware options: Avro, Protobuf, and JSON Schema with a Schema Registry for evolution.
- Custom serializers implement org.apache.kafka.common.serialization.Serializer<T> and Deserializer<T>.

Example: simple JSON serializer (Java)
```java
public class JsonSerializer<T> implements org.apache.kafka.common.serialization.Serializer<T> {
  private final com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
  @Override public byte[] serialize(String topic, T data) {
    try { return data == null ? null : mapper.writeValueAsBytes(data); }
    catch (Exception e) { throw new org.apache.kafka.common.errors.SerializationException(e); }
  }
}
```

Replication Factor, Leaders, and Availability
---------------------------------------------
- Replication factor (RF): number of copies of each partition across brokers (commonly 3 in production).
- Leader and followers:
  - Exactly one leader per partition handles reads/writes.
  - Followers replicate from the leader.
- In-Sync Replicas (ISR): replicas sufficiently up-to-date. Brokers outside the ISR don’t acknowledge writes.
- Reliability settings:
  - acks=all (or -1): producer waits for leader + ISR acknowledgments.
  - min.insync.replicas: minimum ISR needed for writes; combined with acks=all prevents data loss.
- Unclean leader election:
  - If enabled, a non-ISR replica may be elected leader to restore availability, risking data loss. Best disabled for strong durability.
- Rack awareness:
  - Spread replicas across racks/availability zones to survive AZ failures.

The Concept of a Leader for a Partition
- Clients (producers/consumers) communicate with the leader broker for a partition.
- If the leader fails, the controller elects a new leader from the ISR.
- Leader epoch/versioning prevents stale leaders from accepting writes after a failover.

Kafka Broker Discovery (How Clients Find the Cluster)
-----------------------------------------------------
- Clients start with bootstrap.servers: a comma-separated list of one or more reachable brokers.
- The client sends a metadata request to any bootstrap node to learn:
  - Full broker list and advertised endpoints
  - Topic partitions and their current leaders
- Clients automatically refresh metadata periodically or on errors.
- Important: advertised.listeners must be resolvable and reachable by clients (NAT/proxy issues are common).
- No load balancer is required between clients and brokers; clients connect directly to the appropriate leaders.

Producer Essentials
-------------------
- Partitioning:
  - If a key is set, the default partitioner hashes the key for stable routing and ordering per key.
  - Without a key, records are round-robin partitioned (balanced but no per-key ordering).
- Acknowledgments and retries:
  - acks=all, retries high, and enable.idempotence=true for exactly-once producer semantics (no duplicates on retry).
- Batching and latency:
  - linger.ms (delay to form bigger batches), batch.size (per-partition buffer), compression.type for throughput.
- Transactions:
  - For exactly-once processing across producer and consumer (read-process-write), enable transactions with a transactional.id and use sendOffsetsToTransaction.

Simple Java producer
```java
Properties p = new Properties();
p.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092,broker2:9092");
p.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
p.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
p.put(ProducerConfig.ACKS_CONFIG, "all");
p.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
p.put(ProducerConfig.LINGER_MS_CONFIG, "10");
p.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "zstd");

try (KafkaProducer<String,String> producer = new KafkaProducer<>(p)) {
  ProducerRecord<String,String> rec = new ProducerRecord<>("orders", "order-123", "{\"total\":42}");
  rec.headers().add("source", "web".getBytes());
  producer.send(rec).get(); // wait for ack for simplicity
}
```

Consumer Essentials
-------------------
- Poll loop:
  - Consumers call poll() repeatedly; Kafka delivers records per assigned partitions.
  - Keep processing within max.poll.interval.ms and send heartbeats (via poll) to avoid rebalancing.
- Offset management:
  - enable.auto.commit=false and manual commit for at-least-once.
  - Commit after processing to avoid message loss; committing before processing yields at-most-once.
- Rebalancing:
  - Strategies include range, round-robin, and cooperative-sticky (reduces stop-the-world rebalances).
- Delivery semantics:
  - At-least-once: default, with manual commits after processing.
  - At-most-once: commit before processing (risk of loss).
  - Exactly-once: use idempotent producers + transactions (EOS) with supported processing libraries.

Simple Java consumer
```java
Properties c = new Properties();
c.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092,broker2:9092");
c.put(ConsumerConfig.GROUP_ID_CONFIG, "billing-service");
c.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
c.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
c.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
c.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

try (KafkaConsumer<String,String> consumer = new KafkaConsumer<>(c)) {
  consumer.subscribe(Arrays.asList("orders"));
  while (true) {
    ConsumerRecords<String,String> records = consumer.poll(Duration.ofMillis(500));
    for (ConsumerRecord<String,String> r : records) {
      // process r.key(), r.value(), r.headers(), r.timestamp()
    }
    consumer.commitSync(); // at-least-once
  }
}
```

ZooKeeper and KRaft
-------------------
- ZooKeeper era (legacy):
  - Kafka stored cluster metadata (brokers, topics, ACLs) in Apache ZooKeeper.
  - A Kafka controller broker used ZooKeeper to coordinate leader elections and metadata changes.
- KRaft (Kafka Raft) era:
  - Kafka now includes its own metadata quorum using the Raft consensus algorithm.
  - Dedicated controller nodes (or co-located mode) maintain metadata; ZooKeeper is no longer required.
  - Benefits: simpler ops, faster controller failover, better scalability for metadata.
- Status:
  - ZooKeeper mode is deprecated; recent Kafka releases make KRaft production-ready.
  - Kafka 4.0+ removes ZooKeeper support entirely. Plan migrations accordingly.
- Migration:
  - There is a documented ZK-to-KRaft migration path; test thoroughly in non-prod before switching.

Operational Tips and Gotchas
----------------------------
- Choose partitions deliberately: too few limits parallelism; too many increases overhead and rebalancing time.
- Use keys for deterministic routing and compaction; avoid “hot keys” that create partition hotspots.
- Set min.insync.replicas=2 with acks=all and RF=3 for strong durability.
- Watch rebalances: use cooperative-sticky assignor and keep poll loops healthy.
- Schema evolution: use a Schema Registry for Avro/Protobuf/JSON Schema to evolve contracts safely.
- Networking: ensure client access to advertised.listeners; DNS and firewall issues are common.
- Security: enable TLS and SASL (PLAIN, SCRAM, or OAuth) and configure ACLs.

Quick Mental Model
------------------
Think of Kafka as:
- A persistent, distributed commit log (topics/partitions on disk),
- With a built-in replication system (leaders/followers, ISR),
- Exposed via a high-throughput socket API (producers/consumers),
- Coordinated by a metadata quorum (KRaft) instead of an external ZooKeeper.

Wrapping Up
-----------
Kafka’s power comes from its simple primitives—topics, partitions, offsets—combined with strong guarantees from replication and consensus. Mastering message keys, serializers, offset commits, and group rebalancing will make your applications fast, reliable, and scalable. As the project moves fully to KRaft, operations get simpler while retaining the durability and performance Kafka is known for.