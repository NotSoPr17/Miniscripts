local Rooms = {
    Count = 0,
    RoomPlantilla = {
        Status = nil, --"False or nil is inactive" true is active
        CurPlayers = {},
        MaxPlayers = 20,
        x, y, z = {Target },
        
        Data = {
            RoundsPassed = 0,       
            RevolverRounds = 0,     
            RevolverRoundsArr = {}
        },
    },
}

local CommandList = {
    
    help = function(e) Chat:sendSystemMsg("Helpcommand",0) end
    
}

local function AddRooms(RoomNum)
  
    Rooms.Count = Rooms.Count + 1
    print("Room added at position: " .. Rooms.Count)
    local NewRoom = setmetatable({}, {__index = Rooms.RoomPlantilla})
    --rawset(Rooms, "Room" .. Rooms.Count, NewRoom)
    Rooms["Room" .. Rooms.Count] = NewRoom
    NewRoom.Status = true
    return NewRoom
end

local function RemoveRoom(index)
    
    if type(index) ~= number then 
      print("Index is not a number")
      return
    end
    
    if index == nil or index < 0 then 
      print("Index is nil or less than 0")
      return
    end
    
    if index > Rooms.Count then 
    
      print("Room does not exist, number is greater than count")
      return
    end
    
    local k = 0
        
    for i=1,Rooms.Count do 
        local RoomIndex = i - (i - 1) + k
        local CurRoom = Rooms["Room".. RoomIndex]
        
        if RoomIndex == index then 
            CurRoom.Status = nil
            return
        end
        k = k + 1
    end
end

local function RoomListDisplay()
      
      local k = 0
      
      Chat:sendSystemMsg("Existing rooms: ")
      
      for i=1,Rooms.Count do
        
        local RoomIndex = i - (i - 1) + k
        
        local CurRoom = Rooms["Room".. RoomIndex]
        
        if CurRoom and CurRoom.Status then 
            print("Room: ".. RoomIndex)
            Chat:sendSystemMsg("Room" .. RoomIndex, 0)
        end
        k = k + 1
      end
  
  end

function BuscarValor(tabla, valor)
    for _, v in ipairs(tabla) do
        if v == valor then
            return true
        end
    end
    return false
end

ScriptSupportEvent:registerEvent([=[Game.Start]=], function(e) 
    
    for i=1, math.huge do
        
        _,_,PlayerArr = World:getAllPlayers(-1)
        
        if #PlayerArr >= 1 then
            --Chat:sendSystemMsg("Warning: debug mode", 0)
            if Rooms.Count <= 1 then
      
            print("Game was created/ no available rooms")
            for i=1, 4 do AddRooms() end
        
            RemoveRoom(2)  -- Cambiado a 2 para eliminar la segunda habitación
            RoomListDisplay()
            
            end
        
        else
            -- Otra lógica si no hay suficientes jugadores
        end    
        threadpool:wait(0.5)
    end 
end)

ScriptSupportEvent:registerEvent([=[Player.InputContent]=], function(e) 
    
    local playerid = e['eventobjid']
    local content = e['content']
    
    if #content >= 2 and content:sub(1, 1) == "/" then 
        local commandsimple = content:sub(2):lower():gsub("[0-9]", "")

        print("Commandsimple with no prefix or digits: " .. commandsimple)

        for key, func in pairs(CommandList) do 
            if commandsimple == key then
                
                print("FUNCTION FOUND")
                func()
                
            end
        end
    end
    
end)

