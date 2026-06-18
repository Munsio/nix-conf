# NixOS / nix-darwin Configuration

Modular NixOS, nix-darwin, and home-manager configuration using flakes and flake-parts.

## Hosts

| Host | Type | System |
|------|------|--------|
| **whirl** | NixOS | Framework 13 AMD (x86_64-linux) |
| **gust** | Home-Manager | Non-NixOS Linux (x86_64-linux) |
| **tempest** | nix-darwin | macOS (aarch64-darwin) |

## Development

Enter the dev shell (with alejandra, statix, deadnix, nil, nodejs):

```bash
# If direnv is installed:
direnv allow

# Otherwise:
nix develop
```

### Building and Testing

```bash
# Dry-run NixOS configuration (whirl)
nixos-rebuild build --flake .#whirl

# Apply NixOS configuration
sudo nixos-rebuild switch --flake .#whirl

# Dry-run nix-darwin configuration (tempest)
darwin-rebuild build --flake .#tempest

# Apply nix-darwin configuration
darwin-rebuild switch --flake .#tempest

# Apply standalone home-manager (gust)
home-manager switch --flake .#gust

# Apply home-manager only (on whirl)
home-manager switch --flake .#martin@whirl
```

**Inspect build output:**

```bash
# Build home-manager activation package
nix build .#nixosConfigurations.whirl.config.home-manager.users.martin.home.activationPackage

# Build NixOS system toplevel
nix build .#nixosConfigurations.whirl.config.system.build.toplevel

# Diff closures to see what changed
nix store diff-closures /run/current-system ./result/ | grep ghostty
```

### Formatting and Linting

```bash
# Format all Nix files
alejandra .

# Check formatting without making changes
alejandra --check .

# Lint for Nix anti-patterns
statix check .

# Find unused code
deadnix --fail .
```

## CI

GitHub Actions run on every push/PR to main:

- **nix-lint** (`.github/workflows/nix-lint.yml`) — alejandra, statix, deadnix, `nix flake check`
- **opencode-update** (`.github/workflows/opencode-update.yml`) — daily check for new opencode releases, auto-PR on update

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix), encrypted with age keys and stored in `secrets/`.

```bash
# Edit secrets for whirl
sops secrets/whirl.yaml
```

See `.sops.yaml` for key configuration.

## Project Structure

```
.
├── flake.nix             # Entry point — auto-imports all modules
├── modules/              # NixOS/nix-darwin level
│   ├── features/         # Atomic configs (audio, bluetooth, steam, sops, ...)
│   ├── services/         # System services (greetd, openssh, twingate, ...)
│   ├── bundles/          # Feature groups (hypr-desktop, tailscale, yubikey, ...)
│   ├── overlays.nix      # nixpkgs overlays (unstable, opencode)
│   ├── options.nix       # flake-parts option types
│   └── devshell.nix      # nix develop shell
├── home/                 # Home-manager level
│   ├── features/         # User tools (fish, git, nvf, zed, kitty, ...)
│   ├── services/         # User services (clipman, hypridle, ...)
│   └── bundles/          # Home feature groups (hypr-desktop)
├── hosts/                # Per-machine definitions
│   ├── default.nix       # Common NixOS module
│   ├── whirl/            # NixOS host
│   ├── gust/             # Standalone home-manager
│   └── tempest/          # nix-darwin host
├── users/                # Per-user profiles
│   └── martin/           # NixOS/Linux + macOS user
└── secrets/              # SOPS-encrypted secrets
```

## Inspiration and Thanks

- [anotherhadi](https://github.com/anotherhadi) — [nixy](https://github.com/anotherhadi/nixy)
- [Misterio77](https://github.com/Misterio77) — [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [vimjoyer](https://github.com/vimjoyer) — [nixconf](https://github.com/vimjoyer/nixconf)
