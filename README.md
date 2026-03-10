# Spectre OS

**Version:** Wraith  
**Base:** Arch Linux  
**Target:** Penetration testers, threat researchers, OSINT analysts

A reproducible, professional red-team and OSINT workstation distribution. Minimal boot splash, BSPWM tiling, cyan-on-navy theme. No Matrix clichés, no purple gradients.

---

## Quick Start

### Build the ISO (on Arch Linux)

```bash
# Install archiso
sudo pacman -S archiso

# Clone or copy this repository, then:
chmod +x build.sh
./build.sh
```

The ISO will be in `output/spectre-os-*.iso`. Write to USB:

```bash
sudo dd if=output/spectre-os-*.iso of=/dev/sdX bs=4M status=progress
```

### First Boot

1. Boot from USB — **LightDM graphical login** appears automatically.
2. Log in: `arch` / `arch` (or `root` / `root`).
3. BSPWM desktop starts. **Super + Enter** opens terminal, **Super + Space** opens app launcher.
4. In a terminal: `spectre-init` then `sudo spectre-harden`
5. Optional: `spectre-tools-install` for AUR packages

---

## Directory Structure

```
/etc/spectre/          # Distro config (motd, scripts)
/usr/local/bin/        # spectre-harden, spectre-init, anon, opsec, recon, exfil
~/.config/             # bspwm, sxhkd, polybar, rofi, alacritty, dunst, picom
~/.config/spectre/     # Wallpaper generator
~/.config/nvim/        # Neovim (lazy.nvim, LSP, telescope, oil)
~/.config/starship.toml
~/.zshrc               # Zinit, Starship, aliases
```

---

## Pre-Installed Tooling

### Recon / OSINT
- theHarvester, amass, subfinder, httpx, nuclei (AUR)
- shodan (pip), maltego CE (AUR)

### Network
- nmap, masscan, tshark, netcat, socat
- responder, bettercap (AUR)

### Exploitation
- metasploit-framework, sqlmap, ffuf, gobuster (AUR)
- burpsuite (AUR, install manually)

### Post-Exploitation
- impacket, bloodhound+neo4j, crackmapexec, evil-winrm (AUR)

### Crypto / Passwords
- hashcat, john, gpg, age, pass

### Anonymity
- tor, torsocks, proxychains-ng, macchanger, firejail, dnscrypt-proxy

### Dev / Scripting
- python3, pip, go, rustup, git, neovim
- LSP: pyright, gopls, bashls

---

## Aliases

| Alias  | Action |
|--------|--------|
| `scan` | `nmap -sV -sC -T4` |
| `recon`| Opens tmux with amass, subfinder, httpx panes |
| `anon` | Toggle Tor + MAC randomization |
| `exfil`| Menu: compress, encrypt, split files |
| `opsec`| OPSEC checklist (DNS, ports, VPN status) |

---

## OPSEC Hardening (spectre-harden)

Run `sudo spectre-harden` to:

1. Disable IPv6
2. Enable UFW (default-deny inbound)
3. Configure dnscrypt-proxy
4. MAC randomization at boot
5. Kernel sysctl hardening
6. AppArmor enable
7. auditd rules (setuid, /etc/passwd, /etc/shadow)
8. Disable telemetry

Manual steps: LUKS /home, GPG keypair (Kleopatra).

---

## Boot Splash

The ISO uses standard Arch boot. For installed systems, configure Plymouth:

```bash
sudo plymouth-set-default-theme -R text
```

Custom theme (Spectre branding): white text on black, IBM Plex Mono. See `/usr/share/plymouth/themes/` for structure.

---

## Theme

- **Background:** #0a0a0f
- **Accent:** #00ffe1 (cyan)
- **Alert:** #ff4c4c
- **Text:** #c9c9c9
- **Fonts:** IBM Plex Mono (terminal), IBM Plex Mono (UI; Geist optional)
- **Window:** 1px #00ffe1 border, 6px outer / 3px inner gaps

---

## Installation to Disk

Use `archinstall` or manual Arch install. After chroot:

```bash
# Copy Spectre configs
git clone https://github.com/spectre-os/spectre.git /tmp/spectre
cp -r /tmp/spectre/airootfs/etc/skel/. /home/youruser/
cp -r /tmp/spectre/airootfs/usr/local/bin/* /usr/local/bin/
cp -r /tmp/spectre/airootfs/etc/spectre /etc/
```

Then run `spectre-init` and `spectre-harden`.

---

## What Not Included

- No anime wallpapers, no "HACK THE PLANET" ASCII
- No neon green, no purple gradients
- No games or media apps
- No auto-login
- No unencrypted shell history (HISTFILE unset by default)
- No GUI package manager

---

## License

MIT. Tools have their own licenses.
