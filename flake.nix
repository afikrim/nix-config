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
      braveOverlay = final: prev:
        let
          newVersion = "1.85.111";
        in
        if prev.stdenv.hostPlatform.system == "aarch64-darwin" then
          {
            brave = prev.brave.overrideAttrs (_: {
              version = newVersion;
              src = prev.fetchzip {
                url = "https://github.com/brave/brave-browser/releases/download/v${newVersion}/brave-v${newVersion}-darwin-arm64.zip";
                hash = "sha256-4U9nKCxrrLKE7ZRUsyi4ECuzDGzevm7eIU2jGUyUjN8=";
              };
            });
          }
        else
          { };
      overlays = [ braveOverlay ];
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
        inherit overlays;
      };
      dotfiles = lib.cleanSource ./home;
      repoRoot = ./.;
      mkDarwinHost = hostModule:
        nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = { inherit dotfiles; };
          modules = [
            { nixpkgs.overlays = overlays; }
            hostModule
          ];
        };
    in {
      nixosConfigurations = {
        personal = lib.nixosSystem {
          system = linuxSystem;
          specialArgs = { inherit dotfiles; };
          modules = [
            { nixpkgs.overlays = overlays; }
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

      # Development shells for various projects
      devShells = {
        aarch64-darwin = {
          boon-core = import ./devshells/boon-core.nix { pkgs = darwinPkgs; };
          default = import ./devshells/boon-core.nix { pkgs = darwinPkgs; };
        };
        x86_64-darwin = let
          x86Pkgs = import nixpkgs {
            system = "x86_64-darwin";
            config.allowUnfree = true;
            inherit overlays;
          };
        in {
          boon-core = import ./devshells/boon-core.nix { pkgs = x86Pkgs; };
          default = import ./devshells/boon-core.nix { pkgs = x86Pkgs; };
        };
        aarch64-linux = let
          linuxPkgs = import nixpkgs {
            system = linuxSystem;
            config.allowUnfree = true;
            inherit overlays;
          };
        in {
          boon-core = import ./devshells/boon-core.nix { pkgs = linuxPkgs; };
          default = import ./devshells/boon-core.nix { pkgs = linuxPkgs; };
        };
        x86_64-linux = let
          x86LinuxPkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            inherit overlays;
          };
        in {
          boon-core = import ./devshells/boon-core.nix { pkgs = x86LinuxPkgs; };
          default = import ./devshells/boon-core.nix { pkgs = x86LinuxPkgs; };
        };
      };
    };
}
