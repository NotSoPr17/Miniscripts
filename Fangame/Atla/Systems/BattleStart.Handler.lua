
ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    for i=1,1,0 do 
        
        local result, IsGameStarted = VarLib2:getGlobalVarByName(5,"Game_Started")
        
        if result == ErrorCode.OK then 
            if IsGameStarted then 
                
                Chat:sendSystemMsg("Game has started!", 0)
                
            end
            
        else
            
            break
            
        end
        
        threadpool:wait(1)
    end
    
    Chat:sendSystemMsg("A bug has been found, reseting the map in 5 seconds, sorry for the inconvenience!", 0)
    threadpool:wait(5)
    Game:doGameEnd()

end)
