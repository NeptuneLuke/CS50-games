--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]


PlayState = Class{__includes = BaseState}


--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    
    self.paddle = params.paddle
    self.ball = params.ball
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highscores = params.highscores
    self.level = params.level
    self.recover_points = 5000

    -- give ball random starting speed
    self.ball.speed_x = math.random(-200, 200)
    self.ball.speed_y = math.random(-50, -60)
end


function PlayState:update(dt)
    
    if self.paused then
        
        if love.keyboard.wasPressed("space") then
            self.paused = false
            sounds["pause"]:play()
        
        else
            return
        end
    
    elseif love.keyboard.wasPressed("space") then
        
        self.paused = true
        sounds["pause"]:play()
        return
    end

    -- update positions based on speed
    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collide(self.paddle) then
        
        -- raise ball above paddle in case it goes below it, then reverse dy
        self.ball.y = self.paddle.y - 8
        self.ball.speed_y = -self.ball.speed_y

        -- tweak angle of bounce based on where it hits the paddle
        -- if we hit the paddle on its left side while moving left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.speed < 0 then
            self.ball.speed_x = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.speed > 0 then
            self.ball.speed_x = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        sounds["paddle-hit"]:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        if brick.in_play and self.ball:collide(brick) then

            self.score = self.score + (brick.tier * 200 + brick.color * 25)     -- add to score
            brick:hit()                                                         -- trigger the brick's hit function, which removes it from play

            -- if we have enough points, recover a point of health
            if self.score > self.recover_points then
                
                self.health = math.min(3, self.health + 1)                          -- can't go above 3 health
                self.recover_points = math.min(100000, self.recover_points * 2)     -- multiply recover points by 2
                sounds["recover"]:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                
                sounds["victory"]:play()

                game_state_machine:change("victory", {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highscores = self.highscores,
                    ball = self.ball,
                    recover_points = self.recover_points
                })
            end

            -- collision code for bricks:
            -- we check to see if the opposite side of our speed is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if self.ball.x + 2 < brick.x and self.ball.speed_x > 0 then
                
                -- flip x speed and reset position outside of brick
                self.ball.speed_x = -self.ball.speed_x
                self.ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.speed_x < 0 then
                
                -- flip x speed and reset position outside of brick
                self.ball.speed_x = -self.ball.speed_x
                self.ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                
                -- flip y speed and reset position outside of brick
                self.ball.speed_y = -self.ball.speed_y
                self.ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y speed and reset position outside of brick
                self.ball.speed_y = -self.ball.speed_y
                self.ball.y = brick.y + 16
            end

            -- slightly scale the y speed to speed up the game, capping at +- 150
            if math.abs(self.ball.speed_y) < 150 then
                self.ball.speed_y = self.ball.speed_y * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if self.ball.y >= VIRTUAL_HEIGHT then
        
        self.health = self.health - 1
        sounds["hurt"]:play()

        if self.health == 0 then
            game_state_machine:change("game-over", { score = self.score, highscores = self.highscores })
        
        else
            game_state_machine:change("serve", {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highscores = self.highscores,
                level = self.level,
                recover_points = self.recover_points
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end


function PlayState:render()
    
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()
    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(fonts["large"])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
    end
end


function PlayState:checkVictory()
    
    for k, brick in pairs(self.bricks) do
        if brick.in_play then
            return false
        end 
    end

    return true
end