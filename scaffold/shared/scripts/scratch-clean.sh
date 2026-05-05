#!/usr/bin/env bash
# scratch-clean.sh — Lista archivos en shared/scratch/ con más de 30 días
#
# Uso:
#   ./shared/scripts/scratch-clean.sh          # solo lista
#   ./shared/scripts/scratch-clean.sh --delete # borra interactivamente

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRATCH="$WORKSPACE_ROOT/shared/scratch"
MODE="${1:-list}"

if [[ ! -d "$SCRATCH" ]]; then
  echo "No existe $SCRATCH" >&2
  exit 1
fi

echo "Archivos en shared/scratch/ con mas de 30 dias:"
echo ""

OLD_FILES=$(find "$SCRATCH" -type f -mtime +30 ! -name "README.md" 2>/dev/null || true)

if [[ -z "$OLD_FILES" ]]; then
  echo "  (ninguno - scratch esta limpio)"
  exit 0
fi

echo "$OLD_FILES" | while read -r f; do
  AGE=$(( ($(date +%s) - $(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f")) / 86400 ))
  SIZE=$(du -h "$f" | cut -f1)
  printf "  %4d dias  %6s  %s\n" "$AGE" "$SIZE" "${f#$WORKSPACE_ROOT/}"
done

if [[ "$MODE" == "--delete" ]]; then
  echo ""
  read -p "Borrar todos estos archivos? [y/N] " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "$OLD_FILES" | xargs -r rm -v
    echo "Listo."
  else
    echo "Cancelado."
  fi
else
  echo ""
  echo "Para borrarlos: $0 --delete"
fi
