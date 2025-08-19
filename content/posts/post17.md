---
title: "System Deployment"
date: 2025-04-20T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Deployment", "Environments", "CI/CD", "IaC", "Kubernetes"]
author: "Me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "System Deployment: A Practical Guide for Developers"
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
# System Deployment: A Practical Guide for Developers

System deployment is how you move your code from “it works on my machine” to serving real users safely, repeatably, and fast. Done well, deployments become boring: predictable, observable, and reversible. This guide covers the essentials—from packaging and pipelines to rollout strategies and post-deploy verification—so you can ship with confidence.

## What “Deployment” Really Means

Deployment is the automated process of:
- Building a reproducible artifact (e.g., container image)
- Provisioning or updating infrastructure
- Configuring the runtime environment
- Releasing the new version with minimal risk
- Verifying, monitoring, and rolling back if needed

Key principles:
- Immutability: Build once, deploy the same artifact everywhere.
- Declarative over imperative: Describe desired state; let tools converge to it.
- Idempotency: Running the process multiple times results in the same state.
- Fast feedback and small batches: Ship in small, testable increments.

## Environments and Promotion

Common flow: dev → staging → production. Keep them:
- Isolated (Network, data, identity)
- Alike but not identical (production data scale is different)
- Promotion-based: Promote artifacts between environments; don’t rebuild.

Tip: Use the same deployment code for all environments, parameterized by configuration.

## Build and Package: Artifacts That Travel Well

- Language-native package (JAR, wheel) vs. container image. Containers are the default for portability and consistent runtime behavior.
- Versioning: Semantic versioning (e.g., 1.4.2) and build metadata (git SHA). Tag both.
- SBOM and signing: Generate an SBOM (e.g., with Syft) and sign images (Cosign) to secure the supply chain.
- Minimal images: Use distroless or slim bases to reduce surface area.

Example Dockerfile (Node.js, multi-stage):

```dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage (distroless for security)
FROM gcr.io/distroless/nodejs20
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
USER nonroot
CMD ["dist/server.js"]
```

## CI/CD Pipeline: From Commit to Release

A typical pipeline:
1. Lint, test, and build
2. Package artifact (container)
3. Scan (SAST/DAST), SBOM, sign
4. Push to registry
5. Deploy to environment
6. Verify and notify

Example GitHub Actions (container build + K8s deploy):

```yaml
name: ci-cd
on:
  push:
    branches: [main]
    tags: ['v*.*.*']

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm test -- --ci

  package-and-publish:
    needs: build-test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/app:sha-${{ github.sha }}
            ghcr.io/${{ github.repository }}/app:${{ github.ref_name }}
      # Optional: SBOM + sign (Syft, Cosign)

  deploy-staging:
    if: github.ref == 'refs/heads/main'
    needs: package-and-publish
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Setup kubectl
        uses: azure/setup-kubectl@v4
        with: { version: 'v1.30.0' }
      - name: Kubeconfig
        run: echo "${KUBECONFIG_B64}" | base64 -d > $HOME/.kube/config
        env:
          KUBECONFIG_B64: ${{ secrets.KUBECONFIG_STAGING_B64 }}
      - name: Deploy
        run: |
          kubectl set image deployment/myapp myapp=ghcr.io/${{ github.repository }}/app:sha-${{ github.sha }} -n apps
          kubectl rollout status deployment/myapp -n apps --timeout=120s

  deploy-prod:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: package-and-publish
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
        with: { version: 'v1.30.0' }
      - run: echo "${KUBECONFIG_B64}" | base64 -d > $HOME/.kube/config
        env:
          KUBECONFIG_B64: ${{ secrets.KUBECONFIG_PROD_B64 }}
      - name: Deploy
        run: |
          kubectl set image deployment/myapp myapp=ghcr.io/${{ github.repository }}/app:${{ github.ref_name }} -n apps
          kubectl rollout status deployment/myapp -n apps --timeout=180s
```

Notes:
- Stage deploy on main branch, prod deploy on version tags.
- Use environments to gate with approvals.
- Consider GitOps (Argo CD, Flux) to sync desired state from Git.

## Infrastructure as Code (IaC) and Config Management

- IaC: Terraform, Pulumi, or CloudFormation to provision networks, clusters, databases, and IAM.
- Config Management: Ansible, Chef, or cloud-init for VM-level config; Helm/Kustomize for Kubernetes manifests.
- Drift detection: Run terraform plan in CI; use GitOps for Kubernetes.

Example: Kubernetes Deployment + Service with health probes and resource limits.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: apps
  labels: { app: myapp, version: v1.4.2 }
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  selector:
    matchLabels: { app: myapp }
  template:
    metadata:
      labels: { app: myapp }
    spec:
      containers:
        - name: myapp
          image: ghcr.io/acme/myapp:sha-abcdef1
          ports: [{ containerPort: 8080 }]
          envFrom:
            - configMapRef: { name: myapp-config }
            - secretRef: { name: myapp-secrets }
          readinessProbe:
            httpGet: { path: /healthz, port: 8080 }
            initialDelaySeconds: 5
            periodSeconds: 5
          livenessProbe:
            httpGet: { path: /livez, port: 8080 }
            initialDelaySeconds: 10
            periodSeconds: 10
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits: { cpu: "500m", memory: "512Mi" }
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: apps
spec:
  selector: { app: myapp }
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
```

## Release Strategies: Reduce Risk

- Rolling update: Replace pods gradually. Default in Kubernetes; simple and effective when backward compatible.
- Blue–green: Run two identical stacks (blue and green). Switch traffic by changing a Service selector or a load balancer target.
- Canary: Release to a small percentage, monitor, then ramp up. Requires traffic weighting (e.g., service mesh like Istio/Linkerd or gateway weighting).
- Feature flags: Decouple deploy from release; toggle features per user segment.

Blue–green with a selector switch:

```yaml
# Green deployment
apiVersion: apps/v1
kind: Deployment
metadata: { name: myapp-green, namespace: apps, labels: { color: green } }
spec: { ... template: { metadata: { labels: { app: myapp, color: green }}, spec: { containers: [...] } } }

# Blue deployment (currently live)
apiVersion: apps/v1
kind: Deployment
metadata: { name: myapp-blue, namespace: apps, labels: { color: blue } }
spec: { ... template: { metadata: { labels: { app: myapp, color: blue }}, spec: { containers: [...] } } }

# Service – flip 'color' to cut over
apiVersion: v1
kind: Service
metadata: { name: myapp, namespace: apps }
spec:
  selector: { app: myapp, color: blue } # change to green to switch
  ports: [{ port: 80, targetPort: 8080 }]
```

Rollback tips:
- Kubernetes: kubectl rollout undo deploy/myapp
- Helm: helm rollback myapp <REVISION>
- Keep the last N versions warm for rapid fallback.

## Database Changes Without Downtime

Follow a 2-phase, backward-compatible migration pattern:
1. Deploy code that tolerates both old and new schemas.
2. Migrate data and add new columns/indexes online.
3. Switch code to use the new schema.
4. Drop old columns in a later release.

Example (add a nullable column first, then backfill, then enforce):

```sql
-- Phase 1: additive, safe
ALTER TABLE users ADD COLUMN nickname TEXT NULL;

-- Backfill in batches
UPDATE users SET nickname = SUBSTRING(email, 1, 8) WHERE nickname IS NULL LIMIT 1000;

-- Phase 2: app reads/writes nickname
-- Phase 3: enforce constraints
ALTER TABLE users ALTER COLUMN nickname SET NOT NULL;
```

Tools: Flyway, Liquibase, gh-ost/pt-online-schema-change (for MySQL), strong migrations (Rails). Always test on production-sized data.

## Configuration and Secrets Management

- 12-Factor principle: Store config in the environment, not in code.
- Use ConfigMaps and Secrets in Kubernetes, or Vault/Parameter Store/Secrets Manager.
- Rotate credentials and short-lived tokens (OIDC, IRSA/GCP Workload Identity).
- Avoid baking secrets into images or repos; use sealed secrets or external secrets operators.

## Observability, Health, and Verification

- Health checks: readiness (traffic gating) and liveness (self-healing).
- Metrics: Request rate, error rate, latency (RED); resource usage.
- Logging: Structured logs with trace IDs.
- Tracing: Distributed traces to spot cross-service latency.
- SLOs/SLIs and error budgets to guide rollout speed.

Automated verification ideas:
- Post-deploy smoke tests hitting key endpoints
- Synthetic checks from multiple regions
- Compare canary vs. baseline metrics

Example commands:
- Check rollout: kubectl rollout status deploy/myapp -n apps
- Inspect last events: kubectl describe deploy/myapp -n apps
- Undo: kubectl rollout undo deploy/myapp -n apps

## Security in the Deployment Pipeline

- Supply chain:
  - Pin dependencies and base images
  - SBOM generation and image scanning (Grype/Trivy)
  - Image signing and verification (Cosign, policy-controller)
  - Build provenance (SLSA)
- Runtime:
  - Least-privilege service accounts and IAM
  - Network policies and pod security standards
  - Admission controls (OPA Gatekeeper/Kyverno)
- Secrets:
  - Encrypted at rest/in transit, access via workload identity

## Scaling, Performance, and Cost

- Autoscaling: Horizontal Pod Autoscaler (HPA) on CPU/RPS/queue depth; Vertical Pod Autoscaler for right-sizing.
- Capacity: Use load tests; plan surge capacity for deployments (maxSurge).
- Cost: Choose fitting instance sizes, leverage spot/preemptible for stateless, bin-pack with resource requests/limits.

## Monoliths, Microservices, Serverless, and On‑prem

- Monoliths: Fewer moving parts; simpler orchestration; still use CI/CD, blue–green, and health checks.
- Microservices: Independent pipelines, contract testing, shared platform standards (logging, tracing, SLOs).
- Serverless: Deploy functions via SAM/Serverless Framework/Cloud Functions; focus on versioning, aliases, and gradual traffic shifting.
- On‑prem/Hybrid: Emphasize IaC for VMs and networks; use configuration management and artifact repositories; networking and identity integration are key.

## A Minimal Deployment Checklist

Pre-deploy:
- Build once; artifact tagged with version + SHA
- Tests pass; SBOM generated; image scanned and signed
- Migration plan is backward-compatible
- Feature flags default safe
- Observability dashboards and alerts ready

During deploy:
- Progressive rollout (canary/rolling)
- Monitor error rates, latency, saturation
- Keep blast radius small; throttle if anomalies appear

Post-deploy:
- Run smoke tests and business KPIs checks
- Record deployment metadata (who, what, when, version)
- Clean up old resources and feature flags
- Plan follow-up to remove deprecated paths

## Common Pitfalls

- Manual steps or click-ops: leads to drift and outages
- Snowflake servers: unique pets instead of cattle
- Secrets in repos or images
- Non-reversible DB migrations
- Overly large releases and weekend deploys
- No rollback runbooks or insufficient metrics

## Putting It Together: A Reference Flow

1. Developer merges to main.
2. CI runs tests and builds a signed container image with SBOM.
3. Artifact pushed to registry; GitOps repo updated with new tag.
4. Argo CD/Flux syncs to staging; canary deploy; automated checks run.
5. Promote to production via pull request + approval; progressive delivery with monitoring gates.
6. If KPIs degrade, automatic rollback triggers; otherwise traffic ramps to 100%.
7. Post-deploy report posted to Slack with version and metrics.

## Final Thoughts

Great system deployment isn’t about a specific tool—it’s about discipline: immutable artifacts, automated pipelines, progressive releases, strong observability, and fast, safe rollbacks. Start simple, automate relentlessly, and evolve toward boring, reliable deployments.

If you want a hands-on next step, try:
- Containerizing one service with a multi-stage Dockerfile
- A CI pipeline that builds, scans, and signs the image
- A Kubernetes rolling update with readiness probes and a canary gate
- A two-phase database migration verified with smoke tests

Ship small. Watch closely. Roll back fast. Repeat.