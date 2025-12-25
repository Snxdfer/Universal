-- Get the required services
local TweenService = game:GetService("TweenService")

-- Create a new ScreenGui
local GUI = Instance.new("ScreenGui")
GUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create the main frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 60)
MainFrame.Position = UDim2.new(0, -200, 0.95, -60) -- Start off-screen
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = GUI

-- Round the corners of the main frame
local MainFrameCorner = Instance.new("UICorner")
MainFrameCorner.CornerRadius = UDim.new(0, 10)
MainFrameCorner.Parent = MainFrame

-- Create the notification frame
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
NotificationFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Darker gray
NotificationFrame.Parent = MainFrame

-- Round the corners of the notification frame
local NotificationFrameCorner = Instance.new("UICorner")
NotificationFrameCorner.CornerRadius = UDim.new(0, 10)
NotificationFrameCorner.Parent = NotificationFrame

-- Create the text label
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(0.9, 0, 0.7, 0)
TextLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
TextLabel.TextScaled = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextYAlignment = Enum.TextYAlignment.Top
TextLabel.Text = "Cracked By Ata"
TextLabel.Parent = NotificationFrame

-- Create the progress bar
local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0.9, 0, 0.1, 0)
ProgressBar.Position = UDim2.new(0.05, 0, 0.85, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ProgressBar.Parent = NotificationFrame

-- Create the progress bar fill
local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(1, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
ProgressBarFill.Parent = ProgressBar

-- Function to show the notification
local function ShowNotification()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local endPosition = UDim2.new(0.01, 0, 0.95, -60)
    local tween = TweenService:Create(MainFrame, tweenInfo, { Position = endPosition })
    tween:Play()

    -- Start the progress bar countdown
    local countdownTime = 6 -- Countdown time in seconds
    local startTime = tick()

    while tick() - startTime < countdownTime do
        local elapsedTime = tick() - startTime
        local progress = 1 - (elapsedTime / countdownTime)
        ProgressBarFill:TweenSize(UDim2.new(progress, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
        task.wait()
    end

    -- Hide the notification
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local startPosition = UDim2.new(0.01, 0, 0.95, -60)
    local endPosition = UDim2.new(-1, 0, 0.95, -60)
    local tween = TweenService:Create(MainFrame, tweenInfo, { Position = endPosition })
    tween:Play()
end

-- Trigger the notification
ShowNotification()
