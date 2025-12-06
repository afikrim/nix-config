{ config, pkgs, lib, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.enable = false;

  networking.hostName = "mac-mekari";
  networking.computerName = "mac-mekari";

  users.users.mekari = {
    name = "mekari";
    home = "/Users/mekari";
    shell = pkgs.zsh;
  };

  system.primaryUser = "mekari";

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    age
    sops
    coreutils
    curl
    fd
    ffmpeg
    git
    gnupg
    go
    jq
    lazygit
    neovim
    nodejs_22
    openssl
    pnpm
    python312
    ripgrep
    rsync
    stylua
    tmux
    tree
    tree-sitter
    typescript
    yarn
    zsh
    home-manager
  ];

  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
    AppleFontSmoothing = 1;
  };

  system.stateVersion = 5;
}
