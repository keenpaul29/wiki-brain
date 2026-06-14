param(
  [switch]$AutoIngest,
  [switch]$AutoDeepen,
  [switch]$SkipGbrain,
  [switch]$SkipCommit,
  [switch]$SkipLinks,
  [switch]$Help
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$WikiDir = Join-Path $Root "wiki"
$LogPath = Join-Path $WikiDir "log.md"
$StartTime = Get-Date

if ($Help) {
  Write-Host "Usage: powershell -File scripts/run-daily-cycle.ps1 [options]
Options:
  -AutoIngest   Auto-ingest without prompting
  -AutoDeepen   Run auto-deepen on thin concepts
  -SkipGbrain   Skip GBrain sync
  -SkipCommit   Skip git commit
  -SkipLinks    Skip link/lint checks
  -Help         Show this help"
  exit 0
}

function Write-Step($msg) {
  Write-Host ""
  Write-Host ">>> $msg" -ForegroundColor Cyan
}

function Write-Ok($msg) {
  Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
  Write-Host "  [WARN] $msg" -ForegroundColor Yellow
}

function Write-Err($msg) {
  Write-Host "  [ERR] $msg" -ForegroundColor Red
}

function Append-Log($text) {
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
  $entry = "## $stamp daily cycle | $text"
  Add-Content -Path $LogPath -Value "`r`n$entry" -Encoding UTF8
}

function Test-Command($cmd) {
  return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

# Phase 0: Prerequisites
Write-Step "Phase 0/6: Prerequisites"

if (-not (Test-Command gbrain)) {
  Write-Warn "gbrain CLI not found. Install with: bun install -g github:garrytan/gbrain"
  if (-not $SkipGbrain) { $SkipGbrain = $true }
}

Write-Ok "Root: $Root"

# Phase 1: Scan for changes
Write-Step "Phase 1/6: Scan raw/ for changes"

$scanOutput = & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\update-wiki-state.ps1" 2>&1
Write-Host $scanOutput

$reportPath = Join-Path (Join-Path $WikiDir "_state") "daily-scan.md"
$hasChanges = $false
$newCount = 0
$changedCount = 0

if (Test-Path $reportPath) {
  $report = Get-Content -Raw -Path $reportPath
  if ($report -match 'New files: (\d+)') { $newCount = [int]$Matches[1] }
  if ($report -match 'Changed files: (\d+)') { $changedCount = [int]$Matches[1] }
  $hasChanges = ($newCount -gt 0) -or ($changedCount -gt 0)
  if ($hasChanges) {
    Write-Ok "$newCount new, $changedCount changed file(s)"
  } else {
    Write-Ok "No changes detected"
  }
}

# Phase 1.5: Auto-deepen
if ($AutoDeepen) {
  Write-Step "Phase 1.5/6: Auto-deepen thin concepts"

  $conceptDir = Join-Path $WikiDir "concepts"
  if (Test-Path $conceptDir) {
    $thinPages = @()
    foreach ($c in (Get-ChildItem -Path $conceptDir -Filter "*.md")) {
      $lines = (Get-Content -Path $c.FullName).Count
      $text = Get-Content -Raw -Path $c.FullName
      $sourceRefs = ([regex]::Matches($text, '\[\[sources/')).Count
      if ($lines -lt 100 -or $sourceRefs -lt 2) {
        $thinPages += @{
          name = $c.BaseName
          lines = $lines
          sources = $sourceRefs
        }
      }
    }
    $thinPages = $thinPages | Sort-Object lines

    if ($thinPages.Count -gt 0) {
      Write-Ok "$($thinPages.Count) thin concept(s) queued"
      $thinPages | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.name) ($($_.lines) lines, $($_.sources) source refs)" -ForegroundColor Yellow
      }
      if ($thinPages.Count -gt 10) {
        Write-Host "  ... and $($thinPages.Count - 10) more"
      }
      Append-Log "Auto-deepen: $($thinPages.Count) thin concept(s) flagged"
    } else {
      Write-Ok "All concept pages have sufficient depth"
    }
  }
}

# Phase 2: Link check and lint
if (-not $SkipLinks) {
  Write-Step "Phase 2/6: Wiki link check"
  $linksResult = & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\check-wiki-links.ps1" 2>&1
  $linksOk = $LASTEXITCODE -eq 0
  if ($linksOk) {
    Write-Ok "Links check passed"
  } else {
    Write-Err "Links check failed:"
    Write-Host $linksResult
    Append-Log "Link check FAILED"
  }

  Write-Step "Phase 2b/6: Orphan page lint"
  $lintResult = & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\lint-wiki.ps1" 2>&1
  $lintOk = $LASTEXITCODE -eq 0
  if ($lintOk) {
    Write-Ok "Orphan lint passed"
  } else {
    Write-Warn "Orphan pages found:"
    Write-Host $lintResult
  }
}

# Phase 3: Commit state
if (-not $SkipCommit) {
  Write-Step "Phase 3/6: Commit wiki state"
  & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\update-wiki-state.ps1" -CommitState 2>&1 | Out-Null

  $status = git status --porcelain -- wiki/ raw/
  $hasGitChanges = ($status | Measure-Object | Select-Object -ExpandProperty Count) -gt 0
  if ($hasGitChanges) {
    git add -A
    git commit -m "daily cycle: wiki update $(Get-Date -Format yyyy-MM-dd)" --quiet
    Write-Ok "Changes committed"
    Append-Log "Wiki state committed"
  } else {
    Write-Ok "No changes to commit"
  }
}

# Phase 4: Sync to GBrain
if (-not $SkipGbrain) {
  Write-Step "Phase 4/6: Sync wiki to GBrain"
  $syncResult = & gbrain sync --source brain 2>&1
  $syncOk = $LASTEXITCODE -eq 0
  if ($syncOk) {
    Write-Ok "GBrain sync completed"
    Append-Log "GBrain sync OK"
  } else {
    Write-Warn "GBrain sync completed with warnings"
    $syncResult | ForEach-Object { Write-Host "  $_" }
    Append-Log "GBrain sync completed with warnings"
  }
}

# Phase 5: GBrain health
if (-not $SkipGbrain) {
  Write-Step "Phase 5/6: GBrain health check"
  $doctor = & gbrain doctor --json 2>&1 | Out-String
  $score = 0
  $brainScore = 0
  if ($doctor -match '"health_score":(\d+)') { $score = [int]$Matches[1] }
  if ($doctor -match '"brain_score":(\d+)') { $brainScore = [int]$Matches[1] }
  if ($score -ge 80) {
    Write-Ok "Health score: $score/100"
  } elseif ($score -ge 50) {
    Write-Warn "Health score: $score/100"
  } else {
    Write-Err "Health score: $score/100"
  }
  Write-Host "  Content score: $brainScore/100"
  Append-Log "Health score: $score/100"
}

# Phase 6: Summary
Write-Step "Phase 6/6: Summary"
$duration = (Get-Date) - $StartTime
$elapsed = "{0:N0}s" -f $duration.TotalSeconds
Write-Host "Cycle completed in $elapsed" -ForegroundColor Green

$summary = "Cycle completed in $elapsed"
if ($hasChanges) { $summary += ", $newCount new + $changedCount changed" }
if ($AutoDeepen) { $summary += ", auto-deepen queued" }
if ($linksOk) { $summary += ", links OK" }
Append-Log $summary

Write-Host ""
Write-Host "Done. Logged to wiki/log.md" -ForegroundColor Green
