#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Stopping active vLLM process..."

if pgrep -f "vllm.entrypoints.openai.api_server" > /dev/null; then
    pkill -f "vllm.entrypoints.openai.api_server" || true
    echo "[$TIMESTAMP] INFO: Sent termination signal to vLLM."
    sleep 2
else
    echo "[$TIMESTAMP] INFO: No active vLLM server found."
fi

if lsof -t -i :8000 > /dev/null 2>&1; then
    echo "[$TIMESTAMP] WARN: Port 8000 still occupied. Forcing release..."
    kill -9 $(lsof -t -i :8000) 2>/dev/null || true
fi

echo "[$TIMESTAMP] INFO: vLLM stop procedure complete."
