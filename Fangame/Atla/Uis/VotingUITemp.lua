--Version 0.3

local AllMaplist = {
    
    Map1 = {
        
        Name = "LAVAMAP",
        Pos_Heroes = {},
        Pos_Villains = {}
        
    },    
    Map2 = {
        
        Name = "TEMPLEMAP",
        Pos_Heroes = {},
        Pos_Villains = {}
        
    },    
    Map3 = {
        
        Name = "ICEBERGMAP",
        Pos_Heroes = {},
        Pos_Villains = {}
        
    },    
    Map4 = {
        
        Name = "EARTHMAP",
        Pos_Heroes = {},
        Pos_Villains = {}
        
    },
    
}
local AllModeList = {"TDM","LTS","CTF"}
--------------
local _,_,PlayerArr = World:getAllPlayers(-1)

local VoteUi = [[7323242840771770665]]

local VoteGlobalVar = "Vote_Started"
local GameStartGlobalVar = "Game_Started"

local VoteTimerName = "VoteTimer"
local countdown = false

function BuscarValor(tabla, valor)
    for _, v in ipairs(tabla) do
        if v == valor then
            return true
        end
    end
    return false
end

    print("Votescript")

	
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
				
        else --I'm going to change this so you can change your votes, this script is a rough draft right now
        
            Chat:sendSystemMsg("#R You already voted!", playerid)    
            Actor:playSoundEffectById(playerid, 10949, 100, 1, false)
            
        end
    end

end)

ScriptSupportEvent:registerEvent([=[Game.Start]=], threadpool:work(function() 
    
    for i=1,math.huge do
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
            
        if not countdown then 
            
            countdown = true
            _, TimerId = MiniTimer:createTimer(VoteTimerName)
            MiniTimer:startBackwardTimer(TimerId,30,false)
        end
            
        end
        threadpool:wait(0.5)
	 end
    
end))

ScriptSupportEvent:registerEvent([=[minitimer.change]=], function(e) 
    
    local CurTimerName = e['timername']
    local CurTimerTime = e['timertime']
    
    if CurTimerName == VoteTimerName then 
        
        if CurTimerTime <= 0 then 
            
            local val = 0
            local index = 0
            
            for i=1,4 do
                local _,comp = VarLib2:getGlobalVarByName(3,"Map"..i.. "_Votes")
                
                if comp > val then 
                
                    val = comp
                    index = i
                    
                end
                
            end
            if index > 0 and val > 0 then 
                Chat:sendSystemMsg("#Y" .. "Map ".. index .. " won with ".. val.. " votes",0)
            else 
                Chat:sendSystemMsg("#Y".. "A random map will be chosen...", 0)    
            end
            
            for i,v in ipairs(PlayerArr) do
                Player:hideUIView(v, VoteUi)
                VarLib2:setGlobalVarByName(5,GameStartGlobalVar,true)
                VarLib2:setGlobalVarByName(5,VoteGlobalVar,false)
                return
            end
            
        end
        
    end
    
end)

-----

local Cur = {}
local CurM = {}
local numberOfMaps = 0  -- Variable to keep track of the number of maps


for key, value in pairs(AllMaplist) do
    if type(value) == "table" and value["Name"] then
        numberOfMaps = numberOfMaps + 1
    end
end

print("The numbers of maps in the master array is: ".. numberOfMaps)

ScriptSupportEvent:registerEvent([=[UI.Show]=], function(e) 
    
    if e['CustomUI'] == VoteUi then 
        for i = 1, 4 do 
            local randomMapIndex = math.random(1, numberOfMaps) --(2) 6 8 10 12, 7 9 11 13
            table.insert(Cur, AllMaplist["Map" .. randomMapIndex])
            CurM[#CurM + 1] = AllModeList[math.random(#AllModeList)]
        end
        
        for i, chosenMap in ipairs(Cur) do 
            print("MapIndex: " .. i .. "\nName of the chosen map: " .. chosenMap["Name"] .. "\nMode chosen for the map: " .. CurM[i])
        end
        
        local k1 = 0
        
        for i=6,12,2 do -- [[7323242840771770665_6]], [[7323242840771770665_12]] modo: [[7323242840771770665_7]], [[7323242840771770665_13]]
            Customui:setText(e['eventobjid'], VoteUi, VoteUi .. "_" .. i .. "", Cur[ (i-(i-1)) + k1 ]["Name"]) -- (6 - (6-1) + n )
            k1 = k1 + 1
        end
        
        local k2 = 0
        
        for i=7,13,2 do 
            Customui:setText(e['eventobjid'], VoteUi, VoteUi .. "_" .. i .. "", CurM[(i-(i-1)) + k2]) -- (6 - (6-1) + n )
            k2 = k2 + 1
        end -- 7 
        
    end
    
end)
