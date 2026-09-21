# NovaCode Cloud — LLM Selection & Model Policy Guide

## Model Selection Principles

1. **Open-Weight & Permissive License:** Focuses on models such as `Qwen/Qwen2.5-Coder-7B-Instruct-AWQ` and its variants.
2. **No Model Weights in Git:** Never commit model weights (`.safetensors`, `.bin`, `.pt`) to the Git repository. Weights are cached locally in the runtime environment (`/kaggle/working/cache/huggingface`).
3. **Quantization & VRAM Efficiency:** Prefers AWQ or GPTQ quantized variants when running on Kaggle dual/single NVIDIA T4 GPUs.
4. **Tool Calling & Agent Compatibility:** Ensures model template compatibility with vLLM tool calling parser (`llama3_json` / `hermes`).

---

## Model Hierarchy & Fallback Matrix

| Tier | Model ID | Quantization | Context Window | Min VRAM | Target Hardware |
|---|---|---|---|---|---|
| **Primary** | `Qwen/Qwen2.5-Coder-7B-Instruct-AWQ` | AWQ | 32,768 | 12 GB | Dual NVIDIA T4 / Single T4 |
| **Fallback 1** | `Qwen/Qwen2.5-Coder-3B-Instruct` | None (FP16) | 16,384 | 6 GB | NVIDIA P100 / Low VRAM GPU |
| **Fallback 2** | `Qwen/Qwen2.5-Coder-1.5B-Instruct` | None (FP16) | 8,192 | 3.5 GB | Emergency CPU / Ultra Low VRAM |

---

## License & Usage Terms

- **Qwen2.5-Coder Series:** Released under the Apache 2.0 License. Free for commercial and research use.
- Model downloads are performed directly from HuggingFace Hub during initial runtime bootstrap.
