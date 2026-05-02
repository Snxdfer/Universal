local TryGet = game.HttpGet or game.HttpGetAsync or nil
assert(TryGet, "No Http GET function found. This script is unavailable for your lua environment.")
loadstring(TryGet(game, "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/main.lua", true))()
