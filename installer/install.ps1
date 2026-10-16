# Cooby's Deathmatch installer for Windows.
# Right-click > Run with PowerShell, from inside the extracted zip.
$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot 'coobydm'

function Find-HalfLife {
    $steam = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    if (-not $steam) { $steam = 'C:\Program Files (x86)\Steam' }
    $libraries = @($steam)
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
        Select-String -Path $vdf -Pattern '"path"\s+"([^"]+)"' | ForEach-Object {
            $libraries += $_.Matches[0].Groups[1].Value -replace '\\\\', '\'
        }
    }
    foreach ($lib in $libraries) {
        $hl = Join-Path $lib 'steamapps\common\Half-Life'
        if (Test-Path (Join-Path $hl 'valve')) { return $hl }
    }
    return $null
}

$hl = Find-HalfLife
if (-not $hl) {
    $hl = Read-Host "Couldn't find Half-Life. Paste your Half-Life folder path (the one containing 'valve')"
}
if (-not (Test-Path (Join-Path $hl 'valve'))) { throw "No valve folder in $hl. Is Half-Life installed?" }

Copy-Item -Recurse -Force $src $hl
Write-Host ""
Write-Host "Installed to $hl\coobydm" -ForegroundColor Green
Write-Host "Restart Steam. 'Cooby's Deathmatch' will show up in your library, or launch Half-Life > Change Game."
Read-Host "Press Enter to close"
