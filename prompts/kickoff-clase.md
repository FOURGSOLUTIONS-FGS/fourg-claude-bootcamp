# Prompt de kickoff — primera clase

> Pegá esto como **primer mensaje** en la sesión de Claude Code del alumno, una vez que ya completó el `install.ps1` y está parado en su workspace.

---

```
Hola Claude. Acabo de instalar el FourG Claude Code Bootcamp y estoy en mi workspace nuevo.

Por favor, hacé esto en orden:

1. Leé `CLAUDE.md` (debería estar en este directorio).
2. Leé `obsidian-vault/00-memoria/MEMORY.md`.
3. Leé `obsidian-vault/CLAUDE.md` (sub-CLAUDE del vault).
4. Leé `shared/docs/adr/0001-folder-structure.md`.

Después contame en máximo 8 bullets cortos:

- Quién soy (según el CLAUDE.md personalizado).
- Cuáles son las 3 reglas globales que tengo que respetar.
- Qué estructura tiene el workspace (carpetas top-level + qué va en cada una).
- Qué scripts utilitarios tengo y para qué sirve cada uno.
- Cómo te vas a comportar cuando inicies cualquier tarea no trivial (protocolo de memoria).
- Qué herramientas tengo instaladas (preguntame `claude --version`, `node --version`, `python --version`, `git --version`).
- Una pregunta concreta tuya para mí, para validar que entendiste mi perfil.

Después de eso, esperame para indicarte qué proyecto quiero arrancar.
```

---

## Qué esperar de la respuesta

Claude debería:
- Confirmar tu nombre, empresa y email (los placeholders ya reemplazados).
- Listar las 3 reglas: identidad por defecto · UTF-8 BOM en `.ps1` · no commitear secretos.
- Dibujar el árbol de carpetas correctamente.
- Explicar `snapshot.sh`, `new-project.sh`, `scratch-clean.sh`.
- Decir que al iniciar tarea no trivial leerá `obsidian-vault/00-memoria/MEMORY.md` primero.
- Devolver versiones de las 4 herramientas.
- Hacer una pregunta como "¿en qué proyecto querés arrancar hoy?" o "¿usaste antes Next.js o querés que te lo explique desde cero?".

Si Claude se confunde en alguno de estos puntos → corregilo con un mensaje breve. Eso es parte de afinar el `CLAUDE.md` para que sea más explícito.

---

## Siguientes prompts sugeridos para la clase

### Crear primer proyecto:
```
Necesito crear un proyecto que se llame "<nombre>". Usá `./shared/scripts/new-project.sh`. Después documentalo en el vault siguiendo la convención de `obsidian-vault/01-proyectos/`.
```

### Personalizar el CLAUDE.md:
```
Mirá `prompts/personalizar-claude-md.md` (en el bootcamp) y guiame paso a paso para adaptar el CLAUDE.md a mi forma de trabajar real.
```

### Cerrar sesión:
```
Vamos a cerrar la sesión. Por favor, agregá una entrada al daily de hoy en `obsidian-vault/02-daily/YYYY-MM-DD.md` con lo que hicimos y qué queda pendiente.
```
