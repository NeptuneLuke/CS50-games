--[[

    Original Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by: NeptuneLuke @Github

    Helper functions for writing games.
]]


--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tile_width, tile_height)
    
    local sheet_width = atlas:getWidth() / tile_width
    local sheet_height = atlas:getHeight() / tile_height

    local sheet_counter = 1
    local spritesheet = {}

    for y = 0, sheet_height - 1 do
        
        for x = 0, sheet_width - 1 do
            
            spritesheet[sheet_counter] = love.graphics.newQuad(x * tile_width, y * tile_height, 
                tile_width, tile_height,  atlas:getDimensions())
            
                sheet_counter = sheet_counter + 1
        end
    end

    return spritesheet
end


--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]
function table.slice(tbl, first, last, step)
    
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end


--[[
    Piece out the bricks from the sprite sheet. 
    Since the sprite sheet has non-uniform sprites within,
    we have to return a subset of GenerateQuads.
]]
function GenerateQuadsBricks(atlas)
    return table.slice(GenerateQuads(atlas, 32, 16), 1, 21)
end


--[[
    Piece out the paddles from the sprite sheet. 
    For this, we have to piece out the paddles a little more
    manually, since they are all different sizes.
]]
function GenerateQuadsPaddles(atlas)
    
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        
        -- smallest
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        counter = counter + 1
        
        -- medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16, atlas:getDimensions())
        counter = counter + 1
        
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16, atlas:getDimensions())
        counter = counter + 1
        
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16, atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end


--[[
    Piece out the balls from the sprite sheet. 
    For this, we have to piece out the balls a little more
    manually, since they are in an awkward part of the sheet and small.
]]
function GenerateQuadsBalls(atlas)
    
    local x = 96
    local y = 48

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    x = 96
    y = 56

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end