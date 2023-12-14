
-- This script was the first i ever made, inspired by worldguard from yeyocore UID: 2769323

local MaxTime = 60
local AUTHName = "MapAuth"
local AUTHLogo = "⊗"
local AUTHColor = "#c7D89FF"
local PlayerAuth = false

local AuthPasses = {}
local AuthPlayers = {}

AuthPasses[1] = "VisitantePass"
AuthPasses[2] = "NuevoPass"
AuthPasses[3] = "TesterPass"
AuthPasses[4] = "ModPass"

AuthPlayers[1] = 1002769323 -- Map creator UID (Here your uid) --
AuthPlayers[2] = 75820841 -- Extra auth UID 1 Por alguna razon hay que añadir un 10 antes de la uid para que funcione (en mi caso)
AuthPlayers[3] = 2769323 -- Extra auth UID 2
AuthPlayers[4] = 2769324 -- Extra auth UID 3 (modify the UID as needed)
AuthPlayers[5] = 2769325 -- Extra auth UID 4 (modify the UID as needed)

function BuscarValor(tabla, valor)
    for _, v in ipairs(tabla) do
        if v == valor then
            return true
        end
    end
    return false
end

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], function(e) 
  
    local playerid = e['eventobjid']
    globalplayerid = playerid
   
   Chat:sendSystemMsg("Closed multiplayer testing, only allowlist users are allowed to play/ if you have a ModPass type it \n #GAll the scripts are avaible on my discord (@notsopr17) and on my github",playerid)
   Actor:playSoundEffectById(playerid, 10713, 100, 1, true)
   
    for i,v in ipairs(AuthPlayers) do 
        
        if playerid == v  then 
            
            PlayerAuth = true
            Chat:sendSystemMsg("Eres un usuario autorizado",playerid)
            Actor:stopSoundEffectById(playerid, 10713)
            
            return
            
        end
        
    end
    
    _,_,PlayerArr = World:getAllPlayers(-1)
    _, MapAuthTimer = MiniTimer:createTimer("MapAuth", nil, false)
    MiniTimer:startBackwardTimer(MapAuthTimer, MaxTime, false)
    MiniTimer:showTimerTips(PlayerArr, MapAuthTimer, AUTHColor.. AUTHLogo.. AUTHName.." ", true)
    
    end)

ScriptSupportEvent:registerEvent([=[minitimer.change]=], function(e) 
    
    local _, seconds = MiniTimer:getTimerTime(e.timerid)

    
    if PlayerAuth == true then 
        
        MiniTimer:deleteTimer(MapAuthTimer)
        return
        
    end
    
    if seconds <= 10 then 
        
        Player:notifyGameInfo2Self(globalplayerid, AUTHName.." #R#b⚠TYPE A PASSWORD NOW!  #B SECONDS LEFT: #G".. seconds)
        
    end
    
    if seconds <= 0 then 
        
        local playernick = Player:getNickname(globalplayerid)
        Actor:stopSoundEffectById(globalplayerid, 10713)
        Chat:sendSystemMsg(playernick.. " Was kicked by: SYSTEM", 0)
        World:despawnActor(globalplayerid)
        MiniTimer:deleteTimer(MapAuthTimer)
        
        end
    
end)

function Passhandler(args)
    local content = args['content']
    local playerid = args['eventobjid'] --la id del jugador que escribio en el chat
    local Check_pass = BuscarValor(AuthPasses, content)

    if Check_pass == true then
        PlayerAuth = true
        Actor:stopSoundEffectById(playerid, 10713)

    elseif Check_pass == false and PlayerAuth == false then
        
        Player:notifyGameInfo2Self(playerid, AUTHName.." #R#b⚠WRONG PASSWORD #Wtry again#n")
        Actor:playSoundEffectById(playerid, 10949, 100, 1, false)
        
    end
    
        if content == AuthPasses[2] then
            print("Login normal") -- ==Implementar==
            logon = 0
            VarLib2:setPlayerVarByName(playerid,5,"IsTester",true)

            
        elseif content == AuthPasses[1] then
            print("Login Visitante") -- ==Implementar==
            logon = 1
            VarLib2:setPlayerVarByName(playerid,5,"IsTester",true)
            
        elseif content == AuthPasses[3] then
            print("Login Tester") -- ==Implementar==
            logon = 2
            VarLib2:setPlayerVarByName(playerid,5,"IsTester",true)
            
        elseif content == AuthPasses[4] then
            
            print("Login especial") -- ==Implementar==
            logon = 3
            Check_pass = true
            AUTH = true
            VarLib2:setPlayerVarByName(playerid,5,"IsTester",true)
                
        end


end


ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], Passhandler)
