
local MinPlayerStart = 2 --Minimun num of players to start

ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    for i=1,1,0 do 
        
        _,playernum,_ = World:getAllPlayers(-1)
        
        if playernum >= MinPlayerStart then 
            
            print("TBA start game") --To be added
            
            end
        
        threadpool:wait(0.5)
        
        end
    
    end)
