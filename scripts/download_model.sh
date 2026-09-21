#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [Model] %s\n' "$TS" "$1" "$2"; }
RUNTIME_ENV="${RUNTIME_ENV:-/kaggle/working/runtime-selection.env}"
source "$RUNTIME_ENV"
export HF_HOME="${HF_HOME:-/kaggle/working/cache/huggingface}"
mkdir -p "$HF_HOME"

[ -n "${SELECTED_MODEL:-}" ] || { log ERROR "SELECTED_MODEL is missing."; exit 1; }

python3 - "$SELECTED_MODEL" <<'PY'
import os, sys
from huggingface_hub import snapshot_download
from transformers import AutoConfig, AutoTokenizer

model=sys.argv[1]
cache=os.environ.get("HF_HOME")
path=snapshot_download(repo_id=model, cache_dir=cache)
print("MODEL_SNAPSHOT="+path)
config=AutoConfig.from_pretrained(model, cache_dir=cache)
AutoTokenizer.from_pretrained(model, cache_dir=cache)
print("MODEL_TYPE="+str(getattr(config,"model_type","unknown")))
print("MODEL_CONFIG_OK=1")
PY

log INFO "Model files, configuration and tokenizer verified."
