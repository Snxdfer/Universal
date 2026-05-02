local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(parent: GuiObject)
    local Input = IrisModules.UserInputService

    Input.SinkFrame.Parent = parent

    Iris.Internal._utility.UserInputService = Input
    Iris.UpdateGlobalConfig({
        UseScreenGUIs = false,
    })
    Iris.Internal._utility.GuiOffset = Input.SinkFrame.AbsolutePosition
    Iris.Internal._utility.MouseOffset = Input.SinkFrame.AbsolutePosition
    Input.SinkFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        Iris.Internal._utility.GuiOffset = Input.SinkFrame.AbsolutePosition
        Iris.Internal._utility.MouseOffset = Input.SinkFrame.AbsolutePosition
    end)

    Iris.Init(parent)

    -- Actual Iris code here:
    Iris:Connect(Iris.ShowDemoWindow)

    return function()
        Iris.Shutdown()

        for _, connection in Input._connections do
            connection:Disconnect()
        end

        Input.SinkFrame:Destroy()
    end
end
