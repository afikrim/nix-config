{ config, pkgs, lib, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.enable = false;

  networking.hostName = "mac-personal";
  networking.computerName = "mac-personal";

  users.users.azizf = {
    name = "azizf";
    home = "/Users/azizf";
    shell = pkgs.zsh;
  };

  system.primaryUser = "azizf";

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
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
