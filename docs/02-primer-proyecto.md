# 02 — Tu primer proyecto

Asumo que ya corriste `install.ps1` y `verify.ps1` te dio 6/6 OK.

---

## 1. Entrar al workspace

```powershell
cd C:\TRABAJOS    # o donde lo hayas creado
```

Mirá la estructura:

```powershell
ls
```

Deberías ver:
```
CLAUDE.md
README.md
.gitignore
projects/
shared/
archive/
obsidian-vault/
```

---

## 2. Arrancar Claude Code

```powershell
claude
```

Primer prompt sugerido (copiá y pegá):

```
Lee CLAUDE.md y obsidian-vault/00-memoria/MEMORY.md.
Después contame en 5 bullets qué entendiste del workspace
y qué reglas tenés que seguir.
```

Esto verifica que:
- Claude lee el CLAUDE.md raíz.
- Claude entra al vault de Obsidian.
- Tu personalización (`{{NOMBRE}}` etc.) se aplicó bien.

---

## 3. Crear tu primer proyecto

Dentro de Claude Code (o desde una shell aparte):

```bash
./shared/scripts/new-project.sh mi-primer-sitio
```

> En PowerShell nativo: `.\shared\scripts\new-project.ps1 mi-primer-sitio`

Esto crea:
- `projects/mi-primer-sitio/` con un `git init` y un README.
- `shared/assets/mi-primer-sitio/` para imágenes/videos.

---

## 4. Trabajar en el proyecto

```powershell
cd projects\mi-primer-sitio
claude
```

Cuando arranca Claude Code en un subdirectorio:
- Sube y lee el `CLAUDE.md` del workspace raíz (te da el contexto global).
- Si hay un `CLAUDE.md` en `projects/mi-primer-sitio/`, lo lee también (para reglas específicas del proyecto).

Prompt sugerido para arrancar un Next.js, por ejemplo:

```
Crea un Next.js 14 con App Router, TypeScript y Tailwind.
Página de inicio simple con un Hero y un footer.
Usa pnpm.
```

---

## 5. Anotar el proyecto en el vault

Cuando termines la sesión, agregá una nota en el vault:

`obsidian-vault/01-proyectos/mi-primer-sitio.md`

```markdown
---
tipo: proyecto
nombre: mi-primer-sitio
estado: activo
ultimo_update: 2026-05-04
tags: [proyecto, next.js]
---

# mi-primer-sitio

## Qué es
Mi primer proyecto creado con el bootcamp.

## Estado actual
Scaffold de Next.js + Tailwind listo. Hero básico funcionando en `pnpm dev`.

## Siguiente paso
Diseñar la estructura de páginas reales.

## Stack
- Next.js 14 App Router
- TypeScript
- Tailwind
- Deploy: Vercel (pendiente)
```

Y agregalo al MOC en `obsidian-vault/00-memoria/MEMORY.md` en la tabla "Proyectos vivos".

---

## 6. Snapshot al cerrar la sesión (opcional)

Si querés un backup zippeado del estado actual:

```bash
./shared/scripts/snapshot.sh mi-primer-sitio
# crea archive/2026-05-04/mi-primer-sitio-snapshot-2026-05-04.zip
```

---

## Próximo paso

[`03-convenciones.md`](03-convenciones.md) — las reglas que mantienen el workspace ordenado a largo plazo.
