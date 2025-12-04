# macOS packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shells and prompts
    nushell # Modern shell with structured data support
    oh-my-posh # Prompt framework for nushell and other shells

    # Web browsers
    firefox

    # Security & password management
    bitwarden

    # Development tools
    vscode
  ];
}
