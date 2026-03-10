#!/usr/bin/env bash
# Spectre OS - Boot intro: earth.mp4 → THE WORLD IS YOURS (red) + boot sound
# Runs before SDDM. Place earth.mp4 and Spectre_OS_boot_sound_1.mp3 in /usr/share/spectre/
# Falls back to console display when mpv/DRM unavailable (e.g. VM)

EARTH="/usr/share/spectre/earth.mp4"
SOUND="/usr/share/spectre/Spectre_OS_boot_sound_1.mp3"
TWIY_IMG="/tmp/spectre-twiy.png"

chvt 1 2>/dev/null
export TERM=linux

# Helper: show THE WORLD IS YOURS in red on console + play sound
show_twiy_console() {
    clear
    echo ""
    echo ""
    echo -ne "\033[0;31m"
    echo "    ████████╗██╗  ██╗███████╗     ██╗    ██╗ ██████╗ ██████╗ ██╗     ██████╗ "
    echo "    ╚══██╔══╝██║  ██║██╔════╝     ██║    ██║██╔═══██╗██╔══██╗██║     ██╔══██╗"
    echo "       ██║   ███████║█████╗       ██║ █╗ ██║██║   ██║██████╔╝██║     ██║  ██║"
    echo "       ██║   ██╔══██║██╔══╝       ██║███╗██║██║   ██║██╔══██╗██║     ██║  ██║"
    echo "       ██║   ██║  ██║███████╗     ╚███╔███╔╝╚██████╔╝██║  ██║███████╗██████╔╝"
    echo "       ╚═╝   ╚═╝  ╚═╝╚══════╝      ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ "
    echo ""
    echo "       ██╗███████╗    ██╗   ██╗ ██████╗ ██╗   ██╗██████╗ ███████╗"
    echo "       ██║██╔════╝    ╚██╗ ██╔╝██╔═══██╗██║   ██║██╔══██╗██╔════╝"
    echo "       ██║███████╗     ╚████╔╝ ██║   ██║██║   ██║██████╔╝███████╗"
    echo "       ██║╚════██║      ╚██╔╝  ██║   ██║██║   ██║██╔══██╗╚════██║"
    echo "       ██║███████║       ██║   ╚██████╔╝╚██████╔╝██║  ██║███████║"
    echo "       ╚═╝╚══════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo ""
    echo -ne "\033[0m"
}

# Play sound (mp3 or fallback sox)
play_sound() {
    if [[ -f "$SOUND" ]] && command -v mpv &>/dev/null; then
        mpv --no-video --no-input --really-quiet "$SOUND" 2>/dev/null &
        return
    fi
    if command -v play &>/dev/null; then
        play -q -n synth 3 sine 220 sine 277 sine 330 fade 0.2 0.8 2>/dev/null &
    fi
}

# Quick DRM test (1 frame) - fails in VMs
DRM_WORKS=0
if [[ -f "$EARTH" ]] && command -v mpv &>/dev/null; then
    timeout 3 mpv --vo=drm --no-input -fs --frames=1 -ao=null "$EARTH" 2>/dev/null && DRM_WORKS=1 || true
fi

if [[ "$DRM_WORKS" -eq 1 ]]; then
    # DRM works - play full video then TWIY
    [[ -f "$EARTH" ]] && timeout 300 mpv --vo=drm --no-input -fs --no-osc --no-osd-bar "$EARTH" 2>/dev/null || true
    if command -v convert &>/dev/null; then
        convert -size 1920x1080 xc:black -fill '#ff0000' -font DejaVu-Sans-Bold \
            -pointsize 120 -gravity center -annotate 0 'THE WORLD\nIS YOURS' "$TWIY_IMG" 2>/dev/null
    fi
    if [[ -f "$TWIY_IMG" ]]; then
        play_sound
        mpv --vo=drm --no-input -fs --no-osc --no-osd-bar --length=6 "$TWIY_IMG" 2>/dev/null || true
        rm -f "$TWIY_IMG"
    fi
else
    # Fallback: console display (works in VM, no DRM)
    play_sound
    show_twiy_console
    sleep 5
fi

exit 0
