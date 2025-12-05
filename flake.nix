{
  description = "Aziz Fikri's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
      dotfiles = nixpkgs.lib.cleanSource ./home;
    in {
      nixosConfigurations = {
        personal = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit dotfiles; };
          modules = [
            ./hosts/personal/default.nix
          ];
        };
        mekari-m2-pro = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit dotfiles; };
          modules = [
            ./hosts/mekari-m2-pro/default.nix
          ];
        };
      };
    };
}
