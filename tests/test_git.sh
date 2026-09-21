#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "[FAIL] Not a Git worktree"; exit 1; }
grep -q '^\.env' .gitignore || { echo "[FAIL] .env not protected"; exit 1; }
grep -q '^secrets/' .gitignore || { echo "[FAIL] secrets/ not protected"; exit 1; }
if git diff --cached --quiet 2>/dev/null; then :; fi
echo "[PASS] Git workspace and secret ignore rules"
