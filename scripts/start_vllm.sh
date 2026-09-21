#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_DIR="${LOG_DIR:-/kaggle/working/logs}"
mkdir -p "$LOG_DIR"
VLLM_LOG="$LOG_DIR/vllm.log"

RUNTIME_ENV="/kaggle/working/runtime-selection.env"
if [ -f "$RUNTIME_ENV" ]; then
    source "$RUNTIME_ENV"
else
    "$(dirname "$0")/detect_environment.sh"
    source "$RUNTIME_ENV"
fi

MODEL="${SELECTED_MODEL:-Qwen/Qwen2.5-Coder-7B-Instruct-AWQ}"
TP_SIZE="${SELECTED_TENSOR_PARALLEL_SIZE:-1}"
GPU_UTIL="${SELECTED_GPU_MEMORY_UTILIZATION:-0.90}"
INITIAL_CONTEXT="${SELECTED_MAX_MODEL_LEN:-32768}"
QUANT="${SELECTED_QUANTIZATION:-awq}"

echo "[$TIMESTAMP] INFO: Starting vLLM with Model: $MODEL, TP: $TP_SIZE, Quant: $QUANT..."

if pgrep -f "vllm.entrypoints.openai.api_server" > /dev/null; then
    echo "[$TIMESTAMP] INFO: Active vLLM instance detected. Stopping existing instance first..."
    "$(dirname "$0")/stop_vllm.sh"
fi

CONTEXT_WINDOW_ATTEMPTS=("$INITIAL_CONTEXT" 24576 16384 8192)
SUCCESS=false

for CTX in "${CONTEXT_WINDOW_ATTEMPTS[@]}"; do
    echo "[$TIMESTAMP] INFO: Attempting vLLM launch with max_model_len=$CTX..."

    EXTRA_FLAGS=()
    if [ "$QUANT" != "none" ]; then
        EXTRA_FLAGS+=("--quantization" "$QUANT")
    fi

    EXTRA_FLAGS+=("--enable-auto-tool-choice" "--tool-call-parser" "llama3_json")

    python3 -m vllm.entrypoints.openai.api_server \
        --model "$MODEL" \
        --tensor-parallel-size "$TP_SIZE" \
        --gpu-memory-utilization "$GPU_UTIL" \
        --max-model-len "$CTX" \
        --host 127.0.0.1 \
        --port 8000 \
        "${EXTRA_FLAGS[@]}" > "$VLLM_LOG" 2>&1 &

    VLLM_PID=$!
    echo "[$TIMESTAMP] INFO: vLLM process spawned with PID $VLLM_PID. Waiting for server readiness..."

    READY=false
    for i in {1..45}; do
        sleep 2
        if curl -s http://127.0.0.1:8000/v1/models | grep -q "object"; then
            READY=true
            break
        fi
        if ! kill -0 "$VLLM_PID" 2>/dev/null; then
            echo "[$TIMESTAMP] WARN: vLLM process died unexpectedly. Checking log..."
            break
        fi
    done

    if [ "$READY" = true ]; then
        echo "[$TIMESTAMP] INFO: vLLM Server ready on http://127.0.0.1:8000/v1 with context $CTX!"
        SUCCESS=true
        break
    else
        echo "[$TIMESTAMP] WARN: Launch failed for context $CTX. Cleaning up and retrying lower context window..."
        "$(dirname "$0")/stop_vllm.sh"
    fi
done

if [ "$SUCCESS" = false ]; then
    echo "[$TIMESTAMP] ERROR: MODEL START FAILED after trying fallback context windows."
    echo "[$TIMESTAMP] ERROR: Last 20 log lines from $VLLM_LOG:"
    tail -n 20 "$VLLM_LOG" || true
    python3 -c "import sys; sys.exit(1)"
fi
