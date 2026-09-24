#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
if [ -f "/kaggle/working/runtime-selection.env" ]; then
    RUNTIME_ENV="/kaggle/working/runtime-selection.env"
else
    RUNTIME_ENV="runtime-selection.env"
fi

if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
else
    source "$(dirname "$0")/detect_gpu.sh"
fi

echo "=========================================="
echo "NovaCode Cloud Environment Report"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="
echo "OS Kernel:             $(uname -sr)"
echo "Python Version:        $(python3 --version 2>&1)"
echo "CUDA Version:          ${CUDA_VERSION:-N/A}"
echo "Driver Version:        ${DRIVER_VERSION:-N/A}"
echo "PyTorch CUDA Status:   ${TORCH_CUDA_AVAILABLE:-false}"
echo "GPU Models:            ${GPU_NAMES:-None}"
echo "GPU Count:             ${GPU_COUNT:-0}"
echo "VRAM Per GPU:          ${GPU_VRAM_MB:-0} MB"
echo "Total VRAM:            ${TOTAL_VRAM_MB:-0} MB"
echo "System RAM:            ${SYSTEM_RAM_MB:-0} MB"
echo "vLLM Status:           $(python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo 'Not installed')"
echo "OpenCode Status:       $(command -v opencode &>/dev/null && echo 'Installed' || echo 'Not installed')"
echo "Git Version:           $(git --version 2>/dev/null || echo 'Not installed')"
echo "Selected Model:        ${SELECTED_MODEL:-N/A}"
echo "Tensor Parallel Size:  ${SELECTED_TENSOR_PARALLEL_SIZE:-1}"
echo "Quantization Mode:     ${SELECTED_QUANTIZATION:-N/A}"
echo "Context Window:        ${SELECTED_MAX_MODEL_LEN:-N/A}"
echo "=========================================="
