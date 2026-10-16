#!/usr/bin/env bash
# Starts Cooby's Deathmatch. Override with env vars, e.g. MAP=bounce MAXPLAYERS=12 ./run_server.sh
set -euo pipefail
HLDS_DIR="${HLDS_DIR:-$HOME/hlds}"
MAP="${MAP:-crossfire}"
MAXPLAYERS="${MAXPLAYERS:-16}"
PORT="${PORT:-27015}"

cd "$HLDS_DIR"
exec ./hlds_run -game coobydm +ip 0.0.0.0 -port "$PORT" +maxplayers "$MAXPLAYERS" +map "$MAP" \
	+sv_lan 0 -pingboost 2 -autoupdate
