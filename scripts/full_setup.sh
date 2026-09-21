#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================="
echo "NovaCode Cloud - Full Automation Setup"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="

SCRIPT_DIR="$(dirname "$0")"

echo "[1/7] Recovering & Syncing Git repository..."
"$SCRIPT_DIR/git_resume.sh"

echo "[2/7] Detecting hardware capability & evaluating model..."
"$SCRIPT_DIR/detect_environment.sh"

echo "[3/7] Installing dependencies..."
"$SCRIPT_DIR/install_dependencies.sh"

echo "[4/7] Ensuring vLLM engine is installed..."
"$SCRIPT_DIR/install_vllm.sh"

echo "[5/7] Installing OpenCode Agent..."
"$SCRIPT_DIR/install_opencode.sh"

echo "[6/7] Pre-fetching model metadata..."
"$SCRIPT_DIR/download_model.sh"

echo "[7/7] Generating environment diagnostic report..."
"$SCRIPT_DIR/environment_report.sh"

echo "=========================================="
echo "Full Setup Phase Complete! Ready for runtime start."
echo "=========================================="
