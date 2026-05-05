#Requires -Version 5.1
<#
.SYNOPSIS
    Instala skills recomendadas en ~/.claude/skills/
.DESCRIPTION
    Instala find-skills (la skill que descubre/instala otras skills)
    y opcionalmente otras skills curadas por FourG.

    Uso:
      .\install-skills.ps1            # interactivo, te pregunta cuales
      .\install-skills.ps1 -All       # instala todas las recomendadas sin preguntar
      .\install-skills.ps1 -ListOnly  # solo lista las disponibles, no instala
.NOTES
    Requiere git instalado (lo trae el bootcamp).
#>
param(
    [switch]$All,
    [switch]$ListOnly
)

$ErrorActionPreference = 'Stop'

# -----------------------------------------------------------------------------
# Catalogo curado por FourG
# -----------------------------------------------------------------------------
$skills = @(
    @{
        Name        = 'find-skills'
        Description = 'Descubre e instala otras skills via `npx skills find <query>`'
        Repo        = 'https://github.com/vercel-labs/skills.git'
        Subpath     = 'skills/find-skills'
        Recommended = $true
    },
    @{
        Name        = 'polish'
        Description = 'Review final UI/UX: alignment, spacing, transitions, WCAG AA'
        Repo        = 'https://github.com/pbakaus/impeccable.git'
        Subpath     = ''
        Recommended = $true
    }
)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
function Write-Step { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param($Msg) Write-Host "    OK  $Msg" -ForegroundColor Green }
function Write-Warn { param($Msg) Write-Host "    !!  $Msg" -ForegroundColor Yellow }
function Write-Fail { param($Msg) Write-Host "    XX  $Msg" -ForegroundColor Red }

function Install-Skill {
    param([hashtable]$Skill)

    $target = Join-Path $env:USERPROFILE ".claude\skills\$($Skill.Name)"

    if (Test-Path $target) {
        Write-Warn "$($Skill.Name) ya esta instalado en $target"
        return $true
    }

    Write-Step "Instalando $($Skill.Name)"
    Write-Host "    $($Skill.Description)" -ForegroundColor Gray

    $tmp = Join-Path $env:TEMP "skill-$($Skill.Name)-$(Get-Random)"
    try {
        git clone --depth 1 --quiet $Skill.Repo $tmp
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "git clone fallo"
            return $false
        }

        New-Item -ItemType Directory -Path $target -Force | Out-Null

        $sourcePath = if ($Skill.Subpath) { Join-Path $tmp $Skill.Subpath } else { $tmp }
        Copy-Item -Path "$sourcePath\*" -Destination $target -Recurse -Force -Exclude '.git'

        Write-Ok "$($Skill.Name) instalado en $target"
        return $true
    } catch {
        Write-Fail "Error: $_"
        return $false
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  FourG Claude Code Bootcamp - Install Skills' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# Validar git
try { git --version | Out-Null } catch {
    Write-Fail 'git no esta instalado. Instalalo con: winget install Git.Git'
    exit 1
}

# Listar
Write-Host 'Skills disponibles:' -ForegroundColor Cyan
$i = 0
foreach ($s in $skills) {
    $i++
    $rec = if ($s.Recommended) { '[recomendada]' } else { '' }
    Write-Host ("  {0}. {1,-30} {2}" -f $i, $s.Name, $rec) -ForegroundColor White
    Write-Host ("     {0}" -f $s.Description) -ForegroundColor Gray
}
Write-Host ''

if ($ListOnly) {
    Write-Host 'Mas skills curadas en https://skills.sh' -ForegroundColor DarkGray
    exit 0
}

# Decidir cuales instalar
$toInstall = @()
if ($All) {
    $toInstall = $skills
} else {
    $resp = Read-Host 'Que instalar? (a=todas, r=solo recomendadas, lista de numeros separados por coma, vacio=cancelar)'
    switch -Regex ($resp) {
        '^[aA]' { $toInstall = $skills }
        '^[rR]' { $toInstall = $skills | Where-Object { $_.Recommended } }
        '^[\d,\s]+$' {
            $nums = $resp -split '\s*,\s*' | Where-Object { $_ } | ForEach-Object { [int]$_ }
            $toInstall = $nums | ForEach-Object {
                if ($_ -ge 1 -and $_ -le $skills.Count) { $skills[$_ - 1] }
            }
        }
        default { Write-Warn 'Cancelado.'; exit 0 }
    }
}

if ($toInstall.Count -eq 0) {
    Write-Warn 'Nada que instalar.'
    exit 0
}

Write-Host ''
Write-Step "Instalando $($toInstall.Count) skill(s)..."
Write-Host ''

$ok = 0
foreach ($s in $toInstall) {
    if (Install-Skill -Skill $s) { $ok++ }
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host "  $ok / $($toInstall.Count) instaladas" -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Para descubrir mas skills:' -ForegroundColor Cyan
Write-Host '  npx skills find "<query>"     # ej: "postgres", "design", "video"' -ForegroundColor White
Write-Host '  npx skills add owner/repo@skill-name' -ForegroundColor White
Write-Host ''
Write-Host 'Catalogo completo: https://skills.sh' -ForegroundColor DarkGray
Write-Host 'Tus skills viven en: ~\.claude\skills\' -ForegroundColor DarkGray
Write-Host ''
