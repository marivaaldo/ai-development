# Regenerates adr/INDEX.md from the headers of all ADR files.
# Run from the root of a project that uses the ADR pattern.
# Usage: update-adr-index.ps1 [adr-dir]
#
# Reads the first 25 lines of each ADR file to extract:
#   Title, Category, Summary
# Writes adr/INDEX.md with a full table.
param(
    [string]$AdrDir = 'adr'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $AdrDir -PathType Container)) {
    Write-Error "Error: ADR directory not found: $AdrDir"
    exit 1
}

$IndexFile = Join-Path $AdrDir 'INDEX.md'

$header = @"
# ADR Index

| ADR  | Category | Title | Summary |
|------|----------|-------|---------|
"@

Set-Content -Path $IndexFile -Value $header -NoNewline

$files = Get-ChildItem -Path $AdrDir -Filter '*.md' -Recurse |
         Where-Object { $_.Name -ne 'INDEX.md' } |
         Sort-Object Name

foreach ($file in $files) {
    $filename  = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $adrNumber = if ($filename -match '^(\d+)') { $Matches[1] } else { $null }
    if (-not $adrNumber) { continue }

    $lines    = Get-Content $file.FullName | Select-Object -First 25
    $fileText = $lines -join "`n"

    $title    = if ($fileText -match '(?im)^Title:\s*(.+)$')    { $Matches[1].Trim() } else { '(no title)' }
    $category = if ($fileText -match '(?im)^Category:\s*(.+)$') { $Matches[1].Trim() } else { '(no category)' }
    $summary  = if ($fileText -match '(?im)^Summary:\s*(.+)$')  { $Matches[1].Trim() } else { '(no summary)' }

    Add-Content -Path $IndexFile -Value "| $adrNumber | $category | $title | $summary |"
}

Write-Host "INDEX.md regenerated at $IndexFile"
