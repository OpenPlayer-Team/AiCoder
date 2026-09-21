#!/usr/bin/env bash
set -euo pipefail

# NovaCode Cloud - Kaggle Session Bootstrap Script
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Bootstrapping NovaCode Cloud Environment..."

# 1. Prepare base directories
WORKDIR="/kaggle/working"
mkdir -p "$WORKDIR/cache" "$WORKDIR/logs"

# 2. Extract GitHub credentials from Kaggle secrets if available
if command -v kaggle_secrets &> /dev/null || python3 -c "from kaggle_secrets import UserSecretsClient" &> /dev/null; then
    echo "[$TIMESTAMP] INFO: Querying Kaggle User Secrets for GITHUB_TOKEN..."
    TOKEN=$(python3 -c "
from kaggle_secrets import UserSecretsClient
try:
    user_secrets = UserSecretsClient()
    print(user_secrets.get_secret('GITHUB_TOKEN'))
except Exception as e:
    print('')
" 2>/dev/null || echo "")
    if [ -n "$TOKEN" ]; then
        export GITHUB_TOKEN="$TOKEN"
        echo "[$TIMESTAMP] INFO: GITHUB_TOKEN acquired successfully from Kaggle Secrets."
    fi
fi

# 3. Clone or Sync Repository
cd "$WORKDIR"
if [ ! -d "novacode-cloud" ]; then
    echo "[$TIMESTAMP] INFO: Cloning repository into $WORKDIR/novacode-cloud..."
    if [ -n "${GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_USER:-}" ] && [ -n "${GITHUB_REPO:-}" ]; then
        git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git" novacode-cloud
    else
        git clone https://github.com/novacode-cloud/novacode-cloud.git novacode-cloud || true
    fi
fi

if [ -d "novacode-cloud" ]; then
    cd novacode-cloud
    bash scripts/full_setup.sh
fi

echo "[$TIMESTAMP] INFO: Bootstrap phase complete."
