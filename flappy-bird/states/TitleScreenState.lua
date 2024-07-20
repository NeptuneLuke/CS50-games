--[[
    TitleScreenState Class
    
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    display "Press Enter" and also our highest score.
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
        
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        game_state_machine:change("countdown")
    end
end

function TitleScreenState:render()
    
    love.graphics.setFont(flappy_font)
    love.graphics.printf("Flappy Bird Remake", 0, 64, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(medium_font)
    love.graphics.printf("Press Enter", 0, 100, VIRTUAL_WIDTH, "center")
end