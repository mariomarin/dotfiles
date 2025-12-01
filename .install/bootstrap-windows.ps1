#!/usr/bin/env pwsh
# Bootstrap script for Windows
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle setup itself

Write-Host "🚀 Running Windows bootstrap..." -ForegroundColor Cyan

# Function to install winget using the winget-install script
function Install-Winget {
    Write-Host "📦 Setting up winget..." -ForegroundColor Yellow

    try {
        # Use the community-maintained winget-install script
        # This handles all edge cases: dependencies, PATH, different Windows versions
        Write-Host "  Running winget-install script..." -ForegroundColor White
        & ([scriptblock]::Create((irm https://get.winget.run))) -Force -ErrorAction Stop

        # Refresh PATH in current session to pick up winget
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Verify winget works
        $version = winget --version 2>$null
        if ($version) {
            Write-Host "  ✓ winget $version is ready" -ForegroundColor Green
        } else {
            throw "winget not responding after installation"
        }
    } catch {
        Write-Host "  ❌ Failed to setup winget automatically: $_" -ForegroundColor Red
        Write-Host "" -ForegroundColor White
        Write-Host "  Please install winget manually using one of these methods:" -ForegroundColor Yellow
        Write-Host "  1. Install App Installer from Microsoft Store" -ForegroundColor White
        Write-Host "  2. Download from: https://aka.ms/getwinget" -ForegroundColor White
        Write-Host "  3. Run manually: irm https://get.winget.run | iex" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        exit 1
    }
}

# Check if winget is available, install if not
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Install-Winget
} else {
    $version = winget --version
    Write-Host "✓ winget $version already available" -ForegroundColor Green
}

# Function to refresh PATH in current session
function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Install Nushell
Write-Host "📦 Checking Nushell..." -ForegroundColor White
if (-not (Get-Command nu -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Nushell..." -ForegroundColor Yellow
    winget install --id Nushell.Nushell --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Nushell installed" -ForegroundColor Green

        # Refresh PATH to make nu available immediately
        Refresh-Path

        # Verify nu is now available
        if (Get-Command nu -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ nu command is ready" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  nu installed but not in PATH yet" -ForegroundColor Yellow
            Write-Host "  Please restart PowerShell before running 'chezmoi apply'" -ForegroundColor Yellow
        }
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

        # Refresh PATH to make bw available immediately
        Refresh-Path

        # Verify bw is now available
        if (Get-Command bw -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ bw command is ready" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  bw installed but not in PATH yet" -ForegroundColor Yellow
            Write-Host "  Please restart PowerShell before running 'chezmoi apply'" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ Failed to install Bitwarden CLI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Bitwarden CLI already installed" -ForegroundColor Green
}

# Install Just (task runner)
Write-Host "📦 Checking Just..." -ForegroundColor White
if (-not (Get-Command just -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Just..." -ForegroundColor Yellow
    winget install --id Casey.Just --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Just installed" -ForegroundColor Green
        Refresh-Path
        if (Get-Command just -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ just command is ready" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  just installed but not in PATH yet" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ Failed to install Just" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Just already installed" -ForegroundColor Green
}

Write-Host "" -ForegroundColor White
Write-Host "✅ Bootstrap complete for Windows" -ForegroundColor Green

# Final check - warn if commands still not available
$needsRestart = $false
if (-not (Get-Command nu -ErrorAction SilentlyContinue)) {
    $needsRestart = $true
}
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    $needsRestart = $true
}
if (-not (Get-Command just -ErrorAction SilentlyContinue)) {
    $needsRestart = $true
}

if ($needsRestart) {
    Write-Host "" -ForegroundColor White
    Write-Host "⚠️  IMPORTANT: Please restart PowerShell before running 'chezmoi apply'" -ForegroundColor Yellow
    Write-Host "   Newly installed commands (nu, bw, just) require a fresh PowerShell session" -ForegroundColor Yellow
}
