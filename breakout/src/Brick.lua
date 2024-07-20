--[[
   
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents a brick in the world space that the ball can collide with;
    differently colored bricks have different point values. On collision,
    the ball will bounce away depending on the angle of collision. When all
    bricks are cleared in the current map, the player should be taken to a new
    layout of bricks.
]]


Brick = Class{}


-- some of the colors in our palette (to be used with particle systems)
-- used for score calculation, each color is associated with a tier which is associated with a score
palette_colors = {

    -- blue
    [1] = { ["r"] = 99, ["g"] = 155, ["b"] = 255 },
    
    -- green
    [2] = { ["r"] = 106, ["g"] = 190, ["b"] = 47 },
    
    -- red
    [3] = { ["r"] = 217, ["g"] = 87, ["b"] = 99 },
    
    -- purple
    [4] = { ["r"] = 215, ["g"] = 123, ["b"] = 186 },
    
    -- gold
    [5] = { ["r"] = 251, ["g"] = 242, ["b"] = 54 }
}


function Brick:init(x, y)
    
    self.tier = 0
    self.color = 1
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    self.in_play = true     -- used to determine whether this brick should be rendered

    -- particle system belonging to the brick, emitted at every hit
    self.particle = love.graphics.newParticleSystem(textures["particle"], 64)

    -- various behavior-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 seconds seconds
    self.particle:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward 
    self.particle:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural than uniform
    self.particle:setEmissionArea("normal", 10, 10)
end


--[[
    Triggers a hit on the brick, taking it out of play if at 0 health or
    changing its color otherwise.
]]
function Brick:hit()
    
    -- set the particle system to interpolate between two colors; in this case, we give
    -- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.particle:setColors(
        palette_colors[self.color].r / 255,
        palette_colors[self.color].g / 255,
        palette_colors[self.color].b / 255,
        55 * (self.tier + 1) / 255,
        palette_colors[self.color].r / 255,
        palette_colors[self.color].g / 255,
        palette_colors[self.color].b / 255,
        0
    )
    self.particle:emit(64)

    -- sound on hit
    sounds["brick-hit-2"]:stop()
    sounds["brick-hit-2"]:play()

    -- if we're at a higher tier than the base, we need to go down a tier
    -- if we're already at the lowest color, else just go down a color
    if self.tier > 0 then
        
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        
        else
            self.color = self.color - 1
        end
    
    else
        
        -- if we're in the first tier and the base color, remove brick from play
        if self.color == 1 then
            self.in_play = false
        
        else
            self.color = self.color - 1
        end
    end

    -- play a second layer sound if the brick is destroyed
    if not self.in_play then
        sounds["brick-hit-1"]:stop()
        sounds["brick-hit-1"]:play()
    end
end


function Brick:update(dt)
    self.particle:update(dt)
end


function Brick:render()
    
    if self.in_play then
        love.graphics.draw(textures["main"], 
            -- multiply color by 4 (-1) to get our color offset, then add tier to that
            -- to draw the correct tier and color brick onto the screen
            frames["bricks"][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y)
    end
end


--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Brick:renderParticles()
    love.graphics.draw(self.particle, self.x + 16, self.y + 8)
end