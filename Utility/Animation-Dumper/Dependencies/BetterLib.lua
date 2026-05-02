local genv = getgenv()

if genv.BetterLib == nil then
    genv.BetterLib = {
        FirstRun = nil;
        --// Hook Storage
        LoadstringCaching = {};
        GetCaching = {};
        OldLoadstring = loadstring;
    }
end
BetterLib = genv.BetterLib

--// First Run
if BetterLib.FirstRun == nil then
    BetterLib.FirstRun = true
elseif BetterLib.FirstRun == true then
    BetterLib.FirstRun = false
end

if BetterLib.FirstRun then
    --// Better Loadstring
    function BetterLib.loadstring(str: string): any
        assert(type(str) == "string", "[Error] loadstring: First Argument needs to be a string!")

        if BetterLib.LoadstringCaching[str] == nil then
            local toCache = BetterLib.OldLoadstring(str)
            BetterLib.LoadstringCaching[str] = toCache
            return toCache
        end
        return BetterLib.LoadstringCaching[str]
    end
    loadstring = BetterLib.loadstring
    genv.loadstring = BetterLib.loadstring

    --// Better Get
    function BetterLib.Get(url: string): any
        assert(type(url) == "string", "[Error] Get: First Argument needs to be a string!")

        if BetterLib.GetCaching[url] == nil then
            local success, result = pcall(function()
                return game.HttpGet and game:HttpGet(url, true) or game.HttpGetAsync and game:HttpGetAsync(url, true) or nil
            end)

            if success then
                BetterLib.GetCaching[url] = result
                return result
            else
                error("[Error] httpGet: Failed to get content from URL: " .. url .. "\n" .. tostring(result))
            end
        else
            return BetterLib.GetCaching[url]
        end
        return nil
    end
    Get = BetterLib.Get
    genv.Get = BetterLib.Get

    BetterLib.saveinstance = saveinstance or (function()
        --warn("No built-in saveinstance exists, using SynSaveInstance and wrapper...")
        if game:GetService("RunService"):IsStudio() then return function() error("Cannot run in Roblox Studio!") end end
        local Params = {
            RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
            SSI = "saveinstance",
        }
        local synsaveinstance = loadstring(oldgame:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
    
        local function wrappedsaveinstance(obj, filepath, options)
            options["FilePath"] = filepath
            --options["ReadMe"] = false
            options["Object"] = obj
            return synsaveinstance(options)
        end
        
        getgenv().saveinstance = wrappedsaveinstance
        return wrappedsaveinstance
    end)()
    saveinstance = BetterLib.saveinstance
    genv.saveinstance = BetterLib.saveinstance
    
    BetterLib.ConfigLibraryUrl = "https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua"
    ConfigLibraryUrl = BetterLib.ConfigLibraryUrl
    genv.ConfigLibraryUrl = BetterLib.ConfigLibraryUrl

    BetterLib.ConfigLibrary = BetterLib.loadstring(BetterLib.Get(BetterLib.ConfigLibraryUrl))()
    ConfigLibrary = BetterLib.ConfigLibrary
    genv.ConfigLibrary = BetterLib.ConfigLibrary

    BetterLib.reprUrl = "https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Animation-Dumper/Dependencies/repr.lua"
    reprUrl = BetterLib.reprUrl
    genv.reprUrl = BetterLib.reprUrl
    
    BetterLib.repr = BetterLib.loadstring(BetterLib.Get(BetterLib.reprUrl))()
    repr = BetterLib.repr
    genv.repr = BetterLib.repr
    
    BetterLib.reprSettings = {
        pretty = true;              -- print with \n and indentation?
    	semicolons = true;          -- when printing tables, use semicolons (;) instead of commas (,)?
    	sortKeys = true;             -- when printing dictionary tables, sort keys alphabetically?
    	spaces = 2;                  -- when pretty printing, use how many spaces to indent?
    	tabs = false;                -- when pretty printing, use tabs instead of spaces?
    	robloxFullName = true;      -- when printing Roblox objects, print full name or just name? 
    	robloxProperFullName = true; -- when printing Roblox objects, print a proper* full name?
    	robloxClassName = true;      -- when printing Roblox objects, also print class name in parens?
    }
    reprSettings = BetterLib.reprSettings
    genv.reprSettings = BetterLib.reprSettings
    -- Example usage: local str = repr(table, reprSettings)

    --Check Executor Has Global Function
    BetterLib.CEHGF = function(name: string): boolean
        if genv[name] and type(genv[name]) == "function" then
            return true
        end
        return false
    end
    CEHGF = BetterLib.CEHGF
    genv.CEHGF = BetterLib.CEHGF
    
    BetterLib.shallowCopy = function(t)
    	local t2 = {}
    	t.__index = nil
    	for key, value in pairs(t) do
    		value = rawget(t, key)
    		t2[key] = value
    	end
    	return t2
    end
    shallowCopy = BetterLib.shallowCopy
    genv.shallowCopy = BetterLib.shallowCopy
    
    BetterLib.deepCopy = function(t)
    	local t2 = {}
    	t.__index = nil
    	for key, value in pairs(t) do
    		value = rawget(t, key)
    		if type(value) == "table" then
    			value = BetterLib.deepCopy(value)
    		end
    		t2[key] = value
    	end
    	return t2
    end
    deepCopy = BetterLib.deepCopy
    genv.deepCopy = BetterLib.deepCopy
    
    BetterLib.EXECUTOR_FILING_FUNCTIONS = {
        "readfile";
        "listfiles";
        "writefile";
        "makefolder";
        "appendfile";
        "isfile";
        "isfolder";
        "delfile";
        "delfolder";
        "loadfile";
        "dofile";
    }
    EXECUTOR_FILING_FUNCTIONS = BetterLib.EXECUTOR_FILING_FUNCTIONS
    genv.EXECUTOR_FILING_FUNCTIONS = BetterLib.EXECUTOR_FILING_FUNCTIONS
    
    BetterLib.EXECUTOR_FILING_ENABLED = true
    EXECUTOR_FILING_ENABLED = BetterLib.EXECUTOR_FILING_ENABLED
    genv.EXECUTOR_FILING_ENABLED = BetterLib.EXECUTOR_FILING_ENABLED
    
    for i, name in ipairs(BetterLib.EXECUTOR_FILING_FUNCTIONS) do
        if not BetterLib.CEHGF(name) then
            BetterLib.EXECUTOR_FILING_ENABLED = false
            warn("Executor does not support file functions. File saving/loading features will be disabled. Missing function: " .. name)
            break
        end
    end
end

return BetterLib
