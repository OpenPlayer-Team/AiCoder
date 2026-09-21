#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [Deps] %s\n' "$TS" "$1" "$2"; }

export HF_HOME="${HF_HOME:-/kaggle/working/cache/huggingface}"
mkdir -p "$HF_HOME"

PYTHON_VERSION="$(python3 -c 'import sys; print(".".join(map(str,sys.version_info[:3])))')"
log INFO "Python $PYTHON_VERSION"

if python3 -c 'import torch' >/dev/null 2>&1; then
  log INFO "Using preinstalled PyTorch: $(python3 -c 'import torch; print(torch.__version__)')"
else
  log INFO "PyTorch not present; installing the environment default package."
  python3 -m pip install torch
fi

python3 -m pip install -U "transformers>=4.45" "huggingface-hub>=0.25" "accelerate>=0.34" "openai>=1.50" requests
log INFO "Core Python dependencies ready; CUDA/PyTorch are not forcibly replaced."
