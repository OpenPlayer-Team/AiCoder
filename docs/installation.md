# NovaCode Cloud — Installation Guide

## Local Client Setup (Windows 10/11)

1. Install Git for Windows and VS Code.
2. Clone your repository:
   git clone https://github.com/<YOUR_USER>/novacode-cloud.git
   cd novacode-cloud

## Remote Kaggle Backend Setup

1. Log into Kaggle and create a new notebook.
2. In Settings -> Accelerator, select GPU T4 x2.
3. In Add-ons -> Secrets, create GITHUB_TOKEN with a fine-grained token.
4. Execute bootstrap script in notebook cell.
