#!/usr/bin/env pwsh
# Bootstrap script for Windows
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle setup itself

Write-Host "🚀 Running Windows bootstrap..." -ForegroundColor Cyan

# Function to install/register winget
function Install-Winget {
    Write-Host "📦 Setting up winget..." -ForegroundColor Yellow

    # Step 1: Register the App Installer package
    try {
        Write-Host "  Registering App Installer package..." -ForegroundColor White
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
        Write-Host "  ✓ App Installer registered" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Could not register App Installer: $_" -ForegroundColor Yellow
        Write-Host "  Attempting to download winget manually..." -ForegroundColor Yellow

        # Try to download and install from aka.ms
        try {
            $tempFile = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller.msixbundle"
            Write-Host "  Downloading winget installer..." -ForegroundColor White
            Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $tempFile -UseBasicParsing
            Add-AppxPackage -Path $tempFile
            Remove-Item $tempFile
            Write-Host "  ✓ winget installed" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ Failed to install winget automatically" -ForegroundColor Red
            Write-Host "  Please install App Installer from Microsoft Store manually" -ForegroundColor Red
            Write-Host "  URL: https://aka.ms/getwinget" -ForegroundColor Yellow
            exit 1
        }
    }

    # Step 2: Add WindowsApps to PATH if needed
    $windowsAppsPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

    # Check if winget.exe exists
    if (-not (Test-Path "$windowsAppsPath\winget.exe")) {
        Write-Host "  ❌ winget.exe not found in $windowsAppsPath" -ForegroundColor Red
        Write-Host "  Please restart PowerShell and try again" -ForegroundColor Yellow
        exit 1
    }

    # Add to PATH permanently if not already there
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$windowsAppsPath*") {
        Write-Host "  Adding WindowsApps to PATH..." -ForegroundColor White
        [Environment]::SetEnvironmentVariable(
            "PATH",
            "$userPath;$windowsAppsPath",
            "User"
        )
        Write-Host "  ✓ PATH updated" -ForegroundColor Green
    }

    # Add to current session
    if ($env:PATH -notlike "*$windowsAppsPath*") {
        $env:PATH += ";$windowsAppsPath"
    }

    # Verify winget works
    try {
        $version = winget --version
        Write-Host "  ✓ winget $version is ready" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ winget not responding. Please restart PowerShell." -ForegroundColor Red
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
