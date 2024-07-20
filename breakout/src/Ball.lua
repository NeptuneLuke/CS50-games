--[[
    
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents a ball which will bounce back and forth between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball can have a skin, which is chosen at random, just
    for visual variety.
]]


Ball = Class{}


function Ball:init(skin)
    
    self.width = 8
    self.height = 8
    self.speed_x = 0
    self.speed_y = 0
    self.skin = skin -- the color of the ball and we will index our table of Quads relating to the global block texture using this
end


--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Ball:collide(target)
    
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > (target.x + target.width) or target.x > (self.x + self.width) then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > (target.y + target.height) or target.y > (self.y + self.height) then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end


--[[
    Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.speed_x = 0
    self.speed_y = 0
end


function Ball:update(dt)
    
    self.x = self.x + (self.speed_x * dt)
    self.y = self.y + (self.speed_y * dt)

    -- allow the ball to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.speed_x = -self.speed_x
        sounds["wall-hit"]:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.speed_x = -self.speed_x
        sounds["wall-hit"]:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.speed_y = -self.speed_y
        sounds["wall-hit"]:play()
    end
end


function Ball:render()
    
    -- textures is our global texture for all blocks
    -- frames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(textures["main"], frames["balls"][self.skin], self.x, self.y)
end