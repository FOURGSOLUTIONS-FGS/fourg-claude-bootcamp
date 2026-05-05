# FourG Claude Code Bootcamp

> Kit oficial de **FourG Solutions** para arrancar a alguien desde cero con Claude Code y dejarlo con el mismo scaffold de trabajo profesional que usamos internamente.
>
> **Autor:** Adrián Garzón — FourG Solutions · `four4gsolutions@gmail.com` · [www.fourgsolutions.com](https://www.fourgsolutions.com)

---

## Qué hace este kit

Una sola corrida de `install.ps1` deja al alumno con:

1. **Runtimes instalados** — Node LTS, Python 3.12, Git, VS Code (vía `winget`).
2. **Claude Code instalado y autenticado** con su propia cuenta de Anthropic.
3. **Workspace estructurado** en la carpeta que él elija, con `projects/`, `shared/`, `archive/` y un `obsidian-vault/` listo para usar como cerebro persistente.
4. **`CLAUDE.md` personalizado** con su nombre, empresa y email — Claude Code lo lee automáticamente al arrancar en el directorio.
5. **Scripts utilitarios** — `snapshot.sh`, `new-project.sh`, `scratch-clean.sh` listos en `shared/scripts/`.
6. **Skills recomendadas** documentadas (no se instalan auto, las elige el alumno).
7. **Módulo IaC opcional** — templates Terraform + CloudFormation (S3 privado/versionado/encriptado) listos para `terraform apply` o `aws cloudformation deploy`. Si elegís "instalar IaC", también agrega Terraform CLI + AWS CLI. Ver [`docs/06-iac-terraform-cloudformation.md`](docs/06-iac-terraform-cloudformation.md).

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

Abrir PowerShell **como Administrador** y correr:

```powershell
irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/install.ps1 | iex
```

> Si todavía no está publicado el repo: cloná y corré local — ver `docs/01-instalacion.md`.

El instalador te pregunta:
- Dónde querés crear el workspace (default: `C:\TRABAJOS\`).
- Tu nombre, empresa y email para personalizar el `CLAUDE.md`.
- Si querés VS Code (sí/no).
- Si querés el módulo IaC: Terraform + AWS CLI (sí/no, default no).

Después de ~5 minutos ya podés correr `claude` en tu workspace.

---

## Estructura del kit

```
fourg-claude-bootcamp/
├── README.md                  ← este archivo
├── install.ps1                ← bootstrap Windows
├── verify.ps1                 ← chequeo post-instalación
├── scaffold/                  ← se copia tal cual al workspace del alumno
│   ├── CLAUDE.md.template     ← con placeholders {{NOMBRE}}, {{EMPRESA}}, {{EMAIL}}
│   ├── README.md
│   ├── projects/              ← acá van los repos
│   ├── shared/
│   │   ├── scripts/           ← snapshot, new-project, scratch-clean
│   │   └── docs/adr/          ← ADRs del workspace
│   ├── archive/               ← snapshots por fecha
│   ├── obsidian-vault/        ← cerebro persistente (Obsidian opcional)
│   └── infra/                 ← Terraform + CloudFormation templates (S3 ejemplo)
├── docs/
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
