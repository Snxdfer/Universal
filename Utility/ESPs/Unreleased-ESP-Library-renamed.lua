--[[
⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⢠⡆⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⣷⣄⠀⠀⠀⠀⣾⣷⠀⠀⠀⠀⣠⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢿⠿⠃⠀⠀⠀⠉⠉⠁⠀⠀⠐⠿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣶⣶⣶⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⣶⣿⣿⡿⣿⣿⣿⡿⠋⠉⠀⠀⠉⠙⢿⣿⣿⡿⣿⣿⣷⣦⡀⠀⠀⠀
⠀⢀⣼⣿⣿⠟⠁⢠⣿⣿⠏⠀⠀⢠⣤⣤⡀⠀⠀⢻⣿⣿ ⠙⢿⣿⣿⣦⠀⠀
⣰⣿⣿⡟⠁⠀⠀⢸⣿⣿⠀⠀⢿DEPSO⡟⠀⠀⢸⣿⡇⠀⠀ ⠙⣿⣿⣷⡄
⠈⠻⣿⣿⣦⣄⠀⠸⣿⣿⡀⠀⠀⠀⠉⠉⠀⠀  ⣸⣿⣿ ⢀⣤⣾⣿⣿⠟⠁
⠀⠀⠈⠻⣿⣿⣿⣶⣿⣿⣿⣦⣄⠀⠀⠀⢀⣠⣾⣿⣿⣿⣾⣿⣿⡿⠋⠁⠀⠀
⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠿⠿⠿⠿⠿⠿⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⣷⡦⠀⠀⠀⢀⣀⣀⠀⠀⠀⢴⣾⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣸⠟⠁⠀⠀⠀⠘⣿⡇⠀⠀⠀⠀⠙⢷⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀ ⠻⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀
ts file was generated at discord.gg/25ms
renamed by AI
]]

local moduleRegistry

moduleRegistry = {
    cache = {},
    load = function(moduleKey)
        if not moduleRegistry.cache[moduleKey] then
            moduleRegistry.cache[moduleKey] = {
                c = moduleRegistry[moduleKey](),
            }
        end

        return moduleRegistry.cache[moduleKey].c
    end,
}

do
    function moduleRegistry.a()
        return {}
    end
    function moduleRegistry.b()
        local drawingManager = {Objects = {}}

        drawingManager.__index = drawingManager

        moduleRegistry.load'a'

        function drawingManager:CreateObjectsClass()
            return {
                Objects = {},
                Counter = 1,
            }
        end
        function drawingManager:GetDrawingObject(drawType, constructorFn)
            local objectsMap = self.Objects
            local typeEntry = objectsMap[drawType]

            if not typeEntry then
                typeEntry = self:CreateObjectsClass()
                objectsMap[drawType] = typeEntry
            end

            local counter, objectsList = typeEntry.Counter, typeEntry.Objects
            local drawingObject = objectsList[counter]

            typeEntry.Counter += 1

            if not drawingObject then
                drawingObject = constructorFn(drawType)
                objectsList[counter] = drawingObject
            end

            drawingObject.Visible = true

            return drawingObject
        end
        function drawingManager:CleanUpClass(classEntry, debugLabel)
            local usedCount, objectsList = classEntry.Counter - 1, classEntry.Objects

            classEntry.Counter = 1

            local totalCount = #objectsList
            local unusedCount = totalCount - usedCount

            if unusedCount <= 0 then
                return totalCount, unusedCount
            end

            for i = 1, unusedCount do
                local iterationDone = false

                repeat
                    local objectIndex = usedCount + i
                    local drawingObject = objectsList[objectIndex]

                    if not drawingObject then
                        iterationDone = true

                        break
                    end

                    drawingObject.Visible = false
                    drawingObject.Position = Vector2.zero
                    iterationDone = true
                until true

                if not iterationDone then
                    break
                end
            end

            return totalCount, unusedCount
        end
        function drawingManager:CleanUp(printStats)
            local objectsMap, statsString = self.Objects, printStats and '' or nil

            for typeName, classEntry in objectsMap do
                local totalCount, unusedCount = self:CleanUpClass(classEntry, typeName, statsString)

                if statsString then
                    statsString ..= string.format('%s Objects: %s Unused: %s\n', tostring(typeName), tostring(totalCount), tostring(unusedCount))
                end
            end

            return statsString
        end

        return drawingManager
    end
    function moduleRegistry.c()
        local schedulerState, renderJobClass = {
            Enabled = true,
            Jobs = {},
            RegistoredCallbacks = {},
            IsWaiting = false,
            TickThreshold = 20,
            DebugStats = false,
            CompletionTime = nil,
            ObjectStats = nil,
        }, {}

        renderJobClass.__index = renderJobClass

        local baseModule, drawingManager, runService = moduleRegistry.load'a', moduleRegistry.load'b', game:GetService'RunService'

        function renderJobClass:Remove()
            local jobList, jobPosition = schedulerState.Jobs, self.Position

            table.remove(jobList, jobPosition)
        end
        function schedulerState:WaitCheck(tickIndex)
            local tickThreshold = self.TickThreshold

            if (tickIndex % tickThreshold) + 1 ~= tickThreshold then
                return
            end

            self.IsWaiting = true

            task.wait()

            self.IsWaiting = false
        end
        function schedulerState:AddRenderJob(jobHeader, jobArgs)
            local jobList, newJob = self.Jobs, {
                Enabled = true,
                Args = jobArgs,
                Header = jobHeader,
            }

            newJob.Position = table.insert(jobList, newJob)

            return setmetatable(newJob, renderJobClass)
        end
        function schedulerState:SetEnabled(enabled)
            self.Enabled = enabled
        end
        function schedulerState:RenderStep()
            local jobList, callbacks, debugEnabled = self.Jobs, self.RegistoredCallbacks, self.DebugStats

            for jobIndex, job in jobList do
                local iterationDone = false

                repeat
                    self:WaitCheck(jobIndex)

                    local jobHeader, jobEnabled, jobArgs, callbackFn = job.Header, job.Enabled, (job.Args)

                    if not jobEnabled then
                        iterationDone = true

                        break
                    end
                    if typeof(jobHeader) == 'string' then
                        callbackFn = callbacks[jobHeader]
                    else
                        callbackFn = jobHeader
                    end
                    if jobArgs then
                        callbackFn(unpack(jobArgs))
                    else
                        callbackFn()
                    end

                    iterationDone = true
                until true

                if not iterationDone then
                    break
                end
            end

            self.ObjectStats = drawingManager:CleanUp(debugEnabled)
        end
        function schedulerState:BeginRenderJobs()
            runService.PreRender:Connect(function()
                if not self.Enabled then
                    return
                end
                if self.IsWaiting then
                    return
                end

                local debugEnabled = self.DebugStats
                local startTime = debugEnabled and tick() or nil

                self:RenderStep()

                if debugEnabled then
                    self.CompletionTime = tick() - startTime
                end
            end)
        end
        function schedulerState:RegistorJobFunc(callbackKey, callbackFn)
            local callbacks = self.RegistoredCallbacks

            callbacks[callbackKey] = callbackFn
        end

        return schedulerState
    end
    function moduleRegistry.d()
        local espRenderer, baseModule, drawingObjectManager, renderScheduler, inputService, camera = {
            UseScreenPoint = false,
            UserConfig = nil,
            Pointers = nil,
            Drawing = Drawing,
        }, moduleRegistry.load'a', moduleRegistry.load'b', moduleRegistry.load'c', game:GetService'UserInputService', workspace.CurrentCamera
        local worldToScreenPoint, worldToViewportPoint, getPartsObscuring, isA, getPivot, getMouseLocation = camera.WorldToScreenPoint, camera.WorldToViewportPoint, camera.GetPartsObscuringTarget, game.IsA, workspace.GetPivot, inputService.GetMouseLocation

        function espRenderer:Create(drawingType, properties)
            local drawingLib = self.Drawing
            local newObject = drawingLib.new(drawingType)

            if properties then
                self:SetProperties(newObject, properties)
            end

            return newObject
        end
        function espRenderer:GetMousePosition()
            return getMouseLocation(inputService)
        end
        function espRenderer:SetProperties(drawingObject, properties)
            for key, value in properties do
                drawingObject[key] = value
            end
        end
        function espRenderer:ToScreenPoint(worldPosition, allowOffscreen)
            local screenPoint, isOnScreen

            if typeof(worldPosition) == 'CFrame' then
                worldPosition = worldPosition.Position
            end
            if self.UseScreenPoint then
                screenPoint, isOnScreen = worldToScreenPoint(camera, worldPosition)
            else
                screenPoint, isOnScreen = worldToViewportPoint(camera, worldPosition)
            end
            if allowOffscreen and not isOnScreen then
                return self:GetOffscreenPoint(worldPosition)
            end

            return Vector2.new(screenPoint.X, screenPoint.Y), isOnScreen
        end
        function espRenderer:GetTracerPoint(character, prePoints)
            if prePoints then
                return (prePoints[4] + prePoints[3]) / 2
            end

            local characterPosition, allowOffscreen = getPivot(character).Position, self:GetConfigValue('Display', 'AllowOffscreen')
            local screenPoint, isOnScreen = self:ToScreenPoint(characterPosition, allowOffscreen)

            if not allowOffscreen and not isOnScreen then
                return
            end

            return screenPoint
        end
        function espRenderer:GetObjectSize(object)
            if isA(object, 'Model') then
                return object:GetBoundingBox()
            end

            return object.CFrame, object.Size
        end
        function espRenderer:MultiCall(callArgs, methodMap)
            for methodName, isEnabled in methodMap do
                local iterationDone = false

                repeat
                    if not isEnabled then
                        iterationDone = true

                        break
                    end

                    local method = self[methodName]

                    method(self, unpack(callArgs))

                    iterationDone = true
                until true

                if not iterationDone then
                    break
                end
            end
        end
        function espRenderer:GetObject(drawingType)
            local drawingObject = drawingObjectManager:GetDrawingObject(drawingType, function()
                return self:Create(drawingType)
            end)

            drawingObject.Thickness = self:GetConfigValue('Display', 'BorderThickness')

            return drawingObject
        end
        function espRenderer:ForObjects(objectsSource, callback)
            local sourceType = typeof(objectsSource)

            if sourceType == 'Instance' then
                callback(objectsSource)

                return
            end
            if sourceType == 'function' then
                objectsSource = objectsSource()
            end

            for index, object in objectsSource do
                callback(object)
                renderScheduler:WaitCheck(index)
            end
        end
        function espRenderer:CheckValue(defaultValue, valueOrFunc, ...)
            local resolvedValue = valueOrFunc

            if typeof(valueOrFunc) == 'function' then
                resolvedValue = valueOrFunc(...)
            end

            return resolvedValue or defaultValue
        end
        function espRenderer:IsObstructedPoint(worldPosition, ignoreParts)
            local obstructingParts, transparencyThreshold = getPartsObscuring(camera, {worldPosition}, ignoreParts), 0.7

            for index, part in obstructingParts do
                local iterationDone = false

                repeat
                    if not isA(part, 'BasePart') then
                        iterationDone = true

                        break
                    end
                    if part.Transparency >= transparencyThreshold then
                        table.remove(obstructingParts, index)
                    end

                    iterationDone = true
                until true

                if not iterationDone then
                    break
                end
            end

            return #obstructingParts > 0
        end
        function espRenderer:Get2DBoxPoints(object)
            local objectCFrame, objectSize = self:GetObjectSize(object)
            local screenCenter, isOnScreen = self:ToScreenPoint(objectCFrame)

            if not isOnScreen then
                return
            end
            if self:GetConfigValue('Display', 'FaceCamera') then
                objectCFrame = CFrame.new(objectCFrame.Position, camera.CFrame.Position)
            end

            return {
                self:ToScreenPoint(objectCFrame * CFrame.new(objectSize.X / 2, objectSize.Y / 2, 0)),
                self:ToScreenPoint(objectCFrame * CFrame.new(-objectSize.X / 2, objectSize.Y / 2, 0)),
                self:ToScreenPoint(objectCFrame * CFrame.new(-objectSize.X / 2, -objectSize.Y / 2, 0)),
                self:ToScreenPoint(objectCFrame * CFrame.new(objectSize.X / 2, -objectSize.Y / 2, 0)),
            }
        end
        function espRenderer:GetOffscreenPoint(worldPosition)
            local viewportSize = camera.ViewportSize
            local viewportCenter, worldDirection, cameraRight, cameraUp = viewportSize * 0.5, (worldPosition - camera.CFrame.Position).Unit, camera.CFrame.RightVector, camera.CFrame.UpVector
            local dotRight, dotUp = worldDirection:Dot(cameraRight), worldDirection:Dot(cameraUp)
            local screenDirection = Vector2.new(dotRight, -dotUp).Unit
            local scaleX, scaleY = math.abs(viewportCenter.X / screenDirection.X), math.abs(viewportCenter.Y / screenDirection.Y)
            local clampScale = math.min(scaleX, scaleY)

            return viewportCenter + screenDirection * clampScale
        end
        function espRenderer:GetConfigValue(category, key)
            local config = self.UserConfig

            return config[category][key]
        end
        function espRenderer:DrawSkeleton(character, drawOptions)
            local pointers = self.Pointers
            local skeletonMap = pointers:GetSkeletonMap(character)

            if not skeletonMap then
                return
            end

            local overrideColor = drawOptions.Color
            local skeletonColor = self:GetConfigValue('Colors', 'SkeletonColor', overrideColor)

            for boneIndex, bonePair in skeletonMap do
                local iterationDone = false

                repeat
                    local boneNameA, boneNameB = bonePair[1], bonePair[2]
                    local bonePartA, bonePartB = character:FindFirstChild(boneNameA), character:FindFirstChild(boneNameB)

                    if not bonePartA or not bonePartB then
                        iterationDone = true

                        break
                    end

                    local screenPointA, isOnScreenA = self:ToScreenPoint(bonePartA.Position)
                    local screenPointB = self:ToScreenPoint(bonePartB.Position)

                    if not isOnScreenA then
                        iterationDone = true

                        break
                    end

                    local lineObject = self:GetObject'Line'

                    lineObject.From = screenPointA
                    lineObject.To = screenPointB
                    lineObject.Color = skeletonColor
                    iterationDone = true
                until true

                if not iterationDone then
                    break
                end
            end
        end
        function espRenderer:DrawHealth(character, drawOptions)
            local pointers = self.Pointers
            local health, maxHealth = pointers:GetHealth(character)

            if not health then
                return
            end

            local prePoints = drawOptions.PrePoints
            local boxPoints = prePoints or self:Get2DBoxPoints(character)

            if not boxPoints then
                return
            end

            local cornerA, cornerB = boxPoints[1], boxPoints[4]
            local boxEdge = cornerB - cornerA
            local perpVector = Vector2.new(boxEdge.Y, -boxEdge.X)

            if perpVector.Magnitude == 0 then
                return
            end

            local edgeLength = boxEdge.Magnitude
            local barOffset, perpUnit = edgeLength * 0.1, perpVector.Unit
            local offsetVector, healthRatio = perpUnit * barOffset, math.clamp(health / maxHealth, 0, 1)
            local healthEndPoint, healthColor, emptyHealthColor = cornerB:Lerp(cornerA, healthRatio), self:GetConfigValue('Colors', 'HealthColor'), self:GetConfigValue('Colors', 'EmptyHealthColor')

            if healthRatio < 1 then
                local lineObject = self:GetObject'Line'

                lineObject.From = cornerA - offsetVector
                lineObject.To = cornerB - offsetVector
                lineObject.Color = emptyHealthColor
            end

            local lineObject = self:GetObject'Line'

            lineObject.From = healthEndPoint - offsetVector
            lineObject.To = cornerB - offsetVector
            lineObject.Color = healthColor
        end
        function espRenderer:DrawLabel(character, drawOptions)
            local offsetPercent, prePoints, overrideColor, labelText = drawOptions.OffsetPercent or 0.1, drawOptions.PrePoints, drawOptions.Color, drawOptions.Text
            local boxPoints = prePoints or self:Get2DBoxPoints(character)

            if not boxPoints then
                return
            end

            local pointA, pointB, nameColor, borderThickness, labelSize = boxPoints[1], boxPoints[2], self:GetConfigValue('Colors', 'NameColor'), self:GetConfigValue('Display', 'BorderThickness'), self:GetConfigValue('Display', 'LabelSize')
            local topEdge = pointB - pointA
            local edgeLength = topEdge.Magnitude
            local verticalOffset = edgeLength * offsetPercent
            local offsetVector, centerPoint, textObject = Vector2.new(0, verticalOffset + labelSize + borderThickness), (pointA + pointB) / 2, self:GetObject'Text'

            textObject.Text = self:CheckValue('', labelText, character)
            textObject.Color = self:CheckValue(nameColor, overrideColor, character)
            textObject.Size = labelSize
            textObject.Center = true
            textObject.Outline = true
            textObject.Position = centerPoint - offsetVector
        end
        function espRenderer:Draw2DBox(character, drawOptions)
            local prePoints, overrideColor = drawOptions.PrePoints, drawOptions.Color
            local boxPoints = prePoints or self:Get2DBoxPoints(character)

            if not boxPoints then
                return
            end

            local boxColor, quadObject = self:GetConfigValue('Colors', 'BoxColor'), self:GetObject'Quad'

            quadObject.Color = self:CheckValue(boxColor, overrideColor, character)
            quadObject.PointA = boxPoints[1]
            quadObject.PointB = boxPoints[2]
            quadObject.PointC = boxPoints[3]
            quadObject.PointD = boxPoints[4]
        end
        function espRenderer:DrawTracer(character, drawOptions)
            local prePoints, overrideColor, followMouse, tracerColor, viewportSize, bottomOffset, tracerOrigin = drawOptions.PrePoints, drawOptions.Color, self:GetConfigValue('Display', 'TracersFollowMouse'), self:GetConfigValue('Colors', 'TracerColor'), camera.ViewportSize, 10

            if followMouse then
                tracerOrigin = self:GetMousePosition()
            else
                tracerOrigin = Vector2.new(viewportSize.X / 2, viewportSize.Y - bottomOffset)
            end

            local targetPoint = self:GetTracerPoint(character, prePoints)

            if not targetPoint then
                return
            end

            local lineObject = self:GetObject'Line'

            lineObject.Color = self:CheckValue(tracerColor, overrideColor, character)
            lineObject.From = tracerOrigin
            lineObject.To = targetPoint
        end

        return espRenderer
    end
    function moduleRegistry.e()
        local utils, baseModule = {}, moduleRegistry.load'a'

        function utils:Merge(target, source)
            if not source then
                return
            end

            for key, value in source do
                target[key] = value
            end

            return target
        end
        function utils:CheckInterval(interval, lastTime, currentTime)
            if not interval then
                return
            end
            if not lastTime then
                return true
            end

            local elapsed = currentTime - lastTime

            return elapsed >= interval
        end

        return utils
    end
    function moduleRegistry.f()
        local groupClass = {}

        groupClass.__index = groupClass

        moduleRegistry.load'a'

        function groupClass:NewGroup()
            local newGroup = {Enabled = true}

            return setmetatable(newGroup, self)
        end
        function groupClass:Remove()
            self.Enabled = false
        end

        return groupClass
    end
    function moduleRegistry.g()
        local uiManager = {
            ReGui = 'https://raw.githubusercontent.com/catblox1346/Dear-ReGui/refs/heads/main/ReGui.lua',
            WindowConfig = {
                Theme = 'Sigma-ESP',
                Title = 'Sigma ESP | By: depso',
                Size = UDim2.fromOffset(300, 200),
            },
            ElementValueTypes = {
                boolean = 'Checkbox',
                Color3 = 'DragColor3',
                number = 'SliderInt',
            },
        }

        uiManager.Accent = {
            Dark = Color3.fromRGB(35, 30, 35),
            Normal = Color3.fromRGB(148, 98, 255),
            Light = Color3.fromRGB(193, 164, 255),
        }
        uiManager.ThemeConfig = {
            BaseTheme = 'ImGui',
            TitleBarBg = uiManager.Accent.Dark,
            TitleBarBgActive = uiManager.Accent.Normal,
            FrameBg = uiManager.Accent.Normal,
            FrameBgActive = uiManager.Accent.Light,
            TabBg = uiManager.Accent.Normal,
            TabBgActive = uiManager.Accent.Normal,
            SliderGrab = uiManager.Accent.Normal,
            ResizeGrab = uiManager.Accent.Normal,
            CollapsingHeaderBg = uiManager.Accent.Normal,
            CheckMark = uiManager.Accent.Light,
        }

        local baseModule, renderScheduler = moduleRegistry.load'a', (moduleRegistry.load'c')

        function uiManager:Init(userConfig)
            local reguiUrl, themeConfig = self.ReGui, self.ThemeConfig

            ReGui = loadstring(game:HttpGet(reguiUrl))()

            ReGui:DefineTheme('Sigma-ESP', themeConfig)
            self:CreateWindow()
            self:MakeTabs(userConfig)
        end
        function uiManager:MakeTabs(userConfig)
            local window = self.Window

            self:MakeOptionsTab(userConfig, window:CreateTab{
                Name = 'Options',
            })
            self:MakeDebugTab(window:CreateTab{
                Name = 'Debug',
            })
        end
        function uiManager:CreateWindow()
            local windowConfig = self.WindowConfig
            local window = ReGui:TabsWindow(windowConfig)

            self.Window = window
        end
        function uiManager:MakeDebugTab(tab)
            tab:Checkbox{
                Value = true,
                Label = 'Debug Enabled',
                Callback = function(checkboxElement, newValue)
                    renderScheduler.DebugStats = newValue
                end,
            }

            local renderTimeLabel, objectStatsLabel = tab:Label(), tab:Label()

            renderScheduler:AddRenderJob(function()
                if not renderScheduler.DebugStats then
                    return
                end

                renderTimeLabel.Text = string.format('Render time: %s', tostring(renderScheduler.CompletionTime))
                objectStatsLabel.Text = tostring(renderScheduler.ObjectStats)
            end)
        end
        function uiManager:MakeOptionsTab(userConfig, tab)
            for categoryName, categoryOptions in userConfig do
                local sectionHeader = tab:CollapsingHeader{Title = categoryName}

                self:CreateOptions(sectionHeader, categoryOptions)
            end
        end
        function uiManager:CreateOptions(sectionHeader, optionsTable)
            for optionKey, optionValue in optionsTable do
                self:CreateOption(sectionHeader, optionKey, optionValue, function(element, newValue)
                    optionsTable[optionKey] = newValue
                end)
            end
        end
        function uiManager:CreateOption(sectionHeader, optionKey, optionValue, updateCallback)
            local elementTypes = self.ElementValueTypes
            local elementType = elementTypes[typeof(optionValue)]

            assert(elementType, string.format('No element for %s', tostring(optionKey)))

            local elementConfig, createElement = {
                Label = optionKey,
                Value = optionValue,
                Callback = updateCallback,
            }, sectionHeader[elementType]

            createElement(sectionHeader, elementConfig)
        end

        return uiManager
    end
    function moduleRegistry.h()
        local playerUtils, playersService = {
            SkeletonMaps = {
                R15 = {
                    {
                        'Head',
                        'UpperTorso',
                    },
                    {
                        'UpperTorso',
                        'LowerTorso',
                    },
                    {
                        'UpperTorso',
                        'LeftUpperArm',
                    },
                    {
                        'LeftUpperArm',
                        'LeftLowerArm',
                    },
                    {
                        'LeftLowerArm',
                        'LeftHand',
                    },
                    {
                        'UpperTorso',
                        'RightUpperArm',
                    },
                    {
                        'RightUpperArm',
                        'RightLowerArm',
                    },
                    {
                        'RightLowerArm',
                        'RightHand',
                    },
                    {
                        'LowerTorso',
                        'LeftUpperLeg',
                    },
                    {
                        'LeftUpperLeg',
                        'LeftLowerLeg',
                    },
                    {
                        'LeftLowerLeg',
                        'LeftFoot',
                    },
                    {
                        'LowerTorso',
                        'RightUpperLeg',
                    },
                    {
                        'RightUpperLeg',
                        'RightLowerLeg',
                    },
                    {
                        'RightLowerLeg',
                        'RightFoot',
                    },
                },
                R6 = {
                    {
                        'Head',
                        'Torso',
                    },
                    {
                        'Torso',
                        'Left Arm',
                    },
                    {
                        'Torso',
                        'Right Arm',
                    },
                    {
                        'Torso',
                        'Left Leg',
                    },
                    {
                        'Torso',
                        'Right Leg',
                    },
                },
            },
        }, game:GetService'Players'
        local localPlayer = playersService.LocalPlayer

        function playerUtils:GetTeam(player)
            return player.Team
        end
        function playerUtils:GetCharacter(player)
            return player.Character
        end
        function playerUtils:GetPlayerName(player)
            return player.Name
        end
        function playerUtils:IsTeamMate(player)
            local localTeam, playerTeam = self:GetTeam(localPlayer), self:GetTeam(player)

            return playerTeam == localTeam
        end
        function playerUtils:GetTeamColor(player)
            local team = self:GetTeam(player)

            if not team then
                return
            end

            return team.TeamColor.Color
        end
        function playerUtils:GetPlayers()
            return playersService:GetPlayers()
        end
        function playerUtils:GetLocalPlayer()
            return localPlayer
        end
        function playerUtils:GetHealth(character)
            local humanoid = character:FindFirstChildOfClass'Humanoid'

            if not humanoid then
                return
            end

            return humanoid.Health, humanoid.MaxHealth
        end
        function playerUtils:GetSkeletonMap(character)
            local skeletonMaps, humanoid = playerUtils.SkeletonMaps, character:FindFirstChildOfClass'Humanoid'

            if not humanoid then
                return
            end

            local rigTypeName = humanoid.RigType.Name

            return skeletonMaps[rigTypeName]
        end

        return playerUtils
    end
    function moduleRegistry.i()
        return {
            Colors = {
                BoxColor = Color3.fromRGB(94, 255, 0),
                TracerColor = Color3.fromRGB(94, 255, 0),
                SkeletonColor = Color3.fromRGB(255, 157, 0),
                HealthColor = Color3.fromRGB(9, 255, 0),
                EmptyHealthColor = Color3.fromRGB(255, 0, 0),
                ClosestPlayerColor = Color3.fromRGB(144, 0, 255),
                NameColor = Color3.fromRGB(255, 255, 255),
            },
            Objects = {
                Boxes2D = true,
                Tracers = true,
                Names = true,
                Health = true,
                Skeleton = true,
            },
            Display = {
                VisibilityCheck = false,
                TracersFollowMouse = false,
                TeamColor = true,
                AllowOffscreen = true,
                FaceCamera = true,
                DisplayDead = false,
                BorderThickness = 2,
                LabelSize = 16,
                TeamMates = true,
                HighlightClosest = true,
                OnlyShowClosest = false,
                ExcludeLocalPlayer = true,
            },
        }
    end
end

local esp, espRenderer, utils, scheduler, groupClass, uiManager, baseModule = {
    Enabled = true,
    DrawPlayers = false,
    UiEnabled = false,
    UserConfig = nil,
}, moduleRegistry.load'd', moduleRegistry.load'e', moduleRegistry.load'c', moduleRegistry.load'f', moduleRegistry.load'g', moduleRegistry.load'a'
local playerUtils, defaultConfig, getPivot = moduleRegistry.load'h', moduleRegistry.load'i', workspace.GetPivot

function esp:Init(initConfig)
    utils:Merge(self, initConfig)
    utils:Merge(espRenderer, initConfig)

    if self.UiEnabled then
        local userConfig = self.UserConfig

        uiManager:Init(userConfig)
    end

    return self
end
function esp:SetEnabled(enabled)
    self.Enabled = enabled

    return self
end
function esp:CheckPlayer(userConfig, character, player, localPlayer)
    local pointers, displayConfig = self.Pointers, userConfig.Display
    local showTeammates, showDead, excludeLocalPlayer = displayConfig.TeamMates, displayConfig.DisplayDead, displayConfig.ExcludeLocalPlayer

    if not showTeammates and pointers:IsTeamMate(player) then
        return
    end

    local health = pointers:GetHealth(character)

    if not showDead and (not health or health <= 0) then
        return
    end
    if excludeLocalPlayer and player == localPlayer then
        return
    end

    return true
end
function esp:DrawPlayer(userConfig, character, player, overrideColor)
    local pointers, drawObjects, useTeamColor = self.Pointers, userConfig.Objects, userConfig.Display.TeamColor
    local drawColor, playerName = overrideColor or useTeamColor and pointers:GetTeamColor(player) or nil, pointers:GetPlayerName(player)
    local drawArgs = {
        PrePoints = espRenderer:Get2DBoxPoints(character),
        Color = drawColor,
        Text = playerName,
    }

    espRenderer:MultiCall({character, drawArgs}, {
        DrawTracer = drawObjects.Tracers,
        DrawSkeleton = drawObjects.Skeleton,
        Draw2DBox = drawObjects.Boxes2D,
        DrawHealth = drawObjects.Health,
        DrawLabel = drawObjects.Names,
    })
end
function esp:DrawPlayersStep()
    if not self.Enabled then
        return
    end

    local pointers, userConfig = self.Pointers, self.UserConfig
    local localPlayer = pointers:GetLocalPlayer()
    local localCharacter, displayConfig = pointers:GetCharacter(localPlayer), userConfig.Display
    local onlyShowClosest, highlightClosest, visibilityCheck, closestPlayerColor, closestEntry, closestDistance, localPivot = displayConfig.OnlyShowClosest, displayConfig.HighlightClosest, displayConfig.VisibilityCheck, (userConfig.Colors.ClosestPlayerColor)

    if localCharacter then
        localPivot = getPivot(localCharacter)
    end

    for playerIndex, player in pointers:GetPlayers()do
        local iterationDone = false

        repeat
            local character = pointers:GetCharacter(player)

            if not character then
                iterationDone = true

                break
            end
            if not self:CheckPlayer(userConfig, character, player, localPlayer) then
                iterationDone = true

                break
            end

            local characterPosition = getPivot(character).Position

            if visibilityCheck then
                local isObstructed = espRenderer:IsObstructedPoint(characterPosition, {localCharacter, character})

                if isObstructed then
                    iterationDone = true

                    break
                end
            end
            if onlyShowClosest or highlightClosest then
                if not localCharacter then
                    iterationDone = true

                    break
                end

                local distance = (characterPosition - localPivot.Position).Magnitude

                if not closestDistance or distance < closestDistance then
                    closestDistance = distance
                    closestEntry = {player, character}
                end
                if onlyShowClosest then
                    iterationDone = true

                    break
                end
            end

            self:DrawPlayer(userConfig, character, player)
            scheduler:WaitCheck(playerIndex)

            iterationDone = true
        until true

        if not iterationDone then
            break
        end
    end

    if closestEntry then
        local closestPlayer, closestCharacter, highlightColor = closestEntry[1], closestEntry[2], highlightClosest and closestPlayerColor or nil

        self:DrawPlayer(userConfig, closestCharacter, closestPlayer, highlightColor)
    end
end
function esp:ExportFunc(funcName, sourceClass)
    local classFunc = sourceClass[funcName]

    assert(classFunc, string.format('Class function %s does not exist!', tostring(funcName)))

    self[funcName] = function(...)
        return classFunc(sourceClass, ...)
    end
end
function esp:ExportDrawingFunc(exportedName, drawFuncName)
    local drawFunc = espRenderer[drawFuncName]
    local renderJobCreator = function(rendererInstance, options)
        local highlight, refreshInterval, group, allowedCheck, getHighlightPart = options.Highlight, options.RefreshInterval, options.Group, options.AllowedCheck, options.GetHighlightPart
        local highlightIsFunc, lastRefreshTime = (typeof(highlight) == 'function')
        local highlightObjects = highlightIsFunc and {} or highlight

        return scheduler:AddRenderJob(function()
            if group and not group.Enabled then
                return
            end

            local currentTime = tick()

            if highlightIsFunc and utils:CheckInterval(refreshInterval, lastRefreshTime, currentTime) then
                lastRefreshTime = currentTime
                highlightObjects = highlight()
            end

            espRenderer:ForObjects(highlightObjects, function(object)
                if not object then
                    return
                end

                local targetPart = object

                if allowedCheck and not allowedCheck(object) then
                    return
                end
                if getHighlightPart then
                    targetPart = getHighlightPart(object)

                    if not targetPart then
                        return
                    end
                end

                drawFunc(espRenderer, targetPart, options)
            end)
        end)
    end

    self[exportedName] = renderJobCreator
end
function esp:MakeBasePointers()
    return utils:Merge({}, playerUtils)
end
function esp:SetGamePointers(gamePointers)
    local basePointers = self:MakeBasePointers()
    local mergedPointers = utils:Merge(basePointers, gamePointers)

    self.Pointers = mergedPointers
    espRenderer.Pointers = mergedPointers
end

esp:ExportDrawingFunc('Box2D', 'Draw2DBox')
esp:ExportDrawingFunc('Tracer', 'DrawTracer')
esp:ExportDrawingFunc('Skeleton', 'DrawSkeleton')
esp:ExportDrawingFunc('Label', 'DrawLabel')
esp:ExportFunc('NewGroup', groupClass)
esp:ExportFunc('AddRenderJob', scheduler)
esp:Init{
    Pointers = esp:MakeBasePointers(),
    UserConfig = defaultConfig,
}
scheduler:AddRenderJob(function()
    if not esp.DrawPlayers then
        return
    end

    esp:DrawPlayersStep()
end)
scheduler:BeginRenderJobs()

return esp
