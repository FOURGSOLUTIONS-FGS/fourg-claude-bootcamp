# 01 — Instalación

Guía paso a paso para correr el bootcamp en una máquina Windows nueva.

---

## Pre-requisitos

- Windows 10 versión 1809+ o Windows 11.
- Permisos de administrador (necesarios para instalar runtimes).
- 3 GB libres en `C:\` (o donde elijas).
- Conexión a internet (la primera corrida descarga ~500 MB).
- Cuenta de Anthropic. Si no tenés, registrate gratis en:
  - [console.anthropic.com](https://console.anthropic.com) (recomendado, da créditos iniciales)
  - o [claude.ai](https://claude.ai) (cuenta gratuita básica)

---

## Opción A — Instalación 1-comando (recomendada)

> Cuando el repo esté publicado en GitHub.

1. Abrir **PowerShell como Administrador**:
   - Tecla Windows → escribir "powershell" → click derecho → "Ejecutar como administrador".

2. Pegar y enter:
   ```powershell
   irm https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/install.ps1 | iex
   ```

3. Responder las preguntas:
   - Dónde crear el workspace (default `C:\TRABAJOS\`)
   - Nombre, empresa y email
   - Si querés VS Code

4. Esperar ~5 minutos.

5. Cuando termine, abrir una **nueva** PowerShell (para que el PATH se refresque) y correr:
   ```powershell
   cd C:\TRABAJOS
   claude
   ```

---

## Opción B — Instalación desde clone local

Si todavía no está publicado el repo o querés correrlo offline:

1. Clonar (o descomprimir el ZIP que te pasaron) en cualquier carpeta:
   ```powershell
   cd C:\Users\Tu\Downloads
   git clone https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp.git
   cd fourg-claude-bootcamp
   ```

2. Habilitar ejecución de scripts en PowerShell (una sola vez):
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

3. Correr el instalador (PowerShell como Admin):
   ```powershell
   .\install.ps1
   ```

---

## Qué se instala

| Herramienta   | Versión       | Cómo se instala    |
|---------------|---------------|--------------------|
| Node.js       | LTS (20+)     | `winget install OpenJS.NodeJS.LTS` |
| Python        | 3.12          | `winget install Python.Python.3.12` |
| Git           | última        | `winget install Git.Git` |
| VS Code       | última (opt.) | `winget install Microsoft.VisualStudioCode` |
| Claude Code   | última        | `npm install -g @anthropic-ai/claude-code` |

---

## Post-instalación

Después de correr `install.ps1` ejecuta automáticamente `verify.ps1`. Si todo está bien verás:

```
[OK]  Node.js          v20.x.x
[OK]  npm              10.x.x
[OK]  Python           Python 3.12.x
[OK]  pip              pip 24.x
[OK]  Git              git version 2.x
[OK]  Claude Code      x.x.x

Resultado: 6/6 OK
```

Si alguno falla, ver [`05-troubleshooting.md`](05-troubleshooting.md).

---

## Login en Claude Code

La primera vez que corras `claude` te abre el navegador para login. Opciones:

1. **Claude Pro/Max** (recomendado si vas a usarlo bastante) — login con tu cuenta de claude.ai.
2. **API key** (pay-as-you-go) — generar en [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) y pegar.
3. **Cuenta gratuita** — sirve para empezar; con límites diarios.

Una vez autenticado, el token queda guardado en `~/.claude/` y no te lo pide más.

---

## Siguiente paso

[`02-primer-proyecto.md`](02-primer-proyecto.md) — crear tu primer proyecto y arrancar a usar Claude Code.
