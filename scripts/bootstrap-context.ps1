param(
  [int]$MaxLinesPerFile = 200,
  [switch]$SkipGitPull
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$FilesToLoad = @(
  "AGENTS.md",
  "BRAIN_CONTEXT.md",
  "SESSION_HANDOFF.md",
  "wiki/_state/daily-scan.md",
  "GBRAIN_DEV_WORKFLOW.md"
)

function Write-Section {
  param(
    [string]$Title,
    [string]$Body
  )

  Write-Output ""
  Write-Output "===== $Title ====="
  Write-Output $Body
}

Push-Location $Root.Path
try {
  if (-not $SkipGitPull) {
    $hasGit = Get-Command git -ErrorAction SilentlyContinue
    if ($hasGit) {
      $insideWorkTree = git rev-parse --is-inside-work-tree 2>$null
      if ($LASTEXITCODE -eq 0 -and $insideWorkTree -eq "true") {
        Write-Output "[bootstrap] Pulling latest changes..."
        git pull --ff-only
      } else {
        Write-Output "[bootstrap] Skipping git pull (not a git worktree)."
      }
    } else {
      Write-Output "[bootstrap] Skipping git pull (git not found)."
    }
  } else {
    Write-Output "[bootstrap] Skipping git pull (requested)."
  }

  Write-Output "[bootstrap] Running wiki state scan..."
  & powershell -ExecutionPolicy Bypass -File (Join-Path $Root.Path "scripts/update-wiki-state.ps1")

  Write-Output ""
  Write-Output "COPY THE BLOCK BELOW INTO A NEW CLAUDE/CODEX SESSION"
  Write-Output "======================================================="
  Write-Output "Read these files first and treat them as authoritative memory/instructions for this session:"
  Write-Output "1) AGENTS.md"
  Write-Output "2) BRAIN_CONTEXT.md"
  Write-Output "3) SESSION_HANDOFF.md"
  Write-Output "4) wiki/_state/daily-scan.md"
  Write-Output "5) GBRAIN_DEV_WORKFLOW.md"
  Write-Output ""
  Write-Output "Then continue the daily wiki workflow end-to-end, without modifying raw/."

  foreach ($relativePath in $FilesToLoad) {
    $absolutePath = Join-Path $Root.Path $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
      Write-Section -Title $relativePath -Body "[missing]"
      continue
    }

    $contentLines = Get-Content -LiteralPath $absolutePath
    if ($contentLines.Count -gt $MaxLinesPerFile) {
      $truncated = @($contentLines[0..($MaxLinesPerFile - 1)]) + "[truncated at $MaxLinesPerFile lines]"
      Write-Section -Title $relativePath -Body ($truncated -join "`r`n")
    } else {
      Write-Section -Title $relativePath -Body ($contentLines -join "`r`n")
    }
  }

  Write-Output ""
  Write-Output "[bootstrap] Done."
}
finally {
  Pop-Location
}
