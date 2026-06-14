---
title: Multi-Agent Orchestration
type: concept
created: 2026-06-14
tags:
  - concept
  - agents
  - orchestration
  - multi-agent
  - langgraph
  - system-design
---

# Multi-Agent Orchestration

A single agent can handle straightforward tasks. Complex, multi-step workflows need multiple specialized agents coordinated by an orchestrator. The question is not whether to use one agent or many — it is how to divide the work and manage the communication between agents.

## Agent Topologies

### Router Graph (Supervisor + Specialists)

A central router or supervisor agent receives the task and dispatches sub-tasks to specialized agents:

```
[User Request] → [Router Agent]
                     ↓
    ┌──────────┬────┼────┬──────────┐
    ↓          ↓    ↓    ↓          ↓
[Search]  [Analysis] [Code] [Research] [Planning]
```

Each specialist agent has its own tools, context, and model configuration. The router decides which specialist (or sequence of specialists) to invoke.

**Example**: Kensho's Grounding system uses a RouterGraph to route financial queries to specialized data agents. Each agent is responsible for querying a specific structured dataset. The router handles query decomposition and result assembly.

**When to use**: the task covers multiple domains or data sources, each requiring different tools or context.

**Strengths**: clear separation of concerns, each agent can use a model optimized for its task, easy to add new specialists.
**Weaknesses**: the router is a single point of failure and a latency bottleneck. Router errors cascade to downstream agents.

### Planning-Execution Separation

Separate the reasoning (planning) from the action (execution):

```
[User Request] → [Planner Agent]
                     ↓
              [Execution Plan: DAG of steps]
                     ↓
              [Executor (deterministic)]
              ┌────┼────┐
              ↓    ↓    ↓
            [Tool 1] [Tool 2] [Tool 3]
                     ↓
              [Output Assembler]
```

The planner decomposes the task into a directed graph of parallelizable steps. The executor runs each step deterministically, handling failures, retries, and timeouts without requiring LLM intervention.

**Example**: Remote's data migration system uses this pattern. The LLM plans the data transformation (which columns to map, what transformations to apply), then deterministic Python code executes the plan in a sandboxed WebAssembly environment.

**When to use**: tasks with well-defined steps that can be pre-planned. Tasks where execution must be deterministic and auditable.

**Strengths**: execution is fast, deterministic, and debuggable. The LLM is only needed for the reasoning step.
**Weaknesses**: not suitable for tasks where the plan changes dynamically based on intermediate results.

### Peer-to-Peer (Debate / Ensemble)

Multiple agents work on the same problem and converge on a solution through discussion:

```
[Agent A] ←→ [Agent B]
    ↕            ↕
[Agent C] ←→ [Agent D]

Each agent has a different perspective, model, or prompt.
They exchange findings and converge on a consensus.
```

**When to use**: verification tasks (code review, fact checking), creative tasks where diversity of output is valuable, risk assessment.

**Strengths**: robust to individual agent failures, diversity of reasoning catches more errors.
**Weaknesses**: expensive (multiple LLM calls per step), convergence is not guaranteed, slow.

### Hierarchical

Agents themselves spawn sub-agents, creating a tree:

```
[Orchestrator Agent]
    ↓
[Lead Researcher] → [Web Searcher] [Database Searcher]
    ↓
[Lead Writer] → [Section Writer A] [Section Writer B]
```

**When to use**: very complex tasks with clear hierarchical decomposition (e.g., writing a research report with multiple sections).

**Strengths**: natural decomposition, reusable sub-agents.
**Weaknesses**: hard to debug, deep trees create latency, parent agents may lose context on child work.

## Communication Between Agents

### Structured Protocols

Agents should communicate using structured data, not free-form text:

```json
{
  "from": "router",
  "to": "search-agent",
  "task_id": "task-abc",
  "type": "query",
  "payload": {
    "query": "revenue Q3 2025",
    "data_sources": ["financials"],
    "filters": {"date_range": "2025-Q3"},
    "max_results": 5
  },
  "metadata": {
    "trace_id": "d94f3a17...",
    "deadline_ms": 30000
  }
}
```

### Shared Context Surface

Agents can share context through a persistent filesystem or database rather than passing large payloads:

- The router writes the task definition to a shared file.
- The specialist agent reads the task, writes results to a shared directory.
- The router reads the results and determines next steps.

This avoids context window pressure from passing large inter-agent messages.

### Trace Context Propagation

Every inter-agent call must propagate the trace ID so the entire workflow is observable:

```
[Router: trace_id=X, span_id=A]
    ↓
[Search Agent: trace_id=X, span_id=B, parent=A]
    ↓
[Analysis Agent: trace_id=X, span_id=C, parent=B]
```

Without trace propagation, debugging multi-agent failures is impossible.

## Agent Harness Architecture

The agent harness is the wrapper that turns a model into an autonomous work engine:

| Component | Purpose | Example |
|-----------|---------|---------|
| Filesystem | Durable workspace, context overflow, Git versioning | `/workspace` per task |
| Execution sandbox | Safe code execution | WebAssembly, Docker |
| Tool registry | Allowed tools with schemas | LangChain tools, MCP |
| Memory manager | Context compaction, sliding window | Summary of oldest turns |
| Self-verification | Test runners, assertion checks | pytest, CI scripts |
| Ralph Loop | Resume agent after context window full | Save state, restart clean |

### Harness Optimization

The harness itself significantly affects agent performance. Swapping from a general-purpose harness to a task-tailored harness can move an agent from the 30th to the 5th percentile on benchmarks.

Key optimization axes:
- **Tool disclosure**: show the agent only the tools relevant to the current step.
- **Context compaction frequency**: summarize every N turns to avoid context degradation.
- **Sandbox isolation granularity**: per-task containers vs per-agent persistent environments.
- **Checkpoint strategy**: save state after every step vs on-demand.

## Evaluation at the Agent Level

Multi-agent systems need evaluation at each level:

| Level | What to Measure | Method |
|-------|----------------|--------|
| Router accuracy | Did the router send the task to the right specialist? | Ground-truth labeled dataset |
| Specialist quality | Did the specialist produce correct output? | Per-agent test suite |
| End-to-end | Did the overall workflow produce the right result? | Full workflow eval |
| Latency budget | Did the workflow complete within the deadline? | Per-step timing |
| Cost per task | What is the total LLM and tool cost per completed task? | Token accounting |

## When to Add More Agents

Adding agents increases system complexity. A single agent should be the default. Add agents when:

- One agent's context window cannot hold all the tools and context needed.
- Different steps need different models (e.g., cheap model for classification, expensive model for generation).
- Steps must run in parallel for latency.
- The task spans domains with distinct knowledge bases.
- A dedicated agent for verification/review improves quality.

## Links

- Parent concept: [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Related: [[concepts/agent-memory-architecture|Agent Memory Architecture]]
- Related: [[concepts/production-ai-operations|Production AI Operations]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/kensho-multi-agent|Kensho Multi-Agent Architecture]]
- Source: [[sources/madrigal-multi-agent|Madrigal Agentic Research Platform]]
- Source: [[sources/remote-data-migration-agent|Remote Data Migration Agent]]
- Source: [[sources/anatomy-agent-harness|Anatomy of an Agent Harness]]
- Source: [[sources/dropbox-beyond-code-generation|Dropbox Nova Agent Platform]]
