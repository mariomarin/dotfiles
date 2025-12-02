#!/usr/bin/env pwsh
# Bootstrap script for Windows
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle setup itself

[CmdletBinding()]
param()

Write-Host "🚀 Running Windows bootstrap..." -ForegroundColor Cyan

#region Configuration

# Packages to install via winget
$packages = @(
    @{ Id = "twpayne.chezmoi"; Command = "chezmoi"; DisplayName = "chezmoi" },
    @{ Id = "Nushell.Nushell"; Command = "nu"; DisplayName = "Nushell" },
    @{ Id = "Bitwarden.CLI"; Command = "bw"; DisplayName = "Bitwarden CLI" },
    @{ Id = "Casey.Just"; Command = "just"; DisplayName = "Just" },
    @{ Id = "MikeFarah.yq"; Command = "yq"; DisplayName = "yq (YAML processor)" },
    @{ Id = "topgrade-rs.topgrade"; Command = "topgrade"; DisplayName = "Topgrade" },
    @{ Id = "Kubernetes.krew"; Command = "kubectl-krew"; DisplayName = "Krew" },
    @{ Id = "Microsoft.Azure.Kubelogin"; Command = "kubelogin"; DisplayName = "Azure Kubelogin" },
    @{ Id = "ahmetb.kubectx"; Command = "kubectx"; DisplayName = "kubectx/kubens" }
)

#endregion

#region Helper Functions

# Function to refresh PATH in current session
function Update-SessionPath {
    <#
    .SYNOPSIS
    Refreshes the PATH environment variable in the current session.
    #>
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Function to test if a command exists
function Test-CommandExists {
    <#
    .SYNOPSIS
    Tests if a command is available in the current session.

    .PARAMETER CommandName
    The name of the command to test.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName
    )

    return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

# Function to install winget
function Install-Winget {
    <#
    .SYNOPSIS
    Installs or updates winget package manager.
    #>
    Write-Host "📦 Setting up winget..." -ForegroundColor Yellow

    try {
        # Use the community-maintained winget-install script
        # This handles all edge cases: dependencies, PATH, different Windows versions
        Write-Host "  Running winget-install script..." -ForegroundColor White
        & ([scriptblock]::Create((irm https://get.winget.run))) -Force -ErrorAction Stop

        # Refresh PATH in current session to pick up winget
        Update-SessionPath

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

# Function to install a package via winget
function Install-WingetPackage {
    <#
    .SYNOPSIS
    Installs a package using winget if not already installed.

    .PARAMETER PackageId
    The winget package ID.

    .PARAMETER CommandName
    The command name to check if the package is already installed.

    .PARAMETER DisplayName
    The friendly name to display in output messages.

    .RETURNS
    Boolean indicating if a restart is needed for PATH updates.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackageId,

        [Parameter(Mandatory)]
        [string]$CommandName,

        [Parameter(Mandatory)]
        [string]$DisplayName
    )

    Write-Host "📦 Checking $DisplayName..." -ForegroundColor White

    if (Test-CommandExists -CommandName $CommandName) {
        Write-Host "  ✓ $DisplayName already installed" -ForegroundColor Green
        return $false
    }

    try {
        Write-Host "  Installing $DisplayName..." -ForegroundColor Yellow
        winget install --id $PackageId --exact --silent --accept-package-agreements --accept-source-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $DisplayName installed" -ForegroundColor Green

            # Refresh PATH to make command available immediately
            Update-SessionPath

            # Verify command is now available
            if (Test-CommandExists -CommandName $CommandName) {
                Write-Host "  ✓ $CommandName command is ready" -ForegroundColor Green
                return $false
            } else {
                Write-Host "  ⚠️  $CommandName installed but not in PATH yet" -ForegroundColor Yellow
                return $true  # Restart needed
            }
        } else {
            throw "winget install failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Host "  ❌ Failed to install $($DisplayName): $_" -ForegroundColor Red
        exit 1
    }
}

#endregion

#region Main Script

# Check if winget is available, install if not
if (-not (Test-CommandExists -CommandName "winget")) {
    Install-Winget
} else {
    $version = winget --version
    Write-Host "✓ winget $version already available" -ForegroundColor Green
}

# Install packages
$needsRestart = $false
foreach ($package in $packages) {
    $restartNeeded = Install-WingetPackage -PackageId $package.Id -CommandName $package.Command -DisplayName $package.DisplayName
    if ($restartNeeded) {
        $needsRestart = $true
    }
}

Write-Host "" -ForegroundColor White
Write-Host "✅ Tools installed" -ForegroundColor Green

# If restart needed, stop here
if ($needsRestart) {
    Write-Host "" -ForegroundColor White
    Write-Host "⚠️  IMPORTANT: Please restart PowerShell and run this script again" -ForegroundColor Yellow
    Write-Host "   Newly installed commands require a fresh PowerShell session" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    exit 0
}

# Clone repository
Write-Host "" -ForegroundColor Cyan
Write-Host "==> Clone dotfiles repository" -ForegroundColor Cyan
$chezmoiPath = "$env:USERPROFILE/.local/share/chezmoi"
if (Test-Path "$chezmoiPath/.git") {
    Write-Host "ℹ️  Repository already exists" -ForegroundColor White
} else {
    git clone https://github.com/mariomarin/dotfiles.git $chezmoiPath
    Write-Host "✅ Repository cloned" -ForegroundColor Green
}

# Set hostname
Write-Host "" -ForegroundColor Cyan
Write-Host "==> Set hostname" -ForegroundColor Cyan
if (-not $env:HOSTNAME) {
    Write-Host "Available machines:" -ForegroundColor White
    Push-Location $chezmoiPath
    yq '.machines | keys | .[]' .chezmoidata/machines.yaml
    Pop-Location
    $hostname = Read-Host "`nEnter hostname for this machine"
    $env:HOSTNAME = $hostname
}
Write-Host "✅ Using hostname: $($env:HOSTNAME)" -ForegroundColor Green

# Initialize chezmoi
Write-Host "" -ForegroundColor Cyan
Write-Host "==> Initialize chezmoi" -ForegroundColor Cyan
Push-Location $chezmoiPath
chezmoi init --force
Write-Host "✅ Chezmoi initialized" -ForegroundColor Green

# Setup Bitwarden
Write-Host "" -ForegroundColor Cyan
Write-Host "==> Setup Bitwarden" -ForegroundColor Cyan
if (!(bw login --check 2>$null)) {
    Write-Host "⚠️  Please login to Bitwarden:" -ForegroundColor Yellow
    bw login
}
Write-Host "Unlocking vault..." -ForegroundColor White
just bw-unlock

Write-Host "" -ForegroundColor Green
Write-Host "✅ Bootstrap complete!" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd ~/.local/share/chezmoi" -ForegroundColor White
Write-Host "  just apply" -ForegroundColor White
Write-Host "" -ForegroundColor White
Pop-Location

#endregion
