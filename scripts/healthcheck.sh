#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ printf '[%s] [%s] [Health] %s\n' "$TS" "$1" "$2"; }

BASE_URL="${VLLM_BASE_URL:-http://127.0.0.1:8000/v1}"
LOG_DIR="${LOG_DIR:-/kaggle/working/logs}"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/healthcheck-report.txt"
: > "$REPORT"
PASS=0
FAIL=0
SKIP=0

check_pass(){ echo "[PASS] $1" | tee -a "$REPORT"; PASS=$((PASS+1)); }
check_fail(){ echo "[FAIL] $1" | tee -a "$REPORT"; FAIL=$((FAIL+1)); }
check_skip(){ echo "[SKIP] $1" | tee -a "$REPORT"; SKIP=$((SKIP+1)); }

if command -v nvidia-smi >/dev/null 2>&1; then check_pass "GPU utility"; else check_skip "GPU utility (CPU host)"; fi

if pgrep -f 'vllm.*(serve|api_server)' >/dev/null 2>&1; then
  check_pass "vLLM process"
else
  check_fail "vLLM process"
fi

if curl -fsS --max-time 5 "$BASE_URL/models" >/tmp/novacode_models.json 2>/dev/null; then
  check_pass "vLLM /v1/models"
else
  check_fail "vLLM /v1/models"
  echo "OVERALL RESULT: FAIL" | tee -a "$REPORT"
  exit 1
fi

MODEL_ID="$(python3 - /tmp/novacode_models.json <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
data=d.get("data") or []
if not data or not data[0].get("id"):
    raise SystemExit(1)
print(data[0]["id"])
PY
)" || { check_fail "model identity"; exit 1; }
check_pass "model identity: $MODEL_ID"

CHAT_RESPONSE="$(curl -fsS --max-time 120 -X POST "$BASE_URL/chat/completions"   -H 'Content-Type: application/json'   -H 'Authorization: Bearer EMPTY'   -d "$(python3 - "$MODEL_ID" <<'PY'
import json,sys
print(json.dumps({"model":sys.argv[1],"messages":[{"role":"user","content":"Reply with exactly OK."}],"max_tokens":8}))
PY
)")" || { check_fail "chat completion"; echo "OVERALL RESULT: FAIL" | tee -a "$REPORT"; exit 1; }

python3 - "$CHAT_RESPONSE" <<'PY' >/dev/null
import json,sys
d=json.loads(sys.argv[1])
assert isinstance(d.get("choices"),list) and d["choices"]
assert isinstance(d["choices"][0].get("message",{}).get("content"),str)
PY
check_pass "chat completion"

echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP" | tee -a "$REPORT"
if [ "$FAIL" -gt 0 ]; then
  echo "OVERALL RESULT: FAIL" | tee -a "$REPORT"
  exit 1
fi
echo "OVERALL RESULT: PASS" | tee -a "$REPORT"
