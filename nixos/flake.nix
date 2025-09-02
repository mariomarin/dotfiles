{
  description = "NixOS configuration for ThinkPad T470";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, nur, home-manager, claude-code-nix, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # Main configuration
        ./configuration.nix

        # Hardware configuration for ThinkPad T470
        nixos-hardware.nixosModules.lenovo-thinkpad-t470s

        # Enable common hardware settings
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

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

      specialArgs = { inherit inputs; };
    };
  };
}
