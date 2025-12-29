--Configuration
getgenv().Use_Displayname = true -- if true, put accounts displayname for bots | if false use the username of accounts
getgenv().bots = {"Asu_Bot1", "Asu_Bot2", "Asu_Bot3", "Asu_Bot4", "Asu_Bot5", "Asu_Bot6"} --bots
getgenv().owner = "TheReal_Asu2" --Owner (USER NAME, DO NOT PUT DISPLAYNAME)
getgenv().nbbot = 6 -- Number of bots you want to use
getgenv().prefix = ";" -- Prefix
getgenv().botrender = false -- when true, bots use less CPU
getgenv().printcmd = true -- if true, displays all commands available in the console

loadstring(game:HttpGet('https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Random/AsuBotController/src.lua'))()

--[[ INFO:

- do ;quits to deactivate the script
- activate script only once
- you can check whether bots are active by doing ;status
- if the bots don't execute the command, you'll have to redo the command until it's executed.
- put the bots you want to use in the places of the list. 
- you can try to fix bots with ;fix command

]]
