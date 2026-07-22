# Installs skills from kit/skills/ into the appropriate location for a given AI provider.
# Usage: .\scripts\install.ps1 [-Provider <claude|gemini|codex|windsurf>] [-Skill "<name> [<name> ...]"]
param(
    [string]$Provider = "",
    [string]$Skill    = "",
    [string]$Scope    = ""
)

$ErrorActionPreference = 'Stop'

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot     = Split-Path -Parent $ScriptDir
$SkillsDir    = Join-Path $RepoRoot 'kit\skills'
$FragmentsDir = Join-Path $RepoRoot 'kit\fragments'

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
    foreach ($cmd in @('claude','gemini','codex')) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) { $found += $cmd }
    }
    # Windsurf is an IDE and does not install a CLI binary — cannot be auto-detected
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
    $dest = if ($Scope -eq 'global') { Join-Path $HOME '.gemini' 'skills' $SkillName }
            else                     { Join-Path (Get-Location) '.gemini' 'skills' $SkillName }
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
    $dest = if ($Scope -eq 'global') { Join-Path $HOME '.codex' 'skills' $SkillName }
            else                     { Join-Path (Get-Location) '.codex' 'skills' $SkillName }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
    Write-Host "  [OK] Copied skill files to $dest"
    Write-Host ""
    Write-Host "  Manual step required for Codex/Copilot:"
    Write-Host "  Register the skill in your plugin configuration."
    Write-Host "  See kit/references/codex.md for details."
}

# ── fragment append ───────────────────────────────────────────────────────────

function Get-FragmentGroup {
    param([string]$SkillName)
    switch -Wildcard ($SkillName) {
        'adr-*'             { return 'adr' }
        'architecture-review' { return 'adr' }
        'ddd-*'             { return 'ddd' }
        'ca-*'              { return 'clean-architecture' }
        'eng-*'             { return 'engineering' }
        'code-review'       { return 'engineering' }
        'ai-*'              { return 'ai' }
        default             { return $SkillName }
    }
}

function Append-Fragments {
    # Idempotent: skips if the fragment marker (first heading text) is already present.
    # Limitation: if a fragment is updated and its first heading changes, re-running install
    # will append the new version without removing the old one. Resolve manually by editing
    # the config file to remove the outdated fragment block before re-running.
    param([string]$SkillName, [string]$ProviderName, [string]$Scope)

    if ($Scope -ne 'project') { return }

    $group    = Get-FragmentGroup $SkillName
    $fragment = Join-Path $FragmentsDir "${group}.${ProviderName}.md"
    if (-not (Test-Path $fragment)) { return }

    $configFile = switch ($ProviderName) {
        'claude'   { Join-Path (Get-Location) 'CLAUDE.md' }
        'gemini'   { Join-Path (Get-Location) 'GEMINI.md' }
        'windsurf' { Join-Path (Get-Location) '.windsurfrules' }
        'codex'    { Join-Path (Get-Location) 'AGENTS.md' }
        default    { return }
    }

    $fragmentContent = Get-Content $fragment -Raw
    $marker = ($fragmentContent -split "`n" | Where-Object { $_ -match '^#' } | Select-Object -First 1) -replace '^#+ *', ''
    if (-not $marker) {
        $marker = ($fragmentContent -split "`n" | Select-Object -Skip 1 -First 1).Trim()
    }

    $existing = if (Test-Path $configFile) { Get-Content $configFile -Raw } else { '' }
    if ($existing -and $existing.Contains($marker)) {
        Write-Host "  [SKIP] Fragment already present in $(Split-Path $configFile -Leaf)"
        return
    }

    Add-Content -Path $configFile -Value $fragmentContent
    Write-Host "  [OK] Appended fragment to $(Split-Path $configFile -Leaf)"
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

# Ask scope if not supplied via -Scope
Write-Host ""
if (-not $Scope) {
    $Scope = Prompt-Choice "Install scope" @('global','project')
}
if ($Provider -eq 'windsurf') {
    Write-Host "  global = ~/.codeium/windsurf/skills  |  project = ./.windsurf/skills"
} else {
    Write-Host "  global = ~/.$Provider/skills  |  project = ./.$Provider/skills"
}

# Select skill(s)
Write-Host ""
$skillsToInstall = @()
if ($Skill) {
    $skillsToInstall = @($Skill -split '\s+' | Where-Object { $_ })
} else {
    Write-Host "Available skills:"
    List-Skills | ForEach-Object { Write-Host "  - $_" }
    Write-Host "  - all"
    Write-Host ""
    $input = Read-Host "Skill to install (name or 'all', space-separated for multiple)"
    $skillsToInstall = @($input -split '\s+' | Where-Object { $_ })
}

# Resolve "all" regardless of whether it came from -Skill flag or interactive input
if ($skillsToInstall.Count -eq 1 -and $skillsToInstall[0] -eq 'all') {
    $skillsToInstall = List-Skills
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
    Append-Fragments $s $Provider $Scope
}

Write-Host ""
Write-Host "Done."
