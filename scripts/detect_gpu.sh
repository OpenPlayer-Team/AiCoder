#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] [INFO] [GPU] Detecting hardware capabilities and CUDA runtime..."

TORCH_CUDA_AVAILABLE=$(python3 -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "false")

if ! command -v nvidia-smi &> /dev/null; then
    echo "[$TIMESTAMP] [WARN] [GPU] nvidia-smi utility not found."
    GPU_COUNT=0
    GPU_NAMES="None"
    GPU_VRAM_MB=0
    TOTAL_VRAM_MB=0
    FREE_VRAM_MB=0
    DRIVER_VERSION="N/A"
    CUDA_VERSION="N/A"
    TENSOR_PARALLEL_SIZE=1
else
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader | head -n 1 | tr -d ' ' || echo 0)
    GPU_NAMES=$(nvidia-smi --query-gpu=name --format=csv,noheader | tr '\n' ',' | sed 's/,$//' || echo "Unknown")
    GPU_VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1 | tr -d ' ' || echo 0)
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
echo "NovaCode Cloud Hardware Detection Summary"
echo "=========================================="
echo "GPU Count:            $GPU_COUNT"
echo "GPU Models:           $GPU_NAMES"
echo "VRAM Per GPU (MB):    $GPU_VRAM_MB"
echo "Total VRAM (MB):      $TOTAL_VRAM_MB"
echo "Free VRAM (MB):       $FREE_VRAM_MB"
echo "Driver Version:       $DRIVER_VERSION"
echo "CUDA Version:         $CUDA_VERSION"
echo "PyTorch CUDA Status:  $TORCH_CUDA_AVAILABLE"
echo "Tensor Parallel Size: $TENSOR_PARALLEL_SIZE"
echo "=========================================="

export GPU_COUNT="$GPU_COUNT"
export GPU_NAMES="$GPU_NAMES"
export GPU_VRAM_MB="$GPU_VRAM_MB"
export TOTAL_VRAM_MB="$TOTAL_VRAM_MB"
export FREE_VRAM_MB="$FREE_VRAM_MB"
export DRIVER_VERSION="$DRIVER_VERSION"
export CUDA_VERSION="$CUDA_VERSION"
export TORCH_CUDA_AVAILABLE="$TORCH_CUDA_AVAILABLE"
export TENSOR_PARALLEL_SIZE="$TENSOR_PARALLEL_SIZE"
