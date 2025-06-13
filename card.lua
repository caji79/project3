-- card.lua

require "vector"
require "constants"

CardClass = {}

CARD_STATE = {
    IDLE = 0,
    MOUSE_OVER = 1,
    GRABBED = 2
}

function CardClass:new(xPos, yPos, name, mana, power, text, faceUp, owner)
    local card = {}
    local metadata = {__index = CardClass}
    setmetatable(card, metadata)

    card.position = Vector(xPos, yPos)
    card.size = Vector(CARD_WIDTH, CARD_HEIGHT)
    card.state = CARD_STATE.IDLE
    card.faceUp = faceUp or false
    card.draggable = true
    
    -- card info & stats
    card.name = name
    card.manaCost = mana
    card.costPaid = false
    card.power = power
    card.text = text
    
    card.owner = owner

    return card
end

function CardClass:update()
    if self.state == CARD_STATE.GRABBED and grabber.heldObject == self then
        self.position.x = grabber.currentMousePos.x - grabber.mouseOffset.x
        self.position.y = grabber.currentMousePos.y - grabber.mouseOffset.y
    end
    
    -- debug
    -- print("heldObject:", grabber.heldObject)
    -- print("self:", self)
    -- print("grabber.heldObject == self:", grabber.heldObject == self)
end

function CardClass:draw()
    if self.faceUp then
        love.graphics.setColor(1, 1, 1, 1)  -- white (front)
    else
        love.graphics.setColor(0.3, 0.12, 0.4, 1)  -- dark purple (back)
    end

    -- card rendering
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
    
    -- draw card name & stat if faceUp
    if self.faceUp then
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(self.name, self.position.x + 5, self.position.y + 5)
        love.graphics.print("Cost:"..self.manaCost, self.position.x + 5, self.position.y + 25)
        love.graphics.print("Pow:"..self.power, self.position.x + 5, self.position.y + 45)
    end

    -- card state debugging
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.state), self.position.x, self.position.y - 20)

end

function CardClass:checkForMouseOver(grabber)
    if self.state == CARD_STATE.GRABBED then
        return
    end
      
    local mousePos = grabber.currentMousePos
    local isMouseOver = 
        mousePos.x > self.position.x and
        mousePos.x < self.position.x + self.size.x and
        mousePos.y > self.position.y and
        mousePos.y < self.position.y + self.size.y
    
    self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
end

function CardClass:drawHoverText()
--    if not (self.faceUp and self.state == CARD_STATE.MOUSE_OVER) then
--        return
--    end
    
    local padding = 6
    local wrapWidth = 150
    local font = CARD_TEXT_FONT
    
    -- lines for wrapping text
    local lines = 5
    local fontHeight = font:getHeight()
    
    -- dimensions
    local boxW = wrapWidth + padding*2
    local boxH = (fontHeight * lines) + padding*2
    
    -- box position
    local boxX = self.position.x + TEXT_OFFSET_X
    local boxY = self.position.y + TEXT_OFFSET_Y
    
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 4, 4)
    
    -- text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(self.text, boxX + padding, boxY + padding, wrapWidth)
    love.graphics.setFont(CARD_DEFAULT_FONT)
    
end