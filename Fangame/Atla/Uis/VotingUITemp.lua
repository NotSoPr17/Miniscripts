--Version 0.1 
local VoteUi = [[7323242840771770665]]
local VoteArr = {0,0,0,0}

local VoteGlobalVar = "Vote_Started"
local GameStartGlobalVar = "Game_Started"

    ScriptSupportEvent:registerEvent([=[UI.Button.Click]=], function(e) 
	
	local playerid = e['eventobjid']
    local CurUi = e['CustomUI']
    local CurElement = e['uielement']	
	
    end)
    
function VotesSync2client() 
    threadpool:work(function()
        
        for i=1,math.huge do
        local ret,Vote = VarLib2:getGlobalVarByName(5,VoteGlobalVar)
        
        local _,Map1Count = VarLib2:getGlobalVarByName(3,"Map1_Votes") --Voy a mejorar esto con un bucle for cuando tenga tiempo
        local _,Map2Count = VarLib2:getGlobalVarByName(3,"Map2_Votes")
        local _,Map3Count = VarLib2:getGlobalVarByName(3,"Map3_Votes")
        local _,Map4Count = VarLib2:getGlobalVarByName(3,"Map4_Votes")

        if Vote then 
        
        end
        
        threadpool:wait(1)
        
        end
    end)
end

ScriptSupportEvent:registerEvent([=[Game.Start]=], VotesSync2client)
