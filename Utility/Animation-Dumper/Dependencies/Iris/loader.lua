-- Iris loader script. This script is responsible for loading all of the required modules for Iris and initializing it. It also caches the loaded modules and the initialized Iris in the global table, so that they can be accessed by other scripts if needed.

local genv = getgenv()

-- If Iris is already loaded, return it instead of loading it again.
if genv.Iris then
    return genv.Iris
end

if not genv.BetterLib then
    local OldGet = game.HttpGet or game.HttpGetAsync or nil
    assert(OldGet, "No HttpGet function found.")
    -- Load BetterLib first (if it's not already loaded), since every other loaded stuff will depend on it. If BetterLib fails to load, everything else won't work, but at least the error will be more informative.
    loadstring(OldGet(game, "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/Dependencies/BetterLib.lua", true))()
end
-- Begin Script:

IrisMainURL = "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/Dependencies/Iris/"
MustBeLoadedManually = {
    -- Because of dependencies, they must be loaded in a specific order,
    -- so we load them manually instead of in the loop with the other modules.
    "init";
    "Signal";
    "UserInputService";
}
IrisURLs = {
    -- lib
    API = IrisMainURL .. "lib/API.lua";
    Internal = IrisMainURL .. "lib/Internal.lua";
    config = IrisMainURL .. "lib/config.lua";
    demoWindow = IrisMainURL .. "lib/demoWindow.lua";
    init = IrisMainURL .. "lib/init.lua";

    -- src/libraries
    Signal = IrisMainURL .. "src/libraries/UserInputService/Signal.lua";
    UserInputService = IrisMainURL .. "src/libraries/UserInputService/init.lua";

    -- widgets
    widgets = IrisMainURL .. "lib/widgets/init.lua";
    Button = IrisMainURL .. "lib/widgets/Button.lua";
    Checkbox = IrisMainURL .. "lib/widgets/Checkbox.lua";
    Combo = IrisMainURL .. "lib/widgets/Combo.lua";
    Format = IrisMainURL .. "lib/widgets/Format.lua";
    Image = IrisMainURL .. "lib/widgets/Image.lua";
    Input = IrisMainURL .. "lib/widgets/Input.lua";
    Menu = IrisMainURL .. "lib/widgets/Menu.lua";
    Plot = IrisMainURL .. "lib/widgets/Plot.lua";
    RadioButton = IrisMainURL .. "lib/widgets/RadioButton.lua";
    Root = IrisMainURL .. "lib/widgets/Root.lua";
    Tab = IrisMainURL .. "lib/widgets/Tab.lua";
    Table = IrisMainURL .. "lib/widgets/Table.lua";
    Text = IrisMainURL .. "lib/widgets/Text.lua";
    Tree = IrisMainURL .. "lib/widgets/Tree.lua";
    Window = IrisMainURL .. "lib/widgets/Window.lua";
}

-- Load and cache all of the required modules before initializing Iris
-- instead of loading them on demand, since the on-demand loading would
-- cause a lot of redundant HTTP requests and would be very slow.

-- Also, the normal version of Iris requires the scripts based on Roblox heirarchy.
-- This looks like "require(script.Types)"
-- "script" referring to what would be the current script in a normal Roblox setup.
-- However we aren't going to use the "script" variable at all since we are using
-- loadstring and get requests instead of normal module scripts, so there is no
-- real way to replicate this heirarchy. We could try to fake it by creating a
-- table that represents the heirarchy and then using that table as the environment
-- for the modules, but that would be more trouble than it's worth and would still be pretty hacky.
-- So instead, we'll just load all of the modules using Get and
-- cache them in genv.IrisModules, and then instead of using require
-- calls, we will just look up the modules in that table.

IrisModules = {}
genv.IrisModules = IrisModules

IrisModules.Signal = loadstring(Get(IrisURLs.Signal))()
genv.IrisModules = IrisModules

IrisModules.UserInputService = loadstring(Get(IrisURLs.UserInputService))()
genv.IrisModules = IrisModules

for moduleName, url in pairs(IrisURLs) do
    if not table.find(MustBeLoadedManually, moduleName) then
        IrisModules[moduleName] = loadstring(Get(url))()
    end
end

genv.IrisModules = IrisModules

-- Finally initialize Iris and cache it in genv.Iris,
-- so that it can be accessed by other scripts if needed.

Iris = loadstring(Get(IrisURLs.init))().Init()
genv.Iris = Iris
return Iris
