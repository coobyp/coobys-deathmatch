# Cooby's Deathmatch

Half-Life Deathmatch, but it's ours. Real GoldSrc engine, real Half-Life movement
(bhop, gauss jumps, crowbar diplomacy), built on the
[Half-Life Updated SDK](https://github.com/twhl-community/halflife-updated) so we can mod it however we want.

## What's in here

| Folder | What it is |
| --- | --- |
| `dlls/`, `cl_dll/`, `pm_shared/` ... | The game code (server `hl.dll/hl.so`, client `client.dll/client.so`). Deathmatch rules live in `dlls/multiplay_gamerules.cpp`, movement in `pm_shared/pm_shared.cpp`. |
| `mod/coobydm/` | The mod folder that goes next to `valve/`: `liblist.gam`, `server.cfg`, `mapcycle.txt`, `motd.txt`. |
| `server/` | Dedicated server (HLDS) install + run scripts and a systemd unit. |
| `bot/` | Discord bot: live player count in its status, an auto-updating scoreboard post, `/status` and `/join`. |
| `installer/` | One-click installers that drop `coobydm` into your Half-Life folder (Windows + Linux/Steam Deck). |

## Playing (for your Discord folks)

1. Own Half-Life on Steam and launch it once.
2. Grab the latest `coobys-deathmatch` zip from Releases (or the Actions tab) and extract it.
3. Windows: right-click `install.ps1` > Run with PowerShell. Linux/Deck: `./install.sh`.
4. Restart Steam, launch **Cooby's Deathmatch**, open the console and `connect <server ip:port>`
   (the bot's `/join` command prints the exact line).

## Building

GitHub Actions builds everything on every push: Linux (Steam Runtime, so it works on any distro)
and Windows (Visual Studio, Win32), then packages a ready-to-install `coobydm` folder.
Push a tag like `v0.1` to publish a Release zip.

Building locally:

- **Linux**: `sudo apt install g++-multilib libgl1-mesa-dev`, then `cd linux && make CFG=release COMPILER=g++ -j`.
  Output is in `linux/release/`.
- **Windows**: Visual Studio 2019 or newer with "Desktop development with C++".
  Open `projects/vs2019/projects.sln`, pick **Release / Win32**, build.
  Output: `projects/vs2019/Release/hldll/hl.dll` and `projects/vs2019/Release/hl_cdll/client.dll`.

Copy `hl.dll`/`hl.so` into `coobydm/dlls/` and `client.dll`/`client.so` into `coobydm/cl_dlls/`.

## Running the server

On a Linux box (x86, a VPS or an old PC; HLDS doesn't run on a Raspberry Pi's ARM chip):

```bash
./server/install_hlds.sh path/to/extracted/zip   # installs HLDS via steamcmd + copies coobydm in
./server/run_server.sh                            # MAP=bounce MAXPLAYERS=12 ./server/run_server.sh
```

Open UDP 27015 on your router/firewall. Set `rcon_password` in `~/hlds/coobydm/server.cfg`.

## Discord bot

1. Create an application at https://discord.com/developers/applications, add a Bot, copy its token.
2. Invite it with the `bot` and `applications.commands` scopes.
3. `cd bot && pip install -r requirements.txt && cp .env.example .env`, fill in the token and server address.
4. `python bot.py`

Discord won't make `steam://` links clickable, so the bot shows the `connect` line to copy instead.

## Roadmap ideas

- Custom weapons / tweaks (start in `dlls/`), custom maps in `coobydm/maps/`
- Game modes: instagib, gungame, crowbar-only (new `CGameRules` subclass picked in `dlls/gamerules.cpp`)
- Real installer `.exe`, auto-updater
