#Requires -Version 5.1
<#
.SYNOPSIS
    Scaffold de un nuevo proyecto en projects/
.EXAMPLE
    .\shared\scripts\new-project.ps1 mi-sitio
    .\shared\scripts\new-project.ps1 mi-app https://github.com/user/mi-app.git
#>
param(
    [Parameter(Mandatory)] [string]$Name,
    [string]$GitUrl
)

$ErrorActionPreference = 'Stop'

$WorkspaceRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$ProjectsDir   = Join-Path $WorkspaceRoot 'projects'
$Target        = Join-Path $ProjectsDir $Name

if (Test-Path $Target) {
    Write-Error "Ya existe $Target"
    exit 1
}

if (-not (Test-Path $ProjectsDir)) {
    New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null
}

Push-Location $ProjectsDir
try {
    if ($GitUrl) {
        Write-Host "Clonando $GitUrl -> projects/$Name" -ForegroundColor Cyan
        git clone $GitUrl $Name
    } else {
        Write-Host "Creando projects/$Name vacio" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $Name -Force | Out-Null
        Push-Location $Name
        git init -q
        $today = Get-Date -Format 'yyyy-MM-dd'
        @"
# $Name

Proyecto nuevo.

Creado: $today
"@ | Out-File -FilePath 'README.md' -Encoding utf8
        Pop-Location
    }
} finally {
    Pop-Location
}

# Assets folder
$assetsDir = Join-Path $WorkspaceRoot "shared\assets\$Name"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
Write-Host "Assets folder listo: shared/assets/$Name/" -ForegroundColor Green

Write-Host ''
Write-Host 'Listo. Proximos pasos sugeridos:' -ForegroundColor Cyan
Write-Host "  cd projects\$Name"
Write-Host '  claude              # arrancar Claude Code en el proyecto'
