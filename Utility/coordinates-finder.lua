if not game:IsLoaded() then
    game.Loaded:Wait()
end

local StartTime = tick()
local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local TweenService = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")

local ScriptVersion = "3.0.0"
local Executor = "Unknown"
local LocalPlayer = Players.LocalPlayer
local CloneRefSupported = (cloneref ~= nil)

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/back-ups-for-libs/refs/heads/main/OrionModified.lua"))()
local Window = OrionLib:MakeWindow({Name = "coords finder | v" .. ScriptVersion .. " | .gg/jB4yJgn3pE", HidePremium = false, SaveConfig = false, SearchBar = false, IntroEnabled = true, IntroText = "made by 00Fazee (elrandom#1311)", IntroIcon = "rbxassetid://120907355927374", ShowIcon = true, Icon = "rbxassetid://120907355927374", ConfigFolder = "coordsfinderv2"})

local function Notify(title, content, imageID, time)
    OrionLib:MakeNotification({
        Name = tostring(title or "coords finder"),
        Content = tostring(content or ""),
        Image = imageID and (tostring(imageID):find("rbxassetid://") and tostring(imageID) or "rbxassetid://" .. tostring(imageID)) or "rbxassetid://4483345998",
        Time = tonumber(time) or 5
    })
end

local function toClipboard(str)
    local setcb = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if setcb then
        setcb(str)
    else
        Notify("coords finder | error", "your exploit doesn't support setclipboard", "rbxassetid://10747384394", 5)
        warn("[coords finder | clipboard error]: setclipboard not available")
    end
end

local function GetHRP()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetPositionText(hrp)
    if not hrp then return "Position: N/A" end
    local pos = hrp.Position
    return string.format("X: %d  |  Y: %d  |  Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
end

local function ServiceLine(serviceName)
    if CloneRefSupported then
        return string.format('local %s = cloneref and cloneref(game:GetService("%s")) or game:GetService("%s")', serviceName, serviceName, serviceName)
    else
        return string.format('local %s = game:GetService("%s")', serviceName, serviceName)
    end
end

local InformationTab = Window:MakeTab({Name = "Information", Icon = "rbxassetid://10723415903", PremiumOnly = false})
local InfoSection = InformationTab:AddSection({Name = "Information"})

if identifyexecutor then local ok, res = pcall(identifyexecutor) if ok and res then Executor = tostring(res) end end

local Supported = "Yes"
InfoSection:AddParagraph("Script Info", "Version: "   .. ScriptVersion .. "\nExecutor: " .. Executor .. "\nSupported: " .. Supported .. "\nCloneRef: "  .. (CloneRefSupported and "Yes" or "No"))
InfoSection:AddParagraph("Generated Scripts", "scripts you generate will " .. (CloneRefSupported and "USE cloneref (your executor supports it)." or "use standard GetService (cloneref not detected)."))

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://10723407389", PremiumOnly = false})
local PositionSection = MainTab:AddSection({Name = "Position"})
local PositionLabel = PositionSection:AddLabel("waiting for character...")

task.spawn(function()
    local lastPos = Vector3.new(0, 0, 0)
    while true do
        task.wait(0.1)

        local character = LocalPlayer.Character
        if not character then
            PositionLabel:Set("waiting for character...")
            LocalPlayer.CharacterAdded:Wait()
            continue
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            PositionLabel:Set("waiting for HumanoidRootPart...")
            character:WaitForChild("HumanoidRootPart", 10)
            continue
        end

        local pos = hrp.Position
        if (pos - lastPos).Magnitude > 0.5 then
            PositionLabel:Set(GetPositionText(hrp))
            lastPos = pos
        end
    end
end)

PositionSection:AddButton({
Name = "Copy Position (Vector3)",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then
            Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
            return
        end
        toClipboard(tostring(hrp.Position))
        Notify("coords finder | success", "Position copied!", "rbxassetid://6023426945", 5)
    end
})

PositionSection:AddButton({
    Name = "Copy CFrame (includes rotation)",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then
            Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
            return
        end
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = hrp.CFrame:components()
        toClipboard(string.format(
            "CFrame.new(%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g)",
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22
        ))
        Notify("coords finder | success", "CFrame copied!", "rbxassetid://6023426945", 5)
    end
})

local NormalSection = MainTab:AddSection({Name = "Instant Teleport Script"})
NormalSection:AddButton({
    Name = "Generate (position only)",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then
            Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
            return
        end

        local pos = hrp.Position
        local script = string.format([[
%s

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

HumanoidRootPart.CFrame = CFrame.new(%g, %g, %g)
]], ServiceLine("Players"), pos.X, pos.Y, pos.Z)

        toClipboard(script)
        Notify("coords finder | success", "Instant TP script copied!", "rbxassetid://6023426945", 5)
    end
})

NormalSection:AddButton({
    Name = "Generate (with rotation)",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then
            Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
            return
        end

        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = hrp.CFrame:components()
        local script = string.format([[
%s

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

HumanoidRootPart.CFrame = CFrame.new(%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g)
]], ServiceLine("Players"), x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)

        toClipboard(script)
        Notify("coords finder | success", "Instant TP (with rotation) copied!", "rbxassetid://6023426945", 5)
    end
})

local TweenSection = MainTab:AddSection({Name = "Tween Teleport Script" })
local TweenTime = 3
local TweenEasingStyle = "Linear (Default)"
TweenSection:AddLabel("i dont recommend using other easing style than Linear")
TweenSection:AddSlider({
    Name = "Tween Time",
    Min = 1,
    Max = 50,
    Default = 3,
    Increment = 0.5,
    ValueName = "Seconds",
    Callback = function(value)
        TweenTime = value
    end
})

TweenSection:AddDropdown({
    Name = "Easing Style",
    Default = "Linear (Default)",
    Options = {"Linear (Default)", "Sine", "Bounce", "Back", "Elastic", "Exponential", "Circular", "Cubic", "Quad", "Quart", "Quint"},
    Callback = function(value)
        TweenEasingStyle = value
    end
})

TweenSection:AddButton({
    Name = "Generate Tween Script",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then
            Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
            return
        end

        local pos = hrp.Position
        local script = string.format([[
%s
%s

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local tweenInfo = TweenInfo.new(%g, Enum.EasingStyle.%s)
TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(%g, %g, %g)}):Play()
]], ServiceLine("Players"), ServiceLine("TweenService"), TweenTime, TweenEasingStyle, pos.X, pos.Y, pos.Z)

        toClipboard(script)
        Notify("coords finder | success", "Tween script copied!", "rbxassetid://6023426945", 5)
    end
})

local WaypointsTab = Window:MakeTab({Name = "Waypoints", Icon = "rbxassetid://10734886004", PremiumOnly = false})
local Waypoints = {}

for i = 1, 3 do
    Waypoints[i] = nil

    local SlotSection = WaypointsTab:AddSection({Name = "Waypoint " .. i })
    local SlotLabel = SlotSection:AddLabel("Waypoint " .. i .. ": Empty")

    SlotSection:AddButton({
        Name = "Save to Waypoint " .. i,
        Callback = function()
            local hrp = GetHRP()
            if not hrp then
                Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
                return
            end
            Waypoints[i] = hrp.CFrame
            local pos = hrp.Position
            SlotLabel:Set(string.format(
                "Waypoint %d: X:%d  Y:%d  Z:%d",
                i, math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
            ))
            Notify("coords finder", "Saved to Waypoint " .. i .. "!", "rbxassetid://6023426945", 3)
        end
    })

    SlotSection:AddButton({
        Name = "Teleport to Waypoint " .. i,
        Callback = function()
            if not Waypoints[i] then
                Notify("coords finder | error", "Waypoint " .. i .. " is empty!", "rbxassetid://10747384394", 5)
                return
            end
            local hrp = GetHRP()
            if not hrp then
                Notify("coords finder | error", "HumanoidRootPart not found", "rbxassetid://10747384394", 5)
                return
            end
            hrp.CFrame = Waypoints[i]
            Notify("coords finder", "teleported to Waypoint " .. i .. "!", "rbxassetid://6023426945", 3)
        end
    })

    SlotSection:AddButton({
        Name = "Generate TP Script (Waypoint " .. i .. ")",
        Callback = function()
            if not Waypoints[i] then
                Notify("coords finder | error", "Waypoint " .. i .. " is empty!", "rbxassetid://10747384394", 5)
                return
            end
            local pos = Waypoints[i].Position
            local script = string.format([[
%s

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Waypoint %d
HumanoidRootPart.CFrame = CFrame.new(%g, %g, %g)
]], ServiceLine("Players"), i, pos.X, pos.Y, pos.Z)
            toClipboard(script)
            Notify("coords finder | success", "Script for Waypoint " .. i .. " copied!", "rbxassetid://6023426945", 3)
        end
    })
end

local CreditsTab = Window:MakeTab({Name = "Credits", Icon = "rbxassetid://74007982981741", PremiumOnly = false})
local CreditsSection = CreditsTab:AddSection({Name = "Credits"})
CreditsSection:AddLabel("thanks for using my coords finder script")
CreditsSection:AddLabel("made by 00Fazee (elrandom#1311)")
CreditsSection:AddLabel("join my discord pls: discord.gg/jB4yJgn3pE")

OrionLib:Init()
local LoadTime = tick() - StartTime
Notify("coords finder | loaded", string.format("Loaded successfully in %.2fs", LoadTime), "rbxassetid://10709805144", 7)
pcall(function() loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6bcd5f73ca1a", "1.0.0", false) end) --scriptblox analytics, please do not delete, thank you.
