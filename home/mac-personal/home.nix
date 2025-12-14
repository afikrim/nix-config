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
  tmuxPlugins = import ../../pkgs/tmux-plugins.nix { inherit pkgs; };
  tmuxPluginFiles =
    lib.mapAttrs'
      (name: path: {
        name =
          if name == "oh-my-tmux" then
            ".tmux/oh-my-tmux"
          else
            ".tmux/plugins/${name}";
        value = {
          source = path;
          recursive = true;
        };
      })
      tmuxPlugins;
  secretsFile = "${toString repoRoot}/secrets/mac-personal/dev-secrets.sops.zsh";
  secretsExists = builtins.pathExists secretsFile;
  secretsPath = if secretsExists then builtins.path { path = secretsFile; name = "mac-personal-dev-secrets"; } else null;
  gpgSecretsFile = "${toString repoRoot}/secrets/mac-personal/gpg-getboon.sops.asc";
  gpgSecretsExists = builtins.pathExists gpgSecretsFile;
  gpgSecretsPath = if gpgSecretsExists then builtins.path { path = gpgSecretsFile; name = "mac-personal-gpg-getboon"; } else null;
  cloudflareTokenFile = "${toString repoRoot}/secrets/mac-personal/cloudflare-tunnel-token.sops.txt";
  cloudflareTokenExists = builtins.pathExists cloudflareTokenFile;
  cloudflareTokenPath = if cloudflareTokenExists then builtins.path { path = cloudflareTokenFile; name = "mac-personal-cloudflare-tunnel-token"; } else null;
  defaultKittyTheme = "${dotfiles}/.config/kitty/themes/one_light.conf";
  terminalNotifier = pkgs.callPackage ../../pkgs/terminal-notifier-xcode.nix { };
  devToolPackages =
    (with pkgs; [
      nodejs_24
      pnpm
      bun
      flutter
      google-cloud-sdk
      uv
      posting
    ]);
  # SSH authorized keys for remote access
  authorizedKeys = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYlfc5U0E6Y3tblUm6V60yN3X6IpzDYxJvvFP02w7EW mekari@mac-mekari
  '';
in
{
  home = {
    username = "azizf";
    homeDirectory = "/Users/azizf";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  programs.codex = {
    enable = true;
  };

  programs.claude-code = {
    enable = true;
  };


  home.packages =
    (with pkgs; [
      kitty
      brave
      chafa
      fzf
      ghostscript
      imagemagick
      lua5_1
      luarocks
      neovim
      nodePackages_latest.mermaid-cli
      rust-analyzer
      tectonic
      trash-cli
      ueberzugpp
      viu
      vscode
      wezterm
    ])
    ++ devToolPackages
    ++ [ terminalNotifier ];

  home.file =
    {
      ".zshrc".source = "${dotfiles}/.zshrc";
      ".mac.plugin.zsh".source = "${dotfiles}/.mac.plugin.zsh";
      ".linux.plugin.zsh".source = "${dotfiles}/.linux.plugin.zsh";
      ".dev-mekari.plugin.zsh".source = "${dotfiles}/.dev-mekari.plugin.zsh";
      ".dev-boon.plugin.zsh".source = "${dotfiles}/.dev-boon.plugin.zsh";
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
      ".codex/config.toml".source = "${dotfiles}/.codex/config.toml";
      ".codex/notify.sh".source = "${dotfiles}/.codex/notify.sh";
      ".copilot/config.json".source = "${dotfiles}/.copilot/config.json";
      ".copilot/mcp-config.json".source = "${dotfiles}/.copilot/mcp-config.json";
      ".config/kitty/kitty.conf".source = "${dotfiles}/.config/kitty/kitty.conf";
      ".config/scripts/theme-switcher.sh" = {
        source = "${dotfiles}/.config/scripts/theme-switcher.sh";
        executable = true;
      };
      ".config/kitty/themes" = {
        source = "${dotfiles}/.config/kitty/themes";
        recursive = true;
      };
      ".zsh" = {
        source = "${dotfiles}/.zsh";
        recursive = true;
      };
      ".ssh/authorized_keys" = {
        text = authorizedKeys;
      };
    }
    // pluginFiles
    // tmuxPluginFiles;

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
  sops.secrets."gpg-getboon" = lib.mkIf gpgSecretsExists {
    sopsFile = gpgSecretsPath;
    format = "binary";
    path = "${config.home.homeDirectory}/.gnupg/getboon-private.asc";
  };
  sops.secrets."cloudflare-tunnel-token" = lib.mkIf cloudflareTokenExists {
    sopsFile = cloudflareTokenPath;
    format = "binary";
    path = "${config.home.homeDirectory}/.config/cloudflared/tunnel-token";
  };
  sops.age.keyFile = lib.mkIf secretsExists "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  home.activation = {
    ensureSshDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
    '';
    ensureCloudflaredDir = lib.hm.dag.entryBefore [ "sopsNix" ] ''
      mkdir -p "$HOME/.config/cloudflared"
    '';
    developmentDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Development/mekari" \
               "$HOME/Development/getboon" \
               "$HOME/Development/azifex" \
               "$HOME/Development/afikrim"
    '';
    prepareKittyDir = lib.hm.dag.entryAfter [ "developmentDirs" ] ''
      target="$HOME/.config/kitty"
      if [ -L "$target" ]; then
        rm "$target"
      fi
      mkdir -p "$target"
    '';
    cleanKittyThemes = lib.hm.dag.entryAfter [ "prepareKittyDir" ] ''
      target="$HOME/.config/kitty/themes"
      if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
      fi
    '';
    ensureAiAppDirs = lib.hm.dag.entryAfter [ "cleanKittyThemes" ] ''
      mkdir -p "$HOME/.codex" "$HOME/.copilot" "$HOME/.claude/commands"
    '';
    ensureKittyThemeLink = lib.hm.dag.entryAfter [ "cleanKittyThemes" ] ''
      theme_link="$HOME/.config/kitty/current-theme.conf"
      default_theme="${defaultKittyTheme}"
      if [ ! -L "$theme_link" ] && [ ! -f "$theme_link" ]; then
        ln -sf "$default_theme" "$theme_link"
      fi
    '';
    importGpgKey = lib.hm.dag.entryAfter [ "sopsNix" ] ''
      gpg_key="$HOME/.gnupg/getboon-private.asc"
      if [ -f "$gpg_key" ]; then
        # Check if key is already imported
        if ! ${pkgs.gnupg}/bin/gpg --list-secret-keys "aziz@getboon.ai" &>/dev/null; then
          ${pkgs.gnupg}/bin/gpg --batch --import "$gpg_key" 2>/dev/null || true
        fi
      fi
    '';
  };
}
