#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

failed=0
for test in tests/test_gpu.sh tests/test_git.sh tests/test_opencode.sh tests/test_vllm.sh tests/test_e2e.sh; do
  echo "===== $test ====="
  if ! bash "$test"; then failed=$((failed+1)); fi
done

if [ "$failed" -ne 0 ]; then
  echo "NovaCode Cloud Test Suite RESULT: FAIL ($failed test suites failed)"
  exit 1
fi
echo "NovaCode Cloud Test Suite RESULT: PASS"
