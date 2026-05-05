#Requires -Version 5.1
<#
.SYNOPSIS
    FourG Claude Code Bootcamp - Bootstrap remoto (irm | iex)
.DESCRIPTION
    Ejecuta directo desde GitHub (modo interactivo):
      irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.ps1 | iex

    Descarga el ZIP del repo, lo descomprime en %TEMP% y lanza install.ps1.
    Ese script (a su vez) instala runtimes, copia scaffold y personaliza CLAUDE.md.

    Modo Express (desatendido) — setear variables de entorno ANTES:
      $env:FGB_EXPRESS = '1'
      $env:FGB_NAME    = 'Juan Perez'
      $env:FGB_EMAIL   = 'juan@jp.com'
      irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.ps1 | iex

    Variables de entorno soportadas:
      FGB_EXPRESS      '1' o 'true' para modo desatendido
      FGB_WORKSPACE    Path del workspace (default: C:\TRABAJOS)
      FGB_NAME         Nombre del usuario
      FGB_COMPANY      Empresa o marca
      FGB_EMAIL        Email
      FGB_VSCODE       '1' o '0' para instalar/saltar VS Code
      FGB_IAC          '1' o '0' para instalar/saltar Terraform + AWS CLI
      FGB_SKIP_LOGIN   '1' para no lanzar `claude` al final
.NOTES
    Autor:   Adrian Garzon - FourG Solutions
    Email:   four4gsolutions@gmail.com
    Version: 1.1.1
#>

# Nota: NO usamos param() porque rompe `irm | iex` (Invoke-Expression no
# procesa bloques param). Los argumentos se reciben via env vars FGB_*.

$ErrorActionPreference = 'Stop'

# Mapear env vars FGB_* a variables locales
$Express   = ($env:FGB_EXPRESS    -in @('1','true','True','TRUE','yes','y'))
$Workspace = if ($env:FGB_WORKSPACE) { $env:FGB_WORKSPACE } else { '' }
$UserName  = if ($env:FGB_NAME)      { $env:FGB_NAME }      else { '' }
$Company   = if ($env:FGB_COMPANY)   { $env:FGB_COMPANY }   else { '' }
$Email     = if ($env:FGB_EMAIL)     { $env:FGB_EMAIL }     else { '' }
$VSCode    = switch ($env:FGB_VSCODE)    { '1' { $true } '0' { $false } default { $null } }
$IaC       = switch ($env:FGB_IAC)       { '1' { $true } '0' { $false } default { $null } }
$SkipLogin = ($env:FGB_SKIP_LOGIN -in @('1','true','True'))

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  FourG Claude Code Bootcamp - Bootstrap' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# 1. Admin check (skip en CI)
if ($env:CI) {
    Write-Host '  OK  CI detectado - skip admin check' -ForegroundColor Green
} else {
    $current   = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host '  XX  Necesitas PowerShell como Administrador.' -ForegroundColor Red
        Write-Host '      Cerra esta ventana, abri PowerShell con boton derecho > "Ejecutar como administrador" y volve a correr.' -ForegroundColor Gray
        exit 1
    }
    Write-Host '  OK  Corriendo como Administrador' -ForegroundColor Green
}

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
Write-Host '==> Lanzando install.ps1' -ForegroundColor Cyan
Write-Host ''

# Forward los params recibidos al installer
$installerArgs = @{}
if ($Express)            { $installerArgs.Express   = $true }
if ($Workspace)          { $installerArgs.Workspace = $Workspace }
if ($UserName)           { $installerArgs.UserName  = $UserName }
if ($Company)            { $installerArgs.Company   = $Company }
if ($Email)              { $installerArgs.Email     = $Email }
if ($null -ne $VSCode)   { $installerArgs.VSCode    = $VSCode }
if ($null -ne $IaC)      { $installerArgs.IaC       = $IaC }
if ($SkipLogin)          { $installerArgs.SkipLogin = $true }

Push-Location $kitDir
try {
    & $installer @installerArgs
} finally {
    Pop-Location
}

Write-Host ''
Write-Host "Tip: el bootcamp quedo en $kitDir (lo podes borrar despues)." -ForegroundColor DarkGray
Write-Host ''
