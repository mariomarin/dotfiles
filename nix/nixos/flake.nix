{
  description = "NixOS configurations for multiple hosts";

  inputs = {
    # Stable 26.05 for NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Stable 26.05 for darwin (uses darwin-specific branch)
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Unstable available for select packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # NixOS-WSL support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin support - must match nixpkgs-darwin branch
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv/v2.1.1";
    };

    caarlos0-nur = {
      url = "github:caarlos0/nur";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixos-hardware, nixos-wsl, nix-darwin, nur, devenv, claude-code-nix, ... }@inputs:
    let
      # Common overlays shared by all hosts
      commonOverlays = [
        nur.overlays.default
        (final: _prev: {
          unstable = import nixpkgs-unstable {
            inherit (final) system;
            config.allowUnfree = true;
          };
          tmux-harpoon = final.callPackage ./pkgs/tmux-harpoon.nix { };
          tmux-tilish = final.callPackage ./pkgs/tmux-tilish.nix { };
          bitbucket-cli = final.callPackage ./pkgs/bitbucket-cli.nix { };
          kanata-tray = final.callPackage ./pkgs/kanata-tray.nix { };
          jj-spr = final.callPackage ./pkgs/jj-spr.nix { };
          jj-stack = final.callPackage ./pkgs/jj-stack.nix { };
          jj-hooks = final.callPackage ./pkgs/jj-hooks.nix { };
          clipper = final.callPackage ./pkgs/clipper.nix { };
        })
        claude-code-nix.overlays.default
      ];

      # Helper function to create a NixOS system
      mkSystem = { system, modules, username, ... }:
        let
          userConfig = { inherit username; };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.overlays = commonOverlays; }
            { _module.args = { inherit inputs userConfig; }; }
          ] ++ modules;
          specialArgs = { inherit inputs; };
        };

      # Helper function to create a darwin system
      mkDarwin = { system, modules, username }:
        let
          userConfig = { inherit username; };
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            { nixpkgs.overlays = commonOverlays; }
          ] ++ modules;
          specialArgs = {
            inherit inputs userConfig;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
        };
    in
    {
      nixosConfigurations = {
        # dendrite - ThinkPad T470 portable workstation
        dendrite = mkSystem {
          hostname = "dendrite";
          system = "x86_64-linux";
          username = "mario";
          modules = [
            # Main configuration
            ./configuration.nix

            # Host-specific configuration
            ./hosts/dendrite/configuration.nix

            # Hardware configuration for ThinkPad T470
            nixos-hardware.nixosModules.lenovo-thinkpad-t470s
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
          ];
        };

        # mitosis - Virtual machine for testing and replication
        mitosis = mkSystem {
          hostname = "mitosis";
          system = "x86_64-linux";
          username = "mario";
          modules = [
            # Main configuration (shared)
            ./configuration.nix

            # VM-specific configuration
            ./hosts/mitosis/configuration.nix
          ];
        };

        # symbiont - NixOS on WSL (two systems coexisting)
        symbiont = mkSystem {
          hostname = "symbiont";
          system = "x86_64-linux";
          username = "mario";
          modules = [
            # NixOS-WSL base module (provides wsl.* options)
            nixos-wsl.nixosModules.default

            # Main configuration (shared)
            ./configuration.nix

            # WSL-specific configuration
            ./hosts/symbiont/configuration.nix
          ];
        };
      };

      # nix-darwin configurations
      darwinConfigurations = {
        # malus - macOS workstation
        malus = mkDarwin {
          system = "aarch64-darwin";
          username = "mario";
          modules = [ ../darwin/hosts/malus/configuration.nix ];
        };

        # axon - work Mac (nix-darwin for services)
        axon = mkDarwin {
          system = "aarch64-darwin";
          username = "mmarin";
          modules = [ ../darwin/hosts/axon/configuration.nix ];
        };
      };

      # Package bundles for non-NixOS hosts (linux-apt)
      packages = {
        x86_64-linux =
          let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = commonOverlays;
              config.allowUnfree = true;
            };
            cliPkgs = import ../common/modules/cli-tools-pkgs.nix pkgs;
          in
          {
            # Individual packages
            atuin = pkgs.unstable.atuin;
            devenv = devenv.packages.x86_64-linux.default;

            # Bundled environment for ribosome (linux-apt platform)
            ribosome-env = pkgs.buildEnv {
              name = "ribosome-cli-tools";
              paths = cliPkgs.base ++ cliPkgs.modern ++ [
                # Runtime (needed by Mason for node-based LSPs)
                pkgs.nodejs
              ];
              pathsToLink = [ "/bin" "/share" ];
            };
          };
      };
    };
}
