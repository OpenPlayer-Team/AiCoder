param(
  [string]$Repository = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "Git for Windows is required."
}

Set-Location $Repository
if (-not (Test-Path ".git")) {
  throw "The selected directory is not a Git repository."
}

Write-Host "NovaCode Cloud Windows client"
Write-Host "Repository: $Repository"
Write-Host "Local machine is a lightweight Git/project client; LLM inference remains remote."

git status --short
git remote -v

Write-Host ""
Write-Host "Use GitHub as the persistent source of truth."
Write-Host "Start the Kaggle backend with kaggle/NovaCode_Cloud.ipynb."
