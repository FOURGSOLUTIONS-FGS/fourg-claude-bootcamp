# 05 — Troubleshooting

Los problemas más comunes y cómo resolverlos.

---

## Errores de instalación

### "winget no se reconoce como comando"

`winget` viene con "App Installer" de Microsoft Store.

```powershell
# verificar
winget --version
```

Si falla:
1. Microsoft Store → buscar "App Installer" → instalar/actualizar.
2. Reiniciar PowerShell.

### "No puedes ejecutar scripts en este sistema"

```
.\install.ps1 : File install.ps1 cannot be loaded because running scripts is disabled on this system.
```

Solución (correr **una sola vez** en PowerShell como user normal):
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### "Acceso denegado" al instalar runtimes

`winget install` necesita Administrador. Cerrá PowerShell, abrila con click derecho → "Ejecutar como administrador".

### `npm install -g @anthropic-ai/claude-code` falla con EACCES

En Windows con Node desde winget esto no debería pasar. Si pasa:
```powershell
# verificar prefix
npm config get prefix
# debería ser algo como C:\Users\TuUser\AppData\Roaming\npm
# si está en Program Files, cambialo:
npm config set prefix "$env:APPDATA\npm"
# y reinstalá
npm install -g @anthropic-ai/claude-code
```

---

## Después de instalar, `claude` no se reconoce

### Causa más común: PATH no refrescado

Cerrá la PowerShell donde instalaste y abrí una nueva. El PATH se refresca solo en sesiones nuevas.

### Si persiste:

```powershell
# encontrar dónde instaló npm el binario
npm config get prefix
# debería contener una carpeta con `claude.cmd`
```

Si está pero no en PATH, agregalo:
```powershell
$env:Path += ";$env:APPDATA\npm"
# para hacerlo permanente:
[Environment]::SetEnvironmentVariable('Path', $env:Path + ";$env:APPDATA\npm", 'User')
```

---

## Mojibake en archivos `.ps1` (`Â¿`, `Ã©`, `â€"`)

PowerShell 5.1 lee archivos sin BOM como CP1252. Cualquier `.ps1` con tildes/eñes/símbolos debe tener **UTF-8 BOM**.

**Síntoma:** `echo "¿Hola?"` en un `.ps1` se imprime como `Â¿Hola?`.

**Fix:**
```powershell
$f = "ruta\al\archivo.ps1"
[System.IO.File]::WriteAllText($f, [System.IO.File]::ReadAllText($f), [System.Text.UTF8Encoding]::new($true))
```

Los `.ps1` que vienen con el bootcamp ya tienen BOM aplicado.

---

## Claude Code arranca pero no lee CLAUDE.md

### Causa: estás en un directorio sin `CLAUDE.md`

Claude Code lee el `CLAUDE.md` del **directorio actual** y de los padres (sube el árbol). Si estás dentro de `C:\Users\Tu\Documents` no lo va a encontrar.

```powershell
cd C:\TRABAJOS    # o donde tengas el workspace
claude
```

### Verificación rápida

Pedile a Claude:
> "qué CLAUDE.md leíste? mostrame las primeras 10 líneas"

Si dice "no encontré ninguno" → estás en otro directorio.

---

## El vault de Obsidian no se abre con Obsidian

Obsidian no viene preinstalado (es opcional).

Descargar de [obsidian.md](https://obsidian.md) (gratis), abrir → "Open folder as vault" → seleccionar `obsidian-vault/`.

Si no querés instalar Obsidian, igual podés editar las notas como markdown plano con cualquier editor; los `[[wikilinks]]` simplemente no van a tener click pero el contenido sirve.

---

## Login Claude Code falla

### "browser failed to open"

Copiá la URL que muestra Claude en consola y pegala manualmente en el navegador.

### "401 Unauthorized" después del login

```powershell
# limpiar credenciales y volver a empezar
claude logout
claude   # vuelve a hacer login
```

### Cuenta gratuita: "rate limit exceeded"

La cuenta gratuita tiene límites diarios. Opciones:
- Esperar al reset (24h).
- Comprar Claude Pro ($20/mes).
- Cambiar a API key de pago (`console.anthropic.com`).

---

## Workspace contaminado / quiero empezar de cero

Borrar el workspace actual y volver a correr `install.ps1`:

```powershell
Remove-Item -Recurse -Force C:\TRABAJOS
.\install.ps1
```

⚠️ **Antes:** asegurate de no perder código. Hacé snapshot o backup del `obsidian-vault/` y de `projects/`.

---

## macOS / Linux

Por ahora el kit solo soporta Windows. Versión Mac en roadmap (junto con la migración de Adrián a M5).

Si necesitás correr esto en macOS hoy:
1. Instalá manualmente: `brew install node python git`
2. `npm install -g @anthropic-ai/claude-code`
3. Copiá manualmente la carpeta `scaffold/` y reemplazá los placeholders del `CLAUDE.md.template`.
4. Los `.sh` ya están listos. Los `.ps1` no aplican (son específicos de PowerShell).

---

## Soporte

Si nada de esto resuelve tu problema:
- Issues: [github.com/Adriangar333/fourg-claude-bootcamp/issues](https://github.com/Adriangar333/fourg-claude-bootcamp/issues)
- Email: `four4gsolutions@gmail.com`
