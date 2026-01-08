---
title: "Redis + Kafka"
date: 2025-09-14T23:00:03+00:00
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
description: "Redis + Kafka: Fast Reads with Event-Driven Change Propagation"
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

# Redis + Kafka: Fast Reads with Event-Driven Change Propagation

## Overview

Redis and Kafka are often presented together, yet they solve **orthogonal problems**:

* **Redis** optimises *synchronous access to current state*
* **Kafka** propagates *asynchronous state changes to interested consumers*

Used together, they enable:

* Low-latency API responses
* Decoupled distribution of data changes
* Independent scaling of read paths and consumers

This article explains **how they complement each other in practice**, without implying any direct coupling or “magic integration”.

---

## The Core Pattern

The pattern can be summarised as:

1. An API request enters the system
2. The application tries to read from Redis (cache)
3. On a cache miss, the application loads data from the database
4. The application stores the result in Redis
5. When data changes, the application:

   * persists the change
   * publishes an event to Kafka
6. Other applications consume the event and react independently

```
Client
  ↓
API Gateway
  ↓
Application
  ├─ read/write Redis (fast state)
  ├─ read/write Database (source of truth)
  └─ publish Kafka events (state change notification)
                         ↓
                 Consumer Applications
```

Redis accelerates the **request path**.
Kafka distributes the **fact that something changed**.

---

## Why This Works Well

### Redis

* In-memory
* Deterministic reads
* Ideal for “current state”
* Synchronous and low latency

### Kafka

* Durable event log
* Fan-out to many consumers
* Replayable
* Asynchronous by design

They do not replace each other.
They **coexist** because real systems need both *state* and *history*.

---

## Practical Example Scenario

Assume a **User Profile** service:

* API must return profiles quickly → Redis
* Other systems must react to profile updates:

  * analytics
  * email
  * audit logging
    → Kafka

---

## Reading and Writing Cache with Redis

### Python (redis-py)

```python
import redis
import json

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

def get_user_profile(user_id):
    key = f"user:{user_id}"

    cached = r.get(key)
    if cached:
        return json.loads(cached)

    # Simulated DB fetch
    profile = {
        "id": user_id,
        "name": "Alice",
        "country": "PT"
    }

    r.setex(key, 3600, json.dumps(profile))
    return profile
```

This is a classic **read-through cache**:

* Redis is checked first
* Database is only hit on cache miss
* Cache is populated for subsequent requests

---

### Java (Jedis)

```java
import redis.clients.jedis.Jedis;
import com.fasterxml.jackson.databind.ObjectMapper;

public class UserCache {

    private static final ObjectMapper mapper = new ObjectMapper();

    public static String getUser(String userId) throws Exception {
        try (Jedis jedis = new Jedis("localhost", 6379)) {
            String key = "user:" + userId;
            String cached = jedis.get(key);

            if (cached != null) {
                return cached;
            }

            // Simulated DB fetch
            String profileJson = mapper.writeValueAsString(
                new User(userId, "Alice", "PT")
            );

            jedis.setex(key, 3600, profileJson);
            return profileJson;
        }
    }
}
```

---

## Publishing Events to Kafka on State Change

The important point:
👉 **Events are published because state changed, not because Redis was updated**.

---

### Python Kafka Producer (confluent-kafka)

```python
from confluent_kafka import Producer
import json

producer = Producer({"bootstrap.servers": "localhost:9092"})

def publish_user_updated(user):
    event = {
        "type": "UserUpdated",
        "userId": user["id"],
        "payload": user
    }

    producer.produce(
        topic="user-events",
        value=json.dumps(event)
    )
    producer.flush()
```

This event announces:

> “The user profile changed”

It does **not** instruct consumers what to do.

---

### Java Kafka Producer

```java
import org.apache.kafka.clients.producer.*;
import java.util.Properties;

public class UserEventProducer {

    public static void publish(String payload) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        Producer<String, String> producer = new KafkaProducer<>(props);

        producer.send(
            new ProducerRecord<>("user-events", payload)
        );

        producer.close();
    }
}
```

---

## Consuming the Event in Other Applications

Consumers react **independently**.

Examples:

* invalidate their own cache
* update a search index
* write audit logs
* trigger notifications

---

### Python Kafka Consumer

```python
from confluent_kafka import Consumer
import json

consumer = Consumer({
    "bootstrap.servers": "localhost:9092",
    "group.id": "analytics-service",
    "auto.offset.reset": "earliest"
})

consumer.subscribe(["user-events"])

while True:
    msg = consumer.poll(1.0)
    if msg is None:
        continue
    if msg.error():
        continue

    event = json.loads(msg.value())
    print("Received event:", event)
```

---

### Java Kafka Consumer

```java
import org.apache.kafka.clients.consumer.*;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class UserEventConsumer {

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("group.id", "email-service");
        props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        KafkaConsumer<String, String> consumer =
            new KafkaConsumer<>(props);

        consumer.subscribe(Collections.singletonList("user-events"));

        while (true) {
            ConsumerRecords<String, String> records =
                consumer.poll(Duration.ofMillis(100));

            for (ConsumerRecord<String, String> record : records) {
                System.out.println("Processing: " + record.value());
            }
        }
    }
}
```

---

## Key Takeaways

* Redis and Kafka do **not** integrate directly
* Redis accelerates *current state access*
* Kafka distributes *state changes*
* The application layer coordinates both
* Consumers stay decoupled and scalable

This combination works not because Redis and Kafka are special together, but because **state and events are fundamentally different concerns** — and both are required in non-trivial systems.

---
