getgenv().Settings = {
    Antilock = true,
    yAxis = 100000,

    Keybind = Enum.KeyCode.C,

    DesyncMode = false,
    DesyncAngles = 0.1,

    VelocityVisual = true
}
local veldot = Drawing.new("Circle")
spawn(function()
    veldot.Filled = true
    veldot.Thickness = 1
    veldot.Transparency = 1
    veldot.Radius = 5
    veldot.Color = Color3.fromRGB(170, 120, 210)
end)
game:GetService("RunService").Heartbeat:Connect(function()
    local pos, onscreen = workspace.CurrentCamera:WorldToViewportPoint(
        game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].CFrame.Position +
            (game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].AssemblyLinearVelocity *
                0.15))

    if Settings.VelocityVisual and onscreen then
        veldot.Visible = true
        veldot.Position = Vector2.new(pos.X, pos.Y)
    else
        veldot.Visible = false
    end
end)
game:GetService("RunService").Heartbeat:Connect(function()
    local hrp, hum = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, game:GetService("Players").LocalPlayer.Character.Humanoid
    local velocity, cframe = hrp.AssemblyLinearVelocity, hrp.CFrame

    if Settings.Antilock then
        hrp.AssemblyLinearVelocity = Vector3.new(
            0,
            Settings.yAxis,
            0)

        if Settings.DesyncMode then
            hrp.CFrame = cframe *
                CFrame.Angles(0, math.rad(Settings.DesyncAngles), 0)
        end

        game:GetService("RunService").RenderStepped:Wait()
        hrp.AssemblyLinearVelocity = velocity
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(Key)
    if Key.KeyCode == Settings.Keybind and not game:GetService("UserInputService"):GetFocusedTextBox() then
        Settings.Antilock = not Settings.Antilock
    end
end)
