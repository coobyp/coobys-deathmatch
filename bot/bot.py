"""Cooby's Deathmatch Discord bot.

Shows live server status in the bot's presence, keeps one auto-updating status
message in a channel, and answers /status and /join.

Config (env vars or a .env file next to this script):
  DISCORD_TOKEN       bot token from the Discord developer portal
  SERVER_ADDRESS      public ip:port of the HLDS, e.g. 203.0.113.5:27015
  STATUS_CHANNEL_ID   optional: channel id for the auto-updating status embed
  POLL_SECONDS        optional: how often to query the server (default 30)
"""

import asyncio
import os
from pathlib import Path

import a2s
import discord
from discord import app_commands
from discord.ext import tasks


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip().strip('"'))


load_dotenv(Path(__file__).with_name(".env"))

TOKEN = os.environ["DISCORD_TOKEN"]
HOST, _, PORT = os.environ["SERVER_ADDRESS"].partition(":")
ADDRESS = (HOST, int(PORT or 27015))
STATUS_CHANNEL_ID = int(os.environ.get("STATUS_CHANNEL_ID", "0") or 0)
POLL_SECONDS = int(os.environ.get("POLL_SECONDS", "30"))
CONNECT = f"{ADDRESS[0]}:{ADDRESS[1]}"


async def query():
    """Returns (info, players) or (None, []) if the server is down."""
    try:
        info = await a2s.ainfo(ADDRESS, timeout=3)
        try:
            players = await a2s.aplayers(ADDRESS, timeout=3)
        except Exception:
            players = []
        return info, players
    except Exception:
        return None, []


def status_embed(info, players) -> discord.Embed:
    if info is None:
        return discord.Embed(
            title="Cooby's Deathmatch",
            description="Server is offline. Somebody kicked the power cord again.",
            color=discord.Color.dark_grey(),
        )
    embed = discord.Embed(
        title=info.server_name,
        description=f"**{info.player_count}/{info.max_players}** fragging on **{info.map_name}**",
        color=discord.Color.orange(),
    )
    named = sorted((p for p in players if p.name), key=lambda p: p.score, reverse=True)
    if named:
        board = "\n".join(f"`{p.score:>3}` {discord.utils.escape_markdown(p.name)}" for p in named[:16])
        embed.add_field(name="Scoreboard", value=board, inline=False)
    embed.add_field(name="Join", value=f"In the Half-Life console: `connect {CONNECT}`", inline=False)
    embed.add_field(name="Or paste in your browser", value=f"`steam://connect/{CONNECT}`", inline=False)
    embed.set_footer(text="Needs Half-Life on Steam + the coobydm mod installed")
    return embed


class DeathmatchBot(discord.Client):
    def __init__(self):
        super().__init__(intents=discord.Intents.default())
        self.tree = app_commands.CommandTree(self)
        self.status_message: discord.Message | None = None

    async def setup_hook(self):
        await self.tree.sync()
        self.poll.start()

    @tasks.loop(seconds=POLL_SECONDS)
    async def poll(self):
        info, players = await query()
        if info is None:
            activity = discord.Game("server offline")
        else:
            activity = discord.Game(f"{info.player_count}/{info.max_players} on {info.map_name}")
        await self.change_presence(activity=activity)

        if STATUS_CHANNEL_ID:
            await self.update_status_message(status_embed(info, players))

    @poll.before_loop
    async def before_poll(self):
        await self.wait_until_ready()

    async def update_status_message(self, embed: discord.Embed):
        channel = self.get_channel(STATUS_CHANNEL_ID)
        if channel is None:
            return
        if self.status_message is None:
            # reuse our last message in the channel so restarts don't spam
            async for message in channel.history(limit=20):
                if message.author == self.user:
                    self.status_message = message
                    break
        if self.status_message is None:
            self.status_message = await channel.send(embed=embed)
        else:
            try:
                await self.status_message.edit(embed=embed)
            except discord.NotFound:
                self.status_message = await channel.send(embed=embed)


bot = DeathmatchBot()


@bot.tree.command(name="status", description="Who's fragging on Cooby's Deathmatch right now")
async def status(interaction: discord.Interaction):
    info, players = await query()
    await interaction.response.send_message(embed=status_embed(info, players))


@bot.tree.command(name="join", description="How to join the server")
async def join(interaction: discord.Interaction):
    await interaction.response.send_message(
        f"Open Half-Life, pick **Cooby's Deathmatch** from Custom Game, then in the console type:\n"
        f"`connect {CONNECT}`\n"
        f"Or paste `steam://connect/{CONNECT}` into your browser's address bar.",
        ephemeral=True,
    )


if __name__ == "__main__":
    asyncio.run(bot.start(TOKEN))
