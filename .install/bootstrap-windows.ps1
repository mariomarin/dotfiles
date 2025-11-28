#!/usr/bin/env pwsh
# Bootstrap script for Windows
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle setup itself

Write-Host "🚀 Running Windows bootstrap..." -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}

# Install Bitwarden CLI
Write-Host "📦 Checking Bitwarden CLI..." -ForegroundColor White
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Bitwarden CLI..." -ForegroundColor Yellow
    winget install --id Bitwarden.CLI --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Bitwarden CLI installed" -ForegroundColor Green
        Write-Host "  ⚠️  Please restart PowerShell to use 'bw' command" -ForegroundColor Yellow
        Write-Host "      Or run: refreshenv (if you have Chocolatey)" -ForegroundColor Yellow
    } else {
        Write-Host "  ❌ Failed to install Bitwarden CLI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Bitwarden CLI already installed" -ForegroundColor Green
}

Write-Host "✅ Bootstrap complete for Windows" -ForegroundColor Green
