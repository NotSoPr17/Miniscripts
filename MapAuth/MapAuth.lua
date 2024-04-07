local AuthVar = "AuthLevel"

-- Ya casi

local MapAuthVer = 1.1

local maxTime = 60

local authName = "MapAuth"
local authLogo = "⊗"
local authTextColors = "#c7D89FF"

local playerAuthLevel = nil

local CommandsEnabled = true -- Los comandos estan habilitados
local UsesPass = true -- Se usa la contraseña del juego en caso de que no se encuentre en los jugadores cn autorizacion

local AuthPasses = {}
local AuthPlayers = {
    
    Tester = {
       Pass = "TesterPass",
       12345678,
       87654321
    },
    
    Mod = {
        Pass = "ModPass",
        286294036 -- Random UID
        
    },
    
    Admin = {
        Pass = "AdminPass",
        2769323, --UID YeyoCore
        1075820841 --UID NotSoPr17 
        
    } --Full admin powers
    
}

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], function(e) 
    
    local playerid = e['eventobjid']
    
    Chat:sendSystemMsg(authTextColors.. "Protected using ".. authName.. " Version ".. MapAuthVer, playerid)
    Chat:sendSystemMsg(authTextColors .."MapAuth by NotSoPr17 UID: 75820841".."\n" .."#G Original WorldGuard by YeyoCore UID: 2769323" .. "\n", playerid)
    
    for k, playerTable in pairs(AuthPlayers) do 
        
        if type(playerTable) == "table" then
            
           -- print("tabla")
            
            for _, v in pairs(playerTable) do
                
                --print("key: ".. k)
                
                if playerid == v then
                    Chat:sendSystemMsg("Found, welcome!", playerid)
                    Chat:sendSystemMsg("Your perm level is: ".. k,playerid)--:gsub("Ids",""), playerid)
                    
                    --VarLib2:setPlayerVarByName(playerid,4,AuthVar,k)
                    playerAuthLevel = k
                    
                    return
                end
            end
        end
    end
    
    if UsesPass == true then
        
    Chat:sendSystemMsg("#Y".."Your UID was not found in the authorized list, Using map password auth login", playerid)
    _, timerid = MiniTimer:createTimer("MapAuthTimer", nil, true)
    MiniTimer:showTimerWnd({playerid}, timerid,authTextColors.. authLogo .. authName.. " ")	
    MiniTimer:startBackwardTimer(timerid,maxTime,false)
    
    Actor:playSoundEffectById(playerid, 10713, 100, 1, true)
    
    Chat:sendSystemMsg("\n", playerid)
    Chat:sendSystemMsg("#G Please enter the map password!", playerid)
    
    end
end)

ScriptSupportEvent:registerEvent([=[minitimer.change]=], function(e) 
    
    local curTimerId = e['timerid']
    local curTimerTime = e['timertime']
    local curTimerName = e['timername']
    
    --[[print("CurTimerId: ".. curTimerId)
    print("CurTimerName: ".. curTimerName)]]--
    
    
    if  curTimerName == "MapAuthTimer" then 
        
        --print("Timer found")
        
        if playerAuthLevel ~= nil then 
        
            ret = MiniTimer:deleteTimer(curTimerId)
            --print("Ret delete: ".. ret)
        end

        if curTimerTime <= 0 then 
            ret = MiniTimer:deleteTimer(curTimerId)
            Game:doGameEnd()
            return
        end
        
    end
    
    --TableDisplayAll(e)
    
end)

ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], function(e) 
    local playerid = e['eventobjid']
    local content = e['content']

    if #content >= 2 then 
        if CommandsEnabled and content:sub(1, 1) == "/" then 
            print("Searching for commands. MapAuthScript")
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
        
        if playerAuthLevel == nil then
            for key, val in pairs(AuthPlayers) do 
                --print("ContentKey: " .. key)
                if val["Pass"] then
                    --print("Password exitst")
                    if content == val["Pass"] then 
                        Chat:sendSystemMsg("Found, welcome!", playerid)
                        Chat:sendSystemMsg("Your perm level is: " .. key, playerid)
                        playerAuthLevel = key
                    
                    else
                        
                        Actor:playSoundEffectById(playerid, 10949, 100, 1, false)
                        Player:notifyGameInfo2Self(playerid, "#b".. "#R" .. "Incorrect password. #n #Y Try again")
                        
                    end
                end
            end
        end
    end
end)
