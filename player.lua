local player = {ALLY=1,ENEMY=2,NEUTRAL=3}

function player.get(id)
    return player[id]
end

function player.new(id, color)
    local ret = {}
    ret.id = id
    ret.color = color
    ret.states = {}

    function ret:getState(player2)
        return self.states[player2] or player.NEUTRAL
    end

    function ret:setState(player2, state)
        self.states[player2] = state
        player2.states[self] = state
    end

    function ret:isEnemy(player2)
        return self:getState(player2) == player.ENEMY
    end

    player[id] = ret

    return ret
end


local function setupPlayers()
    player.P1 = player.new( 1, {255,255,0} )
    player.P2 = player.new( 2, {255,0,0} )
    player.P3 = player.new( 3, {255,255,255} )

    player.P1:setState(player.P2, player.ENEMY)
end

setupPlayers()


return player