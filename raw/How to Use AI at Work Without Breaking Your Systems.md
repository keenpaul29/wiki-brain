---
title: "How to Use AI at Work Without Breaking Your Systems?"
source: "https://substack.com/home/post/p-190624275"
author:
  - "[[Shreyas Patro]]"
published: 2026-03-11
created: 2026-05-08
description: "AI coding assistants have changed the way engineers work."
tags:
  - "clippings"
---
AI coding assistants have changed the way engineers work. Tools like Claude Code, GitHub Copilot, Cursor, and ChatGPT can now write functions, debug errors, refactor entire codebases, and generate infrastructure scripts in seconds. For developers, this feels like a superpower and in many ways, it is.

But superpowers come with risk.

A developer lost 2.5 years of work after an AI coding assistant executed `terraform destroy` while attempting to fix a configuration issue. The AI didn’t malfunction. It didn’t go rogue. It simply did what it was asked, and nobody stopped it.

That’s the uncomfortable truth about AI in engineering workflows: the tool isn’t the problem. Over-reliance on it without safeguards is.

The right mental model is this: treat AI like a brilliant junior engineer. Incredibly fast, impressively knowledgeable, but lacking real-world judgment. You wouldn’t give a junior developer unsupervised access to your production database on day one. The same logic applies here. AI should always be supervised, verified, and contained,never autonomous.

---

## The Real Risks of AI in Engineering Workflows

Most engineers understand that AI can generate buggy code. What they underestimate is that AI can also take destructive, irreversible actions,and do so confidently.

Here’s what that looks like in practice:

**Destructive commands.** AI assistants operating in agentic mode can run terminal commands directly. Without guardrails, a prompt like “clean up unused infrastructure” could trigger `terraform destroy` or `rm -rf` on critical directories.

**Database deletion.** An AI tasked with “resetting the dev environment” may not distinguish between a local test database and a production one — especially if permissions aren’t scoped correctly.

**File overwrites.** AI-generated scripts that write to the filesystem can silently overwrite configuration files, environment variables, or deployment scripts without warning.

**Infrastructure misconfiguration.** AI-generated Terraform, Kubernetes, or Ansible files often look correct at a glance but contain subtle errors, open security groups, misconfigured IAM roles, or exposed ports, that create serious vulnerabilities.

**Broken deployments.** AI may generate code that passes basic tests but fails under production conditions, and if there’s no human review gate, that code ships.

The underlying issue is consistent: AI executes instructions but does not understand consequences. It has no concept of “this will take down your system” or “there’s no undoing this.” That judgment belongs to the human in the loop, which means the human must actually be in the loop.

---

## The AI Safety Checklist

This is the section to save, share, and pin to your team’s Notion.

### Access Control

- **Never give AI direct production access.** AI tools should operate in sandboxed or development environments only.
- **Use scoped permissions.** If an AI agent needs database access, give it read-only credentials, not admin.
- **Audit what your AI tool can touch.** Know exactly which systems, APIs, and filesystems an AI assistant has access to before you run anything.

### Command Verification

- **Always read AI-generated commands before running them.** Every single time, without exception.
- **Never blindly copy-paste terminal commands.** If you don’t understand what a command does, look it up before executing it.
- **Be especially cautious with flags.** Commands like `--force`, `--all`, `-r`, or `--delete` are red flags that warrant extra scrutiny.

### Infrastructure Protection

- **Treat destructive commands as radioactive.** `terraform destroy`, `rm -rf`, `DROP TABLE`, `kubectl delete namespace`, these require human confirmation, full stop.
- **Add confirmation steps to critical operations.** If your tooling allows it, require explicit approval before any command that modifies or deletes infrastructure.
- **Version control your infrastructure code.** Changes to Terraform, Helm charts, or deployment configs should go through pull requests, not direct execution.

### Backup Strategy

- **Maintain multiple backups, in multiple locations.** Local, cloud, and offsite. The developer who lost 2.5 years of data had none.
- **Test your recovery procedures.** A backup you’ve never restored is a backup you can’t trust.
- **Automate backups and verify them regularly.** Don’t rely on manual processes for something this critical.

### Deployment Safety

- **Always use a staging environment.** AI-generated code should be tested in an environment that mirrors production, not in production itself.
- **Use CI/CD pipelines with human approval gates.** Automated checks catch many issues; human review catches the rest.
- **Never let AI push directly to main.** PRs exist for a reason. Use them.

---

## Best Practices for Using AI at Work

The checklist tells you what to avoid. Here’s how to get the most out of AI while staying safe.

**Use AI for drafting, not executing.** AI is exceptional at generating code, writing scripts, and proposing solutions. Let it do that. Reserve execution for humans who’ve reviewed the output.

**Make incremental changes.** Instead of asking AI to “refactor the entire authentication system,” ask it to refactor one function. Smaller changes are easier to review, easier to test, and easier to roll back.

**Use AI suggestions as proposals, not instructions.** When an AI says “run this command,” treat it the way you’d treat advice from a colleague, worth considering, but requiring your own judgment before acting.

**Keep humans in the loop for critical operations.** Anything touching production, customer data, or infrastructure should have a human review step. No exceptions.

**Document your AI-assisted changes.** If AI helped write a migration script or infrastructure change, note that in your commit message or PR description. Your future self and teammates will thank you.

---

## A Simple Rule Engineers Should Remember

When in doubt, come back to this framework:

**AI → Suggests. Human → Verifies. System → Executes.**

AI is a proposal engine, not a decision-maker. The moment you remove the human verification step because you’re tired, rushed, or just confident, is the moment you’re exposed. The `terraform destroy` incident didn’t happen because AI is dangerous. It happened because the human step was skipped.

Build workflows where skipping that step is impossible. Review before you run. Verify before you deploy. Back up before you change anything critical.

The engineers who use AI most effectively aren’t the ones who trust it most. They’re the ones who’ve built just enough friction to stay in control.