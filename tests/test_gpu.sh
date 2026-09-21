#!/usr/bin/env bash
set -euo pipefail
bash scripts/detect_gpu.sh >/tmp/novacode-gpu.txt
grep -q '^\|.*GPU_COUNT=' /tmp/novacode-gpu.txt || true
grep -q 'GPU_COUNT=' /tmp/novacode-gpu.txt || { echo "[FAIL] GPU detection output"; exit 1; }
grep -q 'TORCH_CUDA_AVAILABLE=' /tmp/novacode-gpu.txt || { echo "[FAIL] PyTorch CUDA detection output"; exit 1; }
echo "[PASS] GPU detection script"
