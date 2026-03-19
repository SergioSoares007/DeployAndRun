---
title: "From Local Dockerfile to Kubernetes Deployment"
date: 2025-10-19T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["k8s", "docker"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "From Local Dockerfile to Kubernetes Deployment: A Complete Step-by-Step Guide"
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

# From Local Dockerfile to Kubernetes Deployment: A Complete Step-by-Step Guide

## Introduction

In modern cloud-native development, containerisation and orchestration are fundamental skills. This guide walks you through the entire lifecycle of a simple Python application — from building a Docker image locally, storing it in GitHub, pushing it to Docker Hub, and finally running it in a Kubernetes cluster from another virtual machine.

By the end of this tutorial, you will have a fully reproducible workflow that mirrors real-world DevOps practices.

---

## Prerequisites

Before starting, ensure you have:

* A GitHub account
* A Docker Hub account
* Access to a cloud provider (e.g., DigitalOcean)
* Basic knowledge of Linux terminal commands
* Installed locally:

  * Docker
  * Git
  * Python (optional but useful for testing)

---

## Step 1 — Create a Simple Python Application

Create a project folder:

```bash
mkdir python-docker-app
cd python-docker-app
```

Create a file called `app.py`:

```python
from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello from Dockerized Python app!")

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8000), SimpleHandler)
    print("Server running on port 8000...")
    server.serve_forever()
```

---

## Step 2 — Create the Dockerfile

Create a file named `Dockerfile`:

```Dockerfile
# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY app.py .

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "app.py"]
```

---

## Step 3 — Test Locally with Docker

Build the image:

```bash
docker build -t python-docker-app .
```

Run the container:

```bash
docker run -p 8000:8000 python-docker-app
```

Test in browser:

```
http://localhost:8000
```

---

## Step 4 — Initialise Git and Push to GitHub

Initialise repository:

```bash
git init
git add .
git commit -m "Initial commit - Python Docker app"
```

Create a repository on GitHub, then:

```bash
git remote add origin https://github.com/YOUR_USERNAME/python-docker-app.git
git branch -M main
git push -u origin main
```

---

## Step 5 — Create a Cloud VM (DigitalOcean Example)

* Create a Droplet (Ubuntu recommended)
* Add your SSH key (recommended)
* Note the public IP address

Connect via SSH:

```bash
ssh root@YOUR_VM_IP
```

---

## Step 6 — Install Docker on the VM

```bash
apt update
apt install -y docker.io
systemctl start docker
systemctl enable docker
```

(Optional) Allow non-root usage:

```bash
usermod -aG docker $USER
```

Log out and back in.

---

## Step 7 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/python-docker-app.git
cd python-docker-app
```

---

## Step 8 — Build the Docker Image on the VM

```bash
docker build -t python-docker-app .
```

Verify:

```bash
docker images
```

---

## Step 9 — Login to Docker Hub

```bash
docker login
```

Enter your credentials.

---

## Step 10 — Tag the Image

Replace `yourdockerhubusername` accordingly:

```bash
docker tag python-docker-app yourdockerhubusername/python-docker-app:latest
```

---

## Step 11 — Push the Image to Docker Hub

```bash
docker push yourdockerhubusername/python-docker-app:latest
```

Confirm the image appears in Docker Hub.

---

## Step 12 — Prepare Another VM (Kubernetes Client)

Create another VM or reuse an existing one.

Install:

```bash
apt update
apt install -y docker.io
```

Install kubectl:

```bash
apt install -y curl
curl -LO "https://dl.k8s.io/release/latest/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

## Step 13 — Configure Kubernetes Access

You need access to a Kubernetes cluster (e.g., DigitalOcean Kubernetes, Minikube, or K3s).

Verify access:

```bash
kubectl get nodes
```

---

## Step 14 — Deploy the Image Using kubectl

Run the container:

```bash
kubectl run python-app \
  --image=yourdockerhubusername/python-docker-app:latest \
  --port=8000
```

Check the pod:

```bash
kubectl get pods
```

---

## Step 15 — Expose the Application

```bash
kubectl expose pod python-app --type=NodePort --port=8000
```

Get service details:

```bash
kubectl get svc
```

---

## Step 16 — Access the Application

Find the NodePort and access:

```
http://NODE_IP:NODE_PORT
```

---

## Additional Best Practices (Often Missed)

### 1. Use a `.dockerignore`

```bash
.git
__pycache__
*.pyc
```

---

### 2. Use Version Tags (Avoid only `latest`)

```bash
docker tag python-docker-app yourdockerhubusername/python-docker-app:v1.0
docker push yourdockerhubusername/python-docker-app:v1.0
```

---

### 3. Add Health Checks (Optional)

Inside Dockerfile:

```Dockerfile
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1
```

---

### 4. Use Kubernetes Deployment Instead of Pod

```bash
kubectl create deployment python-app \
  --image=yourdockerhubusername/python-docker-app:latest
```

---

### 5. Scale the Application

```bash
kubectl scale deployment python-app --replicas=3
```

---

### 6. Debugging

```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

---

## Conclusion

This guide demonstrated a full DevOps workflow:

* Building a Python application
* Containerising it with Docker
* Versioning and storing code in GitHub
* Distributing images via Docker Hub
* Deploying workloads into Kubernetes

These steps form the backbone of modern cloud-native systems. While the example is intentionally simple, the same workflow scales to production-grade systems with CI/CD pipelines, monitoring, and automated deployments.

Mastering this process ensures you can confidently move applications from your local machine into scalable, distributed environments.


