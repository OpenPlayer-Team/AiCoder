#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [Git] %s\n' "$TS" "$1" "$2"; }

BRANCH="${NOVACODE_BRANCH:-novacode-cloud-implementation-8109331521118669701}"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log ERROR "Not inside a Git repository. Bootstrap must clone the repository first."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  log WARN "Uncommitted changes detected; preserving them. No reset/clean/forced checkout will run."
  git status --short
  exit 0
fi

git fetch origin "$BRANCH"
current="$(git branch --show-current)"
if [ "$current" != "$BRANCH" ]; then
  git checkout "$BRANCH"
fi
git pull --ff-only origin "$BRANCH"
log INFO "Repository synchronized on $BRANCH."
