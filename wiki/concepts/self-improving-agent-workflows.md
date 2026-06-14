---
title: Self-Improving Agent Workflows
type: concept
created: 2026-04-28
tags:
  - concept
  - agents
  - automation
  - learning-loops
---

# Self-Improving Agent Workflows

Self-improving agent workflows capture feedback from human-agent sessions and convert repeated corrections into persistent instructions. The agent does not need true memory if the workflow writes lessons into files that future sessions read.

## Loop

1. Capture raw session signals.
2. Preserve human corrections, approvals, agent prompts, outputs, and skills used.
3. Wait until there are enough sessions to distinguish pattern from noise.
4. Ask an LLM worker to infer repeated mistakes.
5. Write concise rules to the most local useful place.
6. Load those lessons at the start of future work.

## Design Principles

- Human corrections are ground truth.
- Do not overfit to a single session.
- Keep lessons short and behavioral.
- Put global rules in global files and agent-specific rules near the relevant agent.
- Separate raw capture from later interpretation.

## Relevance to This Wiki

This wiki uses the same basic pattern at the knowledge-base level. Raw sources are captured in `raw/`; the maintained lessons live in `wiki/`; [[automation]] and [[maintenance]] define how future runs keep the system current. The daily auto-update job is a simpler cousin of the hook workflow: scan for new signal, integrate it into durable markdown, and preserve the result for future sessions.

## Skills and Hooks

Agent workflows become more reliable when recurring behavior is encoded as commands, skills, hooks, and permission-bounded agents. Hooks can run formatting, guard risky actions, and verify completion. Skills are most useful when they capture tested gotchas and operational protocol rather than generic explanations. Fat-skill systems go further by letting workflows run on triggers or schedules and file the results back into persistent memory.

## Agent Harnesses and Execution Sandboxes

Autonomous agents require an execution harness to turn base intelligence into functional work engines. Key components of an agent harness include:
- **Filesystem Primitives**: Serving as a workspace, coordinate state area, and git-managed integration space.
- **Sandboxed Execution**: Using secure environments (like WebAssembly or Docker containers) to run LLM-generated code (e.g. Pandas operations) and prevent arbitrary code execution on host machines.
- **Context Rot Mitigation**: Compacting context, offloading tool payloads, and employing progressive tool disclosure (skills).
- **Federated Multi-Agent Routing**: Routing complex tasks to specialized subagents using directed state graphs (such as LangGraph Routing/Grounding) with custom protocols and schemas to isolate concerns.
- **Skill Normalization**: Abstracting all data sources and capabilities into swappable, modular tools to allow new capabilities to scale without rewriting main orchestrators.

## Project Operating Layer

A maintainable agent setup needs a clear filesystem shape. Keep global project context in a compact root instruction file, keep operational controls in obvious settings files, and move specialized guidance into modular rule files. Commands, hooks, skills, and agents should each have a distinct home so reusable behavior can grow without turning the main instruction file into an overloaded prompt dump.

## Environment-Aware Automation

Remote and containerized development environments can carry their own agent instructions. This lets an assistant know which toolchains are installed, which commands are safe, and what kind of machine it is operating in. The same principle applies to wiki automation: preserve durable rules near the workspace and use logs or queues so scheduled jobs coordinate instead of re-discovering state each run.

## Production Agent Platforms

Dropbox's Nova demonstrates agentic coding at production scale: Nova produces ~1 in 12 pull requests at Dropbox. Agents handle migrations, flaky test remediation, bug investigation, and dependency updates alongside feature work. The key measurement model tracks four stages: Fuel (AI usage), Adoption (workflow changes), Output (production contributions), and Impact (customer value). The insight is that agentic engineering moves more pressure upstream into product and design — sharper problem framing and specs matter more when agents execute implementation.

## Federated Multi-Agent Architectures

Two production patterns extend self-improving workflows across multiple specialized agents:

### Kensho Grounding: Router-Orchestrated Retrieval

[[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]] uses a centralized RouterGraph (LangGraph) to orchestrate federated data retrieval across structured financial datasets. A single routing agent classifies the query intent and dispatches to specialized data agents, each responsible for one dataset domain.

Key design properties:

- **Custom communication protocols**: agents query, respond, and pass execution metadata through typed contracts. Protocol versioning prevents silent drift between router and agent interfaces.
- **LangGraph tracing**: end-to-end observability across nested routing paths. Essential for debugging the multi-step routing decisions that produce incorrect results.
- **Multi-stage evaluation**: router accuracy is measured at two levels — routing decision correctness (did the router pick the right agent?) and tool-call correctness (did the agent execute the right query?). Both are checked against exact-match ground-truth datasets.

The learning loop: routing mistakes are captured, classified, and fed back as refinement prompts for the router agent's instructions. This is the same capture→distill→file pattern applied to agent orchestration.

### Madrigal: Modular Agent Platforms

[[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]] abstracts data sources into standardized tool interfaces, decoupling orchestration from ingestion. Skills are swappable modules that can be composed into new research workflows without modifying the main orchestrator.

Key design properties:

- **Managed deployment containers**: agents run as microservices in Docker containers, each research team invoking agent skills via APIs. This is the team-topologies platform-team model applied to agent infrastructure.
- **Evaluative feedback loops**: production errors are captured, converted into assertions, and added as regression tests. The system's knowledge of what went wrong compounds over time.
- **LangSmith tracing**: transparency into model decisions, tool calls, and data retrievals across the agent lifecycle — not just at inference time.

The learning loop: Madrigal's capture→assert→test cycle is the behavioral equivalent of the wiki's ingest→summarize→link cycle. Both turn transient execution outcomes into durable system knowledge.

## Source Support

- [[sources/self-evolving-hooks|Self-Evolving Hooks]]
- [[sources/claude-code-best-practices|Claude Code Best Practices]]
- [[sources/claude-folder-structure|How to Structure .claude Folder]]
- [[sources/rag-llm-wiki-gbrain|RAG, LLM Wiki, or GBrain]]
- [[sources/ai-remote-development|Enhance Productivity with AI + Remote Dev]]
- [[sources/ai-brain-never-forgets|How To Build An AI Brain That Never Forgets]]
- [[sources/anatomy-agent-harness|Anatomy of an AI Agent Harness]]
- [[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]]
- [[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]]
- [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]

