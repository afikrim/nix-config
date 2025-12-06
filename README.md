# nix-config

Shareable flake-based configuration for both the personal NixOS VM and the `mekari-m2-pro` macOS host via nix-darwin + home-manager.

## Layout

- `flake.nix`: entry point describing available `nixosConfigurations` and `darwinConfigurations`.
- `hosts/personal`: NixOS modules (plus generated hardware config) for the personal VM.
- `hosts/mac-mekari`, `hosts/mac-personal`: nix-darwin modules for the two macOS hosts.
- `home/mac-mekari`, `home/mac-personal`: Home Manager profiles for each macOS user.
- `home`: shared dotfiles (Zsh, git, tmux, editors).
- `secrets`: per-host templates that feed `~/.config/dev/secrets.zsh` via `sops`.
- `pkgs`: custom Ruby derivations referenced by the Linux host.

## Apply the configurations

### NixOS (personal VM)

```bash
sudo nixos-rebuild switch --flake /home/azizf/nix-config#personal
```

### macOS (`mac-mekari` / `mac-personal`)

```bash
# 1. Ensure Determinate Systems Nix (or the multi-user installer) is installed.
# 2. Apply system settings with nix-darwin (pick the host you want to configure):
darwin-rebuild switch --flake ~/nix-config#mac-mekari
# or
darwin-rebuild switch --flake ~/nix-config#mac-personal

# 3. Apply user dotfiles with home-manager:
home-manager switch --flake ~/nix-config#mac-mekari
# or
home-manager switch --flake ~/nix-config#mac-personal
```

Each macOS host uses nix-darwin for system settings and its corresponding Home Manager profile (`home/mac-*/home.nix`) for user dotfiles/apps. Re-run both commands to keep OS + user state in sync.

### Secrets via sops

`~/.config/dev/secrets.zsh` is generated from the encrypted templates in `secrets/*/dev-secrets.sops.zsh`. To bootstrap:

1. Generate an age key (one-time):
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```
2. Copy the public key (from `age-keygen -y`) into `.sops.yaml`, replacing `age1REPLACE_ME_WITH_YOUR_PUBLIC_KEY`.
3. Edit the template for each host (placeholders live in `secrets/mac-*/dev-secrets.sops.zsh`) and encrypt it:
   ```bash
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   sops --encrypt --in-place secrets/mac-mekari/dev-secrets.sops.zsh
   # repeat for mac-personal if needed
   ```
4. Re-run `home-manager switch --flake ~/nix-config#mac-…`; the decrypted file is written to `~/.config/dev/secrets.zsh` (git-ignored).

## Update inputs

```bash
cd /home/azizf/nix-config
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --extra-experimental-features 'nix-command flakes' flake update
```
