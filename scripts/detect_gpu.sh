#!/usr/bin/env bash
set -euo pipefail

TS() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '[%s] [%s] [GPU] %s\n' "$TS" "$1" "$2"; }

GPU_COUNT=0
GPU_NAMES="None"
GPU_VRAM_MB=""
TOTAL_VRAM_MB=0
FREE_VRAM_MB=0
DRIVER_VERSION="N/A"
CUDA_VERSION="N/A"
TORCH_CUDA_AVAILABLE="false"

if command -v nvidia-smi >/dev/null 2>&1; then
  mapfile -t GPU_ROWS < <(nvidia-smi --query-gpu=name,memory.total,memory.free,driver_version --format=csv,noheader,nounits)
  GPU_COUNT="${#GPU_ROWS[@]}"
  if [ "$GPU_COUNT" -gt 0 ]; then
    names=()
    vram=()
    for row in "${GPU_ROWS[@]}"; do
      IFS=',' read -r name total free driver <<< "$row"
      name="$(xargs <<< "$name")"
      total="$(xargs <<< "$total")"
      free="$(xargs <<< "$free")"
      driver="$(xargs <<< "$driver")"
      names+=("$name")
      vram+=("$total")
      TOTAL_VRAM_MB=$((TOTAL_VRAM_MB + total))
      FREE_VRAM_MB=$((FREE_VRAM_MB + free))
      [ "$DRIVER_VERSION" = "N/A" ] && DRIVER_VERSION="$driver"
    done
    GPU_NAMES="$(IFS=';'; echo "${names[*]}")"
    GPU_VRAM_MB="$(IFS=';'; echo "${vram[*]}")"
    CUDA_VERSION="$(nvidia-smi | sed -n 's/.*CUDA Version: *\([0-9.]*\).*/\1/p' | head -n1)"
    CUDA_VERSION="${CUDA_VERSION:-N/A}"
  fi
fi

if python3 -c 'import torch; raise SystemExit(0 if torch.cuda.is_available() else 1)' >/dev/null 2>&1; then
  TORCH_CUDA_AVAILABLE="true"
fi

TP_SIZE=1
[ "$GPU_COUNT" -ge 2 ] && TP_SIZE=2

export GPU_COUNT GPU_NAMES GPU_VRAM_MB TOTAL_VRAM_MB FREE_VRAM_MB DRIVER_VERSION CUDA_VERSION TORCH_CUDA_AVAILABLE
export DETECTED_GPU_COUNT="$GPU_COUNT"
export DETECTED_GPU_NAME="$GPU_NAMES"
export DETECTED_GPU_VRAM_MB="$GPU_VRAM_MB"
export DETECTED_TOTAL_VRAM_MB="$TOTAL_VRAM_MB"
export DETECTED_FREE_VRAM_MB="$FREE_VRAM_MB"
export DETECTED_DRIVER_VERSION="$DRIVER_VERSION"
export DETECTED_CUDA_VERSION="$CUDA_VERSION"
export DETECTED_TORCH_CUDA_AVAILABLE="$TORCH_CUDA_AVAILABLE"
export DETECTED_TENSOR_PARALLEL_SIZE="$TP_SIZE"

log INFO "GPU_COUNT=$GPU_COUNT"
log INFO "GPU_NAMES=$GPU_NAMES"
log INFO "GPU_VRAM_MB=$GPU_VRAM_MB"
log INFO "TOTAL_VRAM_MB=$TOTAL_VRAM_MB"
log INFO "FREE_VRAM_MB=$FREE_VRAM_MB"
log INFO "CUDA_VERSION=$CUDA_VERSION"
log INFO "DRIVER_VERSION=$DRIVER_VERSION"
log INFO "TORCH_CUDA_AVAILABLE=$TORCH_CUDA_AVAILABLE"
log INFO "TENSOR_PARALLEL_SIZE=$TP_SIZE"
