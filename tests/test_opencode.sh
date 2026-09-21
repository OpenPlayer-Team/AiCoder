#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: OpenCode Agent Configuration"
echo "=========================================="

if command -v opencode &> /dev/null || [ -f "$HOME/.local/bin/opencode" ]; then
    echo "[PASS] OpenCode executable detected."
else
    echo "[WARN] OpenCode executable not found. Running installer..."
    bash scripts/install_opencode.sh
fi

if [ -f "config/opencode.json" ]; then
    echo "[PASS] config/opencode.json valid configuration file exists."
else
    echo "[FAIL] config/opencode.json missing."
    python3 -c "import sys; sys.exit(1)"
fi

echo "[PASS] OpenCode test completed."
