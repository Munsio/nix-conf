# AGENTS.md: A Guide for AI Agents

This document provides instructions and guidelines for AI agents interacting with this NixOS and home-manager configuration repository.

## 1. Project Overview

This is a NixOS configuration project with Home-Manager integration, using a flake setup with `flake-parts` for modularization. The configuration follows a **dendritic pattern** — directory trees auto-imported by `flake.nix` via `importTree`, where each `.nix` file (not starting with `_`, not `flake.nix` or `hardware-configuration.nix`) automatically becomes a module named after its filename.

- `flake.nix`: Entry point — auto-imports all `.nix` modules from `modules/`, `home/`, `hosts/`, and `users/`.
- `modules/`: NixOS-level configuration, organized into:
  - `features/`: Small, atomic NixOS configs (audio, bluetooth, steam, sops, etc.)
  - `services/`: NixOS services (greetd, openssh, print, twingate, qmk)
  - `bundles/`: Groups of NixOS features/services (hypr-desktop, yubikey, tailscale, automount)
  - `overlays.nix`: Custom nixpkgs overlays (unstable channel, opencode)
  - `devshell.nix`: `nix develop` shell definition
- `home/`: Home-manager configuration, same dendritic pattern:
  - `features/`: User-facing tools (fish, git, nvf, zed, carapace, etc.)
  - `services/`: User background services (clipman, hypridle, wayland-idle-inhibitor)
  - `bundles/`: Groups of home features/services (hypr-desktop)
  - `hyprland.lua`: Lua config for Hyprland compositor
- `hosts/`: Per-machine configurations:
  - `whirl/`: NixOS host (Framework 13 AMD laptop) + `hardware-configuration.nix`
  - `gust/`: Standalone home-manager profile (non-NixOS Linux)
- `users/`: Per-user base profile + host-specific overrides (martin)

## 2. Getting Started

The development environment is managed by `nix develop`. To get started, run:

```bash
nix develop
```

This will drop you into a shell with all the necessary tools for linting and formatting available.

## 3. Build and Apply

This is a NixOS configuration, so "building" means applying the configuration to a system.

- **Full NixOS System Rebuild**:

  ```bash
  sudo nixos-rebuild switch --flake .#<hostname>
  ```

  Replace `<hostname>` with the target host (e.g., `whirl`).

- **Home-Manager Only**:

  ```bash
  home-manager switch --flake .#<username>@<hostname>
  ```

  or for a standalone home configuration:

  ```bash
  home-manager switch --flake .#<home-configuration-name>
  ```

  Replace `<username>`, `<hostname>`, and `<home-configuration-name>` accordingly (e.g., `martin@whirl` or `gust`).

- **Dry-Run a NixOS Configuration**:
  To check if a NixOS configuration will build successfully without actually applying the changes, you can use the `build` command. This is a safe way to validate your changes before attempting a full `switch`.
  ```bash
  nixos-rebuild build --flake .#<hostname>
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
  To get a machine-readable output, use the `-o json` flag. This is useful for parsing the output and handling it programmatically.
  ```bash
  deadnix -o json .
  ```

## 5. Testing

There are no formal test suites in this repository. The primary means of ensuring correctness are:

1.  **Successful evaluation**: The Nix configuration must evaluate without errors.
2.  **Linting and formatting checks**: The linters and formatters must pass.

When making changes, ensure you can successfully run the "Build and Apply" commands for the affected hosts.

## 6. Code Style and Conventions

### File and Directory Structure

The configuration follows a **dendritic pattern**: every `.nix` file in `modules/`, `home/`, `hosts/`, and `users/` (excluding files starting with `_`, `flake.nix`, and `hardware-configuration.nix`) is auto-imported by `importTree` in `flake.nix`. The filename (without `.nix`) becomes the module name under `flake.nixosModules.<name>` or `flake.homeModules.<name>`.

- **Modularity**: Configurations within `modules/` and `home/` are split into `features`, `services`, and `bundles`.
  - `features/`: Small, atomic configurations for a single tool or application.
  - `services/`: Configurations for background processes.
  - `bundles/`: Groups of features and services.
- **Host-specific vs. User-specific**:
  - `hosts/`: Machine-level NixOS and home-manager settings.
  - `users/`: User-specific dotfiles and preferences.
- **Overlays**: Live in `modules/overlays.nix` (not a separate `overlays/` directory). Contains the `unstable` nixpkgs overlay and the custom `opencode` overlay.

### Naming Conventions

- Follow the existing naming conventions for files and directories.
- Use camelCase for variables and function names in Nix code.
- Use kebab-case for file and directory names.

### Types

- This project uses standard Nix types. No special type system is in use.

### Error Handling

- Ensure that your Nix expressions are well-formed and will evaluate correctly.
- Before applying changes, it's a good practice to perform a dry-run to validate the configuration. See the "Dry-Run a NixOS Configuration" section for details.

## 7. Workflows

### Adding a New Application (Feature)

1.  **Create Feature File**: Create a new file in `home/features/` (e.g., `home/features/my-app.nix`). The file name (without the `.nix` extension) will be used as the module name.
2.  **Write Configuration**: Write a standard home-manager module in this file, exporting it as `flake.homeModules.<name>`. For example:
    ```nix
    {...}: {
      flake.homeModules.my-app = {
        programs.my-app = {
          enable = true;
        };
      };
    }
    ```
3.  **Enable Feature**: Import the module in the user's home config (e.g., `users/martin/home.nix`):

    ```nix
    flake.homeModules.martin = {pkgs, ...}: {
      imports = [
        self.homeModules.my-app
        # ... other modules
      ];
    };
    ```

The same pattern applies to NixOS-level features under `modules/features/`.

### Modifying an Existing Configuration

1.  **Locate the relevant file**: Use `grep` or your knowledge of the project structure to find the file to edit.
2.  **Make your changes**: Follow the code style and conventions.
3.  **Lint and format**: Run the linting and formatting commands.
4.  **Apply the changes**: Use the appropriate `nixos-rebuild` or `home-manager` command.

## 8. Updating the OpenCode Overlay

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

## 9. TODO / Known Issues

- **`home/features/sops.nix`** and **`modules/features/sops.nix`**: Investigate `sops.secrets.<name>.neededForUsers = true` to ensure secrets are decrypted before the user session starts, eliminating potential race conditions.
