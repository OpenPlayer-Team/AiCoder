#!/usr/bin/env bash
set -euo pipefail
python3 -c 'import vllm; print("[PASS] vLLM", vllm.__version__)' || { echo "[FAIL] vLLM import"; exit 1; }
BASE_URL="${VLLM_BASE_URL:-http://127.0.0.1:8000/v1}"
curl -fsS --max-time 10 "$BASE_URL/models" >/tmp/novacode-test-models.json || { echo "[FAIL] vLLM /v1/models"; exit 1; }
python3 - /tmp/novacode-test-models.json <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); assert d.get("data")
print("[PASS] vLLM model endpoint")
PY
