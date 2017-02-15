local class = require("libs/30log/30log")

local Entity = class("Entity")
--local gamestate = require("libs/hump/gamestate")


function Entity:init(x,y)
    self.scene = gamestate.current()
    self.x = x + self.scene.tilesize.x/2
    self.y = y + self.scene.tilesize.y/2
    self.angle = 0

    self.rect = self.scene.collisionmaster:rectangle(x + self.scene.tilesize.x/4, y + self.scene.tilesize.x/4, 4, 4)
    self.dead = false

    self.rect.ctag = 1
end

function Entity:mySize()
    return self.scene.tilesize.x
end

function Entity:boundingRect()
    local size = self:mySize()
    
    return { x=self.x-size/2, y=self.y-size/2, w=size, h=size}
end

function Entity:die()
    self.scene.collisionmaster:remove(self.rect)
end

function Entity:update(dt)
end

function Entity:draw()
end

function Entity:move(x,y,checkwalls)
    local check = checkwalls or true
    local points = { { x=self.x,y=self.y } }

  --  local prevx = self.x
--    local prevy = self.y

    self.x = self.x + x
    self.y = self.y + y
    self.rect:move(x, y)

    if check==true then
        for shape, delta in pairs(self.scene.collisionmaster:collisions(self.rect)) do
            if shape.ctag == 1 then
                --self.rect:move(delta.x, delta.y)
                --self.x = self.x + delta.x
                --self.y = self.y + delta.y
                local dx = delta.x*0.1
                local dy = delta.y*0.1

                self.x = self.x + dx
                self.y = self.y + dy
                self.rect:move(dx, dy)
                break
            end
        end

        for shape, delta in pairs(self.scene.collisionmaster:collisions(self.rect)) do
            if shape.ctag == 0 then
                self.rect:move(delta.x, delta.y)
                self.x = self.x + delta.x
                self.y = self.y + delta.y
                --self.x = prevx
                --self.y = prevy
                --self.rect:move(-x, -y)
                --break
            end
        end
    end
end

function Entity:setPosition(x,y)
    self:move( x-self.x, y-self.y, false )
end

function Entity:moveTowards(x,y,speed)
    local dx = x-self.x
    local dy = y-self.y
    local dist = math.sqrt(dx*dx+dy*dy)
    
    self.angle = math.atan2(  y - self.y, x - self.x )
    
    if dist <= speed then
        self:setPosition(x,y)
    else
        self:move( speed * math.cos(self.angle), speed * math.sin(self.angle) )
    end

    self.angle = self.angle + math.pi/2

    return dist-speed
end

function Entity:setRotationXY(x,y)
    self.angle = math.atan2( y-self.y, x-self.x ) + math.pi/2
end


return Entity