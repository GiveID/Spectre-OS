#!/usr/bin/env bash
# Spectre OS - archiso customize_airootfs.sh
# Runs during ISO build in chroot
# NOTE: customize_airootfs.sh is deprecated in archiso; consider migrating to systemd oneshot.

set +e

# Releng provides arch user via passwd; mkarchiso copies skel to home
# Ensure arch exists for live session
id arch &>/dev/null || (useradd -m -G wheel -s /usr/bin/zsh arch && echo "arch:arch" | chpasswd -c SHA512)

# Ensure arch home has our configs - copy skel explicitly (mkarchiso order can vary)
mkdir -p /home/arch/.config
cp -r /etc/skel/.config/bspwm /etc/skel/.config/sxhkd /etc/skel/.config/polybar /etc/skel/.config/picom /etc/skel/.config/rofi /etc/skel/.config/alacritty /etc/skel/.config/dunst /etc/skel/.config/spectre /etc/skel/.config/nvim /home/arch/.config/ 2>/dev/null || true
cp /etc/skel/.xinitrc /etc/skel/.xprofile /etc/skel/.zshrc /home/arch/ 2>/dev/null || true
cp /etc/skel/.config/starship.toml /home/arch/.config/ 2>/dev/null || true
chown -R arch:arch /home/arch

# Spectre config dirs
mkdir -p /etc/spectre /var/log/spectre
[ -d /etc/spectre ] && chmod 755 /etc/spectre
[ -d /var/log/spectre ] && chmod 755 /var/log/spectre

# Make scripts executable (guard: mkdir -p parent, [ -f ] before chmod)
chmod +x /usr/local/bin/spectre-harden.sh /usr/local/bin/spectre-init.sh 2>/dev/null || true
chmod +x /usr/local/bin/anon /usr/local/bin/opsec /usr/local/bin/recon /usr/local/bin/exfil 2>/dev/null || true
chmod +x /usr/local/bin/spectre-tools-install /usr/local/bin/spectre-wallpaper /usr/local/bin/spectre-vpn-status 2>/dev/null || true
[ -f /etc/spectre/motd.sh ] && chmod +x /etc/spectre/motd.sh
mkdir -p /home/arch/.config/bspwm /home/arch/.config/polybar/scripts /home/arch/.config/spectre/scripts
[ -f /home/arch/.config/bspwm/bspwmrc ] && chmod +x /home/arch/.config/bspwm/bspwmrc
[ -f /home/arch/.config/polybar/launch.sh ] && chmod +x /home/arch/.config/polybar/launch.sh
[ -f /home/arch/.config/polybar/scripts/vpn-status.sh ] && chmod +x /home/arch/.config/polybar/scripts/vpn-status.sh
[ -f /home/arch/.config/spectre/scripts/wallpaper.sh ] && chmod +x /home/arch/.config/spectre/scripts/wallpaper.sh

# Python deps for wallpaper and tools
pip install --break-system-packages numpy matplotlib 2>/dev/null || \
pip install numpy matplotlib 2>/dev/null || true
pip install --break-system-packages impacket pwntools cryptography 2>/dev/null || \
pip install impacket pwntools cryptography 2>/dev/null || true

# os-release for Spectre
cat > /etc/os-release << 'EOF'
NAME="Spectre OS"
PRETTY_NAME="Spectre OS (Wraith)"
ID=spectre
ID_LIKE=arch
BUILD_ID=wraith
ANSI_COLOR="0;36"
HOME_URL="https://github.com/spectre-os"
DOCUMENTATION_URL="https://github.com/spectre-os"
EOF

# Boot splash - minimal (Plymouth text theme if available)
# Archiso uses kernel console - we set quiet in boot params
# Custom plymouth would need initramfs changes; document in README

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 2>/dev/null || true
locale-gen 2>/dev/null || true

# Timezone UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime 2>/dev/null || true

# Disable reflector timer in live (we use our own)
systemctl disable reflector.timer 2>/dev/null || true

# Enable LightDM (graphical login - no startx needed)
systemctl enable lightdm.service
systemctl set-default graphical.target 2>/dev/null || true

# Enable first-boot setup
systemctl enable spectre-firstboot.service

# Make session script executable
chmod +x /usr/local/bin/spectre-session /usr/local/bin/spectre-firstboot.sh
