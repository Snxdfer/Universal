repeat task.wait() until game:IsLoaded()

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Velocity",
        Text = "Injected Successfully.",
        Duration = 10,
        Icon = "rbxassetid://92048641694788"
    })
end)

local screenGui = Instance.new("ScreenGui")
local imageLabel = Instance.new("ImageLabel")
local sound = Instance.new("Sound")

screenGui.Parent = CoreGui
screenGui.Name = "ImageFadeGui"
screenGui.DisplayOrder = 10 ^ 6
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

imageLabel.Parent = screenGui
imageLabel.Name = "FadingImage"
imageLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
imageLabel.Position = UDim2.new(1.2, 0, -0.2, 0)
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Image = "rbxassetid://92048641694788"
imageLabel.BackgroundTransparency = 1
imageLabel.ImageTransparency = 1
imageLabel.ScaleType = Enum.ScaleType.Fit
imageLabel.ZIndex = 10 ^ 6

sound.Parent = screenGui
sound.SoundId = "rbxassetid://8795831946"
sound.Volume = 1.5
sound.Looped = false
sound:Play()

local moveDuration = 1.5
local exitDuration = 1
local fadeDuration = 1

local moveTweenInfo = TweenInfo.new(moveDuration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local exitTweenInfo = TweenInfo.new(exitDuration, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
local fadeTweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local moveGoal = {Position = UDim2.new(0.5, 0, 0.5, 0)}
local exitGoal = {Position = UDim2.new(-0.2, 0, 1.2, 0)}

local moveTween = TweenService:Create(imageLabel, moveTweenInfo, moveGoal)
local exitTween = TweenService:Create(imageLabel, exitTweenInfo, exitGoal)

local fadeInGoal = {ImageTransparency = 0}
local fadeOutGoal = {ImageTransparency = 1}

local fadeInTween = TweenService:Create(imageLabel, fadeTweenInfo, fadeInGoal)
local fadeOutTween = TweenService:Create(imageLabel, fadeTweenInfo, fadeOutGoal)

local function animate()
    fadeInTween:Play()
    moveTween:Play()

    moveTween.Completed:Once(function()
        task.wait(1.5)
        exitTween:Play()
		task.wait(0.3)
        fadeOutTween:Play()

        exitTween.Completed:Once(function()
            screenGui:Destroy()
        end)
    end)
end

animate()
