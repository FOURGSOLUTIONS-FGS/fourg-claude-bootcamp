# .claude/

Configuración local de Claude Code para este workspace.

## Archivos

| Archivo | Versionado | Para qué |
|---------|------------|----------|
| `settings.json` | Sí | Permisos sensatos por default (allow git/npm/python básicos, deny destructivo) |
| `settings.local.json` | No (en .gitignore) | Tus overrides personales |
| `settings.local.json.example` | Sí | Template para empezar tu `settings.local.json` |

## Qué viene allow / deny por default

**Permitido (no te pide confirmación):**
- Lectura/edición de archivos en el workspace.
- Git read-only y operaciones comunes (status, log, diff, add, commit, push, pull, checkout, branch).
- npm/pnpm/yarn install + run scripts. npx.
- Python + pip básicos.
- Comandos de shell de inspección (ls, cat, head, tail, find, grep, rg, jq).
- Scripts del workspace (`./shared/scripts/*`).
- Terraform read-only (fmt, validate, plan, init, output) — NO apply ni destroy.
- AWS CLI read-only (sts, s3 ls, cloudformation describe).
- WebFetch a docs oficiales (anthropic, github, terraform, aws, node, python, vercel).

**Bloqueado (te pide confirmación o falla):**
- `sudo:*`
- `rm -rf /`, `rm -rf ~`, fork bombs.
- `curl | sh` o `wget | bash` (shell injection).
- `npm install -g` (preferí instalación local del proyecto).
- `git push --force`, `git reset --hard`, `git clean -fd` (destructivos).
- `terraform apply`, `terraform destroy` (te pide aprobar cada vez).
- `aws s3 rm`, `aws s3 sync --delete`, `aws cloudformation delete-stack`, `aws iam delete:*`.
- `docker system prune`.

## Cómo personalizar para tu máquina

```powershell
cd .claude
cp settings.local.json.example settings.local.json
# Editar settings.local.json con los allows extra que necesites
```

`settings.local.json` mergea con `settings.json` y le agrega/sobrescribe permisos solo en tu máquina (no se commitea).

## Cómo cambiar permisos para todo el equipo

Editar `settings.json` directamente y commitearlo. Todos los que clonen el workspace van a heredar el cambio.

## Más info

- Docs oficiales: https://docs.anthropic.com/en/docs/claude-code/settings
- Esquema JSON: https://json.schemastore.org/claude-code-settings.json
