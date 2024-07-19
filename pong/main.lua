--[[
    GD50 2018
    Pong Remake
	
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

	Modified by: NeptuneLuke @Github

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is;
-- used to provide a more retro aesthetic
-- https://github.com/Ulydev/push
push = require "libs.push"

-- class.lua is a library that helps us using OOP in Lua
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "libs.class"

-- Paddle and Ball classes
require "Paddle"
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move the paddle; multiplied by deltatime in love.update()
PADDLE_SPEED = 200


--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    
	love.window.setTitle("Pong Remake")
	
	-- seed the RNG using the current time
    math.randomseed(os.time())

    -- use nearest-neighbor filtering on upscaling and downscaling 
    -- to prevent blurring of text and graphics;
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- more "retro-looking" font object we can use for any text
    -- set LÖVE2D current font
    small_font = love.graphics.newFont("res/font.ttf", 8)
    large_font = love.graphics.newFont("res/font.ttf", 16)
    score_font = love.graphics.newFont("res/font.ttf", 32)
    love.graphics.setFont(small_font)

    -- set up sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ["paddle_hit"] = love.audio.newSource("res/sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("res/sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("res/sounds/wall_hit.wav", "static")
    }

    -- initialize the virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; 
    -- replaces "love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false, resizable = false, vsync = true})"
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen 
    -- and keeping track of the winner
    player_1_score = 0
    player_2_score = 0
    max_score = 10

    -- initialize players (paddles) and ball
    player_1 = Paddle(10, 30, 7, 20);
    player_2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 7, 20);
    ball = Ball((VIRTUAL_WIDTH/2) - 2, (VIRTUAL_HEIGHT/2) - 2, 4, 4);
    serving_player = 1

    -- game state variable used to transition between different parts of the game
    -- (beginning, menu, main game, high score list, etc.)
    -- used to determine behavior during render and update
    game_state = "start"
end


--[[
    Called by LÖVE2D whenever we resize the screen; here, we just want to pass in the
    width and height to "push" so our virtual resolution can be resized as needed.
]]
function love.resize(width, height)
    push:resize(width, height)
end


--[[
    Runs every frame, with "dt" being deltaTime, the time in seconds passed 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    
	if game_state == "serve" then
        
		-- before switching to play, initialize ball's speed based
        -- on player who last scored
        ball.speed_y = math.random(-50, 50)

        if serving_player == 1 then
            ball.speed_x = math.random(140, 200)
        else
            ball.speed_x = -math.random(140, 200)
        end
		
    elseif game_state == "play" then
        
		-- detect ball collision with paddles
        -- reversing the X speed if true and slightly increasing it
        -- altering the Y speed based on the position of collision
		if ball:collide(player_1) or ball:collide(player_2) then
            
            sounds["paddle_hit"]:play()

            ball.speed_x = -ball.speed_x * 1.03
            
            if ball:collide(player_1) then
                ball.x = player_1.x + 5
            elseif ball:collide(player_2) then
                ball.x = player_2.x - 4
            end
            
            if ball.speed_y < 0 then
                ball.speed_y = -math.random(10, 150)
            else
                ball.speed_y = math.random(10, 150)
            end
        end

        -- detect upper and lower screen boundary collision and reverse speed if collided
        if ball.y <= 0 then
            
            sounds["wall_hit"]:play()
            ball.y = 0
            ball.speed_y = -ball.speed_y
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            
            sounds["wall_hit"]:play()
            ball.y = VIRTUAL_HEIGHT - 4
            ball.speed_y = -ball.speed_y
        end
        
        -- if we reach the left or right edge of the screen, 
        -- go back to start and update the score
        if ball.x < 0 then
            
			serving_player = 1
            player_2_score = player_2_score + 1
            sounds["score"]:play()

            if player_2_score == max_score then
                winner = 2
                game_state = "done"
            else
                game_state = "serve"
				ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            serving_player = 2
            player_1_score = player_1_score + 1
            sounds["score"]:play()
            
            if player_1_score == max_score then
                winner = 1
                game_state = "done"
            else
                game_state = "serve"
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown("w") then
        
		-- add negative paddle speed to current Y scaled by deltaTime
        -- clamp the paddle position between the bounds of the screen
        -- math.max returns the greater between 0 and paddle Y
        -- ensuring we don't go above it
        -- paddle_1_y = math.max(0, paddle_1_y + (-PADDLE_SPEED * dt))
        player_1.speed = -PADDLE_SPEED;
		
    elseif love.keyboard.isDown("s") then
        
		-- add positive paddle speed to current Y scaled by deltaTime
        -- math.min returns the lesser between bottom of the egde minus paddle height
        -- and paddle Y will ensure we don't go below it
        -- paddle_1_y = math.min(VIRTUAL_HEIGHT - 20, paddle_1_y + (PADDLE_SPEED * dt))
        player_1.speed = PADDLE_SPEED;
    
	else
        player_1.speed = 0
    end

    -- player 2 movement
    if love.keyboard.isDown("up") then

        -- add negative paddle speed to current Y scaled by deltaTime
        -- paddle_2_y = math.max(0, paddle_2_y + (-PADDLE_SPEED * dt))
        player_2.speed = -PADDLE_SPEED

    elseif love.keyboard.isDown("down") then
        
        -- add positive paddle speed to current Y scaled by deltaTime
        -- paddle_2_y = math.min(VIRTUAL_HEIGHT - 20, paddle_2_y + (PADDLE_SPEED * dt))
        player_2.speed = PADDLE_SPEED;
    else
        player_2.speed = 0
    end

    -- ball movement, update the X and Y positions only if in play state
    -- scale the velocity by deltatime so movement is framerate-independent
    if game_state == "play" then
        ball:update(dt)
    end

    player_1:update(dt)
    player_2:update(dt)
end


--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access it.
]]
function love.keypressed(key)

    if key == "escape" then
        
		love.event.quit()
    
	-- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == "enter" or key == "return" then
        
		if game_state == "start" then
            game_state = "serve"
			
        elseif game_state == "serve" then
            game_state = "play"
        
		elseif game_state == "done" then
            
			-- game is restarting
            player_1_score = 0
            player_2_score = 0
            ball:reset()
            game_state = "serve"

            -- decide serving player as the opposite of who won
            if winner == 1 then
                serving_player = 2
            else
                serving_player = 1
            end
        end
    elseif key == "space" then
        serving_player = 1
        player_1_score = 0
        player_2_score = 0
        ball:reset()
        game_state = "serve"
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()

    -- begin rendering at virtual resolution
    push:apply("start")

    -- clear the screen with a specific color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(small_font)
	
	-- render the paddles (left and right side) and the ball (center)
    -- love.graphics.rectangle("fill", 10, paddle_1_y, 5, 20)
    -- love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, paddle_2_y, 5, 20)
    -- love.graphics.rectangle("fill", ball_x, ball_y, 4, 4)
    player_1:render()
    player_2:render()
    ball:render()
	
    displayScore()
    displayFPS()
    love.graphics.setColor(1, 1, 1, 255/255)

    if game_state == "start" then
        love.graphics.setFont(small_font)
        love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
    
	elseif game_state == "serve" then
        love.graphics.setFont(small_font)
        love.graphics.printf("Player " .. tostring(serving_player) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
    
	elseif game_state == "play" then
        -- no UI messages to display in play
    
	elseif game_state == "done" then
        love.graphics.setFont(large_font)
        love.graphics.printf("Player " .. tostring(winner) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(small_font)
        love.graphics.printf("Press Enter to restart!", 0, 30, VIRTUAL_WIDTH, "center")
    end

    -- end rendering at virtual resolution
    push:apply("end")
end


function displayFPS()
    love.graphics.setFont(small_font)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end


function displayScore()
    love.graphics.setFont(score_font)
    love.graphics.print(tostring(player_1_score), (VIRTUAL_WIDTH / 2) - 50, VIRTUAL_HEIGHT - 200)
    love.graphics.print(tostring(player_2_score), (VIRTUAL_WIDTH / 2) + 30, VIRTUAL_HEIGHT - 200)
end  
