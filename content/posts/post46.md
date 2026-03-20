---
title: "CKAD Certification Journey — Part 1: Application Design & Build"
date: 2025-10-26T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["k8s", "CKAD"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "CKAD Certification Journey — Part 1: Application Design & Build"
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
# CKAD Certification Journey — Part 1: Application Design & Build

Achieving the **Certified Kubernetes Application Developer (CKAD)** certification has been a rewarding milestone in my journey as a developer. This blog series is structured into **five parts**, each covering a key domain of the CKAD curriculum:

1. **Application Design & Build** *(this article)*
2. Application Deployment
3. Application Observability & Maintenance
4. Application Environment, Configuration & Security
5. Services & Networking

This first part focuses on the **foundations of building applications for Kubernetes** — understanding containers, how they are built and distributed, and how Kubernetes runs them efficiently.

---

## 🧱 Container Fundamentals

### Docker Images — The Building Blocks

Every Kubernetes workload starts with a **container image**.

A Docker image is:

* Immutable (does not change once built)
* Layered (each instruction adds a layer)
* Portable (can run anywhere Docker is supported)

👉 Think of it as a **snapshot of your application + runtime + dependencies**.

---

### 🐳 Building Custom Images

Creating your own image gives you full control over your application runtime.

**Example Dockerfile:**

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT ["python"]
CMD ["app.py"]
```

### 🔍 Best Practices for Dockerfiles

* Use **small base images** (e.g., `alpine`, `slim`)
* Minimise layers (combine commands where possible)
* Use `.dockerignore` to exclude unnecessary files
* Avoid running containers as root
* Pin dependency versions for reproducibility

---

### ⚙️ ENTRYPOINT vs CMD (Deep Dive)

These two instructions define how your container behaves at runtime.

```bash
ENTRYPOINT ["python"]
CMD ["app.py"]
```

#### How they work together:

* `ENTRYPOINT` → defines the executable
* `CMD` → provides default arguments

➡️ Default execution:

```bash
python app.py
```

➡️ Override CMD:

```bash
docker run my-image script.py
```

➡️ Result:

```bash
python script.py
```

💡 **Important insight for CKAD:**
Use `ENTRYPOINT` when you want to enforce a specific executable, and `CMD` when you want flexibility.

---

### 📦 Docker Hub & Image Distribution

Once built, images need to be shared.

**Typical workflow:**

```bash
docker build -t username/my-app:v1 .
docker login
docker push username/my-app:v1
```

💡 Notes:

* Use **version tags** (`v1`, `v2`) instead of `latest`
* Private registries are common in production
* Kubernetes pulls images using `imagePullPolicy`

---

## ☸️ Kubernetes Core Concepts

### Kubernetes API — The Control Plane Brain

Everything in Kubernetes is an **API object**:

* Pods
* Deployments
* Services
* ConfigMaps

You define desired state in YAML → Kubernetes ensures it becomes reality.

---

### 🧩 Pods — The Smallest Unit

A **Pod** represents a running instance of your application.

Characteristics:

* One or more containers
* Shared network (same IP & port space)
* Shared storage (volumes)

👉 In real-world usage:

> You almost always run **one container per Pod**

---

### ⚠️ Single vs Multi-Container Pods

#### ✅ Recommended:

**Single container per Pod**

* Easier scaling
* Better isolation
* Simpler debugging

#### ❌ Multi-container drawbacks:

* Cannot scale containers independently
* Increased coupling

---

### Multi-Container Patterns (When You REALLY Need Them)

#### 1. Sidecar Pattern

Adds supporting functionality.

Example:

* Logging agent
* Monitoring exporter

#### 2. Ambassador Pattern

Acts as a proxy.

Example:

* Database proxy container

#### 3. Adapter Pattern

Transforms output.

Example:

* Convert app metrics into Prometheus format

#### 4. Init Containers

Run **before** main container starts.

Example:

```yaml
initContainers:
- name: init-db
  image: busybox
  command: ['sh', '-c', 'echo preparing environment']
```

💡 Key point:
Init containers must complete successfully before the main container starts.

---

## 🛠️ kubectl — Your Main Tool

### Generate YAML Automatically

Instead of writing YAML from scratch:

```bash
kubectl run redis-app --image=redis --dry-run=client -o yaml
```

This outputs a valid Pod manifest.

---

### Why This Is Powerful

* Saves time in exams (CKAD is time-constrained!)
* Helps learn object structure
* Reduces syntax errors

👉 You can also:

```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
```

---

### Essential Pod Commands

```bash
kubectl get pods
kubectl describe pod <name>
kubectl logs <pod>
kubectl exec -it <pod> -- /bin/sh
kubectl delete pod <name>
```

💡 CKAD tip:
Memorise these — they are heavily used during the exam.

---

## 🔁 Jobs and CronJobs

Not all workloads should run forever.

---

### 🧩 Jobs — Run Once and Finish

A **Job** ensures a task completes successfully.

Example use cases:

* Database migrations
* Data processing
* Backups

**Example:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ["echo", "Running backup"]
      restartPolicy: Never
```

---

### ⏰ CronJobs — Scheduled Execution

A **CronJob** runs Jobs on a schedule.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cron
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ["echo", "Daily backup"]
          restartPolicy: Never
```

---

### 🔍 Job vs CronJob (Clear Distinction)

| Feature   | Job       | CronJob       |
| --------- | --------- | ------------- |
| Execution | Once      | Repeated      |
| Trigger   | Manual    | Scheduled     |
| Use case  | Migration | Daily backups |

---

## 💾 Storage & Volumes

Containers are ephemeral — data disappears when they stop.

👉 Volumes solve this.

---

### Volume Types

#### emptyDir

* Lives as long as the Pod exists
* Good for temporary data (cache, scratch space)

#### hostPath

* Uses node filesystem
* Not portable (avoid in production)

---

### 📊 Data Classification

Understanding your data is critical:

| Type       | Example       | Solution          |
| ---------- | ------------- | ----------------- |
| Temporary  | Cache         | emptyDir          |
| Persistent | Database      | Persistent Volume |
| Shared     | Logs          | Network storage   |
| Config     | Env variables | ConfigMaps        |
| Sensitive  | Passwords     | Secrets           |

---

### 🔐 ConfigMaps & Secrets

#### ConfigMaps

Store non-sensitive config:

```yaml
env:
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: mode
```

#### Secrets

Store sensitive data (base64 encoded):

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

💡 Important:

* Secrets are **not encrypted by default**
* Use RBAC + encryption at rest in production

---

## 🧠 Key Takeaways

* Docker images are the **foundation** of Kubernetes workloads
* A well-structured Dockerfile makes everything easier downstream
* Pods should be **simple and single-purpose**
* Multi-container Pods are advanced — use only when necessary
* `kubectl` is essential — speed matters in CKAD
* Jobs and CronJobs handle **non-continuous workloads**
* Understanding data types helps you choose the right storage strategy

---

## 🚀 What’s Next?

In **Part 2**, we’ll dive into:

👉 **Application Deployment**

* Deployments
* ReplicaSets
* Rolling updates
* Scaling strategies

This is where Kubernetes truly starts to shine.

Stay tuned!

