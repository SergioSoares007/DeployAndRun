---
title: "CKAD Certification Journey — Part 4: Application Environment, Configuration & Security"
date: 2025-11-23T23:00:03+00:00
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
description: "CKAD Certification Journey — Part 4: Application Environment, Configuration & Security"
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
# CKAD Certification Journey — Part 4: Application Environment, Configuration & Security (Where Control Meets Responsibility)

By the time you reach this stage, you already know how to:

* build applications
* deploy them
* observe them

But here is where things become **real engineering**:

> 👉 How you configure and secure your applications determines whether your system is stable, multi-tenant, and safe — or fragile and dangerous.

This is not just about features like ConfigMaps or Secrets.
This is about understanding **how Kubernetes enforces boundaries and behaviour**.

---

# 🧠 The Kubernetes API Is Extensible — CRDs

Kubernetes is not a fixed platform.

It is:

> 👉 an **extensible API system**

---

## 🔧 What is a CRD (Custom Resource Definition)?

A **CRD** allows you to define your own Kubernetes object.

Instead of just:

* Pods
* Deployments
* Services

You can create:

* `APIConnectCluster`
* `AnalyticsCluster`
* `Database`

---

## 🧠 Why this matters

CRDs are the foundation of:

* Operators
* Platform engineering
* Kubernetes as a platform (not just orchestration)

---

## 📄 Example CRD

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: myapps.example.com
spec:
  group: example.com
  names:
    kind: MyApp
    plural: myapps
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
```

---

## 🔁 What happens after you apply it?

```text
CRD registered
   ↓
New API endpoint created
   ↓
kubectl can now manage new resource type
```

---

## 🔍 Discovering resources

```bash
kubectl api-resources
```

This shows:

* built-in resources (`pods`, `deployments`)
* CRDs (`analyticsclusters`, `datapowerservices`, etc.)

---

## 🧠 Insight

> Kubernetes is not just using APIs — it **is an API platform**

---

# 🔐 Security Model — The Three Pillars

Kubernetes security is built on:

```text
Authentication → Authorization → Admission Control
```

---

## 1️⃣ Authentication — Who are you?

Methods include:

* username/password
* LDAP
* tokens
* X.509 certificates

---

## 2️⃣ Authorization — What can you do?

Controlled via **RBAC (Role-Based Access Control)**

Example:

```yaml
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

---

## 3️⃣ Admission Control — Should this request be allowed?

This is where Kubernetes:

* enforces quotas
* validates configs
* mutates requests

---

## 🧠 Insight

> Admission control is where governance actually happens

---

# 📊 Resource Management — The Hidden Constraint

Kubernetes does not give you infinite resources.

Every node has limits.

👉 If you don’t manage them:

* noisy neighbour problems
* unstable workloads
* cluster-wide failures

---

## ⚙️ Requests vs Limits

Defined at **container level**:

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

---

## 🧠 CPU Explained

```text
1 CPU = 1000m (millicores)
```

* `100m` = 0.1 CPU
* `500m` = half a core

---

## ⚠️ Important behaviour

* **Requests** → used for scheduling
* **Limits** → enforced at runtime

---

## 💥 Real issue

```text
Low memory limit → OOMKilled
```

---

# 🏢 Resource Quotas — Multi-Tenant Control

In shared clusters:

> 👉 Without quotas, one team can consume everything

---

## Example

```yaml
kind: ResourceQuota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    pods: "10"
```

---

## How it works

* Applied per namespace
* Enforced by admission controller

---

## 🧠 Insight

> Quotas are not about fairness — they are about **protecting the cluster**

---

# ⚙️ ConfigMaps — Externalising Configuration

Applications should not hardcode configuration.

---

## What is a ConfigMap?

* key-value store
* non-sensitive data
* managed via Kubernetes API

---

## Creating ConfigMaps

### Imperative

```bash
kubectl create configmap app-config \
  --from-literal=env=prod \
  --from-file=config.txt
```

👉 File name = key
👉 File content = value

---

### Declarative

```yaml
apiVersion: v1
kind: ConfigMap
data:
  APP_MODE: production
```

---

## Using ConfigMaps

### As environment variables

```yaml
env:
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_MODE
```

---

### As files

Mounted as volume:

```yaml
volumeMounts:
- name: config
  mountPath: /etc/config
```

---

## 🔍 Debugging

```bash
kubectl describe configmap app-config
kubectl exec pod -- env
```

---

## 🧠 Insight

> ConfigMaps decouple code from environment — critical for CI/CD

---

# 🔐 Secrets — Same Concept, Higher Risk

Secrets are for:

* passwords
* tokens
* certificates

---

## ⚠️ Important Truth

```text
Secrets are base64 encoded — NOT encrypted by default
```

---

## Creating a Secret

```bash
echo -n 'adminuser' | base64
```

```yaml
kind: Secret
data:
  username: YWRtaW51c2Vy
```

---

## Using Secrets

Same as ConfigMaps:

* env variables
* mounted files

---

## Types of Secrets

* Opaque
* TLS
* Docker registry

---

## 🧠 Insight

> Secrets are about access control, not encryption

---

# 🔒 Security Context — Controlling Runtime Behaviour

SecurityContext defines:

* user ID
* privileges
* filesystem access

---

## Example

```yaml
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
```

---

## Pod vs Container

* Pod-level → default
* Container-level → overrides

---

## Why this matters

By default:

```text
Containers run as root
```

👉 This is a risk.

---

## 🧠 Insight

> SecurityContext is your last line of defence inside the container

---

# 🆔 Service Accounts — Identity Inside the Cluster

Pods need identity to talk to Kubernetes API.

---

## What is a ServiceAccount?

> 👉 An identity assigned to a Pod

---

## Example

```yaml
spec:
  serviceAccountName: my-service-account
```

---

## What it enables

* API access
* RBAC control
* secure communication

---

## 🧠 Insight

> ServiceAccounts are how Pods become first-class citizens in the cluster

---

# 🔥 Bringing It All Together

This is not a list of features — this is a system:

---

```text
CRDs → extend Kubernetes
ConfigMaps → configure apps
Secrets → protect sensitive data
SecurityContext → control runtime
ServiceAccount → define identity
ResourceQuota → enforce fairness
RBAC → enforce permissions
```

---

# ⚠️ What Most People Get Wrong

---

## 1. Config is hardcoded

👉 breaks portability

---

## 2. Secrets treated as secure storage

👉 they are not (without encryption at rest)

---

## 3. No resource limits

👉 leads to cluster instability

---

## 4. Running everything as root

👉 major security risk

---

## 5. Ignoring RBAC

👉 over-permissioned systems

---

# 🧠 Final Thought

> Kubernetes is not just about running containers — it is about controlling behaviour, access, and resources in a distributed system.

If you get this part wrong:
👉 everything else eventually breaks.

---

## 🔜 Next Part

In **Part 5**, we’ll explore:

👉 Services, Networking, and Traffic Flow

Because:

> how traffic flows through your system defines how your system behaves under load.
