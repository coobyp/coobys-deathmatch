#!/usr/bin/env bash
# Installs a Half-Life Dedicated Server (HLDS) with Cooby's Deathmatch on Linux.
# Usage: ./install_hlds.sh [path/to/coobydm-package-dir]
# Works on Debian/Ubuntu/Raspberry Pi OS (x86 only: HLDS is 32-bit x86, a Pi can't run it natively).
set -euo pipefail

HLDS_DIR="${HLDS_DIR:-$HOME/hlds}"
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
PKG_DIR="${1:-}"

if command -v apt-get >/dev/null; then
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y lib32gcc-s1 lib32stdc++6 libc6-i386 curl tar
fi

mkdir -p "$STEAMCMD_DIR" "$HLDS_DIR"
if [ ! -x "$STEAMCMD_DIR/steamcmd.sh" ]; then
	curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C "$STEAMCMD_DIR"
fi

# App 90 is famous for needing a few passes before it fully downloads.
for i in 1 2 3; do
	"$STEAMCMD_DIR/steamcmd.sh" +force_install_dir "$HLDS_DIR" +login anonymous \
		+app_set_config 90 mod valve +app_update 90 validate +quit && break || true
done

# HLDS looks for steamclient.so here
mkdir -p "$HOME/.steam/sdk32"
ln -sf "$STEAMCMD_DIR/linux32/steamclient.so" "$HOME/.steam/sdk32/steamclient.so"

if [ -n "$PKG_DIR" ]; then
	cp -r "$PKG_DIR/coobydm" "$HLDS_DIR/"
	echo "Installed coobydm into $HLDS_DIR"
else
	echo "HLDS installed. Copy the coobydm folder into $HLDS_DIR, then run ./run_server.sh"
fi
