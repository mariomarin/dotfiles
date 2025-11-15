#!/usr/bin/env pwsh
# Chezmoi pre-hook: Install Bitwarden CLI before reading source state
# This runs every time chezmoi reads source state, so exit fast if nothing to do

# Exit immediately if bw is already in PATH
if (Get-Command bw -ErrorAction SilentlyContinue) {
    exit 0
}

Write-Host "📦 Installing Bitwarden CLI..." -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}

# Install Bitwarden CLI via winget
Write-Host "  Installing via winget..." -ForegroundColor White
winget install --id Bitwarden.CLI --exact --silent --accept-package-agreements --accept-source-agreements

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Bitwarden CLI installed successfully" -ForegroundColor Green
    Write-Host "💡 You may need to restart your terminal for PATH changes to take effect" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to install Bitwarden CLI (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}
