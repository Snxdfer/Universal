local SCRIPT_NAME = "AnimationDumper"
local SCRIPT_VERSION = {
    -- Semantic Versioning
    Major = 1;
    Minor = 1;
    Patch = 1;
}

local genv = getgenv()

if not BetterLib then
    local OldGet = game.HttpGet or game.HttpGetAsync or nil
    assert(OldGet, "No HttpGet function found.")
    -- Load BetterLib first (if it's not already loaded), since every other loaded stuff will depend on it. If BetterLib fails to load, everything else won't work, but at least the error will be more informative.
    loadstring(OldGet(game, "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/Dependencies/BetterLib.lua", true))()
end
-- Begin Script:

-- Load Dependencies:

if not Iris then
    local IrisLoaderUrl = "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/Dependencies/Iris/loader.lua"
    genv.Iris = loadstring(Get(IrisLoaderUrl))()
end

-- Loaded Dependencies!

-- Generic Helpers
genv.CountList = genv.CountList or function(list): number
    local count = 0
    for _, _ in pairs(list) do
        count += 1
    end
    return count
end

function genv.FormatHours(seconds: number): string
    seconds = math.max(0, math.floor(seconds)) -- clamp + remove decimals

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function genv.FormatMinutes(seconds: number): string
    seconds = math.max(0, math.floor(seconds))
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

function genv.FormatSemVer(versionTable: { Major: number?, Minor: number?, Patch: number? }): string
    assert(type(versionTable) == "table", "FormatSemVer expects a table")

    local major = versionTable.Major or 0
    local minor = versionTable.Minor or 0
    local patch = versionTable.Patch or 0

    return string.format("%d.%d.%d", major, minor, patch)
end
local ver = FormatSemVer(SCRIPT_VERSION)

-- Setup executor workspace file directory for saving configs and settings:

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SCRIPT_DIRECTORY_PATH = nil
local CONFIG_DIRECTORY_PATH = nil
local DUMP_DIRECTORY_PATH = nil
if EXECUTOR_FILING_ENABLED then
    SCRIPT_DIRECTORY_PATH = SCRIPT_NAME .. "_" .. ver
    makefolder(SCRIPT_DIRECTORY_PATH)
    CONFIG_DIRECTORY_PATH = SCRIPT_DIRECTORY_PATH .. "/Configs"
    makefolder(CONFIG_DIRECTORY_PATH)
    DUMP_DIRECTORY_PATH = SCRIPT_DIRECTORY_PATH .. "/Dumps"
    makefolder(DUMP_DIRECTORY_PATH)
end

-- Done setting up file directory!

-- External States
local showMainWindow = Iris.State(true)
local showRuntimeInfo = Iris.State(false)
local showStyleEditor = Iris.State(false)
local showDebugWindow = Iris.State(false)

local Config = {}
genv.Config = Config

function getIrisStatesRecursively(IrisTable)
    local configTable = {}
    for index, value in pairs(IrisTable) do
        if type(value) == "table" and type(value.get) == "function" and type(value.set) == "function" then
            local got = value:get()
            if type(got) == "table" then
                local temp = deepCopy(got)
                temp.IS_IRIS_TABLE_STATE = true
                configTable[index] = temp
            else
                configTable[index] = got
            end
        elseif type(value) == "table" then
            configTable[index] = getIrisStatesRecursively(value)
        end
    end
    return configTable
end

local function SaveIrisConfig(path: string)
    if not EXECUTOR_FILING_ENABLED then
        -- warn("Cannot save config, executor does not support file functions.")
        return
    end

    local ConfigTable = getIrisStatesRecursively(Config)
    if not ConfigTable then
        -- warn("Failed to get config table.")
        return
    end
    local success, err = pcall(function()
        ConfigLibrary:SaveConfig(path, ConfigTable)
    end)
    if not success and err then
        -- warn("Error saving config: " .. tostring(err))
    end
end

function setIrisStatesRecursively(IrisTable, Overwrite)
    for index, ovalue in pairs(Overwrite) do
        if ovalue == nil then
            -- warn("What? This shouldn't be happening... Config value for " .. index .. " is nil, skipping this setting to avoid breaking it.")
            continue
        end
        if index == "IS_IRIS_TABLE_STATE" then
            continue
        end

        local value = IrisTable[index]
        if value == nil then
            -- State doesn't exist in current config, add it in so it doesn't get lost when saving/loading configs that don't have newer settings
            if type(ovalue) == "table" then
                local temp = deepCopy(ovalue)
                temp.IS_IRIS_TABLE_STATE = nil
                if ovalue.IS_IRIS_TABLE_STATE == true then
                    IrisTable[index] = Iris.State(temp)
                else
                    IrisTable[index] = {}
                    setIrisStatesRecursively(IrisTable[index], temp)
                end
            else
                IrisTable[index] = Iris.State(ovalue)
            end
        elseif type(value) == "table" then
            -- all states are tables, but not all tables are states, so we have to check if it is a state or just a regular table
            -- State exists in current config, just update the value so it gets saved in the config file. This also allows for loading older configs that don't have newer settings without breaking them by removing those settings, since it will just keep the current value for those settings instead of trying to set them to nil or something.

            if (type(value.get) == "function" and type(value.set) == "function") then
                -- is a state table, so we can just set the value
                local got = value:get()
                if got and type(got) == "table" then
                    local temp = deepCopy(ovalue)
                    temp.IS_IRIS_TABLE_STATE = nil
                    IrisTable[index]:set(temp)
                else
                    IrisTable[index]:set(ovalue)
                end
            else
                -- is table but not state, so we have to go deeper
                if type(ovalue) == "table" then
                    local temp = deepCopy(ovalue)
                    temp.IS_IRIS_TABLE_STATE = nil
                    if ovalue.IS_IRIS_TABLE_STATE == true then
                        IrisTable[index] = Iris.State(temp)
                    else
                        IrisTable[index] = {}
                        setIrisStatesRecursively(IrisTable[index], temp)
                    end
                else
                    -- warn("Config value for " .. index .. " is not a table, but the current config value is a table. Skipping this setting to avoid breaking it.")
                end
            end
        end
    end
    return true
end

local function LoadIrisConfig(path: string)
    if not EXECUTOR_FILING_ENABLED then
        -- warn("Cannot load config, executor does not support file functions.")
        return
    end

    local ConfigTable = nil
    local success, err = pcall(function()
        ConfigTable = ConfigLibrary:LoadConfig(path)
    end)
    if not success and err then
        -- warn("Error loading config: " .. tostring(err))
    elseif success then
        -- Apply loaded config to current state
        local applySuccess, applyErr = pcall(function()
            setIrisStatesRecursively(Config, ConfigTable)
        end)
        if not applySuccess and applyErr then
            -- warn("Error applying config: " .. tostring(applyErr))
        end
    end
end

local DefaultConfig = {
    ["showBackground"] = false;
    ["backgroundColor"] = Color3.fromRGB(115, 140, 152);
    ["backgroundTransparency"] = 0;
    --Referring to Iris' GlobalConfig:
    ["IrisSizingConfig"] = {
        IS_IRIS_TABLE_STATE = true;
    };
    ["IrisColorsConfig"] = {
        IS_IRIS_TABLE_STATE = true;
    };
    ["IrisFontsConfig"] = {
        IS_IRIS_TABLE_STATE = true;
    };

    ["windowKeyCode"] = {
        IS_IRIS_TABLE_STATE = true;
        "F3"
    };
}

setIrisStatesRecursively(Config, DefaultConfig)

-- Iris Init
table.insert(Iris.Internal._initFunctions, function()
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Config.backgroundColor:get()
    background.BackgroundTransparency = Config.backgroundTransparency:get()

    local widget
    if Iris._config.UseScreenGUIs then
        widget = Instance.new("ScreenGui")
        widget.Name = "Iris_Background"
        widget.IgnoreGuiInset = true
        widget.DisplayOrder = Iris._config.DisplayOrderOffset - 1
        widget.ScreenInsets = Enum.ScreenInsets.None
        widget.Enabled = true

        background.Parent = widget
    else
        background.ZIndex = Iris._config.DisplayOrderOffset - 1
        widget = background
    end

    Config.backgroundColor:onChange(function(value: Color3)
        background.BackgroundColor3 = value
    end)
    Config.backgroundTransparency:onChange(function(value: number)
        background.BackgroundTransparency = value
    end)

    Config.showBackground:onChange(function(show: boolean)
        if show then
            widget.Parent = Iris.Internal.parentInstance
        else
            widget.Parent = nil
        end
    end)
end)

-- Iris Helpers
local function helpMarker(helpText: string)
    Iris.PushConfig({ TextColor = Iris._config.TextDisabledColor })
    local text = Iris.Text({ "(?)" })
    Iris.PopConfig()

    Iris.PushConfig({ ContentWidth = UDim.new(0, 350) })
    if text.hovered() then
        Iris.Tooltip({ helpText })
    end
    Iris.PopConfig()
end

local function textAndHelpMarker(text: string, helpText: string)
    Iris.SameLine()
    do
        Iris.Text({ text })
        helpMarker(helpText)
    end
    Iris.End()
end

local waiting = nil
local function keybindButton(state: {[number]: string?}, index: number)
    -- the button has a clicked event, returning true when it is pressed
    local keybindingArray = state:get()
    local currentKeyCodeName = keybindingArray and index and keybindingArray[index] or nil
    if currentKeyCodeName == nil or currentKeyCodeName == "" then
        currentKeyCodeName = "None"
    end
    if Iris.Button({currentKeyCodeName}).clicked() then
        -- run code if we click the button
        if not waiting then
            waiting = {}

            -- Disconnect helper
            local function stopWaiting()
                if waiting.began and waiting.began.Connected then waiting.began:Disconnect() end
                if waiting.changed and waiting.changed.Connected then waiting.changed:Disconnect() end
                waiting = nil
            end

            -- Handle normal buttons (keyboard, mouse, gamepad buttons)
            waiting.began = UserInputService.InputBegan:Connect(function(input)
                local code = input.KeyCode
                local name = code and code.Name or nil

                if not name then return end

                -- Reject unusable keys
                if name == "Unknown" or name == "Escape" or name == "Return" then
                    name = ""
                end

                -- Reject thumbstick clicks (we only want directions)
                if name == "Thumbstick1" or name == "Thumbstick2" then
                    -- ignore here; handled in InputChanged
                    return
                end

                -- Save keybind
                if name ~= currentKeyCodeName then
                    local array = state:get() or {}
                    array[index] = name
                    state:set(array)
                end

                stopWaiting()
            end)

            -- Handle thumbstick movement
            waiting.changed = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Gamepad1 then return end

                local code = input.KeyCode
                if code ~= Enum.KeyCode.Thumbstick1 and code ~= Enum.KeyCode.Thumbstick2 then
                    return
                end

                local vec = input.Position
                local x, y = vec.X, vec.Y
                local deadzone = 0.4

                -- Deadzone
                if math.abs(x) < deadzone and math.abs(y) < deadzone then
                    return
                end

                local base = code.Name
                local direction = nil

                -- Determine direction
                if math.abs(x) > math.abs(y) then
                    if x > deadzone then direction = "Right"
                    elseif x < -deadzone then direction = "Left" end
                else
                    if y > deadzone then direction = "Up"
                    elseif y < -deadzone then direction = "Down" end
                end

                if not direction then return end

                local finalName = base .. direction

                -- Save keybind
                if finalName ~= currentKeyCodeName then
                    local array = state:get() or {}
                    array[index] = finalName
                    state:set(array)
                end

                stopWaiting()
            end)
        end
    end
end
local function keybindWidget(text: string, state)
    Iris.SameLine()
    do
        Iris.Text({ text })
        local addButton = Iris.Button({ "+" })
        Iris.Text({ "|" })
        local subtractButton = Iris.Button({ "-" })
        if addButton.clicked() then
            -- add a new keybind to the array
            local array = state:get() or {}
            table.insert(array, "None") -- default value for new keybinds
            state:set(array)
        elseif subtractButton.clicked() then
            -- remove the last keybind from the array
            local array = state:get() or {}
            if #array > 0 then
                table.remove(array, #array)
            end
            state:set(array)
        end
    end
    Iris.End()

    local keybindsTree = Iris.Tree({"Keybind(s)"})
    do
        if keybindsTree.state.isUncollapsed:get() then
            -- Keybind content would go here
            local array = state:get()
            if array and type(array) == "table" then
                for i: number = 1, #array, 1 do
                    keybindButton(state, i)
                end
            end
        end
    end
    Iris.End()
end

local function color4Picker(text: string, colorState, transparencyState)
    local ColorPicker = Iris.InputColor4({"Color"}, {
        color = Iris.WeakState(colorState:get());
        transparency = Iris.WeakState(transparencyState:get());
    })
    ColorPicker.state.color:set(colorState:get())
    ColorPicker.state.transparency:set(transparencyState:get())
    if ColorPicker.numberChanged() then
        colorState:set(ColorPicker.state.color:get())
        transparencyState:set(ColorPicker.state.transparency:get())
    end
end

-- shows list of runtime widgets and states, including IDs. shows other info about runtime and can show widgets/state info in depth.
local function runtimeInfo()
    local runtimeInfoWindow = Iris.Window({ "Runtime Info" }, { isOpened = showRuntimeInfo })
    do
        local lastVDOM = Iris.Internal._lastVDOM
        local states = Iris.Internal._states

        local numSecondsDisabled = Iris.State(3)
        local rollingDT = Iris.State(0)
        local lastT = Iris.State(os.clock())

        Iris.SameLine()
        do
            Iris.InputNum({ [Iris.Args.InputNum.Text] = "", [Iris.Args.InputNum.Format] = "%d Seconds", [Iris.Args.InputNum.Max] = 10 }, { number = numSecondsDisabled })
            if Iris.Button({ "Disable" }).clicked() then
                Iris.Disabled = true
                task.delay(numSecondsDisabled:get(), function()
                    Iris.Disabled = false
                end)
            end
        end
        Iris.End()

        local t = os.clock()
        local dt = t - lastT.value
        rollingDT.value += (dt - rollingDT.value) * 0.2
        lastT.value = t
        Iris.Text({ string.format("Average %.3f ms/frame (%.1f FPS)", rollingDT.value * 1000, 1 / rollingDT.value) })

        Iris.Text({
            string.format("Window Position: (%d, %d), Window Size: (%d, %d)", runtimeInfoWindow.position.value.X, runtimeInfoWindow.position.value.Y, runtimeInfoWindow.size.value.X, runtimeInfoWindow.size.value.Y),
        })
    end
    Iris.End()
end

local function debugPanel()
    Iris.Window({ "Debug Panel" }, { isOpened = showDebugWindow })
    do
        Iris.CollapsingHeader({ "Widgets" })
        do
            Iris.SeparatorText({ "GuiService" })
            Iris.Text({ `GuiOffset: {Iris.Internal._utility.GuiOffset}` })
            Iris.Text({ `MouseOffset: {Iris.Internal._utility.MouseOffset}` })

            Iris.SeparatorText({ "UserInputService" })
            Iris.Text({ `MousePosition: {Iris.Internal._utility.UserInputService:GetMouseLocation()}` })
            Iris.Text({ `MouseLocation: {Iris.Internal._utility.getMouseLocation()}` })

            Iris.Text({ `Left Control: {Iris.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)}` })
            Iris.Text({ `Right Control: {Iris.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)}` })
        end
        Iris.End()
    end
    Iris.End()
end

local choosingConfig_open = Iris.State(false);
local choosingConfig_save = Iris.State(false);
local typingCustomConfig_save = Iris.State(false);

local function mainMenuBar()
    Iris.MenuBar()
    do
        Iris.Menu({ "Configs" })
        do
            local newMenuItem = Iris.MenuItem({ "New" })
            if newMenuItem.clicked() then
                setIrisStatesRecursively(Config, DefaultConfig)
            end
            if EXECUTOR_FILING_ENABLED then
                local openMenuItem = Iris.MenuItem({ "Open" })
                local saveMenuItem = Iris.MenuItem({ "Save" })
                if not choosingConfig_open:get() and not choosingConfig_save:get() and not typingCustomConfig_save:get() then
                    if openMenuItem.clicked() then
                        choosingConfig_open:set(true)
                    elseif saveMenuItem.clicked() then
                        choosingConfig_save:set(true)
                    end
                end
            else
                Iris.Text({ "Config saving/loading is not supported in this executor." })
            end
        end
        Iris.End()

        Iris.Menu({ "Tools" })
        do
            Iris.MenuToggle({ "Runtime Info" }, { isChecked = showRuntimeInfo })
            Iris.MenuToggle({ "Style Editor" }, { isChecked = showStyleEditor })
            Iris.MenuToggle({ "Debug Panel" }, { isChecked = showDebugWindow })
        end
        Iris.End()
    end
    Iris.End()
end

-- allows users to edit state
local styleEditor
do
    styleEditor = function()
        local styleList = {
            {
                "Sizing",
                function()
                    Iris.SameLine()
                    do
                        if Iris.Button({ "Update" }).clicked() then
                            Iris.UpdateGlobalConfig(Config.IrisSizingConfig.value)
                            Config.IrisSizingConfig:set({})
                        end

                        helpMarker("Update the global config with these changes.")
                    end
                    Iris.End()

                    local function SliderInput(input: string, arguments: { any })
                        local Input = Iris[input](arguments, { number = Iris.WeakState(Iris._config[arguments[1]]) })
                        if Input.numberChanged() then
                            Config.IrisSizingConfig.value[arguments[1]] = Input.number:get()
                        end
                    end

                    local function BooleanInput(arguments: { any })
                        local Input = Iris.Checkbox(arguments, { isChecked = Iris.WeakState(Iris._config[arguments[1]]) })
                        if Input.checked() or Input.unchecked() then
                            Config.IrisSizingConfig.value[arguments[1]] = Input.isChecked:get()
                        end
                    end

                    Iris.SeparatorText({ "Main" })
                    SliderInput("SliderVector2", { "WindowPadding", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "WindowResizePadding", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "FramePadding", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "ItemSpacing", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "ItemInnerSpacing", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "CellPadding", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderNum", { "IndentSpacing", 1, 0, 36 })
                    SliderInput("SliderNum", { "ScrollbarSize", 1, 0, 20 })
                    SliderInput("SliderNum", { "GrabMinSize", 1, 0, 20 })

                    Iris.SeparatorText({ "Borders & Rounding" })
                    SliderInput("SliderNum", { "FrameBorderSize", 0.1, 0, 1 })
                    SliderInput("SliderNum", { "WindowBorderSize", 0.1, 0, 1 })
                    SliderInput("SliderNum", { "PopupBorderSize", 0.1, 0, 1 })
                    SliderInput("SliderNum", { "SeparatorTextBorderSize", 1, 0, 20 })
                    SliderInput("SliderNum", { "FrameRounding", 1, 0, 12 })
                    SliderInput("SliderNum", { "GrabRounding", 1, 0, 12 })
                    SliderInput("SliderNum", { "PopupRounding", 1, 0, 12 })

                    Iris.SeparatorText({ "Widgets" })
                    SliderInput("SliderVector2", { "DisplaySafeAreaPadding", nil, Vector2.zero, Vector2.new(20, 20) })
                    SliderInput("SliderVector2", { "SeparatorTextPadding", nil, Vector2.zero, Vector2.new(36, 36) })
                    SliderInput("SliderUDim", { "ItemWidth", nil, UDim.new(), UDim.new(1, 200) })
                    SliderInput("SliderUDim", { "ContentWidth", nil, UDim.new(), UDim.new(1, 200) })
                    SliderInput("SliderNum", { "ImageBorderSize", 1, 0, 12 })
                    local TitleInput = Iris.ComboEnum({ "WindowTitleAlign" }, { index = Iris.WeakState(Iris._config.WindowTitleAlign) }, Enum.LeftRight)
                    if TitleInput.closed() then
                        Config.IrisSizingConfig.value["WindowTitleAlign"] = TitleInput.index:get()
                    end
                    BooleanInput({ "RichText" })
                    BooleanInput({ "TextWrapped" })

                    Iris.SeparatorText({ "Config" })
                    BooleanInput({ "UseScreenGUIs" })
                    SliderInput("DragNum", { "DisplayOrderOffset", 1, 0 })
                    SliderInput("DragNum", { "ZIndexOffset", 1, 0 })
                    SliderInput("SliderNum", { "MouseDoubleClickTime", 0.1, 0, 5 })
                    SliderInput("SliderNum", { "MouseDoubleClickMaxDist", 0.1, 0, 20 })
                end,
            },
            {
                "Colors",
                function()
                    Iris.SameLine()
                    do
                        if Iris.Button({ "Update" }).clicked() then
                            Iris.UpdateGlobalConfig(Config.IrisColorsConfig.value)
                            Config.IrisColorsConfig:set({})
                        end
                        helpMarker("Update the global config with these changes.")
                    end
                    Iris.End()

                    local color4s = {
                        "Text",
                        "TextDisabled",
                        "WindowBg",
                        "PopupBg",
                        "Border",
                        "BorderActive",
                        "ScrollbarGrab",
                        "TitleBg",
                        "TitleBgActive",
                        "TitleBgCollapsed",
                        "MenubarBg",
                        "FrameBg",
                        "FrameBgHovered",
                        "FrameBgActive",
                        "Button",
                        "ButtonHovered",
                        "ButtonActive",
                        "Image",
                        "SliderGrab",
                        "SliderGrabActive",
                        "Header",
                        "HeaderHovered",
                        "HeaderActive",
                        "SelectionImageObject",
                        "SelectionImageObjectBorder",
                        "TableBorderStrong",
                        "TableBorderLight",
                        "TableRowBg",
                        "TableRowBgAlt",
                        "NavWindowingHighlight",
                        "NavWindowingDimBg",
                        "Separator",
                        "CheckMark",
                    }

                    for _, vColor in color4s do
                        local Input = Iris.InputColor4({ vColor }, {
                            color = Iris.WeakState(Iris._config[vColor .. "Color"]),
                            transparency = Iris.WeakState(Iris._config[vColor .. "Transparency"]),
                        })
                        if Input.numberChanged() then
                            Config.IrisColorsConfig.value[vColor .. "Color"] = Input.color:get()
                            Config.IrisColorsConfig.value[vColor .. "Transparency"] = Input.transparency:get()
                        end
                    end
                end,
            },
            {
                "Fonts",
                function()
                    Iris.SameLine()
                    do
                        if Iris.Button({ "Update" }).clicked() then
                            Iris.UpdateGlobalConfig(Config.IrisFontsConfig.value)
                            Config.IrisFontsConfig:set({})
                        end

                        helpMarker("Update the global config with these changes.")
                    end
                    Iris.End()

                    local fonts: { [string]: Font } = {
                        ["Code (default)"] = Font.fromEnum(Enum.Font.Code),
                        ["Ubuntu (template)"] = Font.fromEnum(Enum.Font.Ubuntu),
                        ["Arial"] = Font.fromEnum(Enum.Font.Arial),
                        ["Highway"] = Font.fromEnum(Enum.Font.Highway),
                        ["Roboto"] = Font.fromEnum(Enum.Font.Roboto),
                        ["Roboto Mono"] = Font.fromEnum(Enum.Font.RobotoMono),
                        ["Noto Sans"] = Font.new("rbxassetid://12187370747"),
                        ["Builder Sans"] = Font.fromEnum(Enum.Font.BuilderSans),
                        ["Builder Mono"] = Font.new("rbxassetid://16658246179"),
                        ["Sono"] = Font.new("rbxassetid://12187374537"),
                    }

                    Iris.Text({ `Current Font: {Iris._config.TextFont.Family} Weight: {Iris._config.TextFont.Weight} Style: {Iris._config.TextFont.Style}` })
                    Iris.SeparatorText({ "Size" })

                    local TextSize = Iris.SliderNum({ "Font Size", 1, 4, 20 }, { number = Iris.WeakState(Iris._config.TextSize) })
                    if TextSize.numberChanged() then
                        Config.IrisFontsConfig.value["TextSize"] = TextSize.state.number:get()
                    end

                    Iris.SeparatorText({ "Properties" })

                    local TextFont = Iris.WeakState(Iris._config.TextFont.Family)
                    local FontWeight = Iris.ComboEnum({ "Font Weight" }, { index = Iris.WeakState(Iris._config.TextFont.Weight) }, Enum.FontWeight)
                    local FontStyle = Iris.ComboEnum({ "Font Style" }, { index = Iris.WeakState(Iris._config.TextFont.Style) }, Enum.FontStyle)

                    Iris.SeparatorText({ "Fonts" })
                    for name, font in fonts do
                        font = Font.new(font.Family, FontWeight.state.index.value, FontStyle.state.index.value)
                        Iris.SameLine()
                        do
                            Iris.PushConfig({
                                TextFont = font,
                            })

                            if Iris.Selectable({ `{name} | "The quick brown fox jumps over the lazy dog."`, font.Family }, { index = TextFont }).selected() then
                                Config.IrisFontsConfig.value["TextFont"] = font
                            end
                            Iris.PopConfig()
                        end
                        Iris.End()
                    end
                end,
            },
        }

        Iris.Window({ "Style Editor" }, { isOpened = showStyleEditor })
        do
            Iris.Text({ "Customize the look of Iris in realtime." })

            local ThemeState = Iris.State("Dark Theme")
            if Iris.ComboArray({ "Theme" }, { index = ThemeState }, { "Dark Theme", "Light Theme" }).closed() then
                if ThemeState.value == "Dark Theme" then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                elseif ThemeState.value == "Light Theme" then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
                end
            end

            local SizeState = Iris.State("Classic Size")
            if Iris.ComboArray({ "Size" }, { index = SizeState }, { "Classic Size", "Larger Size" }).closed() then
                if SizeState.value == "Classic Size" then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                elseif SizeState.value == "Larger Size" then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
                end
            end

            Iris.SameLine()
            do
                if Iris.Button({ "Revert" }).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                    ThemeState:set("Dark Theme")
                    SizeState:set("Classic Size")
                end

                helpMarker("Reset Iris to the default theme and size.")
            end
            Iris.End()

            Iris.TabBar()
            do
                for i, v in ipairs(styleList) do
                    Iris.Tab({ v[1] })
                    do
                        styleList[i][2]()
                    end
                    Iris.End()
                end
            end
            Iris.End()

            Iris.Separator()
        end
        Iris.End()
    end
end

saveinstance = (function()
    if game:GetService("RunService"):IsStudio() then return function() error("Cannot run in Roblox Studio!") end end
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
        SSI = "saveinstance",
    }
    local synsaveinstance = loadstring(Get(Params.RepoURL .. Params.SSI .. ".luau"), Params.SSI)()

    local function wrappedsaveinstance(obj, filepath, options)
        options["FilePath"] = filepath
        --options["ReadMe"] = false
        options["Object"] = obj
        return synsaveinstance(options)
    end

    genv.saveinstance = wrappedsaveinstance
    return wrappedsaveinstance
end)()

local MarketplaceService = game:GetService("MarketplaceService")

local function getAnimationName(animationId: number): string
    local success, info = pcall(function()
        -- Get product info for the current place
        return MarketplaceService:GetProductInfoAsync(animationId, Enum.InfoType.Asset)
    end)

    if success and info and info.Name then
        return info.Name
    else
        -- warn("Failed to get animation name:", info)
        return "UnknownAnimation"
    end
end

local function extractId(str: string): string?
    local sub = str:match("%d+")
    if sub then
        return sub
    else
        -- warn("Failed to extract ID from string:", str)
        return nil
    end
end

local sequenceProvider = game:GetService("KeyframeSequenceProvider")

local OutputModel = Instance.new("Model")
OutputModel.Name = "Stolen Animations"
if script and script.Parent then
    OutputModel.Parent = script
end

local animMap = {}
local infoMap = {}
local mapCounter = 0
local dumpThread: thread? = nil
local startedTime = nil
local lastUpdatedTime = nil
local function stopDumping(): ()
    if dumpThread and coroutine.status(dumpThread) ~= "dead" then
        task.cancel(dumpThread)
        dumpThread = nil
    else
        -- warn("Not currently dumping animations!")
    end
end
local function startDumping(): ()
    if dumpThread and coroutine.status(dumpThread) ~= "dead" then
        -- warn("Already dumping animations!")
        return
    end

    startedTime = os.time()
    lastUpdatedTime = os.time()

    dumpThread = task.spawn(function()
        while true do
            lastUpdatedTime = os.time()
            local Animators = workspace:QueryDescendants("Animator")
            for _, v: Animator in ipairs(Animators) do
                if v and v:IsA("Animator") then
                    local model = v:FindFirstAncestorOfClass("Model")
                    local modelName = "Unknown"
                    if model then
                        modelName = model.Name
                    end
                    if Players:GetPlayerFromCharacter(model) then
                        modelName = "Player"
                    end

                    local tracks: {[number]: AnimationTrack} = v:GetPlayingAnimationTracks()
                    if #tracks > 0 then
                        for i: number, track: AnimationTrack in ipairs(tracks) do
                            local animId = track.Animation and track.Animation.AnimationId or nil
                            if not animId then continue end
                            local extractedAnimId: string? = extractId(animId)
                            if not extractedAnimId then continue end
                            local entry = {
                                id = extractedAnimId;
                            }
                            if not animMap[extractedAnimId] then
                                local assetName: string = getAnimationName(tonumber(extractedAnimId))
                                entry.animation = "Model:"..modelName.."_Index:"..tostring(i).."_AssetName:"..assetName.."_AnimationName:"..track.Animation.Name.."_TrackName:"..track.Name;
                                local ks: KeyframeSequence = sequenceProvider:GetKeyframeSequenceAsync(animId)
                                entry.sequence = ks
                                entry.output = ks
                                if ks then
                                    if not ks.Parent then
                                        ks.Name = entry.animation
                                        ks.Parent = OutputModel
                                    elseif ks.Parent then
                                        local newKS = ks:Clone()
                                        entry.output = newKS
                                        newKS.Name = entry.animation
                                        newKS.Parent = OutputModel
                                    end
                                end
                                animMap[extractedAnimId] = entry
                                
                                local repacked_info = {
                                    ["AnimationId"] = extractedAnimId;
                                    ["Playing Animation Index"] = tostring(i);
                                    ["Track Name"] = track.Name;
                                    ["Animation Name"] = track.Animation.Name;
                                    ["Asset Name"] = assetName;
                                }
                                local ks = entry.output
                                if ks and ks:IsA("KeyframeSequence") then
                                    repacked_info["Keyframe Count"] = ks and #(ks:GetKeyframes()) or "Unknown";
                                end

                                if infoMap[modelName] then
                                    table.insert(infoMap[modelName], repacked_info)
                                else
                                    infoMap[modelName] = { repacked_info }
                                end

                                mapCounter += 1
                            end
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

local safeModeState = Iris.State(false)

-- returns a boolean indicating whether the save was successful or not, and prints an error if it was not successful
local function saveGatheredAnimations(): boolean
    local modelName: string = `Place_{tostring(game.PlaceId)}_Version_{tostring(game.PlaceVersion)}_Date_{tostring(os.time())}_StolenAnimations`
    OutputModel.Name = modelName
    local fileName: string = `{DUMP_DIRECTORY_PATH}/{modelName}`

    local success, err = pcall(function()
        saveinstance(OutputModel, fileName, {
            noscripts = true;
            KillAllScripts = safeModeState:get();
            RemovePlayerCharacters = true;
            SafeMode = safeModeState:get();
        })
    end)
    if not success then
        -- if err then
        --     --print("Error saving animations: " .. tostring(err))
        -- else
        --     --print("Unknown error saving animations.")
        -- end
        return false
    end
    return true
end

local isCurrentlyDownloading = false
local isNonEmpty = false
local downloadedPopupState = Iris.State(false) -- false = popup closed, true = popup open
local downloadedSuccessfullyState = Iris.State(1) -- 1 = n/a, 2 = success, 3 = failed
local downloadedPopupTimerMadeState = Iris.State(false)
local function downloadPopup(timeout: number?): ()
    if downloadedSuccessfullyState:get() == 1 then
        -- warn("downloadPopup called but download result is n/a, this should not happen.")
        return
    end
    if not timeout then timeout = 3 end
    if downloadedPopupTimerMadeState:get() == false then
        downloadedPopupTimerMadeState:set(true)
        downloadedPopupState:set(true)
        task.delay(timeout, function()
            if downloadedPopupState:get() == false then
                return
            end
            downloadedPopupState:set(false)
            downloadedPopupTimerMadeState:set(false)
            downloadedSuccessfullyState:set(1)
        end)
    end
end

-- Widgets
Iris:Connect(function()
    --Connected to RunService.Heartbeat (~60 FPS)
    local sessionTime = FormatHours(time())
    local window = Iris.Window({"Animation Dumper by @Brycki404 (" .. ver .. ") " .. sessionTime}, {
        size = Iris.State(Vector2.new(600, 550));
        position = Iris.State(Vector2.new(100, 25));
        isOpened = showMainWindow;
    })
    -- the window has opened and uncollapsed events, which return booleans
    if window.state.isOpened:get() and window.state.isUncollapsed:get() then
        -- run the window code only if the window is actually open and uncollapsed,
        -- which is more efficient.
        Iris.Text({"Version: " .. ver})
        Iris.Text({"Your Session Time: " .. sessionTime})

        Iris.SameLine()
            Iris.Text({ "Toggle UI Keybind" })
            keybindButton(Config.windowKeyCode, 1)
        Iris.End()

        mainMenuBar()

        local dumpingTree = Iris.Tree({ "Dumping" })
        if dumpingTree.state.isUncollapsed:get() then
            if startedTime and lastUpdatedTime then
                local beenDumpingFor = FormatHours(lastUpdatedTime - startedTime)
                Iris.Text({ "Been Dumping For: " .. beenDumpingFor })
            end
            if not dumpThread or dumpThread and coroutine.status(dumpThread) == "dead" then
                if Iris.Button({ "Start Dumping Animations" }).clicked() then
                    startDumping()
                end
            else
                if Iris.Button({ "Stop Dumping Animations" }).clicked() then
                    stopDumping()
                end
            end
        end
        Iris.End()
        
        if isNonEmpty == false then
            if mapCounter > 0 then
                isNonEmpty = true
            end
        end
        if isNonEmpty == true then
            local gatheredTree = Iris.Tree({ "Gathered Animations" })
            if gatheredTree.state.isUncollapsed:get() then
                for modelName: string, listOfInfoUnderModel in pairs(infoMap) do
                    local modelTree = Iris.Tree({ modelName })
                    if modelTree.state.isUncollapsed:get() then
                        for i: number, info in ipairs(listOfInfoUnderModel) do
                            local infoHeader = `({i}): Id: {info["AnimationId"]} | [Names]: Asset: {info["Asset Name"]} | Animation: {info["Animation Name"]} | Track: {info["Track Name"]}`
                            local animTree = Iris.Tree({ infoHeader })
                            if animTree.state.isUncollapsed:get() then
                                Iris.Text({ `AnimationId: {info["AnimationId"]}` })
                                Iris.Text({ `Asset Name: {info["Asset Name"]}` })
                                Iris.Text({ `Animation Name: {info["Animation Name"]}` })
                                Iris.Text({ `Track Name: {info["Track Name"]}` })
                                Iris.Text({ `Playing Animation Index: {info["Playing Animation Index"]}` })
                                Iris.Text({ `Keyframe Count: {info["Keyframe Count"]}` })
                            end
                            Iris.End()
                        end
                    end
                    Iris.End()
                end
            end
            Iris.End()

            local downloadTree = Iris.Tree({ "Download" })
            if downloadTree.state.isUncollapsed:get() then
                if isCurrentlyDownloading == false and downloadedPopupState:get() == false and downloadedSuccessfullyState:get() == 1 then
                    Iris.SameLine()
                    local safeMode = Iris.Checkbox({ "Safe Mode" }, { isChecked = safeModeState })
                    if safeMode.checked() then
                        safeModeState:set(true)
                    elseif safeMode.unchecked() then
                        safeModeState:set(false)
                    end
                    helpMarker("Safe Mode kicks you from the game as to prevent detection.")
                    Iris.End()

                    local button = Iris.Button({ "Save Gathered Animations" })
                    if button.clicked() then
                        isCurrentlyDownloading = true
                        task.spawn(function()
                            local success = saveGatheredAnimations()
                            if success then
                                downloadedSuccessfullyState:set(2)
                                downloadPopup(10)
                            else
                                downloadedSuccessfullyState:set(3)
                                downloadPopup(10)
                            end
                            isCurrentlyDownloading = false
                        end)
                    end
                else
                    Iris.Text({ "Currently downloading gathered animations, please wait..." })
                end
            end
            Iris.End()
        end
    end
    Iris.End()

    if downloadedPopupState:get() == true then
        local popupWindow = Iris.Window({ "Download Notification" }, { size = Iris.State(Vector2.new(250, 100)), isOpened = downloadedPopupState })
        if popupWindow.state.isOpened:get() and popupWindow.state.isUncollapsed:get() then
            if downloadedSuccessfullyState:get() == 2 then
                Iris.Text({ "Successfully downloaded gathered animations!" })
                Iris.Separator()
                Iris.Text({ "Check your workspace folder for the file: "})
                Iris.Text({ `{DUMP_DIRECTORY_PATH}/{OutputModel.Name}.rbxmx` })
            elseif downloadedSuccessfullyState:get() == 3 then
                Iris.Text({ "Failed to download gathered animations." })
            end
        end
        Iris.End()
    else
        downloadedPopupTimerMadeState:set(false)
        downloadedSuccessfullyState:set(1)
    end

    if showRuntimeInfo.value then
        runtimeInfo()
    end
    if showDebugWindow.value then
        debugPanel()
    end
    if showStyleEditor.value then
        styleEditor()
    end

    if EXECUTOR_FILING_ENABLED then
        if choosingConfig_open:get() then
            local chooseWindow = Iris.Window({ "Open Config" }, {
                size = Iris.State(Vector2.new(300, 200));
                isOpened = choosingConfig_open;
            })
            if chooseWindow.state.isOpened:get() and chooseWindow.state.isUncollapsed:get() then
                local files = listfiles(CONFIG_DIRECTORY_PATH)

                for _, filePath in ipairs(files) do
                    -- Extract just the filename (no path)
                    local fileName = filePath:match("([^/\\]+)$")
                    -- Only continue if it's a .json file
                    if fileName and fileName:match("%.json$") then
                        fileName = fileName:sub(1, -6) -- Remove the .json extension for display
                        if Iris.Button({ fileName }).clicked() then
                            choosingConfig_open:set(false)
                            LoadIrisConfig(filePath)
                        end
                    end
                end
            end
            Iris.End()
        elseif choosingConfig_save:get() then
            local chooseWindow = Iris.Window({ "Save Config" }, {
                size = Iris.State(Vector2.new(300, 200));
                isOpened = choosingConfig_save;
            })
            if chooseWindow.state.isOpened:get() and chooseWindow.state.isUncollapsed:get() then
                local files = listfiles(CONFIG_DIRECTORY_PATH)

                for _, filePath in ipairs(files) do
                    -- Extract just the filename (no path)
                    local fileName = filePath:match("([^/\\]+)$")
                    -- Only continue if it's a .json file
                    if fileName and fileName:match("%.json$") then
                        fileName = fileName:sub(1, -6) -- Remove the .json extension for display
                        if Iris.Button({ fileName }).clicked() then
                            choosingConfig_save:set(false)
                            SaveIrisConfig(filePath)
                        end
                    end
                end

                if Iris.Button({ "[Save To New Config]" }).clicked() then
                    choosingConfig_save:set(false)
                    typingCustomConfig_save:set(true)
                end
            end
            Iris.End()
        end
        if typingCustomConfig_save.value then
            local promptWindow = Iris.Window({ "Enter Config Name" }, { isOpened = typingCustomConfig_save })
            -- the promptWindow has opened and uncollapsed states, which return booleans
            if promptWindow.state.isOpened:get() and promptWindow.state.isUncollapsed:get() then
                local textInputWidget = nil
                Iris.SameLine()
                do
                    Iris.Text({ "Enter a Config Name: " })
                    textInputWidget = Iris.InputText({ "" }, { text = Iris.WeakState("Default") })
                end
                Iris.End()
                Iris.SameLine()
                do
                    local continueButton = Iris.Button({ "Continue" })
                    local cancelButton = Iris.Button({ "Cancel" })
                    if continueButton.clicked() then
                        local configName = textInputWidget.state.text:get()
                        if configName and configName ~= "" then
                            SaveIrisConfig(CONFIG_DIRECTORY_PATH .. "\\" .. configName .. ".json")
                        end
                        typingCustomConfig_save:set(false)
                    end
                    if cancelButton.clicked() then
                        typingCustomConfig_save:set(false)
                    end
                end
                Iris.End()
            end
            Iris.End()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
    if not gameProcessedEvent then
        for _, keyCodeName in ipairs(Config.windowKeyCode:get()) do
            if keyCodeName == nil or keyCodeName == "" or keyCodeName == "None" then
                continue
            end
            local keyCode = Enum.KeyCode[keyCodeName]
            if keyCode and input.KeyCode == keyCode then
                showMainWindow:set(not showMainWindow:get())
            end
        end
    end
end)
