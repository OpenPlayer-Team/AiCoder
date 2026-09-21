# NovaCode Cloud — System Architecture

## Overview

NovaCode Cloud bridges low-spec client PCs with high-performance cloud GPUs. All heavy machine learning execution, model weights, and agent processing run remotely inside a Kaggle Notebook VM, while the local client PC handles code editing, Git version control, and project management.

## Component Topology



## Security & Isolation

- **Local Endpoint Isolation:** vLLM server binds strictly to 127.0.0.1:8000 inside the remote Kaggle VM.
- **Credential Hygiene:** Tokens managed via Kaggle Secrets or runtime environment variables; zero hardcoded secrets.
