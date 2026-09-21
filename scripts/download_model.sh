#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RUNTIME_ENV="/kaggle/working/runtime-selection.env"

if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
else
    SELECTED_MODEL="${PRIMARY_MODEL:-Qwen/Qwen2.5-Coder-7B-Instruct-AWQ}"
fi

echo "[$TIMESTAMP] [INFO] [MODEL] Verifying & downloading model weights/config for: $SELECTED_MODEL..."
export HF_HOME="${HF_HOME:-/kaggle/working/cache/huggingface}"
mkdir -p "$HF_HOME"

python3 -c "
from huggingface_hub import snapshot_download
import sys

model_id = '$SELECTED_MODEL'
print(f'Fetching model assets for {model_id}...')
try:
    snapshot_download(
        repo_id=model_id,
        allow_patterns=['*.json', '*.safetensors', 'model.safetensors.index.json', 'tokenizer*']
    )
    print('Model download and verification completed successfully.')
except Exception as e:
    print(f'Error downloading model {model_id}: {e}', file=sys.stderr)
    sys.exit(1)
"

echo "[$TIMESTAMP] [INFO] [MODEL] Model download verification PASSED."
