#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "NovaCode Cloud Master Test Suite"
echo "=========================================="

bash tests/test_e2e.sh
