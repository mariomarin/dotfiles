# macOS packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shells and prompts
    oh-my-posh # Prompt framework for nushell and other shells
    carapace # Universal completion framework (nushell, zsh, bash, fish)

    # Development tools
    vscode
  ];
}
