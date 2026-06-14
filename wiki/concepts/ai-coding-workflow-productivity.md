---
title: AI Coding Workflow and Productivity
type: concept
created: 2026-06-14
tags:
  - concept
  - ai-coding
  - workflow
  - productivity
  - software-engineering
---

# AI Coding Workflow and Productivity

The quality of AI-generated code depends less on prompt cleverness and more on process discipline. The core method is context-first: provide complete task context, ask for an implementation plan before code, review decisions early, and execute in small reviewed steps.

## Context-First Workflow

```
1. Gather context (requirements, codebase structure, conventions)
2. Request implementation plan (markdown: scope, files, approach, rationale)
3. Review and challenge plan decisions
4. Execute step-by-step with review gates
5. Generate and review tests
6. Manual test scenarios
```

### Step 1: Context

Give the model the full task artifact — requirements, acceptance criteria, constraints — instead of a memory-based summary. Ask the AI to study project structure and conventions before generating code.

**Context bundle:**
- Task description and acceptance criteria.
- Relevant architecture docs or `CLAUDE.md` rules.
- Existing code patterns (show 2-3 examples).
- Error messages or stack traces if fixing a bug.

### Step 2: Implementation Plan

Ask for a markdown plan before code:

```markdown
## Implementation Plan: Add Rate Limiting Middleware

### Scope
- New middleware class `RateLimitMiddleware`
- Uses Redis-backed sliding window
- Configurable per-route limits

### Files
- `app/middleware/rate_limit.py` — new
- `app/config/rate_limits.py` — new
- `tests/test_rate_limit.py` — new

### Approach
1. Read rate limit config from settings
2. On request, check Redis sorted set for client_id
3. If under limit, add timestamp and allow
4. If over limit, return 429 with Retry-After header

### Edge Cases
- Redis connection failure → allow request, log error
- Clock skew → use server time only
- Rapid retry after 429 → include Retry-After
```

### Step 3: Review

Review plan decisions with business and architecture context that the model cannot infer:

- Does the architecture match the existing codebase patterns?
- Are there existing utilities the model did not know about?
- Does the plan handle all acceptance criteria?
- Are there security, performance, or operational concerns?

### Step 4: Execute

Implement step-by-step. Review each step before moving to the next. Update the existing plan incrementally after clarifications instead of regenerating from scratch.

### Step 5: Tests

Generate tests and review them as carefully as the implementation. Tests encode assumptions — wrong tests encode wrong assumptions.

## Cognitive Modes

| Mode | When to Use | Risk |
|------|-------------|------|
| **Supportive** | Familiar domain, implementation only | Over-reliance, skill decay |
| **Mixed** | Unfamiliar domain, learning mode | Slower, but builds understanding |
| **Exploratory** | Prototyping, spike solutions | May generate throwaway code |
| **Review-only** | Bug fixes in unfamiliar code | Slower, but preserves understanding |

The supportive mode is for implementation speed. The mixed mode is for learning. Switching between them based on task is the mark of an experienced AI user.

## Bottleneck Awareness

AI coding does not eliminate bottlenecks — it shifts them:

```
Without AI:    Writing code → Review → Test → Deploy
              [bottleneck: writing]

With AI:       Writing code → Review → Test → Deploy
              [bottleneck: review + test]
```

As code generation accelerates, the bottleneck shifts to review queues, CI systems, validation workflows, and release coordination. Teams must invest in the entire SDLC, not just code generation.

## Learning-Oriented AI Use

AI coding accelerates strong engineers and also accelerates weak or absent reasoning. To avoid cognitive debt:

- **Pre-commit review**: read every AI-generated change before committing.
- **Post-commit reflection**: for complex changes, revisit after a day and see if you understand the code.
- **Explain the code**: if you cannot explain an AI-generated function to a colleague, do not ship it.
- **Alternate modes**: use AI for speed when the domain is familiar, and for learning when it is not.

## Links

- Parent concept: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/code-quality-and-ai-slop|Code Quality and AI Slop Management]]
- Related: [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Related: [[concepts/structured-learning-and-retention|Structured Learning and Retention]]
- Source: [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]]
- Source: [[sources/medium-10x-dev-llm-coding-faster|10x Dev: LLM Coding Faster Without Slop]]
- Source: [[sources/ai-developer-cognitive-archetypes|AI Developer Cognitive Archetypes]]
- Source: [[sources/dont-outsource-learning|Don't Outsource the Learning]]
- Source: [[sources/dropbox-beyond-code-generation|Dropbox Nova Agent Platform]]
