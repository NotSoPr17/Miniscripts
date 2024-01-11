


ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    for i=1,1,0 do 
        
        _,_,PlayerArr = World:getAllPlayers(-1)
        for i,v in ipairs(PlayerArr) do
            
            local _,PlayerElement = VarLib2:getPlayerVarByName(v,3,"Element")
            local _,PlayerCanBend = VarLib2:getPlayerVarByName(v, 5 ,"CanBend")
            local _,CurName = Player:getNickname(v)
            
            if PlayerElement == 0 and not PlayerCanBend then 
            print("Player's element: ".. PlayerElement)
            print("Curname: ".. CurName)
            
            threadpool:wait(0.1)
            
            else
                
                Player:hideUIView(v, [[7322549134833989929]])
                Player:openUIView(v, [[7322943318342482217]])
                VarLib2:setPlayerVarByName(v,5,"CanBend",true)
                
            end
            
        end
        
        threadpool:wait(1)
        
    end
end)
