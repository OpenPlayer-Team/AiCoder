#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [KAGGLE] Executing NovaCode Cloud Startup Sequence..."

cd /kaggle/working/novacode-cloud || cd .

echo "[1/4] Starting vLLM Server..."
bash scripts/start_vllm.sh

echo "[2/4] Executing Healthcheck..."
bash scripts/healthcheck.sh

echo "[3/4] Initializing OpenCode Agent..."
bash scripts/start_opencode.sh

echo "[4/4] System Operational. Resource Status:"
bash scripts/resource_monitor.sh

echo "=========================================="
echo "NovaCode Cloud Backend Engine ACTIVE!"
echo "Server URL: http://127.0.0.1:8000/v1"
echo "=========================================="
