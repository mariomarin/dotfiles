{ pkgs, lib, ... }:

{
  # Development environment for this repository
  # Includes formatters and linters for all languages used

  packages = with pkgs; [
    # Nix formatting and linting
    nixpkgs-fmt
    deadnix
    statix

    # Lua formatting
    stylua

    # Shell formatting and linting
    shellcheck
    shfmt

    # Multi-format formatting
    biome

    # YAML formatting
    yamlfmt

    # TOML formatting and LSP
    taplo

    # Markdown linting
    markdownlint-cli

    # agents
    claude-code
  ];

  # JavaScript/TypeScript environment
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_20;
    bun = {
      enable = true;
      install.enable = true;
    };
  };

  # Git hooks - format only staged files on commit
  git-hooks = {
    hooks = {
      # Post-commit hook to run make (applies chezmoi changes)
      post-commit = {
        enable = true;
        name = "Apply changes with make";
        entry = "make";
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

      # JSON and TOML formatting with biome
      biome = {
        enable = true;
        name = "biome";
        entry = "biome format --write --no-errors-on-unmatched";
        files = "\\.(json|jsonc|toml)$";
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
    };
  };

  # Shell initialization
  enterShell = ''
    echo "🚀 Development environment loaded"
    echo "📝 Pre-commit hooks installed - will format staged files on commit"
    echo "Available formatters: nixpkgs-fmt, stylua, shfmt, biome, yamlfmt, markdownlint"
    echo "Run 'make format' to format all files"
    echo "Run 'make lint' to check all files"
  '';
}
