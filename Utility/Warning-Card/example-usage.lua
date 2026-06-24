-- made by: ancestrychanged
-- https://scriptblox.com/u/ancestrychanged

-- usage

loadstring(game:HttpGet("https://ancestrychanged.com/scripts/warningcard.lua"))({
	title = "Unsupported executor",
	body = "This script uses functions that your executor doesn't support.",
	site = "https://weao.xyz/",
	note = "Every executor on the site works, except Xeno and Solara.",
	primary = "View executors", -- opens discord if user has it
	secondary = "Dismiss",
	invite = "weaoxyz", -- discord invite, set to nil if you don't want to see the primary button
	logoUrl = "https://ancestrychanged.com/images/weaologo.png",
	logoFile = "weaologo.png",
	yields = true, -- false: returns instantly and script keeps running; true: waits for user to click any button + also returns which button was clicked - primary (view executors) or secondary (dismiss)
	hideOtherUis = true, -- hide every other UI (inf yield, roblox topbar, other ScreenGuis/SurfaceGuis/BillboardGuis) while the warning is visible, restore them on close
})()

-- i pair it w/ this
--[[
if string.lower(identifyexecutor()):find("xeno") then
    loadstring ... ... ...
end
--]]
