---
title: Agent Memory Architecture
type: concept
created: 2026-06-14
tags:
  - concept
  - agents
  - memory
  - rag
  - knowledge-management
  - system-design
---

# Agent Memory Architecture

Context windows are not durable memory. They are temporary working space. For an agent to act autonomously across sessions, it needs explicit memory architecture. The three fundamental paradigms are retrieval (RAG), compilation (LLM Wiki), and action-embedded (fat skills). Each serves a different job.

## The Three Paradigms

### Retrieval (RAG)

The agent queries a vector store or search index at inference time to find relevant documents.

**When to use:** large or frequently changing corpora, question-answering on existing documents, systems where the source material is the authoritative truth.

**Strengths:**
- Scales to millions of documents.
- Works with unmodified source material.
- Naturally handles updates (re-index).

**Weaknesses:**
- Fragmented chunks lose cross-document synthesis.
- Each query re-derives the same synthesis (no compounding).
- Pipeline latency (embedding + retrieval + reranking + generation).
- No persistent knowledge accumulation — what the agent learns in one session is lost.

### Compilation (LLM Wiki)

The agent maintains a persistent, interlinked knowledge base of markdown pages. Sources are read, summarized, and linked into a growing wiki.

**When to use:** hundreds to low thousands of sources, recurring queries on the same topics, knowledge that compounds across sessions.

**Strengths:**
- Synthesis persists. A concept page written today answers questions tomorrow.
- Cross-linking creates emergent insight — connections that no single source made.
- Human-readable and auditable.

**Weaknesses:**
- Does not scale to millions of documents without a retrieval layer.
- Requires maintenance: stale pages, broken links, orphan detection.
- Write overhead — each new source requires synthesis effort.

### Action-Embedded (Fat Skills / GBrain)

The agent carries workflow documents that declare triggers, tools, allowed writes, quality bars, and execution protocol. Memory is embedded in the skill's behavior.

**When to use:** autonomous agents running recurring workflows, systems where the agent must act (not just answer), cron-driven monitoring and reporting.

**Strengths:**
- Memory is baked into action — the agent knows what to do and how.
- Always-on skills and cron jobs turn memory into autonomous monitoring.
- Deterministic execution for writes and API calls.

**Weaknesses:**
- Skills are harder to author than wiki pages.
- Not suitable for ad-hoc querying.
- Less human-readable than a wiki.

### Hybrid Architecture

Most production systems combine all three:

```
[User Query]
    ↓
[Retrieval (RAG)] → finds relevant sources from large corpus (scale)
    │
    ├─ Has wiki synthesis page? → use compiled answer (speed, quality)
    └─ No wiki page → query online, write wiki page for next time (compounding)
    ↓
[Skill execution] → act on the answer (write file, send email, update DB)
```

The decision flowchart:
```
Does the corpus have >10K documents?
  ├─ Yes → RAG is primary, wiki is periodic summary layer
  └─ No → Wiki is primary, RAG for live data
        → Does the agent need to act autonomously?
          ├─ Yes → Add fat skills for recurring actions
          └─ No → Wiki + RAG is sufficient
```

## Short-Term vs Long-Term Memory

### Session Context

The agent's current context window. Everything in the conversation is ephemeral:

- **Contents:** current task, recent tool outputs, user instructions.
- **Limitations:** context window fills up, oldest messages are lost.
- **Management:** summarization, context compaction, sliding window.

### Working Memory

Persistence across turns within a session, but not across sessions:

| Storage | Format | Lookup |
|---------|--------|--------|
| Vector store (in-memory) | Embeddings of key facts | Top-k semantic |
| Key-value store | Structured data (user_id, project state) | Exact match |
| Scratchpad | Free-form markdown note | Sequential read |

### Long-Term Memory

Persistence across sessions:

| Approach | Durability | Example |
|----------|-----------|---------|
| Wiki pages | Months-years | Concept pages, source summaries |
| SQL/NoSQL DB | Indefinite | User preferences, project state |
| Vector store | Until deletion | Archived conversations, past decisions |
| Knowledge graph | Indefinite | Entity-relation facts |

### Ephemeral State

Data that is relevant only for the current turn:

- Tool output from the most recent call.
- Intermediate computation results.
- The user's most recent message.

Ephemeral state should not persist. It is the source of stale context bugs when it leaks into permanent memory.

## Memory Quality Metrics

| Metric | What It Measures | Target |
|--------|-----------------|--------|
| Retrieval precision | % of retrieved items that are relevant | > 80% |
| Retrieval recall | % of relevant items that are retrieved | > 90% for top-20 |
| Synthesis accuracy | Does the compiled page answer queries correctly? | Manual audit quarterly |
| Memory staleness | Age since last update per page | Median < 30 days |
| Cross-session reuse | How many queries use wiki pages vs retrieve fresh | > 50% after 3 months |
| Write amplification | New pages created per source ingested | < 2:1 |

## Common Failure Modes in Agent Memory

| Failure | Symptom | Cause | Fix |
|---------|---------|-------|-----|
| Context overflow | Agent loses track of task | Too much ephemeral state | Explicit summary step |
| Stale knowledge | Agent acts on outdated info | Long-term memory not refreshed | TTL-based re-read |
| Fragmented retrieval | Missing key context | Chunk boundaries split concepts | Semantic chunking |
| Write amplification | Wiki grows without bound | Every source gets its own page | Merge similar sources |
| Memory interference | Wrong facts recalled | Similar embeddings collide | Metadata filtering |
| Circular dependencies | Agent loops through same pages | Over-connected pages | Break cycles manually |
| Missing decay | All memories equally important | No recency weighting | Time-decayed reranking |

## Links

- Parent concept: [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Related: [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Related: [[concepts/production-ai-operations|Production AI Operations]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/rag-llm-wiki-gbrain|RAG, LLM Wiki, or GBrain]]
- Source: [[sources/production-ai-failure-modes|Production AI Failure Modes]]
- Source: [[sources/anatomy-agent-harness|Anatomy of an Agent Harness]]
- Source: [[sources/self-evolving-hooks|Self-Evolving Hooks]]
