# NixOS 25.05 Upgrade Instructions

## Changes Made

1. **Flake inputs updated**:
   - `nixpkgs`: 24.11 → 25.05
   - `home-manager`: release-24.11 → release-25.05

2. **Package updates**:
   - `nerdfonts.override` → individual `nerd-fonts.*` packages
   - `transmission_3` → `transmission-gtk`

3. **system.stateVersion**: Kept at "24.11" (correct behavior - this should remain at your original install version)

## Upgrade Steps

1. **Update flake inputs**:

   ```bash
   cd ~/nixos
   nix flake update
   ```

2. **Build and test the new configuration** (without switching):

   ```bash
   sudo nixos-rebuild test --flake .#nixos
   ```

3. **If test succeeds, switch to the new configuration**:

   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

4. **If you encounter issues**, you can rollback:

   ```bash
   sudo nixos-rebuild switch --rollback
   ```

## Post-Upgrade

After successful upgrade:

- Check that all services are running: `systemctl status`
- Verify audio/bluetooth: `systemctl --user status pipewire wireplumber`
- Test your applications work correctly
- The old NixOS 24.11 will be end-of-life on 2025-06-30

## Known Changes in 25.05

- GNOME upgraded to version 48 (not applicable - using leftwm)
- Linux kernel: 6.6 → 6.12
- LLVM 19, GCC 14
- Various package updates

## Troubleshooting

If you encounter package-specific issues:

1. Check the [NixOS 25.05 release notes](https://nixos.org/manual/nixos/stable/release-notes#sec-release-25.05)
2. Search for deprecated options in your configuration
3. Consider temporarily using older packages from nixpkgs-24.11 if needed
