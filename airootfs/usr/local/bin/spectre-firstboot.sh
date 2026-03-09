#!/usr/bin/env bash
# Spectre OS - First boot setup: copy skel to first user, ensure configs exist
# Runs once via spectre-firstboot.service

set +e

USER_HOME=$(getent passwd 1000 | cut -d: -f6)
USER_NAME=$(getent passwd 1000 | cut -d: -f1)

[[ -z "$USER_HOME" || ! -d "$USER_HOME" ]] && exit 0

# Copy skel configs to user home
mkdir -p "$USER_HOME/.config"
for dir in bspwm sxhkd polybar picom rofi alacritty dunst spectre nvim; do
    [[ -d /etc/skel/.config/$dir ]] && cp -rn /etc/skel/.config/$dir "$USER_HOME/.config/"
done
[[ -f /etc/skel/.config/starship.toml ]] && cp -n /etc/skel/.config/starship.toml "$USER_HOME/.config/"
[[ -f /etc/skel/.xinitrc ]] && cp -n /etc/skel/.xinitrc "$USER_HOME/"
[[ -f /etc/skel/.xprofile ]] && cp -n /etc/skel/.xprofile "$USER_HOME/"
[[ -f /etc/skel/.zshrc ]] && cp -n /etc/skel/.zshrc "$USER_HOME/"

# Ensure .xinitrc exists (critical for startx)
if [[ ! -f "$USER_HOME/.xinitrc" ]]; then
    printf '%s\n' 'sxhkd &' 'exec bspwm' > "$USER_HOME/.xinitrc"
fi

# Ensure sxhkd config exists
mkdir -p "$USER_HOME/.config/sxhkd"
if [[ ! -f "$USER_HOME/.config/sxhkd/sxhkdrc" ]]; then
    [[ -f /etc/skel/.config/sxhkd/sxhkdrc ]] && cp /etc/skel/.config/sxhkd/sxhkdrc "$USER_HOME/.config/sxhkd/"
fi

# Fix ownership
chown -R 1000:1000 "$USER_HOME/.config" "$USER_HOME/.xinitrc" "$USER_HOME/.xprofile" "$USER_HOME/.zshrc" 2>/dev/null || true

# Make bspwmrc executable
chmod +x "$USER_HOME/.config/bspwm/bspwmrc" 2>/dev/null || true
chmod +x "$USER_HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$USER_HOME/.config/spectre/scripts/wallpaper.sh" 2>/dev/null || true

# Disable this service (run once)
systemctl disable spectre-firstboot.service 2>/dev/null || true
