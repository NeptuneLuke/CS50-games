--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Screen that allows us to input a new high score in the form of three characters, arcade-style.
]]


EnterHighScoreState = Class{__includes = BaseState}


local chars = { [1] = 65, [2] = 65, [3] = 65 }  -- individual chars of our string
local highlited_char = 1                        -- char we're currently changing


function EnterHighScoreState:enter(params)
    self.highscores = params.highscores
    self.score = params.score
    self.score_index = params.score_index
end


function EnterHighScoreState:update(dt)
    
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        
        -- update scores table
        local name = string.char(chars[1]) .. string.char(chars[2]) .. string.char(chars[3])

        -- go backwards through high scores table till this score, shifting scores
        for i = 10, self.score_index, -1 do
            self.highscores[i + 1] = { name = self.highscores[i].name, score = self.highscores[i].score }
        end

        self.highscores[self.score_index].name = name
        self.highscores[self.score_index].score = self.score

        -- write scores to file
        local scores_string = ""

        for i = 1, 10 do
            scores_string = scores_string .. self.highscores[i].name .. "\n"
            scores_string = scores_string .. tostring(self.highscores[i].score) .. "\n"
        end

        love.filesystem.write("breakout-remake.lst", scores_string)
        game_state_machine:change("high-scores", { highscores = self.highscores })
    end

    -- scroll through character slots
    if love.keyboard.wasPressed("left") and highlited_char > 1 then
        highlited_char = highlited_char - 1
        sounds["select"]:play()
    
    elseif love.keyboard.wasPressed("right") and highlited_char < 3 then
        highlited_char = highlited_char + 1
        sounds["select"]:play()
    end

    -- scroll through characters
    if love.keyboard.wasPressed("up") then
        
        chars[highlited_char] = chars[highlited_char] + 1
        if chars[highlited_char] > 90 then
            chars[highlited_char] = 65
        end
    
    elseif love.keyboard.wasPressed("down") then
        
        chars[highlited_char] = chars[highlited_char] - 1
        if chars[highlited_char] < 65 then
            chars[highlited_char] = 90
        end
    end
end


function EnterHighScoreState:render()
    
    love.graphics.setFont(fonts["medium"])
    love.graphics.printf("Your score: " .. tostring(self.score), 0, 30, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(fonts["large"])
    
    -- render all three characters of the name
    if highlited_char == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(chars[1]), VIRTUAL_WIDTH / 2 - 28, VIRTUAL_HEIGHT / 2)
    
    love.graphics.setColor(1, 1, 1, 1)
    if highlited_char == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(chars[2]), VIRTUAL_WIDTH / 2 - 6, VIRTUAL_HEIGHT / 2)
    
    love.graphics.setColor(1, 1, 1, 1)
    if highlited_char == 3 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(chars[3]), VIRTUAL_WIDTH / 2 + 20, VIRTUAL_HEIGHT / 2)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fonts["small"])
    love.graphics.printf("Press Enter to confirm!", 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, "center")
end