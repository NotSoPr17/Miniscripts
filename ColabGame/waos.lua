local Rooms = {
    Count = 0,
    RoomPlantilla = {
        Status = nil, --"False or nil is inactive" true is active
        CurPlayers = {},
        MaxPlayers = 20,
        x, y, z = {},
        
        Data = {
            RoundsPassed = 0,       
            RevolverRounds = 0,     
            RevolverRoundsArr = {}
        },
    },
}

local CommandList = {
    
    help = function() Chat:sendSystemMsg("Helpcommand",0) end,
    roomcreate = function(args) end,
    errortestfunc = function() assert(false, "Error intencional") end
    
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
        local commandSimple, argsString = content:sub(2):lower():match("(%S+)%s*(.*)")

        print("Commandsimple with no prefix or digits: " .. commandSimple)
        print("Arguments: " .. argsString)

        local args = {}

        for arg in argsString:gmatch("(%S+)") do
            if tonumber(arg) then
                args[#args + 1] = tonumber(arg)
            else
                args[#args + 1] = arg
            end
        end

        for key, func in pairs(CommandList) do 
            if commandSimple == key then 
                print("FUNCTION FOUND")
                
                if #args >= 1 then 
                
                sucess, errorstatus = pcall(func, unpack(args) )
                
                if not sucess then 
                    
                    Chat:sendSystemMsg("#YError found \nIf you see this, send a screenshot to @notsopr17 on discord, please #A111", 0)
                    Chat:sendSystemMsg("#YSe encontro un error \n Si ves esto enviale una captura de pantalla a @notsopr17 en discord, por favor #A111", 0)
                    
                    threadpool:wait(3)
                    
                    Chat:sendSystemMsg("#RError: ", 0)
                    Chat:sendSystemMsg(errorstatus, 0)
                    
                    error("Error found.")
                    error(errorstatus)
                    
                end
                
                
                else
                    
                    func()
                    
                end
                
            end
        end
    end

    
end)
