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
    nixpkgs-legacy.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, nixpkgs-legacy }:
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
      mkPkgsFor = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
      };
      mkLegacyPkgsFor = system: import nixpkgs-legacy {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
      };
      withQuickbookDeps = base: legacy: base // {
        nodejs_14 = legacy."nodejs-14_x";
      };
      darwinPkgs = mkPkgsFor darwinSystem;
      legacyDarwinPkgs = mkLegacyPkgsFor darwinSystem;
      quickbookDarwinPkgs = withQuickbookDeps darwinPkgs legacyDarwinPkgs;
      x86DarwinPkgs = mkPkgsFor "x86_64-darwin";
      legacyX86DarwinPkgs = mkLegacyPkgsFor "x86_64-darwin";
      quickbookX86DarwinPkgs = withQuickbookDeps x86DarwinPkgs legacyX86DarwinPkgs;
      linuxPkgs = mkPkgsFor linuxSystem;
      legacyLinuxPkgs = mkLegacyPkgsFor linuxSystem;
      quickbookLinuxPkgs = withQuickbookDeps linuxPkgs legacyLinuxPkgs;
      x86LinuxPkgs = mkPkgsFor "x86_64-linux";
      legacyX86LinuxPkgs = mkLegacyPkgsFor "x86_64-linux";
      quickbookX86LinuxPkgs = withQuickbookDeps x86LinuxPkgs legacyX86LinuxPkgs;
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
          boon-core = import ./devshells/boon-core/shell.nix { pkgs = darwinPkgs; };
          accounting_service = import ./devshells/accounting_service/shell.nix { pkgs = darwinPkgs; };
          quickbook = import ./devshells/quickbook/shell.nix { pkgs = quickbookDarwinPkgs; };
        };
        x86_64-darwin = {
          boon-core = import ./devshells/boon-core/shell.nix { pkgs = x86DarwinPkgs; };
          accounting_service = import ./devshells/accounting_service/shell.nix { pkgs = x86DarwinPkgs; };
          quickbook = import ./devshells/quickbook/shell.nix { pkgs = quickbookX86DarwinPkgs; };
        };
        aarch64-linux = {
          boon-core = import ./devshells/boon-core/shell.nix { pkgs = linuxPkgs; };
          accounting_service = import ./devshells/accounting_service/shell.nix { pkgs = linuxPkgs; };
          quickbook = import ./devshells/quickbook/shell.nix { pkgs = quickbookLinuxPkgs; };
        };
        x86_64-linux = {
          boon-core = import ./devshells/boon-core/shell.nix { pkgs = x86LinuxPkgs; };
          accounting_service = import ./devshells/accounting_service/shell.nix { pkgs = x86LinuxPkgs; };
          quickbook = import ./devshells/quickbook/shell.nix { pkgs = quickbookX86LinuxPkgs; };
        };
      };
    };
}
