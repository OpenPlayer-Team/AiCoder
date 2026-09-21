#!/usr/bin/env bash
set -euo pipefail

TS() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '[%s] [%s] [OpenCode] %s\n' "$TS" "$1" "$2"; }

if command -v opencode >/dev/null 2>&1; then
  version="$(opencode --version 2>&1)" || { log ERROR "Existing opencode executable failed --version"; exit 1; }
  log INFO "OpenCode already installed: $version"
  exit 0
fi

log INFO "Installing the real OpenCode CLI."
if command -v npm >/dev/null 2>&1; then
  npm install -g @opencode/cli
elif command -v bun >/dev/null 2>&1; then
  bun install -g --trust @opencode/cli
else
  log ERROR "Neither npm nor bun is available."
  exit 1
fi

command -v opencode >/dev/null 2>&1 || { log ERROR "OpenCode executable not found after installation."; exit 1; }
opencode --version >/dev/null 2>&1 || { log ERROR "Installed OpenCode failed --version."; exit 1; }
log INFO "Verified real OpenCode: $(opencode --version 2>&1)"
