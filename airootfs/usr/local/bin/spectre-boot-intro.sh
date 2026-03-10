#!/usr/bin/env bash
# Spectre OS - Boot intro: earth.mp4 fullscreen → THE WORLD IS YOURS (red) + boot sound
# Runs before SDDM. Place earth.mp4 and Spectre_OS_boot_sound_1.mp3 in /usr/share/spectre/
# Fallback: ASCII art + sox choir if custom files missing

EARTH="/usr/share/spectre/earth.mp4"
SOUND="/usr/share/spectre/Spectre_OS_boot_sound_1.mp3"
TWIY_IMG="/tmp/spectre-twiy.png"

chvt 1 2>/dev/null

if [[ -f "$EARTH" ]] && command -v mpv &>/dev/null; then
    # 1. Play earth.mp4 fullscreen (timeout 5min in case of corruption)
    timeout 300 mpv --vo=drm --no-input -fs --no-osc --no-osd-bar "$EARTH" 2>/dev/null || true
fi

if command -v convert &>/dev/null; then
    # 2. Generate "THE WORLD IS YOURS" red image
    convert -size 1920x1080 xc:black -fill '#ff0000' -font DejaVu-Sans-Bold \
        -pointsize 120 -gravity center -annotate 0 'THE WORLD\nIS YOURS' "$TWIY_IMG" 2>/dev/null
fi

if [[ -f "$TWIY_IMG" ]] && command -v mpv &>/dev/null; then
    # 3. Display text fullscreen + play boot sound
    if [[ -f "$SOUND" ]]; then
        mpv --no-video --no-input "$SOUND" 2>/dev/null &
        SND_PID=$!
    fi
    mpv --vo=drm --no-input -fs --no-osc --no-osd-bar --length=5 "$TWIY_IMG" 2>/dev/null
    [[ -n "$SND_PID" ]] && wait "$SND_PID" 2>/dev/null
    rm -f "$TWIY_IMG"
else
    # Fallback: ASCII + sox choir
    export TERM=linux
    ASCII=$(cat << 'ART'

    ███████╗██████╗ ███████╗ ██████╗████████╗██████╗ ███████╗
    ██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝
    ███████╗██████╔╝█████╗  ██║        ██║   ██████╔╝███████╗
    ╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██╔══██╗╚════██║
    ███████║██║     ███████╗╚██████╗   ██║   ██║  ██║███████║
    ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝

                         W R A I T H  //  O P S E C  R E A D Y

ART
)
    clear
    echo -ne "\033[0;36m"
    printf '%s\n' "$ASCII"
    echo -ne "\033[0m"
    if command -v play &>/dev/null; then
        play -q -n synth 2.5 sine 220 sine 277 sine 330 fade 0.15 0.8 2>/dev/null &
    fi
    sleep 2
fi

exit 0
