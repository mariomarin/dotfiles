#!/usr/bin/env pwsh
# Install PowerShell modules from PowerShell Gallery
# This script runs when the module list or script content changes

Write-Host "📦 Installing PowerShell modules from PowerShell Gallery..." -ForegroundColor Cyan

# Ensure PowerShellGet is updated
Write-Host "  Updating PowerShellGet..." -ForegroundColor Gray
Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck -ErrorAction SilentlyContinue

# Set PSGallery as trusted (to avoid prompts)
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Write-Host "  Setting PSGallery as trusted repository..." -ForegroundColor Gray
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# List of modules to install
$modules = @(
    'PSReadLine',           # Enhanced command-line editing
    'posh-git',             # Git integration
    'Terminal-Icons',       # File/folder icons
    'PSFzf',                # fzf wrapper
    'git-aliases',          # Oh My Zsh style git aliases
    'CompletionPredictor'   # AI-powered predictions
)

foreach ($module in $modules) {
    Write-Host "  Checking $module..." -ForegroundColor Gray

    $installed = Get-Module -ListAvailable -Name $module | Sort-Object Version -Descending | Select-Object -First 1
    $online = Find-Module -Name $module -ErrorAction SilentlyContinue

    if (-not $installed) {
        Write-Host "    Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    } elseif ($online -and $online.Version -gt $installed.Version) {
        Write-Host "    Updating $module from $($installed.Version) to $($online.Version)..." -ForegroundColor Yellow
        Update-Module -Name $module -Force
    } else {
        Write-Host "    ✓ $module $($installed.Version) already installed" -ForegroundColor Green
    }
}

Write-Host "✅ PowerShell modules installed successfully" -ForegroundColor Green
