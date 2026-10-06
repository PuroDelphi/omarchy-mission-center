#!/usr/bin/env bash
# omarchy-mission-center — instalador idempotente
#
# Uso:   ./install.sh
# Todo es reversible; ver "Desinstalación" en README.md.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"
BIN_DEST="$HOME/.local/bin/startup-manager"
MENU_MARKER='"system.tasks"'
BIND_MARKER='-- omarchy-mission-center'

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

step "Paquetes: mission-center + nethogs"
omarchy pkg add mission-center nethogs

step "nethogs: capacidades para red por proceso"
if [[ -n "$(getcap "$(command -v nethogs)" 2>/dev/null)" ]]; then
  echo "    ya configurado"
else
  sudo setcap "cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace+pe" "$(command -v nethogs)"
  echo "    OK"
fi

step "Script: startup-manager → $BIN_DEST"
install -Dm755 "$REPO_DIR/bin/startup-manager" "$BIN_DEST"
echo "    OK"

step "Menú: entradas en System (Task Manager / Startup)"
mkdir -p "$(dirname "$MENU_FILE")"
[[ -f "$MENU_FILE" ]] || printf '{\n}\n' >"$MENU_FILE"
if grep -qF -- "$MENU_MARKER" "$MENU_FILE"; then
  echo "    ya presente"
else
  python3 - "$MENU_FILE" "$REPO_DIR/fragments/menu.jsonc" <<'PY'
import sys

menu_path, frag_path = sys.argv[1], sys.argv[2]
entries = "\n".join(
    l for l in open(frag_path).read().splitlines()
    if l.strip() and not l.strip().startswith("//")
)
src = open(menu_path).read().rstrip("\n")
last = src.rsplit("\n", 1)[-1].strip()
if last != "}":
    sys.exit(
        f"ERROR: {menu_path} no termina en '}}' en la última línea.\n"
        f"Añade a mano las entradas de fragments/menu.jsonc y reintenta."
    )
head = src[: src.rfind(last)].rstrip()
if head and not head.endswith(("{", ",")):
    head += ","
open(menu_path, "w").write(f"{head}\n\n{entries}\n}}\n")
print("    añadido")
PY
  # validar JSONC resultante (comentarios + sin coma final)
  python3 -c "
import json, re, sys
src = open('$MENU_FILE').read()
json.loads(re.sub(r'^\s*//.*$', '', src, flags=re.M))
"
  echo "    JSONC válido"
fi

step "Keybinding: SUPER+SHIFT+ESC → Task Manager"
mkdir -p "$(dirname "$BINDINGS_FILE")"
[[ -f "$BINDINGS_FILE" ]] || : >"$BINDINGS_FILE"
if grep -qF -- "$BIND_MARKER" "$BINDINGS_FILE"; then
  echo "    ya presente"
else
  printf '\n' >>"$BINDINGS_FILE"
  cat "$REPO_DIR/fragments/bindings.lua" >>"$BINDINGS_FILE"
  echo "    añadido"
fi

step "Validación"
command -v hyprctl >/dev/null 2>&1 || { echo "    sin hyprctl: omarchy no detectado, omite validación"; exit 0; }
hyprctl reload >/dev/null 2>&1 || true
sleep 1
errors="$(hyprctl configerrors 2>/dev/null || true)"
if [[ -n "$errors" ]]; then
  echo "    ERRORES de configuración Hyprland:" >&2
  echo "$errors" >&2
  exit 1
fi
echo "    hyprland: sin errores"
omarchy menu refresh >/dev/null 2>&1 || true

cat <<'EOF'

Listo. Replicado al 100%:
  · Task Manager  → SUPER+SHIFT+ESC  (o menú: System → Task Manager)
  · Startup       → menú: System → Startup

Nota: al primer arranque de Mission Center acepta su diálogo de
setup (habilita red por proceso, ventiladores y consumo).
EOF
