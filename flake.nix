{
  description = "Aziz Fikri's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
    in {
      nixosConfigurations = {
        utm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/utm/default.nix
          ];
        };
      };
    };
}
