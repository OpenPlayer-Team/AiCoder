# vLLM Server & Model Serving Policy

## Server Configuration

- **Endpoint:** http://127.0.0.1:8000/v1
- **Primary Model:** Qwen/Qwen2.5-Coder-7B-Instruct-AWQ
- **Fallback Models:** Qwen2.5-Coder-3B-Instruct / Qwen2.5-Coder-1.5B-Instruct

## Automatic Context Window Fallback

On Out-Of-Memory (OOM) errors during startup, vLLM automatically retries with decreasing context windows:
32768 -> 24576 -> 16384 -> 8192.
