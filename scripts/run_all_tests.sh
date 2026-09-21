#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "NovaCode Cloud Automated Test Suite"
echo "=========================================="

FAILED=0

bash tests/test_gpu.sh || FAILED=$((FAILED+1))
bash tests/test_git.sh || FAILED=$((FAILED+1))
bash tests/test_opencode.sh || FAILED=$((FAILED+1))
bash tests/test_vllm.sh || FAILED=$((FAILED+1))

echo "=========================================="
if [ "$FAILED" -eq 0 ]; then
    echo "NovaCode Cloud Test Suite RESULT: PASS"
else
    echo "NovaCode Cloud Test Suite RESULT: FAIL ($FAILED tests failed)"
    python3 -c "import sys; sys.exit(1)"
fi
echo "=========================================="
