
local MasterUi = {
    
    Id = [[7322549134833989929]],
    
    Btn = {
        BtnFire = [[7322549134833989929_9]],
        BtnAir = [[7322549134833989929_3]],
        BtnWater = [[7322549134833989929_5]],
        BtnEarth = [[7322549134833989929_7]]
        
    },
}

ScriptSupportEvent:registerEvent([=[UI.Button.Click]=], function(e) 
    print("\n")
    
    local playerid = e['eventobjid']
    local CurUi = e['CustomUI']
    local CurUiElement = e['uielement']
    
    print("CurUi: ".. CurUi)
    print("Curelement".. CurUiElement)
    
    if CurUi == MasterUi.Id then
        
        if CurUiElement == MasterUi.Btn.BtnFire then 
        
            print("Fire element selected")
            VarLib2:setPlayerVarByName(playerid,3,"Element",1)
        
        end
        
        if  CurUiElement == MasterUi.Btn.BtnAir then 
            
            print("Air element selected")
            VarLib2:setPlayerVarByName(playerid,3,"Element",2)
            
        end
        
        if  CurUiElement == MasterUi.Btn.BtnWater then 
            
            print("Water element selected")
            VarLib2:setPlayerVarByName(playerid,3,"Element",3)
            
        end
        
        if  CurUiElement == MasterUi.Btn.BtnEarth then 
            
            print("Earth element selected")
            VarLib2:setPlayerVarByName(playerid,3,"Element",4)
            
        end
        
    end
end)
