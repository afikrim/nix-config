{ config, pkgs, lib, dotfiles, repoRoot, ... }:

let
  zshPlugins = import ../../pkgs/zsh-plugins.nix { inherit (pkgs) fetchFromGitHub; };
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
  secretsFile = "${toString repoRoot}/secrets/mac-personal/dev-secrets.sops.zsh";
  secretsExists = builtins.pathExists secretsFile;
  secretsPath = if secretsExists then builtins.path { path = secretsFile; name = "mac-personal-dev-secrets"; } else null;
in
{
  home = {
    username = "azizf";
    homeDirectory = "/Users/azizf";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    alacritty
    brave
    neovim
    vscode
  ];

  home.file =
    {
      ".zshrc".source = "${dotfiles}/.zshrc";
      ".mac.plugin.zsh".source = "${dotfiles}/.mac.plugin.zsh";
      ".linux.plugin.zsh".source = "${dotfiles}/.linux.plugin.zsh";
      ".p10k.zsh".source = "${dotfiles}/.p10k.zsh";
      ".p10k-light.zsh".source = "${dotfiles}/.p10k-light.zsh";
      ".tmux.conf".source = "${dotfiles}/.tmux.conf";
      ".gitmodules".source = "${dotfiles}/.gitmodules";
      ".gitconfig".source = "${dotfiles}/.gitconfig";
      ".gitconfig-boon".source = "${dotfiles}/.gitconfig-boon";
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
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/.config/nvim";
      recursive = true;
    };
    "dev/secrets.example.zsh".source = "${dotfiles}/.config/dev/secrets.example.zsh";
  };

  sops.defaultSopsFile = lib.mkIf secretsExists secretsPath;
  sops.secrets."dev-secrets" = lib.mkIf secretsExists {
    sopsFile = secretsPath;
    format = "binary";
    path = "${config.home.homeDirectory}/.config/dev/secrets.zsh";
  };
  sops.age.keyFile = lib.mkIf secretsExists "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  home.activation.developmentDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Development/mekari" \
             "$HOME/Development/getboon" \
             "$HOME/Development/azifex" \
             "$HOME/Development/afikrim"
  '';
}
