# Kaggle Platform Limits & Resilience Strategy

## Kaggle Environment Realities

- **Session Time Limit:** Max 12 hours per interactive session.
- **Weekly GPU Quota:** 30 hours per week (Free tier).
- **GPU Allocation:** Dual NVIDIA T4s (30GB total VRAM) when available, or NVIDIA P100 (16GB VRAM).

## Session Destruction Resilience

Because Kaggle VM instances are ephemeral, NovaCode Cloud treats GitHub as the permanent source of truth. Every time a new session starts:
1. kaggle/bootstrap.sh fetches the latest repository state.
2. Local uncommitted changes are safely preserved.
3. Dependencies, vLLM, and OpenCode are dynamically bootstrapped.
