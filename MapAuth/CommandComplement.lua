--Version 1.1
-- creado por notsopr17 uid: 75820841

--[[

HasMapAuth es verdadero por defecto
Aunque esta en mis planes hacer que el script detecte automaticamente si tienes mapauth o no

]]--

local HasMapAuth = true

local CommandDescriptions = {
        help = "Basic Help Command",
        loadcode = "Loads a script code USE: /loadcode (code:any)",
        tp = "Teleports you to a coordinate USE: /tp x y z [player who will be teleported (if not given teleports you)]",
        give = "Gives you or another player a buff",
        kick = "Kicks a player from the room"
}

function nickToUid(nick) 
    local _,_, playerarr = World:getAllPlayers(-1)    
    for _,v in ipairs(playerarr) do 
        
        local _, playernick = Player:getNickname(v)
        
        if nick:lower() == playernick:gsub("[%p%c%s]", ""):lower() then
            print("PlayerNick found")
            return v
        end
        
    end
    
end

function loadcommand(triggerplayer,codetoload) 
    --loadstring(codetoload)
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
end

function helpcommand(triggerplayer)
    
    for k,v in pairs(CommandDescriptions) do 
        Chat:sendSystemMsg(k ..":".. v .. "\n", triggerplayer)
    end
    
end

function teleportcommand(triggerplayer,x,y,z, tp_player) 
    
    local coords = {x,y,z} 
    
    for _,v in ipairs(coords) do 
        
        if v == v then 
            
            if v == math.huge or v == 1/0 then 
                Chat:sendSystemMsg("A coordinate is an infinite value", triggerplayer)
                return
            end
            
        else
            Chat:sendSystemMsg("A coordinate is a NaN value", triggerplayer)
            return
        end
        
    end
    
    print("triggerplayer: ".. triggerplayer)
    if tp_player then
        
        if type(tp_player) == "number" then 
            print("Teleporting others")
            Chat:sendSystemMsg("Teleporting!", tp_player)
            Actor:setPosition(tp_player, x, y, z)
            return
        else
            local playeruid = nickToUid(tp_player)
            
            print("Teleporting others (name)")
            Chat:sendSystemMsg("Teleporting!", playeruid)
            Actor:setPosition(playeruid, x, y, z)
        end
        
    else
        print("Teleporting self")
        Chat:sendSystemMsg("Teleporting!", triggerplayer)
        Actor:setPosition(triggerplayer, x, y, z)
        return
    end
end

function givecommand(triggerplayer, itemid, quantity, addplayer)
    Chat:sendSystemMsg("Adding items to backpack!", triggerplayer)

     if addplayer then
        
        if type(addplayer) == "number" then 
            print("Give item others others")
            Chat:sendSystemMsg("Adding items to backpack!", addplayer)
            Backpack:addItem(addplayer, itemid, quantity)
            
            return
        else
            local playeruid = nickToUid(addplayer)
            
            print("Teleporting others (name)")
            Chat:sendSystemMsg("Adding items to backpack!", playeruid)
            Backpack:addItem(playeruid, itemid, quantity)
            return
        end
        
    else
        Chat:sendSystemMsg("Adding items to backpack!", triggerplayer)
        Backpack:addItem(triggerplayer, itemid, quantity)
        return
    end
    
end

function buffcommand(triggerplayer, buffid, duration, addplayer)

     if addplayer then
        
        if type(addplayer) == "number" then 
            print("Buff others")
            
            if tonumber(duration) then
                Actor:addBuff(addplayer, buffid, 1, duration)
                Chat:sendSystemMsg("Added a buff!", addplayer)
            else
                Chat:sendSystemMsg("Could not add the buff. Duration was not a number", triggerplayer)
            end
            
            return
        else
            local playeruid = nickToUid(addplayer)
            
            print("Teleporting others (name)")
            Chat:sendSystemMsg("Adding items to backpack!", playeruid)
            
            if tonumber(duration) then
                Actor:addBuff(addplayer, buffid, 1, duration)
                Chat:sendSystemMsg("Added a buff!", playeruid)
            else
                Chat:sendSystemMsg("Could not add the buff. Duration was not a number", triggerplayer)
            end
            
            return
        end
        
    else
        Actor:addBuff(triggerplayer, buffid, 1, triggerplayer)
        Chat:sendSystemMsg("Added a buff!", triggerplayer)
        return
    end
    
end

function kickcommand(triggerplayer, kickedplayer) 
    
    local _, playernick = Player:getNickname(kickedplayer)
    local _, adminNick = Player:getNickname(triggerplayer)
    Chat:sendSystemMsg("Kicked player: ".. playernick, triggerplayer)
    Chat:sendSystemMsg("You were kicked by: ".. adminNick, kickedplayer)
    
    threadpool:wait(1)
    
    World:despawnActor(kickedplayer)
end

CommandList = {
    
    Default = { --Perms de miembro
        
      help = helpcommand  
        
    },
    
    Mod = {
        
        help = helpcommand,
        tp = teleportcommand,
        give = givecommand,
        kick = kickcommand
    },

    Admin = {
        
        help = helpcommand,
        loadcode = loadcommand,
        tp = teleportcommand,
        give = givecommand,
        buff = buffcommand,
        kick = kickcommand
    }
    
}

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
    
    for key, func in pairs(CommandList[UsedCommandList]) do 
        print("Checking command: " .. key)
        if commandSimple == key then 
            print("FUNCTION FOUND")
            
            if #args >= 1 then 
                print("Executing function with arguments")
                local success, errorstatus = pcall(func, playerid ,unpack(args))
                
                if not success then 
                    print("Error executing function:")
                    print(errorstatus)
                    for i=1, #PlayerArr do
                        print("#YError found \nIf you see this, send a screenshot to @notsopr17 on discord, please #A111")
                        print("#YSe encontro un error \n Si ves esto enviale una captura de pantalla a @notsopr17 en discord, por favor #A111")
                    end
                    
                    print("#RError: ", 0)
                    print(errorstatus, 0)
                    
                    error("Error found.")
                    error(errorstatus)
                else
                    print("Function executed successfully")
                end
                return
            else
                print("Executing function without arguments")
                func()
                return
            end
        end
    end

end)


ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], threadpool:work(function(e) 
    
    if HasMapAuth ~= true then 
        
        local playerid = e['eventobjid']
        local content = e['content']
    
        print("content: ".. content)
    
        if #content >= 2 then 
        
            if content:sub(1, 1) == "/" then 
                print("Searching for commands.")
                local data = {Playerid = playerid, PlayerAuthLevel = playerAuthLevel, Content = content}
                local success, result = pcall(JSON.encode, JSON, data)
    
                if not success then
                    print("There was an error.")
                    print(result)
                else
                    print("Encoded without errors.")
                    local ret = Game:dispatchEvent("Command.CommandStart", {customdata = result})
                end   
            end

        end
    end 
end))
