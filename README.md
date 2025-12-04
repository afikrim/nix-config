# nix-config

Shareable flake-based NixOS configuration for the Azik Fikri personal VM (formerly “utm”).

## Layout

- `flake.nix`: entry point describing available `nixosConfigurations` (`personal`).
- `hosts/personal`: host-specific settings plus generated hardware profile.
- `pkgs`: custom Ruby derivations referenced by the host config.

## Apply the configuration

```bash
sudo nixos-rebuild switch --flake /home/azizf/nix-config#personal
```

## Update inputs

```bash
cd /home/azizf/nix-config
nix --extra-experimental-features 'nix-command flakes' flake update
```
