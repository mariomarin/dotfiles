{
  description = "NixOS configurations for multiple hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, nur, home-manager, claude-code-nix, ... }@inputs:
    let
      # Common modules shared by all hosts
      commonModules = [
        # NUR overlay
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        # Make unstable packages available
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                system = final.system;
                config.allowUnfree = true;
              };
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
        # Physical ThinkPad T470 with full desktop
        nixos = mkSystem {
          hostname = "nixos";
          system = "x86_64-linux";
          modules = [
            # Main configuration
            ./configuration.nix

            # Host-specific configuration
            ./hosts/t470/configuration.nix

            # Hardware configuration for ThinkPad T470
            nixos-hardware.nixosModules.lenovo-thinkpad-t470s
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
          ];
        };

        # Headless VM configuration
        vm-headless = mkSystem {
          hostname = "vm-headless";
          system = "x86_64-linux";
          modules = [
            # Main configuration (shared)
            ./configuration.nix

            # VM-specific configuration
            ./hosts/vm/configuration.nix
          ];
        };
      };
    };
}
