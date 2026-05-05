---
tipo: contexto
nombre: Workspace Structure
tags: [contexto, workspace, adr]
---

# Estructura del workspace

Decisión documentada en [[../../shared/docs/adr/0001-folder-structure|ADR-0001]].

```
workspace/
├── CLAUDE.md            ← contexto que Claude Code lee al arrancar
├── projects/            ← un subdirectorio por repo / proyecto
├── shared/
│   ├── assets/          ← imágenes, videos, PSDs (NO van al repo)
│   ├── docs/adr/        ← Architecture Decision Records
│   ├── scratch/         ← WIP, patches sueltos, experimentos
│   └── scripts/         ← snapshot, new-project, scratch-clean
├── archive/             ← snapshots por fecha (YYYY-MM-DD)
└── obsidian-vault/      ← este vault (cerebro persistente)
```

## Reglas

- Repos en `projects/<nombre>/` (kebab-case).
- Assets pesados en `shared/assets/<proyecto>/`, NO dentro del repo.
- Snapshots en `archive/YYYY-MM-DD/`, generados con `snapshot.sh`.
- WIP en `shared/scratch/`, limpiar mensual con `scratch-clean.sh`.
- Decisiones grandes → ADR en `shared/docs/adr/NNNN-titulo.md`.

## Scripts utilitarios

| Script | Qué hace |
|--------|----------|
| `shared/scripts/snapshot.sh <proyecto>` | Crea zip en `archive/YYYY-MM-DD/` |
| `shared/scripts/new-project.sh <nombre> [git-url]` | Scaffold de nuevo proyecto |
| `shared/scripts/scratch-clean.sh [--delete]` | Lista/borra archivos viejos en scratch |

(Hay versiones `.ps1` equivalentes para Windows nativo si no querés usar Git Bash.)
