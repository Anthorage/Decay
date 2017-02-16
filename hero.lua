local Unit = require("unit")

local Hero = Unit:extend("Hero")

local Animation = require("animation")

local Player = require("player")

local Shape = require("libs/HC.shapes")

local HeadText = require("headtext")


function Hero:draw()
    --love.graphics.draw(self.scene.playertexture,self.body,self.x,self.y,self.angle,1,1,4, 4)
    --love.graphics.draw(self.scene.playertexture,self.rhand,self.x,self.y,self.angle,1,1,4,4)
    --love.graphics.draw(self.scene.playertexture,self.lhand,self.x,self.y)
    self.body:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
    self.lhand:draw(self.x, self.y, self.angle, 1, 1, 4, 4)
    self.rhand:draw(self.x, self.y, self.angle, 1, 1, 4, 4)

    --self.mytext:draw()
end

function Hero:move(x,y)
    Hero.super.move(self,x,y)

    self.body:play("move")
end


function Hero:movement(dt)
    local speed = self.stats.movespeed*dt
    local any = false

    --if self.rhand:isPlayingThis("attack") == false then
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

    local angx, angy = self.scene.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    self:setRotationXY( angx, angy)

    self.scene.camera:setPosition(self.x, self.y)

    self.light:setPosition(self.x, self.y)
    --end
end

function Hero:update(dt)
    if self.rhand:isPlayingThis("attack") == false then
        self:movement(dt)
    end

    self.lhand:update(dt)
    self.rhand:update(dt)
    self.body:update(dt)

    self.mytext:update(dt)
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

function Hero:loadAnimation()
    local anim = self.kind.animations

    self.lhand = Animation:new( self.scene.playertexture, anim.cast.startx, anim.cast.starty, self:mySize(), self:mySize() )
    self.rhand = Animation:new( self.scene.playertexture, anim.attack.startx, anim.attack.starty, self:mySize(), self:mySize() )
    self.body = Animation:new( self.scene.playertexture, anim.move.startx, anim.move.starty, self:mySize(), self:mySize())

    self.rhand.owner = self

    self.rhand:addFrames( "attack", anim.attack.startx, anim.attack.starty, anim.attack.ammount,
     anim.attack.time, anim.attack.keyframes, anim.attack.options, onFrameIncrease )

    self.lhand:addFrames( "cast", anim.cast.startx, anim.cast.starty, anim.cast.ammount, anim.cast.time, anim.cast.keyframes,
    anim.cast.options )

    self.body:addFrames( "move", anim.move.startx, anim.move.starty, anim.move.ammount, anim.move.time, anim.move.keyframes,
     anim.move.options )
end

function Hero:init(x, y, id, properties)
    Hero.super.init(self, x, y, id, Player.P1, properties)

    -- The hero is made of 3 parts ( head+body+legs, left arm, right arm )
    -- Each part is animated individually, so you can cast a spell while moving while attacking with a sword.

    self.light = self.scene.lightworld:newLight(self.x, self.y, 155, 155, 155, self.scene.tilesize.x*8*self.scene.camera:getScale())
    self.light:setGlowStrength(0.5)

    self.attacksound = love.audio.newSource("sounds/impact.ogg")

    self.mytext = HeadText:new(self, "Hello", 3.0)
end


return Hero