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
  alacrittyThemes = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "f82c742634b5e840731dd7c609e95231917681a5";
    hash = "sha256-Jcxl1/fEWXPXVdJxRonXJpJx/5iQvTHfZqvd18gjvGk=";
  };
  defaultAlacrittyTheme = "${alacrittyThemes}/themes/one_light.toml";
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
      ".codex/AGENTS.md.bak".source = "${dotfiles}/.codex/AGENTS.md.bak";
      ".claude/CLAUDE.md".source = "${dotfiles}/.claude/CLAUDE.md";
      ".claude/settings.json".source = "${dotfiles}/.claude/settings.json";
      ".claude/mcp.json".source = "${dotfiles}/.claude/mcp.json";
      ".claude/commands/ultrathink" = {
        source = "${dotfiles}/.claude/commands/ultrathink";
        recursive = true;
      };
      ".config/alacritty/alacritty.toml".source = "${dotfiles}/.config/alacritty/alacritty.toml";
      ".config/alacritty/alacritty.toml.bak".source = "${dotfiles}/.config/alacritty/alacritty.toml.bak";
      ".config/scripts/theme-switcher.sh" = {
        source = "${dotfiles}/.config/scripts/theme-switcher.sh";
        executable = true;
      };
      ".config/alacritty/themes" = {
        source = "${alacrittyThemes}/themes";
        recursive = true;
      };
      ".zsh" = {
        source = "${dotfiles}/.zsh";
        recursive = true;
      };
    }
    // pluginFiles;

  xdg.configFile = {
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

  home.activation = {
    developmentDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Development/mekari" \
               "$HOME/Development/getboon" \
               "$HOME/Development/azifex" \
               "$HOME/Development/afikrim"
    '';
    prepareAlacrittyDir = lib.hm.dag.entryAfter [ "developmentDirs" ] ''
      target="$HOME/.config/alacritty"
      if [ -L "$target" ]; then
        rm "$target"
      fi
      mkdir -p "$target"
    '';
    cleanAlacrittyThemes = lib.hm.dag.entryAfter [ "prepareAlacrittyDir" ] ''
      target="$HOME/.config/alacritty/themes"
      if [ -d "$target" ] && [ ! -L "$target" ]; then
        rm -rf "$target"
      fi
    '';
    ensureAiAppDirs = lib.hm.dag.entryAfter [ "cleanAlacrittyThemes" ] ''
      mkdir -p "$HOME/.codex" "$HOME/.copilot" "$HOME/.claude/commands"
    '';
    ensureAlacrittyThemeLink = lib.hm.dag.entryAfter [ "cleanAlacrittyThemes" ] ''
      theme_link="$HOME/.config/alacritty/current-theme.toml"
      default_theme="${defaultAlacrittyTheme}"
      if [ ! -L "$theme_link" ] && [ ! -f "$theme_link" ]; then
        ln -sf "$default_theme" "$theme_link"
      fi
    '';
  };
}
