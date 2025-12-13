{
  description = "NixOS configurations for multiple hosts";

  inputs = {
    # Stable 25.05 for NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # Stable 25.05 for darwin (uses darwin-specific branch)
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    # Unstable available for select packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # NixOS-WSL support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin support - use nix-darwin-25.05 branch
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, nixos-hardware, nixos-wsl, nix-darwin, nur, home-manager, claude-code-nix, ... }@inputs:
    let
      # Common modules shared by all hosts
      commonModules = [
        # NUR overlay
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        # Make unstable packages and custom packages available
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                system = final.system;
                config.allowUnfree = true;
              };
              tmux-harpoon = final.callPackage ./pkgs/tmux-harpoon.nix { };
              bitbucket-cli = final.callPackage ./pkgs/bitbucket-cli.nix { };
            })
            claude-code-nix.overlays.default
          ];
        }

        # Pass flake inputs to configuration
        { _module.args = { inherit inputs; }; }
      ];

      # Helper function to create a NixOS system
      mkSystem = { hostname, system, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = commonModules ++ modules;
          specialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations = {
        # dendrite - ThinkPad T470 portable workstation
        dendrite = mkSystem {
          hostname = "dendrite";
          system = "x86_64-linux";
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
        malus = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            # Make NUR, unstable packages and claude-code available via overlay
            {
              nixpkgs.overlays = [
                nur.overlays.default
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    system = final.system;
                    config.allowUnfree = true;
                  };
                  tmux-harpoon = final.callPackage ./pkgs/tmux-harpoon.nix { };
                  bitbucket-cli = final.callPackage ./pkgs/bitbucket-cli.nix { };
                })
                claude-code-nix.overlays.default
              ];
            }

            # Darwin configuration
            ../darwin/hosts/malus/configuration.nix
          ];
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
        };
      };
    };
}
