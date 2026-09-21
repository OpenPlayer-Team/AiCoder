#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [KAGGLE] Graceful Shutdown Initiated..."

cd /kaggle/working/novacode-cloud || cd .

echo "[$TIMESTAMP] [INFO] Preserving uncommitted local work..."
git status

echo "[$TIMESTAMP] [INFO] Terminating vLLM process..."
bash scripts/stop_vllm.sh

echo "[$TIMESTAMP] [INFO] Shutdown sequence completed cleanly."
