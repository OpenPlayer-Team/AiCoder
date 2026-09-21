#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Running Git Session Recovery & Sync..."

TOKEN="${GITHUB_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "[$TIMESTAMP] WARN: GITHUB_TOKEN environment variable not set. Operating in local read-only git mode."
fi

if [ -d ".git" ]; then
    echo "[$TIMESTAMP] INFO: Git repository detected. Fetching latest remote commits..."
    git fetch origin || echo "[$TIMESTAMP] WARN: Git fetch failed. Check network or credentials."

    UNCOMMITTED=$(git status --porcelain)
    if [ -n "$UNCOMMITTED" ]; then
        echo "[$TIMESTAMP] WARN: Local uncommitted changes detected in Kaggle workspace!"
        echo "$UNCOMMITTED"
        echo "[$TIMESTAMP] INFO: Preserving uncommitted local work."
    else
        echo "[$TIMESTAMP] INFO: Working tree clean."
    fi
else
    echo "[$TIMESTAMP] INFO: No git repository in current folder."
fi

echo "[$TIMESTAMP] INFO: Git session recovery completed."
