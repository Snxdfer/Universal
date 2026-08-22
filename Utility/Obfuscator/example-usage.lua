local obfuscate = loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/Obfuscator/obfuscator-src.lua"))()
local watermark = "your watermark here ez"
local varPrefix = "pref1x_"

-- your script goes inside of these things [[ ]]
local script = [[

print("wassup world")
local bitch = 10
print(bitch * 2)

]]

obfuscate(script, varPrefix, watermark)
