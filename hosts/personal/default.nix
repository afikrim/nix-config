{ config, pkgs, lib, dotfiles, ... }:

let
  ruby_3_3_6 = pkgs.callPackage ../../pkgs/ruby_3_3_6.nix { };
  ruby_3_3_6_wrapper = pkgs.callPackage ../../pkgs/ruby_3_3_6_wrapper.nix { inherit ruby_3_3_6; };
  ruby_2_6_5 = pkgs.callPackage ../../pkgs/ruby_2_6_5.nix {
    openssl = pkgs.openssl_1_1;
  };
  ruby_2_6_5_wrapper = pkgs.callPackage ../../pkgs/ruby_2_6_5_wrapper.nix { inherit ruby_2_6_5; };
  azizGroup = config.users.users.azizf.group or "users";
  gemHomeRuby336 = "/home/azizf/.gem/ruby/3.3.0";
  gemHomeRuby265 = "/home/azizf/.gem/ruby/2.6.0";
  zshPlugins = import ../../pkgs/zsh-plugins.nix { inherit (pkgs) fetchFromGitHub; };
  installZshPlugins =
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList
        (name: path:
          "        rm -rf /home/azizf/.zsh/plugins/${name}\n"
          + "        cp -r ${path} /home/azizf/.zsh/plugins/${name}\n"
          + "        chown -R azizf:${azizGroup} /home/azizf/.zsh/plugins/${name}")
        zshPlugins);
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  ################
  # NIX SETTINGS #
  ################

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  ################
  # BOOTLOADER   #
  ################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ################
  # NETWORKING   #
  ################

  networking.hostName = "personal";
  networking.networkmanager.enable = true;

  ################
  # LOCALE / TZ  #
  ################

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  ################
  # HYPRLAND     #
  ################

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.agreety}/bin/agreety --cmd Hyprland";
        user = "greeter";
      };
      initial_session = {
        command = "Hyprland";
        user = "azizf";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  ################
  # VIDEO / GPU  #
  ################

  services.xserver.videoDrivers = [ "virtio" ];

  hardware.graphics.enable = true;


  ################
  # AUDIO        #
  ################

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ################
  # FILE MANAGER #
  ################

  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  ################
  # USER         #
  ################

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.zsh.enable = true;

  users.users.azizf = {
    isNormalUser = true;
    description = "Aziz Fikri";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  virtualisation.docker.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  system.activationScripts = {
    hyprlandConfig = {
      deps = [ "users" ];
      text = ''
        install -d -m755 -o azizf -g ${azizGroup} /home/azizf/.config/hypr
        install -m644 -o azizf -g ${azizGroup} ${./hypr/hyprland.conf} /home/azizf/.config/hypr/hyprland.conf
      '';
    };

    dotfilesInstall = {
      deps = [ "users" ];
      text = ''
        install -d -m755 -o azizf -g ${azizGroup} /home/azizf/.config
        rm -rf /home/azizf/.config/nvim
        rm -rf /home/azizf/.config/sketchybar
        rm -rf /home/azizf/.config/kitty
        rm -rf /home/azizf/.zsh
        rm -rf /home/azizf/.tmux

        ${pkgs.rsync}/bin/rsync -a --chown=azizf:${azizGroup} ${dotfiles}/ /home/azizf/

        install -d -m755 -o azizf -g ${azizGroup} /home/azizf/.zsh/plugins
${installZshPlugins}
      '';
    };
  };

  ################
  # FONTS        #
  ################

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  ################
  # PACKAGES     #
  ################

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = with pkgs; [
    "lima-1.0.7"
    "openssl-1.1.1w"
  ];

  environment.systemPackages = with pkgs; [
    vim
    neovim
    ripgrep
    fd
    lazygit
    tree-sitter
    stylua
    curl
    git
    gnupg
    openssl
    gcc
    gnumake
    pkg-config
    libyaml
    libffi
    colima
    docker_28
    pinentry-qt

    brave
    vscode
    codex
    claude-code
    firefox
    (writeShellScriptBin "brave-soft" ''
      export LIBGL_ALWAYS_SOFTWARE=1
    
      exec brave \
        --use-gl=swiftshader \
        --disable-gpu \
        --disable-software-rasterizer \
        --disable-gpu-compositing \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --disable-features=VaapiVideoDecoder,AcceleratedVideoDecode \
        --disable-gpu-shader-disk-cache \
        --disable-breakpad \
        --disable-crashpad \
        --disable-extensions-file-access-check \
        --no-first-run \
        --password-store=basic \
        --enable-logging=stderr \
        --process-per-tab \
        "$@"
    '' )

    ruby_3_3_6
    ruby_3_3_6_wrapper
    ruby_2_6_5
    ruby_2_6_5_wrapper
    go
    python3
    nodePackages_latest.nodejs
    nodePackages_latest.npm
    yarn
    typescript
    typescript-language-server

    hyprland
    hyprpaper
    hypridle
    hyprlock

    kitty
    (writeShellScriptBin "kitty-soft" ''
      export LIBGL_ALWAYS_SOFTWARE=1
      exec kitty "$@"
    '' )

    waybar
    wofi
    rofi

    mako

    wl-clipboard
    grim
    slurp

    playerctl
    brightnessctl
    zsh
    zsh-powerlevel10k
  ];

  environment.variables = {
    NPM_CONFIG_PREFIX = "/home/azizf/.npm-global";
    GEM_HOME = gemHomeRuby336;
    GEM_PATH = gemHomeRuby336;
    GEM_HOME_RUBY_3_3_6 = gemHomeRuby336;
    GEM_PATH_RUBY_3_3_6 = gemHomeRuby336;
    GEM_HOME_RUBY_2_6_5 = gemHomeRuby265;
    GEM_PATH_RUBY_2_6_5 = gemHomeRuby265;
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.curl ]}";
  };

  ################
  # FINAL        #
  ################

  system.stateVersion = "25.05";
}
