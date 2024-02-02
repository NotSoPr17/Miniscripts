local Rooms = {
    Count = 0,
    RoomPlantilla = {
        CurPlayers = {},
        x, y, z = nil,
        Data = {
            RoundsPassed = 0,       
            RevolverRounds = 0,     
            RevolverRoundsArr = {}
        },
    },
}

local function AddRooms()
    Rooms.Count = Rooms.Count + 1
    print("Room added at position: " .. Rooms.Count)
    local NewRoom = setmetatable({}, {__index = Rooms.RoomPlantilla})
    rawset(Rooms, "Room" .. Rooms.Count, NewRoom)
    return NewRoom
end

local function RemoveRoom(index)
    print("Room removed at index: " .. index .. "\nCurrent number of rooms: " .. Rooms.Count)
    table.remove(Rooms, index)
end

local function RoomListDisplay()
      
      local k = 0
      
      for i=2,Rooms.Count do
        
        local RoomIndex = i - (i - 1) + k
        if Rooms["Room".. RoomIndex] then 
            print("Room: ".. RoomIndex)
        end
        k = k + 1
      end
  
  end

PlayerArr = {1, 2}

if #PlayerArr >= 2 then
    if Rooms.Count <= 1 then
        print("Game was created/ no available rooms")
        for i=1, 4 do AddRooms() end
        RemoveRoom(1)  -- Cambiado a 2 para eliminar la segunda habitación
        RoomListDisplay()
        --[[sucess, errormsg = pcall(RoomListDisplay)
        
        if not sucess then 
          
          print("Error found: ")
          print(errormsg)
        
        end]]--
        
    end
        
else
    -- Otra lógica si no hay suficientes jugadores
end
