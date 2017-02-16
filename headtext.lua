local class = require("libs/30log/30log")
local HeadText = class("HeadText")


function HeadText:draw()
    if self.over == false then
        local x,y = self.where.scene.camera:toScreen(self.where.x, self.where.y)
        love.graphics.setColor(192, 192, 96)
        love.graphics.printf(self.text, x, y, 140, "left", 0, 1, 1, 8, 32)
        love.graphics.setColor(255, 255, 255)
    end
end

function HeadText:update(dt)
    if self.time <= 0 then
        self.over = true
    else
        self.time = self.time - dt
    end
end

function HeadText:setCurrentText(text, time)
    self.text = text
    self.time = time or self.time

    self.over = (self.time <= 0)
end

function HeadText:init(where, text, time)
    self.where = where
    self.time = time or 1.0
    self.text = text or ""

    self.over = false
end


return HeadText