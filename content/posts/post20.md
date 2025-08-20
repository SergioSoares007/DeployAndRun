---
title: "101 Sites Every System Architect and Developer Should Know"
date: 2025-05-11T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Business Applications", "Developers"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "101 Sites Every System Architect and Developer Should Know"
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
# 101 Sites Every System Architect and Developer Should Know

Whether you’re designing systems, building APIs, or keeping services healthy in production, having the right links bookmarked saves time and reduces risk. This curated list groups 101 essential sites by category—covering standards, cloud, CI/CD, infra-as-code, monitoring, data, security, and more. Each entry includes a short “why it matters.”

Tip: Don’t try to adopt everything. Pick one or two per category that fit your stack and maturity, then expand as your needs grow.

---

## Foundational References (10)

- MDN Web Docs — https://developer.mozilla.org/  
  Gold-standard references for web APIs, JavaScript, CSS.
- W3C — https://www.w3.org/  
  Web standards and specifications.
- IETF RFC Editor — https://www.rfc-editor.org/  
  Canonical protocols (HTTP, TLS, DNS, etc.).
- WHATWG HTML Living Standard — https://html.spec.whatwg.org/  
  The evolving HTML spec.
- Unicode Consortium — https://unicode.org/  
  Character encoding standards (text correctness matters).
- TC39 (ECMAScript) — https://tc39.es/  
  JavaScript proposals and language evolution.
- OpenAPI Initiative — https://www.openapis.org/  
  The de facto standard for REST API contracts.
- AsyncAPI — https://www.asyncapi.com/  
  Contracts for event-driven and message-based systems.
- GraphQL — https://graphql.org/  
  Spec, best practices, and ecosystem for GraphQL APIs.
- Open Container Initiative — https://opencontainers.org/  
  Standards for container images and runtimes.

---

## Architecture & Patterns (8)

- Martin Fowler — https://martinfowler.com/  
  Architecture essays on patterns, refactoring, and microservices.
- microservices.io — https://microservices.io/  
  Patterns for service decomposition and inter-service comms.
- 12factor — https://12factor.net/  
  App design for SaaS and cloud-native delivery.
- Azure Architecture Center — https://learn.microsoft.com/azure/architecture/  
  Reference architectures, patterns, anti-patterns.
- AWS Well-Architected — https://aws.amazon.com/architecture/well-architected/  
  Pillars for building secure, reliable, cost-aware systems.
- Google Cloud Architecture — https://cloud.google.com/architecture  
  Design blueprints, SRE practices, and decision guides.
- ThoughtWorks Tech Radar — https://www.thoughtworks.com/radar  
  Pragmatic takes on tools, techniques, platforms, languages.
- Enterprise Integration Patterns — https://www.enterpriseintegrationpatterns.com/  
  Messaging patterns you’ll use beyond ESBs.

---

## Cloud & Hosting (12)

- Amazon Web Services — https://aws.amazon.com/  
  Broadest cloud platform; industry default for many.
- Microsoft Azure — https://azure.microsoft.com/  
  Strong enterprise and hybrid story.
- Google Cloud — https://cloud.google.com/  
  Data/ML strengths and global network.
- DigitalOcean — https://www.digitalocean.com/  
  Simple VMs, managed DBs, and K8s for SMBs/startups.
- Linode (Akamai) — https://www.linode.com/  
  Developer-friendly VMs and managed services.
- Hetzner — https://www.hetzner.com/  
  Cost-effective dedicated and cloud servers in EU.
- Netlify — https://www.netlify.com/  
  Jamstack hosting, serverless functions, CI for sites.
- Vercel — https://vercel.com/  
  Frontend-first hosting, edge functions, Next.js native.
- Cloudflare — https://www.cloudflare.com/  
  CDN, DNS, WAF, edge compute, and performance tools.
- Render — https://render.com/  
  PaaS for web services, background workers, static sites.
- Fly.io — https://fly.io/  
  Run apps close to users with global deployment.
- Heroku — https://www.heroku.com/  
  Classic PaaS with a deep add-on ecosystem.

---

## Containers & Orchestration (8)

- Docker — https://www.docker.com/  
  Standard container tooling for dev and prod.
- Kubernetes — https://kubernetes.io/  
  The orchestration platform for containerized workloads.
- Helm — https://helm.sh/  
  Package manager for Kubernetes manifests.
- Minikube — https://minikube.sigs.k8s.io/  
  Local single-node Kubernetes for development.
- kind — https://kind.sigs.k8s.io/  
  K8s in Docker—fast local clusters for CI/testing.
- k3s — https://k3s.io/  
  Lightweight Kubernetes for edge/IoT/small clusters.
- Podman — https://podman.io/  
  Daemonless containers; Docker-compatible CLI.
- Docker Hub — https://hub.docker.com/  
  Public and private container image registry.

---

## CI/CD & DevOps (10)

- GitHub — https://github.com/  
  Source hosting, PRs, Actions CI/CD, packages.
- GitLab — https://about.gitlab.com/  
  All-in-one DevOps platform with integrated CI/CD.
- Bitbucket — https://bitbucket.org/  
  Atlassian VCS with Pipelines CI.
- Jenkins — https://www.jenkins.io/  
  Extensible open-source automation server.
- CircleCI — https://circleci.com/  
  Fast, hosted CI for containers and monorepos.
- Travis CI — https://travis-ci.com/  
  Simple pipelines; long-standing OSS heritage.
- Buildkite — https://buildkite.com/  
  Hybrid CI—hosted control plane, your own runners.
- Argo CD — https://argo-cd.readthedocs.io/  
  GitOps continuous delivery for Kubernetes.
- Tekton — https://tekton.dev/  
  Kubernetes-native CI/CD building blocks.
- Spinnaker — https://spinnaker.io/  
  Multi-cloud progressive delivery (canary, blue/green).

---

## Infrastructure as Code & Config (8)

- Terraform — https://www.terraform.io/  
  Provider-based IaC for multi/cloud infra.
- Pulumi — https://www.pulumi.com/  
  IaC with real languages (TypeScript, Python, Go, C#).
- AWS CloudFormation — https://aws.amazon.com/cloudformation/  
  Native AWS IaC with deep service coverage.
- Ansible — https://www.ansible.com/  
  Agentless configuration management and orchestration.
- Chef — https://www.chef.io/  
  Policy-as-code for infra and compliance.
- Puppet — https://puppet.com/  
  Declarative infra automation at scale.
- Salt Project — https://saltproject.io/  
  Event-driven automation and config management.
- Crossplane — https://www.crossplane.io/  
  Control-plane-driven IaC on top of Kubernetes.

---

## Monitoring, Logging & Tracing (10)

- Prometheus — https://prometheus.io/  
  Metrics scraping, alerting, and time series.
- Grafana — https://grafana.com/  
  Visualization for metrics, logs, traces; alerting.
- Datadog — https://www.datadoghq.com/  
  Unified APM, infra, logs, RUM, security.
- New Relic — https://newrelic.com/  
  Full-stack observability with APM and telemetry.
- Elastic — https://www.elastic.co/  
  Elasticsearch, Logstash, Kibana for search/logs.
- Splunk — https://www.splunk.com/  
  Machine data analytics and enterprise logging.
- Sentry — https://sentry.io/  
  Error tracking for backends, frontends, and mobile.
- Honeycomb — https://www.honeycomb.io/  
  High-cardinality observability and event-based debugging.
- OpenTelemetry — https://opentelemetry.io/  
  Vendor-neutral SDKs and specs for telemetry data.
- Jaeger — https://www.jaegertracing.io/  
  Distributed tracing backend and UI.

---

## Databases & Storage (10)

- PostgreSQL — https://www.postgresql.org/  
  Robust relational database with rich SQL features.
- MySQL — https://www.mysql.com/  
  Ubiquitous relational DB powering many stacks.
- MongoDB — https://www.mongodb.com/  
  Document database with flexible schemas.
- Redis — https://redis.io/  
  In-memory data store for caching, queues, streams.
- Apache Cassandra — https://cassandra.apache.org/  
  Linearly scalable, highly available wide-column store.
- CockroachDB — https://www.cockroachlabs.com/  
  Globally distributed, strongly consistent SQL.
- ClickHouse — https://clickhouse.com/  
  Columnar OLAP database for fast analytics.
- SQLite — https://www.sqlite.org/  
  Embedded SQL DB for apps and edge.
- Amazon S3 — https://aws.amazon.com/s3/  
  Durable object storage—data lake default.
- MinIO — https://min.io/  
  S3-compatible object storage you can run anywhere.

---

## Messaging & Streaming (7)

- Apache Kafka — https://kafka.apache.org/  
  High-throughput distributed event log.
- Confluent — https://www.confluent.io/  
  Managed Kafka, connectors, stream governance.
- RabbitMQ — https://www.rabbitmq.com/  
  Battle-tested AMQP broker for work queues and RPC.
- Apache Pulsar — https://pulsar.apache.org/  
  Multi-tenant messaging + streaming with tiered storage.
- NATS — https://nats.io/  
  Lightweight, fast messaging with JetStream.
- MQTT (EMQX) — https://www.emqx.com/en/mqtt  
  IoT-friendly pub/sub over constrained networks.
- Apache Flink — https://flink.apache.org/  
  Stateful stream processing at scale.

---

## Search & Indexing (5)

- OpenSearch — https://opensearch.org/  
  Open-source search and analytics suite.
- Apache Solr — https://solr.apache.org/  
  Enterprise search on top of Lucene.
- Meilisearch — https://www.meilisearch.com/  
  Lightweight, typo-tolerant search for apps.
- Typesense — https://typesense.org/  
  Fast, simple search engine with a great DX.
- Algolia — https://www.algolia.com/  
  Hosted search with great relevance and analytics.

---

## API & Integrations (5)

- Postman — https://www.postman.com/  
  API design, testing, monitoring, collections.
- Swagger / SwaggerHub — https://swagger.io/  
  OpenAPI tooling and collaborative API design.
- Stoplight — https://stoplight.io/  
  Contract-first design, mocking, and governance.
- Hoppscotch — https://hoppscotch.io/  
  Open-source API client for REST, GraphQL, WebSocket.
- Kong — https://konghq.com/  
  API gateway and service mesh for microservices.

---

## Security & Auth (8)

- OWASP — https://owasp.org/  
  Top 10, cheat sheets, and secure design resources.
- Let’s Encrypt — https://letsencrypt.org/  
  Free TLS certificates with ACME automation.
- Have I Been Pwned — https://haveibeenpwned.com/  
  Breach checks and Pwned Passwords for defenses.
- Security Headers — https://securityheaders.com/  
  Quick audit of your site’s security headers.
- Snyk — https://snyk.io/  
  Dependency, container, and IaC vulnerability scanning.
- Auth0 — https://auth0.com/  
  Hosted authentication, authorization, and MFA.
- Keycloak — https://www.keycloak.org/  
  Open-source identity and access management.
- HashiCorp Vault — https://www.vaultproject.io/  
  Secrets management, encryption, and dynamic creds.

---

## How to use this list (without getting overwhelmed)

- Start with standards and patterns. They outlast tools.  
- For each problem space (hosting, CI, IaC, observability, data, auth), pilot one option that aligns with your team’s skills and constraints.  
- Prefer contract-first (OpenAPI/AsyncAPI) and infrastructure-as-code (Terraform/Pulumi) to reduce drift.  
- Bake in security and observability from day one—retrofitting is costlier than starting right.

Happy building—and bookmark this so your next architectural decision starts from strong options.