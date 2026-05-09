---
title: Exception Handling Patterns Over Blanket try-catch
type: source
created: 2026-05-09
source: https://freedium-mirror.cfd/medium.com/stackademic/junior-devs-use-try-catch-everywhere-senior-devs-use-these-4-exception-handling-patterns-dcd869ed6551
tags:
  - source
  - exception-handling
  - backend
  - reliability
---

# Exception Handling Patterns Over Blanket try-catch

## Summary

This source contrasts defensive-looking but fragile blanket `try-catch` usage with four structured patterns: upfront validation, typed exception hierarchies, centralized exception handling, and result objects for expected outcomes.

## Key Ideas

- Input problems should be prevented with validation at boundaries, not caught after failure.
- Generic exceptions hide root causes; specific application exceptions should carry intent and response semantics.
- Controller-level duplication should be replaced with centralized handlers (for example, `@RestControllerAdvice`) and consistent error payloads.
- Expected business outcomes should use explicit result types rather than exceptions.
- A useful distinction is expected vs exceptional failures: expected outcomes drive control flow, exceptional failures trigger logs, alerts, and recovery.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (failure classification and operational visibility)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (accountability for correctness and production behavior)
- Connects to [[concepts/software-design-patterns|Software Design Patterns]] (control-flow design decisions from concrete pain)

