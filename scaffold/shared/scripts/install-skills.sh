#!/usr/bin/env bash
# install-skills.sh - Instala skills recomendadas en ~/.claude/skills/
# Equivalente bash de install-skills.ps1 (para macOS / Linux)
#
# Uso:
#   ./install-skills.sh          # interactivo
#   ./install-skills.sh --all    # instala todas
#   ./install-skills.sh --list   # solo lista
set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

# Catalogo: name|repo|subpath|recommended|description
SKILLS=(
  "find-skills|https://github.com/vercel-labs/skills.git|skills/find-skills|true|Descubre e instala otras skills via npx skills"
  "polish|https://github.com/pbakaus/impeccable.git||true|Review final UI/UX: alignment, spacing, transitions, WCAG AA"
)

cyan='\033[1;36m'; green='\033[1;32m'; red='\033[1;31m'; yellow='\033[1;33m'; gray='\033[0;37m'; reset='\033[0m'

list_skills() {
  echo -e "${cyan}Skills disponibles:${reset}"
  i=0
  for entry in "${SKILLS[@]}"; do
    IFS='|' read -r name repo sub rec desc <<<"$entry"
    i=$((i+1))
    badge=""; [[ "$rec" == "true" ]] && badge="[recomendada]"
    printf "  %d. %-30s %s\n" "$i" "$name" "$badge"
    echo -e "     ${gray}$desc${reset}"
  done
}

install_skill() {
  IFS='|' read -r name repo sub rec desc <<<"$1"
  target="$SKILLS_DIR/$name"
  if [[ -d "$target" ]]; then
    echo -e "${yellow}    !!  $name ya instalado en $target${reset}"
    return 0
  fi
  echo -e "${cyan}==> Instalando $name${reset}"
  echo -e "    ${gray}$desc${reset}"
  tmp=$(mktemp -d)
  if ! git clone --depth 1 --quiet "$repo" "$tmp" 2>/dev/null; then
    echo -e "${red}    XX  git clone fallo${reset}"
    rm -rf "$tmp"
    return 1
  fi
  mkdir -p "$target"
  src="$tmp"; [[ -n "$sub" ]] && src="$tmp/$sub"
  cp -R "$src"/* "$target"/ 2>/dev/null || true
  rm -rf "$tmp" "$target/.git" 2>/dev/null || true
  echo -e "${green}    OK  $name instalado en $target${reset}"
  return 0
}

echo ''
echo -e "${cyan}============================================================${reset}"
echo -e "${cyan}  FourG Claude Code Bootcamp - Install Skills${reset}"
echo -e "${cyan}============================================================${reset}"
echo ''

if ! command -v git >/dev/null 2>&1; then
  echo -e "${red}    XX  git no esta instalado.${reset}"
  exit 1
fi

list_skills
echo ''

if [[ "${1:-}" == "--list" ]]; then
  echo -e "${gray}Mas skills curadas en https://skills.sh${reset}"
  exit 0
fi

selected=()
if [[ "${1:-}" == "--all" ]]; then
  selected=("${SKILLS[@]}")
else
  read -p "Que instalar? (a=todas, r=solo recomendadas, lista de numeros separados por coma, vacio=cancelar): " resp
  case "$resp" in
    a|A) selected=("${SKILLS[@]}") ;;
    r|R)
      for s in "${SKILLS[@]}"; do
        IFS='|' read -r _ _ _ rec _ <<<"$s"
        [[ "$rec" == "true" ]] && selected+=("$s")
      done ;;
    [0-9]*)
      IFS=',' read -ra nums <<<"$resp"
      for n in "${nums[@]}"; do
        n=$(echo "$n" | tr -d ' ')
        if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#SKILLS[@]} )); then
          selected+=("${SKILLS[$((n-1))]}")
        fi
      done ;;
    *) echo -e "${yellow}Cancelado.${reset}"; exit 0 ;;
  esac
fi

if (( ${#selected[@]} == 0 )); then
  echo -e "${yellow}Nada que instalar.${reset}"
  exit 0
fi

echo ''
ok=0
for s in "${selected[@]}"; do
  install_skill "$s" && ok=$((ok+1))
done

echo ''
echo -e "${green}============================================================${reset}"
echo -e "${green}  $ok / ${#selected[@]} instaladas${reset}"
echo -e "${green}============================================================${reset}"
echo ''
echo -e "${cyan}Para descubrir mas skills:${reset}"
echo "  npx skills find \"<query>\""
echo "  npx skills add owner/repo@skill-name"
echo ''
echo -e "${gray}Catalogo completo: https://skills.sh${reset}"
