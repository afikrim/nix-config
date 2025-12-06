# nix-config

Shareable flake-based configuration for both the personal NixOS VM and the `mekari-m2-pro` macOS host via nix-darwin + home-manager.

## Layout

- `flake.nix`: entry point describing available `nixosConfigurations` and `darwinConfigurations`.
- `hosts/personal`: NixOS modules (plus generated hardware config) for the personal VM.
- `hosts/mekari-m2-pro/darwin.nix`: nix-darwin module used on macOS.
- `home`: dotfiles that are linked by the macOS home-manager profile.
- `pkgs`: custom Ruby derivations referenced by the Linux host.

## Apply the configurations

### NixOS (personal VM)

```bash
sudo nixos-rebuild switch --flake /home/azizf/nix-config#personal
```

### macOS (`mekari-m2-pro`)

```bash
# 1. Ensure Determinate Systems Nix (or the multi-user installer) is installed.
# 2. Apply system settings with nix-darwin:
darwin-rebuild switch --flake ~/nix-config#mekari-m2-pro
# 3. Apply user dotfiles with home-manager:
home-manager switch --flake ~/nix-config#mekari
```

The macOS host uses nix-darwin for system settings and home-manager for user dotfiles (`~/nix-config/home`). Re-running the commands above keeps both in sync.

## Update inputs

```bash
cd /home/azizf/nix-config
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --extra-experimental-features 'nix-command flakes' flake update
```
