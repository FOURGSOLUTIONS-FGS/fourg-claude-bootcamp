# ADR-0001: Estructura híbrida del workspace

**Status:** Accepted
**Date:** (fecha de instalación del kit)
**Origen:** FourG Claude Code Bootcamp v1.0

## Context

Este workspace personal va a contener múltiples cosas con naturaleza distinta:
- Repos de código (versionados con git, pueden ser muchos).
- Assets pesados (videos, imágenes, PSDs) que NO deberían vivir adentro de los repos.
- Snapshots / backups históricos.
- Documentos transversales (ADRs, code reviews, notas).
- Archivos sueltos de trabajo en progreso (patches, experimentos).
- Cerebro persistente para que Claude Code recuerde contexto entre sesiones.

Sin estructura, todo termina mezclado en la raíz y se vuelve imposible:
- Clonar nuevos repos sin contaminar.
- Distinguir código versionado de assets binarios.
- Archivar viejo sin mezclarlo con activo.
- Compartir assets entre proyectos.

## Decision

Adoptar una **estructura híbrida** con cuatro carpetas raíz:

```
workspace/
├── projects/              # Un subdirectorio por repo / proyecto
├── shared/                # Recursos transversales y no-código
│   ├── assets/<proyecto>/ # Imágenes, videos, PSDs (namespaced)
│   ├── docs/
│   │   ├── adr/           # Architecture Decision Records
│   │   └── reviews/       # Code reviews y auditorías
│   ├── scratch/           # WIP, patches sueltos, experimentos
│   └── scripts/           # Utilidades compartidas
├── archive/               # Snapshots y backups por fecha (YYYY-MM-DD)
└── obsidian-vault/        # Cerebro persistente (Obsidian opcional)
```

**Reglas:**
- Repos van en `projects/<nombre>/`.
- Assets de un proyecto en `shared/assets/<proyecto>/` (NO dentro del repo).
- Snapshots en `archive/YYYY-MM-DD/`.
- WIP en `shared/scratch/` (limpiar mensual).
- Decisiones grandes documentadas como ADR en `shared/docs/adr/NNNN-titulo.md`.

## Options Considered

### Option A: Por tipo puro (`projects/`, `assets/`, `docs/`, `archive/` en raíz)

**Pros:** Limpio, fácil de navegar.
**Cons:** Si dos proyectos tienen assets con el mismo nombre, colisionan.

### Option B: Por proyecto puro (cada proyecto con su propio `assets/`, `docs/`, `archive/`)

**Pros:** Aislamiento fuerte, fácil mover/zippear.
**Cons:** Duplica estructura en cada proyecto; no hay lugar natural para docs transversales.

### Option C: Híbrida (`projects/` + `shared/` + `archive/`) — **ELEGIDA**

**Pros:** Repos aislados, assets namespaced por proyecto, lugar natural para ADRs y experimentos compartidos.
**Cons:** Requiere disciplina; `shared/scratch/` puede volverse basurero si no se limpia.

## Trade-off Analysis

La decisión clave es **dónde viven los assets pesados**. Dejarlos dentro del repo infla el repo y rompe Vercel/Git LFS. Sacarlos completamente del workspace pierde el vínculo con el proyecto. La híbrida los mantiene cerca (`shared/assets/<proyecto>/`) pero fuera del árbol de git.

## Consequences

**Más fácil:**
- Clonar nuevo repo: `cd projects && git clone ...` sin contaminar.
- Archivar: snapshots a `archive/YYYY-MM-DD/`, no más duplicados flotantes.
- Encontrar decisiones: `shared/docs/adr/` es el índice de por qué las cosas están así.
- Compartir assets sin versionarlos en git.

**Más difícil:**
- Hay que recordar la convención (mitigado por `CLAUDE.md` que se lo recuerda a Claude).
- `shared/scratch/` necesita limpieza periódica (sugerido: revisar mensual con `scratch-clean.sh`).

## Action Items

- [x] Crear estructura `projects/`, `shared/`, `archive/`, `obsidian-vault/`
- [x] Escribir CLAUDE.md raíz
- [x] Scripts utilitarios en `shared/scripts/`
- [ ] Primer proyecto: `./shared/scripts/new-project.sh <nombre>`
- [ ] Revisar `shared/scratch/` mensualmente
