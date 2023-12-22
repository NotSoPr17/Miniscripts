
local JetpackActivated = false

ScriptSupportEvent:registerEvent([=[Player.InputKeyDown]=], function(e) 
    
    local ActivationKey = "Z"
    
    if e['vkey'] == ActivationKey and JetpackActivated == false then 
        
    JetpackActivated = true
    print("Jetpack activated")
        
    elseif e['vkey'] == ActivationKey and JetpackActivated == true then
        
    JetpackActivated = true
    print("Jetpack disabled")
        
    end
    
end)

ScriptSupportEvent:registerEvent([=[Player.InputKeyOnPress]=], function(e) 

local playerid = e['eventobjid']
local curkey = e['vkey']

local UpKey = "Q"
local DownKey = "E"

local _,px,py,pz = Actor:getPosition(playerid)

if curkey == UpKey then
    print("tba")
end


end)
