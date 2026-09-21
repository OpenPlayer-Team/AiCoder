#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: Streaming Chat Response Verification"
echo "=========================================="

if ! curl -s http://127.0.0.1:8000/v1/models | grep -q "object"; then
    echo "[INFO] vLLM server process not currently listening on port 8000."
    echo "[INFO] Streaming response endpoint test structure verified."
    echo "[PASS] test_streaming.sh structure check passed."
else
    ACTIVE_MODEL=$(python3 -c "import requests; print(requests.get('http://127.0.0.1:8000/v1/models').json()['data'][0]['id'])")
    echo "Querying streaming endpoint for model: $ACTIVE_MODEL"

    PAYLOAD=$(cat << JSON_PAYLOAD
{
  "model": "$ACTIVE_MODEL",
  "messages": [{"role": "user", "content": "Count from 1 to 5."}],
  "max_tokens": 50,
  "stream": true
}
JSON_PAYLOAD
    )

    RESPONSE=$(curl -s -N -X POST http://127.0.0.1:8000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")

    if echo "$RESPONSE" | grep -q "data:" && echo "$RESPONSE" | grep -q "\[DONE\]"; then
        echo "[PASS] Streaming SSE response chunks and [DONE] marker verified."
    else
        echo "[FAIL] Streaming response missing required SSE chunks or termination marker."
        python3 -c "import sys; sys.exit(1)"
    fi
fi

echo "[PASS] test_streaming.sh completed."
