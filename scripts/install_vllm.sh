#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [vLLM] %s\n' "$TS" "$1" "$2"; }

if python3 -c 'import vllm' >/dev/null 2>&1; then
  log INFO "Using preinstalled vLLM $(python3 -c 'import vllm; print(vllm.__version__)')"
else
  log INFO "Installing current vLLM package for the detected runtime."
  python3 -m pip install -U vllm
  python3 -c 'import vllm; print("[PASS] vLLM", vllm.__version__)'
fi
