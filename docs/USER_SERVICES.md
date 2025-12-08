# User Services Management

This repository uses two different approaches for managing systemd user services, each with specific use cases and trade-offs.

## Overview

| Aspect | NixOS Modules | Chezmoi Scripts |
| --- | --- | --- |
| **Service Type** | System-wide user services | User-specific services |
| **Configuration** | Declarative (Nix) | Imperative (Shell scripts) |
| **Examples** | Syncthing, Rclone mount | Desktop autostart files |
| **Location** | `/etc/systemd/user/` | `~/.config/systemd/user/` |
| **Activation** | `nixos-rebuild` | `chezmoi apply` |
| **Persistence** | Survives user deletion | Tied to user home directory |

## Detailed Comparison

### NixOS Module Approach

**Used for:**

- Syncthing (`nixos/modules/services/syncthing.nix`)
- Rclone mounts (`nixos/modules/services.nix`)
- Polkit authentication agent

**How it works:**

```nix
systemd.user.services."service-name" = {
  description = "Service description";
  wantedBy = [ "graphical-session.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.package}/bin/command";
    Restart = "on-failure";
  };
};
```

**Advantages:**

- ✅ Declarative and reproducible
- ✅ Version controlled with rollback capability
- ✅ Package dependencies automatically handled
- ✅ Integrated with NixOS module system
- ✅ Services defined once for all users

**Drawbacks:**

- ❌ Requires system rebuild to modify (`just nixos`)
- ❌ Services are system-wide, not user-specific
- ❌ Harder to test changes quickly
- ❌ Can't reference user-specific paths directly
- ❌ Rebuilding entire system for user service changes

### Chezmoi Script Approach

**Used for:**

- Systemd user service symlink management (syncthing, ssh-agent)
- Desktop autostart entries

**How it works:**

```bash
#!/usr/bin/env bash
# .chezmoiscripts/linux/30-setup-battery-service.sh

cat > ~/.config/systemd/user/battery-combined-udev.service << 'EOF'
[Unit]
Description=Battery level notification daemon

[Service]
ExecStart=/path/to/script
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable battery-combined-udev.service
```

**Advantages:**

- ✅ User can modify without root access
- ✅ Quick iteration and testing
- ✅ Can reference user-specific paths easily
- ✅ More flexible for dynamic configurations
- ✅ Portable across non-NixOS systems

**Drawbacks:**

- ❌ Imperative - harder to track state
- ❌ No automatic rollback
- ❌ Manual dependency management
- ❌ Scripts can fail silently
- ❌ Harder to ensure idempotency

## Decision Matrix

| Use Case | Recommended Approach | Reason |
| --- | --- | --- |
| System daemons that all users need | NixOS Module | Declarative, system-wide |
| Services requiring NixOS packages | NixOS Module | Automatic dependency handling |
| User-specific configurations | Chezmoi Script | Flexibility, user control |
| Services needing frequent tweaks | Chezmoi Script | Quick iteration |
| Cross-platform services | Chezmoi Script | Portability |
| Services with complex dependencies | NixOS Module | Dependency management |

## Best Practices

1. **Prefer NixOS modules when:**
   - The service should be available to all users
   - You need strict dependency management
   - The service rarely changes
   - You want declarative configuration

2. **Use Chezmoi scripts when:**
   - The service is user-specific
   - You need to reference user paths
   - The service requires frequent adjustments
   - You want to test changes quickly

3. **Hybrid approach:**
   - Define the service in NixOS but symlink with Chezmoi
   - Use NixOS for packages, Chezmoi for configuration
   - Example: Syncthing service (NixOS) with user symlinks (Chezmoi)

## Current Services

### Managed by NixOS Modules

| Service | Module | Purpose |
| --- | --- | --- |
| Syncthing | `services/syncthing.nix` | File synchronization |
| Rclone | `services.nix` | Cloud storage mounts |
| Polkit Agent | `services.nix` | Authentication dialogs |
| Kanata | `services/kanata.nix` | Keyboard remapping |

### Managed by Chezmoi Scripts

| Service | Script | Purpose |
| --- | --- | --- |
| Systemd User Services | `linux-systemd-user-services.nu` | Manage symlinks for syncthing, ssh-agent |
| Desktop Autostart | `linux-autostart-desktop-files.nu` | Application startup |

### Managed by Chezmoi Files (Direct)

| Service | File | Purpose |
| --- | --- | --- |
| Battery Monitor | `battery-combined-udev.service` | Low battery notifications for Polybar |

## Migration Guidelines

To migrate a service from Chezmoi to NixOS:

1. Create a new module in `nixos/modules/services/`
2. Define the service using `systemd.user.services`
3. Import the module in `configuration.nix`
4. Remove the Chezmoi script
5. Run `nixos-rebuild switch`

To migrate from NixOS to Chezmoi:

1. Export the service definition
2. Create a Chezmoi script in `.chezmoiscripts/`
3. Write the service file to `~/.config/systemd/user/`
4. Remove from NixOS configuration
5. Run `chezmoi apply`
