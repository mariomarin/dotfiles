#!/usr/bin/env pwsh
# Windows setup script for dotfiles
# Run with: irm https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/windows-setup.ps1 | iex
# Or locally: .\windows-setup.ps1

#Requires -RunAsAdministrator

Write-Host "🚀 Windows Dotfiles Setup" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}

Write-Host "✅ winget found" -ForegroundColor Green
Write-Host ""

# Function to install package via winget
function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$Name
    )

    Write-Host "📦 Installing $Name..." -ForegroundColor Cyan

    # Check if already installed
    $installed = winget list --id $PackageId --exact 2>&1 | Out-String
    if ($installed -match $PackageId) {
        Write-Host "  ✅ $Name already installed" -ForegroundColor Green
        return
    }

    # Install package
    winget install --id $PackageId --exact --silent --accept-package-agreements --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ $Name installed successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $Name installation failed (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
    }
}

# Install essential tools
Write-Host "📦 Installing essential tools..." -ForegroundColor Cyan
Write-Host ""

Install-WingetPackage -PackageId "Git.Git" -Name "Git"
Install-WingetPackage -PackageId "twpayne.chezmoi" -Name "chezmoi"
Install-WingetPackage -PackageId "Bitwarden.CLI" -Name "Bitwarden CLI"
Install-WingetPackage -PackageId "Alacritty.Alacritty" -Name "Alacritty"

Write-Host ""
Write-Host "✨ Installation complete!" -ForegroundColor Green
Write-Host ""

# Check if chezmoi is in PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    Write-Host "📝 Next steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Close and reopen PowerShell (to refresh PATH)" -ForegroundColor White
    Write-Host "  2. Initialize chezmoi with your dotfiles:" -ForegroundColor White
    Write-Host ""
    Write-Host "     chezmoi init https://github.com/mariomarin/dotfiles.git" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  3. Review changes:" -ForegroundColor White
    Write-Host ""
    Write-Host "     chezmoi diff" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  4. Apply dotfiles:" -ForegroundColor White
    Write-Host ""
    Write-Host "     chezmoi apply -v" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "⚠️  chezmoi not found in PATH. Please restart PowerShell and try again." -ForegroundColor Yellow
}

Write-Host "💡 Tip: For WSL, run the Linux setup after installing WSL2 and NixOS" -ForegroundColor Cyan
