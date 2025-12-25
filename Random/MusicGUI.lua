-- Gui to Lua
-- Version: 3.2

-- Instances:

function CreateGui()
    local MusicGui = Instance.new("ScreenGui")
    local MainUIFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local SoundIDbox = Instance.new("TextBox")
    local UICorner_2 = Instance.new("UICorner")
    local PlaySoundButton = Instance.new("TextButton")
    local UICorner_3 = Instance.new("UICorner")
    local StopSoundButton = Instance.new("TextButton")
    local UICorner_4 = Instance.new("UICorner")
    local SoundVolume = Instance.new("TextBox")
    local UICorner_5 = Instance.new("UICorner")
    local Toggle = Instance.new("Frame")
    local UICorner_6 = Instance.new("UICorner")
    local Text = Instance.new("TextLabel")
    local TextButton = Instance.new("TextButton")
    local UICorner_7 = Instance.new("UICorner")
    local Sound = Instance.new("Sound")

    -- Properties:

    MusicGui.Name = "MusicGui"
    MusicGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    MusicGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainUIFrame.Name = "MainUIFrame"
    MainUIFrame.Parent = MusicGui
    MainUIFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
    MainUIFrame.Position = UDim2.new(0.281, 0, 0.268, 0)
    MainUIFrame.Size = UDim2.new(0, 232, 0, 273)
    MainUIFrame.Draggable = true
    MainUIFrame.Active = true

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = MainUIFrame

    SoundIDbox.Name = "SoundIDbox"
    SoundIDbox.Parent = MainUIFrame
    SoundIDbox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    SoundIDbox.Position = UDim2.new(0.065, 0, 0.103, 0)
    SoundIDbox.Size = UDim2.new(0, 200, 0, 50)
    SoundIDbox.Font = Enum.Font.SourceSans
    SoundIDbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    SoundIDbox.PlaceholderText = "SoundID"
    SoundIDbox.Text = ""
    SoundIDbox.TextColor3 = Color3.fromRGB(0, 0, 0)
    SoundIDbox.TextSize = 14.000

    UICorner_2.CornerRadius = UDim.new(0, 4)
    UICorner_2.Parent = SoundIDbox

    Sound.Name = "PlayableSound"
    Sound.Parent = workspace

    PlaySoundButton.Name = "PlaySoundButton"
    PlaySoundButton.Parent = MainUIFrame
    PlaySoundButton.BackgroundColor3 = Color3.fromRGB(0, 159, 26)
    PlaySoundButton.Position = UDim2.new(0.241, 0, 0.678, 0)
    PlaySoundButton.Size = UDim2.new(0, 119, 0, 36)
    PlaySoundButton.Font = Enum.Font.FredokaOne
    PlaySoundButton.Text = "Play"
    PlaySoundButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    PlaySoundButton.TextSize = 30.000

    UICorner_3.CornerRadius = UDim.new(0, 4)
    UICorner_3.Parent = PlaySoundButton

    StopSoundButton.Name = "StopSoundButton"
    StopSoundButton.Parent = MainUIFrame
    StopSoundButton.BackgroundColor3 = Color3.fromRGB(149, 0, 2)
    StopSoundButton.Position = UDim2.new(0.241, 0, 0.842, 0)
    StopSoundButton.Size = UDim2.new(0, 119, 0, 36)
    StopSoundButton.Font = Enum.Font.FredokaOne
    StopSoundButton.Text = "Stop"
    StopSoundButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    StopSoundButton.TextSize = 30.000

    UICorner_4.CornerRadius = UDim.new(0, 4)
    UICorner_4.Parent = StopSoundButton

    SoundVolume.Name = "SoundVolume"
    SoundVolume.Parent = MainUIFrame
    SoundVolume.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    SoundVolume.Position = UDim2.new(0.138, 0, 0.333, 0)
    SoundVolume.Size = UDim2.new(0, 166, 0, 34)
    SoundVolume.Font = Enum.Font.SourceSans
    SoundVolume.PlaceholderText = "Sound Volume (1 - 10)"
    SoundVolume.Text = ""
    SoundVolume.TextColor3 = Color3.fromRGB(0, 0, 0)
    SoundVolume.TextSize = 14.000

    UICorner_5.CornerRadius = UDim.new(0, 4)
    UICorner_5.Parent = SoundVolume

    Toggle.Name = "Toggle"
    Toggle.Parent = MainUIFrame
    Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    Toggle.Position = UDim2.new(0.185, 0, 0.516, 0)
    Toggle.Size = UDim2.new(0, 143, 0, 29)

    UICorner_6.CornerRadius = UDim.new(0, 4)
    UICorner_6.Parent = Toggle

    Text.Name = "Text"
    Text.Parent = Toggle
    Text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Text.BackgroundTransparency = 1.000
    Text.Size = UDim2.new(0, 107, 0, 29)
    Text.Font = Enum.Font.Gotham
    Text.Text = "Looped:"
    Text.TextColor3 = Color3.fromRGB(178, 178, 178)
    Text.TextSize = 14.000

    TextButton.Parent = Toggle
    TextButton.BackgroundColor3 = Color3.fromRGB(166, 0, 3)
    TextButton.Position = UDim2.new(0.645, 0, -0.034, 0)
    TextButton.Size = UDim2.new(0, 30, 0, 30)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = ""
    TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextSize = 14.000

    local loopedUbag = false

    TextButton.MouseButton1Click:Connect(function()
        Sound = Sound or workspace:FindFirstChild("PlayableSound")
        loopedUbag = not loopedUbag
        TextButton.BackgroundColor3 = loopedUbag and Color3.fromRGB(0, 159, 26) or Color3.fromRGB(149, 0, 2)
        Sound.Looped = loopedUbag
    end)

    UICorner_7.CornerRadius = UDim.new(0, 4)
    UICorner_7.Parent = TextButton

    PlaySoundButton.MouseButton1Click:Connect(function()
        Sound = Sound or workspace:FindFirstChild("PlayableSound")
        Sound.SoundId = "rbxassetid://" .. SoundIDbox.Text
        local volume = tonumber(SoundVolume.Text)
        if volume then
            Sound.Volume = math.clamp(volume, 0, 10)
        end
        Sound:Play()
    end)

    StopSoundButton.MouseButton1Click:Connect(function()
        Sound:Stop()
    end)
end

CreateGui()

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if not game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MusicGui") then
        CreateGui()
    end

    if not workspace:FindFirstChild("PlayableSound") then
        local Sound = Instance.new("Sound")
        Sound.Name = "PlayableSound"
        Sound.Parent = workspace
    end
end)
