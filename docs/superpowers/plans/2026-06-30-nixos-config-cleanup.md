# NixOS Config Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply four targeted cleanups to the NixOS flake — remove a stale fish alias, remove a duplicate system package, add binary caches, and replace a greetd `lib.mkForce` override with the proper `initial_session` mechanism.

**Architecture:** Each change is independent and touches a single file. No new files or modules are created. Changes are applied in order and each gets its own commit and `nix flake check` gate.

**Tech Stack:** NixOS flakes, home-manager, greetd, pipewire

## Global Constraints

- All changes must pass `nix flake check` before committing
- Follow the existing module pattern: one concern per file, options via `lib.mkOption` only where a value needs to be overridable
- No new files unless the spec explicitly calls for them
- This repo is at `~/nix-conf`; the active host is `vortex`

---

### Task 1: Remove stale `hm-switch` fish alias

**Files:**
- Modify: `features/fish.nix`

**Interfaces:**
- Consumes: nothing
- Produces: nothing (pure removal)

- [ ] **Step 1: Remove the `hm-switch` entry from `shellAliases`**

  Open `features/fish.nix`. The `shellAliases` attrset currently contains:

  ```nix
  hm-switch = "home-manager switch --flake ~/Documents/nix-conf/#(hostname)";
  ```

  Delete that line entirely. The result should be:

  ```nix
  shellAliases = {
    check-opencode-update = "curl -s https://api.github.com/repos/Munsio/nix-conf/pulls?head=Munsio:auto/opencode-update&state=open | jq -r 'if .[0] then \"OpenCode update PR: \" + .[0].html_url else \"No pending opencode update.\" end'";
    ls = "ls --color=auto";
    ll = "ls -lah";
    ".." = "cd ..";
    os-update = "nh os switch -u -a";
  };
  ```

- [ ] **Step 2: Verify the flake evaluates**

  ```bash
  nix flake check ~/nix-conf 2>&1 | tail -20
  ```

  Expected: no errors mentioning `fish.nix` or `shellAliases`

- [ ] **Step 3: Commit**

  ```bash
  git -C ~/nix-conf add features/fish.nix
  git -C ~/nix-conf commit -m "fix(fish): remove stale hm-switch alias"
  ```

---

### Task 2: Remove duplicate `fzf` from system packages

**Files:**
- Modify: `hosts/default.nix`

**Interfaces:**
- Consumes: nothing
- Produces: nothing (pure removal; `fzf` remains in `users/martin/home.nix`)

- [ ] **Step 1: Remove `fzf` from `environment.systemPackages`**

  Open `hosts/default.nix`. The `environment.systemPackages` list currently includes `fzf`:

  ```nix
  environment.systemPackages = with pkgs; [
    dmidecode
    fzf
    btop
    killall
    pciutils
    usbutils
    wget
  ];
  ```

  Remove the `fzf` entry:

  ```nix
  environment.systemPackages = with pkgs; [
    dmidecode
    btop
    killall
    pciutils
    usbutils
    wget
  ];
  ```

- [ ] **Step 2: Verify the flake evaluates**

  ```bash
  nix flake check ~/nix-conf 2>&1 | tail -20
  ```

  Expected: no errors

- [ ] **Step 3: Commit**

  ```bash
  git -C ~/nix-conf add hosts/default.nix
  git -C ~/nix-conf commit -m "fix(common): remove duplicate fzf from system packages"
  ```

---

### Task 3: Add binary caches for nix-community and nvf

**Files:**
- Modify: `features/nixos.nix`

**Interfaces:**
- Consumes: nothing
- Produces: `nix.settings.substituters` and `nix.settings.trusted-public-keys` extended with two new entries

- [ ] **Step 1: Look up the nvf public key**

  The nix-community key is stable and well-known. The nvf key must be retrieved from Cachix:

  1. Visit `https://app.cachix.org/cache/nvf` in a browser
  2. Find the "Public signing keys" section — it will show a string in the format `nvf.cachix.org-1:<base64>=`
  3. Copy that key; you will paste it in the next step

  The nix-community key is:
  ```
  nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  ```

- [ ] **Step 2: Add substituters and trusted-public-keys to `features/nixos.nix`**

  Open `features/nixos.nix`. Replace the `nix.settings` block:

  ```nix
  # Before
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      trusted-users = ["@wheel"];
    };
  ```

  With (substitute the actual nvf key from Step 1 in place of `<NVF_KEY>`):

  ```nix
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      trusted-users = ["@wheel"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nvf.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "<NVF_KEY>"
      ];
    };
  ```

- [ ] **Step 3: Verify the flake evaluates**

  ```bash
  nix flake check ~/nix-conf 2>&1 | tail -20
  ```

  Expected: no errors

- [ ] **Step 4: Commit**

  ```bash
  git -C ~/nix-conf add features/nixos.nix
  git -C ~/nix-conf commit -m "feat(nixos): add nix-community and nvf binary caches"
  ```

---

### Task 4: Replace greetd `mkForce default_session` with `initial_session`

**Files:**
- Modify: `hosts/vortex/default.nix`

**Interfaces:**
- Consumes: `self.nixosModules.greetd` (which sets `default_session` to tuigreet)
- Produces: greetd that auto-starts Hyprland as `martin` on boot, falls back to tuigreet if Hyprland exits non-zero

- [ ] **Step 1: Replace the greetd override in `hosts/vortex/default.nix`**

  The current override:

  ```nix
  services.greetd.settings.default_session = lib.mkForce {
    command = "Hyprland";
    user = "martin";
  };
  ```

  Replace with:

  ```nix
  services.greetd.settings.initial_session = {
    command = "Hyprland";
    user = "martin";
  };
  ```

- [ ] **Step 2: Verify the flake evaluates**

  ```bash
  nix flake check ~/nix-conf 2>&1 | tail -20
  ```

  Expected: no errors. (`lib` remains in the module args — it is still used by `services.openssh.openFirewall = lib.mkForce true;` in the same file.)

- [ ] **Step 3: Commit**

  ```bash
  git -C ~/nix-conf add hosts/vortex/default.nix
  git -C ~/nix-conf commit -m "fix(vortex): use greetd initial_session for auto-login instead of mkForce"
  ```

---

## Verification After All Tasks

After all four commits:

```bash
nix flake check ~/nix-conf
```

Expected: clean exit, no warnings or errors across all four modified files.

To test Task 4 in practice, rebuild and reboot vortex:

```bash
nh os switch ~/nix-conf
# then reboot to verify Hyprland auto-starts without tuigreet
```
