--Version 0.1 
local _,_,PlayerArr = World:getAllPlayers(-1)

local VoteUi = [[7323242840771770665]]

local VoteGlobalVar = "Vote_Started"
local GameStartGlobalVar = "Game_Started"

function BuscarValor(tabla, valor)
    for _, v in ipairs(tabla) do
        if v == valor then
            return true
        end
    end
    return false
end

    print("Votescript")

--for i=1,math.huge do

    --threadpool:wait(0.5)
	
    ScriptSupportEvent:registerEvent([=[UI.Button.Click]=], function(e)  
        
    local playerid = e['eventobjid']
    local CurUi = e['CustomUI']
    local CurElement = e['uielement']
    
    if BuscarValor({[[7323242840771770665_2]],[[7323242840771770665_3]],[[7323242840771770665_4]],[[7323242840771770665_5]]}, CurElement) then  --7323242840771770665_2 , 7323242840771770665_5
        
        local Num = CurElement:sub(#CurElement,#CurElement)
        local _,CurVotes = VarLib2:getGlobalVarByName(3,"Map".. (Num - 1) .. "_Votes")
        local _,PlayerVote = VarLib2:getPlayerVarByName(playerid,5,"Player_vote")
        
        if not PlayerVote then
				
            VarLib2:setGlobalVarByName(3,"Map".. (Num - 1) .. "_Votes", (CurVotes + 1) )
            VarLib2:setPlayerVarByName(playerid,5,"Player_vote", true)
            print("Button num: ".. Num)
            print("Player voted: ".. PlayerVote)
				
        else --I'm going to change this so you can change your votes, this script is a rough draft right now
        
            Chat:sendSystemMsg("#R You already voted!", playerid)    
            Actor:playSoundEffectById(playerid, 10949, 100, 1, false)
            
        end
    end

end)

    ScriptSupportEvent:registerEvent([=[Game.RunTime]=], function(e) 
    
    local ret,Vote = VarLib2:getGlobalVarByName(5,VoteGlobalVar)
    
        if Vote then
            
            --print("Inicio de la votacion")
            for i=1,4 do 
                local _,CurMapVotes = VarLib2:getGlobalVarByName(3,"Map"..i.. "_Votes")
                
                for z,v in ipairs(PlayerArr) do -- [[7323242840771770665_14]] to [[7323242840771770665_17]]
                    local ret = Customui:setText(v, [[ 7323242840771770665]],VoteUi.. "_" .. (13+i) .. "", "" .. CurMapVotes)	
                    --print("Textsetret: ".. ret)
                end
            end
        end
	
    end)
--end    
