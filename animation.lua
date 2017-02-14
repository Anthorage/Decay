local class = require("libs/30log/30log")

local Animation = class("Animation", { forward=1, backwards=-1, twoway=0 } )


-- Animation name ("walk", "attack", "cast")
-- X & Y points of the quad to use
-- ammount of frames (X,X+tileSX, X+tileSX*2...X+tileSX*ammount)
-- keyframe (for example you want flames to erupt on frame 2, ground to shake in 3, and the spell to be casted on 3)

-- Whenever the animation is on a keyframe it will raise and alert.
function Animation:addFrames( name, startx, starty, ammount, time, keyframes, options, onincrease )
    local ftime = time or 0.2
    local fkf = keyframes or {}
    local opt = options or {}

    assert(ammount>1, "Single frame animations not allowed")

    self.frames[name] = { name=name, sx=startx, sy=starty, current=0, options=opt, ammount=ammount-1, advance=1,
     totaltime=ftime, time=ftime, keyframes=fkf, finished=false, keyactive=false, paused=true, onincrease=onincrease,
      currentquad=love.graphics.newQuad(startx, starty, self.tsx, self.tsy, self.image:getWidth(), self.image:getHeight()) }
end

function Animation:isOnKeyFrame(anim, name, dual)
    
    if self:isPlayingThis(anim) then
        return self:isCurrentOnKeyFrame(name, dual)
    end

    return false
end

function Animation:isCurrentOnKeyFrame(name, dual)
    local keys = self.playing.keyframes[name]
    dual = dual or 1

    if type(keys) == "table" then
        if dual == 0 then
            for _, keyn in ipairs(keys) do
                if self.playing.current == keyn then
                    return true
                end
            end
        else
            for _, keyn in ipairs(keys) do
                if self.playing.current == keyn and self.playing.advance == dual then
                    return true
                end
            end
        end
    else
        if dual == 0 then
            return self.playing.current == keys
        else
            return self.playing.current == keys and self.playing.advance == dual
        end
    end

    return false
end

function Animation:hasCurrentAnimation()
    return self.playing ~= nil and self.playing.finished == false
end

function Animation:isPlaying()
    return self.playing ~= nil and self.playing.finished == false and self.playing.paused == false
end

function Animation:isPlayingThis(anim)
    return self.playing ~= nil and self.playing.name == anim and self.playing.finished == false and self.playing.paused == false
end

function Animation:stop()
    if self.playing ~= nil then
        self.playing.finished = true
        self.playing.paused = true
        self.playing.current = 0
        self.playing.advance = 1
        self.playing.currentquad = love.graphics.newQuad(self.playing.sx, self.playing.sy, self.tsx, self.tsy,
        self.image:getWidth(), self.image:getHeight())
        self.playing = nil
    end
end

function Animation:pause(how)
    if self.playing ~= nil then
        how = how or true
        self.playing.paused = how
    end
end

function Animation:incFrame()
    self.playing.current = self.playing.current + self.playing.advance

    local once = self.playing.options.once or true
    local goback = self.playing.options.rewind or false

    if self.playing.current >= self.playing.ammount then
        if once and goback == false then
            if self.playing.current > self.playing.ammount then
                self:stop()
            end
        elseif goback then
            self.playing.advance = -1
        else
            self.playing.current = 0
        end
    elseif self.playing.current <= 0 then

        if once then
            if self.playing.current < 0 then
                self:stop()
            end
        else
            self.playing.advance = 1
        end
    end

    if self.playing ~= nil then
        self.playing.currentquad = love.graphics.newQuad( self.playing.sx+self.playing.current*self.tsx,
        self.playing.sy, self.tsx, self.tsy, self.image:getWidth(), self.image:getHeight())

        if self.playing.onincrease ~= nil then
            self.playing.onincrease(self, self.playing.name, self.playing.current)
        end
    end

end

function Animation:draw(x,y,r,sx,sy,cx,cy)
    if self.playing ~= nil then
        love.graphics.draw( self.image, self.playing.currentquad, x, y, r, sx, sy, cx, cy )
    else
        love.graphics.draw( self.image, self.defaultquad, x, y, r, sx, sy, cx, cy )
    end
end

function Animation:isPlayingAnim(name)
    if self.playing then
        return self.playing == name
    end

    return false
end

function Animation:play(name, reset)
    reset = reset or false

    self.playing = self.frames[name]
    self.playing.paused = false
    self.playing.finished = false

    if reset then
        self.playing.currentquad = love.graphics.newQuad(self.playing.sx, self.playing.sy, self.tsx, self.tsy,
    self.image:getWidth(), self.image:getHeight())
        self.playing.current = 0
        self.playing.advance = 1
    end
end

function Animation:update(dt)
    if self.playing ~= nil and self.playing.paused == false then
        self.playing.time = self.playing.time - dt

        if self.playing.time <= 0 then
            self.playing.time = self.playing.totaltime
            self:incFrame()
        end
    end
end

-- Returns the current quad
function Animation:getCurrentFrame()
    if self.playing then
        return self.playing.currentquad
    end

    return self.defaultquad
end

function Animation:init(image, defx, defy, tileSX, tileSY)
    self.tsx = tileSX
    self.tsy = tileSY

    self.image = image
    self.frames = {}
    self.playing = nil

    self.defaultquad = love.graphics.newQuad(defx, defy, tileSX, tileSY, image:getWidth(), image:getHeight())
end

return Animation