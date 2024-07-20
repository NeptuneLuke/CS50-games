--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]


PaddleSelectState = Class{__includes = BaseState}


function PaddleSelectState:enter(params)
    self.highscores = params.highscores
end


function PaddleSelectState:init()
    
    -- the paddle we're highlighting; will be passed to the ServeState
    -- when we press Enter
    self.current_paddle = 1
end


function PaddleSelectState:update(dt)
    
    if love.keyboard.wasPressed("left") then
        
        if self.current_paddle == 1 then
            sounds["no-select"]:play()
        else
            sounds["select"]:play()
            self.current_paddle = self.current_paddle - 1
        end
    
    elseif love.keyboard.wasPressed("right") then
        
        if self.current_paddle == 4 then
            sounds["no-select"]:play()
        
        else
            sounds["select"]:play()
            self.current_paddle = self.current_paddle + 1
        end
    end

    -- select paddle and move on to the serve state, passing in the selection
    if love.keyboard.wasPressed("return") or love.keyboard.wasPressed("enter") then
        
        sounds["confirm"]:play()

        game_state_machine:change("serve", {
            paddle = Paddle(self.current_paddle),
            bricks = LevelMaker.createMap(32),
            health = 3,
            score = 0,
            highscores = self.highscores,
            level = 32,
            recover_points = 5000
        })
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end


function PaddleSelectState:render()
    
    -- instructions
    love.graphics.setFont(fonts["medium"])
    love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4,VIRTUAL_WIDTH, "center")
    
    love.graphics.setFont(fonts["small"])
    love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
        
    -- left arrow; should render normally if we're higher than 1, else
    -- in a shadowy form to let us know we're as far left as we can go
    if self.current_paddle == 1 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)     -- tint; give it a dark gray with half opacity
    end
    
    love.graphics.draw(textures["arrows"], frames["arrows"][1], VIRTUAL_WIDTH / 4 - 24, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(1, 1, 1, 1)  -- reset drawing color to full white for proper rendering

    -- right arrow; should render normally if we're less than 4, else
    -- in a shadowy form to let us know we're as far right as we can go
    if self.current_paddle == 4 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)     -- tint; give it a dark gray with half opacity
    end
    
    love.graphics.draw(textures["arrows"], frames["arrows"][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(1, 1, 1, 1)      -- reset drawing color to full white for proper rendering

    -- draw the paddle itself, based on which we have selected
    love.graphics.draw(textures["main"], frames["paddles"][2 + 4 * (self.current_paddle - 1)], VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end