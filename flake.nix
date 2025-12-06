{
  description = "Aziz Fikri's NixOS + nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      lib = nixpkgs.lib;
      linuxSystem = "aarch64-linux";
      darwinSystem = "aarch64-darwin";
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
      };
      dotfiles = lib.cleanSource ./home;
    in {
      nixosConfigurations = {
        personal = lib.nixosSystem {
          system = linuxSystem;
          specialArgs = { inherit dotfiles; };
          modules = [
            ./hosts/personal/default.nix
          ];
        };
      };

      darwinConfigurations = {
        mekari-m2-pro = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = { inherit dotfiles; };
          modules = [
            ./hosts/mekari-m2-pro/darwin.nix
          ];
        };
      };

      homeConfigurations = {
        mekari = home-manager.lib.homeManagerConfiguration {
          pkgs = darwinPkgs;
          extraSpecialArgs = { inherit dotfiles; };
          modules = [
            ./home/darwin-home.nix
          ];
        };
      };
    };
}
