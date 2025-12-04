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
        personal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/personal/default.nix
          ];
        };
      };
    };
}
