--[[
    
    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]


-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row


LevelMaker = Class{}


--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    
    local bricks = {}
    
    local rows = math.random(1, 5)      -- randomly choose the number of rows
    local columns = math.random(7, 13)  -- randomly choose the number of columns, ensuring odd
    columns = columns % 2 == 0 and (columns + 1) or columns
    
    local highest_tier = math.min(3, math.floor(level / 5)) -- highest possible spawned brick color in this level, no higher than 3
    local highest_color = math.min(5, level % 5 + 3)        -- highest color of the highest tier, no higher than 5

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, rows do
        
        local skip_pattern = math.random(1, 2) == 1 and true or false       -- whether we want to enable skipping for this row
        local alternate_pattern = math.random(1, 2) == 1 and true or false   -- whether we want to enable alternating colors for this row
        
        -- choose two colors to alternate between
        local alternate_color_1 = math.random(1, highest_color)
        local alternate_color_2 = math.random(1, highest_color)
        local alternate_tier_1 = math.random(0, highest_tier)
        local alternate_tier_2 = math.random(0, highest_tier)
        
        local skip_flag = math.random(2) == 1 and true or false         -- used only when we want to skip a block, for skip pattern
        local alternate_flag = math.random(2) == 1 and true or false    -- used only when we want to alternate a block, for alternate pattern

        -- solid color we'll use if we're not skipping or alternating
        local solid_color = math.random(1, highest_color)
        local solid_tier = math.random(0, highest_tier)

        for x = 1, columns do
            
            -- if skipping is turned on and we're on a skip iteration
            if skip_pattern and skip_flag then
                
                skip_flag = not skip_flag   -- turn skipping off for the next iteration
                goto continue               -- Lua doesn't have a continue statement, so this is the workaround
            else
                skip_flag = not skip_flag   -- flip the flag to true on an iteration we don't use it
            end

            b = Brick(
                -- x-coordinate
                (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                    -- multiply by 32, the brick width
                + 8                     -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                + (13 - columns) * 16,  -- left-side padding for when there are fewer than 13 columns
                
                -- y-coordinate
                y * 16                  -- just use y * 16, since we need top padding anyway
            )

            -- if we're alternating, figure out which color/tier we're on
            if alternate_pattern and alternate_flag then
                b.color = alternate_color_1
                b.tier = alternate_tier_1
                alternate_flag = not alternate_flag
            
            else
                b.color = alternate_color_2
                b.tier = alternate_tier_2
                alternate_flag = not alternate_flag
            end

            -- if not alternating and we made it here, use the solid color/tier
            if not alternate_pattern then
                b.color = solid_color
                b.tier = solid_tier
            end 

            table.insert(bricks, b)
            ::continue::            -- Lua's version of the "continue" statement
        end
    end 

    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end