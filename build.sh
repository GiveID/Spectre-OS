#!/usr/bin/env bash
# Spectre OS ISO Build Script
# Run on Arch Linux: ./build.sh
# Requires: archiso package installed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"
WORK_DIR="/tmp/spectre-archiso-work"
RELENG_SOURCE="/usr/share/archiso/configs/releng"
ARCHLIVE="${SCRIPT_DIR}/archlive"

if [[ ! -d "${RELENG_SOURCE}" ]]; then
    echo "Error: archiso not installed or releng profile not found."
    echo "Install with: sudo pacman -S archiso"
    exit 1
fi

echo "[*] Preparing Spectre OS build..."

# Create fresh archlive from releng
rm -rf "${ARCHLIVE}"
mkdir -p "${ARCHLIVE}"
cp -r "${RELENG_SOURCE}"/* "${ARCHLIVE}/"

# Overlay Spectre customizations
echo "[*] Overlaying Spectre OS customizations..."
cp "${SCRIPT_DIR}/profiledef.sh" "${ARCHLIVE}/"
# Merge packages: releng base + Spectre additions (our file has full list)
cp "${SCRIPT_DIR}/packages.x86_64" "${ARCHLIVE}/"

# Copy airootfs customizations
if [[ -d "${SCRIPT_DIR}/airootfs" ]]; then
    mkdir -p "${ARCHLIVE}/airootfs"
    cp -a "${SCRIPT_DIR}/airootfs"/. "${ARCHLIVE}/airootfs/"
fi

# Update boot configs for Spectre branding
for f in "${ARCHLIVE}"/grub/*.cfg "${ARCHLIVE}"/syslinux/*.cfg "${ARCHLIVE}"/efiboot/loader/entries/*.conf; do
    [[ -f "$f" ]] && sed -i 's/Arch Linux/Spectre OS/g; s/archlinux/spectre/g' "$f"
done

# Verify syslinux is in package list (mkarchiso requirement for BIOS boot)
if ! grep -q '^syslinux$' "${ARCHLIVE}/packages.x86_64" 2>/dev/null; then
    echo "ERROR: syslinux is missing from packages.x86_64"
    echo "First 25 lines of ${ARCHLIVE}/packages.x86_64:"
    head -25 "${ARCHLIVE}/packages.x86_64" | cat -A
    exit 1
fi

# Build
echo "[*] Building ISO (this may take 15-30 minutes)..."
mkdir -p "${OUTPUT_DIR}"
mkarchiso -v -r -w "${WORK_DIR}" -o "${OUTPUT_DIR}" "${ARCHLIVE}"

echo ""
echo "[+] Build complete. ISO location:"
ls -la "${OUTPUT_DIR}"/*.iso 2>/dev/null || ls -la "${OUTPUT_DIR}"
echo ""
echo "Write to USB: sudo dd if=${OUTPUT_DIR}/spectre-os-*.iso of=/dev/sdX bs=4M status=progress"
