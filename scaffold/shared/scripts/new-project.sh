#!/usr/bin/env bash
# new-project.sh — Scaffold de un nuevo proyecto en projects/
#
# Uso:
#   ./shared/scripts/new-project.sh <nombre> [url-git]
#
# Ejemplos:
#   ./shared/scripts/new-project.sh mi-nuevo-sitio
#   ./shared/scripts/new-project.sh mi-app https://github.com/usuario/mi-app.git

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <nombre> [url-git]" >&2
  exit 1
fi

NAME="$1"
GIT_URL="${2:-}"
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECTS_DIR="$WORKSPACE_ROOT/projects"
TARGET="$PROJECTS_DIR/$NAME"

if [[ -e "$TARGET" ]]; then
  echo "Error: ya existe $TARGET" >&2
  exit 1
fi

mkdir -p "$PROJECTS_DIR"
cd "$PROJECTS_DIR"

if [[ -n "$GIT_URL" ]]; then
  echo "Clonando $GIT_URL -> projects/$NAME"
  git clone "$GIT_URL" "$NAME"
else
  echo "Creando projects/$NAME vacio"
  mkdir -p "$NAME"
  cd "$NAME"
  git init -q
  cat > README.md <<EOF
# $NAME

Proyecto nuevo.

Creado: $(date +%Y-%m-%d)
EOF
fi

# Crear assets folder en shared/ para este proyecto
mkdir -p "$WORKSPACE_ROOT/shared/assets/$NAME"
echo "Assets folder listo: shared/assets/$NAME/"

echo ""
echo "Listo. Proximos pasos sugeridos:"
echo "  cd projects/$NAME"
echo "  claude              # arrancar Claude Code en el proyecto"
echo "  # opcional: agregar un CLAUDE.md propio para este proyecto"
