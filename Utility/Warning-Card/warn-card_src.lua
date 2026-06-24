--!optimize 2
--!native

-- Made with <3 by Dave
-- ancestrychanged.com/socials

return function(userConfig)
    -- if not IB_OBFUSCATED then
    --     IB_NO_VIRTUALIZE = function(f) return f end
    --     IB_CRASH = function() end
    --     IB_ENCSTR = function(s) return s end
    --     IB_LINE = 1
    -- end

    userConfig = userConfig or {}
    
    local cloneref = cloneref or clonereference or clone_reference or function(s) return s end
    local gethui = gethui or get_hui or get_hidden_gui or get_hidden_ui or gethiddengui or function() return game.Players.LocalPlayer.PlayerGui end
    local writefile = writefile or write_file
    local getcustomasset = getcustomasset or get_custom_asset or getsynasset or get_syn_asset
    local setidentity = setidentity or setthreadidentity or set_thread_identity or set_identity or setthreadcontext or set_thread_context or setcontext or (syn and (syn.set_thread_identity or syn.setthreadidentity)) or function(n) return n end
    local setclipboard = setclipboard or toclipboard or set_clipboard or to_clipboard or (syn and syn.write_clipboard) or function(s) return s end
    local request = request or http_request or (syn and syn.request) or (http and http.request)
    -- no i didn't make the aliases up
    -- they exist in envs i collected
    -- see more at:
    -- https://ancestrychanged.com/misc/environments.7z
    
    local ident = setidentity(3) -- pray that user's executor returns previous identity on setid call 🙏
    local ts = game:GetService("TweenService") -- ok come on probably every game holds this as a hard ref lol im not cloneref()'ing it
    local run = game:GetService("RunService")
    local starterGui = game:GetService("StarterGui")
    local lighting = cloneref(game:GetService("Lighting")) -- cloneref'ing cuz what if the game has weak table dtc and doesnt hard ref lighting
    local cam = workspace.CurrentCamera
    local baseFov = cam.FieldOfView
    local vp = cam.ViewportSize
    local gothamUrl = "rbxasset://fonts/families/GothamSSm.json"
    local stripePer = 3
    local stripeFrames = 5
    local stripeTotal = stripePer * stripeFrames
    local stripeScrollSpeed = 0.05
    local stripePhase = 0
    local closed = false
    local result -- which button closed it: "primary" or "secondary"
    local stripeLayers = {}
    local stripeGrads = {}
    local stripeSide = math.max(vp.X, vp.Y) + 100
    local weaopic
    local logo

    local icon1 = { -- warning
        Image = "rbxassetid://16898613869",
        ImageRectSize = Vector2.new(48, 48),
        ImageRectOffset = Vector2.new(967, 0),
    }

    local icon2 = { -- link
        Image = "rbxassetid://16898613509",
        ImageRectSize = Vector2.new(48, 48),
        ImageRectOffset = Vector2.new(967, 404),
    }

    local icon3 = { -- external link
        Image = "rbxassetid://16898613777",
        ImageRectSize = Vector2.new(48, 48),
        ImageRectOffset = Vector2.new(967, 514),
    }

    local config = {
        title = "Unsupported executor",
        body = "This script uses functions that your executor doesn't support.",
        site = "https://weao.xyz/",
        note = "Every executor on the site works, except Xeno and Solara.",
        primary = "View executors",
        secondary = "Dismiss",
        invite = "weaoxyz", -- discord invite, set to nil if you don't want to see the primary button
        logoUrl = "https://ancestrychanged.com/images/weaologo.png",
        logoFile = "weaologo.png",
        yields = true, -- false: returns instantly, script keeps running; true: waits for user to click any button + also returns which button was clicked - primary (view executors) or secondary (dismiss)
        hideOtherUis = true, -- hide every other UI (inf yield, roblox topbar, other ScreenGuis/SurfaceGuis/BillboardGuis) while the warning is visible, restore them on close
    }

    for k, v in userConfig do
        config[k] = v
    end

    if config.logoGradient == nil then
        config.logoGradient = config.logoFile:match("^weaologo") ~= nil
    end

    local colors = {
        cardBg = Color3.fromRGB(27, 29, 35),
        cardStroke = Color3.fromRGB(48, 52, 62),
        badgeBg = Color3.fromRGB(58, 42, 32),
        badgeRing = Color3.fromRGB(90, 67, 48),
        amber = Color3.fromRGB(240, 166, 90),
        title = Color3.fromRGB(244, 245, 248),
        body = Color3.fromRGB(156, 162, 174),
        insetBg = Color3.fromRGB(21, 22, 27),
        insetStroke = Color3.fromRGB(42, 45, 53),
        logoBg = Color3.fromRGB(13, 14, 17),
        caption = Color3.fromRGB(110, 116, 128),
        ghostIdle = Color3.fromRGB(38, 41, 49),
        ghostHover = Color3.fromRGB(52, 56, 66),
        ghostStroke = Color3.fromRGB(58, 62, 72),
        ghostText = Color3.fromRGB(199, 204, 214),
        primary = Color3.fromRGB(232, 154, 60),
        primaryHover = Color3.fromRGB(242, 166, 74),
        primaryText = Color3.fromRGB(58, 38, 6),
    }

    local function font(weight)
        return Font.new(gothamUrl, weight, Enum.FontStyle.Normal)
    end

    local function applyIcon(img, data, color)
        for i, v in data do
            img[i] = v
        end

        img.ImageColor3 = color
    end

    local function tween(obj, time, props, style, dir)
        if not style then
            style = Enum.EasingStyle.Quad
        end

        if not dir then
            dir = Enum.EasingDirection.Out
        end

        ts:Create(obj, TweenInfo.new(time, style, dir), props):Play()
    end

    local function stripeSeq(layer)
        local kp = {}
        local e = 0.0012

        kp[#kp + 1] = NumberSequenceKeypoint.new(0, 1)

        for f = 0, stripePer - 1 do
            local s = layer + f * stripeFrames
            local a = (s + 0.25) / stripeTotal
            local b = (s + 0.75) / stripeTotal
            kp[#kp + 1] = NumberSequenceKeypoint.new(a - e, 1)
            kp[#kp + 1] = NumberSequenceKeypoint.new(a, 0)
            kp[#kp + 1] = NumberSequenceKeypoint.new(b, 0)
            kp[#kp + 1] = NumberSequenceKeypoint.new(b + e, 1)
        end

        kp[#kp + 1] = NumberSequenceKeypoint.new(1, 1)

        return NumberSequence.new(kp)
    end

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = lighting

    for i, v in {"UnsupportedToolWarning", "UnsupportedToolWarningBg"} do
        if gethui():FindFirstChild(v) then
            gethui():FindFirstChild(v):Destroy()
        end
    end

    local bgGui = Instance.new("ScreenGui")
    bgGui.Name = "UnsupportedToolWarningBg"
    bgGui.IgnoreGuiInset = true
    bgGui.ScreenInsets = Enum.ScreenInsets.None
    bgGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
    bgGui.ClipToDeviceSafeArea = false
    bgGui.ResetOnSpawn = false
    bgGui.DisplayOrder = 2147483646
    bgGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bgGui.Parent = gethui()

    local gui = Instance.new("ScreenGui")
    gui.Name = "UnsupportedToolWarning"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = gethui()

    local hiddenUis = {}
    local uiConns = {}

    local function isOther(inst)
        return inst:IsA("LayerCollector") and inst ~= gui and inst ~= bgGui
    end

    local function suppress(inst)
        if inst.Enabled then
            inst.Enabled = false
            hiddenUis[inst] = true
        end
    end

    local function watch(inst)
        suppress(inst)
        uiConns[#uiConns + 1] = inst:GetPropertyChangedSignal("Enabled"):Connect(function()
            suppress(inst)
        end)
    end

    local function hideOtherUis()
        starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        starterGui:SetCore("TopbarEnabled", false)

        local roots = {game:GetService("CoreGui"), gethui(), game.Players.LocalPlayer.PlayerGui, workspace}

        for i, root in roots do
            for i, inst in root:GetDescendants() do
                if isOther(inst) then
                    watch(inst)
                end
            end

            uiConns[#uiConns + 1] = root.DescendantAdded:Connect(function(inst)
                if isOther(inst) then
                    watch(inst)
                end
            end)
        end
    end

    local function restoreOtherUis()
        for i, conn in uiConns do
            conn:Disconnect()
        end

        table.clear(uiConns)

        starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        starterGui:SetCore("TopbarEnabled", true)

        for inst in hiddenUis do
            if inst.Parent then
                inst.Enabled = true
            end
        end

        table.clear(hiddenUis)
    end

    local dim = Instance.new("Frame")
    dim.Name = "Dim"
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 1
    dim.BorderSizePixel = 0
    dim.ZIndex = 1
    dim.Parent = bgGui

    local stripes = Instance.new("Frame")
    stripes.Name = "Stripes"
    stripes.Size = UDim2.fromScale(1, 1)
    stripes.BackgroundTransparency = 1
    stripes.BorderSizePixel = 0
    stripes.ZIndex = 2
    stripes.Parent = bgGui

    for i = 0, stripeFrames - 1 do
        local layer = Instance.new("Frame")
        layer.AnchorPoint = Vector2.new(0.5, 0.5)
        layer.Position = UDim2.fromScale(0.5, 0.5)
        layer.Size = UDim2.fromOffset(stripeSide, stripeSide)
        layer.BackgroundColor3 = colors.amber
        layer.BackgroundTransparency = 0.85
        layer.BorderSizePixel = 0
        layer.Parent = stripes

        local grad = Instance.new("UIGradient")
        grad.Rotation = -45
        grad.Transparency = stripeSeq(i)
        grad.Parent = layer

        stripeLayers[#stripeLayers + 1] = layer
        stripeGrads[#stripeGrads + 1] = grad
    end

    local dir = Vector2.new(math.cos(math.rad(-45)), math.sin(math.rad(-45)))
    local span = math.abs(dir.X) + math.abs(dir.Y)
    local stripeConn = run.RenderStepped:Connect(function(dt)
        stripePhase += dt * stripeScrollSpeed
        local off = dir * ((stripePhase % (1 / stripeTotal)) * span)

        for i, grad in stripeGrads do
            grad.Offset = off
        end
    end)

    task.spawn(function()
        if writefile and getcustomasset then
            if getcustomasset(config.logoFile) then
                weaopic = getcustomasset(config.logoFile)
            else
                writefile(config.logoFile, game:HttpGet(config.logoUrl))
                weaopic = getcustomasset(config.logoFile)
            end
        end

        if weaopic and logo then
            logo.Image = weaopic
        end
    end)

    local card = Instance.new("CanvasGroup")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.new(0.92, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = colors.cardBg
    card.BorderSizePixel = 0
    card.GroupTransparency = 1
    card.ZIndex = 2
    card.Parent = gui

    local cardSize = Instance.new("UISizeConstraint")
    cardSize.MaxSize = Vector2.new(400, math.huge)
    cardSize.Parent = card

    local scale = Instance.new("UIScale")
    scale.Scale = 0.85
    scale.Parent = card

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 18)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = colors.cardStroke
    cardStroke.Thickness = 1
    cardStroke.Transparency = 1
    cardStroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 26)
    pad.PaddingBottom = UDim.new(0, 22)
    pad.PaddingLeft = UDim.new(0, 24)
    pad.PaddingRight = UDim.new(0, 24)
    pad.Parent = card

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = card

    local function spacer(order, h)
        local s = Instance.new("Frame")
        s.LayoutOrder = order
        s.Size = UDim2.new(1, 0, 0, h)
        s.BackgroundTransparency = 1
        s.Parent = card
    end

    local badge = Instance.new("Frame")
    badge.LayoutOrder = 1
    badge.Size = UDim2.fromOffset(56, 56)
    badge.BackgroundColor3 = colors.badgeBg
    badge.BorderSizePixel = 0
    badge.Parent = card

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 15)
    badgeCorner.Parent = badge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = colors.badgeRing
    badgeStroke.Thickness = 1
    badgeStroke.Parent = badge

    local badgeIcon = Instance.new("ImageLabel")
    badgeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    badgeIcon.Position = UDim2.fromScale(0.5, 0.5)
    badgeIcon.Size = UDim2.fromOffset(28, 28)
    badgeIcon.BackgroundTransparency = 1
    applyIcon(badgeIcon, icon1, colors.amber)
    badgeIcon.Parent = badge

    spacer(2, 14)

    local title = Instance.new("TextLabel")
    title.LayoutOrder = 3
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Size = UDim2.new(1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.title
    title.TextColor3 = colors.title
    title.FontFace = font(Enum.FontWeight.Medium)
    title.TextSize = 21
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = card

    spacer(4, 8)

    local body = Instance.new("TextLabel")
    body.LayoutOrder = 5
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.Size = UDim2.new(0.9, 0, 0, 0)
    body.BackgroundTransparency = 1
    body.Text = config.body
    body.TextColor3 = colors.body
    body.FontFace = font(Enum.FontWeight.Regular)
    body.TextSize = 14
    body.LineHeight = 1.1
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.Parent = card

    spacer(6, 18)

    local inset = Instance.new("Frame")
    inset.LayoutOrder = 7
    inset.AutomaticSize = Enum.AutomaticSize.Y
    inset.Size = UDim2.new(1, 0, 0, 0)
    inset.BackgroundColor3 = colors.insetBg
    inset.BorderSizePixel = 0
    inset.Parent = card

    local insetCorner = Instance.new("UICorner")
    insetCorner.CornerRadius = UDim.new(0, 12)
    insetCorner.Parent = inset

    local insetStroke = Instance.new("UIStroke")
    insetStroke.Color = colors.insetStroke
    insetStroke.Thickness = 1
    insetStroke.Parent = inset

    local insetPad = Instance.new("UIPadding")
    insetPad.PaddingTop = UDim.new(0, 12)
    insetPad.PaddingBottom = UDim.new(0, 12)
    insetPad.PaddingLeft = UDim.new(0, 12)
    insetPad.PaddingRight = UDim.new(0, 12)
    insetPad.Parent = inset

    local insetList = Instance.new("UIListLayout")
    insetList.FillDirection = Enum.FillDirection.Horizontal
    insetList.VerticalAlignment = Enum.VerticalAlignment.Center
    insetList.SortOrder = Enum.SortOrder.LayoutOrder
    insetList.Padding = UDim.new(0, 12)
    insetList.Parent = inset

    local logoHolder = Instance.new("Frame")
    logoHolder.LayoutOrder = 1
    logoHolder.Size = UDim2.fromOffset(48, 48)
    logoHolder.BackgroundTransparency = 1
    logoHolder.BorderSizePixel = 0
    logoHolder.ClipsDescendants = false
    logoHolder.Parent = inset

    logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromScale(1.1, 1.1)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.5)
    logo.BackgroundTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Image = weaopic or ""
    logo.Parent = logoHolder

    local logoRounder = Instance.new("UICorner")
    logoRounder.CornerRadius = UDim.new(0, 12)
    logoRounder.Parent = logo

    if config.logoGradient then
        local logoStroke = Instance.new("UIStroke")
        logoStroke.Color = Color3.fromRGB(232, 154, 60)
        logoStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
        logoStroke.Thickness = 0.015
        logoStroke.Transparency = 0
        logoStroke.Parent = logo

        local logoGradient = Instance.new("UIGradient")
        logoGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.273, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.649, Color3.fromRGB(2, 8, 0)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(77, 255, 0)),
        })
        logoGradient.Rotation = 56
        logoGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.000, 0.400),
            NumberSequenceKeypoint.new(1.000, 0.400),
        })
        logoGradient.Parent = logoStroke
    end

    local textCol = Instance.new("Frame")
    textCol.LayoutOrder = 2
    textCol.AutomaticSize = Enum.AutomaticSize.Y
    textCol.Size = UDim2.new(1, -84, 0, 0)
    textCol.BackgroundTransparency = 1
    textCol.Parent = inset

    local textColList = Instance.new("UIListLayout")
    textColList.FillDirection = Enum.FillDirection.Vertical
    textColList.SortOrder = Enum.SortOrder.LayoutOrder
    textColList.Padding = UDim.new(0, 5)
    textColList.Parent = textCol

    local siteRow = Instance.new("Frame")
    siteRow.LayoutOrder = 1
    siteRow.AutomaticSize = Enum.AutomaticSize.Y
    siteRow.Size = UDim2.new(1, 0, 0, 0)
    siteRow.BackgroundTransparency = 1
    siteRow.Parent = textCol

    local siteRowList = Instance.new("UIListLayout")
    siteRowList.FillDirection = Enum.FillDirection.Horizontal
    siteRowList.VerticalAlignment = Enum.VerticalAlignment.Center
    siteRowList.SortOrder = Enum.SortOrder.LayoutOrder
    siteRowList.Padding = UDim.new(0, 8)
    siteRowList.Parent = siteRow

    local linkImg = Instance.new("ImageLabel")
    linkImg.LayoutOrder = 1
    linkImg.Size = UDim2.fromOffset(16, 16)
    linkImg.BackgroundTransparency = 1
    applyIcon(linkImg, icon2, colors.amber)
    linkImg.Parent = siteRow

    local siteLbl = Instance.new("TextLabel")
    siteLbl.LayoutOrder = 2
    siteLbl.AutomaticSize = Enum.AutomaticSize.XY
    siteLbl.BackgroundTransparency = 1
    siteLbl.RichText = true
    siteLbl.Text = "<u>" .. config.site .. "</u>"
    siteLbl.TextColor3 = colors.amber
    siteLbl.FontFace = font(Enum.FontWeight.Medium)
    siteLbl.TextSize = 14
    siteLbl.Parent = siteRow

    local note = Instance.new("TextLabel")
    note.LayoutOrder = 2
    note.AutomaticSize = Enum.AutomaticSize.Y
    note.Size = UDim2.new(.95, 0, 0, 0)
    note.BackgroundTransparency = 1
    note.Text = config.note
    note.TextColor3 = colors.caption
    note.FontFace = font(Enum.FontWeight.Regular)
    note.TextSize = 13
    note.TextWrapped = true
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = textCol

    spacer(8, 18)

    local btnRow = Instance.new("Frame")
    btnRow.LayoutOrder = 9
    btnRow.Size = UDim2.new(1, 0, 0, 44)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = card

    local btnRowList = Instance.new("UIListLayout")
    btnRowList.FillDirection = Enum.FillDirection.Horizontal
    btnRowList.VerticalAlignment = Enum.VerticalAlignment.Center
    btnRowList.SortOrder = Enum.SortOrder.LayoutOrder
    btnRowList.Padding = UDim.new(0, 10)
    btnRowList.Parent = btnRow

    local dismiss = Instance.new("TextButton")
    dismiss.LayoutOrder = 1
    dismiss.Size = UDim2.new(1, 0, 1, 0)
    dismiss.AutoButtonColor = false
    dismiss.BackgroundColor3 = colors.ghostIdle
    dismiss.BackgroundTransparency = 0
    dismiss.Text = config.secondary
    dismiss.TextColor3 = colors.ghostText
    dismiss.FontFace = font(Enum.FontWeight.Medium)
    dismiss.TextSize = 14
    dismiss.Parent = btnRow

    local dismissCorner = Instance.new("UICorner")
    dismissCorner.CornerRadius = UDim.new(0, 11)
    dismissCorner.Parent = dismiss

    local dismissStroke = Instance.new("UIStroke")
    dismissStroke.Color = colors.ghostStroke
    dismissStroke.Thickness = 1
    dismissStroke.Parent = dismiss

    local primary = Instance.new("TextButton")
    primary.LayoutOrder = 2
    primary.Size = UDim2.new(0, 0, 1, 0)
    primary.AutoButtonColor = false
    primary.BackgroundColor3 = colors.primary
    primary.BackgroundTransparency = 1
    primary.ClipsDescendants = true
    primary.Visible = false
    primary.Text = ""
    primary.Parent = btnRow

    local primaryScale = Instance.new("UIScale")
    primaryScale.Scale = 0.9
    primaryScale.Parent = primary

    local primaryCorner = Instance.new("UICorner")
    primaryCorner.CornerRadius = UDim.new(0, 11)
    primaryCorner.Parent = primary

    local primaryList = Instance.new("UIListLayout")
    primaryList.FillDirection = Enum.FillDirection.Horizontal
    primaryList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    primaryList.VerticalAlignment = Enum.VerticalAlignment.Center
    primaryList.SortOrder = Enum.SortOrder.LayoutOrder
    primaryList.Padding = UDim.new(0, 6)
    primaryList.Parent = primary

    local primaryLbl = Instance.new("TextLabel")
    primaryLbl.LayoutOrder = 1
    primaryLbl.AutomaticSize = Enum.AutomaticSize.XY
    primaryLbl.BackgroundTransparency = 1
    primaryLbl.Text = config.primary
    primaryLbl.TextColor3 = colors.primaryText
    primaryLbl.TextTransparency = 1
    primaryLbl.FontFace = font(Enum.FontWeight.Medium)
    primaryLbl.TextSize = 14
    primaryLbl.Parent = primary

    local primaryIcon = Instance.new("ImageLabel")
    primaryIcon.LayoutOrder = 2
    primaryIcon.Size = UDim2.fromOffset(15, 15)
    primaryIcon.BackgroundTransparency = 1
    primaryIcon.ImageTransparency = 1
    applyIcon(primaryIcon, icon3, colors.primaryText)
    primaryIcon.Parent = primary

    local function showCopied()
        setclipboard(config.site)

        local lx = linkImg.AbsoluteSize.X + siteRowList.Padding.Offset + siteLbl.AbsoluteSize.X + 10

        local toast = Instance.new("TextLabel")
        toast.AnchorPoint = Vector2.new(0, 0.5)
        toast.Position = UDim2.new(0, lx, 0.5, 0--[[4]])
        toast.Size = UDim2.fromOffset(70, 18)
        toast.BackgroundTransparency = 1
        toast.Text = "Copied!"
        toast.TextColor3 = Color3.fromRGB(220, 225, 235)
        toast.TextTransparency = 1
        toast.FontFace = font(Enum.FontWeight.Medium)
        toast.TextSize = 13
        toast.TextXAlignment = Enum.TextXAlignment.Left
        toast.ZIndex = 10
        toast.Parent = linkImg

        tween(toast, 0.35, {--[[Position = UDim2.new(0, lx, 0.5, 0),]] TextTransparency = 0.3})

        task.delay(1.15, function()
            if closed then
                return
            end

            tween(toast, 0.35, {Position = UDim2.new(0, lx, 0.5, -4), TextTransparency = 1})
            task.delay(0.36, function() toast:Destroy() end)
        end)
    end

    siteRow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            showCopied()
        end
    end)

    dismiss.MouseEnter:Connect(function() tween(dismiss, 0.12, {BackgroundColor3 = colors.ghostHover}) end)
    dismiss.MouseLeave:Connect(function() tween(dismiss, 0.12, {BackgroundColor3 = colors.ghostIdle}) end)
    primary.MouseEnter:Connect(function() tween(primary, 0.12, {BackgroundColor3 = colors.primaryHover}) end)
    primary.MouseLeave:Connect(function() tween(primary, 0.12, {BackgroundColor3 = colors.primary}) end)

    local function close(reason)
        if closed then
            return
        end

        result = reason

        if ident then
            setidentity(ident)
        end

        closed = true
        stripeConn:Disconnect()

        if config.hideOtherUis then
            restoreOtherUis()
        end

        tween(dim, 0.16, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(card, 0.16, {GroupTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(cardStroke, 0.16, {Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(scale, 0.16, {Scale = 0.92}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(cam, 0.16, {FieldOfView = baseFov}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(blur, 0.16, {Size = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        for i, layer in stripeLayers do
            tween(layer, 0.16, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        end

        task.delay(0.18, function()
            gui:Destroy()
            bgGui:Destroy()
            blur:Destroy()
        end)
    end

    local function openInvite()
        if not request then
            return
        end

        local body = '{"cmd":"INVITE_BROWSER","args":{"code":"' .. config.invite .. '"},"nonce":"' .. tostring(math.random()) .. '"}'

        for port = 6463, 6472 do -- thanks claude for port list
            local s, res = pcall(request, {
                Url = "http://127.0.0.1:" .. port .. "/rpc?v=1",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com",
                },
                Body = body,
            })

            if s and res and res.StatusCode and res.StatusCode < 400 then
                return
            end
        end
    end

    dismiss.Activated:Connect(function() close("secondary") end)
    primary.Activated:Connect(function()
        task.spawn(openInvite)
        close("primary")
    end)

    local function dowehavediscord()
        if not request then
            return false
        end

        for port = 6463, 6472 do -- thanks claude for port list
            local s, res = pcall(request, {
                Url = "http://127.0.0.1:" .. port .. "/rpc?v=1",
                Method = "GET",
                Headers = {["Origin"] = "https://discord.com"},
            })

            if s and res and res.StatusCode then
                return true
            end
        end

        return false
    end

    local function revealPrimary()
        primary.Visible = true
        tween(dismiss, 0.32, {Size = UDim2.new(0.36, -5, 1, 0)})
        tween(primary, 0.32, {Size = UDim2.new(0.64, -5, 1, 0)})

        task.delay(0.14, function()
            tween(primary, 0.3, {BackgroundTransparency = 0})
            tween(primaryLbl, 0.3, {TextTransparency = 0})
            tween(primaryIcon, 0.3, {ImageTransparency = 0})
            tween(primaryScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end

    -- no invite => no primary button, so don't even bother probing for discord
    if config.invite then
        task.spawn(function()
            local up = dowehavediscord()

            if up and not closed then
                revealPrimary()
            end
        end)
    end

    if config.hideOtherUis then
        hideOtherUis()
    end

    tween(dim, 0.2, {BackgroundTransparency = 0.5})
    tween(card, 0.22, {GroupTransparency = 0})
    tween(cardStroke, 0.22, {Transparency = 0})
    tween(scale, 0.5, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(blur, 0.2, {Size = 15})
    tween(cam, 0.22, {FieldOfView = baseFov - 20})

    if config.yields then
        repeat task.wait() until closed
        return result
    end

    return {
        close = close,
        config = config,
        gui = gui,
        bgGui = bgGui,
    }
end
