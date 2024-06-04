
local AuthVar = "AuthLevel"
local PlayerIsBanVar = "IsBan"

local maxTime = 60
local defaultAuthLevel = "Default"

local CommandsEnabled = true -- Los comandos estan habilitados
local UsesPass = true -- Se usa la contraseña del juego en caso de que el jugador no se encuentre en la whitelist
local KickOnTimeOut = false --  Cuando se agota el tiempo y el jugador no ha ingresado la contraseña del mapa, es kickeado
local InstantKick = false -- Si un jugador que no esta en la whitelist se une, sera kickeado (incompatible con UsesPass)

local AuthPlayers = {
    
    Default = {},
    
    Tester = {
       Pass = "TesterPass",
       12345678,
       87654321
    },

    Mod = {
        Pass = "ModPass",
        --286294036 -- Random UID
        
    },
    
    Admin = {
        Pass = "AdminPass",
        2769323, --UID YeyoCore
        75820841 --UID NotSoPr17 
        
    },
    
    SuperAdmin = {
        Pass = "SuperAdminPass",
        75820841
        
    }
    
}

-- No modifiques despues de esta linea si no sabes de scripting! --

local playerLogonStatus = {}
local MapAuthVer = 2

local authName = "MapAuth"
local authLogo = "⊗"
local authTextColors = "#c7D89FF"

ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    local sucess, result = pcall(JSON.encode, JSON, {Check = true})
    
    if sucess then
        print("Sending info to command script.")
        Game:dispatchEvent("MapAuth.Test", {customdata = result})
    end
end) 

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], function(e) 
    
    local playerid = e['eventobjid']
    local _, playernick = Player:getNickname(playerid)
    
    Chat:sendSystemMsg(authTextColors.. "Protected using ".. authName.. " Version ".. MapAuthVer, playerid)
    Chat:sendSystemMsg(authTextColors .."MapAuth by NotSoPr17 UID: 75820841".."\n" .."#G Inspired in WorldGuard by YeyoCore UID: 2769323" .. "\n", playerid)
    
    playerLogonStatus[playerid] = {}
    playerLogonStatus[playerid]['islogon'] = false
    playerLogonStatus[playerid]['rank'] = defaultAuthLevel
    playerLogonStatus[playerid]['nick'] = playernick
    playerLogonStatus[playerid]['timerid'] = 0
    
    VarLib2:setPlayerVarByName(playerid,4,AuthVar,defaultAuthLevel)
    
    local _, IsBan = VarLib2:getPlayerVarByName(playerid,5,PlayerIsBanVar)
    
    if IsBan then 
        
        Chat:sendSystemMsg("#R You are banned from this game. Kicking.", playerid)
        World:despawnActor(playerid)
        return
        
    end
    
    for k,v in pairs(AuthPlayers) do 
    
        for i,v in ipairs(v) do 
            
            if playerid == v then
                
                Chat:sendSystemMsg("Found, welcome!", playerid)
                Chat:sendSystemMsg("Your rank is: ".. k, playerid)
                
                playerLogonStatus[playerid]['rank'] = k
                VarLib2:setPlayerVarByName(playerid,4,AuthVar,k)
                
                playerLogonStatus[playerid]['islogon'] = true
                
                return
            end
        end
    
    end
    
    if UsesPass == true and not InstantKick == true then 
        
        local _, timerid = MiniTimer:createTimer(playernick .. "_timer", nil, true)
        playerLogonStatus[playerid]['timerid'] = timerid
        
        MiniTimer:showTimerWnd({playerid}, timerid,authTextColors.. authLogo .. authName.. " ")	
        MiniTimer:startBackwardTimer(timerid,maxTime,false)
        
        Chat:sendSystemMsg("#Y".."Your UID was not found in the authorized list, Using map password auth login", playerid)
        
        Actor:playSoundEffectById(playerid, 10713, 100, 1, true)
        
        Chat:sendSystemMsg("\n", playerid)
        Chat:sendSystemMsg("#G Please enter the map password!", playerid)
            
    elseif InstantKick == true and not UsesPass == true then
        
        Chat:sendSystemMsg("#R".. "You are not in the whitelist. If you believe this was an error, contact the map owner", playerid)
        World:despawnActor(playerid)
        
    else
        
        Chat:sendSystemMsg("#R" .. "InstantKick and UsesPass are incompatible.", playerid)
        return
        
    end
    
end)

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], function(e) 
    local playerid = e['eventobjid']
    playerLogonStatus[playerid] = nil
end)

ScriptSupportEvent:registerEvent([=[minitimer.change]=], function(e) 
    
    local curTimerId = e['timerid']
    local curTimerTime = e['timertime']
    local curTimerName = e['timername']
    
    for k,v in pairs(playerLogonStatus) do 
        
        local playerid = k
        
        if curTimerTime <= 0 and curTimerName == v['nick'].."_timer" then 

            MiniTimer:hideTimerWnd({playerid}, curTimerId, authTextColors.. authLogo .. authName.. " ")
            
            if KickOnTimeOut == true then 
                
                Chat:sendSystemMsg("#R" .. "Kicked because of timeout.", playerid)
                World:despawnActor(playerid)
                
            else
                
                MiniTimer:deleteTimer(curTimerId)            
                v['rank'] = defaultAuthLevel
                
                VarLib2:setPlayerVarByName(playerid,4,AuthVar, defaultAuthLevel)
                v['islogon'] = true
                
                Chat:sendSystemMsg("Could not input the map password on time. Setting default rank.", playerid)
                
            end
            
        end
                
        if v['islogon'] == true and curTimerName == v['nick'].."_timer" then 
            
            if MiniTimer:isExist(curTimerId) then 
                
                MiniTimer:deleteTimer(curTimerId)
            
            end
            
        end
    end

end)

ScriptSupportEvent:registerEvent("Player.NewInputContent", function(e)
    local playerid = e['eventobjid']
    local content = e['content']
    
    local v = playerLogonStatus[playerid]

    if #content >= 2 then 
        if CommandsEnabled and content:sub(1, 1) == "/" then 
            print("Searching for commands...")
            local data = { Playerid = playerid, PlayerAuthLevel = v['rank'],Content = content }
            local success, result = pcall(JSON.encode, JSON, data)
    
            if not success then
                print("Error encoding data:")
                print(result)
            else
                print("Encoded without errors.")
                Game:dispatchEvent("Command.CommandStart", { customdata = result })
            end   
        else
            
            if v['rank'] == nil or v['rank'] == "Default" and not v['islogon'] == true then
                    
                for key, val in pairs(AuthPlayers) do 
                    
                    if val["Pass"] then
                        if content == val["Pass"] then
                                
                            Chat:sendSystemMsg("Welcome!", playerid)
                            Chat:sendSystemMsg("Your permission level is: " .. key, playerid)
                            
                            VarLib2:setPlayerVarByName(playerid, 4, AuthVar, key)
                            
                            playerLogonStatus[playerid]['rank'] = key
                            playerLogonStatus[playerid]['islogon'] = true
                                
                            return

                        end
                    end
                end
                
                    Actor:playSoundEffectById(playerid, 10949, 100, 1, false)
                    Player:notifyGameInfo2Self(playerid, "#b#RIncorrect password. #n #YTry again")
                    
                end
            end
        end
end)
