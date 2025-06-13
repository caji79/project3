-- gameBoard.lua
-- simple game board rendering, including locations and card slots 
require "constants"

GameBoardClass = {}

function GameBoardClass:new()
    local gameBoard = {}
    local metadata = {__index = GameBoardClass}
    setmetatable(gameBoard, metadata)

    return gameBoard
end

function GameBoardClass:draw()
    self:cardLocations()
    self:cardSlots()
end

function GameBoardClass:cardLocations()
    -- vertical location lines
    --love.graphics.line(VERTICAL1_X, VERTICAL_Y, VERTICAL1_X, SCREEN_HEIGHT - VERTICAL_Y)
    love.graphics.line(VERTICAL2_X, VERTICAL_Y, VERTICAL2_X, SCREEN_HEIGHT - VERTICAL_Y)
    love.graphics.line(VERTICAL3_X, VERTICAL_Y, VERTICAL3_X, SCREEN_HEIGHT - VERTICAL_Y)
    --love.graphics.line(VERTICAL4_X, VERTICAL_Y, VERTICAL4_X, SCREEN_HEIGHT - VERTICAL_Y)
    -- horizontal mid line
    --love.graphics.line(VERTICAL1_X, SCREEN_HEIGHT/2, SCREEN_WIDTH - VERTICAL1_X, SCREEN_HEIGHT/2)
end

function GameBoardClass:cardSlots()
    -- line 1
    love.graphics.rectangle('line', SLOT_VERT1_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT1_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT1_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT1_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    -- line 2
    love.graphics.rectangle('line', SLOT_VERT2_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT2_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT2_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT2_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    -- line 3
    love.graphics.rectangle('line', SLOT_VERT3_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT3_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT3_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT3_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    -- line 4
    love.graphics.rectangle('line', SLOT_VERT4_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT4_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT4_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT4_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    -- line 5
    love.graphics.rectangle('line', SLOT_VERT5_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT5_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT5_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT5_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    -- line 6
    love.graphics.rectangle('line', SLOT_VERT6_X, SLOT1_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT6_X, SLOT2_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT6_X, SLOT3_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
    love.graphics.rectangle('line', SLOT_VERT6_X, SLOT4_Y, CARD_WIDTH, CARD_HEIGHT, 6, 6)
end