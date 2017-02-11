local Unit = require("Unit")

local Hero = Unit:extend("Hero")

function Hero:draw()
    love.graphics.draw(self.scene.playertexture,self.body,self.x,self.y,self.angle,1,1,4, 4)
    love.graphics.draw(self.scene.playertexture,self.rhand,self.x,self.y,self.angle,1,1,4,4)
    --love.graphics.draw(self.scene.playertexture,self.lhand,self.x,self.y)

    --self.rect:draw()
end

function Hero:update(dt)
    local speed = self.speed*dt

    if love.keyboard.isDown('w') then
        self:move(0, -speed)
    elseif love.keyboard.isDown('s') then
        self:move(0, speed)
    end

    if love.keyboard.isDown('a') then
        self:move(-speed, 0)
    elseif love.keyboard.isDown('d') then
        self:move(speed, 0)
    end

    self.scene.camera:setPosition(self.x, self.y)

    local angx, angy = self.scene.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    self:setRotationXY( angx, angy)
    --print(angx, angy)
end

function Hero:init(x, y, id)
    Hero.super.init(self, x, y, id)

    -- The hero is made of 3 parts ( head+body+legs, left arm, right arm )
    -- Each part is animated individually, so you can cast a spell while moving while attacking with a sword.
    self.lhand = love.graphics.newQuad(0,16,8,8,self.scene.playertexture:getWidth(),self.scene.playertexture:getHeight())
    self.rhand = love.graphics.newQuad(0,8,8,8,self.scene.playertexture:getWidth(),self.scene.playertexture:getHeight())
    self.body = love.graphics.newQuad(0,0,8,8,self.scene.playertexture:getWidth(),self.scene.playertexture:getHeight())
end


return Hero