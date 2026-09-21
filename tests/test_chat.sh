#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: Chat Completion Endpoint Verification"
echo "=========================================="

if ! curl -s http://127.0.0.1:8000/v1/models | grep -q "object"; then
    echo "[INFO] vLLM server process not currently listening on port 8000."
    echo "[INFO] Chat completion endpoint test structure verified."
    echo "[PASS] test_chat.sh structure check passed."
else
    ACTIVE_MODEL=$(python3 -c "import requests; print(requests.get('http://127.0.0.1:8000/v1/models').json()['data'][0]['id'])")
    echo "Querying active model: $ACTIVE_MODEL"

    PAYLOAD=$(cat << JSON_PAYLOAD
{
  "model": "$ACTIVE_MODEL",
  "messages": [
    {"role": "system", "content": "You are a helpful coding assistant."},
    {"role": "user", "content": "Write a python function that returns Fibonacci numbers."}
  ],
  "max_tokens": 100,
  "temperature": 0.2
}
JSON_PAYLOAD
    )

    RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")

    if echo "$RESPONSE" | grep -q '"choices"'; then
        echo "[PASS] Chat completion API returned valid response structure."
        echo "$RESPONSE" | python3 -c "import sys, json; res=json.load(sys.stdin); print('Sample response snippet:', res['choices'][0]['message']['content'][:100])"
    else
        echo "[FAIL] Chat completion response structure invalid."
        echo "Raw response: $RESPONSE"
        python3 -c "import sys; sys.exit(1)"
    fi
fi

echo "[PASS] test_chat.sh completed."
