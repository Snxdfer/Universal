local ToS_GUI = {}
function ToS_GUI:Agreement(Propeties)
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local Frame_2 = Instance.new("Frame")
	local ImageLabel = Instance.new("ImageLabel")
	local ImageLabel_2 = Instance.new("ImageLabel")
	local TextLabel = Instance.new("TextLabel")
	local expand = Instance.new("ImageLabel")
	local d = Instance.new("TextLabel")
	local uistroke1 = Instance.new("UIStroke")
	local uistroke2 = Instance.new("UIStroke")

	ScreenGui.Parent = game["Run Service"]:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or game.CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = ScreenGui
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(45, 46, 45)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	Frame.Size = UDim2.new(0, 240, 0, 65)
	Frame.AutomaticSize = Enum.AutomaticSize.Y

	Frame_2.Parent = Frame
	Frame_2.BackgroundColor3 = Color3.fromRGB(54, 55, 54)
	Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame_2.BorderSizePixel = 0
	Frame_2.Position = UDim2.new(0, 10, 0, 23)
	Frame_2.Size = UDim2.new(0, 30, 0, 30)

	ImageLabel.Parent = Frame_2
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1.000
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Image = "rbxassetid://88565752667453"
	ImageLabel.ImageColor3 = Color3.fromRGB(134, 255, 78)

	ImageLabel_2.Parent = Frame
	ImageLabel_2.AnchorPoint = Vector2.new(1, 0)
	ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel_2.BackgroundTransparency = 1.000
	ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel_2.BorderSizePixel = 0
	ImageLabel_2.Position = UDim2.new(1, -10, 0, 10)
	ImageLabel_2.Size = UDim2.new(0, 48, 0, 48)
	ImageLabel_2.Image = "rbxassetid://81547176107809"

	TextLabel.Parent = Frame
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0, 10, 0, 5)
	TextLabel.Size = UDim2.new(0, 200, 0, 15)
	TextLabel.Font = Enum.Font.Ubuntu
	TextLabel.Text = Propeties.Title or "Do you agree to the terms of this script"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 13.000
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	expand.Name = "expand"
	expand.Parent = Frame
	expand.AnchorPoint = Vector2.new(0.5, 1)
	expand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	expand.BackgroundTransparency = 1.000
	expand.BorderColor3 = Color3.fromRGB(0, 0, 0)
	expand.BorderSizePixel = 0
	expand.Position = UDim2.new(0.5, 0, 1, -4)
	expand.Size = UDim2.new(0, 16, 0, 16)
	expand.Image = "rbxassetid://78984098833846"
	expand.ImageColor3 = Color3.fromRGB(144, 144, 144)

	d.Name = "d"
	d.Parent = Frame
	d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	d.BackgroundTransparency = 1.000
	d.BorderColor3 = Color3.fromRGB(0, 0, 0)
	d.BorderSizePixel = 0
	d.Position = UDim2.new(0, 10, 0, 57)
	d.Size = UDim2.new(1, -20, 0, 15)
	d.Visible = false
	d.Font = Enum.Font.Ubuntu
	d.Text = Propeties.AgreementText
	d.TextColor3 = Color3.fromRGB(144, 144, 144)
	d.TextSize = 13.000
	d.TextWrapped = true
	d.TextXAlignment = Enum.TextXAlignment.Left
	d.AutomaticSize = Enum.AutomaticSize.Y

	uistroke1.Parent = Frame
	uistroke1.Color = Color3.fromRGB(103, 103, 103)
	uistroke1.Thickness = 2

	uistroke2.Parent = Frame_2
	uistroke2.Color = Color3.fromRGB(41, 41, 41)

	-- Scripts:

	local function FVGFJFY_fake_script() -- Frame_2.LocalScript 
		local script = Instance.new('LocalScript', Frame_2)

		local uis = game:GetService("UserInputService")
		local done = false
		local function pressed(obj: Frame, f: Function)
			obj.InputEnded:Connect(function(a)
				if (a.UserInputType == Enum.UserInputType.MouseButton1 or a.UserInputType == Enum.UserInputType.Touch) and done ~= true then
					script.Parent.ImageLabel.Size = UDim2.new(0, 0, 1, -7)
					done = true
					;(Propeties.OnAgreed or function() end)()
					local l = 6
					for i = 1, l do
						game:GetService("TweenService"):Create(script.Parent.ImageLabel, TweenInfo.new(i == l and 0.4 or 0.08, i == l and Enum.EasingStyle.Sine or Enum.EasingStyle.Linear), {
							Size = i == l and UDim2.new(1, -10, 1, -10) or (i % 2 ~= 0 and UDim2.new(1, -7, 1, -7) or UDim2.new(0, 0, 1, -7))
						}):Play()
						wait(i == l and 0.4 or 0.08)
					end
				end
			end)
		end
		pressed(script.Parent)
		repeat task.wait() until done
		wait(2.5)
		script.Parent.Parent.Parent:Destroy()
	end
	coroutine.wrap(FVGFJFY_fake_script)()
	local function HGEGFJU_fake_script() -- expand.LocalScript 
		local script = Instance.new('LocalScript', expand)

		local uis = game:GetService("UserInputService")
		local done = false
		local function pressed(obj: Frame, f: Function)
			obj.InputEnded:Connect(function(a)
				if (a.UserInputType == Enum.UserInputType.MouseButton1 or a.UserInputType == Enum.UserInputType.Touch) and done ~= true then
					f()
				end
			end)
		end
		pressed(script.Parent, function()
			script.Parent.Parent.d.Visible = true
			script.Parent.Visible = false
		end)

		pressed(script.Parent.Parent.d, function()
			script.Parent.Parent.Parent:Destroy()
		end)
	end
	coroutine.wrap(HGEGFJU_fake_script)()
end
return ToS_GUI
