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
        Write-Host "  ✓ winget installed successfully" -ForegroundColor Green

        # Refresh PATH in current session
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Verify winget works
        $version = winget --version 2>$null
        if ($version) {
            Write-Host "  ✓ winget $version is ready" -ForegroundColor Green
        } else {
            throw "winget not responding after installation"
        }
    } catch {
        Write-Host "  ⚠️  winget-install script failed: $_" -ForegroundColor Yellow
        Write-Host "  Attempting simple fallback method..." -ForegroundColor Yellow

        # Fallback: Simple registration method
        try {
            Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
            Write-Host "  ✓ App Installer registered" -ForegroundColor Green

            # Add to PATH with literal %LOCALAPPDATA% to prevent profile-specific issues
            $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($userPath -notlike "*%LOCALAPPDATA%\Microsoft\WindowsApps*") {
                Write-Host "  Adding WindowsApps to PATH..." -ForegroundColor White
                [Environment]::SetEnvironmentVariable(
                    "PATH",
                    "$userPath;%LOCALAPPDATA%\Microsoft\WindowsApps",
                    "User"
                )
            }

            # Refresh PATH in current session
            $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            # Verify
            $version = winget --version 2>$null
            if ($version) {
                Write-Host "  ✓ winget $version is ready" -ForegroundColor Green
            } else {
                throw "winget not available after registration"
            }
        } catch {
            Write-Host "  ❌ Failed to setup winget automatically" -ForegroundColor Red
            Write-Host "" -ForegroundColor White
            Write-Host "  Please install winget manually using one of these methods:" -ForegroundColor Yellow
            Write-Host "  1. Install App Installer from Microsoft Store" -ForegroundColor White
            Write-Host "  2. Download from: https://aka.ms/getwinget" -ForegroundColor White
            Write-Host "  3. Run: irm https://get.winget.run | iex" -ForegroundColor White
            Write-Host "" -ForegroundColor White
            exit 1
        }
    }
}

# Check if winget is available, install if not
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Install-Winget
} else {
    $version = winget --version
    Write-Host "✓ winget $version already available" -ForegroundColor Green
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
