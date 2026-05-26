---
title: "Effective Git Workflows and Commands"
type: source
created: 2026-05-26
source: https://medium.com/@TusharKanjariya/i-used-git-wrong-for-years-8c8307402640
published: 2026-05-08
tags:
  - source
---

# Effective Git Workflows and Commands

## Summary

Explores advanced Git commands and habits—such as interactive staging, bisecting, worktrees, and reflogs—that shift Git usage from a basic backup tool to an editable, recoverable timeline.

## Key Ideas

- Senior developers view Git as a project timeline of states rather than just a remote backup mechanism.
- git add -p (patch mode) allows developers to stage files interactively line-by-line, producing clean, scoped commits.
- git bisect uses binary search to quickly locate the exact commit that introduced a bug across a range of commits.
- git worktree enables checking out multiple branches simultaneously into separate physical directories, avoiding the need to stash and switch.
- git reflog tracks every action taken locally (including deleted commits/branches and reset states) for up to 90 days, enabling recovery of lost work.
- git rebase -i (interactive rebase) allows squashing, reordering, and editing local commits to ensure clean, readable commit histories before merging.

## Links

- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Connects to [[concepts/structured-learning-and-retention|Structured Learning and Retention]]
- Connects to [[concepts/shared-engineering-language|Shared Engineering Language]]
