# Scripts

This folder contains utility scripts for project setup and maintenance.

## Available Scripts

| Script | Description |
|--------|-------------|
| `github-setup.ps1` | PowerShell script to create and configure GitHub repository |
| `github-setup.sh` | Bash script to create and configure GitHub repository |

## GitHub Setup

### Prerequisites
- [GitHub CLI](https://cli.github.com/) installed
- Authenticated with `gh auth login`
- Local git repository initialized with commits

### Usage

**PowerShell (Windows):**
```powershell
.\scripts\github-setup.ps1
```

**Bash (Linux/macOS/WSL):**
```bash
chmod +x scripts/github-setup.sh
./scripts/github-setup.sh
```

### What it does
1. Creates a public GitHub repository
2. Pushes all local commits
3. Adds relevant topics (azure, devops, fastapi, terraform, etc.)
4. Configures repository settings (issues, projects, delete branch on merge)
5. Opens the repository in your browser
