--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents the screen where we can view all high scores previously recorded.
]]


HighScoreState = Class{__includes = BaseState}


function HighScoreState:enter(params)
    self.highscores = params.highscores
end


function HighScoreState:update(dt)
    
    -- return to the start screen if we press escape
    if love.keyboard.wasPressed("escape") then
        
        sounds["wall-hit"]:play()
        game_state_machine:change("start", { highscores = self.highscores })
    end
end


function HighScoreState:render()
    
    love.graphics.setFont(fonts["large"])
    love.graphics.printf("High Scores", 0, 20, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(fonts["medium"])

    -- iterate over all high score indices in our high scores table
    for i = 1, 10 do
        
        local name = self.highscores[i].name or "---"
        local score = self.highscores[i].score or "---"
        love.graphics.printf(tostring(i) .. ".", VIRTUAL_WIDTH / 4, 60 + i * 13, 50, "left")    -- score number (1-10)
        love.graphics.printf(name, VIRTUAL_WIDTH / 4 + 38, 60 + i * 13, 50, "right")            -- score name
        love.graphics.printf(tostring(score), VIRTUAL_WIDTH / 2, 60 + i * 13, 100, "right")     -- score itself
    end

    love.graphics.setFont(fonts["small"])
    love.graphics.printf("Press Escape to return to the main menu!", 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, "center")
end
