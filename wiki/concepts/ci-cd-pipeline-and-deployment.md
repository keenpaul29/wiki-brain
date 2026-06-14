---
title: CI/CD Pipeline and Deployment Strategy
type: concept
created: 2026-06-14
tags:
  - concept
  - ci-cd
  - deployment
  - devops
  - reliability
---

# CI/CD Pipeline and Deployment Strategy

A CI/CD pipeline is the automated path from code commit to production deployment. It must be consistent, fast, secure, and observable. The pipeline is not a build script — it is the team's deployment discipline encoded in automation.

## Pipeline Stages

```
[Commit] → [Lint + SAST] → [Unit Tests] → [Build Artifact]
    → [Integration Tests] → [Security Scan] → [Deploy Staging]
    → [E2E Tests] → [Deploy Production (gradual)] → [Smoke Test]
```

Each stage gates the next. If any stage fails, the pipeline stops and alerts.

### Core Principles

1. **Every change follows the same path**: no manual deploys, no skip-ci hacks.
2. **Automate by default**: manual steps are forgotten under pressure.
3. **Fast feedback**: CI should complete within 10-15 minutes.
4. **Least privilege**: pipeline access is scoped to what each stage needs.
5. **Observability**: pipeline metrics (duration, pass/fail rate, flakiness) are tracked.

### Immutable Artifact

Build once, deploy the same artifact everywhere. Never modify a built artifact:

```
Commit → CI Build → artifact:v1.2.3-build45
    ↓                    ↓
Staging uses artifact:v1.2.3-build45
Production uses artifact:v1.2.3-build45
```

Different environments get different configurations, not different artifacts.

## Deployment Strategies

| Strategy | Behavior | Risk | Rollback |
|----------|----------|------|----------|
| **Rolling** | Replace instances gradually (10-30% at a time) | Low — gradual exposure | Re-deploy old version |
| **Blue-green** | Two identical environments. Switch traffic from blue to green | Low — instant switch | Switch back (DNS/load balancer) |
| **Canary** | Route small % of traffic to new version, ramp up | Low — measured exposure | Route traffic back |
| **Feature flag** | Deploy code dark, enable via config toggle | Lowest — toggle off | Disable toggle |

The safest strategy is the one your team understands under pressure. A canary deployment with a team that has never practiced it is riskier than a rolling deployment they run daily.

## Rollback

Rollback should be a single command or automated trigger:

```
# Rollback to the previous known-good version
kubectl rollout undo deployment/my-service

# Or via CI pipeline
./deploy.sh --version v1.2.3-build44
```

Feature flags complement rollback: disable a feature without redeploying. This is faster than a rollback when the issue is a specific feature, not the entire release.

## Container Optimization

### Multi-Stage Builds

Separate build environment from runtime:

```dockerfile
# Stage 1: build
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: runtime
FROM python:3.12-slim
COPY --from=builder /root/.local /root/.local
COPY app/ /app
CMD ["python", "/app/main.py"]
```

The runtime image contains only what the application needs at runtime — no build tools, no package manager cache.

### Image Optimization

- Use distroless or slim base images (no shell, no package manager).
- Run as non-root user. Create a dedicated user in the Dockerfile.
- Use rootless container runtime for production.
- Scan images for vulnerabilities in CI.

## DORA Metrics

| Metric | What It Measures | Target (Elite) |
|--------|-----------------|----------------|
| Deployment frequency | How often code is deployed to production | Multiple times per day |
| Lead time for changes | Time from commit to production | < 1 hour |
| Change failure rate | % of deployments that cause a failure | < 5% |
| Mean time to restore (MTTR) | Time to recover from a failure | < 1 hour |

Metrics guide improvement, not punishment. Teams with low deployment frequency and high change failure rate need investment in CI/CD tooling and testing.

## Links

- Parent concept: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/integration-testing-and-test-strategy|Integration Testing and Test Strategy]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/command-line-and-git-productivity|Command-Line and Git Productivity]]
- Source: [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
- Source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
- Source: [[sources/podman-python-deploys|Podman for Faster Python Deploys]]
- Source: [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]]
