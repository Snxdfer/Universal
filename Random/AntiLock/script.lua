-- // Sky Antilock Keybind: C \\--
-- // Underground Keybind: X \\--
-- // Prediction Breaker Keybind: Z \\--

-- UI Modules
local UI_Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local UI_Client = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

-- global config
getgenv().AntiLockSettings = {
    Mode = 1, --// 1 = Underground, 2 = Sky, 3 = Prediction Breaker \\--
    Notifications = true, --// Sends Notifications When The Anti-Lock Is Executed \\--
    CeleryExecutor = false, --// put true if u have shit executor (Optimized for weak executors)
    SolaraExecutor = false, --// Same as Celery but better i guess
}

-- Local Settings
local selectedMode = getgenv().AntiLockSettings.Mode
local notificationsEnabled = getgenv().AntiLockSettings.Notifications
local usingCelery = getgenv().AntiLockSettings.CeleryExecutor
local usingSolara = getgenv().AntiLockSettings.SolaraExecutor

-- Disable notifications on weak executors
if usingCelery or usingSolara then
    notificationsEnabled = false
end

-- Mode Loader
if selectedMode == 1 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Random/AntiLock/underground.lua", true))()

    if notificationsEnabled then
        Notification:Notify({Title = "Voidx", Description = "Script Loaded!"}, {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "image"}, {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)})
    end

elseif selectedMode == 2 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Random/AntiLock/sky.lua", true))()

    if notificationsEnabled then
        Notification:Notify({Title = "Voidx", Description = "Script Loaded!"}, {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "image"}, {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)})
    end

elseif selectedMode == 3 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Random/AntiLock/prediction-breaker.lua", true))()

    if notificationsEnabled then
        Notification:Notify({Title = "Voidx", Description = "Script Loaded!"}, {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "image"}, {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)})
    end
end
