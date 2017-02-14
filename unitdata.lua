return {

gorlath = {
    name = "Gorlath",
    id = 65,
    animations = {
        stand = { startx = 0, starty = 0 },
        move = { startx=0, starty=0, ammount=4, time=0.15 },
        attack = { startx=0, starty=8, ammount=5, time=0.1, keyframes={} }
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
        attack = { startx=0, starty=8, ammount=5, time=0.1, keyframes={} }
    },
    stats = {
        health = 16,
        damage = 4,
        armor = 0,
        movespeed = 3
    }
}

}