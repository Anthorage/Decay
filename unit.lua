local Entity = require("Entity")

local Unit = Entity:extend("Unit")

local Animation = require("animation")

local Shape = require("libs/HC.shapes")

local UnitType = require("unittype")

function Unit:draw()
    self.graphic:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
end

function Unit:update(dt)
end

local function onFrameIncrease(animation, name, current)
    owner = animation.owner

    if owner.graphic:isCurrentOnKeyFrame("hit", Animation.forward) then
        local ran = owner:mySize()*0.6
        local px, py = owner.x + math.cos(owner.angle-math.pi/2) * ran, owner.y + math.sin(owner.angle-math.pi/2) * ran

        for _, target in ipairs(owner.scene.units) do
            local bounds = target:boundingRect()
            if px >= bounds.x and py >= bounds.y and px <= bounds.x+bounds.w and py <= bounds.y+bounds.h and owner.player:isEnemy(target) then
                --dodamagehere
            end
        end
    end
end

function Unit:loadAnimation()
    local anim = self.kind.animations

    self.graphic = Animation:new(self.scene.unittexture, anim.stand.startx, anim.stand.starty,
    self:mySize(), self:mySize())

    self.graphic:addFrames("move", anim.move.startx, anim.move.starty, anim.move.ammount, anim.move.time,
     anim.move.keyframes, anim.move.options)

    self.graphic:addFrames("attack", anim.attack.startx, anim.attack.starty, anim.attack.ammount, anim.attack.time,
     anim.attack.keyframes, anim.attack.options, onFrameIncrease)

    self.graphic.owner = self
end

function Unit:init(x, y, kind, player, properties)
    Unit.super.init(self, x, y)

    local size = self:mySize()

    self.kind = kind

    self.player = player
    self.properties = properties

    self:loadAnimation()

    self.stats = UnitType.makeStats(kind.stats)
    self.stats.attackrange = self.stats.attackrange*size
    self.stats.sightrange = self.stats.sightrange*size
    self.stats.movespeed = self.stats.movespeed*size
end


return Unit