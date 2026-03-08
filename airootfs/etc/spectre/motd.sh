#!/usr/bin/env bash
# Spectre OS MOTD - hostname, uptime, last login, threat indicator
# Called from /etc/profile.d/spectre-motd.sh

ports=$(ss -tuln 2>/dev/null | grep -c LISTEN || echo 0)
if [[ "$ports" -gt 10 ]]; then
    level="HIGH"
elif [[ "$ports" -gt 5 ]]; then
    level="MED"
else
    level="LOW"
fi

echo ""
echo "Spectre OS - Wraith"
echo "hostname: $(hostname) | uptime: $(uptime -p 2>/dev/null || uptime)"
echo "last: $(last -1 -n 1 2>/dev/null | head -1 || echo 'N/A')"
echo "threat: $level ($ports listening ports)"
echo ""
