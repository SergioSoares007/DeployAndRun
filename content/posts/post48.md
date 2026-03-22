---
title: "CKAD Certification Journey — Part 2: Application Deployment"
date: 2025-11-09T23:00:03+00:00
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
description: "CKAD Certification Journey — Part 2: Application Deployment"
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
# CKAD Certification Journey — Part 2: Application Deployment 

If **Part 1** was about building applications correctly, this part is about something far more dangerous:

> 👉 **Deploying them without breaking production**

Because here’s the uncomfortable truth:

Most Kubernetes outages are not caused by Kubernetes itself —
they are caused by **how applications are deployed, updated, and scaled**.

This article is not a glossary. It’s a **mental model + practical guide** to how deployment actually works in real systems.

---

# 🧠 Deployment Is Not “Running Pods”

When people start with Kubernetes, they think:

> “I just need to run a container”

So they create a Pod.

That works — until:

* the Pod crashes
* the node dies
* you need to update the image
* you need 3 replicas instead of 1

👉 This is where **Deployments** come in.

---

# 📦 Deployments: Declarative Control, Not Just Execution

A Deployment is not a runtime object — it is a **controller of state**.

When you write:

```yaml
spec:
  replicas: 3
```

You are not saying:

> “Run 3 Pods”

You are saying:

> “Ensure there are always 3 Pods, no matter what happens”

That distinction is everything.

---

## 🔁 What Actually Happens Internally

```text
You change Deployment
   ↓
Deployment creates/updates ReplicaSet
   ↓
ReplicaSet creates Pods
   ↓
Kubelet schedules Pods on nodes
```

👉 You never interact with Pods directly in production — you interact with controllers.

---

# ⚠️ The First Mistake Everyone Makes

> Thinking scaling and upgrading are separate concerns

They are not.

They are both:
👉 **state transitions controlled by the Deployment controller**

---

# 🔄 Deployment Strategies — Where Systems Either Shine or Break

This is not theory — this is where production incidents are born.

---

## 1️⃣ Recreate — The Honest but Brutal Strategy

Everything stops. Then everything starts.

```yaml
strategy:
  type: Recreate
```

### What really happens:

```text
All Pods terminated
↓
New Pods created
```

### When is this actually useful?

* Stateful apps that cannot run two versions simultaneously
* Schema-incompatible systems

### Why it’s dangerous:

* Guaranteed downtime
* No rollback window

---

## 2️⃣ Rolling Updates — The Default (and Often Misunderstood)

Most people think:

> “Rolling update = zero downtime”

That is **not guaranteed**.

---

### What actually happens:

```text
Old Pods ↓ gradually
New Pods ↑ gradually
```

Controlled by:

```yaml
rollingUpdate:
  maxUnavailable: 1
  maxSurge: 1
```

---

### The subtle problem

During rollout:

* old version is still serving traffic
* new version is also serving traffic

👉 You are running a **distributed system with mixed versions**

---

### Real-world failure scenario

* New version requires new DB schema
* Old Pods still running
* Requests fail inconsistently

👉 This is how “random bugs” appear in production

---

## 🧠 Insight

> Rolling updates assume backward compatibility — if your system doesn’t have it, Kubernetes will not save you.

---

## 3️⃣ Blue-Green — Control Over Chaos

Instead of gradual change, you run two environments:

```text
Blue → current version
Green → new version
```

Then switch traffic.

---

### The key mechanism: Services + Labels

A Service does not know versions — it knows **labels**:

```yaml
selector:
  app: web
```

Change the label → traffic shifts instantly.

---

### Why this is powerful

* Zero downtime
* Instant rollback
* No mixed versions

---

### The real cost

* Double infrastructure
* Requires discipline in versioning

---

## 4️⃣ Canary — Controlled Risk

Instead of all-or-nothing:

* 5% traffic → new version
* observe
* increase gradually

---

### The catch

Kubernetes alone is not enough.

You need:

* Ingress controllers
* Service mesh (Istio, Linkerd)

---

## 🧠 Insight

> Canary is not a deployment strategy — it is an **observability strategy disguised as deployment**

---

# 🔖 Labels — The Most Underrated Concept in Kubernetes

Labels are not metadata.

They are:

> 👉 **The query language of Kubernetes**

---

Everything depends on labels:

* Deployments select Pods
* Services route traffic
* Autoscalers target workloads

---

### Bad labels = broken system

Example:

```yaml
labels:
  app: web
```

Too generic.

Better:

```yaml
labels:
  app: web
  version: v1
  environment: production
```

---

## 🧠 Insight

> Labels are your architecture — not decoration

---

# 📈 Scaling — More Than Just “More Pods”

---

## Manual scaling

```bash
kubectl scale deployment web --replicas=5
```

Simple.

---

## Auto scaling (HPA)

```bash
kubectl autoscale deployment web --cpu-percent=70 --min=2 --max=10
```

---

### What really happens

* Metrics server collects CPU
* HPA adjusts replica count
* Deployment reconciles state

---

## ⚠️ The trap

> Scaling stateless apps is easy
> Scaling stateful or bottlenecked systems is not

If your bottleneck is:

* database
* external API

👉 more Pods = more pressure, not more performance

---

# 🌐 Services — The Hidden Load Balancer

A Service is not just networking.

It is:

> 👉 **Traffic abstraction layer**

---

## LoadBalancer Service

```yaml
type: LoadBalancer
```

* gets external IP
* distributes traffic

---

## But here’s the key:

> Services do not load balance Pods — they load balance **endpoints selected by labels**

---

# 📦 Helm — Where Kubernetes Becomes Maintainable

Let’s be honest:

Nobody deploys a real system with a single YAML.

A real app includes:

* Deployment
* Service
* ConfigMaps
* Secrets
* Ingress
* Jobs
* Volumes

---

## Without Helm

You end up with:

* duplicated YAML
* inconsistent configs
* manual errors

---

## With Helm

You define:

* templates
* variables
* versions

---

# 🧠 What Helm Actually Is

Not just a package manager.

It is:

> 👉 **A templating + versioning + release management system for Kubernetes**

---

## Structure of a Chart (properly understood)

```text
my-app/
  Chart.yaml        → metadata
  values.yaml       → configuration surface
  templates/        → parameterised Kubernetes manifests
```

---

## The real power: values.yaml

Example:

```yaml
replicaCount: 3
image:
  repository: nginx
  tag: 1.25
```

---

And in templates:

```yaml
replicas: {{ .Values.replicaCount }}
```

---

## Why this matters

You can:

* deploy same app to dev/prod with different configs
* version deployments
* reuse architecture

---

## 🔄 Helm lifecycle

```text
Chart → packaged definition
Release → deployed instance
```

---

### Install

```bash
helm install my-release ./my-app
```

---

### Upgrade

```bash
helm upgrade my-release ./my-app
```

---

### Rollback

```bash
helm rollback my-release 1
```

👉 This is huge:

> Native version control for deployments

---

# 🏗️ Building Your Own Helm Charts (Properly)

This is where most tutorials completely fail.

Running:

```bash
helm create my-app
```

is not the goal.

---

## The real goal is:

> Define your application as a **parameterised, reusable deployment model**

---

### What you should actually design:

* clear values interface (`values.yaml`)
* modular templates
* environment-specific overrides
* sensible defaults

---

## Real-world example

Instead of hardcoding:

```yaml
replicas: 3
```

You define:

```yaml
replicas: {{ .Values.replicaCount }}
```

Now:

* dev → 1 replica
* prod → 5 replicas

Same chart. Different behaviour.

---

# 🌍 Artifact Hub — The Ecosystem

👉 [https://artifacthub.io](https://artifacthub.io)

This is where:

* production-grade charts live
* best practices are encoded

But:

> Installing a chart is easy
> Understanding it is not

---

# ⚠️ What Most People Never Learn

---

## 1. Kubernetes does not guarantee safe deployments

It executes your intent — even if it’s wrong.

---

## 2. Deployment strategy must match system design

* Rolling update → requires backward compatibility
* Blue/Green → requires traffic control
* Canary → requires observability

---

## 3. Helm can make things worse

If misused:

* too much abstraction
* unreadable templates

---

## 4. Scaling is constrained by architecture

Kubernetes scales Pods — not systems.

---

# 🧠 Final Mental Model

```text
Deployment → controls state
Labels → connect components
Service → routes traffic
Strategy → defines change
Helm → manages complexity
```

---

# 🚀 Final Thought

> Kubernetes doesn’t make deployments safe — it makes them programmable.

And once deployments are programmable:

👉 Your architecture decisions matter more than ever.

---

## 🔜 Next Part

In **Part 3**, we’ll go into:

👉 Observability, debugging, probes, and real-world troubleshooting

Because deploying is only half the story —
**understanding what is happening after deployment is where real engineers stand out.**
