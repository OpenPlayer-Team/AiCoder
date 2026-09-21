#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_DIR="${LOG_DIR:-/kaggle/working/logs}"
mkdir -p "$LOG_DIR"

echo "[$TIMESTAMP] INFO: Running Healthcheck..."

if command -v nvidia-smi &> /dev/null; then
    echo "[OK] GPU Hardware detected."
else
    echo "[WARN] GPU Hardware not present (CPU fallback mode)."
fi

if lsof -t -i :8000 > /dev/null 2>&1 || nc -z 127.0.0.1 8000 2>/dev/null; then
    echo "[OK] HTTP Server listening on port 8000."
else
    echo "[FAIL] HTTP server on port 8000 is unreachable."
    echo "Reason: vLLM process is not running or failed during startup."
    echo "Suggested action: Check log file at /kaggle/working/logs/vllm.log"
    python3 -c "import sys; sys.exit(1)"
fi

HEALTH_RESP=$(curl -s http://127.0.0.1:8000/v1/models || echo "FAILED")
if echo "$HEALTH_RESP" | grep -q "object"; then
    echo "[OK] vLLM /v1/models endpoint active."
else
    echo "[FAIL] Model server endpoint returned invalid response."
    python3 -c "import sys; sys.exit(1)"
fi

TEST_PAYLOAD='{"model":"Qwen/Qwen2.5-Coder-7B-Instruct-AWQ","messages":[{"role":"user","content":"Respond OK"}],"max_tokens":10}'
COMPLETION_RESP=$(curl -s -X POST http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "$TEST_PAYLOAD" || echo "FAILED")

if echo "$COMPLETION_RESP" | grep -q "choices"; then
    echo "[OK] Test completion inference successful."
else
    echo "[WARN] Inference response test did not return expected json, but API endpoint is active."
fi

echo "[$TIMESTAMP] INFO: Healthcheck PASSED."
