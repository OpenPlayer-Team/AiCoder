# NovaCode Cloud

NovaCode Cloud is a Kaggle-backed AI coding environment for low-spec clients. The client does not run the LLM locally: Git/GitHub and project editing remain local, while the Kaggle runtime hosts vLLM and the OpenCode agent.

> **Validation status:** this branch contains the Phase 2 hardening implementation, but the repository cannot truthfully claim `OPERATIONAL` until `tests/test_e2e.sh` has been executed in a real Kaggle GPU runtime and its report shows PASS.

## Architecture

Windows client -> GitHub -> Kaggle ephemeral runtime -> vLLM OpenAI-compatible API -> OpenCode -> project files/Git.

GitHub is the persistent source of truth. Kaggle `/kaggle/working` is disposable.

## Runtime

The bootstrap detects Python, PyTorch/CUDA, NVIDIA GPUs, VRAM and available vLLM/OpenCode installations. Model selection is capability-based and currently uses Qwen2.5-Coder variants with Hermes tool parsing for Qwen2.5. vLLM binds to `127.0.0.1:8000` by default.

The installer deliberately avoids replacing a Kaggle-provided CUDA/PyTorch stack unless PyTorch is missing.

## Real validation

Run on the GPU runtime:

```bash
bash kaggle/bootstrap.sh
bash kaggle/startup.sh
```

The end-to-end report is written to:

```
/kaggle/working/logs/e2e-report.txt
```

The E2E suite verifies:

- GPU/PyTorch capability
- vLLM installation and model identity
- real chat completion
- real SSE streaming
- real tool calling
- real OpenCode installation
- OpenCode custom OpenAI-compatible provider configuration
- OpenCode -> vLLM -> model execution
- an isolated coding task in a temporary Git repository

A failed critical step produces `OVERALL RESULT: FAIL`. There are no fake OpenCode executables and no success-on-warning inference checks.

## OpenCode

The current OpenCode documentation supports custom OpenAI-compatible providers through `@ai-sdk/openai-compatible`, `options.baseURL`, and a provider/model configuration. The runtime script generates a model-specific configuration after querying the selected vLLM model.

OpenCode is installed using the current CLI package `@opencode/cli` when npm is available, with Bun as the alternative.

## Git safety

Automatic recovery never runs:

- `git reset --hard`
- `git clean -fd`
- `git checkout -- .`
- force push

If uncommitted changes are detected, synchronization stops and the changes are preserved.

## Secrets

Put GitHub credentials in Kaggle Secrets/environment variables. Never commit PATs, private keys or real credentials. The repository contains only placeholders.

## Kaggle limitations

Kaggle GPU availability, session duration, quota and accelerator choices are platform-controlled and can change. NovaCode Cloud therefore detects the actual runtime instead of assuming a particular GPU count or quota.

## Windows client

The Windows side is intentionally lightweight. It should perform Git/project operations and invoke the remote workflow; it is not expected to host the LLM.

## Important limitation

Static repository inspection cannot prove a live GPU/model/OpenCode chain. Only a real Kaggle run of `tests/test_e2e.sh` can establish the final operational status.
