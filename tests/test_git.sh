#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "TEST: Git Workspace & Security Verification"
echo "=========================================="

if [ -d ".git" ]; then
    echo "[PASS] Git repository initialized."
else
    echo "[WARN] Not currently inside a Git repository."
fi

# Security check: Ensure secret patterns in .gitignore
if grep -q "\.env" .gitignore && grep -q "secrets/" .gitignore; then
    echo "[PASS] .gitignore correctly protects sensitive files and tokens."
else
    echo "[FAIL] .gitignore missing security filters."
    exit 1
fi

echo "[PASS] Git test completed."
