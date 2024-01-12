
local MapVoteUi = [[7323242840771770665]]
function Secondfunc()
    threadpool:work(function() --Multi threading function
    
        for i=1,math.huge do 
        
            local result, IsGameStarted = VarLib2:getGlobalVarByName(5,"Game_Started")
        
            if result == ErrorCode.OK then 
                if IsGameStarted then 
                    local _,_,as = World:getAllPlayers(-1)
                    for i,v in ipairs(as) do
                        Player:openUIView(v, MapVoteUi)
                    end
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
end

ScriptSupportEvent:registerEvent([=[Game.Start]=], Secondfunc)
