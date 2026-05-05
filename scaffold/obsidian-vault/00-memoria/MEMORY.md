---
tipo: moc
nombre: Memory Map of Content
ultimo_update: (actualizar al editar)
tags: [moc, indice, memoria]
---

# 🧠 MEMORY — Índice Maestro del Cerebro Persistente

> **Punto de entrada único.** Cuando abrás una conversación nueva, pedile a Claude:
> *"lee `obsidian-vault/00-memoria/MEMORY.md`"*
>
> Este archivo es un **MOC** (Map of Content). No duplica contenido — linkea.

---

## 📍 Yo y mi entorno

- [[../04-contexto/user-profile]] — Quién soy, hardware, tools, estilo de trabajo
- [[../04-contexto/workspace-structure]] — Layout del workspace (ADR-0001)
- [[../04-contexto/stack]] — Stack preferido

## 🚀 Proyectos vivos

| Proyecto | Estado | Link |
|----------|--------|------|
| (vacío)  | crear con `new-project.sh` | — |

> Editá esta tabla cuando crees tu primer proyecto. Una fila por proyecto activo, con su estado en una frase.

## 🧩 Skills y patterns

- (vacío) — agregá acá tus skills custom o instaladas en `~/.claude/skills/`

### Playbooks técnicos (`06-playbooks/`)

- (vacío) — guías técnicas reutilizables que NO son skills invocables

## 🔗 Referencias externas

- (vacío) — agregá acá pointers a sistemas externos (GitHub, Vercel, etc.)

## 🗓️ Dailies recientes

- Crear el primero con: `obsidian-vault/02-daily/YYYY-MM-DD.md`

---

## 🔑 Decisiones clave

- [[../04-contexto/workspace-structure]] — estructura híbrida `projects/` + `shared/` + `archive/`

## 📁 Convenciones del vault

```
00-memoria/      → MOC maestro (MEMORY.md) + decisiones-clave + mapas de contexto
01-proyectos/    → un .md por proyecto con estado + siguiente paso
02-daily/        → log diario (YYYY-MM-DD.md), archivado mensual en YYYY-MM/
03-referencias/  → sistemas externos
04-contexto/     → perfil, stack, workspace, workflows propios
05-skills/       → fuente de skills custom (instalable en ~/.claude/skills/)
06-playbooks/    → guías técnicas reutilizables (patterns) que NO son skills
99-inbox/        → notas volátiles / borradores (NO escribir sin pedido)
```

**05-skills vs 06-playbooks:**
- `05-skills/` → invocables automáticamente por Claude Code. Frontmatter con `name` + `description`.
- `06-playbooks/` → para humanos. Patterns reusables sin ser skills.

**Links:** `[[ruta/archivo]]` sin `.md`.
**Fechas:** ISO `YYYY-MM-DD`.
**No duplicar:** si algo está en otra nota, linkear en lugar de copiar.
