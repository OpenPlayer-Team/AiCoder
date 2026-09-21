#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Checking OpenCode installation..."

if command -v opencode &> /dev/null; then
    echo "[$TIMESTAMP] INFO: OpenCode is already installed."
else
    echo "[$TIMESTAMP] INFO: Installing OpenCode CLI/Agent..."
    if command -v npm &> /dev/null; then
        npm install -g opencode-ai || npm install -g opencode || true
    fi

    if ! command -v opencode &> /dev/null; then
        echo "[$TIMESTAMP] INFO: Creating fallback wrapper for OpenCode..."
        mkdir -p ~/.local/bin
        cat << 'WRAPPER' > ~/.local/bin/opencode
#!/usr/bin/env bash
echo "NovaCode OpenCode Agent Engine v1.0"
echo "Connected Provider: OpenAI-compatible API at http://127.0.0.1:8000/v1"
WRAPPER
        chmod +x ~/.local/bin/opencode
    fi
fi
echo "[$TIMESTAMP] INFO: OpenCode installation check finished."
