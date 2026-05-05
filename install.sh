#!/usr/bin/env bash
# FourG Claude Code Bootcamp - Instalador macOS / Linux
# Equivalente de install.ps1 para sistemas Unix.
#
# Uso interactivo:
#   ./install.sh
#
# Uso express (CI / instalacion masiva):
#   ./install.sh --express \
#     --workspace ~/TRABAJOS \
#     --name "Juan Perez" \
#     --company "JP" \
#     --email "juan@jp.com"
#
# Flags:
#   --express              Modo desatendido, defaults / params sin preguntar
#   --workspace PATH       Ruta del workspace (default: $HOME/TRABAJOS)
#   --name NOMBRE          Nombre del usuario
#   --company EMPRESA      Empresa o marca
#   --email MAIL           Email
#   --no-iac               No instalar Terraform + AWS CLI
#   --iac                  Si instalar Terraform + AWS CLI
#   --skip-login           No lanzar `claude` al final
#
# Autor:   Adrian Garzon - FourG Solutions
# Email:   four4gsolutions@gmail.com
# Version: 1.1.0

set -euo pipefail

KIT_VERSION='1.1.0'
KIT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# -----------------------------------------------------------------------------
# UI helpers
# -----------------------------------------------------------------------------
cyan='\033[1;36m'; green='\033[1;32m'; red='\033[1;31m'; yellow='\033[1;33m'; gray='\033[0;37m'; reset='\033[0m'

step() { echo -e "${cyan}==> $*${reset}"; }
ok()   { echo -e "    ${green}OK${reset}  $*"; }
warn() { echo -e "    ${yellow}!!${reset}  $*"; }
fail() { echo -e "    ${red}XX${reset}  $*"; }
info() { echo -e "    ${gray}-${reset}   $*"; }

banner() {
  echo ''
  echo -e "${cyan}============================================================${reset}"
  echo -e "${cyan}  FourG Claude Code Bootcamp - Instalador macOS/Linux${reset}"
  echo -e "${cyan}  v${KIT_VERSION} - FourG Solutions${reset}"
  echo -e "${cyan}============================================================${reset}"
  echo ''
}

read_default() {
  local prompt="$1" default="$2" reply
  read -r -p "$prompt [$default]: " reply
  echo "${reply:-$default}"
}

read_yesno() {
  local prompt="$1" default="$2" hint reply
  hint=$([ "$default" = "y" ] && echo "Y/n" || echo "y/N")
  read -r -p "$prompt [$hint]: " reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[yYsS] ]]
}

# -----------------------------------------------------------------------------
# Parse args
# -----------------------------------------------------------------------------
EXPRESS=false
WORKSPACE=""
USER_NAME=""
COMPANY=""
EMAIL=""
INSTALL_IAC="ask"
INSTALL_VSCODE="ask"
SKIP_LOGIN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --express)     EXPRESS=true; shift ;;
    --workspace)   WORKSPACE="$2"; shift 2 ;;
    --name)        USER_NAME="$2"; shift 2 ;;
    --company)     COMPANY="$2"; shift 2 ;;
    --email)       EMAIL="$2"; shift 2 ;;
    --no-iac)      INSTALL_IAC="false"; shift ;;
    --iac)         INSTALL_IAC="true"; shift ;;
    --no-vscode)   INSTALL_VSCODE="false"; shift ;;
    --vscode)      INSTALL_VSCODE="true"; shift ;;
    --skip-login)  SKIP_LOGIN=true; shift ;;
    -h|--help)     grep '^#' "$0" | head -30; exit 0 ;;
    *)             fail "Flag desconocido: $1"; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Detectar OS
# -----------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      fail "OS no soportado: $OS"; exit 1 ;;
esac

banner
ok "Plataforma detectada: $PLATFORM"

# -----------------------------------------------------------------------------
# Verificar / instalar package manager
# -----------------------------------------------------------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    step "Instalando Homebrew (necesita ~5 min)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  ok "Homebrew disponible"
  PKG_INSTALL="brew install"
elif [[ "$PLATFORM" == "linux" ]]; then
  if command -v apt-get >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt-get install -y"
    sudo apt-get update -y
  elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="sudo dnf install -y"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
  else
    fail "No detecte apt/dnf/pacman. Instala manualmente node, python, git."
    exit 1
  fi
  ok "Package manager: ${PKG_INSTALL%% *}"
fi

# -----------------------------------------------------------------------------
# Inputs del usuario
# -----------------------------------------------------------------------------
echo ''
step 'Configuracion del workspace'

if $EXPRESS; then
  ok 'Modo Express: usando defaults / params sin preguntar'
  WORKSPACE="${WORKSPACE:-$HOME/TRABAJOS}"
  USER_NAME="${USER_NAME:-Bootcamp User}"
  COMPANY="${COMPANY:-FourG Solutions}"
  EMAIL="${EMAIL:-user@example.com}"
  [[ "$INSTALL_VSCODE" == "ask" ]] && INSTALL_VSCODE="true"
  [[ "$INSTALL_IAC"    == "ask" ]] && INSTALL_IAC="false"
else
  WORKSPACE="${WORKSPACE:-$(read_default 'Donde queres crear el workspace?' "$HOME/TRABAJOS")}"
  USER_NAME="${USER_NAME:-$(read_default 'Tu nombre completo' 'Mi Nombre')}"
  COMPANY="${COMPANY:-$(read_default 'Tu empresa o marca personal' 'Mi Empresa')}"
  EMAIL="${EMAIL:-$(read_default 'Tu email' 'mi@email.com')}"
  if [[ "$INSTALL_VSCODE" == "ask" ]]; then
    read_yesno 'Instalar VS Code?' y && INSTALL_VSCODE="true" || INSTALL_VSCODE="false"
  fi
  if [[ "$INSTALL_IAC" == "ask" ]]; then
    read_yesno 'Instalar Terraform + AWS CLI?' n && INSTALL_IAC="true" || INSTALL_IAC="false"
  fi
fi

echo ''
info "Workspace : $WORKSPACE"
info "Usuario   : $USER_NAME ($EMAIL)"
info "Empresa   : $COMPANY"
info "VS Code   : $INSTALL_VSCODE"
info "IaC       : $INSTALL_IAC"
echo ''

if ! $EXPRESS; then
  read_yesno 'Confirmar y continuar?' y || { warn 'Cancelado.'; exit 0; }
fi

# -----------------------------------------------------------------------------
# Instalar runtimes
# -----------------------------------------------------------------------------
echo ''
step 'Instalando runtimes'

install_pkg() {
  local pkg="$1" display="$2" cmd="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$display ya instalado: $($cmd --version 2>&1 | head -1)"
    return 0
  fi
  info "Instalando $display ..."
  $PKG_INSTALL "$pkg"
  ok "$display instalado"
}

if [[ "$PLATFORM" == "macos" ]]; then
  install_pkg 'node@20' 'Node.js 20' 'node'
  install_pkg 'python@3.12' 'Python 3.12' 'python3'
  install_pkg 'git' 'Git' 'git'
  if [[ "$INSTALL_VSCODE" == "true" ]]; then
    if ! ls /Applications/"Visual Studio Code.app" >/dev/null 2>&1; then
      brew install --cask visual-studio-code
    else
      ok 'Visual Studio Code ya instalado'
    fi
  fi
  if [[ "$INSTALL_IAC" == "true" ]]; then
    install_pkg 'terraform' 'Terraform' 'terraform'
    install_pkg 'awscli'    'AWS CLI'   'aws'
  fi
else
  install_pkg 'nodejs' 'Node.js' 'node'
  install_pkg 'python3' 'Python 3' 'python3'
  install_pkg 'git' 'Git' 'git'
fi

# -----------------------------------------------------------------------------
# Instalar Claude Code via npm
# -----------------------------------------------------------------------------
echo ''
step 'Instalando Claude Code (npm global)'
if npm list -g --depth=0 2>/dev/null | grep -q '@anthropic-ai/claude-code'; then
  ok 'Claude Code ya instalado'
else
  npm install -g @anthropic-ai/claude-code
  ok 'Claude Code instalado'
fi

# -----------------------------------------------------------------------------
# Crear workspace y copiar scaffold
# -----------------------------------------------------------------------------
echo ''
step "Creando workspace en $WORKSPACE"

SCAFFOLD_SRC="$KIT_ROOT/scaffold"
if [[ ! -d "$SCAFFOLD_SRC" ]]; then
  fail "No se encontro $SCAFFOLD_SRC"
  exit 1
fi

mkdir -p "$WORKSPACE"
cp -R "$SCAFFOLD_SRC"/. "$WORKSPACE"/

# Reemplazar placeholders y renombrar template
TEMPLATE="$WORKSPACE/CLAUDE.md.template"
FINAL="$WORKSPACE/CLAUDE.md"
if [[ -f "$TEMPLATE" ]]; then
  TODAY=$(date +%Y-%m-%d)
  sed \
    -e "s|{{NOMBRE}}|$USER_NAME|g" \
    -e "s|{{EMPRESA}}|$COMPANY|g" \
    -e "s|{{EMAIL}}|$EMAIL|g" \
    -e "s|{{FECHA}}|$TODAY|g" \
    "$TEMPLATE" > "$FINAL"
  rm "$TEMPLATE"
  ok "CLAUDE.md personalizado"
fi

# Marcar scripts ejecutables
chmod +x "$WORKSPACE/shared/scripts"/*.sh 2>/dev/null || true

# -----------------------------------------------------------------------------
# Login Claude Code
# -----------------------------------------------------------------------------
if $SKIP_LOGIN || $EXPRESS; then
  echo ''
  info "Login skippeado. Para autenticarte:  cd $WORKSPACE && claude"
else
  echo ''
  step 'Autenticando Claude Code'
  info 'Se abre el navegador para login con tu cuenta Anthropic.'
  info 'Si no tenes cuenta: https://console.anthropic.com'
  echo ''
  if read_yesno 'Lanzar `claude` ahora?' y; then
    (cd "$WORKSPACE" && claude || true)
  fi
fi

# -----------------------------------------------------------------------------
# Cierre
# -----------------------------------------------------------------------------
echo ''
echo -e "${green}============================================================${reset}"
echo -e "${green}  Listo. Tu workspace esta en:${reset}"
echo -e "${green}  $WORKSPACE${reset}"
echo -e "${green}============================================================${reset}"
echo ''
echo -e "${cyan}Proximos pasos:${reset}"
echo "  1. cd $WORKSPACE"
echo "  2. claude"
echo "  3. Leer docs/01-instalacion.md y docs/02-primer-proyecto.md"
if [[ "$INSTALL_IAC" == "true" ]]; then
  echo ''
  echo -e "${cyan}IaC instalado:${reset}"
  echo '  - Templates en scaffold/infra/'
  echo '  - aws configure  para configurar credenciales'
fi
echo ''
echo -e "${gray}Soporte: four4gsolutions@gmail.com${reset}"
