# Instrucciones para Claude Code (sub-CLAUDE.md del vault)

Cuando Claude Code trabaja dentro de `obsidian-vault/`, este archivo le da contexto adicional al CLAUDE.md raíz.

## Protocolo al iniciar sesión

1. Leer `00-memoria/MEMORY.md` — índice global (MOC: Map of Content)
2. Revisar el daily más reciente en `02-daily/YYYY-MM-DD.md` (si existe)
3. Si el usuario menciona un proyecto → abrir `01-proyectos/<proyecto>.md`

## Protocolo al cerrar / pivotear

- Agregar entrada al daily de hoy con lo hecho + pendientes
- Si hubo decisión arquitectónica → documentarla en el proyecto correspondiente

## Convenciones del vault

- **Tono:** español coloquial, sin formalismos.
- **Links internos:** `[[ruta/archivo]]` estilo Obsidian (sin `.md`).
- **Fechas:** ISO `YYYY-MM-DD`.
- **Emojis:** solo si el usuario los usa primero.

## Estructura

```
00-memoria/     → MOC maestro (MEMORY.md) + decisiones-clave
01-proyectos/   → Un .md por proyecto activo, con estado + siguiente paso
02-daily/       → Log diario (YYYY-MM-DD.md), archivado mensual
03-referencias/ → Sistemas externos, credenciales (NO secretos), URLs
04-contexto/    → Perfil, stack, workspace, workflows propios
05-skills/      → Fuente de skills custom para Claude Code
06-playbooks/   → Guías técnicas reutilizables (patrones)
99-inbox/       → Notas volátiles del usuario (NO escribir sin pedido)
```

## No hacer

- No duplicar contenido que ya está en `00-memoria/MEMORY.md` — linkear en lugar de copiar.
- No escribir en `99-inbox/` salvo pedido explícito — es zona personal.
- No borrar dailies antiguos — son historial.
