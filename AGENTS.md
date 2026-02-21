
# AGENTS.md: A Guide for AI Agents

This document provides instructions and guidelines for AI agents interacting with this NixOS and home-manager configuration repository.

## 1. Project Overview

This is a NixOS configuration project with Home-Manager integration, using a flake setup. The configuration is designed to be highly modular, separating concerns into distinct, reusable units.

- `flake.nix`: The entry point of the configuration.
- `hosts/`: Contains machine-specific configurations.
- `home/`: Contains user-specific and application configurations, managed by home-manager.
- `modules/`: Contains NixOS modules.
- `overlays/`: Contains overlays to add or modify packages.
- `users/`: Contains user-specific configurations.
- `lib/`: Contains helper functions.

A more detailed explanation of the architecture can be found in `.continue/rules/codebase.md`.

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

## 5. Testing

There are no formal test suites in this repository. The primary means of ensuring correctness are:

1.  **Successful evaluation**: The Nix configuration must evaluate without errors.
2.  **Linting and formatting checks**: The linters and formatters must pass.

When making changes, ensure you can successfully run the "Build and Apply" commands for the affected hosts.

## 6. Code Style and Conventions

### File and Directory Structure

- **Modularity**: Configurations are split into `features`, `services`, and `bundles`.
  - `features/`: Small, atomic configurations for a single tool or application.
  - `services/`: Configurations for background processes.
  - `bundles/`: Groups of features and services.
- **Host-specific vs. User-specific**:
  - `hosts/`: Machine-level settings.
  - `users/`: User-specific dotfiles and preferences.

### Naming Conventions

- Follow the existing naming conventions for files and directories.
- Use camelCase for variables and function names in Nix code.
- Use kebab-case for file and directory names.

### Types

- This project uses standard Nix types. No special type system is in use.

### Error Handling

- Ensure that your Nix expressions are well-formed and will evaluate correctly.
- Before applying changes, it's a good practice to run `nix flake check` if checks were defined, or try to build the configuration for the target host without switching to it: `nixos-rebuild build --flake .#<hostname>`.

## 7. Workflows

### Adding a New Application (Feature)

1.  **Create Feature File**: Create a new file in `home/features/` (e.g., `home/features/my-app.nix`).
2.  **Write Configuration**: Write the home-manager configuration for the application inside this new file.
3.  **Enable Feature**: Enable the feature in a `home.nix` file for a specific host or user.

### Modifying an Existing Configuration

1.  **Locate the relevant file**: Use `grep` or your knowledge of the project structure to find the file to edit.
2.  **Make your changes**: Follow the code style and conventions.
3.  **Lint and format**: Run the linting and formatting commands.
4.  **Apply the changes**: Use the appropriate `nixos-rebuild` or `home-manager` command.
