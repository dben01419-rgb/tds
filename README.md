# Strategies X TDS

Strategies X is a TDS strategy runner with compatibility support for the common short-form strategy API.

## Load the library

```lua
getgenv().Gatlify = false

local TDS = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dben01419-rgb/tds/main/TDS/MainSource.lua",
    true
))()
```

## Supported strategy format

The compatibility API supports `Loadout`, `Mode`, `GameInfo`, `Place`, `Upgrade`, `Ability`, `SetOption`, `VoteSkip`, `Ready`, `UnlockTimeScale`, and `TimeScale`.

Untimed short-form actions are executed in source order. This prevents upgrades and options from racing ahead of their placement:

```lua
TDS:Loadout("Farm", "Hacker", "DJ Booth", "Mercenary Base", "Cowboy")
TDS:Mode("Fallen")
TDS:GameInfo("Simplicity", {HiddenEnemies = true})
TDS:Ready()

TDS:Place("Farm", 10, 1, 10)
TDS:Upgrade(1)
TDS:SetOption(1, "Track", "Green")
```

Wave-header scripts using `-- [ Wave N ] --` are transformed by the `DevTest` loader. Direct `MainSource.lua` consumers should use explicit timing arguments when wave timing matters.

## Optional Gatlify

Enable it before loading the library:

```lua
getgenv().Gatlify = true
```

The UI also exposes an `Enable Gatlify` toggle. It loads:

```text
https://raw.githubusercontent.com/avtryxz/Gatlify/refs/heads/main/Gatlify.lua
```

The option is disabled by default.

## Troubleshooting

If the console reports `Wave 0` for every short-form action, update the library URL above and restart the executor. The ordered compatibility queue is included in the current `main` branch.
