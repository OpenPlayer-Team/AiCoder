# OpenCode Agent Integration

## Configuration

OpenCode is configured via config/opencode.json to route commands to the local vLLM OpenAI-compatible endpoint at http://127.0.0.1:8000/v1.

## Safety Guidelines

- OpenCode requests explicit user confirmation for destructive operations (rm -rf, git push --force, git reset --hard).
