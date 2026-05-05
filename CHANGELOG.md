# Changelog

Todos los cambios notables del FourG Claude Code Bootcamp.

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/), versionado [SemVer](https://semver.org/lang/es/).

## [1.1.0] — 2026-05-04

### Agregado
- **macOS / Linux:** `bootstrap.sh` + `install.sh` con detección de OS (Brew / apt / dnf / pacman). One-liner `curl … | bash` documentado en README.
- **Modo Express:** `-Express` en bootstrap.ps1 / install.ps1 y `--express` en install.sh para corridas desatendidas (CI, instalaciones masivas). Acepta params `-UserName`, `-Email`, `-Workspace`, `-VSCode`, `-IaC`, `-SkipLogin`.
- **`.claude/settings.json` en el scaffold:** permisos sensatos por default (allow git/npm/python comunes; deny `rm -rf /`, `sudo`, `terraform apply`, `aws s3 rm`, `git push --force`, etc.).
- **`install-skills.{ps1,sh}`** en `shared/scripts/`: clona find-skills + polish desde sus repos a `~/.claude/skills/`, con menú interactivo o `--all` / `-All`.
- **`docs/quickstart.html`:** hoja imprimible A4 con QR al `bootstrap.ps1`, paleta espresso+dorado FourG, listo para imprimir o pasar por WhatsApp.
- **GitHub Actions** (`.github/workflows/test-install.yml`): jobs `lint` (syntax check `.ps1` + `.sh`, validación de UTF-8 BOM, scan de secretos) + `test-windows` (instala en Express y valida workspace) + `test-macos` (idem en macos-latest).
- **Badges** en README: build status, license MIT, plataformas.
- **Skip de admin check si `$env:CI`** definido (para correr en GitHub Actions runners).

### Cambiado
- README estructura ampliada: sección por plataforma, modo Express documentado, mención al QR/PDF.

## [1.0.0] — 2026-05-04

### Agregado
- Bootstrap inicial Windows: `install.ps1` + `verify.ps1` + `bootstrap.ps1`.
- Scaffold con CLAUDE.md template, scripts shell+powershell, ADR-0001, vault Obsidian (00-99).
- Módulo IaC: templates Terraform + CloudFormation (S3 privado/versionado/encriptado).
- Docs `01-instalacion` a `06-iac-terraform-cloudformation`.
- Prompts: `kickoff-clase` y `personalizar-claude-md`.
- Push a https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp como repo público.
