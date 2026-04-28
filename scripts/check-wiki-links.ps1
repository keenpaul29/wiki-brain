param(
  [string]$WikiPath
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($WikiPath)) {
  $WikiPath = Join-Path $PSScriptRoot "..\wiki"
}

$WikiRoot = Resolve-Path $WikiPath
$files = @(Get-ChildItem -Recurse -File -Path $WikiRoot -Filter "*.md")
$targets = @{}

foreach ($file in $files) {
  $relativePath = $file.FullName.Substring($WikiRoot.Path.Length + 1).Replace("\", "/")
  $targetPath = $relativePath -replace "\.md$", ""
  $basename = [IO.Path]::GetFileNameWithoutExtension($file.Name)

  $targets[$targetPath] = $true
  $targets[$basename] = $true
}

$missing = @()

foreach ($file in $files) {
  $text = Get-Content -Raw -LiteralPath $file.FullName
  $relativePath = $file.FullName.Substring($WikiRoot.Path.Length + 1).Replace("\", "/")

  [regex]::Matches($text, "\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]") | ForEach-Object {
    $target = $_.Groups[1].Value
    if (-not $targets.ContainsKey($target)) {
      $missing += "$relativePath`: $target"
    }
  }
}

if ($missing.Count) {
  Write-Output "Missing wiki links:"
  $missing | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
  exit 1
}

Write-Output "All wiki links resolved by relative path or basename."
