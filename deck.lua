-- deck.lua

local CARD_INFO = require "cardData"
require "card"

DeckClass = {}

function DeckClass:new(deckBuild, deckSize, copyLimit)
    local deck = {}
    local metadata = {__index = DeckClass}
    setmetatable(deck, metadata)
    
    deck.cards = {}
    deck.build = deckBuild
    deck.size = deckSize
    deck.copyMax = copyLimit
    
    -- create a 20 cards deck
    deck:createDeck()
    
    -- shuffle deck
    deck:shuffle()
    
    return deck
end

function DeckClass:createDeck()
    local counts = {}
    
    -- fill up to deckSize
    while #self.cards < self.size do
        local name = self.build[love.math.random(#self.build)]  -- pick a random name from deckBuild
        counts[name] = counts[name] or 0

        if counts[name] < self.copyMax then
            local info = CARD_INFO[name]
            if not info then 
                error("deck.lua:createDeck()—no CARD_INFO for `"..tostring(name).."`")
            end
            local c = CardClass:new(0, 0, info.name, info.manaCost, info.power, info.text, false, owner)
            table.insert(self.cards, c)
            counts[name] = counts[name] + 1
        end
    end
end

function DeckClass:shuffle()
    for i = #self.cards, 2, -1 do
        local j = love.math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function DeckClass:drawCards(n)
    local drawn = {}
    
    for i = 1, (n or 1) do
        if #self.cards == 0 then break end
        table.insert(drawn, table.remove(self.cards, 1))
    end
    
    return drawn
end

return DeckClass