#!/usr/bin/env bash
set -euo pipefail

# NovaCode Cloud - GPU Detection & Capability Query

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] INFO: Detecting GPU hardware..."

if ! command -v nvidia-smi &> /dev/null; then
    echo "[$TIMESTAMP] WARN: nvidia-smi not found! Running in CPU-only mode."
    GPU_COUNT=0
    GPU_NAME="None (CPU Only)"
    TOTAL_VRAM_MB=0
    FREE_VRAM_MB=0
    DRIVER_VERSION="N/A"
    CUDA_VERSION="N/A"
    TENSOR_PARALLEL_SIZE=1
else
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader | head -n 1 | tr -d ' ' || echo 0)
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1 | xargs || echo "Unknown GPU")
    TOTAL_VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{s+=$1} END {print s}' || echo 0)
    FREE_VRAM_MB=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | awk '{s+=$1} END {print s}' || echo 0)
    DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n 1 | tr -d ' ' || echo "N/A")
    CUDA_VERSION=$(nvidia-smi | grep -oP 'CUDA Version: \K[0-9.]+' || echo "N/A")

    if [ "$GPU_COUNT" -ge 2 ]; then
        TENSOR_PARALLEL_SIZE=2
    else
        TENSOR_PARALLEL_SIZE=1
    fi
fi

echo "=========================================="
echo "GPU Detection Summary"
echo "=========================================="
echo "GPU Name:               $GPU_NAME"
echo "GPU Count:              $GPU_COUNT"
echo "Total VRAM (MB):        $TOTAL_VRAM_MB"
echo "Free VRAM (MB):         $FREE_VRAM_MB"
echo "Driver Version:         $DRIVER_VERSION"
echo "CUDA Version:           $CUDA_VERSION"
echo "Tensor Parallel Size:   $TENSOR_PARALLEL_SIZE"
echo "=========================================="

export DETECTED_GPU_NAME="$GPU_NAME"
export DETECTED_GPU_COUNT="$GPU_COUNT"
export DETECTED_TOTAL_VRAM_MB="$TOTAL_VRAM_MB"
export DETECTED_FREE_VRAM_MB="$FREE_VRAM_MB"
export DETECTED_DRIVER_VERSION="$DRIVER_VERSION"
export DETECTED_CUDA_VERSION="$CUDA_VERSION"
export DETECTED_TENSOR_PARALLEL_SIZE="$TENSOR_PARALLEL_SIZE"
