---
title: How to Structure .claude/ Folder for Maximum Efficiency
source: https://substack.com/home/post/p-193360884
author:
  - "[[Youssef Hosni]]"
published: 2026-04-06
created: 2026-05-05
description: "How to Configure Claude Code for Real Projects: A Practical Guide to Instructions, Rules, Hooks, Skills, and Permissions"
tags:
  - clippings
---
Most Claude Code users know the**.claude/** folder exists, but far fewer think carefully about how it should be organized.

At first, that usually does not seem like a problem. A small project can get by with a basic **CLAUDE.md**, a few settings, and maybe one or two extra files. But as the project grows, that casual setup starts to show its limits. Instructions become harder to maintain, workflows get scattered across the wrong places, and the folder slowly turns into a mix of useful configuration and hard-to-explain clutter.

That is why structure matters.

A well-organized **.claude/** folder makes Claude easier to guide, easier to trust, and easier to scale across a real project. It helps separate broad instructions from detailed rules, reusable workflows from automated actions, and team-wide standards from personal preferences. Instead of treating **.claude/** like a dumping ground for random config, you start treating it like part of the project’s operating layer.

In this guide, we will look at how to structure the **.claude/** folder for maximum efficiency, what each part should contain, and how to keep the setup clean as your workflows become more advanced.

![](https://substackcdn.com/image/fetch/$s_!NeFZ!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3b75d91c-15d2-4ea4-a5a9-019f6e9c8b60_1536x1024.png)

#### Table of Contents:

1. Why the structure of.claude/ matters?
2. Start with the core: what should live at the top level
3. Keep instructions lean: CLAUDE.md vs rules/
4. Organize for action: hooks/, commands/, and reusable workflows
5. Structure specialized capabilities: skills/ and agents/
6. Separate team structure from personal structure
7. A practical blueprint for an efficient.claude/ folder
8. Common structure mistakes to avoid

---

Before we dive in, if you’re working with Claude Code and want to go beyond basic prompting, I’m hosting a hands-on workshop that might be useful.

**[Building Agent Skills for Claude Code](https://www.tickettailor.com/events/todatabeyond/2123002)** is a practical session where we focus on creating reusable *Skills* that help you build more consistent and repeatable workflows.

![](https://substackcdn.com/image/fetch/$s_!mnj8!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F0d55321b-c87a-495d-bcb2-1c68019f93f6_600x600.png)

---

## 1\. Why the structure of.claude/ matters?

Most people discover the**.claude/** folder by accident!

They see it appear in the project, recognize that it is related to Claude Code, and leave it alone unless they need to change one specific setting. Over time, that folder becomes a mix of instructions, scripts, rules, and experiments with no clear structure behind it.

That usually works at the beginning. It stops working once the project grows.

A poorly organized **.claude/** folder creates the same kind of friction as a poorly organized codebase. Instructions become harder to maintain. Important rules get buried. Automation scripts pile up without naming conventions. Team members are no longer sure where to add new guidance or which files are still active. Instead of making Claude easier to work with, the folder starts adding noise.

A well-structured **.claude/** folder does the opposite. It gives every part of your Claude Code setup a clear place. Your main instructions are easy to find. Reusable rules are separated from one-off preferences. Hooks and workflow files live in predictable locations. Skills and agents, when you actually need them, are organized as deliberate tools rather than scattered experiments.

That structure matters because Claude Code works best when your setup is easy to understand, not only for Claude, but also for you and your team. If the folder is clean, you can update it with confidence. If it is messy, even small improvements start to feel risky.

The goal is not to create the biggest possible **.claude/** folder. The goal is to create one that is easy to navigate, easy to maintain, and easy to scale as your workflow becomes more sophisticated. In practice, maximum efficiency comes from clarity: every file should have a purpose, every folder should solve a specific problem, and the overall structure should make sense at a glance.

That is the real value of organizing **.claude/** properly. You are not just storing configuration files. You are building the operating layer that shapes how Claude works inside your project.

> *Before diving into each component, it helps to look at the overall structure of an efficient* **.claude/** *folder. Think of this as the target layout we want to build toward as the project becomes more sophisticated.*

```markup
your-project/
├── CLAUDE.md                  # Main project instructions
├── CLAUDE.local.md            # Personal overrides (not committed)
└── .claude/
    ├── settings.json          # Control layer
    ├── rules/                 # Modular instructions
    ├── hooks/                 # Automation scripts
    ├── commands/              # Reusable prompt workflows
    ├── skills/                # Packaged capabilities
    └── agents/                # Specialized subagents
```

---

## 2\. Start with the core: what should live at the top level

Once you look past the subfolders, the most important part of the setup is still the top level. This is where Claude should find the files that define the project at the highest level, without digging through nested directories.

In most cases, that means two things matter first: your main instruction file and your main configuration file.

At the project root, **CLAUDE.md** should act as the entry point for how Claude understands the codebase. This is where you place the essential context Claude needs in nearly every session: the stack, the main architecture decisions, important conventions, and the commands that define the normal development workflow. If someone on your team wants to understand how Claude is supposed to behave in this repository, this should be the first file they check.

Inside **.claude/** folder, the **settings.json** fileshould sit at the top level for the same reason. It is not just another support file. It controls the operational side of Claude Code: permissions, hooks, and project-level behavior that needs to be easy to find and update. Burying it deeper in the folder structure makes routine maintenance harder for no real benefit.

That top level should stay intentionally light. The mistake many people make is treating the root of **.claude/** like a storage area for every script, workflow, and experimental note they create. That usually leads to clutter fast. Instead, the top level should contain only the files that define the project globally. Anything more specific should move into a dedicated folder.

***A simple way to think about it is this:***

- **CLAUDE.md:** explains how the project works
- **settings.json:** controls how Claude operates in the project
- The **subfolders** exist to keep everything else organized

That separation is useful because these files serve different purposes. **CLAUDE.md** is about guidance. **settings.json** is about control. One tells Claude what matters in the codebase. The other shapes what Claude is allowed to do and what automatic behaviors should happen around its work.

For example, in a FastAPI project, **CLAUDE.md** might explain that all API schemas live in **schemas/,** all service logic lives in **services/**, and every endpoint should validate inputs with Pydantic models.

Meanwhile, **.claude/settings.json** might allow Claude to run test commands, deny access to **.env** files, and trigger a formatting hook after file edits. Those two files work together, but they should not be mixed.

The top level should also make a clear distinction between shared files and personal overrides. A shared **CLAUDE.md** belongs in the root because the whole team benefits from it.

A personal override, such as **CLAUDE.local.md,** is different. It exists for local preferences and should stay out of the team’s shared structure. The same logic applies to **settings.local.json** inside **.claude/**.

In other words, the top level should answer the biggest questions first. What does Claude need to know about this project? What is Claude allowed to do here? Everything else can be organized underneath that foundation.

That is what makes the structure efficient. The most important files stay obvious, while the more specialized pieces are pushed into folders where they are easier to manage without crowding the core setup.

---

## 3\. Keep instructions lean: CLAUDE.md vs rules/

One of the easiest ways to make.**claude/** folder inefficient is to put too much into **CLAUDE.md**.

At the beginning, that file usually works well because the project is still small. You add a few commands, some coding conventions, and maybe a short note about architecture. But once the codebase grows, **CLAUDE.md** often turns into a catch-all document for everything the team wants Claude to remember. That is when it starts losing clarity.

A better structure is to treat **CLAUDE.md** as the **project’s operating guide**, not its entire knowledge base.

**CLAUDE.md** should hold the instructions Claude needs across most sessions:

- What the project is
- How it is organized
- Which commands matter most
- What conventions apply broadly
- What constraints should Claude not miss

The **rules/** folder is where more specific guidance belongs. That includes instructions tied to a certain part of the codebase, a certain workflow, or a certain engineering concern like testing or security.

A simple way to think about it is this:

- **CLAUDE.md** holds **global guidance**
- **rules/** holds **specialized guidance**

That split makes the structure easier to maintain and easier to scale.

### A practical example

Imagine you are working on a product with three main areas:

- a Next.js frontend
- a FastAPI backend
- a data pipeline for reporting jobs

If you try to describe everything in **CLAUDE.md**, the file becomes noisy very quickly. Frontend conventions sit next to backend validation rules and data pipeline notes. Claude gets more context, but not always better context.

**A cleaner setup would look like this:**

```markup
your-project/
├── CLAUDE.md
└── .claude/
    └── rules/
        ├── frontend.md
        ├── backend-api.md
        ├── testing.md
        └── data-pipelines.md
```

In this setup:

- **CLAUDE.md:** explains the product at a high-level
- **frontend.md:** focuses on UI conventions
- **backend-api.md:** focuses on API behavior and validation rules
- **testing.md:** explains how tests should be written and run
- **data-pipelines.md**: captures conventions for batch jobs and scheduled tasks

That is much easier to maintain than one large instruction file.

### What should stay in CLAUDE.md?

A good **CLAUDE.md** usually includes:

- The main stack
- The high-level architecture
- The most important development commands
- Broad code conventions
- Important project-wide warnings or constraints

Here is a short example for a FastAPI project:

```markup
# Project: Customer Insights AP

## Stack
- FastAPI
- PostgreSQL
- SQLAlchemy
- Pytest

## Structure
- \`app/api/\` contains route definitions
- \`app/services/\` contains business logic
- \`app/models/\` contains ORM models
- \`app/schemas/\` contains request and response schemas

## Commands
- \`pytest\` runs the test suite
- \`alembic upgrade head\` applies migrations
- \`ruff check .\` runs linting
- \`ruff format .\` formats the code

## Conventions
- Validate all request bodies with Pydantic schemas
- Keep route handlers thin; business logic belongs in services
- Do not expose internal exception details in API responses
```

This is useful because it gives Claude a reliable starting point without drowning it in detail.

### What should move into rules/?

Once instructions become narrow or area-specific, move them out of **CLAUDE.md**.

For example, **backend-api.md** might contain rules like these:

```markup
# Backend API Rules

- Every new endpoint must include request and response schemas
- Use dependency injection for database sessions
- Return paginated results for collection endpoints
- Log external API failures with the shared logger
- Prefer service-layer functions over logic inside route files
```

And **frontend.md** might say:

```markup
# Frontend Rules

- Prefer server components unless client interactivity is required
- Keep UI state local unless it is shared across pages
- Reuse design system components before creating new ones
- Put page-specific components beside their route when possible
```

Now each file has a clear purpose.

#### When rules/ becomes the better choice

You should usually split into **rules/** when:

- **CLAUDE.md** starts feeling crowded
- Different parts of the repo need different guidance
- Different people have different standards
- The team updates conventions often
- You want to scope instructions to specific paths or concerns

This is where modularity starts paying off. Instead of editing one big document every time, you update only the file that matches the problem.

![](https://substackcdn.com/image/fetch/$s_!pQSi!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F82a49448-64b1-49e2-a7e0-ab17166697c0_720x440.png)

This diagram helps the reader see that **CLAUDE.md** is the central layer, while **rules/** breaks out detailed guidance into smaller units.

### A stronger structure with path-based rules

As the repo grows, it can be useful to make some rules apply only to certain files. For example:

```markup
.claude/
└── rules/
    ├── frontend.md
    ├── backend-api.md
    ├── tests.md
    └── migrations.m
```

That way, backend-specific instructions do not crowd frontend work, and migration guidance appears only when Claude is operating around database changes.

Even without going deep into syntax, the important organizational idea is simple: keep your global instructions broad, and move targeted guidance into modular files.

### Why is this structure more efficient?

This separation improves efficiency in three ways.

- First, it keeps **CLAUDE.md** readable. That makes it easier for both humans and Claude to extract the main project context quickly.
- Second, it reduces maintenance overhead. You do not have to keep reopening one oversized file whenever a single convention changes.
- Third, it creates a cleaner path for team ownership. The people responsible for testing, frontend work, or API design can update their own rule files without turning the main instruction file into shared clutter.

In practice, the best setup is not the one with the most instructions. It is the one where instructions are placed at the right level.