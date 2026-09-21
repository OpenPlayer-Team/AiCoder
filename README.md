# NovaCode Cloud — Autonomous AI Coding Environment

**NovaCode Cloud** turns low-spec client PCs (e.g., Windows 10/11, 8 GB RAM, NVIDIA GT 730 4GB) into high-performance AI coding stations by leveraging free remote Kaggle GPU compute (up to Dual NVIDIA T4s), vLLM high-throughput inference, Qwen3/2.5-Coder LLMs, and OpenCode AI agent work environments.

> **Disclaimer on Kaggle Limits:** Kaggle Free is not an unlimited GPU service. GPU availability, session durations (up to 12 hours max per session, 30 hours/week total GPU quota), and hardware allocations are governed by Kaggle terms. NovaCode Cloud is architected to be 100% session-resilient and instantly recoverable after total VM resets.

---

## Architecture Overview



---

## Key Features

- **Zero Local LLM Requirement:** All heavy ML execution, tensor processing, and model weights stay in the remote Kaggle cloud.
- **Dynamic Hardware Adaptation:** Auto-detects 1x or 2x GPUs, total VRAM, and RAM to set , quantization (AWQ/GPTQ/Unquantized), and context lengths (8K to 32K).
- **Session Resilience:** Automated setup scripts re-establish state from GitHub without losing uncommitted progress or corrupting local changes.
- **Strict Security First:** Token handling via Kaggle Secrets; no API keys or credentials saved in code, logs, notebooks, or git repository history.
- **Open-Source & Free-Tier First:** Built entirely on open-weight models, open-source vLLM, and OpenCode, with zero compulsory paid API subscriptions.

---

## Quick Setup Guide

### 1. GitHub Setup
1. Fork or clone this repository to your GitHub account.
2. Generate a GitHub Fine-Grained Personal Access Token with  and  permissions.

### 2. Kaggle Setup
1. Open a new Kaggle Notebook.
2. In Settings, set Accelerator to GPU T4 x2 (or GPU P100).
3. In Add-ons -> Secrets, add the secret  with your fine-grained token.
4. Execute bootstrap script in notebook cell.

### 3. Local Windows Client
1. Edit code locally using VS Code and standard Git workflows (, , [?2004h(B)0[?1049h[1;24r[m[4l[39;49m[?1h=[?1h=[?25l[39;49m[m[H[J[22;34H[0;7m[ Reading... ][m[22;32H[0;7m[ Read 12 lines ][m[34h[?25h[24;1H[?1049l
[?1l>[?2004l, ).
2. The remote Kaggle backend executes heavy builds, model inference, and code generation.

---

## Directory Structure



---

## License

Distributed under the MIT License.
