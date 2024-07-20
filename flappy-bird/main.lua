--[[
    GD50
    Flappy Bird Remake

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by:  NeptuneLuke @Github

    A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple 
    but effective gameplay mechanic of avoiding pipes indefinitely by just tapping 
    the screen, making the player's bird avatar flap its wings and move upwards slightly. 
    A variant of popular games like "Helicopter Game" that floated around the internet
    for years prior. Illustrates some of the most basic procedural generation of game
    levels possible as by having pipes stick out of the ground by varying amounts, acting
    as an infinitely generated obstacle course for the player.
]]

-- https://github.com/Ulydev/push
-- virtual resolution handling library
push = require "libs.push"

-- https://github.com/vrld/hump/blob/master/class.lua
-- OOP handling library
Class = require "libs.class"

require "StateMachine"
require "states/BaseState"
require "states/PlayState"
require "states/TitleScreenState"
require "states/ScoreState"
require "states/CountdownState"

require "Bird"
require "Pipe"
require "PipePair"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288


-- images and their starting scroll location (X axis)
local background = love.graphics.newImage("res/img/background.png")
local background_scroll = 0
local ground = love.graphics.newImage("res/img/ground.png")
local ground_scroll = 0

-- speed at which we should scroll the images, scaled by deltaTime
-- so that it is framerate-independent
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop the background and ground back to X = 0
-- we should choose a point halfway through the width of background.png
-- that looks exactly like the beginning of the background.png
local BACKGROUND_LOOPING_POINT = 413


function love.load()

    love.window.setTitle("Flappy Bird Remake")
    love.graphics.setDefaultFilter("nearest", "nearest")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
    })

    -- initialize our nice-looking retro text fonts
    small_font = love.graphics.newFont("res/fonts/font.ttf", 8)
    medium_font = love.graphics.newFont("res/fonts/flappy.ttf", 14)
    flappy_font = love.graphics.newFont("res/fonts/flappy.ttf", 28)
    large_font = love.graphics.newFont("res/fonts/flappy.ttf", 56)
    love.graphics.setFont(flappy_font)

    sounds = {
        ["explosion"] = love.audio.newSource("res/sounds/explosion.wav", "static"),
        ["hurt"] = love.audio.newSource("res/sounds/hurt.wav", "static"),
        ["jump"] = love.audio.newSource("res/sounds/jump.wav", "static"),
        ["score"] = love.audio.newSource("res/sounds/score.wav", "static"),
        ["music"] = love.audio.newSource("res/sounds/marios_way.mp3", "static")
    }
    
    sounds["music"]:setLooping(true)
    sounds["music"]:play()

    -- initialize state machine with all state-returning functions
    game_state_machine = StateMachine {
        ["title"] = function() return TitleScreenState() end,
        ["play"] = function() return PlayState() end,
        ["score"] = function() return ScoreState() end,
        ["countdown"] = function() return CountdownState() end
    }
    game_state_machine:change("title")

    -- initialize input table
    love.keyboard.keysPressed = {}
end


function love.resize(width, height)
    push:resize(width, height)
end


function love.keypressed(key)
    
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == "escape" then
        love.event.quit()
    end
end


--[[
    New function used to check our global input table for keys we activated during
    this frame, looked up by their string value.
]]
function love.keyboard.wasPressed(key)

    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
    
    -- or just: return love.keyboard.keysPressed[key]
end


function love.update(dt)

    -- update background and ground scroll offsets
    background_scroll = (background_scroll + (BACKGROUND_SCROLL_SPEED * dt)) % BACKGROUND_LOOPING_POINT
    ground_scroll = (ground_scroll + (GROUND_SCROLL_SPEED * dt)) % VIRTUAL_WIDTH

    -- now, we just update the state machine, which defers to the right state
    game_state_machine:update(dt)
    
    -- reset input table
    love.keyboard.keysPressed = {}
end


function love.draw()
    
    push:start()
    
    -- draw state machine between the background and ground, which defers
    -- render logic to the currently active state
    love.graphics.draw(background, -background_scroll, 0)
    game_state_machine:render()
    love.graphics.draw(ground, -ground_scroll, VIRTUAL_HEIGHT - 16)
    
    push:finish()
end