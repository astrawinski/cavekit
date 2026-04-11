#!/bin/bash

# Cavekit Installer
#
# Usage:
#   git clone https://github.com/astrawinski/cavekit.git ~/.cavekit && ~/.cavekit/install.sh

set -euo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"

# ─── Colors ─────────────────────────────────────────────────────────────────

R=$'\033[0m' B=$'\033[1m' GR=$'\033[32m' YL=$'\033[33m' BL=$'\033[34m' RD=$'\033[31m'

info()  { printf "${BL}▸${R} %s\n" "$1"; }
ok()    { printf "${GR}■${R} %s\n" "$1"; }
warn()  { printf "${YL}!${R} %s\n" "$1"; }
fail()  { printf "${RD}✗${R} %s\n" "$1" >&2; exit 1; }

# ─── Header ─────────────────────────────────────────────────────────────────

printf "\n${B}${BL}  ┌──────────────────────────┐${R}\n"
printf "${B}${BL}  │  C A V E K I T       │${R}\n"
printf "${B}${BL}  └──────────────────────────┘${R}\n"
printf "${B}Installer${R}\n\n"

# ─── Preflight ──────────────────────────────────────────────────────────────

command -v git &>/dev/null || fail "git not found."
command -v codex &>/dev/null || warn "codex CLI not found. Install Codex CLI to invoke Cavekit with \$ck-* skills."
command -v tmux &>/dev/null || warn "tmux not found. Install for the parallel launcher: brew install tmux"

# ─── Sync Codex local plugin ────────────────────────────────────────────────

info "Configuring Codex skill discovery..."

chmod +x "$INSTALL_DIR/scripts/sync-codex-plugin.sh"
"$INSTALL_DIR/scripts/sync-codex-plugin.sh"

# ─── Install cavekit CLI ─────────────────────────────────────────────────

info "Installing cavekit command..."

chmod +x "$INSTALL_DIR/scripts/cavekit"
chmod +x "$INSTALL_DIR/scripts/cavekit-launch-session.sh"
chmod +x "$INSTALL_DIR/scripts/cavekit-status-poller.sh"
chmod +x "$INSTALL_DIR/scripts/cavekit-analytics.sh"
chmod +x "$INSTALL_DIR/scripts/dashboard-progress.sh"
chmod +x "$INSTALL_DIR/scripts/dashboard-activity.sh"
chmod +x "$INSTALL_DIR/scripts/setup-build.sh"

if [[ -w "$BIN_DIR" ]]; then
  ln -sf "$INSTALL_DIR/scripts/cavekit" "$BIN_DIR/cavekit"
  ok "Installed cavekit to $BIN_DIR/cavekit"
else
  info "Need sudo to install cavekit to $BIN_DIR"
  sudo ln -sf "$INSTALL_DIR/scripts/cavekit" "$BIN_DIR/cavekit"
  ok "Installed cavekit to $BIN_DIR/cavekit"
fi

# ─── Done ───────────────────────────────────────────────────────────────────

printf "\n${B}${GR}Installed!${R}\n\n"

printf "  ${B}Terminal:${R}\n"
printf "    cavekit --monitor                 Pick build sites and launch agents\n"
printf "    cavekit --monitor --expanded      One tmux window per build site\n"
printf "    cavekit --status                  Show build site progress\n"
printf "    cavekit --analytics               Show loop trends\n"
printf "    cavekit --kill                    Stop sessions\n"
printf "\n"
printf "  ${B}Codex:${R}\n"
printf "    Open this repo in Codex; skills are discoverable from .agents/skills\n"
printf "    Invoke phases with \$ck-sketch, \$ck-map, \$ck-make, and \$ck-check\n"
printf "    Optional: use cavekit --monitor to run Codex sessions in tmux\n"
printf "\n"
printf "  Restart Codex if it was already running.\n\n"
