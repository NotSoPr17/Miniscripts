
local PermVar = "AuthLevel"
local PlayerIsBanVar = "IsBan"
local HasMapAuth = true

local TriggerCommandNameVar = "CommandName"
local TriggerArgGroup = "CommandArgs"

CommandList = {}
PermHierarchy = {}

PermHierarchy.Default = 1
PermHierarchy.Tester = 2
PermHierarchy.Mod = 15
PermHierarchy.Admin = 50
PermHierarchy.SuperAdmin = 999

--- No modifiques abajo de esta linea si no sabes de scripting ---

--- Utility functions ---

function DefinePermissionLevel(prevLevel, commands) -- Basically just copies all the key-value pairs from the prevlevel table to commands one
    local newLevel = {}

    if prevLevel then
        for command, value in pairs(prevLevel) do
            newLevel[command] = value
        end
    end

    if commands then
        for command, value in pairs(commands) do
            newLevel[command] = value
        end
    end

    return newLevel
end

function CheckForPerm(Hierarchy, Trigger, Affected)
   if Hierarchy[Trigger] > Hierarchy[Affected] then
        return true
   end

    return false
end

function nickToUid(nick) 
    local _,_, playerarr = World:getAllPlayers(-1)    
    
    for _,v in ipairs(playerarr) do 
        
        local _, playernick = Player:getNickname(v)
        
        if nick:lower() == playernick:gsub("[%p%c%s]", ""):lower() then
            print("PlayerNick found")
            return v
        end
        
    end
    
    return nil
    
end

function UidExist(uid) 
    
    local _,_, playerarr = World:getAllPlayers(-1)
    
    for _,v in ipairs(playerarr) do 
    
        if v == uid then 
            return v
        end
    
    end
    
    return nil
    
end

function levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0

        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end

        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end

        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end

			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end

        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

function findClosestMatch(checkStr, options)
    
    local closestMatch, minDistance = nil, math.huge
    for option, _ in pairs(options) do
        local distance = levenshtein(checkStr, option)
        if distance < minDistance then
            closestMatch = option
            minDistance = distance
        end
    end
    
    return closestMatch
end


function getTriggerVar(varname, player)
    
    print("get trigger var triggered")
    
    if varname and type(varname) == "string" then
        for i=3,5 do 
            
            if not player then
                local ret, val = VarLib2:getGlobalVarByName(i, varname)
                print("global ret:".. ret)
                
                if ret == ErrorCode.OK then
                    print("found")
                    return val
                end
                
            else
                local ret, val = VarLib2:getPlayerVarByName(player, i, varname)	
                print("private ret:".. ret)
                
                if ret == ErrorCode.OK then
                    print("found")
                    return val
                end
            end
        end
    end
end

function setTriggerVar(varname, newval, player) 

    if varname and type(varname) == "string" then 
        
        if newval then 
        
            for i=1,20 do 
                
                if not player then
                    local ret = VarLib2:setGlobalVarByName(i, varname, newval)
                    print("global ret: " .. ret)
                else
                    local ret = VarLib2:setPlayerVarByName(player, i, varname, newval)
                    print("private ret: " .. ret)
                end
                
                if ret == ErrorCode.OK then 
                    return true
                end
            end
        end
    end
end

function IsInvalidNum(num) 

    if num == num and type(num) == "number" then 
        
        if num == math.huge or num == 1/0 then --Num is inf
            return true
        end

        return false

    else --Num is nan, invalid or nil
        return true
    end
    
end

function CheckForMode(trigger, affected) 
    
    local data = {}
    
    if affected then 
        
        data['uid'] = nickToUid(affected) or affected
        
        if data['uid'] == trigger then 
            data['self'] = trigger
        end
        
        return data
    
    else
        if trigger then
            
            data['uid'] = trigger
            data['self'] = true
            
            return data
            
        else
            return nil        
        end
    end
end

function SecondsToTicks(seconds) 

    local tickspersec = 1 / 0.05  -- 0.05 segundos por tick
    return seconds * tickspersec

end

function loadcommand(triggerplayer,...) 
    --loadstring(codetoload)
    
    local arg = {...}
    local codetoload = ""
    
    for _,v in ipairs(arg) do 
        codetoload = codetoload.. " " ..v
    end
    
    local sucess, err = pcall(LoadLuaScript, codetoload)
    
    if not sucess then 
        print("Error with the load code")
        print("err: ".. err)
    else    
        print("Everything is okay")
        
        local s, e = pcall(err)
        
        if not s then 
        
            print("error found in returned func")    
            if e then 
                print("Returned info: ".. e)
            end
        else
            print("no errors found")
            
            if e then 
                print("Returned info: ".. e)
            end
            
        end
        
    end
    
    --LoadLuaScript(codetoload)
end -- 259 - 221

function helpcommand(triggerplayer, commandname) --Second arg can be either a command or page
    local playerauthlvl = getTriggerVar(PermVar, triggerplayer) or "Default"
    
    print("playerauthlvl: ".. playerauthlvl)
    print("Commandname = ".. tostring(Commandname))

    local localAuthList = CommandList[playerauthlvl] or CommandList["Default"]
    
    print("Authlist contents: ")
    
    for k,v in pairs(localAuthList) do 
        
        print("k: ".. k)
        
        if not type(v) == table then
            print("v: ".. v)
        end
        
        print("v is a table, contents: ")
        
        if type(v) == table then 
        
            for k2,v2 in pairs(k) do 
        
                print("k2: ".. k2)
                print("v2: ".. v2)
        
            end
        
        end
        
    end
    
    if commandname == nil then
        
        print("Searching, no commandname")
        
        for k,v in pairs(localAuthList) do 
            
            local desc = v['desc'] or "Not provided"
            Chat:sendSystemMsg("Command: ".. k .. "\n Description: ".. desc, triggerplayer)

        end
        
    else
        
        print("Searching, commandname")
        
        if localAuthList then 
            
            local targetCmd = localAuthList[commandname]
            
            if targetCmd then 
                local desc = targetCmd['desc'] or "Not provided"
                local usage = targetCmd['usage'] or "Not provided"
                
                Chat:sendSystemMsg("Command name: ".. commandname .. "\n Description: ".. desc .."\n Usage: ".. usage, triggerplayer)
                
            else
                local closestMatch = findClosestMatch(commandname, localAuthList) 
        
                if closestMatch then
                    Chat:sendSystemMsg("Could not find the command ".. commandname ..". Did you mean: ".. closestMatch, playerid)
                else
                    Chat:sendSystemMsg("Could not find: ".. commandname, playerid)
                end
            end
            
        else
            Chat:sendSystemMsg("Could not find the command list.", triggerplayer)
            return
        end
        
    end
end -- 305 - 261

function runtriggercommand(triggerplayer, triggercommandname, addmoredata,...) 
    
    local args = {triggerplayer ,...}
    
    for i,v in ipairs(args) do
        local val = v

        if type(val) == "table" then 
            print("val is a table.")
            
            for k,v2 in pairs(val) do 
                print("k: ".. k)
                print("v: ".. tostring(v2))
                
                Valuegroup:insertValueByName(18, TriggerArgGroup, i, tostring(v2), 0)
                
            end
        
        else --Instertar args
            print("val: ".. val)
            
            local data = CheckForMode(val)
            
            if data then 
                print("data was found: ".. data['uid'])    
                val = data['uid']
                
            end
            
            Valuegroup:insertValueByName(18, TriggerArgGroup, i, tostring(val), 0)
        end
        
    end
    
    Valuegroup:insertValueByName(18, TriggerArgGroup, 101, triggercommandname, 0)    
    Valuegroup:insertValueByName(18, TriggerArgGroup, 100, "Sent", 0)

end

function teleportcommand(triggerplayer,x,y,z, tp_player) 
    
    local coords = {x,y,z} 
    
    for _,v in ipairs(coords) do 
        
        if IsInvalidNum(v) then 
            Chat:sendSystemMsg("One of the coordinates was invalid", triggerplayer)
            return
        end
        
    end
    
    local data = CheckForMode(triggerplayer, tp_player)
    Player:setPosition(data['uid'], x, y, z)
    Chat:sendSystemMsg("Teleported to "..x..","..y ..","..z, data['uid'])
    
end

function playerteleportcommand(triggerplayer, player1, player2) 

    if player2 then 
        local data1 = CheckForMode(player1,nil)
        local data2 = CheckForMode(player1, player2)
        
        Chat:sendSystemMsg("Teleporting player: ".. player1 .. "to: ".. player2 , triggerplayer)
        Chat:sendSystemMsg("Teleporting to: ".. player2, data1['uid'])
        Chat:sendSystemMsg(player1.. " is teleporting to you.", data2['uid'])
        
        local _,x,y,z = Actor:getPosition(data2['uid'])
        Actor:setPosition(data1['uid'], x, y, z)
        return
    end
    
    if player1 then 
        
        local data1 = CheckForMode(triggerplayer,nil)
        local data2 = CheckForMode(player1, nil)
        
        Chat:sendSystemMsg("Teleporting player: ".. triggerplayer .. "to: ".. player1 , triggerplayer)
        Chat:sendSystemMsg("Teleporting to: ".. player1, data1['uid'])
        Chat:sendSystemMsg(player1.. " is teleporting to you.", data2['uid'])
        
        local _,x,y,z = Actor:getPosition(data2['uid'])
        Actor:setPosition(data1['uid'], x, y, z)
        return
        
    end
    
    Chat:sendSystemMsg("Can't use this command without a target", triggerplayer)
    return
    
end

function summoncommand(triggerplayer, summonid, ...) 
    
    local args = {}
    if #args == 3 then
        for _,v in ipairs(args) do 
            
            if IsInvalidNum(v) then 
                Chat:sendSystemMsg("One of the coordinates was invalid.", triggerplayer)
                return
            end
            
        end
    end
    
    
    
end

function givecommand(triggerplayer, itemid, quantity, addplayer)
    Chat:sendSystemMsg("Adding items to backpack!", triggerplayer)
    
    local data = CheckForMode(triggerplayer, addplayer)
    
    Chat:sendSystemMsg("Added item(s) to your backpack!", data['uid'])
    Backpack:addItem(data['uid'], itemid, quantity)
    
end

function buffcommand(triggerplayer, buffid, buffduration, addplayer)

    Chat:sendSystemMsg("Adding a buff!", triggerplayer)

    local data = CheckForMode(triggerplayer, addplayer)
    
    if IsInvalidNum(buffid) or IsInvalidNum(buffduration) then 
        Chat:sendSystemMsg("Duration or Buffid was invalid", triggerplayer)
    else
        
        Chat:sendSystemMsg("Added a buff!", data['uid'])
        Actor:addBuff(data['uid'], buffid, 1, SecondsToTicks(buffduration))

    end

end

function addperm_cmd(triggerplayer, perm, addplayer)
    
    local data = CheckForMode(triggerplayer, addplayer)    
    
    local triggerplayerperm = getTriggerVar(PermVar, triggerplayer) or "Default"
    local addplayerperm = getTriggerVar(PermVar, data['uid']) or "Default"
    
    if data['self'] then 
        Chat:sendSystemMsg("You can't use this command in yourself!", triggerplayer)
        return
    end
    
    if not CommandList[perm] then 

        local closestMatch = findClosestMatch(perm, CommandList)
    
        if closestMatch then
            Chat:sendSystemMsg("Could not find the rank: " .. perm .. ". Did you mean \"" .. closestMatch .. "\"?", triggerplayer)
        else
            Chat:sendSystemMsg("Could not find the rank: " .. perm, triggerplayer)
        end
        
        return
    end
    
    if CheckForPerm(PermHierarchy, triggerplayerperm, addplayerperm) then 
        
        if CheckForPerm(PermHierarchy, triggerplayerperm, perm) then 
            
            Chat:sendSystemMsg("Assigning the rank: ".. perm .. " to the player: ".. addplayer, triggerplayer)
            Chat:sendSystemMsg("Your rank has changed, your new rank is: ".. perm, data['uid'])
            setTriggerVar(PermVar, perm, data['uid'])
        else
            Chat:sendSystemMsg("You can't assign a rank higher than yours.", triggerplayer)
        end
    else
            Chat:sendSystemMsg("You can't use this command in someone with higher or equal rank", triggerplayer)
    end
end -- 391 - 353

function removeperm_cmd(triggerplayer, addplayer) 
    
    local data = CheckForMode(triggerplayer, addplayer)    
    
    local triggerplayerperm = getTriggerVar(PermVar, triggerplayer) or "Default"
    local addplayerperm = getTriggerVar(PermVar, data['uid']) or "Default"
    
    if data['self'] then 
        Chat:sendSystemMsg("You can't use this command in yourself!", triggerplayer)
        return
    end

    if CheckForPerm(PermHierarchy, triggerplayerperm, addplayerperm) then 
        
        Chat:sendSystemMsg("Removing the ranks of the player: ".. addplayer, triggerplayer)
        Chat:sendSystemMsg("Your have been removed from your rank.", data['uid'])
        setTriggerVar(PermVar, "Default", data['uid'])

    else
        Chat:sendSystemMsg("You can't use this command in someone with higher or equal rank", triggerplayer)
    end
    
end

function kickcommand(triggerplayer, kickedplayer) 

    local data = CheckForMode(triggerplayer,kickedplayer)
    
    local triggerplayerperm = getTriggerVar(PermVar, triggerplayer) or "Default"
    local kickedplayerperm = getTriggerVar(PermVar, data['uid']) or "Default"

    if data['self'] then 
        Chat:sendSystemMsg("You can't use this command in yourself!", triggerplayer)
    end

   if CheckForPerm(PermHierarchy, triggerplayerperm, kickedplayerperm) then
   
        Chat:sendSystemMsg("Kicking target", triggerplayer)
        World:despawnActor(data['uid'])
    else
        Chat:sendSystemMsg("You can't kick someone with a higher or equal rank", triggerplayer)
    end
    
end

function bancommand(triggerplayer, kickedplayer)
    
    local data = CheckForMode(triggerplayer,kickedplayer)
    
    if data['self'] then 
        Chat:sendSystemMsg("You can't use this command in yourself.", triggerplayer)
    end
    
    local triggerplayerperm = getTriggerVar(PermVar, triggerplayer) or "Default"
    local kickedplayerperm = getTriggerVar(PermVar, data['uid']) or "Default"

   if CheckForPerm(PermHierarchy, triggerplayerperm, kickedplayerperm) then
   
        Chat:sendSystemMsg("Banning target", triggerplayer)
        setTriggerVar(PlayerIsBanVar, true, data['uid']) 
        World:despawnActor(data['uid'])
    else
        Chat:sendSystemMsg("You can't ban someone with a higher or equal rank", triggerplayer)
    end
    
end

function fillcommand(triggerplayer,blockid, face, ...) 

    local  MaxFillDist = 100
    local args = {...}
    
    if #args == 6 then 
        
        for _,v in ipairs(args) do 
            
            if IsInvalidNum(v) then 
                Chat:sendSystemMsg("One of the coordinates was invalid.", triggerplayer)
                return
            end
            
        end
        
        local _, dist = World:calcDistance({x=args[1],y=args[2],z=args[3]}, {x=args[4],y=args[5],z=args[6]})
        
        if dist > MaxFillDist then 
            Chat:sendSystemMsg("You are trying to fill over the distance limit.", triggerplayer)
            return
        end
        
        Chat:sendSystemMsg("Filling", triggerplayer)
        Area:fillBlockAreaRange({x=args[1],y=args[2],z=args[3]}, {x=args[4],y=args[5],z=args[6]}, blockid, face)
        
    end
    
end

function setblockcommand(triggerplayer, blockid, face, ...) 

    local coords = {...}
    for _,v in ipairs(coords) do 
        
        if IsInvalidNum(v) then 
            
            Chat:sendSystemMsg("One of the coordinates was invalid.", triggerplayer)
            return
        end
        
    end

    Chat:sendSystemMsg("Placing the block.", triggerplayer)
    Block:replaceBlock(blockid, coords[1], coords[2], coords[3], face)

end

function timesetcommand(triggerplayer, target_time) 
    
    if not IsInvalidNum(target_time) then
        Chat:sendSystemMsg("Setting the time.", triggerplayer)
        World:setHours(target_time)
    else
        Chat:sendSystemMsg("Provided time was invalid.", triggerplayer)
    end
end -- 490 - 16

CommandList.Default = DefinePermissionLevel(nil, {
    help = {func = helpcommand, desc = "Help command!"},
    saludar = {istrigger = true, desc = "Saluda a tus amigos!", usage = "/saludar"}
})

CommandList.Tester = DefinePermissionLevel(CommandList.Default, {})

CommandList.Mod = DefinePermissionLevel(CommandList.Tester, {
    tp = {func = teleportcommand, desc = "Teleports you or another player to a x y z coordinate.", usage = "/tp x y z [player]"},
    tpa = {func = playerteleportcommand, desc = "Teleports you or another player to the coordinates of a given player.", usage = "/tpa player"},
    give = {func = givecommand, desc = "Gives an item to a given player or you.", usage = "/give itemid quantity [player]"},
    buff = {func = buffcommand, desc = "Adds a buff to a given player or you.", usage = "/buff buffid duration [playerid]"},
    setblock = {func = setblockcommand, desc = "Places a block in a given coordinate", usage = "/setblock blockid face x y z"},
    fill = {func = fillcommand, desc = "Fills from a starting position to an ending position.", usage = "/fill blockid face startx starty startz endx endy endz"},
    timeset = {func = timesetcommand, desc = "Changes the time of the world.", usage = "/timeset time"},
    kick = {func = kickcommand, desc = "Kicks a player from the current room", usage = "/kick player"},
    fly = {istrigger = true, desc = "Empieza a volar!", usage = "/fly jugador"}
})

CommandList.Admin = DefinePermissionLevel(CommandList.Mod, {
    loadcode = {func = loadcommand, desc = "Code load command!", usage = "/loadcode {code:any}"},
    ban = {func = bancommand, desc = "Ban command tba", usage = "/ban player"},
    addperm = {func = addperm_cmd, desc = "Adds a rank to a player. (Can't use on higher ranks, also can't give them)", usage = "/addperm perm player"},
    removeperm = {func = removeperm_cmd, desc = "Returns a player to the default rank. (Can't use on higher or equal ranks)", usage = "/removeperm player"}
})

CommandList.SuperAdmin = DefinePermissionLevel(CommandList.Admin,{}) --El permiso mas alto de todos

ScriptSupportEvent:registerEvent("Command.CommandStart", function(e) 
    
    print("Command.CommandStart event triggered")
    
    local playerid = e.CurEventParam.CloudValue['Playerid']
    local playerauthlvl = e.CurEventParam.CloudValue['PlayerAuthLevel']
    local content = e.CurEventParam.CloudValue['Content']
    
    print("Player ID: " .. playerid)
    print("Player Auth Level: " .. playerauthlvl)
    print("Content: " .. content)
    
    print("Searching for commands")
    
    local commandSimple, argsString = content:sub(2):match("(%S+)%s*(.*)")--content:sub(2):lower():match("(%S+)%s*(.*)")

    print("Commandsimple with no prefix or digits: " .. commandSimple)
    print("Arguments: " .. argsString)

    local args = {}
    
    for arg in argsString:gmatch("(%S+)") do
        if tonumber(arg) then
            args[#args + 1] = tonumber(arg)
        else
            args[#args + 1] = arg
        end
    end
    
    local UsedCommandList = nil
    
    if CommandList[playerauthlvl] then 
        print("Permission level exists")
        UsedCommandList = playerauthlvl
 
    else 
        print("Can't find perm level, using default")
        UsedCommandList = "Default"

    end

    local SearchCommand = CommandList[UsedCommandList][commandSimple]
    print("SearchCommand: ".. tostring(SearchCommand))

    if SearchCommand then 
        print("Command" .. commandSimple .. "was found")
         --runtriggercommand(triggerplayer, triggercommandname ,...) 

        if #args >= 1 then 
            print("Execution with arguments")
            
            if SearchCommand['istrigger'] then 
                Chat:sendSystemMsg("El comando es de activador.", playerid)
                Chat:sendSystemMsg("Ejecutando con argumentos.", playerid)
            
                runtriggercommand(playerid, commandSimple , unpack(args))
                
            else
                SearchCommand['func'](playerid ,unpack(args))
            end
            
        else
            print("Execution with no arguments")
            
            if SearchCommand['istrigger'] then 
                
                Chat:sendSystemMsg("El comando es de activador.", playerid)
                Chat:sendSystemMsg("Ejecutando sin argumentos.", playerid)
                
                runtriggercommand(playerid, commandSimple, "noargs")

            else
                SearchCommand['func'](playerid)
            end
        end
        
    else
        
        local closestMatch = findClosestMatch(commandSimple, CommandList[UsedCommandList]) 
        
        if closestMatch then
            Chat:sendSystemMsg("Could not find the command ".. commandSimple ..". Did you mean: ".. closestMatch, playerid)
        else
            Chat:sendSystemMsg("Could not find: ".. commandSimple, playerid)
        end
    end
    
end)

ScriptSupportEvent:registerEvent("MapAuth.Test", function(e) 
    HasMapAuth = true 
end)
