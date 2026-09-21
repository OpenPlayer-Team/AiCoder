#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Configuring and Starting OpenCode Agent Environment..."

CONFIG_SRC="config/opencode.json"
TARGET_DIR="$HOME/.config/opencode"
mkdir -p "$TARGET_DIR"

if [ -f "$CONFIG_SRC" ]; then
    cp "$CONFIG_SRC" "$TARGET_DIR/opencode.json"
    echo "[$TIMESTAMP] INFO: Copied OpenCode configuration to $TARGET_DIR/opencode.json"
fi

export OPENAI_API_BASE="http://127.0.0.1:8000/v1"
export OPENAI_API_KEY="EMPTY"

echo "[$TIMESTAMP] INFO: OpenCode environment variables configured."
echo "[$TIMESTAMP] INFO: OpenCode Agent Ready."
