 MinPlayerStart = 2 --Minimun num of players to start
 TimerName = "GameStartTimer"
 Countdown = false

print("Enoughpeoplescript")

ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    print("Battle started init")
    
    for i=1,math.huge do 
        
        _,playernum,playerarr = World:getAllPlayers(-1)
        
        if playernum >= MinPlayerStart and Countdown == false then 
            
            print("Enough players to start the game, starting")
            
            Countdown = true
            ret, Timerid = MiniTimer:createTimer(TimerName)
            print("Deleting residual timers")
            
            for z=0,Timerid do 
                
                print("Index: ".. Timerid)
                
                local ResidualTimerCheckExist = MiniTimer:isExist(z)
                
                if ResidualTimerCheckExist and Timerid ~= z then 
                    
                    MiniTimer:deleteTimer(z)
                    
                end
            end
            
            ret2 = MiniTimer:startBackwardTimer(Timerid, 15, false)	
            
            if ret == ErrorCode.OK and ret2 == ErrorCode.OK then 
                print("Timer Started with no problem!")
                MiniTimer:showTimerWnd(playerarr, Timerid, "#G Starting in ")	
            else 
                print("There was an error creating the timer") 
            end
            
        end
        
        if playernum < MinPlayerStart then 
            
            local TimerExist = MiniTimer:isExist(Timerid)
            
            if TimerExist == true then 
                
                local result = MiniTimer:deleteTimer(Timerid)
                
                if result == ErrorCode.OK then 
                    
                    print("Timer deleted with no problems")
                    Chat:sendSystemMsg("Countdown stopped as the number of players is less that 2", 0)
                    
                end
                
            end
            
        end
        
        threadpool:wait(1)
        
        end
    
end)

ScriptSupportEvent:registerEvent([=[minitimer.change]=], function(e) 
        
    local CurTimerId,CurTimerName,CurTimerTime = e['timerid'], e['timername'], e['timertime']
    print("CurTimerId: ".. CurTimerId)
    print("CurTimerTime: ".. CurTimerTime)
    if CurTimerName == TimerName then 
        
        if CurTimerTime >= 1 then 
            
            for i,v in ipairs(playerarr) do
            Actor:playSoundEffectById(v, 10955, 50, 1, false)
            end
        end
        
        if CurTimerTime <= 0 then 
            
            print("Start game tba")
            for i,v in ipairs(playerarr) do
                
            Actor:stopSoundEffectById(v, 10955)
            
            end
            
            MiniTimer:hideTimerWnd(playerarr, Timerid, "#G Starting in ")
            Chat:sendSystemMsg("#G Game started!", 0)
            end
        
        end
    
    end)
