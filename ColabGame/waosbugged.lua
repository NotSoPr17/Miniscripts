local Rooms = {
    Count = 0,
    RoomPlantilla = {
        Status = nil, --"False or nil is inactive" true is active
        CurPlayers = {},
        MaxPlayers = 20,
        x, y, z = nil,
        Data = {
            RoundsPassed = 0,       
            RevolverRounds = 0,     
            RevolverRoundsArr = {}
        },
    },
}

local function AddRooms(RoomNum)
    Rooms.Count = Rooms.Count + 1
    print("Room added at position: " .. Rooms.Count)
    local NewRoom = setmetatable({}, {__index = Rooms.RoomPlantilla})
    rawset(Rooms, "Room" .. Rooms.Count, NewRoom)
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
    
    --[[sucess, status = pcall(table.remove, Rooms, index)
    
    if not sucess then
      print("\n(Remove room function)")
      print("Error found: ".. "\n".. status .. "\n")
    end]]--
    
end

local function RoomListDisplay()
      
      local k = 0
      
      for i=1,Rooms.Count do
        
        local RoomIndex = i - (i - 1) + k
        
        local CurRoom = Rooms["Room".. RoomIndex]
        
        if CurRoom and CurRoom.Status then 
            print("Room: ".. RoomIndex)
        end
        k = k + 1
      end
  
  end
--Scriptsupportregisterevent
PlayerArr = {1, 2}

if #PlayerArr >= 2 then
    if Rooms.Count <= 1 then
      
        print("Game was created/ no available rooms")
        for i=1, 4 do AddRooms() end
        RemoveRoom(2)  -- Cambiado a 2 para eliminar la segunda habitación
        RoomListDisplay()

        
    end
        
else
    -- Otra lógica si no hay suficientes jugadores
end
