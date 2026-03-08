# Spectre OS - Build Notes

## Requirements

- **Arch Linux** (physical or VM) with archiso installed
- ~15 GB free disk space
- Network connection for package downloads

## Build Process

The `build.sh` script:

1. Copies `/usr/share/archiso/configs/releng` to `archlive/`
2. Overlays Spectre's `profiledef.sh` and `packages.x86_64`
3. Rsyncs `airootfs/` (configs, scripts, dotfiles)
4. Updates boot menus for Spectre branding
5. Runs `mkarchiso` to produce the ISO

## Windows Users

The build must run on Linux (Arch). Options:

- Use WSL2 with Arch: `distrobox create -n arch -i archlinux`
- Use a VM (VirtualBox, VMware, QEMU)
- Use a cloud instance (e.g., DigitalOcean, Linode)

## Customization

- **profiledef.sh** - ISO metadata, install_dir (spectre)
- **packages.x86_64** - Full package list (replaces releng)
- **airootfs/** - All files placed in the live system root
- **airootfs/etc/skel/** - Dotfiles for new users
- **airootfs/root/customize_airootfs.sh** - Runs during build in chroot

## Testing

```bash
# QEMU (after build)
run_archiso -u -i output/spectre-os-*.iso
```

## Known Limitations

- AUR packages (metasploit, amass, etc.) require `spectre-tools-install` post-boot
- Geist font not in Arch repos; use IBM Plex Mono or install Geist manually
- Plymouth custom theme requires additional initramfs setup

## CI/CD Fixes (GitHub Actions)

- **syslinux**: Must be in packages.x86_64 for BIOS boot. Use LF line endings (no CRLF).
- **memtest86+, memtest86+-efi, edk2-shell**: Added to suppress mkarchiso warnings; provide memory test and UEFI shell.
- **Line endings**: Workflow strips CR from .sh, packages.x86_64, profiledef.sh before build.
- **Verification**: build.sh verifies syslinux in package list before mkarchiso; fails early with cat -A dump if missing.
