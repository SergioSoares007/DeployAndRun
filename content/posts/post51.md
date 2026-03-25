---
title: "CKAD Certification Journey — Part 5: Services & Networking"
date: 2025-11-30T23:00:03+00:00
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
description: "CKAD Certification Journey — Part 5: Services & Networking"
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
# CKAD Certification Journey — Part 5: Services & Networking (Where Kubernetes Becomes a Distributed System)

Up until now, everything we’ve discussed — Pods, Deployments, Config, Observability — happens **inside isolated units**.

But real systems are not isolated.

They communicate.

And the moment you introduce communication, you introduce:

* instability
* coupling
* failure propagation
* latency
* security risks

This is where Kubernetes networking stops being “just configuration” and becomes **system design**.

---

# 🧠 The Fundamental Problem: Pods Are Ephemeral

Every Pod in Kubernetes gets its own IP.

That sounds great — until you realise:

* Pods can die and restart
* Pods can be rescheduled to another node
* Autoscaling creates and destroys Pods dynamically

👉 Result:

> **Pod IPs are not stable — they are disposable**

---

## 💥 Why This Breaks Naive Architectures

Imagine:

```text
Frontend → calls 10.0.0.12 (backend Pod)
```

That Pod restarts.

Now:

```text
10.0.0.12 → gone
```

👉 Your system is broken.

---

## 🧠 Insight

> In Kubernetes, you never talk to Pods directly — you talk to abstractions

---

# 🧩 Services — The Stable Abstraction Layer

A **Service** solves this problem by acting as a **stable endpoint**.

---

## Conceptually:

```text
Frontend Pod → Service → Backend Pods
```

The Service:

* has a stable IP
* has a stable DNS name
* dynamically routes to Pods

---

## 🔍 Under the hood

Services use:

* **labels** to select Pods
* **endpoints** to track Pod IPs

---

## Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 8080
```

---

## 🧠 Port vs TargetPort

* `port` → where the Service listens
* `targetPort` → where traffic is forwarded inside the Pod

---

## Flow

```text
Client → Service:80 → Pod:8080
```

---

# 🔄 Dynamic Endpoints — The Real Magic

You never update the Service manually.

Kubernetes automatically updates endpoints:

```text
Pod added → endpoint added  
Pod removed → endpoint removed  
Pod restarted → endpoint updated  
```

---

## 🧠 Insight

> Services are not static routing rules — they are **dynamic service discovery mechanisms**

---

# 🌐 Service Types — Exposure Strategies

---

## 1️⃣ ClusterIP (Default)

* Only accessible inside the cluster
* Used for internal communication

```text
Frontend → backend service
```

---

## 2️⃣ NodePort

Exposes the Service externally via:

```text
<NodeIP>:<NodePort>
```

---

### Example

```yaml
type: NodePort
```

* Port range: **30000–32767**

---

### What actually happens

* Every node opens that port
* Traffic forwarded to Service

---

### ⚠️ Limitations

* Not user-friendly
* Requires node IP knowledge
* No load balancing across clusters

---

## 3️⃣ LoadBalancer

Best option in cloud environments.

---

### What happens

```text
Cloud provider provisions external load balancer
   ↓
Traffic routed to nodes
   ↓
Forwarded to Pods via Service
```

---

### 🧠 Insight

> Kubernetes does not implement load balancers — cloud providers do

---

# 🔁 Service Discovery — DNS in Kubernetes

Every Service gets a DNS name:

```text
backend.default.svc.cluster.local
```

👉 Inside the cluster, you can simply call:

```text
http://backend
```

---

## 🧠 Insight

> Kubernetes networking is DNS-driven, not IP-driven

---

# ⚙️ kube-proxy — The Silent Component

Every node runs **kube-proxy**, which:

* programs iptables / IPVS rules
* routes traffic from Services to Pods

---

## 🧠 Insight

> There is no “Service process” — just kernel-level routing rules

---

# 🔥 What Most People Don’t Realise

---

## 1. Services Don’t Load Balance Equally

Depending on mode:

* iptables → random-ish
* IPVS → more advanced

---

## 2. No Session Awareness (by default)

👉 Requests may hit different Pods each time

---

## 3. Sticky sessions require configuration

---

# 🔐 Network Policies — From Open to Zero Trust

By default:

> 👉 Every Pod can talk to every other Pod

---

## ⚠️ This is dangerous

* no isolation
* no boundaries
* lateral movement possible

---

## NetworkPolicy solves this

You define:

```yaml
kind: NetworkPolicy
```

---

## Example

```yaml
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

---

## Result

```text
Frontend → Backend ✅
Everything else → Backend ❌
```

---

## 🧠 Insight

> NetworkPolicies turn Kubernetes from “flat network” into **controlled topology**

---

# 🚧 Ingress — The Missing Piece (Beyond Services)

Services expose applications.

Ingress defines:

> 👉 how external traffic reaches them

---

## Example

```yaml
kind: Ingress
```

Allows:

* domain-based routing
* TLS termination
* path-based routing

---

## Example flow

```text
https://api.myapp.com → Ingress → Service → Pods
```

---

## 🧠 Insight

> Ingress is L7 (HTTP), Services are L4 (TCP)

---

# 🔄 Real Traffic Flow (End-to-End)

```text
User
  ↓
LoadBalancer / Ingress
  ↓
Service
  ↓
kube-proxy
  ↓
Pod
```

---

# ⚠️ Common Mistakes

---

## 1. Hardcoding Pod IPs

👉 breaks immediately

---

## 2. Ignoring readiness probes

👉 traffic sent to broken Pods

---

## 3. Using NodePort in production

👉 poor scalability

---

## 4. No Network Policies

👉 zero security boundaries

---

## 5. Misunderstanding DNS

👉 unnecessary complexity

---

# 🧠 Advanced Insight — Kubernetes Is Not a Network, It’s a Model

Kubernetes networking is:

* flat (every Pod reachable)
* abstracted (Services)
* programmable (Policies)

---

## What it is NOT

* not traditional networking
* not static
* not predictable at IP level

---

# 🧠 Final Mental Model

```text
Pod → ephemeral compute
Service → stable access point
DNS → discovery
kube-proxy → routing
Ingress → external access
NetworkPolicy → security
```

---

# 🚀 Final Thought

> Kubernetes networking is not about connecting machines — it’s about connecting **intent**.

You don’t route packets.

You define relationships.

And Kubernetes makes them real.

---

## 🎉 End of the Series

You now have:

* Built applications
* Deployed them
* Observed them
* Secured them
* Connected them

👉 This is the foundation of **real Kubernetes engineering**

---

If there’s one thing to take away:

> Kubernetes is not about containers — it’s about designing systems that survive change.
