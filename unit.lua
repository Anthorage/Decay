local Entity = require("Entity")

local Unit = Entity:extend("Unit", {MOVE=1,ATTACK=2,STAY=3} )

local Animation = require("animation")

local UnitType = require("unittype")

--local Pathfinding = require("libs/jumper.pathfinder")

function Unit:draw()
    self.graphic:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
end

function Unit:checkAttack()
    local ran = self:mySize()*0.6
    local px, py = self.x + math.cos(self.angle-math.pi/2) * ran, self.y + math.sin(self.angle-math.pi/2) * ran

    for _, target in ipairs(self.scene.units) do
        local bounds = target:boundingRect()
        if px >= bounds.x and py >= bounds.y and px <= bounds.x+bounds.w and py <= bounds.y+bounds.h and self.player:isEnemy(target.player) == true then
            --dodamagehere
            --owner:attackTarget(target)
            --love.audio.play(owner.attacksound)
            return target
        end
    end

    return nil
end


function Unit:stop(forget)
    forget = forget or true

    if forget==true then
        self.target=nil
    end

    self.order = Unit.STAY
    self.path = {}
end

function Unit:update(dt)
    if self.order == Unit.MOVE then
        local node = self.path[#self.path]

        if self:moveTowards(node.x, node.y, self.stats.movespeed*dt) <= self:mySize()*0.1 then
            table.remove(self.path)

            if #self.path <= 0 then
                self:stop(false)
            end
        end
    end
end

function Unit:die(killer)
    Unit.super.die(self)
    self.dead = true
    self.killer = killer
end

function Unit:damage(dmg, source)
    local realdmg = math.max(dmg - self.stats.armor, 0)
    self.stats.health = self.stats.health - realdmg

    if self.stats.health <= 0 then
        self:die(source)
    end
end

function Unit:travel(x, y)
    local tx, ty = x/self.scene.tilesize.x, y/self.scene.tilesize.y--self.scene.tilemap:convertPixelToTile(x, y)
    local sx, sy = self.x/self.scene.tilesize.x, self.y/self.scene.tilesize.y--self.scene.tilemap:convertPixelToTile(self.x, self.y)

    if self.scene:containsPoint(tx, ty) then
        local jpath = self.scene.pathmaker:getPath(math.floor(sx+1), math.floor(sy+1), math.floor(tx+1), math.floor(ty+1))

        jpath:reverse()
        self.path = {}

        for node, count in jpath:nodes() do
            table.insert(self.path, { x= (node:getX()-0.5) * self.scene.tilesize.x, y=(node:getY()-0.5) * self.scene.tilesize.y } )
        end

        if #self.path > 0 then
            self.order = Unit.MOVE
        end

        return true
    end

    return false
end

function Unit:attackTarget(who)
    who:damage(self.stats.damage, self)
end

local function onFrameIncrease(animation, name, current)
    owner = animation.owner

    if owner.rhand:isCurrentOnKeyFrame("hit", Animation.forward) then
        local target = owner:checkAttack()

        if target ~= nil then
            owner:attackTarget(target)
            love.audio.play(owner.attacksound)
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

    self.path = {}

    self:loadAnimation()

    self.order = Unit.STAY
    self.target = nil

    self.stats = UnitType.makeStats(kind.stats)
    self.stats.attackrange = self.stats.attackrange*size
    self.stats.sightrange = self.stats.sightrange*size
    self.stats.movespeed = self.stats.movespeed*size

end


return Unit