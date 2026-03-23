---
title: "CKAD Certification Journey — Part 3: Application Observability & Maintenance"
date: 2025-11-16T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["k8s", "CKAD", "HELM"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "CKAD Certification Journey — Part 3: Application Observability & Maintenance"
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
# CKAD Certification Journey — Part 3: Application Observability & Maintenance (The Reality of Running Systems)

If deployment is where you **introduce change**,
observability is where you **survive that change**.

And here is the uncomfortable truth:

> Most engineers don’t fail at Kubernetes because they don’t know how to deploy —
> they fail because they **don’t know how to understand what’s happening after deployment**.

This article is not a list of tools.
It is a **practical mental model for diagnosing real systems under pressure**.

---

# 🧠 Kubernetes Doesn’t Know Your App Is Broken

Let’s start with the most important idea:

> Kubernetes does not know your application is failing.

It only knows:

* if a process exists
* if a container is running
* if a node is healthy

👉 If your app is:

* deadlocked
* returning 500s
* stuck waiting on a dependency

Kubernetes will happily say:

```bash
STATUS: Running
```

And that’s where **probes** become critical.

---

# ❤️ Liveness Probe — Detecting Dead Applications (Not Dead Containers)

A container can be:

* running
* consuming CPU
* accepting connections

…and still be completely broken.

A **liveness probe** is your way of telling Kubernetes:

> “If this condition fails, kill the container and start again”

---

## 🔬 What You Should Actually Check (Not Just /health)

Bad example:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

👉 Returns 200 even if:

* DB is down
* internal threads are stuck

---

## Better approach

Your liveness endpoint should verify:

* internal threads responsive
* event loop alive
* critical dependencies reachable (with care)

---

## ⚠️ Why “with care” matters

If you include external dependencies (like DB):

```text
DB temporary issue → probe fails → container restarts → cascading failure
```

👉 You’ve just amplified the problem.

---

## 🔁 What actually happens on failure

```text
Liveness fails
   ↓
Kubelet kills container
   ↓
Container restarted
   ↓
State lost (if no volume)
```

---

## 💥 Real-world anti-pattern

Aggressive probes:

```yaml
failureThreshold: 1
periodSeconds: 5
```

👉 One slow response → restart → instability loop

---

## 🧠 Insight

> Liveness is not a health check — it is a **self-healing trigger**

---

# 🚦 Readiness Probe — Traffic Control, Not Health

Readiness is not about fixing problems.

It is about:

> 👉 Protecting your system from bad instances

---

## What readiness really does

If readiness fails:

```text
Pod removed from Service endpoints
Traffic stops
Pod still running
```

---

## Where this matters

### Scenario: slow startup

Without readiness:

* Pod starts
* traffic arrives immediately
* app not ready → errors

With readiness:

* Pod hidden
* app warms up
* then receives traffic

---

## 🧠 Critical distinction

| Situation          | Liveness            | Readiness            |
| ------------------ | ------------------- | -------------------- |
| App stuck          | restart             | no effect            |
| App warming up     | restart (bad)       | no traffic (correct) |
| Dependency failure | restart (dangerous) | isolate instance     |

---

## 💥 Real production pattern

```text
DB latency increases
   ↓
Readiness fails
   ↓
Pods temporarily removed
   ↓
System stabilises
```

👉 Without readiness → cascading failure

---

# 🔁 Probes Working Together (Real Behaviour)

```text
Startup phase:
  Readiness = false (no traffic)

Runtime failure:
  Liveness = fail → restart

Transient issues:
  Readiness = fail → isolate instance
```

---

# 📊 Monitoring — Not Dashboards, But Signal

Most teams confuse monitoring with graphs.

Monitoring is:

> 👉 Detecting abnormal behaviour early enough to act

---

# 🧱 The Observability Stack (Layered Thinking)

You must think in **layers**, or you will debug blindly.

---

## 1️⃣ Infrastructure (Node Level)

* CPU saturation
* memory pressure
* disk I/O
* network

👉 Example:

```text
Node disk full → Pods evicted → app downtime
```

---

## 2️⃣ Kubernetes Control Plane

* scheduling delays
* API server latency
* etcd health

👉 Example:

```text
Scheduler slow → Pods Pending → deployment stalls
```

---

## 3️⃣ Pod / Container Level

* restarts
* OOMKilled
* resource limits

👉 Example:

```text
Memory limit too low → container killed → CrashLoopBackOff
```

---

## 4️⃣ Application Level

* request latency
* error rates
* throughput

👉 This is where business impact lives.

---

## 🧠 Insight

> If you don’t correlate these layers, you’re guessing — not debugging

---

# 🛠️ Metrics — What Kubernetes Actually Gives You

Kubernetes gives you **just enough to be dangerous**.

---

## Metrics Server

```bash
kubectl top nodes
kubectl top pods
```

Shows:

* CPU
* memory

👉 Useful for:

* quick diagnosis
* autoscaling

👉 Useless for:

* deep analysis
* historical trends

---

## cAdvisor

* container-level metrics
* filesystem, CPU, memory

---

## kube-state-metrics

* state of Kubernetes objects
* desired vs actual

---

## ⚠️ Limitation

> No history, no alerting, no correlation

---

# 📈 Real Monitoring Stack (Why Prometheus Exists)

Production requires:

* time-series storage
* alerting
* correlation

---

## Typical stack

```text
Prometheus → collects metrics
Grafana → visualises
Alertmanager → alerts
```

---

## Why this matters

Because:

```text
CPU spike alone = useless
CPU spike + latency spike = insight
```

---

# 📜 Logging — Where Truth Actually Lives

Metrics tell you:
👉 something is wrong

Logs tell you:
👉 what is wrong

---

# 🔍 Kubernetes Logging Reality

Kubernetes does NOT provide:

* log storage
* log search
* log correlation

---

## What actually happens

Your app writes:

```text
stdout / stderr
```

Kubernetes:

* stores it temporarily
* rotates logs
* deletes when Pod dies

---

## 🧠 Insight

> If you don’t aggregate logs, you are losing data continuously

---

# 🧱 Real Logging Architecture

```text
Pod → stdout
   ↓
Fluentd / Fluent Bit
   ↓
Elasticsearch
   ↓
Kibana / Grafana
```

---

## Sources of logs

* Application
* kube-apiserver
* scheduler
* etcd
* node system logs

---

## Example debugging

```bash
kubectl logs <pod>
kubectl logs <pod> --previous
```

👉 `--previous` is critical for crash debugging

---

# 🔥 Troubleshooting Pods — Real Workflow

Forget theory. This is what you actually do.

---

## Step 1 — Check state

```bash
kubectl get pods
```

Look for:

* CrashLoopBackOff
* Pending
* Error

---

## Step 2 — Describe

```bash
kubectl describe pod <name>
```

👉 Most useful part: **Events**

---

## Step 3 — Logs

```bash
kubectl logs <pod>
```

---

## Step 4 — Exec (if needed)

```bash
kubectl exec -it <pod> -- sh
```

---

# 💥 Common Failure Patterns

---

## CrashLoopBackOff

Cause:

* app crash
* bad config
* missing dependency

---

## Pending

Cause:

* no resources
* node selector mismatch
* PVC not bound

---

## OOMKilled

Cause:

* memory limit too low

---

# 🧠 Debugging Mindset

```text
Symptom ≠ Cause
```

Example:

```text
Pod restarting
```

Is NOT the problem.

👉 It is a symptom.

---

# 🧠 Cluster-Level Troubleshooting

Sometimes the issue is not your app.

---

## Check nodes

```bash
kubectl get nodes
kubectl describe node
```

---

## Check system components

```bash
kubectl logs kube-apiserver-<node> -n kube-system
journalctl -u kube-apiserver
```

---

## Real failure example

```text
etcd slow → API slow → scheduling delays → deployment issues
```

---

# ⚠️ What Separates Beginners from Experts

---

## Beginners

* look at Pod status
* restart things
* guess

---

## Experts

* correlate metrics + logs + events
* understand layers
* identify root cause

---

# 🧠 Final Mental Model

```text
Probes → control lifecycle
Metrics → detect anomalies
Logs → explain anomalies
Events → show system decisions
```

---

# 🚀 Final Thought

> Observability is not about tools — it is about reducing uncertainty.

Kubernetes gives you signals.

Your job is to:

* interpret them
* correlate them
* act on them

---

## 🔜 Next Part

In **Part 4**, we’ll explore:

👉 Configuration, Secrets, Environment, and Security

Because:

> misconfigured systems fail more often than badly deployed ones
