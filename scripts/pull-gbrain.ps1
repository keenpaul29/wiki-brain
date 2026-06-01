param(
  [switch]$Force
)

$ErrorActionPreference = "Continue"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
cd $Root.Path

Write-Output "=== Step 1: Pulling latest changes from garrytan/master ==="

# Fetch first to ensure we have the latest commits
git fetch garrytan master
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Could not fetch from 'garrytan' remote. Make sure remote is configured."
  exit 1
}

# Start the merge
git merge --no-edit garrytan/master

# Handle merge conflicts automatically
$conflicts = git diff --name-only --diff-filter=U
if ($conflicts) {
  Write-Output "`nDetected conflicts in the following files:"
  foreach ($c in $conflicts) { Write-Output "  - $c" }
  Write-Output "`nResolving core code conflicts automatically using upstream (theirs)..."

  foreach ($file in $conflicts) {
    if ($file.StartsWith("src/") -or 
        $file.StartsWith("test/") -or 
        $file -eq "package.json" -or 
        $file -eq "bun.lock" -or 
        $file -eq "docs/UPGRADING_DOWNSTREAM_AGENTS.md" -or 
        $file -eq "README.md") {
      Write-Output "  -> Checking out upstream version of $file"
      git checkout --theirs $file
      git add $file
    }
  }

  # Resolve .gitignore if conflicted
  $gitIgnorePath = Join-Path $Root ".gitignore"
  if (Test-Path $gitIgnorePath) {
    $content = Get-Content -Raw -Path $gitIgnorePath
    if ($content -match "<<<<<<< HEAD") {
      Write-Output "  -> Resolving conflicts in .gitignore by keeping both sets of rules"
      $lines = Get-Content -Path $gitIgnorePath
      $filteredLines = @()
      foreach ($line in $lines) {
        if ($line -notmatch "^<<<<<<< HEAD" -and 
            $line -notmatch "^=======" -and 
            $line -notmatch "^>>>>>>> garrytan/master") {
          $filteredLines += $line
        }
      }
      Set-Content -Path $gitIgnorePath -Value $filteredLines -Encoding UTF8
      git add .gitignore
    }
  }
  
  # Check if any conflicts are still unresolved
  $remaining = git diff --name-only --diff-filter=U
  if ($remaining) {
    Write-Warning "The following files have conflicts that must be resolved manually:"
    foreach ($r in $remaining) { Write-Warning "  - $r" }
    Write-Warning "Please resolve them, stage them with 'git add', and run 'git commit' to finish the merge."
    exit 1
  }
}

# Commit merge if still in merging state
$mergeHead = Join-Path $Root ".git/MERGE_HEAD"
if (Test-Path $mergeHead) {
  Write-Output "Committing the merge..."
  git commit -m "Merge remote-tracking branch 'garrytan/master' and resolve formatting conflicts"
}

Write-Output "`n=== Step 2: Installing updated dependencies ==="
bun install --ignore-scripts

Write-Output "`n=== Step 3: Applying database migrations ==="
bun run dev apply-migrations --yes

Write-Output "`n=== Step 4: Syncing project source 'brain' into database (self-growing-brain discipline) ==="
bun run dev sync --source brain --no-embed --no-pull

Write-Output "`n=== Step 5: Running health checks ==="
bun run dev doctor

Write-Output "`n=== GBrain pulled and adjusted successfully! ==="
