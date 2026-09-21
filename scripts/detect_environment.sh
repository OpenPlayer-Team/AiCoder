#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Running Environment Capability Assessment..."

source "$(dirname "$0")/detect_gpu.sh"

SYSTEM_RAM_MB=$(free -m | awk '/^Mem:/{print $2}' || echo 0)
echo "[$TIMESTAMP] INFO: Detected System RAM: ${SYSTEM_RAM_MB} MB"

if [ "$DETECTED_TOTAL_VRAM_MB" -ge 24000 ]; then
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct-AWQ"
    SELECTED_QUANTIZATION="awq"
    SELECTED_MAX_MODEL_LEN=32768
    SELECTED_GPU_MEMORY_UTILIZATION=0.90
    REASON="High VRAM (Dual T4 or >=24GB VRAM) detected. Allocating primary 7B AWQ model with full 32K context window."
elif [ "$DETECTED_TOTAL_VRAM_MB" -ge 12000 ]; then
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct-AWQ"
    SELECTED_QUANTIZATION="awq"
    SELECTED_MAX_MODEL_LEN=16384
    SELECTED_GPU_MEMORY_UTILIZATION=0.85
    REASON="Single T4 or Moderate VRAM (>=12GB) detected. Allocating 7B AWQ model with 16K context window."
elif [ "$DETECTED_TOTAL_VRAM_MB" -ge 6000 ]; then
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-3B-Instruct"
    SELECTED_QUANTIZATION="none"
    SELECTED_MAX_MODEL_LEN=16384
    SELECTED_GPU_MEMORY_UTILIZATION=0.85
    REASON="Low VRAM (>=6GB) detected. Falling back to Qwen2.5-Coder-3B-Instruct."
else
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-1.5B-Instruct"
    SELECTED_QUANTIZATION="none"
    SELECTED_MAX_MODEL_LEN=8192
    SELECTED_GPU_MEMORY_UTILIZATION=0.80
    REASON="Minimal GPU or CPU-only environment detected. Falling back to Qwen2.5-Coder-1.5B-Instruct."
fi

OUTPUT_ENV="/kaggle/working/runtime-selection.env"
mkdir -p "$(dirname "$OUTPUT_ENV")"

cat << ENV_OUT > "$OUTPUT_ENV"
DETECTED_GPU_NAME="$DETECTED_GPU_NAME"
DETECTED_GPU_COUNT="$DETECTED_GPU_COUNT"
DETECTED_TOTAL_VRAM_MB="$DETECTED_TOTAL_VRAM_MB"
DETECTED_FREE_VRAM_MB="$DETECTED_FREE_VRAM_MB"
DETECTED_SYSTEM_RAM_MB="$SYSTEM_RAM_MB"
DETECTED_CUDA_VERSION="$DETECTED_CUDA_VERSION"

SELECTED_MODEL="$SELECTED_MODEL"
SELECTED_QUANTIZATION="$SELECTED_QUANTIZATION"
SELECTED_TENSOR_PARALLEL_SIZE="$DETECTED_TENSOR_PARALLEL_SIZE"
SELECTED_GPU_MEMORY_UTILIZATION="$SELECTED_GPU_MEMORY_UTILIZATION"
SELECTED_MAX_MODEL_LEN="$SELECTED_MAX_MODEL_LEN"
SELECTION_REASON="$REASON"
ENV_OUT

echo "[$TIMESTAMP] INFO: Selection Complete -> $SELECTED_MODEL"
echo "[$TIMESTAMP] INFO: Reason: $REASON"
echo "[$TIMESTAMP] INFO: Saved configuration to $OUTPUT_ENV"
