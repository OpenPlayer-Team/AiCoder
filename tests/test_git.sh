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
    python3 -c "import sys; sys.exit(1)"
fi

# Test git_resume.sh uncommitted changes handling
echo "--- Testing git_resume.sh uncommitted changes handling ---"
TMP_DIR=$(mktemp -d)
ORIGINAL_DIR=$(pwd)
GIT_RESUME_SCRIPT="$ORIGINAL_DIR/scripts/git_resume.sh"

cd "$TMP_DIR"
git init >/dev/null 2>&1
git config user.email "test@example.com"
git config user.name "Test User"
git commit --allow-empty -m "Initial commit" >/dev/null 2>&1
touch dummy_file.txt
git add dummy_file.txt

OUTPUT=$(bash "$GIT_RESUME_SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "Local uncommitted changes detected in Kaggle workspace!"; then
    echo "[PASS] git_resume.sh correctly detects uncommitted changes."
else
    echo "[FAIL] git_resume.sh did not detect uncommitted changes."
    echo "Output was:"
    echo "$OUTPUT"
    cd "$ORIGINAL_DIR"
    rm -rf "$TMP_DIR"
    python3 -c "import sys; sys.exit(1)"
fi

git commit -m "Commit dummy file" >/dev/null 2>&1
OUTPUT_CLEAN=$(bash "$GIT_RESUME_SCRIPT" 2>&1 || true)
if echo "$OUTPUT_CLEAN" | grep -q "Working tree clean."; then
    echo "[PASS] git_resume.sh correctly detects clean working tree."
else
    echo "[FAIL] git_resume.sh did not detect clean working tree."
    echo "Output was:"
    echo "$OUTPUT_CLEAN"
    cd "$ORIGINAL_DIR"
    rm -rf "$TMP_DIR"
    python3 -c "import sys; sys.exit(1)"
fi

cd "$ORIGINAL_DIR"
rm -rf "$TMP_DIR"

echo "[PASS] Git test completed."
