#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Installing core dependencies..."

export HF_HOME="${HF_HOME:-/kaggle/working/cache/huggingface}"
mkdir -p "$HF_HOME"

python3 -m pip install --upgrade pip setuptools wheel

if [ -f "requirements.lock.txt" ]; then
    echo "[$TIMESTAMP] INFO: Installing locked dependencies from requirements.lock.txt..."
    python3 -m pip install -r requirements.lock.txt
else
    echo "[$TIMESTAMP] WARN: requirements.lock.txt not found! Installing standard runtime packages..."
    python3 -m pip install torch transformers huggingface-hub accelerate openai fastapi uvicorn pydantic requests
fi

echo "[$TIMESTAMP] INFO: Dependencies installed successfully."
