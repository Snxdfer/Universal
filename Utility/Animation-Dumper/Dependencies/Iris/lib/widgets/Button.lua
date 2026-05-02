return function(Iris, widgets)
    local abstractButton = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Size"] = 2,
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget)
                return thisWidget.Instance
            end),
            ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end),
        },
        Generate = function(_thisWidget)
            local Button = Instance.new("TextButton")
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromOffset(0, 0)
            Button.BackgroundColor3 = Iris._config.ButtonColor
            Button.BackgroundTransparency = Iris._config.ButtonTransparency
            Button.AutoButtonColor = false

            widgets.applyTextStyle(Button)
            Button.TextXAlignment = Enum.TextXAlignment.Center

            widgets.applyFrameStyle(Button)

            widgets.applyInteractionHighlights("Background", Button, Button, {
                Color = Iris._config.ButtonColor,
                Transparency = Iris._config.ButtonTransparency,
                HoveredColor = Iris._config.ButtonHoveredColor,
                HoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ActiveColor = Iris._config.ButtonActiveColor,
                ActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            return Button
        end,
        Update = function(thisWidget)
            local Button = thisWidget.Instance :: TextButton
            Button.Text = thisWidget.arguments.Text or "Button"
            Button.Size = thisWidget.arguments.Size or UDim2.fromOffset(0, 0)
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end,
    }
    widgets.abstractButton = abstractButton

    --stylua: ignore
    Iris.WidgetConstructor("Button", widgets.extend(abstractButton, {
            Generate = function(thisWidget)
                local Button = abstractButton.Generate(thisWidget)
                Button.Name = "Iris_Button"

                return Button
            end,
        })
    )

    --stylua: ignore
    Iris.WidgetConstructor("SmallButton", widgets.extend(abstractButton, {
            Generate = function(thisWidget)
                local SmallButton = abstractButton.Generate(thisWidget)
                SmallButton.Name = "Iris_SmallButton"

                local uiPadding: UIPadding = SmallButton.UIPadding
                uiPadding.PaddingLeft = UDim.new(0, 2)
                uiPadding.PaddingRight = UDim.new(0, 2)
                uiPadding.PaddingTop = UDim.new(0, 0)
                uiPadding.PaddingBottom = UDim.new(0, 0)

                return SmallButton
            end,
        })
    )
end
