---
title: "Docker Was Slowing My Deploys. Podman Fixed It in 45 Seconds. | by inprogrammer"
source: "https://freedium-mirror.cfd/medium.com/@inprogrammer/docker-was-slowing-my-deploys-podman-fixed-it-in-45-seconds-ba0ef46c149f"
author:
published:
created: 2026-05-05
description: "My FastAPI deploys took 8 minutes with Docker. I switched to Podman and dropped it to 45 seconds...."
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@inprogrammer/docker-was-slowing-my-deploys-podman-fixed-it-in-45-seconds-ba0ef46c149f#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*_ke7gVqWKVtau-1RCWfhMg.png)

## Docker Was Slowing My Deploys. Podman Fixed It in 45 Seconds.

## My FastAPI deploys took 8 minutes with Docker. I switched to Podman and dropped it to 45 seconds. Here's what changed, what broke, and why…

a11y-light · May 5, 2026 (Updated: May 5, 2026) · Free: No

#### My FastAPI deploys took 8 minutes with Docker. I switched to Podman and dropped it to 45 seconds. Here's what changed, what broke, and why I'm never going back to slow builds.

**Friend link for non members-** **[https://medium.com/@inprogrammer/docker-was-slowing-my-deploys-podman-fixed-it-in-45-seconds-ba0ef46c149f?sk=ae9497cfcd11686341b446a718dec851](https://medium.com/@inprogrammer/docker-was-slowing-my-deploys-podman-fixed-it-in-45-seconds-ba0ef46c149f?sk=ae9497cfcd11686341b446a718dec851)**

I was losing an hour every single day to Docker builds.

No exaggeration. My FastAPI app deployed 6 to 8 times daily. Each deploy took 8 minutes. That adds up to nearly 1 hour wasted just watching build logs.

The frustrating part was this. Most of that time was unnecessary. Docker kept rebuilding layers that never changed. It re-downloaded packages that already existed. Same steps. Same delays. Every time.

I tried everything to fix it. Multi-stage builds. Smarter layer ordering. Aggressive caching. Best case, I got it down to 6 minutes.

Still too slow.

Then I switched to Podman.

First deploy took 45 seconds. I assumed something failed. Ran it again. 43 seconds.

That is when I realized the problem was not my setup.

It was Docker.

### The Problem: Docker Builds Were Painfully Slow

My Dockerfile looked standard. Nothing obviously wrong:

```sql
FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]
```

Clean. Simple. Slow as hell.

**What actually happened during each build:**

Minute 0–2: Docker pulled the Python base image (even though it was cached).

Minute 2–5: Installed 47 Python packages from requirements.txt (even though only one package changed).

Minute 5–7: Copied application code (the only thing that actually changed).

Minute 7–8: Created final image layers and pushed to registry.

Eight minutes. Every single deploy. For a 3-line code change.

### Why Docker Was So Slow

Docker struggles with Python deploys for a few simple reasons:

**1\. Cache breaks too easily** Docker saves build steps, but one small code change resets everything after it. Change one line → it rebuilds all layers → even installs packages again.

**2\. No pip cache** pip downloads packages every time. Same files. Same downloads. Wasted time on every build.

**3\. Slow base image checks** Even when images exist, Docker still checks and pulls layers again. This alone can take 1 to 2 minutes.

**4\. BuildKit is not enough** Docker BuildKit helps a bit, but not a big fix. You might save a minute or two, but builds are still slow.

**Result:** More waiting. Less shipping.

### The First Podman Deploy

I installed Podman and ran the exact same Dockerfile. No changes.

```typescript
podman build -t myapp .
```

First build: 4 minutes 20 seconds. Slower than Docker actually, because Podman had zero cache.

Then I made a one-line code change and rebuilt.

```typescript
podman build -t myapp .
```

45 seconds.

I thought it failed. Checked the image. Worked perfectly. Checked again. 43 seconds.

Docker would have taken 8 minutes for the same change.

### What Podman Does Differently

Podman is not just a Docker alternative. It handles Python builds in a smarter way.

**1\. Better layer reuse** Podman reuses layers more intelligently. If only your app code changes, it keeps the pip install layer. No need to reinstall everything.

**2\. Real package caching** Podman works well with system-level cache. When pip downloads a package once, it can reuse it in the next build. No repeated downloads.

**3\. Runs without root** Podman is rootless by default. Fewer permission checks. Faster file operations during builds.

**4\. No background daemon** Unlike Docker, Podman does not run a daemon. Less overhead. Faster commands.

**5\. Faster file handling** Uses efficient copy-on-write storage. Files are not fully copied between layers, so builds feel almost instant.

**Result:** Less rebuild. Less download. Much faster deploys.

### Real Performance Numbers

I tested both on the same deployment pipeline. Same code, same server, same network.

Scenario 1: Fresh build (no cache)

- Docker: 8 minutes 14 seconds
- Podman: 4 minutes 18 seconds
- Winner: Podman (47% faster)

Scenario 2: Code change only

- Docker: 7 minutes 52 seconds (still rebuilds pip install)
- Podman: 45 seconds (reuses pip cache)
- Winner: Podman (10.5x faster)

Scenario 3: Requirements.txt change

- Docker: 8 minutes 31 seconds
- Podman: 3 minutes 12 seconds
- Winner: Podman (2.7x faster)

Scenario 4: No changes (rebuilding same code)

- Docker: 1 minute 8 seconds
- Podman: 8 seconds
- Winner: Podman (8.5x faster)

The pattern is clear. Docker is slow across the board. Podman shines especially when only code changes, which is 90% of deploys during development.

### The Migration Was Surprisingly Easy

I expected migrating from Docker to Podman to be painful. It was not.

Step 1: Install Podman

```csharp
sudo apt-get install podman
```

That is it. No daemon to configure. No groups to join. Just install and use.

Step 2: Use the same Dockerfile

Podman is Dockerfile-compatible. My existing Dockerfile worked without any changes.

Step 3: Replace docker commands with podman

```yaml
# Old
docker build -t myapp .
docker run -p 8000:8000 myapp

# New
podman build -t myapp .
podman run -p 8000:8000 myapp
```

Literally just replacing the word "docker" with "podman" in my scripts.

Step 4: Update CI/CD pipeline

My GitHub Actions workflow needed minor tweaks:

```yaml
# Before
- name: Build with Docker
  run: docker build -t myapp .

# After  
- name: Build with Podman
  run: podman build -t myapp .
```

Took 15 minutes to update. Everything worked on first try.

### What Actually Broke

Not everything was smooth. Three issues came up.

Issue 1: Docker Compose compatibility

I used docker-compose for local development with Postgres and Redis. Podman has podman-compose but it is not perfect.

Some docker-compose features did not work. Had to rewrite a few service definitions.

Fix: Use podman-compose for simple setups. For complex orchestration, I switched to Kubernetes manifests which Podman supports natively.

Issue 2: Volume permissions

Docker volumes just worked. Podman volumes had permission issues because rootless containers have different UIDs.

Fix: Added explicit UID mapping in container config:

```bash
podman run --userns=keep-id -v ./data:/app/data myapp
```

Issue 3: Image registry compatibility

Pushing to Docker Hub from Podman required authentication tweaks. Docker login credentials did not transfer automatically.

Fix: Ran `podman login docker.io` separately and stored credentials in Podman's auth file.

### Production Deployment Changes

Moving Podman to production was smooth but required infrastructure adjustments.

Change 1: No more Docker daemon

My old setup had the Docker daemon running on each server, eating 200–400MB RAM constantly.

Podman has no daemon. Freed up memory immediately.

Change 2: Systemd integration

Podman integrates natively with systemd for container management. No need for Docker's service wrapper.

```bash
podman generate systemd --name myapp > /etc/systemd/system/myapp.service
systemctl enable myapp
systemctl start myapp
```

Containers start on boot automatically. Logs go to journalctl. Cleaner than Docker's setup.

Change 3: Health checks work better

Podman health checks integrate with systemd. If a container fails health checks, systemd restarts it automatically.

Docker required external monitoring tools. Podman does it natively.

Change 4: No more privileged containers

Docker needed privileged mode for some operations. Security risk.

Podman rootless containers do not need privileges. Better security by default.

### The Cost Impact

Faster builds mean real cost savings.

Time savings:

- Before: 8 minutes per deploy × 7 deploys/day = 56 minutes daily
- After: 45 seconds per deploy × 7 deploys/day = 5.25 minutes daily
- Saved: 50.75 minutes daily

Developer productivity:

- Waiting time eliminated: 50 minutes/day
- Context switching reduced (less time to get distracted during builds)
- More iterations possible in same timeframe

CI/CD cost savings:

- GitHub Actions charges per minute
- Before: 56 minutes daily × 30 days = 1,680 minutes/month
- After: 5.25 minutes daily × 30 days = 157.5 minutes/month
- Savings: 1,522.5 minutes = $15.22/month (at $0.01/minute)

Not huge money savings, but the productivity gain is worth way more than $15.

Infrastructure cost reduction:

- Docker daemon RAM usage: 300MB per server × 3 servers = 900MB
- Podman daemon RAM: 0MB
- Freed RAM used for application instead

### When Docker Is Still Better

Podman is not perfect. Some cases where Docker wins:

Docker Desktop is better for Mac/Windows development

Podman on Mac requires a VM. Docker Desktop is more polished and faster on non-Linux systems.

For local development on Mac, I still use Docker Desktop. Deploy to production with Podman on Linux.

Docker Compose is more mature

If your entire infrastructure relies heavily on docker-compose with advanced features, migration pain might not be worth it.

Team familiarity matters

My team knew Docker. Podman has a learning curve. If your team is productive with Docker and builds are not a bottleneck, do not switch just because.

Enterprise support

Docker has commercial support options. Podman is community-driven. If you need vendor support contracts, Docker is safer.

### Would I Switch Back to Docker

No.

The speed difference is too dramatic. Going from 8 minute deploys to 45 seconds changed my development workflow.

I deploy more often now. Test changes faster. Iterate quicker. The productivity gain is real.

Docker is not bad. For small projects or infrequent deploys, it is fine. But for active Python development with multiple daily deploys, Podman is objectively faster.

### Quick Start Guide

If you want to try Podman:

Step 1: Install it

```csharp
# Ubuntu/Debian
sudo apt-get install podman

# Fedora/RHEL
sudo dnf install podman

# macOS (requires VM)
brew install podman
podman machine init
podman machine start
```

Step 2: Test with your existing Dockerfile

```
podman build -t test-app .
podman run -p 8000:8000 test-app
```

Step 3: Compare build times

```perl
# First build
time podman build -t test-app .

# Change one line of code
# Rebuild
time podman build -t test-app .
```

Step 4: If faster, update your deploy scripts

Just replace "docker" with "podman" in your automation.

Step 5: Test in staging before production

Do not yolo deploy to production. Verify everything works in staging first.

### What Surprised Me Most

The compatibility is shockingly good. I expected to rewrite Dockerfiles. Nope. Everything just worked.

Rootless containers are actually useful. I thought this was a security gimmick. It genuinely makes deployment easier and safer.

The speed difference is not marginal. This is not "10% faster." It is 10x faster for the common case of code-only changes.

Nobody talks about this. Most "Docker vs Podman" articles focus on philosophy and architecture. Almost none mention the massive build speed advantage for Python projects.

### Final Thoughts

Docker is fine. Podman is faster.

For Python projects with frequent deploys, the build time difference is night and day. Eight minutes to 45 seconds is not an incremental improvement. It is a fundamental workflow change.

If you deploy multiple times daily and build time annoys you, try Podman. Worst case, you waste an hour testing. Best case, you save an hour every day.

I am never going back to 8-minute builds.

[< Go to the original](https://medium.com/@inprogrammer/docker-was-slowing-my-deploys-podman-fixed-it-in-45-seconds-ba0ef46c149f#bypass)