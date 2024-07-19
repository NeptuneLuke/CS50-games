--[[
    GD50 2018
    Pong Remake

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]

Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed_y = math.random(2) == 1 and -100 or 100
    self.speed_x = math.random(-50, 50)
end

--[[
    Places the ball in the middle of the screen, 
    with an initial random speed on both axes.
]]
function Ball:reset()
    self.x = (VIRTUAL_WIDTH / 2) - 2
    self.y = (VIRTUAL_HEIGHT / 2) - 2
    
    -- gives the ball a random starting speed value
    -- the and/or pattern here is Lua's way of accomplishing a ternary operation
    -- in other programming languages like C
    self.speed_y = math.random(2) == 1 and -100 or 100
    self.speed_x = math.random(-50, 50)
end

--[[
    Simply applies velocity to position, scaled by deltaTime.
]]
function Ball:update(dt)
    self.x = self.x + (self.speed_x * dt)
    self.y = self.y + (self.speed_y * dt)
end

function Ball:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


--[[
    Expects a paddle as an argument and returns true or false, depending
    on whether their rectangles overlap, as seen with AABB Collision Detection 
]]
function Ball:collide(paddle)
    
    -- first, check to see if the left edge of either is 
    -- farther to the right than the right edge of the other
    if self.x > (paddle.x + paddle.width) or 
        paddle.x > (self.x + self.width) then
        
        return false
    end

    -- then check to see if the bottom edge of either is 
    -- higher than the top edge of the other
    if self.y > (paddle.y + paddle.height) or 
        paddle.y > (self.y + self.height) then
        
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end