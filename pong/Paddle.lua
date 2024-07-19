--[[
    GD50 2018
    Pong Remake

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed = 0 -- the speed of the paddle is only on Y axis
end

function Paddle:update(dt)
    
    -- math.max here ensures that we're the greater of 0 or the paddle's
    -- current calculated Y position when pressing up so that we don't
    -- go into negative values; 
    -- the movement calculation is simply our previously-defined paddle speed scaled by dt
    if self.speed < 0 then
        
        self.y = math.max(0, self.y + (self.speed * dt))
    
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + (self.speed * dt))
    end
end

function Paddle:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end