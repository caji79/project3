-- main.lua (game loop)
-- Eli Chen
-- cmpm 121
io.stdout:setvbuf("no")

require "constants"
require "card"
require "grabber"
require "gameBoard"
local Player = require "player"
local Enemy = require "enemy"
local gm = require "gameManager"

function love.load()
    -- game window settings
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.window.setTitle('Titanomachy')
    love.graphics.setBackgroundColor(0.92, 0.75, 1)
    
    -- font
    CARD_DEFAULT_FONT = love.graphics.getFont()
    CARD_TEXT_FONT = love.graphics.newFont(CARD_TEXT_SIZE)
    UI_TEXT_FONT = love.graphics.newFont(UI_TEXT_SIZE)
    SCORE_TEXT_FONT = love.graphics.newFont(SCORE_TEXT_SIZE)
    TURN_TEXT_FONT = love.graphics.newFont(TURN_TEXT_SIZE)

    grabber = GrabberClass:new(playerHand)
    gm:init()
    
    playerHand = {}
    enemyHand = {}
    
    layoutPlayerHand()  -- lay out player hand cards at the bottom
    layoutEnemyHand()  -- lay out enemy hand cards at the bottom

end

function love.update(dt)
    gm:update(dt)
    
    grabber:update()

    for _, card in ipairs(playerHand) do
        card:checkForMouseOver(grabber)
        card:update()
    end
    
    for _, rec in ipairs(gm.staging) do
        rec.card:checkForMouseOver(grabber)
        rec.card:update()
    end
    
    for loc = 1, 3 do
        for _, card in ipairs(gm.board[loc]) do
            card:checkForMouseOver(grabber)
            card:update()
        end
    end

end

function love.draw()
    -- game over and play again
    if gm.phase == "gameover" then
        love.graphics.setColor(0,0,0,0.7)
        love.graphics.rectangle("fill", 0,0, SCREEN_WIDTH, SCREEN_HEIGHT)
        -- result text
        local msg
        if     gm.winner == "player" then msg = "You Win!"
        elseif gm.winner == "enemy"  then msg = "You Lose."
        else                             msg = "Tie Game"
        end

        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(
            msg,
            0, SCREEN_HEIGHT/2 - 40,
            SCREEN_WIDTH,
            "center"
        )

        -- play again button
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.setColor(0.2,0.6,0.2,1)
        love.graphics.rectangle(
            "fill",
            PLAY_AGAIN_BUTTON.x, PLAY_AGAIN_BUTTON.y,
            PLAY_AGAIN_BUTTON.w, PLAY_AGAIN_BUTTON.h,
            6,6
        )
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(
            "Play Again",
            PLAY_AGAIN_BUTTON.x,
            PLAY_AGAIN_BUTTON.y + PLAY_AGAIN_BUTTON.h/2 - 10,
            PLAY_AGAIN_BUTTON.w,
            "center"
        )
        return
    end
    GameBoardClass:draw()
  
    -- draw hand, staging, and board cards
    for _, card in ipairs(playerHand) do
        card:draw()
    end
    for _, card in ipairs(enemyHand) do
        card:draw()
    end
    for loc= 1, 3 do
        for _, card in ipairs(gm.board[loc]) do
            card:draw()
        end
    end
    for _, rec in ipairs(gm.staging) do
        rec.card:draw()
    end
    
    -- draw confirm button
    if gm:canConfirm() then
        love.graphics.setColor(0.2, 0.6, 0.2, 1)
        love.graphics.rectangle(
            'fill',
            CONFIRM_BUTTON.x, CONFIRM_BUTTON.y,
            CONFIRM_BUTTON.w, CONFIRM_BUTTON.h,
            6, 6
        )
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(UI_TEXT_FONT)
        love.graphics.printf("Confirm",
            CONFIRM_BUTTON.x, CONFIRM_BUTTON.y + CONFIRM_BUTTON.h/2 - 8,
            CONFIRM_BUTTON.w, "center"
        )
        love.graphics.setFont(CARD_DEFAULT_FONT)
    end
    
    -- draw pass button (only in staging)
    if gm.phase == "staging" then
        love.graphics.setColor(0.6, 0.2, 0.2, 1)
        love.graphics.rectangle(
            "fill",
            PASS_BUTTON.x, PASS_BUTTON.y,
            PASS_BUTTON.w, PASS_BUTTON.h,
            6,6
        )
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(UI_TEXT_FONT)
        love.graphics.printf(
            "Pass",
            PASS_BUTTON.x,
            PASS_BUTTON.y + PASS_BUTTON.h/2 - 8,
            PASS_BUTTON.w,
            "center"
        )
        love.graphics.setFont(CARD_DEFAULT_FONT)
    end
    
    -- draw player's power
    local playerPower = gm:getLocationPower("player")
    for loc = 1, 3 do
        local leftX  = _G["VERTICAL"..loc.."_X"]
        local rightX = _G["VERTICAL"..(loc+1).."_X"]
        local midX   = (leftX + rightX)/2
        local midY   = SCREEN_HEIGHT/2 + 25
        -- circle
        love.graphics.setColor(POWER_CIRCLE.color)
        love.graphics.circle("fill", midX, midY, POWER_CIRCLE.radius)
        -- text (white, centered)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(UI_TEXT_FONT)
        love.graphics.printf(
            tostring(playerPower[loc]),
            midX - POWER_CIRCLE.radius,
            midY - POWER_CIRCLE.radius/2,
            POWER_CIRCLE.radius*2,
            "center"
        )
        love.graphics.setFont(CARD_DEFAULT_FONT)
    end
    
    -- draw enemy's power
    local enemyPower = gm:getLocationPower("enemy")
    for loc = 1, 3 do
        local leftX  = _G["VERTICAL"..loc.."_X"]
        local rightX = _G["VERTICAL"..(loc+1).."_X"]
        local midX   = (leftX + rightX)/2
        local midY   = SCREEN_HEIGHT/2 - 25
        -- circle
        love.graphics.setColor(POWER_CIRCLE.color)
        love.graphics.circle("fill", midX, midY, POWER_CIRCLE.radius)
        -- text (white, centered)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(UI_TEXT_FONT)
        love.graphics.printf(
            tostring(enemyPower[loc]),
            midX - POWER_CIRCLE.radius,
            midY - POWER_CIRCLE.radius/2,
            POWER_CIRCLE.radius*2,
            "center"
        )
        love.graphics.setFont(CARD_DEFAULT_FONT)
    end
    
    -- draw player mana
    love.graphics.setColor(0, 0.5, 1, 1)  -- bright blue
    love.graphics.circle("fill",
        MANA_CIRCLE_P.x,
        MANA_CIRCLE_P.y,
        MANA_CIRCLE_P.r
    )
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(UI_TEXT_FONT)
    love.graphics.printf(
        tostring(gm.player.manaPool),
        MANA_CIRCLE_P.x - MANA_CIRCLE_P.r,
        MANA_CIRCLE_P.y - 8,
        MANA_CIRCLE_P.r * 2,
        "center"
    )
    love.graphics.setFont(CARD_DEFAULT_FONT)

    -- draw enemy mana
    love.graphics.setColor(0, 0.5, 1, 1)
    love.graphics.circle("fill",
        MANA_CIRCLE_E.x,
        MANA_CIRCLE_E.y,
        MANA_CIRCLE_E.r
    )
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(UI_TEXT_FONT)
    love.graphics.printf(
        tostring(gm.enemy.manaPool),
        MANA_CIRCLE_E.x - MANA_CIRCLE_E.r,
        MANA_CIRCLE_E.y - 8,
        MANA_CIRCLE_E.r * 2,
        "center"
    )
    love.graphics.setFont(CARD_DEFAULT_FONT)
    
    -- draw Player & Enemy scores
    love.graphics.setFont(SCORE_TEXT_FONT)
    love.graphics.setColor(1,1,1,1)
    -- player score
    love.graphics.print("Player Score", 10, SCREEN_HEIGHT/2-20)
    love.graphics.print(tostring(gm.player.score), 60, SCREEN_HEIGHT/2+20)
    -- enemy score
    love.graphics.print("Opponent", SCREEN_WIDTH - 120, SCREEN_HEIGHT/2-30)
    love.graphics.print("Score", SCREEN_WIDTH - 95, SCREEN_HEIGHT/2-5)
    love.graphics.print(tostring(gm.enemy.score), SCREEN_WIDTH - 75, SCREEN_HEIGHT/2+20)
    love.graphics.setFont(CARD_DEFAULT_FONT)
    
    -- hover text
    for _, card in ipairs(playerHand) do
        if card.state == CARD_STATE.MOUSE_OVER and card.faceUp then
            card:drawHoverText()
        end
    end
    for _, card in ipairs(enemyHand) do
        if card.state == CARD_STATE.MOUSE_OVER and card.faceUp then
            card:drawHoverText()
        end
    end
    for _, rec in ipairs(gm.staging) do
        if rec.card.state == CARD_STATE.MOUSE_OVER and rec.card.faceUp then
            rec.card:drawHoverText()
        end
    end
    for loc = 1, 3 do
        for _, card in ipairs(gm.board[loc]) do
            if card.faceUp and card.state == CARD_STATE.MOUSE_OVER then
                card:drawHoverText()
            end
        end
    end
    
    -- draw turn announce
    if gm.phase == "announce" then
        love.graphics.setFont(TURN_TEXT_FONT)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            "Turn " .. gm.turn,
            0,
            SCREEN_HEIGHT/2 - TURN_TEXT_FONT:getHeight()/2,
            SCREEN_WIDTH,
            "center"
        )
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(CARD_DEFAULT_FONT)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- confirm
        if gm:canConfirm() 
        and x >= CONFIRM_BUTTON.x and x <= CONFIRM_BUTTON.x + CONFIRM_BUTTON.w
        and y >= CONFIRM_BUTTON.y and y <= CONFIRM_BUTTON.y + CONFIRM_BUTTON.h then
            gm:confirmPlay()
            return
        end
        -- pass
        if gm.phase=="staging"
        and x >= PASS_BUTTON.x and x <= PASS_BUTTON.x + PASS_BUTTON.w
        and y >= PASS_BUTTON.y and y <= PASS_BUTTON.y + PASS_BUTTON.h then
            gm:pass()
            --gm:playEnemyTurn()
            return
        end
        -- play again
        if gm.phase == "gameover" then
            local b = PLAY_AGAIN_BUTTON
            if x >= b.x and x <= b.x + b.w
            and y >= b.y and y <= b.y + b.h then
                -- re-start the whole match
                gm:init()
                grabber = GrabberClass:new(playerHand)
                layoutPlayerHand()
                layoutEnemyHand()
            end
            return
        end
    end
end

function layoutPlayerHand()
    playerHand = {}
    -- re-position every card
    for i, card in ipairs(gm.player.hand) do
    card.faceUp    = true
    card.draggable = true

    -- compute x,y
    local x = SLOT_VERT1_X + (i-1)*(CARD_WIDTH + 20)
    local y = SCREEN_HEIGHT - CARD_HEIGHT/2
    card.position = Vector(x, y)

    table.insert(playerHand, card)
  end
end

function layoutEnemyHand()
    enemyHand = {}
    -- re-position every card
    for i, card in ipairs(gm.enemy.hand) do
    card.faceUp = false
    card.draggable = false

    -- compute x,y
    local x = SLOT_VERT6_X - (i-1) * (CARD_WIDTH + 20)
    local y = -CARD_HEIGHT/2
    card.position = Vector(x, y)

    table.insert(enemyHand, card)
  end
end