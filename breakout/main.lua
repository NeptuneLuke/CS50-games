--[[
    
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Originally developed by Atari in 1976. An effective evolution of
    Pong, Breakout ditched the two-player mechanic in favor of a single-
    player game where the player, still controlling a paddle, was tasked
    with eliminating a screen full of differently placed bricks of varying
    values by deflecting a ball back at them.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch

    Credit for music (great loop):
    http://freesound.org/people/joshuaempyre/sounds/251461/
    http://www.soundcloud.com/empyreanma
]]


require "src/Dependencies"


function love.load()
    
    love.window.setTitle("Breakout Remake")
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    fonts = {
        ["small"] = love.graphics.newFont("fonts/font.ttf", 8),
        ["medium"] = love.graphics.newFont("fonts/font.ttf", 16),
        ["large"] = love.graphics.newFont("fonts/font.ttf", 32)
    }
    love.graphics.setFont(fonts["small"])

    textures = {
        ["background"] = love.graphics.newImage("img/background.png"),
        ["main"] = love.graphics.newImage("img/breakout.png"),
        ["arrows"] = love.graphics.newImage("img/arrows.png"),
        ["hearts"] = love.graphics.newImage("img/hearts.png"),
        ["particle"] = love.graphics.newImage("img/particle.png")
    }

    -- Quads we will generate for all of our textures; Quads allow us
    -- to show only part of a texture and not the entire sprite sheet
    frames = {
        ["arrows"] = GenerateQuads(textures["arrows"], 24, 24),
        ["paddles"] = GenerateQuadsPaddles(textures["main"]),
        ["balls"] = GenerateQuadsBalls(textures["main"]),
        ["bricks"] = GenerateQuadsBricks(textures["main"]),
        ["hearts"] = GenerateQuads(textures["hearts"], 10, 9)
    }

    sounds = {
        ["paddle-hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall-hit"] = love.audio.newSource("sounds/wall_hit.wav", "static"),
        ["confirm"] = love.audio.newSource("sounds/confirm.wav", "static"),
        ["select"] = love.audio.newSource("sounds/select.wav", "static"),
        ["no-select"] = love.audio.newSource("sounds/no-select.wav", "static"),
        ["brick-hit-1"] = love.audio.newSource("sounds/brick-hit-1.wav", "static"),
        ["brick-hit-2"] = love.audio.newSource("sounds/brick-hit-2.wav", "static"),
        ["hurt"] = love.audio.newSource("sounds/hurt.wav", "static"),
        ["victory"] = love.audio.newSource("sounds/victory.wav", "static"),
        ["recover"] = love.audio.newSource("sounds/recover.wav", "static"),
        ["high-score"] = love.audio.newSource("sounds/high_score.wav", "static"),
        ["pause"] = love.audio.newSource("sounds/pause.wav", "static"),
        ["music"] = love.audio.newSource("sounds/music.wav", "static")
    }

    -- game states:
    -- 1. "start" (the beginning of the game, where we're told to press Enter)
    -- 2. "paddle-select" (where we get to choose the color of our paddle)
    -- 3. "serve" (waiting on a key press to serve the ball)
    -- 4. "play" (the ball is in play, bouncing between paddles)
    -- 5. "victory" (the current level is over, with a victory jingle)
    -- 6. "game-over" (the player has lost; display score and allow restart)
    game_state_machine = StateMachine {
        ["start"] = function() return StartState() end,
        ["play"] = function() return PlayState() end,
        ["serve"] = function() return ServeState() end,
        ["game-over"] = function() return GameOverState() end,
        ["victory"] = function() return VictoryState() end,
        ["high-scores"] = function() return HighScoreState() end,
        ["enter-high-score"] = function() return EnterHighScoreState() end,
        ["paddle-select"] = function() return PaddleSelectState() end
    }
    game_state_machine:change("start", { highscores = loadHighScores() })

    -- play our music outside of all states and set it to looping
    sounds["music"]:play()
    sounds["music"]:setLooping(true)

    love.keyboard.keysPressed = {}
end


function love.resize(width, height)
    push:resize(width, height)
end


function love.update(dt)
    
    -- pass in deltaTime to the state object we're currently using
    game_state_machine:update(dt)

    -- reset keys pressed
    love.keyboard.keysPressed = {}
end


--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end


--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end


--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    
    push:apply("start")

    -- background should be drawn regardless of state, scaled to fit our
    -- virtual resolution
    local background_width = textures["background"]:getWidth()
    local background_height = textures["background"]:getHeight()

    love.graphics.draw( textures["background"], 
        
        -- draw at coordinates 0, 0 
        0, 0, 
        
        -- no rotation
        0,
        
        -- scale factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (background_width - 1), VIRTUAL_HEIGHT / (background_height - 1))
    
    -- use the state machine to defer rendering to the current state we're in
    game_state_machine:render()
    
    displayFPS()
    
    push:apply("end")
end


--[[
    Loads high scores from a .lst file, saved in LÖVE2D's default save directory in a subfolder
    called "breakout-remake".
]]
function loadHighScores()
    
    love.filesystem.setIdentity("breakout-remake")

    -- if the file doesn't exist, initialize it with some default scores
    if not love.filesystem.getInfo("breakout-remake.lst") then
        
        local scores = ""
        for i = 10, 1, -1 do
            scores = scores .. "CTO\n"
            scores = scores .. tostring(i * 1000) .. "\n"
        end

        love.filesystem.write("breakout-remake.lst", scores)
    end

    -- flag for whether we're reading a name or not
    local name = true
    local counter = 1

    -- initialize scores table with at least 10 blank entries
    local scores = {}
    for i = 1, 10 do
        -- blank table; each will hold a name and a score
        scores[i] = { name = nil, score = nil }
    end

    -- iterate over each line in the file, filling in names and scores
    for line in love.filesystem.lines("breakout-remake.lst") do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        -- flip the name flag
        name = not name
    end

    return scores
end


--[[
    Renders hearts based on how much health the player has. First renders
    full hearts, then empty hearts for however much health we're missing.
]]
function renderHealth(health)
    
    -- start of our health rendering
    local current_health = VIRTUAL_WIDTH - 100
    
    -- render health left
    for i = 1, health do
        love.graphics.draw(textures["hearts"], frames["hearts"][1], current_health, 4)
        current_health = current_health + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(textures["hearts"], frames["hearts"][2], current_health, 4)
        current_health = current_health + 11
    end
end


function renderScore(score)
    -- render the player's score at the top right, with left-side padding
    love.graphics.setFont(fonts["small"])
    love.graphics.print("Score:", VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, "right")
end


function displayFPS()
    love.graphics.setFont(fonts["small"])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end