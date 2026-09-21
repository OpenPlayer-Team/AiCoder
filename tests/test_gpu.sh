#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: GPU & CUDA Capability Detection"
echo "=========================================="

if command -v nvidia-smi &> /dev/null; then
    echo "[PASS] nvidia-smi utility present."
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1 || echo "Unknown")
    echo "Detected GPU: $GPU_NAME"
else
    echo "[WARN] nvidia-smi not present (Running in CPU mode)."
fi

echo "[PASS] GPU test completed."
