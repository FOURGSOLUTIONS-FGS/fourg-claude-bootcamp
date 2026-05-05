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
    param([string]$Tool, [string]$Cmd, [string]$Expected = '')
    try {
        $version = & cmd /c "$Cmd 2>&1"
        if ($LASTEXITCODE -eq 0) {
            $first = ($version | Select-Object -First 1).ToString().Trim()
            Write-Host ("  [OK]  {0,-15} {1}" -f $Tool, $first) -ForegroundColor Green
            return $true
        } else {
            Write-Host ("  [XX]  {0,-15} no responde (exit {1})" -f $Tool, $LASTEXITCODE) -ForegroundColor Red
            return $false
        }
    } catch {
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

$results = @()
$results += Write-Check 'Node.js'     'node --version'
$results += Write-Check 'npm'         'npm --version'
$results += Write-Check 'Python'      'python --version'
$results += Write-Check 'pip'         'pip --version'
$results += Write-Check 'Git'         'git --version'
$results += Write-Check 'Claude Code' 'claude --version'

Write-Host ''
$ok    = ($results | Where-Object { $_ -eq $true  }).Count
$total = $results.Count

if ($ok -eq $total) {
    Write-Host "Resultado: $ok/$total OK" -ForegroundColor Green
    Write-Host 'Todo listo. Podes correr `claude` en tu workspace.' -ForegroundColor Green
} else {
    Write-Host "Resultado: $ok/$total OK" -ForegroundColor Yellow
    Write-Host 'Hay herramientas faltantes. Tips:' -ForegroundColor Yellow
    Write-Host '  - Cerra y reabri PowerShell para refrescar el PATH.' -ForegroundColor Gray
    Write-Host '  - Si Claude Code no aparece, corre: npm install -g @anthropic-ai/claude-code' -ForegroundColor Gray
    Write-Host '  - Si Node/Python/Git no aparecen, volve a correr install.ps1.' -ForegroundColor Gray
    Write-Host '  - Para mas ayuda: docs/05-troubleshooting.md' -ForegroundColor Gray
}
Write-Host ''
