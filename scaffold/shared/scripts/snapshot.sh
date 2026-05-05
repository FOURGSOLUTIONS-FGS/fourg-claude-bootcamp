#!/usr/bin/env bash
# snapshot.sh — Crea un snapshot zippeado de un proyecto en archive/YYYY-MM-DD/
#
# Uso:
#   ./shared/scripts/snapshot.sh <nombre-proyecto>
#
# Ejemplo:
#   ./shared/scripts/snapshot.sh mi-sitio

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <nombre-proyecto>" >&2
  echo "Proyectos disponibles:" >&2
  ls projects/ 2>/dev/null | sed 's/^/  - /' >&2
  exit 1
fi

PROJECT="$1"
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_DIR="$WORKSPACE_ROOT/projects/$PROJECT"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Error: no existe $PROJECT_DIR" >&2
  exit 1
fi

DATE="$(date +%Y-%m-%d)"
ARCHIVE_DIR="$WORKSPACE_ROOT/archive/$DATE"
ZIP_PATH="$ARCHIVE_DIR/${PROJECT}-snapshot-${DATE}.zip"

mkdir -p "$ARCHIVE_DIR"

echo "Creando snapshot de $PROJECT -> $ZIP_PATH"
cd "$WORKSPACE_ROOT/projects"
zip -rq "$ZIP_PATH" "$PROJECT" \
  -x "$PROJECT/node_modules/*" \
  -x "$PROJECT/.next/*" \
  -x "$PROJECT/dist/*" \
  -x "$PROJECT/.turbo/*" \
  -x "$PROJECT/tmp/*" \
  -x "$PROJECT/.venv/*" \
  -x "$PROJECT/__pycache__/*"

SIZE="$(du -h "$ZIP_PATH" | cut -f1)"
echo "OK ($SIZE) -> $ZIP_PATH"
