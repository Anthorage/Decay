local Unit = require("unit")

local Hero = Unit:extend("Hero")

local Animation = require("animation")
--local Light = require("libs/light")


function Hero:draw()
    --love.graphics.draw(self.scene.playertexture,self.body,self.x,self.y,self.angle,1,1,4, 4)
    --love.graphics.draw(self.scene.playertexture,self.rhand,self.x,self.y,self.angle,1,1,4,4)
    --love.graphics.draw(self.scene.playertexture,self.lhand,self.x,self.y)
    self.body:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
    self.lhand:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
    self.rhand:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
    
    --self.rect:draw()
end

function Hero:move(x,y)
    Hero.super.move(self,x,y)

    self.body:play("move")
end

function Hero:update(dt)
    local speed = self.speed*dt
    local any = false

    if love.keyboard.isDown('w') then
        any=true
        self:move(0, -speed)
    elseif love.keyboard.isDown('s') then
        any=true
        self:move(0, speed)
    end

    if love.keyboard.isDown('a') then
        any=true
        self:move(-speed, 0)
    elseif love.keyboard.isDown('d') then
        any=true
        self:move(speed, 0)
    end

    if any==false then
        self.body:stop()
    end

    self.scene.camera:setPosition(self.x, self.y)

    local angx, angy = self.scene.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    self:setRotationXY( angx, angy)

    self.lhand:update(dt)
    self.rhand:update(dt)
    self.body:update(dt)
end

function Hero:init(x, y, id)
    Hero.super.init(self, x, y, id)

    -- The hero is made of 3 parts ( head+body+legs, left arm, right arm )
    -- Each part is animated individually, so you can cast a spell while moving while attacking with a sword.
    self.lhand = Animation:new( self.scene.playertexture, 0, 16, 8, 8 )
    self.rhand = Animation:new( self.scene.playertexture, 0, 8, 8, 8 )
    self.body = Animation:new( self.scene.playertexture, 0, 0, 8, 8 )

    self.rhand:addFrames( "attack", 0, 8, 4, 0.1, {}, {once=true,rewind=true} )
    self.lhand:addFrames( "attack", 0, 16, 4, 0.1, {}, {once=true,rewind=true} )
    self.body:addFrames( "move", 0, 0, 4, 0.25, {}, {once=true} )
end


return Hero