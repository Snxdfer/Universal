repeat task.wait() until game:IsLoaded()

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Potassium",
        Text = "Injected Successfully.",
        Duration = 10,
        Icon = "rbxassetid://98061072242937"
    })
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImageFadeGui"
screenGui.DisplayOrder = 10 ^ 6
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "FadingImage"
imageLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
imageLabel.Position = UDim2.new(0.5, 0, 0, -200)
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Image = "rbxassetid://98061072242937"
imageLabel.BackgroundTransparency = 1
imageLabel.ImageTransparency = 1
imageLabel.ScaleType = Enum.ScaleType.Fit
imageLabel.ZIndex = 10 ^ 6
imageLabel.Parent = screenGui

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://8795831946"
sound.Volume = 1.5
sound.Looped = false
sound.Parent = screenGui
sound:Play()

local moveDuration = 1.5
local holdTime = 1.5
local exitDuration = 1
local fadeDuration = 1

local moveTweenInfo = TweenInfo.new(moveDuration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local exitTweenInfo = TweenInfo.new(exitDuration, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
local fadeTweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local moveGoal = { Position = UDim2.new(0.5, 0, 0.5, 0) }
local exitGoal = { Position = UDim2.new(0.5, 0, 0, -200) }

local fadeInGoal = { ImageTransparency = 0 }
local fadeOutGoal = { ImageTransparency = 1 }

local moveTween = TweenService:Create(imageLabel, moveTweenInfo, moveGoal)
local exitTween = TweenService:Create(imageLabel, exitTweenInfo, exitGoal)

local fadeInTween = TweenService:Create(imageLabel, fadeTweenInfo, fadeInGoal)
local fadeOutTween = TweenService:Create(imageLabel, fadeTweenInfo, fadeOutGoal)

local function animate()
    fadeInTween:Play()
    moveTween:Play()

    moveTween.Completed:Once(function()
        task.wait(holdTime)
        fadeOutTween:Play()
        
        fadeOutTween.Completed:Once(function()
            exitTween:Play()
            
            exitTween.Completed:Once(function()
                screenGui:Destroy()
            end)
        end)
    end)
end

animate()
