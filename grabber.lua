-- grabber.lua

require "vector"
require "constants"
require "gameManager"

GrabberClass = {}

function GrabberClass:new(playerHand)
    local grabber = {}
    local metadata = {__index = GrabberClass}
    setmetatable(grabber, metadata)

    grabber.currentMousePos = nil
    grabber.grabPos = nil
    grabber.mouseOffset = nil
    grabber.heldObject = nil
    
    grabber.playerSlots = {}
    grabber.enemySlots  = {}
    for loc = 1, 3 do
        grabber.playerSlots[loc] = {}
        grabber.enemySlots[loc]  = {}

        local colStart = (loc - 1)*2 + 1
        for offset = 0, 1 do
            local col = colStart + offset

            -- bottom half → player (rows 3–4)
            for row = 3, 4 do
                table.insert(grabber.playerSlots[loc], {
                  x     = _G["SLOT_VERT"..col.."_X"],
                  y     = _G["SLOT"..row.."_Y"],
                  w     = CARD_WIDTH,
                  h     = CARD_HEIGHT,
                  empty = true,
                  card  = nil
                })
            end
            -- top half → enemy (rows 1–2)
            for row = 1, 2 do
                table.insert(grabber.enemySlots[loc], {
                  x     = _G["SLOT_VERT"..col.."_X"],
                  y     = _G["SLOT"..row.."_Y"],
                  w     = CARD_WIDTH,
                  h     = CARD_HEIGHT,
                  empty = true,
                  card  = nil
                })
            end
        end
    end

    return grabber
end

function GrabberClass:update()
    self.currentMousePos = Vector(
        love.mouse.getX(), 
        love.mouse.getY()
    )
    
    -- mouse clicked and held down
    if love.mouse.isDown(1) and self.grabPos == nil then
        self:grab()
    end

    -- mouse release
    if not love.mouse.isDown(1) and self.grabPos ~= nil then
        self:release()
    end

end

function GrabberClass:grab()
    -- let all the cards have the grabbing feature
    for _, card in ipairs(playerHand) do
        if card.state == CARD_STATE.MOUSE_OVER and card.draggable then
            return self:startGrab(card)

        end
    end
    
    for i, rec in ipairs(GameManager.staging) do
        local card = rec.card
        if card.state==CARD_STATE.MOUSE_OVER and card.draggable then
            self:freeSlot(card)  -- update slot state (check if there's card in slot)
            table.remove(GameManager.staging, i)  -- remove from staging
            table.insert(playerHand, card)  -- put it back into hand (card is being held)
            return self:startGrab(card)
        end
    end
    

end

function GrabberClass:freeSlot(card)
    -- clear out any visual slot that was holding it
    for loc, slots in ipairs(self.playerSlots) do
      for _, slot in ipairs(slots) do
        if slot.card == card then
          slot.empty = true
          slot.card  = nil
          return
        end
      end
    end
    for loc, slots in ipairs(self.enemySlots) do
      for _, slot in ipairs(slots) do
        if slot.card == card then
          slot.empty = true
          slot.card  = nil
          return
        end
      end
    end
    -- remove it from the GameManager.board
    for loc = 1, 3 do
        local boardList = GameManager.board[loc]
        for i, c in ipairs(boardList) do
            if c == card then
                table.remove(boardList, i)
                break
            end
        end
    end
end

function GrabberClass:startGrab(card)
    self.heldObject = card
    card.state     = CARD_STATE.GRABBED
    card.originalPos = Vector(card.position.x, card.position.y)
    self.grabPos     = self.currentMousePos
    print("GRAB- " .. tostring(self.grabPos))
    self.mouseOffset = {
      x = self.currentMousePos.x - card.position.x,
      y = self.currentMousePos.y - card.position.y
    }
end

function GrabberClass:release()
    if self.heldObject == nil then return end
    
    local card = self.heldObject
    
    -- card center
    local cx = card.position.x + card.size.x/2
    local cy = card.position.y + card.size.y/2
    
    local slot, loc = self:validReleaseLocation(cx, cy)
    
    if slot then
        -- check & spend mana
        if not card.costPaid then
            if not GameManager:spendPlayerMana(card.manaCost) then
                -- not enough mana: bounce back
                card.position = card.originalPos
                return self:stateReset()
            end
            card.costPaid = true
        end
        -- snap and take slot
        card.position.x = slot.x
        card.position.y = slot.y
        slot.empty = false
        slot.card = card
        
        -- track placement
        local rec = { card=card, location=loc }
        GameManager:cardPlaced(rec)
    else
        -- go back to its original position if dropping is invalid
        card.position = card.originalPos
    end
    -- reset states in grabber
    self:stateReset()
end

function GrabberClass:stateReset()
    if self.heldObject then
        self.heldObject.state = CARD_STATE.IDLE
    end
    
    self.heldObject = nil
    self.grabPos = nil
    self.mouseOffset = nil
    
end

function GrabberClass:validReleaseLocation(cx, cy)
    for loc,data in ipairs(self.playerSlots) do
        for _,slot in ipairs(data) do
            if slot.empty
            and cx >= slot.x and cx <= slot.x+slot.w
            and cy >= slot.y and cy <= slot.y+slot.h then
              return slot, loc
            end
        end
    end
    return nil
end
