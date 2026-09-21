#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RUNTIME_ENV="/kaggle/working/runtime-selection.env"

if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
fi

echo "=========================================="
echo "NovaCode Cloud Environment Report"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="
echo "OS:                    $(uname -sr)"
echo "Python:                $(python3 --version 2>&1)"
echo "CUDA Version:          ${DETECTED_CUDA_VERSION:-N/A}"
echo "Driver Version:        ${DETECTED_DRIVER_VERSION:-N/A}"
echo "GPU Model:             ${DETECTED_GPU_NAME:-N/A}"
echo "GPU Count:             ${DETECTED_GPU_COUNT:-0}"
echo "Total VRAM:            ${DETECTED_TOTAL_VRAM_MB:-0} MB"
echo "System RAM:            ${DETECTED_SYSTEM_RAM_MB:-0} MB"
echo "vLLM Version:          $(python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo 'Not installed')"
echo "OpenCode Status:       $(command -v opencode &>/dev/null && echo 'Installed' || echo 'Not found')"
echo "Git Version:           $(git --version 2>/dev/null || echo 'Not installed')"
echo "Selected Model:        ${SELECTED_MODEL:-N/A}"
echo "Tensor Parallel Size:  ${SELECTED_TENSOR_PARALLEL_SIZE:-1}"
echo "Selected Context Len:  ${SELECTED_MAX_MODEL_LEN:-N/A}"
echo "=========================================="
