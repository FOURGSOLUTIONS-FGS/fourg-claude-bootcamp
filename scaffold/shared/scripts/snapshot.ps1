#Requires -Version 5.1
<#
.SYNOPSIS
    Crea un snapshot zippeado de un proyecto en archive/YYYY-MM-DD/
.EXAMPLE
    .\shared\scripts\snapshot.ps1 mi-sitio
#>
param(
    [Parameter(Mandatory)] [string]$ProjectName
)

$ErrorActionPreference = 'Stop'

$WorkspaceRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$ProjectDir    = Join-Path $WorkspaceRoot "projects\$ProjectName"

if (-not (Test-Path $ProjectDir)) {
    Write-Error "No existe $ProjectDir"
    exit 1
}

$Date       = Get-Date -Format 'yyyy-MM-dd'
$ArchiveDir = Join-Path $WorkspaceRoot "archive\$Date"
$ZipPath    = Join-Path $ArchiveDir "$ProjectName-snapshot-$Date.zip"

if (-not (Test-Path $ArchiveDir)) {
    New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
}

Write-Host "Creando snapshot de $ProjectName -> $ZipPath" -ForegroundColor Cyan

# Excluir node_modules, .next, dist, .turbo, .venv, __pycache__
$exclude = @('node_modules', '.next', 'dist', '.turbo', 'tmp', '.venv', '__pycache__')

$tmp = Join-Path $env:TEMP "snap-$ProjectName-$Date"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

robocopy $ProjectDir (Join-Path $tmp $ProjectName) /E /XD $exclude /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null

Compress-Archive -Path (Join-Path $tmp $ProjectName) -DestinationPath $ZipPath -Force
Remove-Item $tmp -Recurse -Force

$size = (Get-Item $ZipPath).Length / 1MB
Write-Host ("OK ({0:N2} MB) -> {1}" -f $size, $ZipPath) -ForegroundColor Green
