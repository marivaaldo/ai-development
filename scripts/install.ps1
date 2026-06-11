# Installs skills from kit/skills/ into the appropriate location for a given AI provider.
# Usage: .\scripts\install.ps1 [-Provider <claude|gemini|codex|windsurf>] [-Skill <name>]
param(
    [string]$Provider = "",
    [string]$Skill    = ""
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$SkillsDir = Join-Path $RepoRoot 'kit\skills'

# ── helpers ───────────────────────────────────────────────────────────────────

function Prompt-Choice {
    param([string]$Label, [string[]]$Options)
    while ($true) {
        $joined = $Options -join '/'
        $reply = Read-Host "$Label [$joined]"
        if ($Options -contains $reply) { return $reply }
        Write-Host "  Please enter one of: $($Options -join ', ')" -ForegroundColor Yellow
    }
}

function List-Skills {
    Get-ChildItem -Path $SkillsDir -Directory | Select-Object -ExpandProperty Name | Sort-Object
}

# ── detect installed providers ────────────────────────────────────────────────

function Detect-Providers {
    $found = @()
    foreach ($cmd in @('claude','gemini','codex','windsurf')) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) { $found += $cmd }
    }
    return $found
}

# ── provider install functions ────────────────────────────────────────────────

function Install-Claude {
    param([string]$SkillName, [string]$Scope)
    $src  = Join-Path $SkillsDir "$SkillName\skill.md"
    $base = if ($Scope -eq 'global') { Join-Path $HOME '.claude' }
            else                     { Join-Path (Get-Location) '.claude' }

    # commands/ → native slash command (works without superpowers)
    $cmdDest = Join-Path $base "commands\$SkillName.md"
    New-Item -ItemType Directory -Path (Split-Path $cmdDest) -Force | Out-Null
    Copy-Item -Path $src -Destination $cmdDest -Force
    Write-Host "  [OK] Installed to $cmdDest"

    # skills/ → discovery via superpowers Skill tool
    $skillDest = Join-Path $base "skills\$SkillName\skill.md"
    New-Item -ItemType Directory -Path (Split-Path $skillDest) -Force | Out-Null
    Copy-Item -Path $src -Destination $skillDest -Force
    Write-Host "  [OK] Installed to $skillDest"
}

function Install-Gemini {
    param([string]$SkillName, [string]$Scope)
    $src = Join-Path $SkillsDir $SkillName
    $dest = if ($Scope -eq 'global') { Join-Path $HOME '.gemini\skills\' + $SkillName }
            else                     { Join-Path (Get-Location) '.gemini\skills\' + $SkillName }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
    Write-Host "  [OK] Copied skill files to $dest"
    Write-Host ""
    Write-Host "  Manual step required for Gemini CLI:"
    Write-Host "  Reference the skill in your GEMINI.md:"
    Write-Host ""
    Write-Host "    @$dest\skill.md"
    Write-Host ""
    Write-Host "  See kit/references/gemini.md for details."
}

function Install-Windsurf {
    param([string]$SkillName, [string]$Scope)
    $src = Join-Path $SkillsDir $SkillName
    $dest = if ($Scope -eq 'global') { Join-Path $HOME ".codeium\windsurf\skills\$SkillName" }
            else                     { Join-Path (Get-Location) ".windsurf\skills\$SkillName" }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
    Write-Host "  [OK] Installed to $dest"
}

function Install-Codex {
    param([string]$SkillName, [string]$Scope)
    $src = Join-Path $SkillsDir $SkillName
    $dest = if ($Scope -eq 'global') { Join-Path $HOME '.codex\skills\' + $SkillName }
            else                     { Join-Path (Get-Location) '.codex\skills\' + $SkillName }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
    Write-Host "  [OK] Copied skill files to $dest"
    Write-Host ""
    Write-Host "  Manual step required for Codex/Copilot:"
    Write-Host "  Register the skill in your plugin configuration."
    Write-Host "  See kit/references/codex.md for details."
}

# ── main ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== ai-development skill installer ==="
Write-Host ""

# Detect or ask provider
if (-not $Provider) {
    $detected = Detect-Providers
    if ($detected.Count -gt 0) {
        Write-Host "Detected providers: $($detected -join ', ')"
        Write-Host ""
    }
    $Provider = Prompt-Choice "Provider" @('claude','gemini','codex','windsurf')
}

# Ask scope
Write-Host ""
$Scope = Prompt-Choice "Install scope" @('global','project')
if ($Provider -eq 'windsurf') {
    Write-Host "  global = ~/.codeium/windsurf/skills  |  project = ./.windsurf/skills"
} else {
    Write-Host "  global = ~/.$Provider/skills  |  project = ./.$Provider/skills"
}

# Select skill(s)
Write-Host ""
$skillsToInstall = @()
if ($Skill) {
    $skillsToInstall = @($Skill)
} else {
    Write-Host "Available skills:"
    List-Skills | ForEach-Object { Write-Host "  - $_" }
    Write-Host "  - all"
    Write-Host ""
    $input = Read-Host "Skill to install (name or 'all')"
    if ($input -eq 'all') {
        $skillsToInstall = List-Skills
    } else {
        $skillsToInstall = @($input)
    }
}

# Install
Write-Host ""
foreach ($s in $skillsToInstall) {
    $skillPath = Join-Path $SkillsDir $s
    if (-not (Test-Path $skillPath -PathType Container)) {
        Write-Host "  [FAIL] Skill not found: $s" -ForegroundColor Red
        continue
    }
    Write-Host "Installing $s for $Provider ($Scope)..."
    switch ($Provider) {
        'claude' { Install-Claude $s $Scope }
        'gemini' { Install-Gemini $s $Scope }
        'codex'  { Install-Codex  $s $Scope }
        'windsurf'  { Install-Windsurf  $s $Scope }
        default  { Write-Host "  [FAIL] Unknown provider: $Provider" -ForegroundColor Red }
    }
}

Write-Host ""
Write-Host "Done."
