#Requires -Version 5.1
<#
.SYNOPSIS
    FourG Claude Code Bootcamp - Instalador Windows
.DESCRIPTION
    Instala Node LTS, Python 3.12, Git, VS Code (opcional), Claude Code,
    y crea un workspace estructurado tipo FourG con CLAUDE.md personalizado.
.PARAMETER Express
    Modo desatendido: usa todos los defaults / params sin preguntar nada.
    Ideal para CI o instalaciones masivas.
.PARAMETER Workspace
    Path donde crear el workspace. Default: C:\TRABAJOS
.PARAMETER UserName
    Nombre del usuario para el CLAUDE.md.
.PARAMETER Company
    Empresa o marca personal.
.PARAMETER Email
    Email del usuario.
.PARAMETER VSCode
    Si instalar VS Code. Default: $true.
.PARAMETER IaC
    Si instalar Terraform + AWS CLI. Default: $false.
.PARAMETER SkipLogin
    No lanzar `claude` al final para login (util en CI).
.EXAMPLE
    .\install.ps1
    # Modo interactivo (te pregunta todo)
.EXAMPLE
    .\install.ps1 -Express -UserName "Juan Perez" -Company "JP" -Email "juan@jp.com"
    # Modo express con datos minimos
.NOTES
    Autor:   Adrian Garzon - FourG Solutions
    Email:   four4gsolutions@gmail.com
    Web:     www.fourgsolutions.com
    Version: 1.1.0
    Fecha:   2026-05-04
#>
param(
    [switch]$Express,
    [string]$Workspace = '',
    [string]$UserName  = '',
    [string]$Company   = '',
    [string]$Email     = '',
    [Nullable[bool]]$VSCode    = $null,
    [Nullable[bool]]$IaC       = $null,
    [switch]$SkipLogin
)

$ErrorActionPreference = 'Stop'
$Script:KitVersion = '1.1.0'
$Script:KitRoot = $PSScriptRoot

# ---------------------------------------------------------------------------
# Helpers de UI
# ---------------------------------------------------------------------------
function Write-Banner {
    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host '  FourG Claude Code Bootcamp - Instalador Windows' -ForegroundColor Cyan
    Write-Host "  v$Script:KitVersion - FourG Solutions" -ForegroundColor DarkCyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Write-Step    { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok      { param($Msg) Write-Host "    OK  $Msg" -ForegroundColor Green }
function Write-Warn    { param($Msg) Write-Host "    !!  $Msg" -ForegroundColor Yellow }
function Write-Fail    { param($Msg) Write-Host "    XX  $Msg" -ForegroundColor Red }
function Write-Info    { param($Msg) Write-Host "    -   $Msg" -ForegroundColor Gray }

function Read-Default {
    param([string]$Prompt, [string]$Default)
    $input = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($input)) { return $Default }
    return $input
}

function Read-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    $hint = if ($Default) { 'Y/n' } else { 'y/N' }
    $input = Read-Host "$Prompt [$hint]"
    if ([string]::IsNullOrWhiteSpace($input)) { return $Default }
    return ($input -match '^[yYsS]')
}

# ---------------------------------------------------------------------------
# Pre-checks
# ---------------------------------------------------------------------------
function Test-Admin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Test-Winget {
    try { winget --version > $null 2>&1; return $true } catch { return $false }
}

# ---------------------------------------------------------------------------
# Instaladores con winget (idempotentes)
# ---------------------------------------------------------------------------
function Install-WithWinget {
    param(
        [Parameter(Mandatory)] [string]$Id,
        [Parameter(Mandatory)] [string]$DisplayName
    )
    $installed = winget list --id $Id --exact 2>$null | Select-String -Pattern $Id -Quiet
    if ($installed) {
        Write-Ok "$DisplayName ya instalado"
        return $true
    }
    Write-Info "Instalando $DisplayName ..."
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$DisplayName instalado"
        return $true
    } else {
        Write-Fail "$DisplayName fallo (exit $LASTEXITCODE)"
        return $false
    }
}

# ---------------------------------------------------------------------------
# Refrescar PATH en la sesion actual
# ---------------------------------------------------------------------------
function Update-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

# ---------------------------------------------------------------------------
# Copiar scaffold + reemplazar placeholders
# ---------------------------------------------------------------------------
function Copy-Scaffold {
    param(
        [Parameter(Mandatory)] [string]$Source,
        [Parameter(Mandatory)] [string]$Target,
        [Parameter(Mandatory)] [hashtable]$Vars
    )

    if (-not (Test-Path $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
    }

    Copy-Item -Path "$Source\*" -Destination $Target -Recurse -Force

    # Renombrar CLAUDE.md.template -> CLAUDE.md y reemplazar placeholders
    $templateFile = Join-Path $Target 'CLAUDE.md.template'
    $finalFile    = Join-Path $Target 'CLAUDE.md'
    if (Test-Path $templateFile) {
        $content = Get-Content $templateFile -Raw -Encoding UTF8
        foreach ($key in $Vars.Keys) {
            $content = $content -replace [regex]::Escape("{{$key}}"), $Vars[$key]
        }
        # Escribir con UTF-8 BOM (regla del workspace para .ps1; aca por consistencia con vault)
        [System.IO.File]::WriteAllText(
            $finalFile,
            $content,
            [System.Text.UTF8Encoding]::new($true)
        )
        Remove-Item $templateFile -Force
    }
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
Write-Banner

# 1. Admin check (skip en CI: el runner ya tiene permisos suficientes)
if ($env:CI) {
    Write-Ok 'CI detectado ($env:CI definido) - skip admin check'
} elseif (-not (Test-Admin)) {
    Write-Fail 'Este script necesita PowerShell como Administrador.'
    Write-Info  'Cerra esta ventana, abri PowerShell con boton derecho > "Ejecutar como administrador" y volve a correr.'
    exit 1
} else {
    Write-Ok 'Corriendo como Administrador'
}

# 2. Winget check
if (-not (Test-Winget)) {
    Write-Fail 'No se encontro winget. Instalalo desde Microsoft Store > "App Installer" y volve a correr.'
    exit 1
}
Write-Ok 'winget disponible'

# 3. Inputs del usuario
Write-Host ''
Write-Step 'Configuracion del workspace'

if ($Express) {
    Write-Ok 'Modo Express: usando params/defaults sin preguntar'
    $workspace  = if ($Workspace) { $Workspace } else { 'C:\TRABAJOS' }
    $userName   = if ($UserName)  { $UserName }  else { 'Bootcamp User' }
    $company    = if ($Company)   { $Company }   else { 'FourG Solutions' }
    $email      = if ($Email)     { $Email }     else { 'user@example.com' }
    $installVS  = if ($null -ne $VSCode) { $VSCode } else { $true }
    $installIaC = if ($null -ne $IaC)    { $IaC }    else { $false }
} else {
    $workspace  = if ($Workspace) { $Workspace } else { Read-Default 'Donde queres crear el workspace?' 'C:\TRABAJOS' }
    $userName   = if ($UserName)  { $UserName }  else { Read-Default 'Tu nombre completo' 'Mi Nombre' }
    $company    = if ($Company)   { $Company }   else { Read-Default 'Tu empresa o marca personal' 'Mi Empresa' }
    $email      = if ($Email)     { $Email }     else { Read-Default 'Tu email' 'mi@email.com' }
    $installVS  = if ($null -ne $VSCode) { $VSCode } else { Read-YesNo 'Instalar VS Code?' $true }
    $installIaC = if ($null -ne $IaC)    { $IaC }    else { Read-YesNo 'Instalar Terraform + AWS CLI (modulo Infrastructure as Code)?' $false }
}

Write-Host ''
Write-Info "Workspace : $workspace"
Write-Info "Usuario   : $userName ($email)"
Write-Info "Empresa   : $company"
Write-Info "VS Code   : $(if ($installVS) { 'si' } else { 'no' })"
Write-Info "IaC       : $(if ($installIaC) { 'si (Terraform + AWS CLI)' } else { 'no (lo podes instalar despues)' })"
Write-Host ''

if (-not $Express) {
    if (-not (Read-YesNo 'Confirmar y continuar?' $true)) {
        Write-Warn 'Cancelado por el usuario.'
        exit 0
    }
}

# 4. Instalar runtimes
Write-Host ''
Write-Step 'Instalando runtimes (puede tardar varios minutos)'

$ok = $true
$ok = (Install-WithWinget -Id 'OpenJS.NodeJS.LTS'  -DisplayName 'Node.js LTS')   -and $ok
$ok = (Install-WithWinget -Id 'Python.Python.3.12' -DisplayName 'Python 3.12')   -and $ok
$ok = (Install-WithWinget -Id 'Git.Git'            -DisplayName 'Git for Windows') -and $ok
if ($installVS) {
    $ok = (Install-WithWinget -Id 'Microsoft.VisualStudioCode' -DisplayName 'Visual Studio Code') -and $ok
}
if ($installIaC) {
    $ok = (Install-WithWinget -Id 'HashiCorp.Terraform' -DisplayName 'Terraform') -and $ok
    $ok = (Install-WithWinget -Id 'Amazon.AWSCLI'      -DisplayName 'AWS CLI v2')  -and $ok
}

if (-not $ok) {
    Write-Warn 'Algunas instalaciones fallaron. Revisa los mensajes y volve a correr.'
}

Update-Path

# 5. Instalar Claude Code via npm
Write-Host ''
Write-Step 'Instalando Claude Code (npm global)'
try {
    $claudeInstalled = (npm list -g --depth=0 2>$null | Select-String '@anthropic-ai/claude-code' -Quiet)
    if ($claudeInstalled) {
        Write-Ok 'Claude Code ya instalado'
    } else {
        npm install -g '@anthropic-ai/claude-code'
        if ($LASTEXITCODE -eq 0) { Write-Ok 'Claude Code instalado' } else { Write-Fail 'npm install fallo' }
    }
} catch {
    Write-Fail "Error instalando Claude Code: $_"
    Write-Info 'Asegurate de que npm este en el PATH (cerra y reabri PowerShell si recien instalaste Node).'
}

# 6. Crear workspace y copiar scaffold
Write-Host ''
Write-Step "Creando workspace en $workspace"

$scaffoldSrc = Join-Path $Script:KitRoot 'scaffold'
if (-not (Test-Path $scaffoldSrc)) {
    Write-Fail "No se encontro la carpeta scaffold/ en $Script:KitRoot"
    exit 1
}

if (Test-Path $workspace) {
    Write-Warn "El directorio $workspace ya existe."
    if (-not (Read-YesNo 'Mezclar contenido? (no se sobreescriben archivos existentes salvo el CLAUDE.md template)' $false)) {
        Write-Warn 'Cancelado.'
        exit 0
    }
}

$vars = @{
    NOMBRE  = $userName
    EMPRESA = $company
    EMAIL   = $email
    FECHA   = (Get-Date -Format 'yyyy-MM-dd')
}

Copy-Scaffold -Source $scaffoldSrc -Target $workspace -Vars $vars
Write-Ok "Scaffold copiado y CLAUDE.md personalizado"

# 7. Login Claude Code
if ($SkipLogin -or $Express) {
    Write-Host ''
    Write-Info 'Login skippeado. Para autenticarte despues:  cd $workspace ; claude'
} else {
    Write-Host ''
    Write-Step 'Autenticando Claude Code con tu cuenta'
    Write-Info  'Se va a abrir tu navegador para login. Usa tu cuenta de Anthropic (gratis o paga).'
    Write-Info  'Si todavia no tenes cuenta, registrate en https://console.anthropic.com'
    Write-Host ''
    $doLogin = Read-YesNo 'Lanzar `claude` ahora para hacer login?' $true
    if ($doLogin) {
        Push-Location $workspace
        try {
            & claude
        } catch {
            Write-Warn "No se pudo lanzar claude desde aca. Cerra y abri una nueva PowerShell, ejecuta: cd $workspace && claude"
        }
        Pop-Location
    }
}

# 8. Verificacion final
Write-Host ''
Write-Step 'Verificando instalacion'
$verify = Join-Path $Script:KitRoot 'verify.ps1'
if (Test-Path $verify) {
    & $verify
}

# 9. Cierre
Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '  Listo. Tu workspace esta en:' -ForegroundColor Green
Write-Host "  $workspace" -ForegroundColor White
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Proximos pasos:' -ForegroundColor Cyan
Write-Host "  1. cd $workspace"
Write-Host '  2. claude            # arrancar Claude Code'
Write-Host '  3. Leer docs/01-instalacion.md y docs/02-primer-proyecto.md del kit'
if ($installIaC) {
    Write-Host ''
    Write-Host 'IaC instalado:' -ForegroundColor Cyan
    Write-Host '  - Templates Terraform y CloudFormation en `scaffold/infra/`'
    Write-Host '  - Configura credenciales AWS:  aws configure'
    Write-Host '  - Doc: docs/06-iac-terraform-cloudformation.md'
}
Write-Host ''
Write-Host 'Soporte: four4gsolutions@gmail.com' -ForegroundColor DarkGray
Write-Host ''
