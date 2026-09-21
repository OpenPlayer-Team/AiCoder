#!/usr/bin/env bash
set -euo pipefail
command -v opencode >/dev/null 2>&1 || { echo "[FAIL] OpenCode executable missing"; exit 1; }
version="$(opencode --version 2>&1)" || { echo "[FAIL] OpenCode --version failed"; exit 1; }
echo "[PASS] OpenCode $version"
test -f config/opencode.json || { echo "[FAIL] OpenCode provider config missing"; exit 1; }
python3 -m json.tool config/opencode.json >/dev/null || { echo "[FAIL] Invalid OpenCode JSON"; exit 1; }
echo "[PASS] OpenCode configuration JSON"
