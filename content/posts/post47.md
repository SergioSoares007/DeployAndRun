---
title: "What Really Happens on a Kubernetes Node (Deep Dive)"
date: 2025-11-02T23:00:03+00:00
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
description: "What Really Happens on a Kubernetes Node (Deep Dive): OverlayFS, containerd, Volumes, and the Hidden Mechanics"
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
# What Really Happens on a Kubernetes Node (Deep Dive): OverlayFS, containerd, Volumes, and the Hidden Mechanics

Most Kubernetes explanations stop at Pods and containers.

But the real story — the one that actually helps you debug, optimise, and reason about failures — happens **inside the node**.

This article goes beyond the basics and explains:

* OverlayFS (and why it matters in real scenarios)
* containerd internals (beyond “it runs containers”)
* Image storage and caching
* Writable layers and their limitations
* Volume mounting mechanics (bind mounts)
* The kubelet’s role in orchestrating everything
* Linux primitives: namespaces & cgroups
* Where performance and problems actually come from

---

## 🧠 The Real Execution Flow

When you create a Pod, Kubernetes does NOT “run a container”.

It orchestrates Linux primitives:

```text
Pod Spec
  ↓
kubelet (node agent)
  ↓
containerd (runtime)
  ↓
runc (low-level runtime)
  ↓
Linux kernel (namespaces, cgroups, mounts)
```

👉 Kubernetes is just the control plane — Linux does the real work.

---

## ⚙️ containerd Internals (What It Actually Does)

containerd is not a monolith — it has multiple components:

* **Image store** → keeps image layers
* **Snapshotter** → builds filesystem layers (OverlayFS)
* **Runtime (runc)** → actually starts processes
* **Content store** → manages blobs (layers)

📍 Important paths:

```bash
/var/lib/containerd/io.containerd.content.v1.content/
/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/
```

---

### 🧠 Key Insight

> containerd does NOT “run containers” directly — it prepares everything and delegates execution to `runc`.

---

## 📦 Image Pulling & Layer Reuse

When Kubernetes pulls an image:

1. It downloads layers (if not cached)
2. Stores them as blobs
3. Reuses layers across containers

👉 Example:

Two Pods using `python:3.9`:

* base layers downloaded once
* reused everywhere

---

### ⚠️ Performance Insight

Slow image pulls?

* Not network — often **layer unpacking (I/O bound)**

---

## 🧱 OverlayFS — Beyond the Basics

You already know:

```text
Read-only layers + Writable layer = container filesystem
```

But here’s what matters in practice:

---

### ⚠️ Copy-on-Write Cost

When a container modifies a file from the image:

👉 It is **copied to the writable layer**

This means:

* Large file modification = expensive
* Databases inside containers = BAD idea (without volumes)

---

### 💥 Real Problem Example

```text
App writes logs inside /app/logs (image layer)
```

👉 Every write triggers CoW → performance degradation

✅ Solution:

> Always use volumes for write-heavy workloads

---

## 🔁 Writable Layer Limitations

The container writable layer:

* Is ephemeral
* Has worse performance than volumes
* Is not shareable
* Can fill up node disk silently

👉 This is a **very common production issue**

---

## 📦 Volumes = Bind Mounts (Important!)

Kubernetes volumes are implemented as:

> **bind mounts from the host into the container**

---

### 🔍 What actually happens

```text
Host path:
/var/lib/kubelet/pods/<uid>/volumes/...

↓ (bind mount)

Container:
/data
```

👉 The container is just seeing a mapped directory

---

### 🧠 Key Insight

> Volumes are NOT part of OverlayFS — they bypass it.

That’s why:

* they are faster
* they persist
* they are shared

---

## 🔐 Secrets — More Than Just tmpfs

Secrets are:

* stored in etcd (base64 encoded, not encrypted by default)
* mounted as tmpfs
* injected via kubelet

---

### ⚠️ Important Detail

Even though mounted in memory:

👉 They still pass through:

* API server
* kubelet
* node filesystem (temporarily)

---

## 🧠 Kubelet — The Hidden Orchestrator

Kubelet is the most underrated component.

It:

* Watches Pod specs
* Mounts volumes
* Calls containerd
* Manages lifecycle
* Handles probes (liveness/readiness)

📍 Its working directory:

```bash
/var/lib/kubelet/
```

---

## 🧬 Namespaces — The Illusion of Isolation

Containers are NOT VMs.

They are processes isolated using:

* **PID namespace** → process isolation
* **Mount namespace** → filesystem isolation
* **Network namespace** → virtual network
* **UTS namespace** → hostname

---

### 🧠 Insight

> A container is just a process with constraints.

---

## 📊 cgroups — Resource Control

cgroups control:

* CPU limits
* Memory limits
* I/O

👉 Without cgroups:

* containers would compete freely
* node stability would collapse

---

## 💥 Where Problems Actually Happen

Understanding internals helps diagnose real issues:

---

### 1. Disk Pressure

Usually caused by:

```bash
/var/lib/containerd/
/var/lib/kubelet/
```

---

### 2. Image Bloat

Too many unused images → disk full

---

### 3. Writable Layer Abuse

Apps writing inside container filesystem instead of volumes

---

### 4. Too Many Small Files

OverlayFS performs poorly with:

* lots of small file operations

---

## 🔍 Debugging Like a Pro

Instead of guessing:

### Check container storage:

```bash
du -sh /var/lib/containerd/*
```

### Check pod volumes:

```bash
du -sh /var/lib/kubelet/pods/*
```

### Check mounts:

```bash
mount | grep overlay
```

---

## 🧠 Mental Model (Advanced)

```text
Image layers (immutable)
        ↓
OverlayFS (ephemeral writable layer)
        ↓
Volumes (persistent, bind-mounted)
        ↓
tmpfs (secrets/config)
        ↓
Namespaces (isolation)
        ↓
cgroups (resource control)
```

---

## 🚀 Final Takeaway

> Kubernetes does not run containers — it orchestrates Linux primitives to create isolated, layered, and composable runtime environments.

Understanding this stack is what allows you to:

* Debug real production issues
* Design better storage strategies
* Avoid performance pitfalls
* Pass CKAD with confidence

---

## 🔥 Closing Thought

> If you don’t understand where your data lives, you don’t really understand your system.

And in Kubernetes, data lives in more places than you think.
