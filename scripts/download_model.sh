#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RUNTIME_ENV="/kaggle/working/runtime-selection.env"

if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
else
    SELECTED_MODEL="${PRIMARY_MODEL:-Qwen/Qwen2.5-Coder-7B-Instruct-AWQ}"
fi

echo "[$TIMESTAMP] INFO: Pre-fetching model metadata: $SELECTED_MODEL..."
export HF_HOME="${HF_HOME:-/kaggle/working/cache/huggingface}"
mkdir -p "$HF_HOME"

python3 -c "
from huggingface_hub import snapshot_download
model_id = '$SELECTED_MODEL'
print(f'Fetching model metadata for {model_id}...')
try:
    snapshot_download(repo_id=model_id, allow_patterns=['*.json', 'tokenizer*'])
    print('Model configuration verified successfully.')
except Exception as e:
    print(f'Warning: Pre-fetch warning: {e}')
" || echo "[$TIMESTAMP] WARN: Model pre-fetch warning. vLLM will handle download on startup."

echo "[$TIMESTAMP] INFO: Model download step complete."
