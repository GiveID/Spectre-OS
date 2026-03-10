#!/usr/bin/env bash
# shellcheck disable=SC2034
# Spectre OS - Wraith - Arch-based red-team/OSINT workstation

iso_name="spectre-os"
iso_label="SPECTRE_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Spectre OS <https://github.com/spectre-os>"
iso_application="Spectre OS Live/Rescue - Red Team Workstation"
iso_version="1.0.0"
install_dir="spectre"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/arch"]="0:0:440"
  ["/root"]="0:0:750"
  ["/etc/spectre"]="0:0:755"
  ["/usr/local/bin/spectre-harden.sh"]="0:0:755"
  ["/usr/local/bin/spectre-init.sh"]="0:0:755"
  ["/usr/local/bin/anon"]="0:0:755"
  ["/usr/local/bin/opsec"]="0:0:755"
  ["/usr/local/bin/recon"]="0:0:755"
  ["/usr/local/bin/exfil"]="0:0:755"
  ["/usr/local/bin/spectre-vpn-status"]="0:0:755"
  ["/usr/local/bin/spectre-tools-install"]="0:0:755"
  ["/usr/local/bin/spectre-wallpaper"]="0:0:755"
  ["/usr/local/bin/spectre-session"]="0:0:755"
  ["/usr/local/bin/spectre-firstboot.sh"]="0:0:755"
  ["/usr/local/bin/spectre-boot-intro.sh"]="0:0:755"
  ["/usr/local/bin/spectre-power-menu"]="0:0:755"
  ["/etc/systemd/system/spectre-mac-randomize.service"]="0:0:644"
  ["/etc/systemd/system/spectre-firstboot.service"]="0:0:644"
  ["/etc/systemd/system/spectre-boot-intro.service"]="0:0:644"
)
