-- gameManager.lua

local Player = require "player"
local Enemy = require "enemy"
local Effects = require "cardEffect"

GameManager = {
    phase = "staging",
    turn = 1,
    winScore = 20,
    player = nil,
    enemy = nil,
    winner = nil,
    confirmVisible = false,
    staging = {},
    board = {
        [1] = {},
        [2] = {},
        [3] = {}
    },
    turnShowTime = 0,
    turnShowDur  = 1.5
}

function GameManager:init()
    self.player = Player:new()
    self.enemy = Enemy:new()
    
    -- draw starting hand & ownership
    self.player.hand = self.player.deck:drawCards(3)
    for _, card in ipairs(self.player.hand) do card.owner = "player" end
    
    self.enemy.hand = self.enemy.deck:drawCards(3)
    for _, card in ipairs(self.enemy.hand) do card.owner = "enemy" end
    
    self.staging = {}
    self.board   = { [1]={}, [2]={}, [3]={} }

    -- reset
    self.phase          = "staging"
    self.confirmVisible = false
    self.turn           = 1
    self.winner         = nil
    self.player.score   = 0
    self.enemy.score    = 0
    self.player.manaPool = self.turn
    self.enemy.manaPool  = self.turn

    -- clear out old slots 
    for _,slots in pairs(grabber.playerSlots) do
        for _,slot in ipairs(slots) do
            slot.empty = true
            slot.card  = nil
        end
    end
    for _,slots in pairs(grabber.enemySlots) do
        for _,slot in ipairs(slots) do
            slot.empty = true
            slot.card  = nil
        end
    end

    -- lay out hands in their new, empty state
    layoutPlayerHand()
    layoutEnemyHand()
end

-- call when a card is dropped successfully (in grabber release)
function GameManager:cardPlaced(rec)
    -- remove the card from the player’s hand
    for i, c in ipairs(self.player.hand) do
        if c == rec.card then
            table.remove(self.player.hand, i)
            break
        end
    end
    table.insert(self.staging, rec)
    layoutPlayerHand()
    layoutEnemyHand()
    
    -- once first card is placed, show the confirm button
    self.confirmVisible = #self.staging > 0
end

function GameManager:canConfirm()
    return self.phase == "staging"
       and self.confirmVisible
       and #self.staging > 0
end

-- player submit the play
function GameManager:confirmPlay()
    if not self:canConfirm() then return end
    
    -- lock and flip the cards face down
    self.confirmVisible = false
    self.phase = "revealing"
    self.revealQueue = {}
    
    for _, rec in ipairs(self.staging) do
        rec.card.faceUp = false
        rec.card.draggable = false
    end
    
    self.confirmVisible = false
    self:endTurn()
end

function GameManager:startReveal(stagingRecs, enemyRecs)
    self.phase = "revealing"
    self.revealQueue = {}
    -- flip them face‐down & queue them in order:
    for _, rec in ipairs(stagingRecs) do
        rec.card.faceUp = false
        table.insert(self.board[rec.location], rec.card)
        table.insert(self.revealQueue, rec)
    end
    for _, rec in ipairs(enemyRecs) do
        rec.card.faceUp = false
        table.insert(self.board[rec.location], rec.card)
        table.insert(self.revealQueue, rec)
    end
    -- schedule the first flip
    self.nextRevealTime = love.timer.getTime() + 0.75
end

function GameManager:update(dt)
    if self.phase == "announce" then
        self.turnShowTime = self.turnShowTime - dt
        if self.turnShowTime <= 0 then
            -- done announcing, actually enter staging
            self.phase = "staging"
            self.confirmVisible = false
            layoutPlayerHand()
            layoutEnemyHand()
        end
        return
    end
  
    if self.phase=="revealing" and self.revealQueue then
        if love.timer.getTime() >= self.nextRevealTime then
            local rec = table.remove(self.revealQueue,1)
            rec.card.faceUp = true
            Effects.onReveal(rec, self)
            self.nextRevealTime = love.timer.getTime() + 1.25
        end

        if #self.revealQueue==0 then
            -- all flipped, do scoring + end‐of‐turn effects + next turn
            local pPts,ePts = self:calculateScores()
            self.player.score = self.player.score + pPts
            self.enemy.score  = self.enemy.score  + ePts
            --Effects.onEndOfTurn(self)
            
            -- check for win
            local result = self:checkForWin()
            if result == "player" or result == "enemy" then
                self.phase  = "gameover"
                self.winner = result
            else
                self:nextTurn()
            end
        end
    end
end

function GameManager:calculateScores()
    local totalP = 0
    local totalE = 0
    
    for loc = 1, 3 do
        local playerPower = 0
        local enemyPower = 0
        
        -- sum up power
        -- confirmed board cards
        for _, card in ipairs(self.board[loc]) do
            if     card.owner == "player" then playerPower = playerPower + card.power
            elseif card.owner == "enemy"  then enemyPower  = enemyPower  + card.power
            end
        end
        -- current turn’s staging
        for _, rec in ipairs(self.staging) do
            if     rec.location == loc and rec.card.owner == "player" then playerPower = playerPower + rec.card.power
            elseif rec.location == loc and rec.card.owner == "enemy"  then enemyPower  = enemyPower  + rec.card.power
            end
        end
        
        -- power difference
        if playerPower > enemyPower then
            totalP = totalP + (playerPower - enemyPower)
        elseif enemyPower > playerPower then
            totalE = totalE + (enemyPower - playerPower)
        end
    end
    
    return totalP, totalE
end

function GameManager:getLocationPower(owner)
    local sums = { 0, 0, 0 }
    -- board (confirmed)
    for loc=1,3 do
        for _, card in ipairs(self.board[loc]) do
            if card.owner == owner then
                sums[loc] = sums[loc] + card.power
            end
        end
    end
    -- staging (this turn’s placements)
    for _, rec in ipairs(self.staging) do
        if rec.card.owner == owner then
            sums[ rec.location ] = sums[ rec.location ] + rec.card.power
        end
    end
    return sums
end

function GameManager:nextTurn()
    self.turn = self.turn + 1
    self.player.manaPool = self.player.manaPool + self.turn + (self.player.manaBonus or 0)
    self.player.manaBonus = 0
    self.enemy.manaPool = self.enemy.manaPool + self.turn + (self.enemy.manaBonus or 0)
    self.enemy.manaBonus = 0
    
    self.phase = "announce"
    self.turnShowTime = self.turnShowDur
    self.staging = {}
    self.confirmVisible = false
    
    -- draw & refresh hand (only if under hand max)
    if #self.player.hand < MAX_HAND_SIZE then
        local playerNewCard = self.player.deck:drawCards(1)[1]
        if playerNewCard then
            playerNewCard.owner = "player"
            table.insert(self.player.hand, playerNewCard)
            layoutPlayerHand()
            
            table.insert(playerHand, playerNewCard)
        end
    end
    
    if #self.enemy.hand < MAX_HAND_SIZE then
        local enemyNewCard = self.enemy.deck:drawCards(1)[1]
        if enemyNewCard then
            enemyNewCard.owner = "enemy"
            table.insert(self.enemy.hand, enemyNewCard)
            layoutEnemyHand()
            
            table.insert(enemyHand, enemyNewCard)
        end
    end
end

function GameManager:checkForWin()
    if self.player.score >= self.winScore 
    or self.enemy.score >= self.winScore then
        if self.player.score > self.enemy.score then
            return "player"
        elseif self.enemy.score > self.player.score then
            return "enemy"
        end
    end
    return nil
end

function GameManager:spendPlayerMana(cost)
    if self.player.manaPool < cost then
      return false
    end
    self.player.manaPool = self.player.manaPool - cost
    return true
end

function GameManager:spendEnemyMana(cost)
    if self.enemy.manaPool < cost then
      return false
    end
    self.enemy.manaPool = self.enemy.manaPool - cost
    return true
end

function GameManager:pass()
    if self.phase ~= "staging" then
        return
    end

    for _, rec in ipairs(self.staging) do
        local card = rec.card
        -- free the visual slot
        grabber:freeSlot(card)

        -- refund the one-time payment
        if card.costPaid then
            self.player.manaPool = self.player.manaPool + card.manaCost
            card.costPaid = false
        end

        -- return it to the player’s hand
        table.insert(self.player.hand, card)
    end

    self.staging       = {}
    self.confirmVisible = false
    layoutPlayerHand()
    layoutEnemyHand()

    self:endTurn()
end

function GameManager:endTurn()
    local enemyRecs = self:playEnemyTurn()
    --self:reveal()
    self:startReveal(self.staging, enemyRecs)
    self.staging = {}
    self.confirmVisible = false
end

function GameManager:playEnemyTurn()
    local recs = {}
    local hand = self.enemy.hand
    local pool = self.enemy.manaPool

    -- find all cards enemy can afford
    local affordable = {}
    for idx, card in ipairs(hand) do
      if card.manaCost <= pool then
        table.insert(affordable, { i = idx, card = card })
      end
    end
    if #affordable == 0 then
        return recs
    end

    -- pick a random affordable card
    local pick = affordable[love.math.random(#affordable)]
    local idx, card = pick.i, pick.card

    -- find all truly empty enemy slots
    local empties = {}
    for loc, slots in ipairs(grabber.enemySlots) do
      for _, slot in ipairs(slots) do
        if slot.empty then
          table.insert(empties, { slot = slot, loc = loc })
        end
      end
    end
    if #empties == 0 then
        return recs
    end

    -- choose one
    local choice = empties[love.math.random(#empties)]
    local slot, loc = choice.slot, choice.loc

    self:spendEnemyMana(card.manaCost)  -- spend the mana

    -- remove from enemy hand
    table.remove(hand, idx)
    layoutEnemyHand()

    -- drop it into that slot visually
    card.position.x, card.position.y = slot.x, slot.y
    card.faceUp    = true
    card.draggable = false
    slot.empty = false
    slot.card  = card

    -- move it into the permanent board
    --table.insert(self.board[loc], card)
    local rec = { card = card, location = loc }
    table.insert(recs, rec)
    
    return recs
end

return GameManager