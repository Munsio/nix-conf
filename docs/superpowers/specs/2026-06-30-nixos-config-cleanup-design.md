# NixOS Config Cleanup — Design

**Date:** 2026-06-30

## Overview

Four targeted cleanups to the NixOS flake configuration addressing a stale alias, a duplicate package, missing binary caches, and an improper greetd auto-login override.

## Changes

### 1. Remove stale `hm-switch` fish alias (`features/fish.nix`)

Delete the `hm-switch` entry from `shellAliases`. The alias pointed to `~/Documents/nix-conf/` which is not where the flake lives. `nh` is already installed and `os-update` covers NixOS switching; home-manager switching can be done via `nh home switch` directly.

### 2. Remove duplicate `fzf` from system packages (`hosts/default.nix`)

Remove `fzf` from `environment.systemPackages` in the `common` nixosModule. `fzf` is already declared in `users/martin/home.nix` as a home-manager package. System packages are for host-level tools; user tools belong to home-manager. Home-manager takes precedence.

### 3. Add binary caches (`features/nixos.nix`)

Extend `nix.settings` with substituters and trusted public keys for:
- `https://nix-community.cachix.org` — covers nixos-hardware, stylix, and other nix-community packages
- `https://nvf.cachix.org` — covers nvf (the primary heavy builder in this config)

Public keys for both caches must be verified from their respective Cachix pages during implementation.

### 4. Proper auto-login via `initial_session` (`hosts/vortex/default.nix`)

Replace the `lib.mkForce` override on `default_session` with greetd's native `initial_session`:

```nix
# Before
services.greetd.settings.default_session = lib.mkForce {
  command = "Hyprland";
  user = "martin";
};

# After
services.greetd.settings.initial_session = {
  command = "Hyprland";
  user = "martin";
};
```

`initial_session` is greetd's built-in auto-login mechanism. It starts the configured session immediately on boot and falls back to `default_session` (tuigreet) on failure. This removes the `lib.mkForce` smell while preserving the same boot behavior and keeping tuigreet available as a fallback.

## Files Changed

| File | Change |
|------|--------|
| `features/fish.nix` | Remove `hm-switch` from `shellAliases` |
| `hosts/default.nix` | Remove `fzf` from `environment.systemPackages` |
| `features/nixos.nix` | Add `substituters` and `trusted-public-keys` to `nix.settings` |
| `hosts/vortex/default.nix` | Replace `mkForce default_session` with `initial_session`; remove `lib` from module args (only used for `mkForce`) |

## Out of Scope

- Fixing `nixpkgs.follows` for unpinned inputs (separate concern)
- Changing `EDITOR` to `nvim`
- `alsa.support32Bit` gaming audio fix
- Any new modules or structural refactoring
