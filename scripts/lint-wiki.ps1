param(
  [string]$WikiPath
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($WikiPath)) {
  $WikiPath = Join-Path $PSScriptRoot "..\wiki"
}

$WikiRoot = Resolve-Path $WikiPath
$files = @(Get-ChildItem -Recurse -File -Path $WikiRoot -Filter "*.md")
$pages = @{}
$inbound = @{}

foreach ($file in $files) {
  $relativePath = $file.FullName.Substring($WikiRoot.Path.Length + 1).Replace("\", "/")
  $pagePath = $relativePath -replace "\.md$", ""
  $basename = [IO.Path]::GetFileNameWithoutExtension($file.Name)

  $pages[$pagePath] = $relativePath
  $pages[$basename] = $relativePath
  if (-not $inbound.ContainsKey($relativePath)) { $inbound[$relativePath] = 0 }
}

foreach ($file in $files) {
  $text = Get-Content -Raw -LiteralPath $file.FullName
  [regex]::Matches($text, "\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]") | ForEach-Object {
    $target = $_.Groups[1].Value
    if ($pages.ContainsKey($target)) {
      $targetRelative = $pages[$target]
      $inbound[$targetRelative] = $inbound[$targetRelative] + 1
    }
  }
}

$exempt = @(
  "index.md",
  "log.md",
  "automation.md",
  "maintenance.md",
  "_state/daily-scan.md"
)

$orphans = @(
  $inbound.Keys |
  Where-Object { $inbound[$_] -eq 0 -and ($exempt -notcontains $_) } |
  Sort-Object
)

if ($orphans.Count -gt 0) {
  Write-Output "Orphan wiki pages (no inbound links):"
  $orphans | ForEach-Object { Write-Output "- $_" }
  exit 1
}

Write-Output "No orphan wiki pages found (excluding maintenance/state docs)."
