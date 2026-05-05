# 04 — Skills recomendadas

Las **skills** son módulos de instrucciones que Claude Code carga automáticamente cuando matchea su trigger. Están en `~/.claude/skills/<nombre>/SKILL.md`.

El bootcamp NO te las instala automáticamente — elegí cuáles querés.

---

## Cómo instalar una skill

### Opción 1: con `find-skills` (la skill que instala skills)

```bash
# instalar find-skills primero (una sola vez)
mkdir -p ~/.claude/skills/find-skills
cd ~/.claude/skills/find-skills
# (descargar SKILL.md de https://github.com/vercel-labs/skills)

# después podés usar:
npx skills find "postgres"
npx skills add vercel-labs/skills@find-skills
```

### Opción 2: manual

Cada skill tiene su instalación documentada. Generalmente:

```bash
mkdir -p ~/.claude/skills/<nombre>
cd ~/.claude/skills/<nombre>
git clone --depth 1 <url-del-repo> .
```

---

## Skills muy recomendadas para empezar

### `find-skills` — para descubrir más skills
- **Para qué:** buscar en el ecosystem y auto-instalar.
- **Repo:** [vercel-labs/skills](https://github.com/vercel-labs/skills)
- **Trigger:** "buscar skill para X", "instalar skill Y".

### `polish` — review final de UI/UX
- **Para qué:** repaso de alineación, espaciado, tinted neutrals, transiciones, WCAG AA.
- **Repo:** [pbakaus/impeccable](https://github.com/pbakaus/impeccable)
- **Trigger:** "polish", "darle el último repaso", "qué se puede mejorar visualmente".

### `supabase-postgres-best-practices`
- **Para qué:** queries y schemas Postgres optimizados (sirve incluso si no usás Supabase).
- **Repo:** [supabase/agent-skills](https://github.com/supabase/agent-skills)
- **Trigger:** trabajo con Postgres, escribir queries, diseñar schemas.

### `typescript-advanced-types`
- **Para qué:** generics, conditional types, mapped types, branded types.
- **Repo:** [wshobson/agents](https://github.com/wshobson/agents)
- **Trigger:** TS complejo, value objects, type-level programming.

---

## Skills para casos específicos

### Si trabajás con video / imágenes generadas por IA

- **flow-video** — workflow Google Flow + Veo 3.1 para generar video.
- **scroll-3d-video** — scroll-driven 3D experiences con GSAP + Canvas.
- **blender-render-automation** — render headless con Blender Python.
- **comfyui-img2img** — workflows ComfyUI para img2img con ControlNet.

### Si trabajás con datos / BD

- **postgresql-table-design** — diseño de schemas Postgres.
- **postgresql-code-review** — review de queries y migraciones.

### Si hacés forensia / seguridad

- **forensic-network-recovery** — búsqueda activa de archivos en redes corporativas.
- **disk-forensics** — análisis de disk images.
- **email-forensics** — análisis de mailboxes.

---

## Catálogo completo

- **skills.sh** — leaderboard global del ecosystem ([skills.sh](https://skills.sh)).
- **Anthropic official skills** — [github.com/anthropics/skills](https://github.com/anthropics/skills).

---

## Crear tu propia skill

Cada skill es un directorio en `~/.claude/skills/<nombre>/` con un `SKILL.md` así:

```markdown
---
name: mi-skill
description: Una línea diciendo qué hace y cuándo invocarla. Ej: "Cotizar en HTML→PDF cuando el usuario pida 'cotizar X para [cliente]'."
---

# Cuerpo de la skill

Instrucciones detalladas para Claude Code:
- qué pasos seguir
- qué archivos leer (con paths relativos al directorio de la skill)
- qué outputs entregar
```

Pueden incluir `templates/`, `examples/`, scripts auxiliares.

Una vez ahí, Claude Code la detecta automáticamente al arrancar.

Si querés mantenerlas versionadas, guardalas como fuente en `obsidian-vault/05-skills/<nombre>/` y hacé un symlink (o copia) a `~/.claude/skills/`.
