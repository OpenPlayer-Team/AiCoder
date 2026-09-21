#!/usr/bin/env bash
set -euo pipefail

ROOT="/kaggle/working/novacode-cloud"
cd "$ROOT"

bash scripts/detect_environment.sh
bash scripts/start_vllm.sh
bash scripts/healthcheck.sh
bash scripts/install_opencode.sh
bash scripts/start_opencode.sh

# Final validation is intentionally real: failures propagate.
bash tests/test_e2e.sh

echo "=========================================="
echo "NovaCode Cloud startup validation: PASS"
echo "=========================================="
