--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    The state in which we've lost all of our health and get our score displayed to us. Should
    transition to the EnterHighScore state if we exceeded one of our stored high scores, else back
    to the StartState.
]]


GameOverState = Class{__includes = BaseState}


function GameOverState:enter(params)
    self.score = params.score
    self.highscores = params.highscores
end


function GameOverState:update(dt)
    
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        
        local highscore = false     -- see if score is higher than any in the high scores table
        local score_index = 11      -- keep track of what high score ours overwrites, if any

        for i = 10, 1, -1 do
            
            local score = self.highscores[i].score or 0
            if self.score > score then
                highscore_index = i
                highscore = true
            end
        end

        if highscore then
            
            sounds["high-score"]:play()
            game_state_machine:change("enter-high-score", {
                highscores = self.highscores,
                score = self.score,
                score_index = highscore_index
            }) 
        
        else 
            game_state_machine:change("start", { highscores = self.highscores }) 
        end
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end


function GameOverState:render()
    
    love.graphics.setFont(fonts["large"])
    love.graphics.printf("GAME OVER", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
    
    love.graphics.setFont(fonts["medium"])
    love.graphics.printf("Final Score: " .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Enter!", 0, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, "center")
end