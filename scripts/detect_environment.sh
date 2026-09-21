#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [ENV] Running dynamic capability assessment..."

source "$(dirname "$0")/detect_gpu.sh"

SYSTEM_RAM_MB=$(free -m | awk '/^Mem:/{print $2}' || echo 0)
echo "[$TIMESTAMP] [INFO] [ENV] System RAM: ${SYSTEM_RAM_MB} MB"

if [ "$TOTAL_VRAM_MB" -ge 24000 ]; then
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct-AWQ"
    SELECTED_QUANTIZATION="awq"
    SELECTED_MAX_MODEL_LEN=32768
    SELECTED_GPU_MEMORY_UTILIZATION=0.90
    REASON="Dual T4 or >=24GB VRAM detected. Selected Qwen2.5-Coder-7B-Instruct-AWQ with 32K context window."
elif [ "$TOTAL_VRAM_MB" -ge 12000 ]; then
    SELECTED_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct-AWQ"
    SELECTED_QUANTIZATION="awq"
    SELECTED_MAX_MODEL_LEN=16384
    SELECTED_GPU_MEMORY_UTILIZATION=0.85
    REASON="Single T4 / P100 (>=12GB VRAM) detected. Selected Qwen2.5-Coder-7B-Instruct-AWQ with 16K context window."
elif [ "$TOTAL_VRAM_MB" -ge 6000 ]; then
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
    REASON="Minimal GPU VRAM or CPU environment detected. Selected Qwen2.5-Coder-1.5B-Instruct."
fi

OUTPUT_ENV="/kaggle/working/runtime-selection.env"
mkdir -p "$(dirname "$OUTPUT_ENV")"

cat << ENV_OUT > "$OUTPUT_ENV"
# NovaCode Cloud - Auto-generated runtime environment
GPU_COUNT="$GPU_COUNT"
GPU_NAMES="$GPU_NAMES"
GPU_VRAM_MB="$GPU_VRAM_MB"
TOTAL_VRAM_MB="$TOTAL_VRAM_MB"
FREE_VRAM_MB="$FREE_VRAM_MB"
SYSTEM_RAM_MB="$SYSTEM_RAM_MB"
CUDA_VERSION="$CUDA_VERSION"
DRIVER_VERSION="$DRIVER_VERSION"
TORCH_CUDA_AVAILABLE="$TORCH_CUDA_AVAILABLE"

SELECTED_MODEL="$SELECTED_MODEL"
SELECTED_QUANTIZATION="$SELECTED_QUANTIZATION"
SELECTED_TENSOR_PARALLEL_SIZE="$TENSOR_PARALLEL_SIZE"
SELECTED_GPU_MEMORY_UTILIZATION="$SELECTED_GPU_MEMORY_UTILIZATION"
SELECTED_MAX_MODEL_LEN="$SELECTED_MAX_MODEL_LEN"
SELECTION_REASON="$REASON"
ENV_OUT

echo "[$TIMESTAMP] [INFO] [ENV] Runtime selection complete: $SELECTED_MODEL (TP=$TENSOR_PARALLEL_SIZE, Quant=$SELECTED_QUANTIZATION, Context=$SELECTED_MAX_MODEL_LEN)"
echo "[$TIMESTAMP] [INFO] [ENV] Saved selection state to $OUTPUT_ENV"
