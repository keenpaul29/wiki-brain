---
title: FastAPI 0.115 Migration Breakages
type: source
created: 2026-05-05
source: https://freedium-mirror.cfd/medium.com/ai-in-plain-english/a-fastapi-update-broke-my-production-app-here-is-the-fix-08d88362805e
tags:
  - source
  - fastapi
  - migration
  - reliability
---

# FastAPI 0.115 Migration Breakages

## Summary

This source describes a production FastAPI upgrade from `0.109` to `0.115` that broke authentication, response validation, background tasks, CORS, WebSockets, datetime serialization, and optional query parameters. The durable lesson is that stricter framework validation can be an improvement while still being a risky production migration.

## Key Ideas

- FastAPI dependency signatures became stricter; request sources such as headers should be explicit with `Annotated`.
- Pydantic v2-style response validation surfaced extra fields that older versions silently ignored.
- Background tasks need explicit exception handling and logging because failures can otherwise disappear from normal request logs.
- Credentialed CORS cannot safely use wildcard origins; production deployments should list real origins per environment.
- WebSocket handlers should treat normal disconnects as expected control flow.
- Datetime serialization should move toward Pydantic field serializers rather than removed custom encoder hooks.
- Optional query parameters should be typed explicitly as nullable, such as `str | None = None`.
- The migration pattern was staged: categorize failures, fix critical paths first, validate in staging with the real frontend, and roll out production traffic gradually.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (migration risk, observability, staged rollout)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (type clarity and production ownership)

