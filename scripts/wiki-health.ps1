param(
  [switch]$Json
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

Write-Output "=== Wiki Brain Health Dashboard ==="
Write-Output "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n"

# ─── Concept thickness ──────────────────────────────────────────
$ConceptsDir = Join-Path $Root "wiki\concepts"
$RawDir = Join-Path $Root "raw"
$SourcesDir = Join-Path $Root "wiki\sources"

$thin = @()
if (Test-Path $ConceptsDir) {
  Get-ChildItem -LiteralPath $ConceptsDir -Filter "*.md" | ForEach-Object {
    $lines = @(Get-Content $_.FullName).Count
    [PSCustomObject]@{ Name = $_.BaseName; Lines = $lines; Path = $_.FullName }
  } | ForEach-Object {
    if ($_.Lines -lt 80) { $thin += $_ }
  }
}

Write-Output "Concepts: $(@(Get-ChildItem $ConceptsDir -Filter '*.md').Count) total, $($thin.Count) thin (<80 lines)"
if ($thin.Count -gt 0) {
  $thin | Sort-Object Lines | ForEach-Object { Write-Output "  THIN $($_.Lines)l  $($_.Name)" }
}
Write-Output ""

# ─── Stale pages (not modified in 30d) ─────────────────────────
$cutoff = (Get-Date).AddDays(-30)
$stale = @(Get-ChildItem -Recurse -LiteralPath (Join-Path $Root "wiki") -Filter "*.md" |
  Where-Object { $_.LastWriteTime -lt $cutoff -and $_.Directory.Name -ne "_state" })

Write-Output "Stale wiki pages (last edit >30d ago): $($stale.Count)"
$stale | Sort-Object LastWriteTime | Select-Object -First 10 | ForEach-Object {
  Write-Output "  STALE $($_.LastWriteTime.ToString('yyyy-MM-dd'))  $($_.FullName.Substring($Root.Path.Length+1))"
}
if ($stale.Count -gt 10) { Write-Output "  ... and $($stale.Count - 10) more" }
Write-Output ""

# ─── Raw → wiki gap ────────────────────────────────────────────
$rawFiles = @(Get-ChildItem -LiteralPath $RawDir -Filter "*.md")
$sourceFiles = @(Get-ChildItem -LiteralPath $SourcesDir -Filter "*.md")
$missed = 0
$matchedRaw = @()
foreach ($raw in $rawFiles) {
  # Use first 40 chars of cleaned stem for fuzzy matching
  $stem = ($raw.BaseName -replace '[^\w\s-]', '' -replace '\s+', '-')
  if ($stem.Length -gt 35) { $stem = $stem.Substring(0, 35) }
  $match = $sourceFiles | Where-Object { $_.BaseName -match ($stem -replace '-', '[- ]') }
  if ($match) { $matchedRaw += $raw }
}
$missed = $rawFiles.Count - $matchedRaw.Count

Write-Output "Raw files: $($rawFiles.Count), Wiki sources: $($sourceFiles.Count), Unmatched (approx): $missed"
Write-Output ""

# ─── Wikilink orphans (concepts no other concept links to) ─────
$conceptPages = @(Get-ChildItem $ConceptsDir -Filter "*.md")
$allLinks = @{}
$conceptPages | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  [regex]::Matches($content, '\[\[concepts/([^\]|]+)') | ForEach-Object {
    $allLinks[$_.Groups[1].Value] = $true
  }
}
$orphans = @($conceptPages | Where-Object { -not $allLinks.ContainsKey($_.BaseName) -and $_.BaseName -ne "shared-engineering-language" })
Write-Output "Orphan concepts (no inbound links from other concepts): $($orphans.Count)"
$orphans | ForEach-Object { Write-Output "  ORPHAN  $($_.BaseName)" }
Write-Output ""

# ─── GBrain doctor score ───────────────────────────────────────
try {
  $doctorStdout = gbrain doctor 2>$null
  $scoreLine = $doctorStdout | Select-String "Brain score"
  if ($scoreLine) {
    Write-Output "GBrain score: $($scoreLine.Line.Trim())"
  }
} catch {
  Write-Output "GBrain: could not run doctor (is gbrain on PATH?)"
}
Write-Output ""

# ─── Uncommitted changes ───────────────────────────────────────
$gitStatus = git -C $Root status --porcelain 2>&1
$changed = @($gitStatus | Where-Object { $_ -and $_ -is [string] })
if ($changed.Count -gt 0) {
  Write-Output "Uncommitted changes: $($changed.Count) file(s)"
} else {
  Write-Output "Working tree: clean"
}
Write-Output ""

# ─── Quick action recommendations ──────────────────────────────
Write-Output "=== Recommendations ==="
if ($thin.Count -gt 0) { Write-Output "- Deepen $($thin.Count) thin concept pages (scripts/run-daily-cycle.ps1 -AutoDeepen)" }
if ($missed -gt 0) { Write-Output "- Process $missed raw files without wiki source pages" }
if ($orphans.Count -gt 0) { Write-Output "- Add backlinks to $($orphans.Count) orphan concepts" }
if ($stale.Count -gt 0) { Write-Output "- Review $($stale.Count) stale wiki pages for currency" }
Write-Output "- Run: gbrain sync --source brain --no-pull (after committing wiki changes)"
Write-Output "- Run: gbrain dream --source brain (after content changes)"
Write-Output "- Run: gbrain integrity auto --yes (periodic quality check)"
Write-Output ""
