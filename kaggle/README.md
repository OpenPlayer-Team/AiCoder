# Kaggle Deployment Guide for NovaCode Cloud

This folder contains all entry points and orchestration scripts for running NovaCode Cloud on Kaggle Notebooks.

## Quick Start on Kaggle

1. **Create Kaggle Notebook:** Open Kaggle and create a new Python notebook.
2. **Configure GPU Accelerator:** In the notebook right panel under **Settings -> Accelerator**, choose **GPU T4 x2** (preferred) or **GPU P100**.
3. **Add Kaggle Secret:**
   - Go to **Add-ons -> Secrets**.
   - Add a secret key `GITHUB_TOKEN` containing your GitHub Fine-Grained Access Token.
4. **Run Notebook:**
   Import or paste `NovaCode_Cloud.ipynb` and run all cells.
