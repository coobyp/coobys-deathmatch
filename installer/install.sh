#!/usr/bin/env bash
# Cooby's Deathmatch installer for Linux / Steam Deck. Run from inside the extracted archive.
set -euo pipefail
HL="${1:-$HOME/.local/share/Steam/steamapps/common/Half-Life}"
[ -d "$HL/valve" ] || HL="$HOME/.steam/steam/steamapps/common/Half-Life"
[ -d "$HL/valve" ] || { echo "Half-Life not found. Pass its folder: ./install.sh /path/to/Half-Life"; exit 1; }
cp -r "$(dirname "$0")/coobydm" "$HL/"
echo "Installed to $HL/coobydm. Restart Steam and look for Cooby's Deathmatch."
