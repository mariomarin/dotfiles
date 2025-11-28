# Sensitive Information Audit

This document lists all potentially sensitive information that should be removed or genericized before publishing
this repository publicly.

## ⚠️ Critical - Contains Actual Secrets

### SSH Key Templates

**Files:**

- `private_dot_ssh/id_ed25519.pub.tmpl.tmpl`
- `private_dot_ssh/private_id_ed25519.tmpl.tmpl`

**Issue:** References Bitwarden item name "id-rsa"

**Action:** These are fine to keep - they're templates that fetch from Bitwarden. Just document in README that users
need to create their own Bitwarden items.

## 📋 Personal Identifiers - Should Genericize

### Username "mario"

**Files with username references:**

- `nix/nixos/modules/users.nix` - User account definition
- `private_dot_config/kmonad/README.md` - Example user in installation instructions
- Many `.git/` files (can be ignored - git history will be preserved)

**Action:**

1. In `nix/nixos/modules/users.nix`, replace with placeholder:

   ```nix
   users.users.yourname = {  # Change from mario
     isNormalUser = true;
     description = "Your Name";  # Change from mario
   ```

2. In `private_dot_config/kmonad/README.md`, use placeholder:

   ```nix
   users.users.yourname = {  # Instead of mario
   ```

3. Add note in README: "Replace `yourname` with your actual username throughout the configuration"

### GitHub Repository URLs

**Files:**

- `README.md` (3 occurrences)

**URLs:**

- `https://github.com/mariomarin/dotfiles.git`

**Action:** Replace with generic placeholder or your actual public repository URL:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.local/share/chezmoi
chezmoi init https://github.com/yourusername/dotfiles.git
```

### Hostname "nixos"

**Files:**

- `.chezmoi.toml.tmpl` - Line 21: `{{- else if eq $hostname "nixos" -}}`
- `.chezmoidata/machines.yaml` - Line 7: `hostname: nixos`

**Action:** Add note in README that users should customize this for their own hostname.

## 🖥️ Machine-Specific Information

### ThinkPad T470 References

**Files:**

- Multiple configuration files reference "t470" as a host
- `nix/nixos/hosts/t470/configuration.nix`
- `private_dot_config/kmonad/README.md` - "ThinkPad T470"
- `.chezmoidata/machines.yaml` - t470 machine definition

**Action:** These are fine - they're example configurations. Add note in README:

> "The repository includes example configurations for a ThinkPad T470. You can use these as a template for your own
> hardware."

### Bitwarden Item Names

**Files:**

- `private_dot_ssh/*.tmpl.tmpl` - Item name "id-rsa"
- `docs/secrets.md` - Example using "id-rsa"
- `CLAUDE.md` - Example using "id-rsa"

**Action:** These are documentation examples. Fine to keep, but add note that users should choose their own item names.

## ✅ Already Generic/Safe

### Configuration Files

- All Nix modules - contain only package lists and system configuration
- Shell configurations - generic settings
- Application configs - no personal data
- `.chezmoidata.toml` - only version pins

### Secrets Management

- No actual secrets in repository (all fetched from Bitwarden)
- SSH keys are templates only
- Git credentials not stored in repo

## 📝 Recommended Actions Before Publishing

### 1. Update README.md

Add a "Customization" section (already exists, enhance it):

```markdown
## Before You Start

This is a personal dotfiles repository. You'll need to customize:

1. **Username**: Replace `mario` with your username in:
   - `nix/nixos/modules/users.nix`
   - NixOS configuration files
2. **Repository URL**: Update git clone URLs in README to point to your fork
3. **Hostname**: Update `.chezmoi.toml.tmpl` and `.chezmoidata/machines.yaml`
4. **Bitwarden Items**: Create your own SSH key items in Bitwarden
5. **Git Config**: Remove or update git user configuration
```

### 2. Create Template Files

Consider creating `.example` versions of sensitive files:

- `users.nix.example` with placeholder username
- `machines.yaml.example` with example hostnames

### 3. Add .gitignore for Local Overrides

Already handled - `.envrc.local` and similar files are git-ignored.

### 4. Documentation

Add to README:

- Clear warning that this is a personal configuration
- Instructions for forking and customizing
- List of files that need personalization

## 🔍 Files That Don't Need Changes

### Safe to Publish As-Is

- All package lists in Nix modules
- Application configurations (nvim, tmux, etc.)
- Scripts and automation
- Documentation (CLAUDE.md, README.md after updates)
- Template files (*.tmpl) - they're templates!

### Git History

Git history will contain your username and email in commits. Consider:

1. Keep history (shows development, more transparent)
2. Squash/rewrite history (cleaner but loses context)
3. Start fresh repository from current state

## Summary

**High Priority (Must Change):**

- [ ] Replace `mariomarin` in GitHub URLs in README.md (3 locations)
- [ ] Add "Customization" warning section to README.md
- [ ] Document username replacement in documentation

**Medium Priority (Should Consider):**

- [ ] Create `.example` template files for sensitive configs
- [ ] Add clearer documentation about hostname customization
- [ ] Consider git history (keep vs. squash)

**Low Priority (Optional):**

- [ ] Replace "mario" in example code with "youruser" or similar placeholder
- [ ] Add more explicit "fork and customize" instructions

**Not Needed:**

- ❌ Removing machine names (t470, etc.) - these are example configurations
- ❌ Removing Bitwarden item names - these are documentation examples
- ❌ Changing Nix package configurations - these are generic
