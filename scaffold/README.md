# Workspace

Workspace personal estructurado con el patrón **FourG Claude Code Bootcamp**.

## Mapa

```
.
├── CLAUDE.md            ← contexto que Claude Code lee al arrancar
├── projects/            ← un subdirectorio por repo / proyecto
├── shared/
│   ├── assets/          ← imágenes, videos, PSDs (NO van al repo)
│   ├── docs/            ← ADRs y docs transversales
│   ├── scratch/         ← WIP, patches sueltos, experimentos
│   └── scripts/         ← snapshot.sh, new-project.sh, scratch-clean.sh
├── archive/             ← snapshots por fecha (YYYY-MM-DD)
└── obsidian-vault/      ← cerebro persistente (abrir con Obsidian)
```

## Cómo arrancar

1. **Abrir Claude Code aquí**: `cd <este-directorio> && claude`
2. **Primer prompt sugerido**: *"Lee CLAUDE.md y obsidian-vault/00-memoria/MEMORY.md, contame qué entendés del workspace."*
3. **Crear tu primer proyecto**: `./shared/scripts/new-project.sh mi-primer-sitio`

## Convenciones rápidas

- Carpetas en `kebab-case`.
- Fechas en `YYYY-MM-DD`.
- Snapshots con `./shared/scripts/snapshot.sh <proyecto>`.
- Decisiones grandes → ADR en `shared/docs/adr/`.

Más detalles en [CLAUDE.md](CLAUDE.md).
