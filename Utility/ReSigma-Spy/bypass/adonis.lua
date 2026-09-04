local Adonis = {
    Name = "Adonis",
    Game = "*",
}

local AdonisAnticheatThreads = {}

function Adonis.Detect()
    if not getreg or not getgc or not isfunctionhooked then
        return false
    end

    local AdonisDetected = false

    for _, thread in getreg() do
        if typeof(thread) ~= "thread" then continue end
        local ok, Source = pcall(debug.info, thread, 1, "s")
        if ok and Source and (Source:match("%.Core%.Anti") or Source:match("%.Plugins%.Anti_Cheat")) then
            AdonisDetected = true
            table.insert(AdonisAnticheatThreads, thread)
        end
    end

    return AdonisDetected
end

function Adonis.Bypass(ctx)
    for _, thread in AdonisAnticheatThreads do
        pcall(coroutine.close, thread)
    end

    local AdonisTables = {}
    if filtergc then
        local Contendors = filtergc("table", { Keys = { "Detected", "RLocked" } }, false)
        for _, t in Contendors do
            if typeof(rawget(t, "Detected")) == "function" then
                table.insert(AdonisTables, t)
            end
        end
    else
        for _, t in getgc(true) do
            if typeof(t) ~= "table" then continue end
            if typeof(rawget(t, "Detected")) == "function" and rawget(t, "RLocked") then
                table.insert(AdonisTables, t)
            end
        end
    end

    for _, tbl in AdonisTables do
        for _, DetectionFunc in tbl do
            if typeof(DetectionFunc) ~= "function" or isfunctionhooked(DetectionFunc) then
                continue
            end
            ctx.Hooks[DetectionFunc] = ctx.HookFunction(DetectionFunc, function()
                coroutine.yield()
                return task.wait(9e9)
            end)
        end
    end

    return true
end

return Adonis
