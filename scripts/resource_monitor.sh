#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "NovaCode Cloud - Real-time Resource Monitor"
echo "=========================================="

if command -v nvidia-smi &> /dev/null; then
    echo "--- GPU Status ---"
    nvidia-smi --query-gpu=name,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu --format=csv
else
    echo "--- GPU Status ---"
    echo "No NVIDIA GPU detected."
fi

echo ""
echo "--- System Memory Status ---"
free -h

echo ""
echo "--- CPU Load Status ---"
uptime

echo ""
echo "--- Active vLLM Processes ---"
pgrep -af "vllm" || echo "No vLLM process active."

echo "=========================================="
