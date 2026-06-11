# Copies the example/ project structure into a target directory.
# Usage: .\scripts\init.ps1 <target-directory>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Target
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$ExampleDir = Join-Path $RepoRoot 'example'

if (-not (Test-Path $ExampleDir -PathType Container)) {
    Write-Error "Error: example/ directory not found at $ExampleDir"
    exit 1
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null

Get-ChildItem -Path $ExampleDir -Recurse | Where-Object {
    -not $_.PSIsContainer -and
    $_.Name -ne 'README.md' -and
    $_.Name -ne '.gitkeep'
} | ForEach-Object {
    $rel  = $_.FullName.Substring($ExampleDir.Length + 1)
    $dest = Join-Path $Target $rel
    $dir  = Split-Path $dest -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
}

Write-Host "Project structure initialized at: $Target"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review docs/guide.md for the maturity roadmap"
Write-Host "  2. Install skills: .\scripts\install.ps1"
Write-Host "  3. Start with Phase 0 — don't create structure you don't need yet"
