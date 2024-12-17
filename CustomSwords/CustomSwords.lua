
local swordlist = {
    
    {id = 4097, dmg = 30, maxdmg = 100, incrementdmg = 10} --example sword
    
}

local sword = {}
local playerobj = {}

function sword:new(o)
    o = o or {}
    
    setmetatable(o, self)
    self.__index = self
    
    self.playerid = o.playerid -- owner
    self.itemid = o.itemid
    
    self.dmg = o.dmg
    self.maxdmg = o.maxdmg
    self.incrementdmg = o.incrementdmg
    
    return o 
end

function sword:addDmg(quantity) 
    
    print("old dmg: " .. self.dmg)
    
    self.dmg = math.min(self.dmg + (quantity or self.incrementdmg), self.maxdmg)
    
    print(" -> " .. self.dmg)
end

function sword:hurt(hurtplayerid) 
    if Actor:isPlayer(hurtplayerid) == ErrorCode.OK then
        
        local _, hurtplayerhp = Player:getAttr(hurtplayerid, PLAYERATTR.CUR_HP)
        local newhp = math.max(hurtplayerhp - self.dmg, 0)
    
        Player:setAttr(hurtplayerid, PLAYERATTR.CUR_HP, newhp)
     else
        
        local _, hurtplayerhp = Creature:getAttr(hurtplayerid, CREATUREATTR.CUR_HP)
        local newhp = math.max(hurtplayerhp - self.dmg, 0)
    
        Creature:setAttr(hurtplayerid, CREATUREATTR.CUR_HP, newhp)
    end
end

function playerobj:new(o) 
    o = o or {}
    
    setmetatable(o, self)
    self.__index = self
    
    self.playerid = o.playerid -- owner
    self.swords = {}
    
    print("Sword created for " .. self.playerid)
    
    return o 
end

function playerobj:addsword(data)
    print("adding sword " .. data.id .. " to " .. self.playerid)
    self.swords[data.id] = sword:new(data)
end

function playerobj:swordupgrade(id, customincrement)
    print("increasing damage to " .. self.playerid " sword")
    self.swords[id]:addDmg(customincrement)
end

function playerobj:swordattack(id, hurtplayerid)
    print(self.playerid .. " hurting " .. hurtplayerid)
    self.swords[id]:hurt(hurtplayerid)
end

local players = {}

ScriptSupportEvent:registerEvent([[Game.AnyPlayer.EnterGame]], function(e) 

    players[e.eventobjid] = playerobj:new({playerid = e.eventobjid}) -- add a playerobject for any new players
    
end) 

ScriptSupportEvent:registerEvent([[Game.AnyPlayer.LeaveGame]], function(e) 

    players[e.eventobjid] = nil -- delete the playerobject of any player that leaves
    
end) 

ScriptSupportEvent:registerEvent([[Player.AttackHit]], function(e) 
    
    local playerid = e['eventobjid']
    local hurtplayerid = e['toobjid'] --e['targetactorid']
    
    local _, curtoolid = Player:getCurToolID(playerid)
    
    players[playerid]:swordattack(curtoolid, hurtplayerid)
end)

ScriptSupportEvent:registerEvent([[Player.PickUpItem]], function(e) 
    
    local playerid = e['eventobjid']
    local itemid = e['itemid']
    
    for k,v in pairs(swordlist) do 
        if v.id == itemid then
            v.playerid = playerid
            players[playerid]:addsword(v)
        end
    end
    
end)
