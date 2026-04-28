---
title: Daily Auto Update Workflow
type: guide
created: 2026-04-28
updated: 2026-04-28
tags:
  - automation
  - workflow
---

# Daily Auto Update Workflow

This page defines the automated daily workflow for keeping the wiki current.

## Daily Job

1. Run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1`.
2. Read `wiki/_state/daily-scan.md`.
3. If there are new or changed raw files, ingest only those files first.
4. Update or create source pages under `wiki/sources/`.
5. Update existing concept and synthesis pages before creating new pages.
6. Update [[index]] and append a dated entry to [[log]].
7. Run the wiki link check.
8. After successful ingest, run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState`.

## Ingest Rules

- Never edit files in `raw/`.
- Keep source summaries factual and compact.
- Prefer expanding existing pages over creating duplicate concepts.
- Add new concept pages when a repeated or central idea needs its own home.
- Log every ingest, lint pass, or durable query result.
- If no raw files changed, append nothing unless a lint issue was fixed.

## Link Check

Use this PowerShell check after edits:

```powershell
$root = (Resolve-Path 'wiki').Path
$files = Get-ChildItem -Recurse -File wiki -Filter *.md
$targets = @{}
foreach ($f in $files) {
  $rel = $f.FullName.Substring($root.Length + 1).Replace('\','/')
  $targets[$rel -replace '\.md$',''] = $true
  $targets[[IO.Path]::GetFileNameWithoutExtension($f.Name)] = $true
}
$missing = @()
foreach ($f in $files) {
  $text = Get-Content -Raw -LiteralPath $f.FullName
  [regex]::Matches($text, '\[\[([^\]|]+)(?:\|[^\]]+)?\]\]') | ForEach-Object {
    $target = $_.Groups[1].Value
    if (-not $targets.ContainsKey($target)) {
      $missing += "$($f.FullName.Substring($root.Length + 1)): $target"
    }
  }
}
if ($missing.Count) { $missing } else { 'All wiki links resolved by relative path or basename.' }
```

