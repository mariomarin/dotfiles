{ pkgs, lib, ... }:

{
  # Development environment for this repository
  # Includes formatters and linters for all languages used

  # Enable dotenv support for loading .env file
  dotenv.enable = true;

  packages = with pkgs; [
    # Nix formatting, linting, and LSP
    nixpkgs-fmt
    deadnix
    statix
    nil # Nix LSP

    # Lua formatting and LSP
    stylua
    lua-language-server

    # Shell formatting, linting, and LSP
    shellcheck
    shfmt
    bash-language-server

    # JSON LSP
    vscode-langservers-extracted # Includes JSON, HTML, CSS LSPs

    # YAML formatting and LSP
    yamlfmt
    yaml-language-server

    # TOML formatting and LSP
    taplo

    # Markdown linting and LSP
    markdownlint-cli
    marksman

    # agents
    claude-code
  ];

  # Git hooks - format only staged files on commit
  git-hooks = {
    hooks = {
      # Post-commit hook to run just (applies chezmoi changes)
      post-commit = {
        enable = true;
        name = "Apply changes with just";
        entry = lib.mkForce "bash -c 'if [ -f .envrc.local ]; then source .envrc.local; fi && just'";
        language = "system";
        pass_filenames = false;
        always_run = true;
        stages = [ "post-commit" ];
      };

      # Nix formatting
      nixpkgs-fmt.enable = true;

      # Lua formatting
      stylua.enable = true;

      # Shell formatting with specific settings
      shfmt = {
        enable = true;
        entry = lib.mkForce "shfmt -w -i 2 -ci -sr -kp";
        excludes = [
          ".*\\.zsh$" # Exclude zsh files
          ".*zshrc$"
          ".*zshenv$"
          "private_dot_config/zim/.*" # Exclude zim modules
        ];
      };

      # Shell linting
      shellcheck = {
        enable = true;
        excludes = [
          ".envrc" # .envrc uses direnv-specific functions
          ".*\\.zsh$" # Exclude zsh files
          ".*zshrc$"
          ".*zshenv$"
          "private_dot_config/zim/.*" # Exclude zim modules
        ];
      };

      # Nushell syntax checking
      nushell-check = {
        enable = true;
        name = "nushell-check";
        entry = "nu --ide-check 0";
        files = "\\.nu$";
        language = "system";
        pass_filenames = true;
      };

      # TOML formatting with taplo
      taplo = {
        enable = true;
        name = "taplo";
        entry = "taplo fmt";
        files = "\\.toml$";
        language = "system";
        pass_filenames = true;
      };

      # YAML formatting with yamlfmt
      yamlfmt = {
        enable = true;
        name = "yamlfmt";
        entry = "yamlfmt";
        files = "\\.(yml|yaml)$";
        language = "system";
        pass_filenames = true;
      };

      # Markdown linting and formatting
      markdownlint = {
        enable = true;
        name = "markdownlint";
        entry = "markdownlint --fix";
        files = "\\.md$";
        language = "system";
        pass_filenames = true;
      };

      # Justfile formatting
      justfile-fmt = {
        enable = true;
        name = "justfile-fmt";
        entry = "just --fmt --unstable";
        files = "justfile$";
        language = "system";
        pass_filenames = false;
        always_run = false;
      };

      # LeftWM config validation
      leftwm-check = {
        enable = true;
        name = "leftwm-check";
        entry = "leftwm check";
        files = "config\\.ron(\\.tmpl)?$";
        language = "system";
        pass_filenames = false;
        always_run = false;
      };
    };
  };
}
