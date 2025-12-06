{ config, pkgs, lib, dotfiles, ... }:

let
  zshPlugins = import ../pkgs/zsh-plugins.nix { inherit (pkgs) fetchFromGitHub; };
  pluginFiles =
    lib.mapAttrs'
      (name: path: {
        name = ".zsh/plugins/${name}";
        value = {
          source = path;
          recursive = true;
        };
      })
      zshPlugins;
in
{
  home = {
    username = "mekari";
    homeDirectory = "/Users/mekari";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  home.file =
    {
      ".zshrc".source = "${dotfiles}/.zshrc";
      ".mac.plugin.zsh".source = "${dotfiles}/.mac.plugin.zsh";
      ".linux.plugin.zsh".source = "${dotfiles}/.linux.plugin.zsh";
      ".dev-boon.plugin.zsh".source = "${dotfiles}/.dev-boon.plugin.zsh";
      ".dev-mekari.plugin.zsh".source = "${dotfiles}/.dev-mekari.plugin.zsh";
      ".p10k.zsh".source = "${dotfiles}/.p10k.zsh";
      ".p10k-light.zsh".source = "${dotfiles}/.p10k-light.zsh";
      ".skhdrc".source = "${dotfiles}/.skhdrc";
      ".tmux.conf".source = "${dotfiles}/.tmux.conf";
      ".yabairc".source = "${dotfiles}/.yabairc";
      ".gitmodules".source = "${dotfiles}/.gitmodules";
      ".gitconfig".source = "${dotfiles}/.gitconfig";
      ".gitconfig-amartha".source = "${dotfiles}/.gitconfig-amartha";
      ".gitconfig-boon".source = "${dotfiles}/.gitconfig-boon";
      ".gitconfig-deliv".source = "${dotfiles}/.gitconfig-deliv";
      ".gitconfig-freelance".source = "${dotfiles}/.gitconfig-freelance";
      ".gitconfig-mekari".source = "${dotfiles}/.gitconfig-mekari";
      ".gitconfig-personal".source = "${dotfiles}/.gitconfig-personal";
      ".zsh" = {
        source = "${dotfiles}/.zsh";
        recursive = true;
      };
    }
    // pluginFiles;

  xdg.configFile = {
    "alacritty".source = "${dotfiles}/.config/alacritty";
    "nvim".source = "${dotfiles}/.config/nvim";
    "sketchybar".source = "${dotfiles}/.config/sketchybar";
  };
}
