# macOS GUI applications from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web browsers
    firefox

    # Security & password management
    bitwarden

    # Development tools
    vscode
  ];
}
