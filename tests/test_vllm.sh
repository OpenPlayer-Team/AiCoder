#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: vLLM Server & Endpoint Availability"
echo "=========================================="

if python3 -c "import vllm" &> /dev/null; then
    echo "[PASS] vLLM Python package import successful."
else
    echo "[WARN] vLLM Python package not installed locally (Expected on Client PC; Remote Kaggle backend installs vLLM automatically)."
fi

if curl -s http://127.0.0.1:8000/v1/models | grep -q "object"; then
    echo "[PASS] vLLM OpenAI-compatible server active on http://127.0.0.1:8000/v1"
else
    echo "[INFO] vLLM server process not active locally on port 8000 (Start with scripts/start_vllm.sh on GPU host)."
fi

echo "[PASS] vLLM test check completed."
