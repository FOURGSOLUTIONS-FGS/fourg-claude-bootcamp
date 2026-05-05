# FourG Claude Code Bootcamp

[![Test install](https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/actions/workflows/test-install.yml/badge.svg)](https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/actions/workflows/test-install.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue)]()

> Kit oficial de **FourG Solutions** para arrancar a alguien desde cero con Claude Code y dejarlo con el mismo scaffold de trabajo profesional que usamos internamente.
>
> **Autor:** Adrián Garzón — FourG Solutions · `four4gsolutions@gmail.com` · [www.fourgsolutions.com](https://www.fourgsolutions.com)

---

## Qué hace este kit

Una sola corrida del bootstrap deja al alumno con:

1. **Runtimes instalados** — Node LTS, Python 3.12, Git, VS Code (vía `winget` en Windows o `brew` en macOS).
2. **Claude Code instalado y autenticado** con su propia cuenta de Anthropic.
3. **Workspace estructurado** en la carpeta que él elija, con `projects/`, `shared/`, `archive/` y un `obsidian-vault/` listo para usar como cerebro persistente.
4. **`CLAUDE.md` personalizado** con su nombre, empresa y email — Claude Code lo lee automáticamente al arrancar en el directorio.
5. **`.claude/settings.json` pre-configurado** con permisos sensatos: allow para git/npm/python comunes, deny para destructivos (`rm -rf /`, `terraform apply`, `aws s3 rm`, etc.). Cero prompts de permisos en el primer día.
6. **Scripts utilitarios** — `snapshot.sh`, `new-project.sh`, `scratch-clean.sh`, `install-skills.sh` (descubre y agrega skills curadas) en `shared/scripts/`.
7. **Skills recomendadas** documentadas + `install-skills.ps1` que clona find-skills y polish con un comando.
8. **Módulo IaC opcional** — templates Terraform + CloudFormation (S3 privado/versionado/encriptado) listos para `terraform apply` o `aws cloudformation deploy`. Si elegís "instalar IaC", también agrega Terraform CLI + AWS CLI. Ver [`docs/06-iac-terraform-cloudformation.md`](docs/06-iac-terraform-cloudformation.md).
9. **Multi-plataforma** — equivalentes `.sh` para macOS y Linux. CI valida ambos en cada push.

---

## Para quién es

- Personas que vos (o cualquier instructor de FourG) están enseñando a usar Claude Code desde cero.
- Devs que quieren copiar el patrón "workspace híbrido" (proyectos + shared + archive + vault) sin reinventarlo.
- Equipos chicos que quieren un onboarding repetible.

**Pre-requisitos del alumno:**
- Windows 10/11 (versión macOS/Linux: roadmap, ver `docs/05-troubleshooting.md`).
- Cuenta de Anthropic — gratis para empezar en [console.anthropic.com](https://console.anthropic.com) o [claude.ai](https://claude.ai).
- ~3 GB libres para runtimes + workspace.
- Conexión a internet decente (la primera corrida descarga ~500 MB).

---

## Instalación rápida (1 comando)

### Windows
Abrir PowerShell **como Administrador** y correr:

```powershell
irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.ps1 | iex
```

### macOS / Linux
Abrir Terminal y correr:

```bash
curl -fsSL https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.sh | bash
```

> El `bootstrap.{ps1,sh}` descarga el ZIP del repo a `%TEMP%` / `/tmp` y lanza el instalador localmente (necesario para que el scaffold se copie al workspace).

El instalador te pregunta:
- Dónde crear el workspace (default: `C:\TRABAJOS` o `~/TRABAJOS`).
- Tu nombre, empresa y email para personalizar el `CLAUDE.md`.
- Si querés VS Code (sí/no).
- Si querés el módulo IaC: Terraform + AWS CLI (sí/no, default no).

Después de ~5 minutos ya podés correr `claude` en tu workspace.

### Modo Express (sin preguntas)

Para CI o instalaciones masivas — todos los defaults sin interactividad:

**Windows:** setear variables de entorno antes de correr el bootstrap (porque `irm | iex` no acepta `param()`):
```powershell
$env:FGB_EXPRESS = '1'
$env:FGB_NAME    = 'Tu Nombre'
$env:FGB_EMAIL   = 'tu@mail.com'
irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.ps1 | iex
```

Vars soportadas: `FGB_EXPRESS`, `FGB_WORKSPACE`, `FGB_NAME`, `FGB_COMPANY`, `FGB_EMAIL`, `FGB_VSCODE`, `FGB_IAC`, `FGB_SKIP_LOGIN`.

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.sh | bash -s -- --express --name "Tu Nombre" --email "tu@mail.com"
```

### Hoja imprimible / QR para WhatsApp

Abrí [`docs/quickstart.html`](docs/quickstart.html) en el navegador → botón "Imprimir / PDF" → quedás con una hoja A4 con los pasos + QR al `bootstrap.ps1`. Útil para pasar al alumno por WhatsApp/email/papel.

---

## Estructura del kit

```
fourg-claude-bootcamp/
├── README.md                  ← este archivo
├── bootstrap.ps1 / .sh        ← entrypoint remoto (curl|bash o irm|iex)
├── install.ps1 / .sh          ← instalador local (Windows / macOS+Linux)
├── verify.ps1                 ← chequeo post-instalación
├── .github/workflows/
│   └── test-install.yml       ← CI: testea install + lint en Windows y macOS
├── scaffold/                  ← se copia tal cual al workspace del alumno
│   ├── CLAUDE.md.template     ← con placeholders {{NOMBRE}}, {{EMPRESA}}, {{EMAIL}}
│   ├── README.md
│   ├── .claude/
│   │   ├── settings.json      ← permisos Claude Code sensatos por default
│   │   └── settings.local.json.example
│   ├── projects/              ← acá van los repos
│   ├── shared/
│   │   ├── scripts/           ← snapshot, new-project, scratch-clean, install-skills
│   │   └── docs/adr/          ← ADRs del workspace
│   ├── archive/               ← snapshots por fecha
│   ├── obsidian-vault/        ← cerebro persistente (Obsidian opcional)
│   └── infra/                 ← Terraform + CloudFormation templates (S3 ejemplo)
├── docs/
│   ├── quickstart.html        ← hoja imprimible con QR
│   ├── 01-instalacion.md
│   ├── 02-primer-proyecto.md
│   ├── 03-convenciones.md
│   ├── 04-skills-recomendadas.md
│   ├── 05-troubleshooting.md
│   └── 06-iac-terraform-cloudformation.md
└── prompts/
    ├── kickoff-clase.md       ← prompt que le pasás al alumno día 1
    └── personalizar-claude-md.md
```

---

## Para el instructor

- El flujo de clase está en `prompts/kickoff-clase.md` — pegalo como primer mensaje en la sesión del alumno.
- Convenciones del workspace en `docs/03-convenciones.md`.
- Si querés ampliar el kit (agregar skills, cambiar branding), editá `scaffold/` y `install.ps1`.

## Licencia

MIT — usá, forkeá, adaptá. Solo mantené el crédito a FourG Solutions en el README del scaffold.

## Soporte

Issues en GitHub: [FOURGSOLUTIONS-FGS/fourg-claude-bootcamp](https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/issues)
Email: `four4gsolutions@gmail.com`
