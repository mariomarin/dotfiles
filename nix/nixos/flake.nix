{
  description = "NixOS configurations for multiple hosts";

  inputs = {
    # Stable 26.05 for NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Stable 26.05 for darwin (uses darwin-specific branch)
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Unstable available for select packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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

    caarlos0-nur = {
      url = "github:caarlos0/nur";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixos-wsl, nix-darwin, nur, claude-code-nix, ... }@inputs:
    let
      # Also exposed as `packages` for CI builds
      localPackages = pkgs: import ./pkgs { inherit pkgs; };

      # Common overlays shared by all hosts
      commonOverlays = [
        nur.overlays.default
        (final: _prev: {
          unstable = import nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
        } // localPackages final)
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
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ]
        (system: localPackages nixpkgs.legacyPackages.${system});

      nixosConfigurations = {
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
      };
    };
}
