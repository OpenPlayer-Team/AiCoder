#!/usr/bin/env bash
set -euo pipefail
bash scripts/detect_gpu.sh >/tmp/novacode-gpu.txt
grep -q 'GPU_COUNT=' /tmp/novacode-gpu.txt || { echo "[FAIL] GPU_COUNT missing"; exit 1; }
grep -q 'GPU_VRAM_MB=' /tmp/novacode-gpu.txt || { echo "[FAIL] GPU_VRAM_MB missing"; exit 1; }
grep -q 'TORCH_CUDA_AVAILABLE=' /tmp/novacode-gpu.txt || { echo "[FAIL] PyTorch CUDA result missing"; exit 1; }
echo "[PASS] GPU detection script"
