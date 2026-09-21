#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [OPENCODE] Configuring OpenCode provider integration..."

if ! command -v opencode &> /dev/null; then
    echo "[$TIMESTAMP] [ERROR] [OPENCODE] opencode command not found. Run scripts/install_opencode.sh first."
    python3 -c "import sys; sys.exit(1)"
fi

RUNTIME_ENV="/kaggle/working/runtime-selection.env"
if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
fi

MODEL_ID="${SELECTED_MODEL:-Qwen/Qwen2.5-Coder-7B-Instruct-AWQ}"

CONFIG_DIR="$HOME/.config/opencode"
mkdir -p "$CONFIG_DIR"

cat << JSON_OUT > "$CONFIG_DIR/opencode.json"
{
  "\$schema": "https://opencode.ai/config.schema.json",
  "version": "1.0",
  "provider": {
    "type": "openai",
    "baseUrl": "http://127.0.0.1:8000/v1",
    "apiKey": "EMPTY",
    "model": "$MODEL_ID"
  },
  "agent": {
    "name": "NovaCode-Agent",
    "safety": {
      "confirmDestructive": true,
      "disallowForcePush": true,
      "disallowHardReset": true,
      "disallowRootDelete": true
    }
  }
}
JSON_OUT

export OPENAI_API_BASE="http://127.0.0.1:8000/v1"
export OPENAI_API_KEY="EMPTY"

echo "[$TIMESTAMP] [INFO] [OPENCODE] OpenCode configuration written to $CONFIG_DIR/opencode.json"
echo "[$TIMESTAMP] [INFO] [OPENCODE] Real OpenCode integration ready for backend http://127.0.0.1:8000/v1 ($MODEL_ID)."
