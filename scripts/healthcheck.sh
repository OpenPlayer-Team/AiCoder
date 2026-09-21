#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_DIR="${LOG_DIR:-logs}"
mkdir -p "$LOG_DIR"

echo "[$TIMESTAMP] [INFO] [HEALTHCHECK] Running system healthcheck..."

# Test 1: GPU
if command -v nvidia-smi &> /dev/null; then
    echo "[PASS] GPU hardware detected."
else
    echo "[INFO] GPU hardware not detected (CPU mode)."
fi

# Test 2: HTTP Port 8000
if lsof -t -i :8000 > /dev/null 2>&1 || nc -z 127.0.0.1 8000 2>/dev/null; then
    echo "[PASS] HTTP Server listening on port 8000."
else
    echo "[FAIL] HTTP server port 8000 unreachable."
    python3 -c "import sys; sys.exit(1)"
fi

# Test 3: /v1/models endpoint
MODELS_RESP=$(curl -s http://127.0.0.1:8000/v1/models || echo "FAILED")
if echo "$MODELS_RESP" | grep -q "object"; then
    echo "[PASS] vLLM /v1/models endpoint active."
else
    echo "[FAIL] /v1/models API endpoint returned invalid response."
    python3 -c "import sys; sys.exit(1)"
fi

# Test 4: Dynamic Chat Completion Test
ACTIVE_MODEL=$(python3 -c "import requests; print(requests.get('http://127.0.0.1:8000/v1/models').json()['data'][0]['id'])" 2>/dev/null || echo "Qwen/Qwen2.5-Coder-7B-Instruct-AWQ")

TEST_PAYLOAD=$(cat << JSON_PAYLOAD
{
  "model": "$ACTIVE_MODEL",
  "messages": [{"role": "user", "content": "Respond with OK"}],
  "max_tokens": 10
}
JSON_PAYLOAD
)

COMPLETION_RESP=$(curl -s -X POST http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "$TEST_PAYLOAD" || echo "FAILED")

if echo "$COMPLETION_RESP" | grep -q "choices"; then
    echo "[PASS] Dynamic Chat completion test successful (Model: $ACTIVE_MODEL)."
else
    echo "[FAIL] Chat completion test failed."
    python3 -c "import sys; sys.exit(1)"
fi

echo "[$TIMESTAMP] [INFO] [HEALTHCHECK] All core healthchecks PASSED."
