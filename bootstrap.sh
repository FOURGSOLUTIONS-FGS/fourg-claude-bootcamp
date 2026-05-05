#!/usr/bin/env bash
# FourG Claude Code Bootcamp - Bootstrap remoto (curl | bash)
#
# Uso interactivo:
#   curl -fsSL https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.sh | bash
#
# Uso express (con args):
#   curl -fsSL https://raw.githubusercontent.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/main/bootstrap.sh | bash -s -- --express --name "Juan" --email "j@x.com"
#
# Descarga el ZIP del repo, lo descomprime en /tmp y lanza install.sh.
#
# Autor:   Adrian Garzon - FourG Solutions
# Version: 1.1.0

set -euo pipefail

cyan='\033[1;36m'; green='\033[1;32m'; red='\033[1;31m'; gray='\033[0;37m'; reset='\033[0m'

echo ''
echo -e "${cyan}============================================================${reset}"
echo -e "${cyan}  FourG Claude Code Bootcamp - Bootstrap${reset}"
echo -e "${cyan}============================================================${reset}"
echo ''

# Pre-checks
for cmd in curl unzip; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo -e "${red}    XX  $cmd no esta instalado.${reset}"
    if [[ "$(uname -s)" == "Darwin" ]]; then
      echo -e "${gray}        Instalalo con: brew install $cmd${reset}"
    else
      echo -e "${gray}        Instalalo con: sudo apt-get install $cmd  (o equivalente)${reset}"
    fi
    exit 1
  fi
done
echo -e "    ${green}OK${reset}  curl + unzip disponibles"

# Variables
REPO_URL='https://github.com/FOURGSOLUTIONS-FGS/fourg-claude-bootcamp/archive/refs/heads/main.zip'
TS=$(date +%Y%m%d%H%M%S)
TMP_ROOT="/tmp/fourg-bootcamp-$TS"
ZIP_PATH="$TMP_ROOT.zip"
KIT_DIR="$TMP_ROOT/fourg-claude-bootcamp-main"

# Descargar
echo ''
echo -e "${cyan}==> Descargando bootcamp${reset}"
curl -fsSL "$REPO_URL" -o "$ZIP_PATH"
size=$(du -h "$ZIP_PATH" | cut -f1)
echo -e "    ${green}OK${reset}  ZIP descargado ($size) -> $ZIP_PATH"

# Descomprimir
echo ''
echo -e "${cyan}==> Descomprimiendo${reset}"
mkdir -p "$TMP_ROOT"
unzip -q "$ZIP_PATH" -d "$TMP_ROOT"
echo -e "    ${green}OK${reset}  Listo en $KIT_DIR"

# Lanzar install.sh
INSTALLER="$KIT_DIR/install.sh"
if [[ ! -f "$INSTALLER" ]]; then
  echo -e "${red}    XX  No se encontro $INSTALLER${reset}"
  exit 1
fi

chmod +x "$INSTALLER"

echo ''
echo -e "${cyan}==> Lanzando install.sh${reset}"
echo ''

cd "$KIT_DIR"
bash "$INSTALLER" "$@"

echo ''
echo -e "${gray}Tip: el bootcamp quedo en $KIT_DIR (lo podes borrar despues).${reset}"
