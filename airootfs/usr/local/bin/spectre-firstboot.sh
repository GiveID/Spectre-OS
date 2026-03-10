#!/usr/bin/env bash
# Spectre OS - First boot setup: copy skel to first user, ensure configs exist
# Runs once via spectre-firstboot.service

set +e

USER_HOME=$(getent passwd 1000 | cut -d: -f6)
USER_NAME=$(getent passwd 1000 | cut -d: -f1)

[[ -z "$USER_HOME" || ! -d "$USER_HOME" ]] && exit 0

# Copy skel configs to user home (Hyprland stack)
mkdir -p "$USER_HOME/.config"
for dir in hypr waybar wofi alacritty dunst spectre nvim; do
    [[ -d /etc/skel/.config/$dir ]] && cp -rn /etc/skel/.config/$dir "$USER_HOME/.config/"
done
[[ -f /etc/skel/.config/starship.toml ]] && cp -n /etc/skel/.config/starship.toml "$USER_HOME/.config/"
[[ -f /etc/skel/.zshrc ]] && cp -n /etc/skel/.zshrc "$USER_HOME/"

# Fix ownership
chown -R 1000:1000 "$USER_HOME/.config" "$USER_HOME/.zshrc" 2>/dev/null || true

# Make scripts executable
chmod +x "$USER_HOME/.config/spectre/scripts/wallpaper-hypr.sh" 2>/dev/null || true
chmod +x "$USER_HOME/.config/spectre/scripts/wallpaper.sh" 2>/dev/null || true

# Disable this service (run once)
systemctl disable spectre-firstboot.service 2>/dev/null || true
