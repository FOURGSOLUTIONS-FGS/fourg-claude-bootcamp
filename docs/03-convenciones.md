# 03 — Convenciones

Las reglas que mantienen el workspace ordenado a largo plazo. Pocas, pero firmes.

---

## Nombres

- **Carpetas y archivos:** `kebab-case` (`mi-sitio`, no `MiSitio` ni `mi_sitio`).
- **Nombres de proyecto:** descriptivos, sin abreviar (`indubienes-site` mejor que `ind`).
- **Excepciones aceptadas:** archivos que vienen de un framework (`README.md`, `package.json`, `CHANGELOG.md`).

## Fechas

- **Siempre formato ISO:** `YYYY-MM-DD` (`2026-05-04`, no `04-05-2026` ni `4/5/26`).
- Razón: ordena lexicográficamente y no hay ambigüedad mes/día.
- Aplica a snapshots, dailies, archivos de log, ADRs, todo.

## Estructura

| Cosa | Va en | NO va en |
|------|-------|----------|
| Repos / código | `projects/<nombre>/` | raíz, `shared/` |
| Imágenes, videos, PSDs | `shared/assets/<proyecto>/` | dentro del repo |
| ADRs y decisiones | `shared/docs/adr/NNNN-titulo.md` | el repo del proyecto |
| WIP, patches sueltos | `shared/scratch/` | la raíz |
| Snapshots/backups | `archive/YYYY-MM-DD/` | cualquier otro lado |
| Notas de proyecto | `obsidian-vault/01-proyectos/<nombre>.md` | el repo |

## ADRs (Architecture Decision Records)

Cuando tomes una decisión arquitectónica importante (cambiar de framework, elegir base de datos, definir convención), documentala como ADR.

- **Numeración:** 4 dígitos secuenciales (`0001-`, `0002-`).
- **Status:** `Proposed` → `Accepted` → `Deprecated` o `Superseded by NNNN`.
- **Estructura mínima:** Context · Decision · Options Considered · Trade-offs · Consequences.

Plantilla en `shared/docs/adr/0001-folder-structure.md`.

## Commits

- **Mensajes:** primera línea ≤ 72 chars, modo imperativo (`add user auth`, no `added`).
- **Idioma:** elegí uno y mantenelo. Mi default: **inglés** para commits técnicos, **español** para docs/notas internas.
- **Atomicidad:** un commit = un cambio coherente. No mezclar refactor + feature + fix.

## Memoria persistente (Obsidian vault)

- **Una entrada al daily por sesión productiva.** Aunque sea 3 líneas.
- **Una nota por proyecto activo** en `01-proyectos/`. Mantener `estado` y `siguiente_paso` actualizados.
- **MOC (`00-memoria/MEMORY.md`) es índice, no contenido.** Linkea, no dupliques.

## Limpieza

- **`shared/scratch/`:** revisar mensual con `scratch-clean.sh`. Borrar lo > 30 días.
- **`archive/`:** revisar trimestral. Mover a almacenamiento externo (Drive, USB) lo > 1 año.
- **Repos abandonados:** mover de `projects/` a `archive/<fecha>/abandoned-<nombre>/`.

## Encoding (Windows)

⚠️ **Regla crítica para Windows:** TODOS los archivos `.ps1` que contengan caracteres no-ASCII (`¿áéíóúñ¡`) DEBEN guardarse con **UTF-8 BOM**.

PowerShell 5.1 nativo lee archivos sin BOM como CP1252 → mojibake.

Para re-aplicar BOM:
```powershell
$f = "ruta\al\archivo.ps1"
[System.IO.File]::WriteAllText($f, [System.IO.File]::ReadAllText($f), [System.Text.UTF8Encoding]::new($true))
```

(Los `.ps1` del kit ya vienen con BOM correctamente aplicado.)

## Secretos

- **NUNCA en git.** Usar `.env.local` (ya está en `.gitignore`).
- **NUNCA en el vault de Obsidian** (lo podés sincronizar a otro dispositivo).
- Para tokens largos que necesitás recordar: archivo aparte fuera del workspace (ej. `~/.secrets/`).
