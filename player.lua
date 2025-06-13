-- player.lua

require "deck"

PlayerClass = {}

PLAYER_DECK = {
    "Zeus", "Hera", "Hermes", "Dionysus", "Medusa", 
    "Apollo", "Athena", "Midas", "Hydra", "Hades",
    "Ship of Theseus", "Poseidon", "Hephaestus", "Wooden Cow", "Pegasus"
}

function PlayerClass:new()
    local player = {}
    local metadata = {__index = PlayerClass}
    setmetatable(player, metadata)
    
    player.deck = DeckClass:new(PLAYER_DECK, 20, 2)
    player.hand = {}
    player.discardPile = {}
    player.mana = 0
    player.manaBonus = 0
    player.score = 0
    player.manaPool = 0
    
    return player
end

return PlayerClass