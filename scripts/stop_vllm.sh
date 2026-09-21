#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [VLLM] Stopping active vLLM process..."

if pgrep -f "vllm.entrypoints.openai.api_server" > /dev/null; then
    pkill -f "vllm.entrypoints.openai.api_server" || true
    echo "[$TIMESTAMP] [INFO] [VLLM] Sent termination signal to vLLM process."
    sleep 2
else
    echo "[$TIMESTAMP] [INFO] [VLLM] No active vLLM process found."
fi

if lsof -t -i :8000 > /dev/null 2>&1; then
    echo "[$TIMESTAMP] [WARN] [VLLM] Port 8000 is still occupied. Killing process on port 8000..."
    kill -9 $(lsof -t -i :8000) 2>/dev/null || true
fi

echo "[$TIMESTAMP] [INFO] [VLLM] vLLM stop procedure completed."
