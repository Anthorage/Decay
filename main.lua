gamestate = require("libs/hump/gamestate")

local game = require("game")


function love.load()
    gamestate.registerEvents()
    gamestate.switch(game)
end
