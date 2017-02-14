return {

gorlath = {
    name = "Gorlath",
    id = 65,
    animations = {
        move = { startx=0, starty=0, ammount=4, time=0.25 },
        attack = { startx=0, starty=8, ammount=6, time=0.085, keyframes={hit=5} },
        cast = { startx=0, starty=16, ammount=4, time=0.1, keyframes={}, options={rewind=true} },
    },
    stats = {
        health = 100,
        damage = 10,
        armor = 1,
        movespeed = 3
    }
},

skeleton = {
    name = "Skeleton",
    id = 66,
    animations = {
        stand = { startx = 0, starty = 0 },
        move = { startx=0, starty=0, ammount=4, time=0.15 },
        attack = { startx=0, starty=8, ammount=5, time=0.1, keyframes={ hit={2,3} } }
    },
    stats = {
        health = 16,
        damage = 4,
        armor = 0,
        movespeed = 3
    }
}

}