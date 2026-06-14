---
title: "Garry Tan's Claude Code Senior Engineer Prompt"
source: "https://howaiworks.ai/blog/garry-tan-claude-code-senior-engineer-prompt"
author:
  - "[[HowAIWorks.ai Team]]"
published: 2026-02-23
created: 2026-06-14
description: "Discover how Y Combinator CEO Garry Tan uses Claude Code as a senior engineer to ship complex features with fully tested code in under an hour."
tags:
  - "clippings"
---
## Introduction

Artificial Intelligence is no longer just a autocomplete tool or a basic code generator. We are entering the era of the **AI Senior Engineer**, where models don't just write code—they review systems, evaluate trade-offs, and plan complex architectures.

Recently, **Garry Tan**, CEO of Y Combinator, shared the exact prompt he uses with **Claude Code**. With this approach, he reported shipping features exceeding 4,000 lines of code, complete with full test coverage, in approximately one hour. This isn't just about speed; it's about shifting the AI's role from a junior coder to a staff-level reviewer.

## The Strategy: Plan Mode First

The core of this workflow is utilizing Claude Code's **Plan Mode**. Instead of asking the AI to "build X," the prompt instructs it to "review the plan for X" across four critical engineering pillars. This forces the model to pause, analyze, and wait for human feedback before a single line of production code is written.

By using this approach, you transform the development process into a collaborative review pipeline. The AI identifies bottlenecks, duplication, and edge cases that often get missed in rapid development cycles.

## The Four Pillars of AI Review

The Garry Tan prompt breaks down the review process into four distinct categories, mirroring the checklist of a high-level software architect.

### 1\. Architecture Review

The AI evaluates the overall system design. It looks at component boundaries, dependency graphs, and potential single points of failure. It asks: *Is the data flow efficient? Are the security boundaries well-defined?*

### 2\. Code Quality Review

This stage focuses on maintainability. The AI aggressively flags violations of the **DRY (Don't Repeat Yourself)** principle and identifies areas that are either over-engineered or under-engineered.

### 3\. Test Review

Rather than just checking for coverage, the AI evaluates the *quality* of assertions and identifies missing edge cases or failure scenarios that haven't been accounted for.

### 4\. Performance Review

The final check looks for N+1 queries, inefficient I/O operations, and memory usage risks. This ensures that the code isn't just correct, but production-ready and scalable.

## The "Senior Engineer" Prompt

Below is the full prompt shared by Garry Tan. You can use this in **Claude Code** (or similar agentic environments) to elevate the quality of AI-driven development.

```markdown
# Claude / AI Senior Engineer Prompt (Plan Mode)

Before writing any code, review the plan thoroughly.  
Do NOT start implementation until the review is complete and I approve the direction.

For every issue or recommendation:

- Explain the concrete tradeoffs
- Give an opinionated recommendation
- Ask for my input before proceeding

Engineering principles to follow:

- Prefer DRY — aggressively flag duplication
- Well-tested code is mandatory (better too many tests than too few)
- Code should be “engineered enough” — not fragile or hacky, but not over-engineered
- Optimize for correctness and edge cases over speed of implementation
- Prefer explicit solutions over clever ones

---

## 1. Architecture Review

Evaluate:

- Overall system design and component boundaries
- Dependency graph and coupling risks
- Data flow and potential bottlenecks
- Scaling characteristics and single points of failure
- Security boundaries (auth, data access, API limits)

---

## 2. Code Quality Review

Evaluate:

- Project structure and module organization
- DRY violations
- Error handling patterns and missing edge cases
- Technical debt risks
- Areas that are over-engineered or under-engineered

---

## 3. Test Review

Evaluate:

- Test coverage (unit, integration, e2e)
- Quality of assertions
- Missing edge cases
- Failure scenarios that are not tested

---

## 4. Performance Review

Evaluate:

- N+1 queries or inefficient I/O
- Memory usage risks
- CPU hotspots or heavy code paths
- Caching opportunities
- Latency and scalability concerns

---

## For each issue found:

Provide:

1. Clear description of the problem
2. Why it matters
3. 2–3 options (including “do nothing” if reasonable)
4. For each option:
   - Effort
   - Risk
   - Impact
   - Maintenance cost
5. Your recommended option and why

Then ask for approval before moving forward.

---

## Workflow Rules

- Do NOT assume priorities or timelines
- After each section (Architecture → Code → Tests → Performance), pause and ask for feedback
- Do NOT implement anything until I confirm

---

## Start Mode

Before starting, ask:

**Is this a BIG change or a SMALL change?**

BIG change:

- Review all sections step-by-step
- Highlight the top 3–4 issues per section

SMALL change:

- Ask one focused question per section
- Keep the review concise

---

## Output Style

- Structured and concise
- Opinionated recommendations (not neutral summaries)
- Focus on real risks and tradeoffs
- Think and act like a Staff/Senior Engineer reviewing a production system
```

## Conclusion

The takeaway from Garry Tan's approach is clear: the future of software engineering isn't just about faster code generation, but about **integrated AI review**. By baking senior-level principles into the AI's planning phase, developers can maintain high standards of quality while moving at an unprecedented pace.

If your team lacks a staff-level engineer, you can partially fill that gap by embedding these high-level review processes directly into your AI workflow.

## Sources

- [Garry Tan's Original X Post](https://x.com/garrytan/status/1893815340058521798)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code)
- [HowAIWorks Guide to Agentic LLMs](https://howaiworks.ai/glossary)