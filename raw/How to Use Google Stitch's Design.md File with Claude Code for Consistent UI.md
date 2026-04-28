---
title: "How to Use Google Stitch's Design.md File with Claude Code for Consistent UI"
source: "https://www.mindstudio.ai/blog/google-stitch-design-md-claude-code-consistent-ui"
author:
  - "[[MindStudio Team]]"
published: 2026-03-23
created: 2026-04-28
description: "Google Stitch's design.md file captures your full design system in a format AI agents can read. Here's how to use it with Claude Code for consistent UI output."
tags:
  - "clippings"
---
## When Your Design System Gets Lost in Translation

One of the most frustrating parts of using AI to write front-end code is how quickly it forgets what your design looks like. You describe your color palette in a prompt, generate a button component, then ask for a card — and suddenly the spacing, colors, and font weights are completely different.

The problem isn’t that the AI is bad at writing code. It’s that AI coding agents have no persistent awareness of your design system unless you give them something structured to reference.

Google Stitch’s design.md file is built to fix this. It captures your entire design system — colors, typography, spacing, component patterns — in a single Markdown document that AI agents like Claude Code can read and consistently apply across a whole codebase.

This guide covers what’s inside a design.md file, how to get one from Google Stitch, and exactly how to wire it up with Claude Code so your generated UI stays on-system from the first component to the last.

---

## What Google Stitch Actually Does

Google Stitch is an AI-powered design tool from Google Labs that uses Gemini to generate UI designs from text descriptions or uploaded reference images. You describe what you want — “a dashboard for a SaaS analytics product with a clean, minimal look and a dark blue and white palette” — and Stitch generates screens, components, and a full design system to support them.

What separates Stitch from a simple mockup generator is its output format. Alongside the visual designs, Stitch produces a design.md file: a plain-text document that captures all design decisions in a structured, machine-readable way.

This wasn’t an accident. The design.md format was designed specifically to be consumed by AI coding agents. The idea is that you hand this file to any agent that writes code — Claude Code, Cursor, GitHub Copilot Workspace, or a custom agent — and it has everything it needs to generate UI that matches your design without you spelling out the specs in every prompt.

### Why Markdown Works for Design Systems

Markdown is plain text. Any AI can read it natively, no special parsing required. It’s version-controllable, easy to edit, and compact enough to fit inside a context window without consuming too much space.

Design tokens have historically lived in JSON files or inside proprietary tools. The design.md approach is simpler: it’s readable by humans and AI alike, requires no special tooling, and sits right in your project repo alongside your code.

---

## What’s Inside a design.md File

The design.md file that Google Stitch generates is essentially a design spec written in a format optimized for AI consumption. A typical file includes:

**Color system**

- Primary, secondary, and accent colors with exact hex values
- Neutral and gray scale values
- Semantic color assignments (success, error, warning, info)
- Background and surface colors

**Typography**

- Font families (primary and secondary)
- Type scale: heading sizes H1–H6, body, small, caption
- Font weights used in the system
- Line height and letter spacing values

**Spacing scale**

- Base unit (usually 4px or 8px)
- Named spacing values — xs, sm, md, lg, xl, 2xl — with pixel values

**Layout and grid**

- Container max-widths
- Column grid specifications
- Responsive breakpoints

**Components**

- Visual patterns for common elements: buttons, inputs, cards, navigation
- Interactive states — hover, active, disabled, focus
- Variants — primary, secondary, ghost, destructive

**Border radius and shadow**

- Corner radius values by component type
- Box shadow definitions and usage context

A well-generated design.md reads almost like a spec written by a human designer. The difference is that it’s structured specifically so an LLM can parse and apply it reliably.

---

## What You Need Before Starting

Before setting up this workflow, have these in place:

- **Google Stitch access** — Available through [Google Labs](https://labs.google.com/). A Google account is all you need.
- **Claude Code installed** — Anthropic’s terminal-based coding agent. Install via npm with `npm install -g @anthropic-ai/claude-code`.
- **A front-end project** — React, Next.js, Vue, plain HTML/CSS — the workflow applies to any stack.
- **Node.js** — Required for Claude Code to run.

You don’t need to know CSS-in-JS or any particular component library. Claude Code can target whatever styling approach your project uses — Tailwind, CSS Modules, plain CSS, styled-components.

---

## Step-by-Step: The Full Workflow

### Step 1: Generate Your Design in Google Stitch

Open Google Stitch and describe the UI you want to build. Be specific about:

- The product type (“a project management web app”)
- The visual tone (“clean, minimal, professional — dark navy and off-white palette”)
- The screens or components you need (“dashboard, sidebar, data table, settings page”)

Stitch will generate UI mockups and a supporting design system. You can also upload a reference image — a screenshot of an existing product or a rough sketch — if you want Stitch to match a specific aesthetic.

Review the output and iterate. The quality of your design.md depends on how well-developed the Stitch design is. Spend time here before exporting.

### Step 2: Export the design.md File

Once the design is finalized, export the design.md from Google Stitch. It will contain all design tokens and system specifications.

Save it to the root of your project directory as `design.md`. Keeping it at the root ensures Claude Code can find it regardless of which subdirectory it’s working in.

### Step 3: Create or Update Your CLAUDE.md File

Claude Code reads a file called `CLAUDE.md` in your project root as persistent context. This is loaded at the start of every session, which makes it the right place to tell Claude Code about your design system.

Create a `CLAUDE.md` at the project root — or update one you already have — with something like this:

```markdown
# Project Context

## Design System
This project uses a design system defined in \`design.md\` at the project root.
Always refer to this file when generating or modifying any UI component.

- Use only colors, fonts, and spacing values defined in design.md.
- Do not invent new values or use defaults from any framework.
- Match component states (hover, focus, active, disabled) to the patterns in design.md.
- Follow the typographic scale and weight assignments in design.md.

## Stack
- Framework: Next.js 14 (App Router)
- Styling: Tailwind CSS with custom config
- Components: Custom components, no UI library
```

Adjust the stack section to match your actual project. The critical part is explicitly telling Claude Code to reference design.md and not deviate from it.

### Step 4: Start a Claude Code Session

Run `claude` in your terminal from the project root. Claude Code will load your CLAUDE.md and carry those instructions throughout the session.

Verify it’s reading the design system by asking: “What primary color is defined in this project’s design system?” It should return the exact hex value from your design.md, not a guess.

### Step 5: Generate Components

Now build UI with component requests in plain language:

- “Build a primary button component using the design system in design.md.”
- “Create a pricing card component, following the spacing and typography defined in the project design system.”
- “Add a top navigation bar that uses the colors and fonts specified in design.md.”

Because CLAUDE.md points to design.md, Claude Code references the file each time instead of inventing values.

### Step 6: Review and Correct

After generating each component, check it against your Stitch designs:

- Color values match exactly (browser DevTools color picker helps)
- Font sizes and weights are correct
- Spacing follows the scale from design.md
- Interactive states are implemented

If something’s off, correct it directly: “The button background doesn’t match the primary color in design.md. Fix it using the exact hex value from that file.”

---

## Tips for Getting Consistent Results

### Mention the Design System in Major Prompts

Even with CLAUDE.md loaded, explicitly referencing the design system in prompts for new components helps. “Using the design system in design.md, build a user profile card component.” It keeps the model’s attention anchored to the spec.

### Translate design.md Into Your CSS Framework Config

If you’re using Tailwind, translate your design.md values into `tailwind.config.js`. This creates a second enforcement layer — even if a prompt drifts slightly, Tailwind’s utility classes constrain the output to your actual token values.

Ask Claude Code to do this once:

“Read design.md and generate a tailwind.config.js that maps all color, spacing, and typography values to custom Tailwind tokens.”

This one-time step pays off across every component generated afterward.

### Run Periodic Consistency Audits

After building a batch of components, ask Claude Code to check for drift: “Review the components in `/components` and identify any that use colors, spacing, or typography values not defined in design.md.”

This surfaces inconsistencies before they accumulate into a bigger problem.

### Commit design.md to Version Control

Treat design.md like source code. Commit it to your repo so everyone on the team works from the same design context. When the design evolves, update the file and commit the change.

---

## Common Mistakes to Avoid

**Not committing design.md to the repo** If the file only exists on your local machine, other developers and future sessions won’t have it. It must be part of the codebase.

**Forgetting to update CLAUDE.md when the stack changes** If you add a new library, switch styling approaches, or introduce a component framework, update CLAUDE.md to reflect it. Claude Code’s behavior depends on what that file says.

**Assuming Claude Code will always follow the design system without drift** It’s consistent, but not infallible. Reviewing generated components against the Stitch designs catches the occasional mistake early.

**Leaving the Stitch design vague before exporting** If you export design.md before fully developing the Stitch design, the file will have gaps — placeholder colors, default spacing, missing component states. Claude Code can only work with what’s there. Refine the design thoroughly before exporting.

**Pointing to design.md without instruction on how to use it** The file provides context, not behavior. Your CLAUDE.md should tell Claude Code *how* to use design.md — not just that it exists. Be explicit: “always use these values, never deviate.”

---

## Where MindStudio Fits Into This Workflow

The Google Stitch → design.md → Claude Code chain is effective, but it’s a manual process. You run each step yourself, review outputs, and iterate by hand.

For teams that want to automate parts of this — or make it accessible to people who aren’t running a terminal — [MindStudio](https://mindstudio.ai/) is a natural fit.

MindStudio is a no-code platform for building AI agents and automated workflows. A practical use here: you can build a MindStudio agent that takes a design.md file as input, runs it through a series of AI processing steps, and outputs component specifications — or complete component code — ready for developer review.

MindStudio supports [multi-model AI workflows](https://mindstudio.ai/blog/ai-workflows) that chain Gemini, Claude, and other models together in a visual builder. If you want Gemini reasoning for design interpretation (keeping it in the same model family as Google Stitch) and Claude for code generation, you can connect those steps without writing a pipeline yourself.

For developers who want to go deeper, MindStudio’s [Agent Skills Plugin](https://mindstudio.ai/blog/agent-skills-plugin) is an npm SDK that lets Claude Code call MindStudio-hosted workflows as simple method calls. If you’ve built a design-validation or token-extraction workflow in MindStudio, Claude Code can invoke it mid-session without leaving the terminal.

For design teams, this creates an interesting option: a self-service web form (built in MindStudio) where a designer uploads their design.md and receives generated component stubs — no developer loop required for the routine parts. You can explore [building AI-powered apps with MindStudio](https://mindstudio.ai/blog/ai-apps-no-code) to see how that kind of workflow comes together.

You can try MindStudio free at [mindstudio.ai](https://mindstudio.ai/).

---

## Frequently Asked Questions

### What is Google Stitch’s design.md file?

The design.md file is a structured Markdown document that Google Stitch generates alongside its UI designs. It documents the complete design system — colors, typography, spacing, components, visual patterns — in a format that AI coding agents can read and apply when writing code. It functions as a machine-readable design spec.

### Can I use a design.md file with AI coding tools other than Claude Code?

Yes. Because design.md is plain Markdown, any AI coding tool that accepts file context can work with it. Cursor, Aider, GitHub Copilot Workspace, and custom agents built with LangChain or CrewAI can all reference the file. The CLAUDE.md mechanism is specific to Claude Code, but the pattern of pointing an AI coding agent to a design system file applies to any LLM-backed tool.

### Does Google Stitch work if I already have a design system?

Google Stitch is primarily for generating new UI from scratch. If you have an existing design system in Figma or another tool, you have two options: import reference screenshots into Stitch and let it derive a matching design system, or manually write a design.md that documents your existing tokens. There’s no direct Figma-to-design.md export path currently, though the community has started building tools in this direction.

### How do I keep design.md current as the design evolves?

Return to Google Stitch, update the design, and re-export the design.md file. Replace the old file in your project and commit the update. Claude Code reads the file fresh at each session start, so it will automatically use the new values going forward. For MindStudio workflows connected to this file, update the workflow’s source reference to point to the new version.

### Does this workflow apply to React Native or mobile development?

The concept transfers, but with some adaptation required. Claude Code can generate React Native components using design tokens from a design.md file. However, Google Stitch focuses on web UI, so the generated specs will be web-oriented — you’ll likely need to manually add mobile-specific patterns (safe area handling, platform navigation conventions, touch target sizing) before using it for mobile.

### What should I do if Claude Code keeps ignoring parts of the design.md?

This usually traces back to vague CLAUDE.md instructions or overly general component prompts. Strengthen the instructions: “Never use any color, spacing, or font value not explicitly defined in design.md.” In component prompts, name the file directly: “Following the exact specifications in design.md, build a secondary button variant.” Running a post-build audit also helps identify where drift is happening so you can tighten the instructions.

---

## Key Takeaways

- Google Stitch’s design.md file captures your full design system in a machine-readable format, removing the need to re-describe design specs in every AI prompt.
- Claude Code’s CLAUDE.md feature lets you embed persistent design instructions at the project level, so every session starts with the design system loaded.
- The workflow is: generate in Stitch → export design.md → add to project → configure CLAUDE.md → generate components with Claude Code.
- Translating design.md tokens into your CSS framework config (Tailwind, CSS Modules) creates a second consistency layer that catches any prompt-level drift.
- For teams, MindStudio can wrap this workflow in an agent that runs automatically — or gives non-technical collaborators a simple interface to trigger it themselves.

This is one of the most practical approaches available right now for maintaining visual consistency in AI-generated UI. Start with one component type — buttons are a good test case — confirm the consistency holds, then apply it to your full component library.