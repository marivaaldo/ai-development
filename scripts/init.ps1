# Copies the example/ project structure into a target directory and appends
# provider fragments into the project's agent config file.
# Usage: .\scripts\init.ps1 <target-directory>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Target
)

$ErrorActionPreference = 'Stop'

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot     = Split-Path -Parent $ScriptDir
$ExampleDir   = Join-Path $RepoRoot 'example'
$FragmentsDir = Join-Path $RepoRoot 'kit\fragments'

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

# Append all available fragments for each detected provider
function Append-ProviderFragments {
    param([string]$Provider)

    $configFile = switch ($Provider) {
        'claude'   { Join-Path $Target 'CLAUDE.md' }
        'gemini'   { Join-Path $Target 'GEMINI.md' }
        'windsurf' { Join-Path $Target '.windsurfrules' }
        'codex'    { Join-Path $Target 'AGENTS.md' }
        default    { return }
    }

    Get-ChildItem -Path $FragmentsDir -Filter "*.$Provider.md" | ForEach-Object {
        $fragment = $_.FullName
        $lines    = Get-Content $fragment

        $marker = ($lines | Where-Object { $_ -match '^#' } | Select-Object -First 1) -replace '^#+ *', ''
        if (-not $marker) { $marker = ($lines | Select-Object -Skip 1 -First 1).Trim() }

        if ((Test-Path $configFile) -and (Select-String -Path $configFile -SimpleMatch $marker -Quiet)) {
            Write-Host "  ↳ Fragment already present in $(Split-Path $configFile -Leaf), skipping"
            return
        }

        Add-Content -Path $configFile -Value (Get-Content $fragment -Raw)
        Write-Host "  ✓ Appended $($_.Name) to $(Split-Path $configFile -Leaf)"
    }
}

Write-Host ""
Write-Host "Appending fragments..."
foreach ($provider in @('claude', 'gemini', 'codex', 'windsurf')) {
    if (-not (Get-Command $provider -ErrorAction SilentlyContinue)) { continue }
    Write-Host "  Provider: $provider"
    Append-ProviderFragments -Provider $provider
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review docs/guide.md for the maturity roadmap"
Write-Host "  2. Run install.ps1 to install skills: .\scripts\install.ps1 -Provider <name> -Skill all"
Write-Host "  3. Start with Phase 0 — don't create structure you don't need yet"
