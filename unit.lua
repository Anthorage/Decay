local Entity = require("Entity")

local Unit = Entity:extend("Unit")

local Animation = require("animation")

local Shape = require("libs/HC.shapes")

function Unit:draw()
    self.graphic:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
end

function Unit:update(dt)
end

function Unit:init(x, y, kind, player, properties)
    Unit.super.init(self, x, y)

    local anim = kind.animations
    local size = self:mySize()

    self.kind = kind

    self.player = player
    self.properties = properties

    self.hitcircle = Shape:newCircleShape(self.x, self.y, 16)

    self.graphic = Animation:new(self.scene.unittexture, anim.stand.startx, anim.stand.starty,
    self:mySize(), self:mySize())

    self.graphic:addFrames("move", anim.move.startx, anim.move.starty, anim.move.ammount, anim.move.time,
     anim.move.keyframes, anim.move.options)

    self.graphic:addFrames("attack", anim.attack.startx, anim.attack.starty, anim.attack.ammount, anim.attack.time,
     anim.attack.keyframes, anim.attack.options)

     self.stats = { health = kind.stats.health, damage=kind.stats.damage, armor=kind.stats.armor,
      attackspeed=kind.stats.attackspeed, movespeed=kind.stats.movespeed*size, sightrange=kind.stats.sightrange*size,
       attackrange=kind.stats.attackrange*size }
end


return Unit