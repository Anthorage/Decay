local HC = require("libs/HC")
local HCShape = require("libs/HC.shapes")
local sti = require("libs/sti")
local gamera = require("libs/gamera/gamera")
local Unit = require("unit")
local Hero = require("hero")
local LightWorld = require("libs/light")
local UnitType = require("unittype")
local Player = require("player")

local PathGrid = require ("libs/jumper.grid") -- The grid class
local Pathfinder = require ("libs/jumper.pathfinder") -- The pathfinder class
 

local game = {}


local function create2DMatrix(w,h,def)
    local ret = {}
    local defa = def or 0

    for x=0, w do
        local tab = {}
        for y=0, h do
            table.insert(tab, def)
        end
        table.insert(ret, tab)
    end

    return ret
end

local function printtable(tab)
    for k, v in pairs(tab) do
        print(k,v)
    end
end

function game:containsPoint(x,y)
    return x>=self.borders.x and y >= self.borders.y and x <= self.borders.x+self.borders.w and y<=self.borders.y+self.borders.h
end

function game:mousepressed(x,y,button,istouch)
    if button == 1 then
        self.hero.rhand:play("attack")
    elseif button == 2 then
        self.hero.lhand:play("cast")
    end
end

function game:addBorderWalls(tsx, tsy)
    local sha = self.collisionmaster:rectangle(-tsx, -tsy, tsx, self.bounds.h+tsy)
    sha.ctag = 0
    table.insert( self.collshapes,sha )
    sha = self.collisionmaster:rectangle(-tsx, -tsy, self.bounds.w+tsx, tsy)
    sha.ctag = 0
    table.insert( self.collshapes,sha )
    sha = self.collisionmaster:rectangle(self.bounds.w, -tsy, tsx, self.bounds.h+tsy)
    sha.ctag = 0
    table.insert(self.collshapes, sha )
    sha = self.collisionmaster:rectangle(-tsx, self.bounds.h, self.bounds.w+tsx, tsy)
    sha.ctag = 0
    table.insert( self.collshapes,sha )
end

function game:parseMap()
    self.tilemap = sti(self.currentlevel.tmx_path)
    self.walkables = create2DMatrix(self.tilemap.height, self.tilemap.width, 0)
    self.walkableid = 1

    self.units = {}
    self.tilesize = { x=self.tilemap.tilewidth, y=self.tilemap.tileheight }

    self.borders = { x=0,y=0,w=self.tilemap.width,h=self.tilemap.height }

    self.lightworld = LightWorld({
    ambient = {0,0,0},         --the general ambient light in the environment
  })

    self.collshapes = {}

    local tsx = self.tilesize.x
    local tsy = self.tilesize.y

    self.bounds = { x=0,y=0,w=self.borders.w*tsx, h=self.borders.h*tsy }

    self:addBorderWalls(tsx, tsy)

    local remlays = {}

    self.pathgrid = PathGrid( self.walkables )
    self.pathmaker = Pathfinder(self.pathgrid, 'ASTAR', self.walkableid)

    for _, lay in ipairs(self.tilemap.layers) do
        if lay.type == "tilelayer" then
            if lay.properties.shadows then
                table.insert(remlays, lay)
                for y=1, lay.height do
                    for x=1, lay.width do
                        local tile = lay.data[y][x]

                        if tile ~= nil then
                            self.lightworld:newRectangle((x-0.5)*tsx, (y-0.5)*tsy, tsx, tsy)
                        end
                    end
                end
            else
                local coll = lay.properties.collision or false

                if coll == true then
                    coll = 2
                else
                    coll = 1
                end

                for y=1, lay.height do
                    for x=1, lay.width do
                        local tile = lay.data[y][x]

                        if tile ~= nil and self.walkables[y][x] ~= 2 then
                            self.walkables[y][x] = coll
                            if coll == 2 then
                                local shape = self.collisionmaster:rectangle((x-1)*tsx,(y-1)*tsy,tsx,tsy)
                                shape.ctag = 0
                                table.insert(self.collshapes, shape)
                            end
                        end
                    end
                end
            end
        elseif lay.type == "objectgroup" then
            if lay.name == "units" then
                for _, ent in ipairs(lay.objects) do
                    local newent = nil
                    local utp = UnitType:getByID(ent.gid)

                    --printtable(ent.properties)
                    
                    if ent.type == "hero" then
                        newent = Hero:new(ent.x, ent.y-tsy, utp, ent.properties or {})
                        --self.camera:setPosition(newent.x, newent.y)
                        self.hero = newent
                    else
                        newent = Unit:new(ent.x, ent.y-tsy, utp, Player.get(ent.properties.player or 1), ent.properties or {})
                    end

                    table.insert(self.units, newent)
                end
            end
        end
    end

    for _, rem in ipairs(remlays) do
        self.tilemap:removeLayer(rem.name)
    end

    self.tilemap:convertToCustomLayer("units")
    local unitLayer = self.tilemap.layers["units"]

    function unitLayer:update(dt)
        --for _, u in ipairs(game.units) do
        for i=#game.units, 1, -1 do
            local u = game.units[i]

            if u.dead == false then
                u:update(dt)
            end

            if u.dead == true then
                table.remove(game.units, i)
            end
        end
    end

    function unitLayer:draw()
        for _, u in ipairs(game.units) do
            u:draw()
        end
    end

end


function game:setLevel(id)
    if self.currentlevel ~= nil then
        self.currentlevel:exit()
    end

    self.levelid = id

    if self.levelid <= #self.levels then
        self.currentlevel = require(self.levels[self.levelid])
        self:parseMap()
        self.currentlevel:enter()
    end
end

    
function game:playMusic(number)
    self.music[self.musicplaying]:stop()
    self.musicplaying = number or 1

    if self.musicplaying > #self.music then
        self.musicplaying = 1
    end

    self.music[self.musicplaying]:play()
end


function game:enter(old_state)
    self:setLevel(1)

    self:playMusic()
end

function game:init()
    self.collisionmaster = HC.new(32)
    self.camera = gamera.new( -200, -200, 2000, 2000 )

    self.camera:setScale(6)

    self.unittexture = love.graphics.newImage( "graphics/units.png" )
    self.playertexture = love.graphics.newImage( "graphics/player.png" )

    self.unittexture:setFilter("nearest", "nearest")
    self.playertexture:setFilter("nearest", "nearest")

    self.levels = { "area_start_1" }
    self.music = { love.audio.newSource("music/Tormented.ogg"), love.audio.newSource("music/Slough_Of_Despond.ogg") }
    self.musicplaying = 1
    
    self:playMusic()
end

function game:update(dt)
    self.tilemap:update(dt)
    self.currentlevel:update(dt)
    self.lightworld:update(dt)

    if self.music[self.musicplaying]:isPlaying() == false then
        self:playMusic(self.musicplaying+1)
    end
end


function game:draw()
    self.camera:draw(function(l,t,w,h)
        local scale = self.camera:getScale()
        self.lightworld:setTranslation(-l*scale,-t*scale,scale)
        self.lightworld:draw(function()
            self.tilemap:draw()
            self.currentlevel:draw()
        end)
        
    end)

    self.hero.mytext:draw()
    

end


return game