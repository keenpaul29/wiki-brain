---
title: Shared Engineering Language
type: concept
created: 2026-05-19
tags:
  - concept
  - engineering
  - context
  - decisions
---

# Shared Engineering Language

This page is the wiki's shared vocabulary for recurring project terms, operating assumptions, and durable engineering decisions. It should work like a lightweight `CONTEXT.md`: short enough for agents and humans to scan, but stable enough to prevent the same concepts from being redefined in every session.

## Purpose

- Keep recurring project terms consistent across wiki pages, source summaries, code comments, and agent handoffs.
- Capture decisions that are too small for a full architecture document but too important to rediscover repeatedly.
- Give future agents a canonical place to check before inventing new names for existing concepts.
- Link terms back to deeper concept, synthesis, architecture, or source pages when more detail exists.

## Current Terms

### Raw Source

Immutable input material stored under `raw/`. Raw files are read-only for wiki maintenance. New or changed raw files are summarized into generated wiki pages rather than edited directly.

Related: [[automation|Daily Auto Update Workflow]]

### Wiki Page

A maintained markdown note under `wiki/`. Wiki pages turn raw sources into durable, linked knowledge: source summaries, concept pages, synthesis pages, maintenance pages, and state reports.

Related: [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]

### Source Summary

A factual summary page under `wiki/sources/` for one raw source. It should capture the source's main claims, useful details, and links into relevant concept or synthesis pages.

### Concept Page

A reusable idea page under `wiki/concepts/`. Concept pages should collect patterns across sources and stay focused enough that backlinks remain meaningful.

### Synthesis Page

A higher-order page under `wiki/synthesis/` that explains how several concepts and sources fit together into an operating model, study spine, or decision framework.

Related: [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]

### Project Operating Architecture

The local architecture that ties this checkout's codebase, wiki, GBrain source routing, automation, and agent handoff documents together.

Related: [[concepts/project-operating-architecture|Project Operating Architecture]]

### Brain

The database target for GBrain operations: which knowledge database an operation reads from or writes to.

Related: [[concepts/project-operating-architecture|Project Operating Architecture]]

### Source

The repository or corpus inside a brain. For this checkout, `brain` is the source slug used to sync the project into local GBrain.

Related: [[concepts/project-operating-architecture|Project Operating Architecture]]

### Ship and Learn

The two-metric AI coding standard: track both what shipped and what the engineer learned. A task can be operationally successful while still creating cognitive debt if the engineer cannot explain or reconstruct the work.

Related: [[sources/dont-outsource-learning|Don't Outsource the Learning]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]]

### Context-First Workflow

An AI coding workflow that starts with complete task context, project conventions, and an implementation plan before code generation. It keeps AI execution reviewable and aligned with human judgment.

Related: [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]], [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]

### Bottleneck Shift

The observation that accelerating code generation with AI does not eliminate SDLC bottlenecks — it moves them downstream to review queues, CI systems, validation workflows, and release coordination. Engineering productivity measurement must shift from local activity metrics (PR throughput) to broader system outcomes (product velocity, quality, rework rate).

Related: [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]

### Slop

Low-quality AI-generated code or text that passes surface review but contains hidden errors, unnecessary complexity, or lacks human judgment. The anti-slop discipline requires maintaining testing rigor, reviewing AI output like a peer's PR, and never accepting output the engineer cannot explain.

Related: [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]], [[sources/medium-10x-dev-llm-coding-faster|10x Dev: LLM Coding Without Slop]]

### Collaborative Prompt Engineering Playground

A shared environment (typically Jupyter Notebooks) where domain experts and engineers iterate on LLM prompts together. Notebooks live in the code repository, share access to production code/libraries, require code reviews and versioning, and enable rapid experimentation while keeping behavior aligned with production.

Related: [[sources/linkedin-prompt-engineering-playgrounds|Collaborative Prompt Engineering Playgrounds]]

### Local-First Sync Engine

A two-layer architecture with an engine (local reads/writes to a representation of the user's data) and a sync service (persistent WebSocket connection). Enables optimistic UI, offline operation, multi-tab coordination via BroadcastChannel, and conflict resolution. Converts a thin web client into a capable client-side application.

Related: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]], [[concepts/local-first-architecture|Local-First Architecture]]

### Fuel→Adoption→Output→Impact

A 4-stage measurement model for agentic engineering productivity. Fuel measures AI usage, Adoption measures workflow changes, Output measures production contributions (e.g., PRs submitted), and Impact measures customer value delivered.

Related: [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]

### Golden Opportunity

A career-growth action that advances multiple goals at once: learning, delivery, communication, team trust, documentation, or leadership visibility. Pair programming, project docs, and public learning are examples when they also improve the team's base execution.

Related: [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]]

### Student Mindset

The expectation that tools, practices, and domains will keep changing, so engineers must keep learning without chasing every trend. This is a career skill as much as a study tactic.

Related: [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]]

### Kaleidoscope

WhatsApp's ensemble of media-level security checks: non-conformant structure detection, risky embedded elements, spoofed file types, MIME/extension mismatches, and known-dangerous attachment classes — all running in Rust on billions of devices.

Related: [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]]

### Explore Recommendation Funnel

Instagram Explore's multi-stage funnel (retrieval → first-stage ranking → second-stage ranking → final reranking) that narrows billions of media items into personalized results using Two Tower neural nets, cached embeddings, and value-model weighted scoring.

Related: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]

### Cognitive Debt

The gap between task completion and understanding. When AI generates a solution before the engineer has formed their own hypothesis, the engineer leaves the session feeling they learned but cannot reproduce the reasoning later. Prevention: hypothesis before prompt, re-derive after session, treat AI output as a peer's draft.

Related: [[sources/dont-outsource-learning|Don't Outsource the Learning]]

### Bottleneck Shift (Engineering)

Accelerating code generation moves the constraint from writing code to reviewing, testing, integrating, and releasing. Measurement must shift from PR throughput to system outcomes (velocity, quality, rework rate). See also: Bottleneck Shift (agentic measurement, Fuel→Adoption→Output→Impact).

Related: [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]

### Tokenmaxxing

The gaming of AI-usage metrics by running automated background tasks to inflate token counts without delivering real value. A Goodhart's Law failure mode: when token consumption becomes a success metric, it ceases to be useful.

Related: [[sources/tracking-ai-usage-goodharts-law|Goodhart's Law in Corporate AI Usage Tracking]]

### PagedAttention

A memory management technique for LLM serving that divides KV cache into fixed-size blocks (pages). Blocks are allocated on demand and shared across requests with common prefixes, dramatically reducing memory fragmentation and increasing throughput 2-4x under high concurrency.

Related: [[concepts/local-llm-serving|Local LLM Serving]]

### Two-Instance Serving Pattern

A deployment architecture where short-context high-concurrency requests and rare long-context requests are served by separate model instances. Each instance is optimized for its traffic profile — smaller context window + higher throughput vs. larger context + lower concurrency.

Related: [[concepts/local-llm-serving|Local LLM Serving]]

### Feature Co-location

An ML inference pattern where candidate features are loaded directly into the inference engine's memory, eliminating high-fanout network retrieval calls during scoring. Used by Snapchat Bento to avoid microservice-style feature fetching. The opposite of a service-oriented architecture for feature serving.

Related: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]

### Order-of-Operations Risk

The learning failure that occurs when AI generates the complete solution before the human has formed their own hypothesis. If the AI answers before the human asks, the human never practices retrieval and the knowledge does not consolidate in long-term memory.

Related: [[sources/dont-outsource-learning|Don't Outsource the Learning]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]]

### Defense in Depth (Security)

A layered security strategy where multiple independent controls protect the same asset. If one layer is bypassed, the next still enforces. Applied at the application level (TLS → Auth → RBAC → Input Validation) and infrastructure level (WAF → Network ACL → Container Isolation → OS Hardening).

Related: [[concepts/security-patterns|Security Patterns]], [[concepts/memory-safety-strategy|Memory Safety and Defense-inDepth]]

## Decision Log

- 2026-05-19: Maintain a shared engineering language page in the wiki for recurring project terms and lightweight decisions, similar to a `CONTEXT.md`.

## Maintenance Rule

When a term, boundary, or decision appears in multiple wiki pages or agent handoffs, add it here with one short definition and links to the deeper pages. Prefer updating this page over creating duplicate local explanations.
