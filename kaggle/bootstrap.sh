#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [KAGGLE] Bootstrapping NovaCode Cloud Environment..."

WORKDIR="/kaggle/working"
mkdir -p "$WORKDIR/cache" "$WORKDIR/logs"

TOKEN="${GITHUB_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    if python3 -c "from kaggle_secrets import UserSecretsClient" &> /dev/null; then
        echo "[$TIMESTAMP] [INFO] [KAGGLE] Attempting Kaggle Secrets retrieval..."
        TOKEN=$(python3 -c "
from kaggle_secrets import UserSecretsClient
try:
    print(UserSecretsClient().get_secret('GITHUB_TOKEN'))
except Exception:
    print('')
" 2>/dev/null || echo "")
    fi
fi

if [ -n "$TOKEN" ]; then
    export GITHUB_TOKEN="$TOKEN"
    echo "[$TIMESTAMP] [INFO] [KAGGLE] GITHUB_TOKEN authenticated."
fi

cd "$WORKDIR"
if [ ! -d "novacode-cloud" ]; then
    echo "[$TIMESTAMP] [INFO] [KAGGLE] Cloning repository into $WORKDIR/novacode-cloud..."
    git clone https://github.com/OpenPlayer-Team/AiCoder.git novacode-cloud || true
fi

if [ -d "novacode-cloud" ]; then
    cd novacode-cloud
    bash scripts/full_setup.sh
fi

echo "[$TIMESTAMP] [INFO] [KAGGLE] Bootstrap execution complete."
