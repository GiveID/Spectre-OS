#!/usr/bin/env bash
# Spectre OS first-boot initialization
# Walks user through hostname, timezone, locale, Tor mode, OPSEC briefing

set -euo pipefail

CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BOX_CHAR="${CYAN}|${NC}"
API_DNSLEAK="https://www.dnsleaktest.com/api/v1/test"

prompt() {
    local msg="$1"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        read -rp "$(echo -e "${CYAN}[?] $msg [$default]: ${NC}")" ans
        echo "${ans:-$default}"
    else
        read -rp "$(echo -e "${CYAN}[?] $msg: ${NC}")" ans
        echo "$ans"
    fi
}

log() { echo -e "${CYAN}[*]${NC} $*"; }
ok() { echo -e "${GREEN}[+]${NC} $*"; }

echo ""
echo -e "${CYAN}=== Spectre OS First Boot ===${NC}"
echo ""

# 1. Hostname randomization
log "Hostname"
current=$(hostname 2>/dev/null || echo "spectre")
new_host=$(prompt "Enter hostname" "$(echo "spectre-$(openssl rand -hex 4)")")
echo "$new_host" > /etc/hostname
hostnamectl set-hostname "$new_host" 2>/dev/null || true
sed -i "s/127.0.1.1.*/127.0.1.1\t$new_host/" /etc/hosts 2>/dev/null || true
ok "Hostname set to $new_host"

# 2. Timezone UTC
log "Setting timezone to UTC..."
timedatectl set-timezone UTC 2>/dev/null || ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ok "Timezone: UTC"

# 3. Locale en_US.UTF-8
log "Setting locale..."
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen 2>/dev/null || true
locale-gen 2>/dev/null || true
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8
ok "Locale: en_US.UTF-8"

# 4. Machine ID
log "Generating new machine ID..."
rm -f /etc/machine-id
systemd-machine-id-setup 2>/dev/null || echo "$(head -c 16 /dev/urandom | xxd -p -u)" > /etc/machine-id
ok "Machine ID randomized"

# 5. Tor-only mode
tor_mode=$(prompt "Set up Tor-only mode? Routes all traffic through Tor (y/N)" "n")
if [[ "${tor_mode,,}" == "y" || "${tor_mode,,}" == "yes" ]]; then
    log "Tor-only: Add iptables rules to route all traffic via Tor. Manual step - see README."
fi

# 6. OPSEC briefing
echo ""
echo -e "${CYAN}+------------------------------------------------------------------+${NC}"
echo -e "${CYAN}|                    SPECTRE OS - OPSEC BRIEFING                    |${NC}"
echo -e "${CYAN}+------------------------------------------------------------------+${NC}"
echo ""

# Current IP (curl over Tor if available)
ip_info="(check manually)"
if command -v curl &>/dev/null; then
    if systemctl is-active --quiet tor 2>/dev/null; then
        ip_info=$(curl -s --max-time 10 --socks5-hostname 127.0.0.1:9050 https://ifconfig.me 2>/dev/null || echo "Tor: timeout")
    else
        ip_info=$(curl -s --max-time 10 https://ifconfig.me 2>/dev/null || echo "Direct: timeout")
    fi
fi
echo -e "${BOX_CHAR} Current IP: ${ip_info}"

# DNS leak (simplified - real API requires key)
echo -e "${BOX_CHAR} DNS: Run 'curl https://dnsleaktest.com' to verify"

# Listening ports
echo -e "${BOX_CHAR} Listening ports:"
ss -tuln 2>/dev/null | head -15 | sed "s/^/  /"

# Kernel
echo -e "${BOX_CHAR} Kernel: $(uname -r)"

# AppArmor
aa_status=$(aa-status 2>/dev/null | head -1 || echo "not running")
echo -e "${BOX_CHAR} AppArmor: $aa_status"

# Last login
echo -e "${BOX_CHAR} Last login: $(last -1 2>/dev/null | head -1 || echo 'N/A')"

echo -e "${CYAN}+------------------------------------------------------------------+${NC}"
echo ""
ok "First boot setup complete. Run 'spectre-harden' for full hardening."
