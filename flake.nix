{
  description = "Test server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      disko,
      home-manager,
      quadlet-nix,
      ...
    }:
    {
      nixosConfigurations = {
        "nixos" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            disko.nixosModules.disko
            ./hardware-configuration.nix
            ./configuration.nix
            home-manager.nixosModules.home-manager
            # Enable podman & podman systemd generator
            quadlet-nix.nixosModules.quadlet
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
