param(
  [switch]$CommitState
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$RawDir = Join-Path $Root "raw"
$WikiDir = Join-Path $Root "wiki"
$StateDir = Join-Path $WikiDir "_state"
$ManifestPath = Join-Path $StateDir "raw-manifest.json"
$ReportPath = Join-Path $StateDir "daily-scan.md"

New-Item -ItemType Directory -Force -Path $StateDir | Out-Null

function Get-RawSnapshot {
  if (-not (Test-Path $RawDir)) { return @() }

  Get-ChildItem -Recurse -File -Path $RawDir | Sort-Object FullName | ForEach-Object {
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName
    [PSCustomObject]@{
      path = $_.FullName.Substring($Root.Path.Length + 1).Replace("\", "/")
      sha256 = $hash.Hash.ToLowerInvariant()
      length = $_.Length
      last_write_time = $_.LastWriteTime.ToString("o")
    }
  }
}

function Read-Manifest {
  if (-not (Test-Path $ManifestPath)) { return @{} }
  $items = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
  $map = @{}
  foreach ($item in $items) { $map[$item.path] = $item }
  return $map
}

$current = @(Get-RawSnapshot)
$previous = Read-Manifest
$currentMap = @{}
foreach ($item in $current) { $currentMap[$item.path] = $item }

$new = @($current | Where-Object { -not $previous.ContainsKey($_.path) })
$changed = @($current | Where-Object { $previous.ContainsKey($_.path) -and $previous[$_.path].sha256 -ne $_.sha256 })
$deleted = @($previous.Keys | Where-Object { -not $currentMap.ContainsKey($_) } | Sort-Object)

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$lines = @(
  "---",
  "title: Daily Wiki Scan",
  "type: state",
  "updated: $(Get-Date -Format yyyy-MM-dd)",
  "---",
  "",
  "# Daily Wiki Scan",
  "",
  "Generated: $now",
  "",
  "## Summary",
  "",
  "- Raw files: $($current.Count)",
  "- New files: $($new.Count)",
  "- Changed files: $($changed.Count)",
  "- Deleted files: $($deleted.Count)",
  "- State committed: $($CommitState.IsPresent)",
  "",
  "## New Files",
  ""
)

if ($new.Count) {
  $lines += $new | ForEach-Object { '- `' + $_.path + '`' }
} else {
  $lines += "- None"
}

$lines += @("", "## Changed Files", "")
if ($changed.Count) {
  $lines += $changed | ForEach-Object { '- `' + $_.path + '`' }
} else {
  $lines += "- None"
}

$lines += @("", "## Deleted Files", "")
if ($deleted.Count) {
  $lines += $deleted | ForEach-Object { '- `' + $_ + '`' }
} else {
  $lines += "- None"
}

$lines += @(
  "",
  "## Automation Instructions",
  "",
  "If new or changed files are listed, ingest them into `wiki/`, update source/concept/synthesis pages, update `wiki/index.md`, and append to `wiki/log.md`.",
  "After a successful ingest, run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState`."
)

Set-Content -LiteralPath $ReportPath -Value ($lines -join "`r`n") -Encoding UTF8

if ($CommitState) {
  $json = $current | ConvertTo-Json -Depth 4
  Set-Content -LiteralPath $ManifestPath -Value $json -Encoding UTF8
}

Write-Output "Daily scan written to $ReportPath"
Write-Output "New=$($new.Count) Changed=$($changed.Count) Deleted=$($deleted.Count) CommitState=$($CommitState.IsPresent)"
