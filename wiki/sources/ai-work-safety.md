---
title: How to Use AI at Work Without Breaking Your Systems
type: source
created: 2026-05-08
source: https://substack.com/home/post/p-190624275
tags:
  - source
  - ai
  - safety
  - operations
---

# How to Use AI at Work Without Breaking Your Systems

## Summary

This source argues that AI coding assistants should be treated like fast junior engineers: useful for drafts and proposals, but unsafe when given unsupervised production authority. The practical pattern is to keep AI contained, require human verification, and route execution through controlled systems.

## Key Ideas

- Agentic coding tools can run destructive commands, delete databases, overwrite files, misconfigure infrastructure, or ship broken deployments when permissions and review gates are too loose.
- AI should not have direct production access; credentials and filesystem permissions should be scoped to development or sandbox environments.
- Engineers should read generated commands before running them, especially commands with destructive flags such as `--force`, recursive deletion, or infrastructure deletion.
- Infrastructure and deployment changes should go through version control, pull requests, staging environments, CI checks, and human approval gates.
- Backups must be automated, distributed, and tested through restores.
- The operating rule is: AI suggests, humans verify, systems execute.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (guardrails, backups, approvals, and production protection)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (AI output ownership)
- Connects to [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]] (agent tools and production risk)

