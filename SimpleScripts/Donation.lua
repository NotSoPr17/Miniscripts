
ScriptSupportEvent:registerEvent([=[Developer.BuyItem]=], function(e) 
    
    local playerid = e['eventobjid']
    local itembought = e['itemid']
    
    print("playerid: ".. playerid)
    print("item bought: ".. itembought)
    
    if itembought == 4098 then 
        
        local _,playernick = Player:getNickname(playerid)
        Chat:sendSystemMsg( "#B"..playernick .."#cf7ff0d Donates, thanks!", 0)
        
        end
    
    if itembought == 4097 then 
        
        Player:notifyGameInfo2Self(playerid, "Muchas gracias por su compra! :)")
        
    end
    
end)
