# AGENTS.md: A Guide for AI Agents

This document provides instructions and guidelines for AI agents interacting with this NixOS, nix-darwin, and home-manager configuration repository.

## 1. Project Overview

This is a NixOS/nix-darwin configuration project with Home-Manager integration, using a flake setup with `flake-parts` for modularization. The configuration follows a **dendritic pattern** — directory trees auto-imported by `flake.nix` via `importTree`, where each `.nix` file (not starting with `_`, not `flake.nix` or `hardware-configuration.nix`) automatically becomes a module named after its filename. Subdirectories with `default.nix` are also auto-imported as modules named after the directory.

- `flake.nix`: Entry point — auto-imports all `.nix` modules from `modules/`, `home/`, `hosts/`, and `users/`.
- `modules/`: NixOS/nix-darwin level configuration, organized into:
  - `features/`: Small, atomic configs (audio, bluetooth, heroic, hyprland, nh, nixos, proton-vpn, sops, steam, systemd-boot)
  - `services/`: System services (greetd, openssh, print, qmk, twingate)
  - `bundles/`: Groups of features/services (automount, hypr-desktop, tailscale, yubikey)
  - `overlays.nix`: Custom nixpkgs overlays (unstable channel, opencode) — exports both `nixosModules` and `darwinModules`
  - `options.nix`: Defines `flake.homeModules` and `flake.darwinModules` option types for flake-parts
  - `devshell.nix`: `nix develop` shell definition (supports `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`)
- `home/`: Home-manager configuration, same dendritic pattern:
  - `features/`: User-facing tools (ansible, carapace, devenv, direnv, discord, fish, fuzzel, ghostty, git, gnome-disks, hyprland, hyprlock, hyprpaper, hyprshot, icons-cursors, kitty, moonlight, noctalia, nvf, obsidian, opencode, opentofu, quickshell, signal-desktop, sops, starship, stylix, yazi, zed, zen-browser, zoxide)
  - `services/`: User background services (clipman, hypridle, wayland-idle-inhibitor)
  - `bundles/`: Groups of home features/services (hypr-desktop)
  - `hyprland.lua`: Lua config for Hyprland compositor
- `hosts/`: Per-machine configurations:
  - `default.nix`: Common NixOS module (timezone, locale, system packages shared across all NixOS hosts)
  - `whirl/`: NixOS host (Framework 13 AMD laptop) — `default.nix` + `home.nix` + `hardware-configuration.nix`
  - `gust/`: Standalone home-manager profile (non-NixOS Linux) — `home.nix`
  - `tempest/`: nix-darwin host (macOS) — `default.nix` + `home.nix`
- `users/`: Per-user base profile + host-specific overrides:
  - `martin/`: NixOS/Linux user — `default.nix` (NixOS user module), `home.nix` (base home config), `home-whirl.nix`, `home-gust.nix`
  - `martin.treml/`: macOS user — `home.nix` (base home config), `home-tempest.nix`
- `secrets/`: SOPS-encrypted secrets (e.g., `whirl.yaml`)
- `opencode.json`: OpenCode editor configuration (MCP servers)
- `shell.nix`: flake-compat for older Nix versions without flake support
- `.sops.yaml`: SOPS age key configuration
- `.envrc`: direnv configuration (auto-enters dev shell)
- `statix.toml`: Statix linter configuration

### Flake Inputs

- `nixpkgs` (nixos-26.05), `nixpkgs-unstable` (nixos-unstable)
- `nixos-hardware` — Framework 13 AMD hardware config
- `home-manager` (release-26.05)
- `nix-darwin` (nix-darwin-26.05) — macOS support
- `sops-nix` — Secrets management
- `stylix` — System-wide theming
- `nvf` — Neovim distribution
- `noctalia` — Legacy v4
- `zen-browser-flake` — Zen Browser (twilight)
- `wayland-pipewire-idle-inhibit` — Idle inhibitor
- `opencode-src` — OpenCode source (used by overlay)
- `flake-parts` — Module system

## 2. Getting Started

The development environment is managed by `nix develop` (and direnv). To get started, run:

```bash
# If direnv is installed, simply allow the .envrc:
direnv allow

# Otherwise, manually enter the dev shell:
nix develop
```

This will drop you into a shell with all the necessary tools (alejandra, statix, deadnix, nil, nodejs).

## 3. Build and Apply

### NixOS (whirl)

- **Full System Rebuild**:
  ```bash
  sudo nixos-rebuild switch --flake .#whirl
  ```
- **Dry-Run**:
  ```bash
  nixos-rebuild build --flake .#whirl
  ```

### nix-darwin (tempest)

- **Full System Rebuild**:
  ```bash
  darwin-rebuild switch --flake .#tempest
  ```
- **Dry-Run**:
  ```bash
  darwin-rebuild build --flake .#tempest
  ```

### Standalone Home-Manager (gust)

```bash
home-manager switch --flake .#gust
```

### Home-Manager Only (NixOS host)

```bash
home-manager switch --flake .#martin@whirl
```

## 4. Linting and Formatting

Before committing any changes, ensure the code is properly linted and formatted.

### Formatting

- **Check formatting**:
  ```bash
  alejandra --check .
  ```
- **Fix formatting**:
  ```bash
  alejandra .
  ```

### Linting

- **Static analysis**:
  ```bash
  statix check .
  ```
- **Find unused code**:
  ```bash
  deadnix --fail .
  ```
  For machine-readable output:
  ```bash
  deadnix -o json .
  ```

### Nix LSP

The devshell includes `nil` (Nix Language Server) for editor integration.

### CI

GitHub Actions automatically run `alejandra`, `statix`, `deadnix`, and `nix flake check` on push/PR to main (`.github/workflows/nix-lint.yml`).

## 5. Testing

There are no formal test suites in this repository. The primary means of ensuring correctness are:

1. **Successful evaluation**: The Nix configuration must evaluate without errors.
2. **Linting and formatting checks**: The linters and formatters must pass.

When making changes, ensure you can successfully run the "Build and Apply" commands for the affected hosts.

## 6. Code Style and Conventions

### File and Directory Structure

The configuration follows a **dendritic pattern**: every `.nix` file in `modules/`, `home/`, `hosts/`, and `users/` (excluding files starting with `_`, `flake.nix`, and `hardware-configuration.nix`) is auto-imported by `importTree` in `flake.nix`. The filename (without `.nix`) becomes the module name under `flake.nixosModules.<name>`, `flake.homeModules.<name>`, or `flake.darwinModules.<name>`. Subdirectories with `default.nix` are imported as modules named after the directory (e.g., `home/features/stylix/` → `homeModules.stylix`).

- **Modularity**: Configurations within `modules/` and `home/` are split into `features`, `services`, and `bundles`.
  - `features/`: Small, atomic configurations for a single tool or application.
  - `services/`: Configurations for background processes.
  - `bundles/`: Groups of features and services.
- **Host layout**: Each host in `hosts/<name>/` typically has:
  - `default.nix`: System-level NixOS or nix-darwin configuration
  - `home.nix`: Home-manager wiring (imports user home modules, external inputs)
- **User layout**: Each user in `users/<name>/` typically has:
  - `default.nix`: NixOS user module (user account, groups) — optional
  - `home.nix`: Base home-manager configuration (shared across all hosts)
  - `home-<host>.nix`: Host-specific home-manager overrides
- **Overlays**: Live in `modules/overlays.nix`. Contains the `unstable` nixpkgs overlay and the custom `opencode` overlay. Exported as both `nixosModules.unstableOverlay` and `darwinModules.unstableOverlay`.

### Naming Conventions

- Follow the existing naming conventions for files and directories.
- Use camelCase for variables and function names in Nix code.
- Use kebab-case for file and directory names.

### Types

- This project uses standard Nix types. No special type system is in use.

### Error Handling

- Ensure that your Nix expressions are well-formed and will evaluate correctly.
- Before applying changes, it's a good practice to perform a dry-run to validate the configuration. See the "Build and Apply" section for details.

## 7. Workflows

### Adding a New Application (Feature)

1. **Create Feature File**: Create a new file in `home/features/` (e.g., `home/features/my-app.nix`). The file name (without the `.nix` extension) will be used as the module name.
2. **Write Configuration**: Write a standard home-manager module in this file, exporting it as `flake.homeModules.<name>`. For example:
   ```nix
   {pkgs, ...}: {
     flake.homeModules.my-app = {
       programs.my-app = {
         enable = true;
       };
     };
   }
   ```
3. **Enable Feature**: Import the module in the user's base home config (e.g., `users/martin/home.nix`):

   ```nix
   {self, ...}: {
     flake.homeModules.martin = {pkgs, ...}: {
       imports = [
         self.homeModules.my-app
         # ... other modules
       ];
     };
   }
   ```

The same pattern applies to NixOS-level features under `modules/features/` and nix-darwin features.

### Modifying an Existing Configuration

1. **Locate the relevant file**: Use `grep` or your knowledge of the project structure to find the file to edit.
2. **Make your changes**: Follow the code style and conventions.
3. **Lint and format**: Run the linting and formatting commands.
4. **Apply the changes**: Use the appropriate `nixos-rebuild`, `darwin-rebuild`, or `home-manager` command.

## 8. Secrets (SOPS)

Secrets are managed with `sops-nix` and encrypted with age keys. Configuration lives in:

- `.sops.yaml`: Age key definitions and creation rules (which keys can encrypt which files)
- `secrets/`: Encrypted YAML files (one per host, e.g., `whirl.yaml`)

### Structure

Keys are defined for each user and host. Creation rules map path patterns to key groups:

```yaml
keys:
  users:
    - &martin age18reh...
  hosts:
    - &whirl age1lw3p...
creation_rules:
  - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
    key_groups:
      - age:
        - *martin
        - *whirl
```

### Editing Secrets

```bash
sops secrets/whirl.yaml
```

### Referencing Secrets in Config

```nix
sops.defaultSopsFile = "${self}/secrets/whirl.yaml";
sops.secrets."my-secret" = {
  path = "/some/path";
};
```

## 9. Updating the OpenCode Overlay

The `opencode` package in nixpkgs (both stable and unstable) is frequently out of date, so a custom overlay in `modules/overlays.nix` pins a specific version from the `opencode-src` flake input.

### Automated Updates

A GitHub Action (`.github/workflows/opencode-update.yml`) runs daily and on manual trigger to check for new opencode releases. When one is found, it:
1. Updates `opencodeVersion` and the `opencode-src` flake lock to the new release tag
2. Computes the correct `node_modules` hash via a `nix build`
3. Opens a PR on the `auto/opencode-update` branch

### Checking for Pending Updates

Run the Fish alias:
```bash
check-opencode-update
```
This queries the GitHub API for an open auto-update PR on `Munsio/nix-conf`. If one exists, it prints the PR URL.

### Manual Update (if needed)

1. Update `opencodeVersion` in `modules/overlays.nix`
2. Update the flake lock: `nix flake lock --update-input opencode-src`
3. Attempt a build — it will fail with a hash mismatch, showing the new expected hash
4. Update `opencodeHash` with the new value
5. Verify with a dry-run: `nixos-rebuild build --flake .#whirl`

## 10. TODO / Known Issues

- **`home/features/sops.nix`** and **`modules/features/sops.nix`**: Investigate `sops.secrets.<name>.neededForUsers = true` to ensure secrets are decrypted before the user session starts, eliminating potential race conditions.
