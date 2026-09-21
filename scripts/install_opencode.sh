#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [OPENCODE] Installing genuine OpenCode AI CLI Agent..."

if command -v opencode &> /dev/null; then
    VER=$(opencode --version 2>/dev/null || echo "installed")
    echo "[$TIMESTAMP] [INFO] [OPENCODE] OpenCode is already installed (version: $VER)."
else
    echo "[$TIMESTAMP] [INFO] [OPENCODE] Installing OpenCode via npm..."
    if command -v npm &> /dev/null; then
        npm install -g opencode-ai || npm install -g opencode || true
    fi

    if ! command -v opencode &> /dev/null; then
        echo "[$TIMESTAMP] [ERROR] [OPENCODE] Failed to install real OpenCode binary via npm."
        echo "[$TIMESTAMP] [ERROR] [OPENCODE] Genuine OpenCode CLI agent is required. Aborting installation."
        python3 -c "import sys; sys.exit(1)"
    else
        VER=$(opencode --version 2>/dev/null || echo "installed")
        echo "[$TIMESTAMP] [INFO] [OPENCODE] OpenCode successfully installed (version: $VER)."
    fi
fi
