---
title: "Understanding and Tuning Garbage Collection in Java (G1GC)"
date: 2025-10-05T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["CPU", "RAM", "Garbage Collection", "GC"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "A practical, production-minded guide (with `gc.log` field reference and tuning options)"
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
# Understanding and Tuning Garbage Collection in Java (G1GC)

## A practical, production-minded guide (with `gc.log` field reference and tuning options)

Garbage Collection (GC) is one of the most misunderstood topics in the Java ecosystem. It is frequently blamed for latency spikes, slow services, and “random” performance issues—yet many teams never look at GC evidence.

In integration platforms such as **webMethods Integration Server**, this matters even more: workloads are long-running, concurrent, and often create large volumes of short-lived objects (pipelines, documents, strings, adapter outputs, transformation data). When GC is unhealthy, the symptoms are operational: thread pool exhaustion, timeouts, throughput collapse, and unpredictable response times.

This article is a complete, production-oriented guide to:

* what G1GC is and how it behaves,
* how to enable and manage `gc.log`,
* how to interpret the log (including a **field → meaning** table),
* what “bad” looks like (red flags),
* which JVM/GC parameters are typically relevant in production,
* and which tools to use alongside GC logs.

---

## 1) GC in one paragraph (why you should care)

Java allocates objects constantly. GC is the system that reclaims memory from objects that are no longer reachable. The key performance impact comes from **stop-the-world (STW) pauses**, during which application threads are stopped. Modern collectors like **G1GC** reduce long pauses by performing much of the work concurrently and collecting in smaller increments—but this is not magic: poor allocation patterns, oversized objects, or memory retention can still lead to bad behaviour.

---

## 2) Why G1GC is usually the correct choice

**G1GC (Garbage-First)** is designed for:

* large heaps,
* predictable pause times,
* incremental collection,
* concurrent background work.

It divides the heap into **regions** and performs collections of a set of regions (a “collection set”) rather than sweeping the entire heap. That’s why G1 is a very good fit for integration runtimes with sustained allocation churn.

---

## 3) Enable GC logging (mandatory before tuning)

Before tuning anything, enable logging. With Java 17 unified logging, a common production-friendly setup is:

```text
-Xlog:gc*:file=logs/gc.log:time,uptime:filecount=5,filesize=10m
```

### What this does

* Writes GC events to `logs/gc.log`
* Adds timestamps (`time`) and JVM uptime (`uptime`)
* Rotates logs:

  * keeps up to `filecount=5` files
  * each up to `filesize=10m`

### Operational note

Treat `gc.log` like any other log:

* rotate/retain intentionally,
* archive if needed,
* ensure it cannot fill the disk.

---

## 4) How to read the log: the essentials

A typical event summary line looks like:

```text
[2026-01-28T09:48:18.692+0000][12.955s] GC(2) Pause Young (Normal) (G1 Evacuation Pause) 141M->44M(2048M) 94.670ms
```

### Key interpretation

* `GC(2)` is the **event ID**. All lines with the same `GC(2)` belong to that event/cycle.
* `Pause Young ...` indicates an **STW pause** collecting young generation.
* `141M->44M(2048M)` means heap used **before → after**, with max heap in brackets.
* `94.670ms` is the pause duration (latency impact).

That single line answers:

* how long the JVM stopped,
* how much memory was reclaimed,
* whether the heap is close to the max.

---

## 5) Event types you will commonly see with G1GC

### `Pause Young (Normal) (G1 Evacuation Pause)`

A young collection:

* clears Eden,
* moves survivors to Survivor/Old,
* short and frequent.

### `Pause Young (Concurrent Start)`

A young GC that also kicks off a **concurrent mark** cycle (often due to thresholds like metadata or heap occupancy).

### `Concurrent Mark Cycle`

Background marking of live objects in old regions to prepare mixed collections.

### `Pause Young (Prepare Mixed)` and `Pause Young (Mixed)`

After marking, G1 performs *mixed* collections:

* young + selected old regions.

### `Pause Remark` / `Pause Cleanup`

Short STW phases that complete marking and clean up.

---

## 6) The GC log field reference (field → meaning)

Use this as an appendix-style quick reference.

| Field/pattern in `gc.log`        | Meaning                                 | What to watch                            |
| -------------------------------- | --------------------------------------- | ---------------------------------------- |
| `[2026-01-28T09:48:18.692+0000]` | Wall-clock timestamp                    | Correlate with incidents/APM             |
| `[12.955s]`                      | JVM uptime                              | Useful around restarts/warm-up           |
| `Using G1`                       | GC algorithm selected                   | Confirms collector                       |
| `Version: 17.x`                  | JVM version                             | Keep consistent across environments      |
| `CPUs: 4 available`              | Available CPU cores                     | Impacts parallelism                      |
| `Heap Max Capacity: 2G`          | Max heap (`-Xmx`)                       | Must match intended sizing               |
| `Heap Region Size: 1M`           | G1 region size                          | Auto is usually fine                     |
| `Parallel Workers: N`            | Threads used in STW evacuation          | Too low can increase pauses              |
| `Concurrent Workers: N`          | Threads used in concurrent marking      | Too low can delay marking                |
| `GC(n)`                          | GC event ID                             | Same ID = same event cycle               |
| `Pause Young ...`                | STW pause (young collection)            | Duration, frequency                      |
| `Pause Young (Mixed)`            | STW pause (young + old regions)         | Pause time and old cleanup effectiveness |
| `Concurrent Mark Cycle`          | Background marking of old gen           | Frequency and total time                 |
| `Pause Remark`                   | STW to finalize marking                 | Should remain small                      |
| `Pause Cleanup`                  | STW cleanup after marking               | Usually very small                       |
| `Eden regions: A->B(C)`          | Eden regions before/after, next target  | Normal to see `->0`                      |
| `Survivor regions: A->B(C)`      | Survivor regions before/after, capacity | If Survivor fills, more promotion        |
| `Old regions: A->B`              | Old gen regions before/after            | Continuous growth can be a problem       |
| `Humongous regions: A->B`        | Regions used by very large objects      | Growth is a major warning                |
| `Metaspace: X->Y`                | Metadata memory                         | Unbounded growth hints classloader leak  |
| `141M->44M(2048M)`               | Heap used before→after (max)            | Post-GC should stabilise                 |
| `94.670ms` / `0.312s`            | Pause duration                          | Compare to latency goals                 |
| `User=… Sys=… Real=…`            | CPU vs wall time                        | `Real` is the true pause impact          |

---

## 7) What “bad” looks like (red flags)

If your `gc.log` includes these regularly, investigate:

### 🚨 Full GC

* `Full GC`
* `Pause Full`

**Why it’s bad:** Full GC typically stops the entire JVM and indicates the collector could not keep up.

### 🚨 Evacuation failures

* `to-space exhausted`
* `Evacuation Failure`

**Why it’s bad:** G1 ran out of space to evacuate objects during a pause. This often leads to Full GC and severe latency.

### 🚨 Consistently high STW pauses

If pause lines frequently show:

* `>= 200ms` (or your own SLO threshold)
* spikes into seconds

**Impact:** direct user-visible latency and service thread starvation.

### 🚨 Old or Humongous regions growing continuously

* `Old regions` steadily rising without stabilising
* `Humongous regions` rising over time

**Typical causes:**

* memory leak or object retention,
* caches without TTL/invalidation,
* large payloads buffered in memory,
* huge strings/byte arrays/pipelines.

### 🚨 Very frequent GC events

Even if pauses are “small”, excessive frequency can burn CPU and reduce throughput.

---

## 8) Production-relevant G1GC tuning parameters (use with evidence)

Tuning is not a first step. But when logs show real issues, these are among the most commonly considered knobs.

### Select G1GC

```text
-XX:+UseG1GC
```

(Usually default on modern JDKs, but explicit is fine for clarity.)

### Target max pause time

```text
-XX:MaxGCPauseMillis=200
```

A **target**, not a guarantee. Lower targets can reduce throughput. Use realistic values.

### Keep reserve space for evacuation

```text
-XX:G1ReservePercent=10
```

Reserves heap space to reduce evacuation failures. Increasing can improve stability but reduces usable heap.

### Start concurrent marking earlier/later

```text
-XX:InitiatingHeapOccupancyPercent=45
```

Lower values start marking earlier (can reduce risk of old-gen pressure) but increase background activity.

### Parallel reference processing

```text
-XX:+ParallelRefProcEnabled
```

Speeds up processing of reference objects (weak/soft/phantom), can reduce pauses.

### Region size

```text
-XX:G1HeapRegionSize=16m
```

Only set this with care. Larger regions can reduce overhead but reduce granularity and may affect humongous behaviour.

### GC worker threads

```text
-XX:ParallelGCThreads=4
-XX:ConcGCThreads=2
```

Tune relative to CPU cores. Too high can steal CPU from the application; too low can increase pause times or delay marking.

### Logging (production-safe baseline)

```text
-Xlog:gc*:file=logs/gc.log:time,uptime:filecount=5,filesize=10m
```

> **Rule of thumb:** tune only after you can clearly state which symptom you’re correcting (e.g., “evacuation failures”, “pauses above 200ms”, “old gen growth”, “humongous growth”).

---

## 9) Practical interpretation patterns (what to conclude from the log)

### “Pausas baixas e heap confortável”

If your log shows:

* pauses mostly below your target,
* post-GC heap remains low,
* no Full GC,

then GC is not the bottleneck.

### “Old keeps growing”

If Old regions and post-GC heap usage keep increasing, you likely have:

* retention/leak,
* overly large cache lifetime,
* long-lived pipeline objects,
* or heavy session-like in-memory state.

### “Humongous is rising”

Large objects are being allocated repeatedly. Typical culprits:

* large payloads buffered instead of streamed,
* huge strings/byte arrays,
* document lists/pipelines containing big documents.

---

## 10) Quick extraction from logs (PowerShell)

### Count Full GC events

```powershell
$log="C:\path\to\gc.log"
(Select-String -Path $log -Pattern "Full GC|Pause Full").Count
```

### List pauses ≥ 200ms (handles `ms` and `s`)

```powershell
$log="C:\path\to\gc.log"
$thresholdMs = 200

Select-String -Path $log -Pattern "Pause" | ForEach-Object {
    $line = $_.Line
    $ms = $null

    if ($line -match "([0-9]+(\.[0-9]+)?)ms") {
        $ms = [double]$matches[1]
    }
    elseif ($line -match "([0-9]+(\.[0-9]+)?)s") {
        $ms = [double]$matches[1] * 1000
    }

    if ($ms -ne $null -and $ms -ge $thresholdMs) {
        [pscustomobject]@{
            PauseMs = [math]::Round($ms, 3)
            Line    = $line
        }
    }
} | Sort-Object PauseMs -Descending
```

### Top 20 longest pauses

```powershell
$log="C:\path\to\gc.log"

Select-String -Path $log -Pattern "Pause" | ForEach-Object {
    $line = $_.Line
    $ms = $null

    if ($line -match "([0-9]+(\.[0-9]+)?)ms") { $ms = [double]$matches[1] }
    elseif ($line -match "([0-9]+(\.[0-9]+)?)s") { $ms = [double]$matches[1] * 1000 }

    if ($ms -ne $null) { [pscustomobject]@{ PauseMs = [math]::Round($ms,3); Line = $line } }
} | Sort-Object PauseMs -Descending | Select-Object -First 20
```

---

## 11) JVM tools that complement `gc.log`

GC logs tell you **what happened**. Tools help you understand **why**.

### Built-in / standard JDK tools

* `jconsole` (JMX live monitoring)
* `jstat` (GC statistics from CLI)
* `jcmd` (heap info, start/stop JFR, diagnostics)
* `jstack` (thread dumps, deadlocks)
* `jmap` (heap histograms/dumps — use carefully in production)

### Best-in-class for production analysis

* **Java Flight Recorder (JFR)** (low overhead)
* **Java Mission Control (JMC)** (analysis UI for JFR)

---

## 12) Final recommendations

1. **Always enable GC logging** in production (with rotation).
2. Establish a routine: periodically scan for:

   * Full GC,
   * pauses above your SLO,
   * old/humongous growth.
3. **Fix code/design causes first** (allocation churn, pipeline bloat, missing streaming, cache lifecycle).
4. Tune G1GC only with a clear hypothesis and measurable objective.
5. Use JFR/JMC when you need to go beyond logs.

When GC is healthy, it becomes boring—predictable pause times, stable heap behaviour, and no unpleasant surprises. For production systems, boring GC is exactly the goal.

---

