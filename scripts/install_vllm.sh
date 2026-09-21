#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Checking vLLM installation status..."

if python3 -c "import vllm" &> /dev/null; then
    VLLM_VER=$(python3 -c "import vllm; print(vllm.__version__)")
    echo "[$TIMESTAMP] INFO: vLLM is already installed (version: $VLLM_VER)."
else
    echo "[$TIMESTAMP] INFO: Installing vLLM compatible with PyTorch and CUDA..."
    python3 -m pip install vllm==0.6.3.post1 || python3 -m pip install vllm
    VLLM_VER=$(python3 -c "import vllm; print(vllm.__version__)" 2>/dev/null || echo "installed")
    echo "[$TIMESTAMP] INFO: vLLM successfully installed (version: $VLLM_VER)."
fi
