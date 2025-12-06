{
  description = "Aziz Fikri's NixOS + nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix }:
    let
      lib = nixpkgs.lib;
      linuxSystem = "aarch64-linux";
      darwinSystem = "aarch64-darwin";
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
      };
      dotfiles = lib.cleanSource ./home;
      repoRoot = ./.;
      mkDarwinHost = hostModule:
        nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = { inherit dotfiles; };
          modules = [
            hostModule
          ];
        };
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
        mac-mekari = mkDarwinHost ./hosts/mac-mekari/default.nix;
        mac-personal = mkDarwinHost ./hosts/mac-personal/default.nix;
      };

      homeConfigurations = {
        mac-mekari = home-manager.lib.homeManagerConfiguration {
          pkgs = darwinPkgs;
          extraSpecialArgs = { inherit dotfiles repoRoot; };
          modules = [
            sops-nix.homeManagerModules.sops
            ./home/mac-mekari/home.nix
          ];
        };
        mac-personal = home-manager.lib.homeManagerConfiguration {
          pkgs = darwinPkgs;
          extraSpecialArgs = { inherit dotfiles repoRoot; };
          modules = [
            sops-nix.homeManagerModules.sops
            ./home/mac-personal/home.nix
          ];
        };
      };
    };
}
