#!/usr/bin/env bash
# =============================================================================
#  install.sh — install `buildit` as a global command
# =============================================================================
#  Does:
#   1. Copies ./buildit → ~/.local/bin/buildit (on PATH for modern distros)
#   2. Ensures ~/.local/bin is on PATH via ~/.bashrc (idempotent)
#   3. Writes a starter config at ~/.config/ai-duet/config (if absent)
#   4. Installs bash tab-completion (low/med/high/status/reset + flags)
#  Re-running is safe; it won't clobber an existing config.
# =============================================================================
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SRC_DIR/buildit"
BIN_DIR="$HOME/.local/bin"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai-duet"
COMP_DIR="$HOME/.local/share/bash-completion/completions"
BASHRC="$HOME/.bashrc"

c_g=$'\e[32m'; c_y=$'\e[33m'; c_b=$'\e[1m'; c_0=$'\e[0m'
say(){ printf '%s\n' "$*"; }
ok(){  printf '%s✔ %s%s\n' "$c_g" "$*" "$c_0"; }
warn(){ printf '%s⚠ %s%s\n' "$c_y" "$*" "$c_0"; }

[[ -f "$SCRIPT" ]] || { echo "Can't find ./buildit next to this installer."; exit 1; }

# 1. Install the command -------------------------------------------------------
mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT" "$BIN_DIR/buildit"
ok "Installed $BIN_DIR/buildit"

# 2. PATH ----------------------------------------------------------------------
if ! printf '%s' ":$PATH:" | grep -q ":$BIN_DIR:"; then
  if ! grep -qsF 'ai-duet:PATH' "$BASHRC"; then
    {
      echo ''
      echo '# ai-duet:PATH — added by buildit installer'
      echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >>"$BASHRC"
    ok "Added ~/.local/bin to PATH in $BASHRC"
    warn "Run:  source ~/.bashrc   (or open a new terminal) to pick it up."
  fi
else
  ok "~/.local/bin already on PATH"
fi

# 3. Starter config ------------------------------------------------------------
mkdir -p "$CFG_DIR"
if [[ ! -f "$CFG_DIR/config" ]]; then
  cat >"$CFG_DIR/config" <<'EOF'
# buildit config — plain shell, sourced before each run. Edit freely.
# These OVERRIDE the script defaults; CLI flags still override these.

# --- Commands (change GEMINI_BIN after the Antigravity migration) ------------
# CLAUDE_BIN="claude"
# GEMINI_BIN="gemini"

# --- Retune what each tier means --------------------------------------------
# Claude aliases: haiku | sonnet | opus  (or e.g. claude-fable-5 for Mythos tier)
# Gemini: gemini-2.5-flash | gemini-2.5-pro  (set gemini-3-pro if you have access)
# T_high_claude="opus"
# T_high_gemini="gemini-2.5-pro"
# T_med_gemini="gemini-2.5-flash"

# --- Behaviour ---------------------------------------------------------------
# HUMAN_GATES=false       # default is false (no pausing); set true to add gates
# PACE_SECONDS=4          # raise to nurse the claude -p Agent SDK credit pool
# AUTO_COMMIT=true        # orchestrator commits code (clean, no AI co-author)
# JOURNAL_DIGEST=false    # true = spend a cheap call to summarise each phase
# DEFAULT_TIER="med"
EOF
  ok "Wrote starter config → $CFG_DIR/config"
else
  ok "Config already exists → $CFG_DIR/config (left untouched)"
fi

# 4. Bash completion -----------------------------------------------------------
mkdir -p "$COMP_DIR"
cat >"$COMP_DIR/buildit" <<'EOF'
_buildit() {
  local cur prev; cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"
  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "low med high status reset --help --dry-run" -- "$cur") ); return
  fi
  case "$prev" in
    --lead) COMPREPLY=( $(compgen -W "claude gemini" -- "$cur") ); return;;
    -d|--dir) COMPREPLY=( $(compgen -d -- "$cur") ); return;;
  esac
  COMPREPLY=( $(compgen -W "-d --dir --restart --dry-run --rounds --lead --no-gates --no-tests --parallel -y --yolo -h --help" -- "$cur") )
}
complete -F _buildit buildit
EOF
ok "Installed bash completion → $COMP_DIR/buildit"
# Make sure completions dir is sourced even without the bash-completion package.
if ! grep -qsF 'ai-duet:COMPLETION' "$BASHRC"; then
  {
    echo ''
    echo '# ai-duet:COMPLETION — added by buildit installer'
    echo "[ -f \"$COMP_DIR/buildit\" ] && source \"$COMP_DIR/buildit\""
  } >>"$BASHRC"
fi

say ''
ok  "Done. Try:  ${c_b}buildit high \"a FastAPI todo API with JWT auth\"${c_0}"
say "    (cd into a project first — buildit works in the current directory and resumes there.)"
warn "Gemini CLI note: the individual/Pro/Ultra tiers stop serving on 2026-06-18 →"
say  "    migrate to Antigravity CLI, then set GEMINI_BIN + T_*_gemini in $CFG_DIR/config."
