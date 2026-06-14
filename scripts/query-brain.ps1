param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Query,
  [int]$TopK = 5,
  [switch]$Raw
)

$ErrorActionPreference = "Stop"

if (-not $Query) {
  Write-Error "Usage: .\scripts\query-brain.ps1 <query> [-TopK N] [-Raw]"
  exit 1
}

Write-Output "=== GBrain Query ==="
Write-Output "Query: $Query"
Write-Output "Top-K: $TopK"
Write-Output ""

$results = gbrain query $Query --top-k $TopK 2>&1
if (-not $results -or $results.Count -eq 0) {
  Write-Output "No results found."
  exit 0
}

$i = 0
foreach ($line in $results) {
  if ($line -match '^\[([\d.]+)\]\s+(.+)$') {
    $i++
    if ($i -gt $TopK) { break }
    $score = [double]$matches[1]
    $path = $matches[2].Trim()
    $pct = if ($score -ge 1) { [math]::Round($score * 100, 1) } else { [math]::Round($score * 100, 1) }

    if ($path -match '^wiki/') {
      $display = "wiki/$($path.Substring(5))"
    } elseif ($path -match '^raw/') {
      $display = "raw/$($path.Substring(4))"
    } else {
      $display = $path
    }
    if ($display.Length -gt 70) { $display = $display.Substring(0, 67) + "..." }

    Write-Output "[$i] $pct%  $display"
  }
}

if ($i -eq 0) {
  Write-Output "(unable to parse results)"
  Write-Output $results
}
Write-Output ""
Write-Output "=== End ==="
