# GitHub Integration & Security Policy

## Authentication

NovaCode Cloud uses GitHub Fine-Grained Access Tokens with minimal necessary scope:
- **Repository Permissions:** Contents: Read and Write, Metadata: Read.

## Security Rules

- Never commit token strings, credentials, or .env files.
- .gitignore explicitly filters secrets, credentials, and cache folders.
