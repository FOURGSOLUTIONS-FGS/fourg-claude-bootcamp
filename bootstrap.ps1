#Requires -Version 5.1
<#
.SYNOPSIS
    FourG Claude Code Bootcamp - Bootstrap remoto (irm | iex)
.DESCRIPTION
    Ejecuta directo desde GitHub:
      irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.ps1 | iex

    Descarga el ZIP del repo, lo descomprime en %TEMP% y lanza install.ps1.
    Ese script (a su vez) instala runtimes, copia scaffold y personaliza CLAUDE.md.
.NOTES
    Autor:   Adrian Garzon - FourG Solutions
    Email:   four4gsolutions@gmail.com
    Version: 1.0.0
#>

$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  FourG Claude Code Bootcamp - Bootstrap' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# 1. Admin check
$current   = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host '  XX  Necesitas PowerShell como Administrador.' -ForegroundColor Red
    Write-Host '      Cerra esta ventana, abri PowerShell con boton derecho > "Ejecutar como administrador" y volve a correr.' -ForegroundColor Gray
    exit 1
}
Write-Host '  OK  Corriendo como Administrador' -ForegroundColor Green

# 2. ExecutionPolicy temporal en el scope del proceso
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    Write-Host '  OK  ExecutionPolicy = Bypass (solo este proceso)' -ForegroundColor Green
} catch {
    Write-Host "  !!  No se pudo ajustar ExecutionPolicy: $_" -ForegroundColor Yellow
}

# 3. TLS 1.2 (algunas versiones de Windows necesitan habilitarlo para GitHub)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 4. Variables
$repoUrl  = 'https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/archive/refs/heads/main.zip'
$tmpRoot  = Join-Path $env:TEMP "fourg-bootcamp-$(Get-Date -Format 'yyyyMMddHHmmss')"
$zipPath  = "$tmpRoot.zip"
$extract  = $tmpRoot
$kitDir   = Join-Path $extract 'fourg-claude-bootcamp-main'

# 5. Descargar ZIP
Write-Host ''
Write-Host "==> Descargando bootcamp ($repoUrl)" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -UseBasicParsing
    $size = [math]::Round((Get-Item $zipPath).Length / 1KB, 1)
    Write-Host "  OK  ZIP descargado ($size KB) -> $zipPath" -ForegroundColor Green
} catch {
    Write-Host "  XX  Falla la descarga: $_" -ForegroundColor Red
    Write-Host '      Verifica conexion a internet o si GitHub esta accesible.' -ForegroundColor Gray
    exit 1
}

# 6. Descomprimir
Write-Host ''
Write-Host "==> Descomprimiendo en $extract" -ForegroundColor Cyan
try {
    if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
    Expand-Archive -Path $zipPath -DestinationPath $extract -Force
    Write-Host '  OK  Listo' -ForegroundColor Green
} catch {
    Write-Host "  XX  Falla descompresion: $_" -ForegroundColor Red
    exit 1
}

# 7. Lanzar install.ps1
$installer = Join-Path $kitDir 'install.ps1'
if (-not (Test-Path $installer)) {
    Write-Host "  XX  No se encontro $installer" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '==> Lanzando install.ps1 (preguntara workspace, nombre, etc.)' -ForegroundColor Cyan
Write-Host ''

Push-Location $kitDir
try {
    & $installer
} finally {
    Pop-Location
}

Write-Host ''
Write-Host "Tip: el bootcamp quedo en $kitDir (lo podes borrar despues)." -ForegroundColor DarkGray
Write-Host ''
