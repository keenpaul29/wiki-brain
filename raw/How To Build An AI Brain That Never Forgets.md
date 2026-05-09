---
title: "How To Build An AI Brain That Never Forgets"
source: "https://substack.com/inbox/post/196522673"
author:
  - "[[Sara Nóbrega]]"
published: 2026-05-07
created: 2026-05-08
description: "The folder structure, CLAUDE.md schema, and three-cadence automation I use"
tags:
  - "clippings"
---
![](https://substackcdn.com/image/fetch/$s_!x4Qa!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fad85eccb-b5b7-456e-bf8c-fb6a33a9c443_1448x1086.png)

**TLDR:**

> [Part 1](https://saranfn.substack.com/p/give-your-ai-unlimited-updated-context) explained the **problem**: every AI conversation starts **blank**, and built-in memory doesn’t cut it. This article shows you how to set it up. The vault runs on two **folders**, a **schema** file, and three **control** files that most people skip and then wonder why their system falls apart after two weeks. The automation separates into three cadences: daily ingestion, weekly compilation, and monthly linting. Each has a different risk tolerance. **Mix** them up and you **corrupt** the vault. Get them right and your AI has **current**, **structured** context every morning without you touching anything. This article walks through the full setup.

## The goal

If you read [Part 1](https://saranfn.substack.com/p/give-your-ai-unlimited-updated-context), you understand the concept. A local **folder** of plain Markdown files.

> **Any AI** can read it. Your context travels with you. No lock-in, no re-explaining, no starting from zero.

![](https://substackcdn.com/image/fetch/$s_!UeAv!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F217fcfbd-257e-462c-8aa6-0633cd611450_1254x1254.png)

What Part 1 didn’t cover is the part where most implementations quietly die.

Not because the idea is wrong. Because the **execution** **skips** three things that hold the whole system together.

This article covers those three things, the folder structure behind them, and the exact automation layer that keeps the vault current without you doing anything.

**Before we start:**

1. **Save** this and spend 30 minutes this week actually setting up your first vault. The setup is front-loaded. After that, you don’t touch it.
2. **Send** it to any engineer, founder, or operator who’s complained about re-explaining themselves to AI.

---

## The Architecture: Two Folders And A Schema File

The whole thing fits in one directory. Here’s the structure:

```markup
vault/
├── CLAUDE.md          ← schema file, entry point for any AI
├── Raw/               ← immutable source documents
│   ├── Meeting Notes/
│   ├── Documents/
│   └── _pending.md    ← compilation queue
└── Wiki/              ← LLM-generated, structured, indexed
    ├── Projects/
    ├── People/
    ├── Decisions/
    ├── _hot.md        ← active cache
    ├── _log.md        ← audit trail
    └── _index.md      ← master index
```

**Two folders, one rule.**

- **Raw** is your source of truth: meeting transcripts, exported Slack threads, documents pulled from wherever your work actually lives. The AI reads Raw, never edits it. Append-only, always.
- **Wiki** is what the AI builds and maintains: one file per project, person, decision, or domain area. Structured, cross-referenced. This is what the AI reads first when you ask a question.
	![](https://substackcdn.com/image/fetch/$s_!eZkF!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd30a3ef0-44ad-4b06-86b7-aa5fbfb91d53_1254x1254.png)

Think of it like a **data pipeline** if you’ve worked with one. **Raw** is your landing zone. **Wiki** is your **curated** **layer**. If Wiki drifts or gets corrupted, you rebuild from Raw. You never lose the source.

The **schema** file sits at the root.

**CLAUDE.md** tells any AI how the vault is **organised**, what to **read** first, and what the operating rules are.

If you’re using a different AI, AGENTS.md works the same way. Name it anything, as long as you point the AI to it at the start of every session.

## The Three Control Files: The Part Most People Skip

A folder of **Markdown** files is not a system. These three files make it one. This is the section most implementations skip, and it’s exactly why most implementations quietly die.

![](https://substackcdn.com/image/fetch/$s_!P5Bc!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F9aa2298d-12e5-49a9-98a2-52e3b1efa98b_1254x1254.png)

### \_hot.md: The Cache

Every **morning**, the **daily** automation rewrites this file. Most active threads, any key numbers or deadlines that surfaced, one line on anything urgent. It stays under **500 tokens.**

When you open a **conversation** and want a fast briefing, the AI reads **\_hot.md first**.

No need to load the full Wiki. It’s the difference between your AI knowing what’s happening today versus knowing what happened in general.

### \_pending.md: The Queue

Every time a **new file** lands in **Raw**, its filename and date get appended here. When the **weekly** **compilation** runs, it reads this file, processes each entry, compiles it into Wiki, and marks it done with a timestamp like \[COMPILED — 2026-05-01\].

**Without** this file, the daily ingest and the weekly compilation can’t coordinate. You get **orphaned raw files** and a Wiki that’s weeks behind. The pending queue is what keeps the pipeline connected.

### \_log.md: The Audit Trail

Every **automated** **run** appends a **timestamped** entry: what ran, what files were processed, what Wiki pages were created or updated. If the system drifts, this is how you find where.

**A useful pattern:** start each **log** entry with a consistent prefix like ## \[2026-05-01\] daily-ingest so the whole log is grep-parseable. When something goes wrong three weeks in, you’ll thank yourself for this.

A vault without these three files accumulates dust. With them, you have a working pipeline.

## The Schema File: Teaching Any AI How To Read Your Vault

**CLAUDE.md** is the entry point. Every session starts here. Here’s what goes in it:

**• The folder map:** what’s in Raw, what’s in Wiki, what each subdirectory is for

**• Read order:** \_hot.md always first, then the relevant domain index

**• Hard rules:** ‘never edit files in Raw/’, ‘never invent facts not present in source files’, ‘always append to \_log.md after every run’

**• Domain structure:** which indexes exist, how they’re named

The schema file is also where you **encode** your prompting defaults. Here’s the pattern I use directly in the schema:

```markup
I want to [TASK] so that [WHAT SUCCESS LOOKS LIKE].

First, read the uploaded files completely before responding.

DO NOT start executing yet. Ask me clarifying questions so we

can refine the approach together.

Only begin work once we’ve aligned.
```

When this is in your **schema**, every AI that reads your **vault** already knows to ask before executing. You stop getting half-baked output from a model that assumed it understood the task.

A few **prompting** **principles** worth encoding explicitly in the schema:

> • **Context** beats prompts. Feed the AI files, not instructions.
> 
> • **Examples** beat prescriptions. Show what you want, don’t describe it.
> 
> • **Constraints** beat rules. Say what the output is NOT, let the AI choose how.
> 
> • **Goals** beat instructions. Say what to achieve, not how.
> 
> • **State** the task and the success criteria. Two sentences.

![](https://substackcdn.com/image/fetch/$s_!vBXV!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F9c6ae79e-f1e2-4438-a052-707c3ebfdd33_992x526.png)

You might want to save this image for later. Or share with someone. Just saying!

## The Automation Layer: Three Cadences, Not One

Two **failure** modes I’ve seen:

1. You update the vault manually and it’s fine for a week, then life happens and it’s been three weeks since anything got filed.
2. Or you **build** one big automated job that ingests, synthesises, and audits all in one pass, and now your daily ingest is editing Wiki files it should never touch.

The fix is to separate the jobs. Three **cadences**, each with a different risk tolerance.

### Daily (Weekday Mornings): Ingestion Only

**Pull** from your sources. **Drop** new files into Raw/. **Queue** them in \_pending.md. Rewrite \_hot.md based on what surfaced. No Wiki edits. The daily job is mechanical, fast, and safe enough to run unattended every day.

![](https://substackcdn.com/image/fetch/$s_!WO7R!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F32978f83-68c7-4a62-8d04-12090bb3aeea_1254x1254.png)

Here’s what the actual prompt looks like:

```markup
Every weekday morning, do the following:

1. Check [your project management tool] for items updated or

created in the last 24 hours.

2. Check [your meeting notes source] for new transcripts.

For each one found, save it as a markdown file in

Raw/Meeting Notes/ using the format:

YYYY-MM-DD - [meeting title].md

Add a line to Raw/_pending.md with the filename and date.

3. Check [your team communication tool] for messages in key

channels. Extract decisions, action items, and anything

that affects an active project.

4. Check [your email] for flagged or important messages.

Summarize what needs attention.

After completing the above, rewrite Wiki/_hot.md with:

- The most active threads or open decisions from today’s scan

- Any key numbers or deadlines that surfaced

- One line on anything urgent

Keep _hot.md under 500 tokens.
```

**Replace** the bracketed placeholders with your actual tools.

This works whether you’re pulling from Linear and Slack, Notion and email, or anything else. The structure is the logic. The tools are interchangeable.

### Weekly (Monday Mornings): Compilation

Read **\_pending.md.** For each unprocessed file, read it in full, create a structured Wiki page in the right domain folder, update the relevant index, add backlinks to related pages, mark the entry compiled.

![](https://substackcdn.com/image/fetch/$s_!Gyob!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F421cc847-5c1c-46a9-af38-faabec7cc09b_1254x1254.png)

The weekly job does interpretation.

It synthesises raw content into structured knowledge. It’s slower, more expensive, and worth reviewing occasionally to check the AI is filing things correctly.

### Monthly (First Of The Month): Linting

**Health** check only.

Scan the entire Wiki for stale pages, missing backlinks, contradictions between pages, coverage gaps, and orphaned pages not referenced in any index. Write a report file. Post a plain-English summary. Don’t auto-fix anything.

![](https://substackcdn.com/image/fetch/$s_!Zwri!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F08142029-e59d-4554-a21a-8fcce1eafda1_1254x1254.png)

The **monthly** job never touches Wiki content directly. That boundary is what makes it safe to run without supervision.

Each **cadence** has a different risk tolerance: daily is mechanical, weekly does interpretation, monthly does diagnosis. Mixing them in one job is how vaults get corrupted.

On **tooling**: **any system** with scheduling works here. A cron job with an MCP-enabled CLI, n8n, or an AI desktop tool that supports scheduled tasks. The prompts above are the logic. **The runner is interchangeable!**

## What This Unlocks In Practice

Once the vault is **running**, the conversations change character. You stop using AI for isolated questions and start using it for actual work.

A few real examples of what this looks like day-to-day:

![](https://substackcdn.com/image/fetch/$s_!Za8u!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb262d367-1f0f-4602-9ee7-76283afb6935_1254x1254.png)

**Status check: Scheduled** task fires at 7 AM -> Claude scans your tools for last 24 hours -> extracts decisions, action items, deal updates -> writes to \_hot.md and updates project files -> you open your laptop and ask ‘what’s the status of the marketing project?’ -> Claude reads the relevant Wiki file and gives you a current answer without you touching anything.

**Weekly prep:** Monday morning compilation runs -> Claude reads \_pending.md -> processes 12 raw files from the week -> creates 3 new Wiki pages, updates 5 existing ones -> you start your week with a structured, indexed knowledge base that reflects everything that happened.

**Switching tools:** You want to try a different AI -> point it at the same vault folder -> it reads CLAUDE.md, understands the structure, reads \_hot.md for current state -> your context travels with you, zero re-setup.

**New session, zero re-explaining:** You open a fresh conversation -> Claude reads CLAUDE.md, loads \_hot.md, checks the relevant project file -> asks a clarifying question based on actual current context, not a generic opener -> you’re working in 30 seconds.

> **Portability** is the other thing worth naming explicitly. Your context lives in a folder on your machine, not inside any AI’s memory system. Point a different AI at the same folder and it reads the same files. Switch tools whenever you want. The vault travels.

## Why This Makes You A Power User Of AI

Most people’s AI usage is **isolated** and **reactive**.

Each **conversation** is a one-off. **Context** disappears. Decisions get re-explained. The tool is fast but the human is doing all the setup work every single time.

**The vault flips that.** You do the setup work once, systematically, and the AI carries it forward. That’s not just a productivity gain.

It’s a different way of working with AI.

![](https://substackcdn.com/image/fetch/$s_!OXhI!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fac84f938-9685-4e47-a342-edfe1daff574_1448x1086.png)

The people **getting** **dramatically** more out of AI right now are not the ones with better prompts.

They’re the ones who solved the **context** problem. They’re not re-explaining. They’re not losing decisions to session resets. They’re **compounding**. Every week the vault gets richer, the AI gets more useful, and the gap between them and everyone else gets wider.

**Andrej Karpathy** described this as a persistent, compounding artifact back when he sketched out the **LLM** **Wiki** **pattern**. That framing is exactly right. The wiki doesn’t just store knowledge. It **builds** it. The synthesis is already done before you ask your next question.

And because the whole thing is **plain** **Markdown files** on your local machine, you’re not locked into anything. Claude reads it today. Whatever comes next reads it tomorrow. Your context is yours.

---

A few failure modes worth knowing before you build:

> • **\_pending.md** backs up if daily ingest is too broad and weekly compilation can’t drain it fast enough. Tighten what you pull in daily.
> 
> **• Wiki** drifts if nobody reads \_log.md. The monthly linter catches this, but only if you actually read the report.
> 
> • The whole system breaks if automation ever touches **Raw**. One job that writes to Raw ‘just this once’ and you’ve lost the source-of-truth guarantee. That boundary doesn’t bend.

## What’s Next

The vault I’ve described here is the architecture.

The actual files, the CLAUDE.md prompt, and the full daily automation prompt are things you can build in an afternoon once you know the structure.

Start with **Raw/** and **Wiki/** and one control file.

Get **\_hot.md** updating daily before you worry about the weekly compilation. Build incrementally.

The **pattern** works with any AI that reads files and any scheduler that can run a prompt on a clock. You set it up once. After that, your AI stops starting from zero.

Thanks for reading!

---

🎯 Need help navigating your own AI journey? Right now I’m offering:

- AI consulting calls - If you’re working on projects or exploring how to bring AI into your business, I’d love to jump on a call and help you figure things out.
- Mentorship sessions - Thinking about a career move or growing your skills in AI? I can share advice and help you map out your next steps.
- Premium membership perk - If you’re a premium subscriber to this newsletter, you already have two 1:1 sessions with me included.

For more info DM me or reply to this email!.

---

*Learn AI is a reader-supported publication. To receive new posts and support my work, consider becoming a free or paid subscriber.*