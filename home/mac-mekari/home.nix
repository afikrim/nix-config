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
  secretsFile = "${toString repoRoot}/secrets/mac-mekari/dev-secrets.sops.zsh";
  secretsExists = builtins.pathExists secretsFile;
  secretsPath = if secretsExists then builtins.path { path = secretsFile; name = "mac-mekari-dev-secrets"; } else null;
  gpgSecretsFile = "${toString repoRoot}/secrets/mac-mekari/gpg-getboon.sops.asc";
  gpgSecretsExists = builtins.pathExists gpgSecretsFile;
  gpgSecretsPath = if gpgSecretsExists then builtins.path { path = gpgSecretsFile; name = "mac-mekari-gpg-getboon"; } else null;
  cloudflareTokenFile = "${toString repoRoot}/secrets/mac-mekari/cloudflare-tunnel-token.sops.txt";
  cloudflareTokenExists = builtins.pathExists cloudflareTokenFile;
  cloudflareTokenPath = if cloudflareTokenExists then builtins.path { path = cloudflareTokenFile; name = "mac-mekari-cloudflare-tunnel-token"; } else null;
  alacrittyThemes = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "f82c742634b5e840731dd7c609e95231917681a5";
    hash = "sha256-Jcxl1/fEWXPXVdJxRonXJpJx/5iQvTHfZqvd18gjvGk=";
  };
  defaultAlacrittyTheme = "${alacrittyThemes}/themes/one_light.toml";
  terminalNotifier = pkgs.callPackage ../../pkgs/terminal-notifier-xcode.nix { };
  devToolPackages =
    (with pkgs; [
      nodejs_24
      pnpm
      bun
      flutter
      github-copilot-cli
    ]);
in
{
  home = {
    username = "mekari";
    homeDirectory = "/Users/mekari";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  home.packages =
    (with pkgs; [
      alacritty
      brave
      neovim
      vscode
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
      ".config/alacritty/alacritty.toml".source = "${dotfiles}/.config/alacritty/alacritty.toml";
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
      ".local/bin/vnc-mac-personal" = {
        executable = true;
        text = ''
          #!/bin/bash
          # VNC to mac-personal via Cloudflare tunnel
          port=''${1:-5901}
          echo "Starting VNC tunnel on localhost:$port..."
          ${pkgs.cloudflared}/bin/cloudflared access tcp --hostname vnc.azifexlab.net --url localhost:$port &
          pid=$!
          sleep 2
          echo "Opening Screen Sharing..."
          open "vnc://localhost:$port"
          echo "Tunnel running (PID: $pid). Press Ctrl+C or close terminal to stop."
          trap "kill $pid 2>/dev/null" EXIT
          wait $pid
        '';
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

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "mac-personal" = {
        hostname = "ssh.azifexlab.net";
        user = "azizf";
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };

  programs.codex = {
    enable = true;
  };

  programs.claude-code = {
    enable = true;
  };

  home.activation = {
    ensureCloudflaredDir = lib.hm.dag.entryBefore [ "sopsNix" ] ''
      mkdir -p "$HOME/.config/cloudflared"
    '';
    developmentDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Development/mekari" \
               "$HOME/Development/personal" \
               "$HOME/Development/getboon"
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
