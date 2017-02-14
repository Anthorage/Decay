local UnitData = require("unitdata")
local UnitType = { namesearch={} }

function UnitType:getByName(name)
    return UnitType.namesearch[name]
end

function UnitType:getByID(id)
    return UnitType[id]
end

function UnitType.makeStats(stats)
    return { health=stats.health or 1, damage=stats.damage or 1, armor=stats.armor or 1, attackspeed = stats.attackspeed or 1.0,
            movespeed = stats.movespeed or 1.0, attackrange = stats.attackrange or 1.0, sightrange = stats.sightrange or 4.0}
end


function UnitType.new(name, id, animations, stats)
    local ret = { name=name, id=id, stats=UnitType.makeStats(stats), animations=animations }


    UnitType[id] = ret
    UnitType.namesearch[name] = ret

    return ret
end



local function setupUnitTypes()
    --local anim = move = {}
    --UnitType.GORLATH = UnitType.new("Gorlath", 0, {}, {health=100,damage=10,armor=1,movespeed=3})
    --UnitType.SKELETON = UnitType.new("Skeleton", 1, {}, {health=16,damage=4,armor=0,movespeed=3})
    for key, val in pairs(UnitData) do
        UnitType[key] = UnitType.new( val.name, val.id, val.animations, val.stats )
    end
end

setupUnitTypes()


return UnitType