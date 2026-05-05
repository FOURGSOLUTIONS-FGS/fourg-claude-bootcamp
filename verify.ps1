#Requires -Version 5.1
<#
.SYNOPSIS
    FourG Claude Code Bootcamp - Verificador post-instalacion
.DESCRIPTION
    Chequea que Node, Python, Git y Claude Code esten en el PATH y funcionen.
    Imprime versiones detectadas y un resumen final.
#>

$ErrorActionPreference = 'Continue'

function Write-Check {
    param(
        [string]$Tool,
        [string]$Cmd,
        [string]$Expected = '',
        [switch]$Optional
    )
    try {
        $version = & cmd /c "$Cmd 2>&1"
        if ($LASTEXITCODE -eq 0) {
            $first = ($version | Select-Object -First 1).ToString().Trim()
            Write-Host ("  [OK]  {0,-15} {1}" -f $Tool, $first) -ForegroundColor Green
            return $true
        } else {
            if ($Optional) {
                Write-Host ("  [--]  {0,-15} no instalado (opcional)" -f $Tool) -ForegroundColor DarkGray
                return $true
            }
            Write-Host ("  [XX]  {0,-15} no responde (exit {1})" -f $Tool, $LASTEXITCODE) -ForegroundColor Red
            return $false
        }
    } catch {
        if ($Optional) {
            Write-Host ("  [--]  {0,-15} no instalado (opcional)" -f $Tool) -ForegroundColor DarkGray
            return $true
        }
        Write-Host ("  [XX]  {0,-15} no encontrado en PATH" -f $Tool) -ForegroundColor Red
        return $false
    }
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  Verificacion de instalacion' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# Refrescar PATH por si recien se instalo algo
$machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$user    = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machine;$user"

Write-Host 'Core (requerido):' -ForegroundColor Cyan
$results = @()
$results += Write-Check 'Node.js'     'node --version'
$results += Write-Check 'npm'         'npm --version'
$results += Write-Check 'Python'      'python --version'
$results += Write-Check 'pip'         'pip --version'
$results += Write-Check 'Git'         'git --version'
$results += Write-Check 'Claude Code' 'claude --version'

Write-Host ''
Write-Host 'Infrastructure as Code (opcional):' -ForegroundColor Cyan
$iacResults = @()
$iacResults += Write-Check 'Terraform' 'terraform --version' -Optional
$iacResults += Write-Check 'AWS CLI'   'aws --version'       -Optional

# Si AWS CLI esta instalado, validar credenciales (opcional)
$awsInstalled = (& cmd /c 'aws --version 2>&1'; $LASTEXITCODE -eq 0)
if ($awsInstalled) {
    Write-Host ''
    Write-Host 'Credenciales AWS:' -ForegroundColor Cyan
    & cmd /c 'aws sts get-caller-identity 2>&1' | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $caller = & cmd /c 'aws sts get-caller-identity --query Arn --output text 2>&1'
        Write-Host ("  [OK]  identidad         {0}" -f $caller) -ForegroundColor Green
    } else {
        Write-Host '  [--]  no configuradas    corre: aws configure' -ForegroundColor DarkGray
    }
}

Write-Host ''
$ok    = ($results | Where-Object { $_ -eq $true  }).Count
$total = $results.Count

if ($ok -eq $total) {
    Write-Host "Core: $ok/$total OK" -ForegroundColor Green
    Write-Host 'Todo listo. Podes correr `claude` en tu workspace.' -ForegroundColor Green
} else {
    Write-Host "Core: $ok/$total OK" -ForegroundColor Yellow
    Write-Host 'Hay herramientas faltantes. Tips:' -ForegroundColor Yellow
    Write-Host '  - Cerra y reabri PowerShell para refrescar el PATH.' -ForegroundColor Gray
    Write-Host '  - Si Claude Code no aparece, corre: npm install -g @anthropic-ai/claude-code' -ForegroundColor Gray
    Write-Host '  - Si Node/Python/Git no aparecen, volve a correr install.ps1.' -ForegroundColor Gray
    Write-Host '  - Para mas ayuda: docs/05-troubleshooting.md' -ForegroundColor Gray
}
Write-Host ''
