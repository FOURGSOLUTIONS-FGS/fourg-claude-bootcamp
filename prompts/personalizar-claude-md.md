# Prompt — personalizar tu CLAUDE.md

> Usá esto cuando ya hayas trabajado un par de días con Claude Code y quieras afinar el `CLAUDE.md` raíz a tu forma real de trabajar.

---

## Por qué importa

El `CLAUDE.md` del scaffold viene con valores razonables, pero el verdadero valor aparece cuando lo personalizás con:
- Tu stack real (no el genérico).
- Tus reglas específicas (cosas que NO querés que Claude haga sin preguntar).
- Tus convenciones de naming, commits, idioma.
- El estilo de respuesta que preferís (corto vs detallado, opciones vs decisión, etc.).

---

## Prompt para Claude

```
Quiero refinar mi CLAUDE.md para que refleje mejor mi forma real de trabajar.

Por favor:

1. Leé el CLAUDE.md actual.
2. Hacéme estas preguntas, una a la vez (no todas juntas), y esperá mi respuesta antes de la siguiente:

   a. ¿Cuál es tu stack real principal? (frontend, backend, deploy, BD)
   b. ¿Hay alguna acción que NO querés que haga sin pedirte permiso explícito?
      (ej: push a main, instalar paquetes, borrar archivos, modificar BD)
   c. ¿Preferís que cuando haya decisión, te dé opciones (A, B, C) o que decida yo y vos vetás?
   d. ¿Idioma para commits? ¿Para docs? ¿Mix?
   e. ¿Cuándo querés respuestas largas y cuándo cortas?
      (ej: "explicaciones largas si es nuevo concepto, cortas si es ejecución")
   f. ¿Hay alguna skill o herramienta que YA usás siempre y querés que la asuma?
      (ej: "siempre uso pnpm, no npm" / "siempre TypeScript estricto")
   g. ¿Hay algún cliente o proyecto especial cuyo nombre NUNCA debe aparecer en código de OTROS proyectos?
      (ej: regla de privacidad)

3. Después de tener todas las respuestas, mostrame un diff propuesto del CLAUDE.md
   (qué secciones agregás, modificás, borrás). NO modifiques el archivo todavía.

4. Esperá que apruebe el diff antes de aplicarlo.

5. Cuando lo apliques, mantené el formato markdown, las secciones existentes que sirven, y agregá una nota al final con la fecha del refinamiento.
```

---

## Iteración recomendada

- **Día 1 (hoy):** correr el bootcamp, primer prompt de kickoff, primer proyecto. NO personalizar todavía.
- **Día 3-7:** una vez que tenés sensación de qué te molesta o qué te gustaría que haga distinto, correr este prompt.
- **Mensual:** revisar `CLAUDE.md` y ajustar si pivotaste de stack o de proyecto principal.

---

## Tips

- **No optimices prematuramente.** Si todavía no sabés qué te gusta o no, dejá el default y observá.
- **Si Claude hace algo mal repetidamente,** esa es la señal de que le falta una regla en `CLAUDE.md`.
- **Si Claude pregunta cosas obvias,** esa es la señal de que le falta contexto en `CLAUDE.md`.
- **Mantenelo bajo 200 líneas** — más allá, Claude empieza a perder atención. Si crece mucho, mové detalle a `obsidian-vault/04-contexto/`.
