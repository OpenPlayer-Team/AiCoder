#!/usr/bin/env bash
set -euo pipefail

TS(){ date '+%Y-%m-%d %H:%M:%S'; }
LOG_DIR="${LOG_DIR:-/kaggle/working/logs}"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/e2e-report.txt"
: > "$REPORT"
PASS=0; FAIL=0; SKIP=0

pass(){ echo "[PASS] $1" | tee -a "$REPORT"; PASS=$((PASS+1)); }
fail(){ echo "[FAIL] $1" | tee -a "$REPORT"; FAIL=$((FAIL+1)); }
skip(){ echo "[SKIP] $1" | tee -a "$REPORT"; SKIP=$((SKIP+1)); }

echo "========================================" | tee -a "$REPORT"
echo "NovaCode Cloud E2E Validation" | tee -a "$REPORT"
echo "Timestamp: $(TS)" | tee -a "$REPORT"
echo "========================================" | tee -a "$REPORT"

command -v python3 >/dev/null 2>&1 && pass "Python" || fail "Python"
if python3 -c 'import torch; assert torch.cuda.is_available()'; then pass "CUDA/PyTorch"; else skip "CUDA/PyTorch (no GPU in this runtime)"; fi
python3 -c 'import vllm' >/dev/null 2>&1 && pass "vLLM installation" || fail "vLLM installation"

BASE_URL="${VLLM_BASE_URL:-http://127.0.0.1:8000/v1}"
MODELS_JSON="$(curl -fsS --max-time 10 "$BASE_URL/models")" || { fail "vLLM API"; exit 1; }
MODEL="$(python3 - "$MODELS_JSON" <<'PY'
import json,sys
d=json.loads(sys.argv[1]); data=d.get("data") or []
assert data and data[0].get("id")
print(data[0]["id"])
PY
)" || { fail "Model availability"; exit 1; }
pass "vLLM API/model: $MODEL"

CHAT="$(curl -fsS --max-time 120 -X POST "$BASE_URL/chat/completions" -H 'Content-Type: application/json' -H 'Authorization: Bearer EMPTY' -d "$(python3 - "$MODEL" <<'PY'
import json,sys
print(json.dumps({"model":sys.argv[1],"messages":[{"role":"user","content":"Reply with exactly NOVACODE_OK"}],"max_tokens":16}))
PY
)")" || { fail "Chat completion"; exit 1; }
python3 - "$CHAT" <<'PY' >/dev/null
import json,sys
d=json.loads(sys.argv[1]); assert d["choices"][0]["message"]["content"]
PY
pass "Chat completion"

STREAM="$(curl -fsS --max-time 120 -N -X POST "$BASE_URL/chat/completions" -H 'Content-Type: application/json' -H 'Authorization: Bearer EMPTY' -d "$(python3 - "$MODEL" <<'PY'
import json,sys
print(json.dumps({"model":sys.argv[1],"messages":[{"role":"user","content":"Count from 1 to 5."}],"max_tokens":32,"stream":True}))
PY
)")" || { fail "Streaming"; exit 1; }
chunks="$(printf '%s' "$STREAM" | grep -c '^data: ' || true)"
[ "$chunks" -ge 2 ] && pass "Streaming" || { fail "Streaming: expected multiple SSE chunks"; exit 1; }

TOOL_RESP="$(curl -fsS --max-time 120 -X POST "$BASE_URL/chat/completions" -H 'Content-Type: application/json' -H 'Authorization: Bearer EMPTY' -d "$(python3 - "$MODEL" <<'PY'
import json,sys
tool={"type":"function","function":{"name":"get_current_project_info","description":"Return static project information","parameters":{"type":"object","properties":{"name":{"type":"string"}},"required":["name"]},"strict":True}}
print(json.dumps({"model":sys.argv[1],"messages":[{"role":"user","content":"Call get_current_project_info for NovaCode Cloud."}],"tools":[tool],"tool_choice":"required","max_tokens":128}))
PY
)")" || { fail "Tool calling HTTP request"; exit 1; }
python3 - "$TOOL_RESP" <<'PY'
import json,sys
d=json.loads(sys.argv[1]); msg=d["choices"][0]["message"]; calls=msg.get("tool_calls") or []
assert calls, "no tool_calls"
c=calls[0]; assert c["function"]["name"]=="get_current_project_info"
json.loads(c["function"]["arguments"])
PY
pass "Tool calling"

command -v opencode >/dev/null 2>&1 && opencode --version >/dev/null 2>&1 && pass "OpenCode installation" || { fail "OpenCode installation"; exit 1; }

export OPENAI_API_KEY="${OPENAI_API_KEY:-EMPTY}"
export VLLM_BASE_URL="$BASE_URL"
export OPENCODE_MODEL="$MODEL"
export OPENCODE_CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.json}"
bash "$(dirname "$0")/start_opencode.sh"
pass "OpenCode provider configuration"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
git -C "$TMP_DIR" init -q
git -C "$TMP_DIR" config user.email "novacode-e2e@example.invalid"
git -C "$TMP_DIR" config user.name "NovaCode E2E"
printf 'def add(a,b):\n    return a+b\n' > "$TMP_DIR/app.py"
printf 'from app import add\n\ndef test_add():\n    assert add(2,3)==5\n' > "$TMP_DIR/test_app.py"
git -C "$TMP_DIR" add . && git -C "$TMP_DIR" commit -qm "e2e fixture"

if (cd "$TMP_DIR" && OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json" opencode run --model "novacode/$MODEL" "Inspect this tiny Python project. Run the existing test. Then create a file named e2e_result.txt containing exactly E2E_OK. Do not change any other file.") > "$LOG_DIR/opencode-e2e.log" 2>&1; then
  if [ -f "$TMP_DIR/e2e_result.txt" ] && grep -qx 'E2E_OK' "$TMP_DIR/e2e_result.txt"; then
    pass "OpenCode -> vLLM -> model -> tool execution"
  else
    fail "OpenCode coding task did not create the expected file"
  fi
else
  fail "OpenCode run failed; see $LOG_DIR/opencode-e2e.log"
fi

git -C "$TMP_DIR" status --porcelain >/dev/null 2>&1 && pass "Git workspace" || fail "Git workspace"

echo "========================================" | tee -a "$REPORT"
echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP" | tee -a "$REPORT"
if [ "$FAIL" -eq 0 ]; then
  echo "OVERALL RESULT: PASS" | tee -a "$REPORT"
else
  echo "OVERALL RESULT: FAIL" | tee -a "$REPORT"
  exit 1
fi
