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

## Decision Log

- 2026-05-19: Maintain a shared engineering language page in the wiki for recurring project terms and lightweight decisions, similar to a `CONTEXT.md`.

## Maintenance Rule

When a term, boundary, or decision appears in multiple wiki pages or agent handoffs, add it here with one short definition and links to the deeper pages. Prefer updating this page over creating duplicate local explanations.
