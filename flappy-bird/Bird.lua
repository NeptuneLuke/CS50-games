--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    The Bird is what we control in the game via clicking or the space bar; 
    whenever we press either, the bird will flap and go up a little bit, 
    where it will then be affected by gravity.
    If the bird hits the ground or a pipe, the game is over.
]]

Bird = Class{}

local GRAVITY = 20

function Bird:init()
    
    self.image = love.graphics.newImage("res/img/bird.png")
    self.x = VIRTUAL_WIDTH / 2 - 8
    self.y = VIRTUAL_HEIGHT / 2 - 8

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.speed_y = 0
end

--[[
    AABB collision that expects a pipe, which will have an X and Y and reference
    global pipe width and height values.
]]
function Bird:collide(pipe)
    
    -- the 2's are left and top offsets
    -- the 4's are right and bottom offsets
    -- both offsets are used to shrink the bounding box to give the player
    -- a little bit of leeway with the collision
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end

    return false
end

function Bird:update(dt)
    
    self.speed_y = self.speed_y + (GRAVITY * dt)

    if love.keyboard.wasPressed("space") then
        self.speed_y = -5
        sounds["jump"]:play()
    end

    self.y = self.y + self.speed_y
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end