Spectre OS - Custom boot assets
================================

Place these files in this directory (before building) for the full boot intro:

  earth.mp4                    - Video played fullscreen at boot
  Spectre_OS_boot_sound_1.mp3  - Sound played with "THE WORLD IS YOURS" screen

If missing, the boot falls back to ASCII art + synthesized sound.

Add to your project before ./build.sh:
  cp earth.mp4 airootfs/usr/share/spectre/
  cp Spectre_OS_boot_sound_1.mp3 airootfs/usr/share/spectre/
