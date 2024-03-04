
--[[

HasMapAuth es verdadero por defecto
Aunque esta en mis planes hacer que el script detecte automaticamente si tienes mapauth o no
Tambien esta en mis planes proximos agregar un comando de ayuda que si funcione bien, no como el actual que no hace mucho
{Playerid = playerid, PlayerAuthLevel = playerAuthLevel, Content = content}


]]--

local HasMapAuth = true

function helpcommand(authLvl)
    
    print("Help command TBA")
    
end

function teleportcommand(x,y,z, triggerplayer) 
    Chat:sendSystemMsg("Teleporting!", triggerplayer)
    Actor:setPosition(triggerplayer, x, y, z)
end

function givecommand(itemid, quantity, triggerplayer)
    Chat:sendSystemMsg("Adding items to backpack!", triggerplayer)
    Backpack:addItem(triggerplayer, itemid, quantity)
end

function kickcommand(kickedplayer, triggerplayer) 
    
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
        tp = teleportcommand
    },

    Admin = {
        
        help = helpcommand,
        tp = teleportcommand,
        give = givecommand,
        kick = kickcommand
    }
    
}

-- ... (Código existente)

ScriptSupportEvent:registerEvent("Command.CommandStart", function(e) 
    
    print("Command.CommandStart event triggered")
    
    local playerid = e.CurEventParam.CloudValue['Playerid']
    local playerauthlvl = e.CurEventParam.CloudValue['PlayerAuthLevel']
    local content = e.CurEventParam.CloudValue['Content']
    
    print("Player ID: " .. playerid)
    print("Player Auth Level: " .. playerauthlvl)
    print("Content: " .. content)
    
    print("Searching for commands")
    
    local commandSimple, argsString = content:sub(2):lower():match("(%S+)%s*(.*)")

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
                local success, errorstatus = pcall(func, unpack(args))
                
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

        end --Contenido >= 2
    end --Tiene mapauth
end))
