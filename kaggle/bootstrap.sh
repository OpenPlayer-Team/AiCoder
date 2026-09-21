#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [Bootstrap] %s\n' "$TS" "$1" "$2"; }

WORKDIR="${NOVACODE_WORKDIR:-/kaggle/working/novacode-cloud}"
REPO="${GITHUB_REPO:-OpenPlayer-Team/AiCoder}"
BRANCH="${NOVACODE_BRANCH:-novacode-cloud-implementation-8109331521118669701}"
mkdir -p /kaggle/working/cache /kaggle/working/logs

if [ ! -d "$WORKDIR/.git" ]; then
  mkdir -p "$(dirname "$WORKDIR")"
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    CRED_FILE="$(mktemp)"
    chmod 600 "$CRED_FILE"
    printf 'https://x-oauth-basic:%s@github.com\n' "$GITHUB_TOKEN" > "$CRED_FILE"
    git -c credential.helper="store --file=$CRED_FILE" clone --branch "$BRANCH" "https://github.com/$REPO.git" "$WORKDIR"
    rm -f "$CRED_FILE"
  else
    git clone --branch "$BRANCH" "https://github.com/$REPO.git" "$WORKDIR"
  fi
fi

cd "$WORKDIR"
if [ -n "$(git status --porcelain)" ]; then
  log WARN "Uncommitted changes detected; preserving them and skipping sync."
else
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull --ff-only origin "$BRANCH"
fi

export LOG_DIR="/kaggle/working/logs"
bash scripts/full_setup.sh
log INFO "Bootstrap completed."
