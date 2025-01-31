--[[
    
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level 
]]


VictoryState = Class{__includes = BaseState}


function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.highscores = params.highscores
    self.paddle = params.paddle
    self.health = params.health
    self.ball = params.ball
    self.recover_points = params.recover_points
end


function VictoryState:update(dt)
    
    self.paddle:update(dt)

    -- have the ball track the player
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - 8

    -- go to play screen if the player presses Enter
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        
        game_state_machine:change("serve", {
            level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highscores = self.highscores,
            recover_points = self.recover_points
        })
    end
end


function VictoryState:render()
    
    self.paddle:render()
    self.ball:render()
    renderHealth(self.health)
    renderScore(self.score)

    -- level complete text
    love.graphics.setFont(fonts["large"])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!", 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, "center")

    -- instructions text
    love.graphics.setFont(fonts["medium"])
    love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center")
end