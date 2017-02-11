local Entity = require("Entity")

local Unit = Entity:extend("Unit")

function Unit:draw()
end

function Unit:update(dt)
end

function Unit:init(x, y, id)
    Unit.super.init(self, x, y)

    self.id = id
    self.speed = 32
end


return Unit