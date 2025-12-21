--[[
THIS IS

$$\   $$\                               $$\ $$\                                  
$$$\  $$ |                              $$ |\__|                                 
$$$$\ $$ |$$\   $$\  $$$$$$\   $$$$$$\  $$ |$$\  $$$$$$\      $$$$$$$\  $$$$$$$\ 
$$ $$\$$ |$$ |  $$ |$$  __$$\ $$  __$$\ $$ |$$ | \____$$\    $$  _____|$$  _____|
$$ \$$$$ |$$ |  $$ |$$ |  \__|$$$$$$$$ |$$ |$$ | $$$$$$$ |   $$ /      $$ /      
$$ |\$$$ |$$ |  $$ |$$ |      $$   ____|$$ |$$ |$$  __$$ |   $$ |      $$ |      
$$ | \$$ |\$$$$$$$ |$$ |      \$$$$$$$\ $$ |$$ |\$$$$$$$ |$$\\$$$$$$$\ \$$$$$$$\ 
\__|  \__| \____$$ |\__|       \_______|\__|\__| \_______|\__|\_______| \_______|
          $$\   $$ |                                                             
          \$$$$$$  |                                                             
           \______/                                                              
    PROPERTY.
]]

--[[
  _     _       _    _     _     _       
 | |   (_)     | |  (_)   | |   | |      
 | |__  _   ___| | ___  __| | __| |_   _ 
 | '_ \| | / __| |/ / |/ _` |/ _` | | | |
 | | | | | \__ \   <| | (_| | (_| | |_| |
 |_| |_|_| |___/_|\_\_|\__,_|\__,_|\__, |
                                    __/ |
                                   |___/ 
]]

-- what this "anti-afk-kick" does its, disable your idle shit, and u can be afk and u cant get kicked no more. and it also does block kick functions from the game, like u execute this script and then you execute a script to kick yourself but it doesnt work, because it blocks it, this is op.
-- and obviously u need an executor that support the required functions, if u have a executor that doesnt support the required functions, it will still work but with the normal anti afk, the fallback mode.
-- IF U GET BANNED ON A GAME IT CAN STILL MANAGE TO KICK YOU TO BAN YOU.

if getgenv().Nyrelia_executed then return end
getgenv().Nyrelia_executed = true

local function getfunction(name)
    local ok, f = pcall(function() return getfenv()[name] end)
    if ok and typeof(f) == "function" then return f end
    return false
end

local required_functions = {
    getconnections   = getfunction("getconnections"),
    hookfunction     = getfunction("hookfunction"),
    hookmetamethod   = getfunction("hookmetamethod"),
    newcclosure      = getfunction("newcclosure"),
    getgc            = getfunction("getgc"),
    getrenv          = getfunction("getrenv"),
    getfenv          = getfunction("getfenv"),
    setfenv          = getfunction("setfenv"),
    getrawmetatable  = getfunction("getrawmetatable"),
    setreadonly      = getfunction("setreadonly") or getfunction("make_writeable"),
    checkcaller      = getfunction("checkcaller"),
    cloneref         = getfunction("cloneref"),
    getnamecallmethod= getfunction("getnamecallmethod")
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local function fallbackAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    if VirtualUser then
        print("[anti-afk] loaded fallback mode")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            task.wait(1)
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.8)
            VirtualUser:ClickButton2(Vector2.new(0,0))
            task.wait(0.8)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end

local function NoneSupported()
    for _, val in pairs(required_functions) do
        if val then return false end
    end
    return true
end

if NoneSupported() then
    fallbackAntiAFK()
    return
end

print("[exploit supported functions]:")
for name, val in pairs(required_functions) do
    warn(name .. ": " .. (val and "supported" or "not supported"))
end

if required_functions.getconnections then
    for _, c in ipairs(required_functions.getconnections(LocalPlayer.Idled)) do
        if typeof(c.Disable) == "function" then
            pcall(c.Disable, c)
        end
    end
else
    fallbackAntiAFK()
end

local function CompareInstances(a, b)
    return (typeof(a) == "Instance" and typeof(b) == "Instance")
end

if not getgenv().Nyrelia_AntiKick then
    getgenv().Nyrelia_AntiKick = { Enabled = true, SendNotifications = true, CheckCaller = true }

    local function nyrelia_notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
        end)
    end

    if required_functions.hookmetamethod and required_functions.newcclosure and required_functions.getnamecallmethod then
        local mt = required_functions.getrawmetatable and required_functions.getrawmetatable(game) or debug.getmetatable(game)
        if mt then
            pcall(required_functions.setreadonly, mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = required_functions.newcclosure(function(self, ...)
                local method = required_functions.getnamecallmethod()
                if CompareInstances(self, LocalPlayer) and method == "Kick" and getgenv().Nyrelia_AntiKick.Enabled then
                    if getgenv().Nyrelia_AntiKick.SendNotifications then
                        nyrelia_notify("Nyrelia.cc","intercepted Kick via __namecall")
                    end
                    return nil
                end
                return oldNamecall(self, ...)
            end)
        end
    end

    if required_functions.hookfunction and required_functions.newcclosure then
        pcall(function()
            required_functions.hookfunction(LocalPlayer.Kick, required_functions.newcclosure(function(self, ...)
                if CompareInstances(self, LocalPlayer) and getgenv().Nyrelia_AntiKick.Enabled then
                    if getgenv().Nyrelia_AntiKick.SendNotifications then
                        nyrelia_notify("Nyrelia.cc","intercepted Kick() call")
                    end
                end
            end))
        end)
    end

    if required_functions.getrawmetatable and required_functions.setreadonly then
        local mt = required_functions.getrawmetatable and required_functions.getrawmetatable(game) or debug.getmetatable(game)
        if mt then
            pcall(required_functions.setreadonly, mt, false)
            local oldIndex = mt.__index
            mt.__index = required_functions.newcclosure(function(obj, key)
                if tostring(key):lower() == "kick" then
                    return function() nyrelia_notify("Nyrelia.cc","blocked via __index Kick") end
                end
                return oldIndex(obj, key)
            end)
        end
    end

    local function hookRemote(r)
        if r:IsA("RemoteEvent") then
            r.OnClientEvent:Connect(function(name, ...)
                if typeof(name) == "string" and name:lower():find("kick") then
                    nyrelia_notify("Nyrelia.cc","blocked RemoteEvent: "..name)
                end
            end)
        elseif r:IsA("RemoteFunction") then
            local oldInvoke = r.InvokeServer
            r.InvokeServer = required_functions.newcclosure(function(self, name, ...)
                if typeof(name) == "string" and name:lower():find("kick") then
                    nyrelia_notify("Nyrelia.cc","blocked RemoteFunction: "..name)
                    return nil
                end
                return oldInvoke(self, name, ...)
            end)
        end
    end
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(hookRemote, obj)
        end
    end
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(hookRemote, obj)
        end
    end)

    if required_functions.getgc and required_functions.hookfunction then
        for _, fn in ipairs(required_functions.getgc(true)) do
            if typeof(fn) == "function" and tostring(fn):lower():find("kick") then
                pcall(function()
                    required_functions.hookfunction(fn, required_functions.newcclosure(function() nyrelia_notify("Nyrelia.cc","blocked getgc func") end))
                end)
            end
        end
    end

    if required_functions.getrenv and required_functions.hookfunction then
        task.spawn(function()
            while true do
                task.wait(10)
                for _, fn in pairs(required_functions.getrenv()) do
                    if typeof(fn) == "function" and tostring(fn):lower():find("kick") then
                        pcall(function()
                            required_functions.hookfunction(fn, required_functions.newcclosure(function() nyrelia_notify("Nyrelia.cc","reblocked getrenv func") end))
                        end)
                    end
                end
            end
        end)
    end

    if getgenv().Nyrelia_AntiKick.SendNotifications then
        StarterGui:SetCore("SendNotification", {
            Title = "Nyrelia.cc",
            Text = "anti AFK-Kick loaded.",
            Icon = "rbxassetid://10709790644",
            Duration = 6
        })
    end
    fallbackAntiAFK()
else
    fallbackAntiAFK()
end
