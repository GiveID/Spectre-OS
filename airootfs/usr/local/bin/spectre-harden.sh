#!/usr/bin/env bash
# Spectre OS hardening script - runs at install or manually
# Executes OPSEC hardening measures for red-team/OSINT workstations

set -euo pipefail

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${CYAN}[*]${NC} $*"; }
ok() { echo -e "${GREEN}[+]${NC} $*"; }
err() { echo -e "${RED}[!]${NC} $*"; }

[[ $EUID -eq 0 ]] || { err "Run as root."; exit 1; }

log "Spectre OS hardening - starting"

# 1. Disable IPv6 (identity leaks through VPN)
log "Disabling IPv6..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1 2>/dev/null || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 2>/dev/null || true
grep -q 'net.ipv6.conf.all.disable_ipv6' /etc/sysctl.d/99-spectre.conf 2>/dev/null || \
    echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/99-spectre.conf

# 2. UFW - default deny inbound
log "Configuring UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow out 53/udp
ufw allow out 53/tcp
ufw allow out 80/tcp
ufw allow out 443/tcp
ufw allow out 9050/tcp
ufw allow out 9150/tcp
ufw --force enable 2>/dev/null || true

# 3. dnscrypt-proxy
log "Configuring dnscrypt-proxy..."
if command -v dnscrypt-proxy &>/dev/null; then
    mkdir -p /etc/dnscrypt-proxy
    if [[ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        dnscrypt-proxy -generate -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null || true
    fi
    systemctl enable dnscrypt-proxy 2>/dev/null || true
fi

# 4. MAC address randomization at boot (systemd service)
log "Setting up MAC randomization service..."
cat > /etc/systemd/system/spectre-mac-randomize.service << 'UNIT'
[Unit]
Description=Spectre OS - MAC address randomization
After=network-pre.target
Before=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'for iface in /sys/class/net/*/; do i=$(basename "$iface"); [[ "$i" == lo ]] && continue; macchanger -r "$i" 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT
systemctl enable spectre-mac-randomize.service 2>/dev/null || true

# 5. Kernel hardening sysctl
log "Applying kernel hardening..."
cat > /etc/sysctl.d/99-spectre.conf << 'SYSCTL'
# Spectre OS kernel hardening
net.ipv4.tcp_timestamps = 0
kernel.randomize_va_space = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
SYSCTL
sysctl -p /etc/sysctl.d/99-spectre.conf 2>/dev/null || true

# 6. AppArmor
log "Enabling AppArmor..."
systemctl enable apparmor 2>/dev/null || true
[[ -d /etc/apparmor.d ]] || mkdir -p /etc/apparmor.d
# Placeholder profiles - user can add firefox, evince, chromium via aa-enforce
touch /etc/apparmor.d/local/usr.bin.firefox 2>/dev/null || mkdir -p /etc/apparmor.d/local

# 7. auditd
log "Configuring auditd..."
mkdir -p /var/log/spectre
audit_log="/var/log/spectre/audit.log"
cat > /etc/audit/rules.d/spectre.rules << AUDIT
-w /usr/bin/sudo -p x -k privilege_escalation
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p r -k shadow_read
-w /etc/sudoers -p wa -k sudoers_changes
-w /usr/bin/su -p x -k privilege_escalation
-w /usr/bin/passwd -p x -k passwd_changes
AUDIT
sed -i "s|^log_file =.*|log_file = ${audit_log}|" /etc/audit/auditd.conf 2>/dev/null || true
sed -i 's|^log_format =.*|log_format = RAW|' /etc/audit/auditd.conf 2>/dev/null || true
systemctl enable auditd 2>/dev/null || true

# 8. Disable telemetry (generic - VS Code if present)
log "Disabling telemetry..."
for f in /usr/share/code/resources/app/product.json /opt/visual-studio-code/resources/app/product.json; do
    [[ -f "$f" ]] && sed -i 's/"enableTelemetry": true/"enableTelemetry": false/g' "$f" 2>/dev/null || true
done

# 9. LUKS /home prompt
log "LUKS /home: Run 'cryptsetup luksFormat' and 'cryptsetup open' on your /home partition, then format and mount. See README."

# 10. GPG keypair - prompt user
log "GPG: Run 'gpg --full-generate-key' to create a 4096-bit RSA keypair. Use Kleopatra for management."

ok "Hardening complete. Reboot recommended. Run spectre-init for first-boot setup."
