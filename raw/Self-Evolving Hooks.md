---
title: "Self-Evolving Hooks"
source: "https://www.buildthisnow.com/blog/real-examples/self-evolving-hooks?mcp_token=eyJwaWQiOjMxMjI4ODAsInNpZCI6NzMwMjY3Mzk1LCJheCI6IjliMGI4MTM2ZWYwM2RmMWY4NWY3YWVkYzdlMDZlYTc1IiwidHMiOjE3NzU2NzU4MTksImV4cCI6MTc3ODA5NTAxOX0.uawZvPRFAh4agCdWJrbQ5oSjPO-_DrvGopL6QLz7Rfw"
author:
  - "[[Build This Now]]"
published: 2026-04-01
created: 2026-04-28
description: "Three hooks turn every 'no, not like that' correction into a skill or rule Claude reads on the next session. Self-improving agents, no prompt tuning needed."
tags:
  - "clippings"
---
Three hooks turn every 'no, not like that' correction into a skill or rule Claude reads on the next session. Self-improving agents, no prompt tuning needed.

Published Apr 1, 20268 min read [Real Builds hub](https://www.buildthisnow.com/blog/library#topic-real-examples)

Claude starts fresh every session. It doesn't remember you hate em-dashes. It doesn't remember you told it to render before reporting done. It doesn't remember anything, unless you write it somewhere it can read.

Hooks fix this. Three files, and every correction you give Claude gets captured, analyzed, and written back into your project automatically. The next session, the mistake is gone before the agent even starts.

---

## What is a hook?

A hook is a script Claude Code runs automatically at specific moments. When a session starts. When a subagent is about to run. When the session ends.

You write a `.js` file, register it in `settings.json`, and Claude calls it at the right time. The hook gets context as JSON on stdin, does whatever you want, and exits. No polling. No background processes to manage.

---

## The insight that makes this work

Every AI learning system has the same problem: where does the signal come from?

The cleanest signal is already sitting in your session. When you say "no, remove the em-dash", that is a correction. When you say "yes exactly", that is approval. You are the ground truth. No AI evaluator needed. No circular loop.

The session transcript (the file Claude writes as you work) contains all of this. Every message you sent. Every agent Claude spawned, with the full prompt it was given and the full output it returned. Every skill file that was read.

Here is what three sessions look like after they are captured:

```
session X:
  human_messages: ["write a LinkedIn post", "no em-dashes please", "yes that's better"]
  agents_run: [{ type: "linkedin-strategist", output: "post with em-dash — great hook" }]
  skills_read: ["linkedin-strategist"]

session Y:
  human_messages: ["write another post", "still has em-dashes wtf", "good"]
  agents_run: [{ type: "linkedin-strategist", output: "The future is here — changing everything" }]
  skills_read: ["linkedin-strategist"]

session Z:
  human_messages: ["write a carousel", "looks good"]
  agents_run: [{ type: "carousel-designer" }]
  skills_read: []
```

The pattern is obvious. The dream worker reads this and reasons: "em-dash complaint in session X and Y. Both ran linkedin-strategist. Session Z had no complaint and did not run linkedin-strategist. Rule goes to linkedin-strategist."

You do not code this logic. An LLM does it. That is the whole trick.

---

## Final file tree

```
.claude/
  hooks/
    subagent-start.js    <- agents wake up with lessons already loaded
    on-stop.js           <- captures the session raw, no pre-classification
    dream/
      dream.js           <- finds patterns, writes rules
  learning/
    sessions/
      2026-04-08.jsonl   <- one observation per session
    global.md            <- lessons that apply to everything
    agents/
      linkedin-strategist.md  <- lessons for one specific agent
  settings.json
```

---

## Hook 1 — Load lessons before the agent starts

Before any agent runs, this script fires. It checks for saved lessons for that agent type. If there are any, it prints them in a `<mnemosyne>` block. Claude Code automatically prepends anything printed here to the agent's context.

The agent wakes up already knowing what went wrong last time.

```
// .claude/hooks/subagent-start.js
'use strict';
const fs   = require('fs');
const path = require('path');

const root    = path.resolve(__dirname, '..', '..', '..');
const coreDir = path.join(root, '.claude', 'core');

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  try {
    const event     = JSON.parse(raw);
    const agentType = (event.agent_type || '').replace(/^[^:]+:/, '').trim().toLowerCase();
    const parts     = [];

    // Global lessons — apply to every agent
    const global = readFile(path.join(coreDir, 'learning', 'global.md'));
    if (global) parts.push(\`### Global Learnings\n\n${global}\`);

    // Agent-specific lessons
    if (agentType) {
      const learned = readFile(path.join(coreDir, 'learning', 'agents', \`${agentType}.md\`));
      if (learned) parts.push(\`### Learnings for ${agentType}\n\n${learned}\`);
    }

    if (parts.length === 0) { process.exit(0); return; }

    const attr = agentType ? \` agent="${agentType}"\` : '';
    process.stdout.write(\`<mnemosyne${attr}>\n\n${parts.join('\n\n')}\n\n</mnemosyne>\n\`);
  } catch {}
  process.exit(0);
});

function readFile(p) {
  try { return fs.readFileSync(p, 'utf8').trim(); } catch { return ''; }
}
```

---

## Hook 2 — Capture the session when it ends

When your Claude session closes, this script reads the full conversation and pulls out the raw signal.

No regex. No pre-classification. It captures three things: every human message verbatim, every agent that ran with its prompt and output, every skill file that was read. That is it. The dream worker does the interpretation later.

```
// .claude/hooks/on-stop.js
'use strict';
const fs     = require('fs');
const path   = require('path');
const crypto = require('crypto');
const { spawn } = require('child_process');

const root    = path.resolve(__dirname, '..', '..', '..');
const coreDir = path.join(root, '.claude', 'core');

const COOLDOWN_MS  = 4 * 3_600_000;
const MIN_SESSIONS = 3;

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  try {
    const event = JSON.parse(raw);
    const { session_id, transcript_path } = event;
    if (!transcript_path || !fs.existsSync(transcript_path)) { process.exit(0); return; }
    const obs = parseSession(session_id || 'unknown', transcript_path);
    writeObservation(obs);
    if (shouldDream()) spawnDream();
  } catch {}
  process.exit(0);
});

function parseSession(sessionId, transcriptPath) {
  const lines = fs.readFileSync(transcriptPath, 'utf8').split('\n').filter(Boolean);
  const humanMessages = [];
  const agentsRun     = [];
  const skillsRead    = new Set();
  let pendingAgent    = null;

  for (const line of lines) {
    let e; try { e = JSON.parse(line); } catch { continue; }
    const role    = e.message?.role;
    const content = e.message?.content;
    if (!Array.isArray(content)) continue;

    for (const block of content) {
      // Every human message, verbatim
      if (role === 'user' && block.type === 'text') {
        const text = (block.text || '').trim();
        if (text.length > 2) humanMessages.push(text.slice(0, 300));
      }

      // Agent output arrives as a tool_result
      if (role === 'user' && block.type === 'tool_result' && pendingAgent) {
        const parts = Array.isArray(block.content)
          ? block.content
          : [{ type: 'text', text: String(block.content || '') }];
        const meta = parts.find(p => p.type === 'text' && p.text?.includes('agentId:'));
        if (meta) {
          const output = parts
            .filter(p => p !== meta && p.type === 'text' && p.text)
            .map(p => p.text).join('\n').trim();
          agentsRun.push({
            type:           pendingAgent.type,
            prompt_preview: pendingAgent.prompt,
            output_preview: output.slice(0, 400).replace(/\s+/g, ' '),
          });
          pendingAgent = null;
        }
      }

      // Track what was spawned and what was read
      if (role === 'assistant' && block.type === 'tool_use') {
        if (block.name === 'Agent') {
          const t = (block.input?.subagent_type || 'unknown')
            .replace(/^[^:]+:/, '').toLowerCase();
          pendingAgent = { type: t, prompt: (block.input?.prompt || '').slice(0, 150) };
        }
        if (block.name === 'Read') {
          const m = (block.input?.file_path || '').match(/skills\/([^/]+)\/SKILL\.md$/i);
          if (m) skillsRead.add(m[1]);
        }
      }
    }
  }

  return {
    id:              \`sess-${Date.now()}-${crypto.randomBytes(2).toString('hex')}\`,
    ts:              new Date().toISOString(),
    session_id:      sessionId,
    transcript_path: transcriptPath,
    human_messages:  humanMessages,
    agents_run:      agentsRun,
    skills_read:     [...skillsRead],
  };
}
```

Here is what one observation looks like on disk:

```
{
  "ts": "2026-04-08T14:32:11.000Z",
  "session_id": "a7b3c2d",
  "human_messages": [
    "Write a LinkedIn post about AI agents",
    "no don't use em-dashes, remove them",
    "yes exactly, that is what I wanted"
  ],
  "agents_run": [{
    "type": "linkedin-strategist",
    "prompt_preview": "Write a LinkedIn post about AI agents building tools",
    "output_preview": "Here is the post. It uses an em-dash to make it punchy..."
  }],
  "skills_read": ["linkedin-strategist"]
}
```

Small. Readable. One line per session. No interpretation baked in.

---

## Hook 3 — The dream worker

This runs in the background when two conditions are met: at least 4 hours since the last run, and at least 3 new sessions captured.

It spawns a one-shot `claude -p` process using Haiku. The worker has Write and Edit access to your project. It reads the session observations, classifies the human messages itself, finds patterns across sessions, and writes rules directly to the right files.

```
// .claude/hooks/dream/dream.js (the prompt sent to Haiku)
\`You analyze recent sessions and write one-line rules to prevent repeated mistakes.

★ = new since last dream. These are fresh signal.

## Sessions

★ 2026-04-08T14:32 | agents:[linkedin-strategist] | skills:[linkedin-strategist]
  Human messages:
    1. "Write a LinkedIn post about AI agents"
    2. "no don't use em-dashes, remove them"
    3. "yes exactly, that is what I wanted"
  linkedin-strategist output: "Here is the post. It uses an em-dash to make it punchy..."

★ 2026-04-07T10:15 | agents:[linkedin-strategist] | skills:[linkedin-strategist]
  Human messages:
    1. "write another post"
    2. "still has em-dashes wtf"
    3. "good"
  linkedin-strategist output: "The future is here — changing everything about how..."

## Where to write

- .claude/learning/agents/{type}.md   for one specific agent
- .claude/learning/global.md          for every agent
- .claude/skills/{name}/SKILL.md      fix the skill that caused the mistake

## Rules

- 1 session = noise. Same correction in 2+ sessions = write it.
- One-line rules only. Specific, not vague.
- Read the target file first. Do not duplicate existing rules.
- Max 5 new rules per run.

Good: "Never use em-dashes. Use commas or short sentences instead."
Bad: "Be more careful with formatting."\`
```

The worker reads your last 20 sessions, spots what you kept correcting, and writes the lesson. Three sessions with the same correction is a rule worth writing. One correction is noise.

---

## Register the hooks

```
{
  "hooks": {
    "SubagentStart": [{
      "type": "command",
      "command": "node .claude/hooks/subagent-start.js"
    }],
    "Stop": [{
      "type": "command",
      "command": "node .claude/hooks/on-stop.js",
      "async": true
    }]
  }
}
```

Two hooks. That is it.

---

## What you get after a week

```
.claude/
  learning/
    global.md
      Never use em-dashes. Use commas or short sentences instead.
      <!-- dream 2026-04-08 -->

    agents/
      linkedin-strategist.md
        Always write in first person when the topic is personal experience.
        <!-- dream 2026-04-09 -->

  skills/
    linkedin-strategist/
      SKILL.md   <- 2 new rules added from repeated corrections
```

Every agent that runs next week already knows what broke last week. You changed nothing.

---

*Posted by @speedy\_devv*

Stop configuring. Start building.

SaaS builder templates with AI orchestration.