# NovaCode Cloud — Troubleshooting Matrix

| Issue | Cause | Diagnosis | Solution |
|---|---|---|---|
| **No GPU Detected** | Accelerator set to CPU | nvidia-smi returns missing | In Kaggle Settings, set Accelerator to GPU T4 x2 |
| **CUDA Mismatch / OOM** | VRAM exceeded during model load | Check /kaggle/working/logs/vllm.log | Automated fallback decreases context window or selects smaller model |
| **Port 8000 Occupied** | Orphan vLLM process active | lsof -i :8000 | Run scripts/stop_vllm.sh |
| **GitHub Authentication Failed** | Expired/Missing token | Run scripts/test_git.sh | Refresh GITHUB_TOKEN in Kaggle Secrets |
| **Session Expired** | Kaggle 12h timeout reached | Notebook stopped | Re-run kaggle/bootstrap.sh in a new session |
