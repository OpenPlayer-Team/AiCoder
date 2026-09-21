#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_DIR="${LOG_DIR:-logs}"
mkdir -p "$LOG_DIR"
REPORT_FILE="$LOG_DIR/e2e-report.txt"

echo "==========================================" | tee "$REPORT_FILE"
echo "NovaCode Cloud E2E Validation Suite" | tee -a "$REPORT_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$REPORT_FILE"
echo "==========================================" | tee -a "$REPORT_FILE"

FAILED=0

run_subtest() {
    local name="$1"
    local cmd="$2"
    echo -n "Evaluating $name ... " | tee -a "$REPORT_FILE"
    if eval "$cmd" > /dev/null 2>&1; then
        echo "[PASS]" | tee -a "$REPORT_FILE"
    else
        echo "[FAIL]" | tee -a "$REPORT_FILE"
        FAILED=$((FAILED+1))
    fi
}

run_subtest "Python Environment" "python3 --version"
run_subtest "GPU & CUDA Detection" "bash tests/test_gpu.sh"
run_subtest "Git Workspace Hygiene" "bash tests/test_git.sh"
run_subtest "OpenCode Configuration" "bash tests/test_opencode.sh"
run_subtest "vLLM Server Checks" "bash tests/test_vllm.sh"
run_subtest "Chat Completion API" "bash tests/test_chat.sh"
run_subtest "Streaming Response API" "bash tests/test_streaming.sh"
run_subtest "Tool Calling Evaluation" "bash tests/test_tool_calling.sh"

echo "==========================================" | tee -a "$REPORT_FILE"
if [ "$FAILED" -eq 0 ]; then
    echo "OVERALL E2E RESULT: PASS" | tee -a "$REPORT_FILE"
else
    echo "OVERALL E2E RESULT: FAIL ($FAILED tests failed)" | tee -a "$REPORT_FILE"
fi
echo "==========================================" | tee -a "$REPORT_FILE"
echo "Full validation report written to $REPORT_FILE"
