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

# Install Nushell
Write-Host "📦 Checking Nushell..." -ForegroundColor White
if (-not (Get-Command nu -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Nushell..." -ForegroundColor Yellow
    winget install --id Nushell.Nushell --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Nushell installed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to install Nushell" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Nushell already installed" -ForegroundColor Green
}

# Install Bitwarden CLI
Write-Host "📦 Checking Bitwarden CLI..." -ForegroundColor White
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Bitwarden CLI..." -ForegroundColor Yellow
    winget install --id Bitwarden.CLI --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Bitwarden CLI installed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to install Bitwarden CLI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Bitwarden CLI already installed" -ForegroundColor Green
}

Write-Host "✅ Bootstrap complete for Windows" -ForegroundColor Green
Write-Host "⚠️  Please restart PowerShell to use new commands (nu, bw)" -ForegroundColor Yellow
