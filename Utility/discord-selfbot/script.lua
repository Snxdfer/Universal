local Bot = loadstring(game:HttpGet("https://raw.githubusercontent.com/penguin-cmyk/Selfbot-Luau-roblox/refs/heads/main/src/main.lua"))()

-- [[ adding commands ]]--
Bot:addCommand("!output",function(info) --> !output hello eg
    Bot:Output(`[~] {info.username} with userid {info.userId} said: {info.content}`,194, 120, 17) --> content: hello
end)
-- [[ actually starting the websocket with your discord token ]] --
Bot:Websocket({
    ["token"] = "",
})
