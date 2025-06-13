-- enemy.lua (AI)

require "deck"

EnemyClass = {}

ENEMY_DECK = {
    "Zeus", "Hera", "Hermes", "Dionysus", "Medusa",
    "Ares", "Pandora", "Iris", "Nyx", "Titan",
    "Hephaestus", "Hades", "Ship of Theseus", "Poseidon", "Wooden Cow"
}

function EnemyClass:new()
    local enemy = {}
    local metadata = {__index = EnemyClass}
    setmetatable(enemy, metadata)
    
    enemy.deck = DeckClass:new(ENEMY_DECK, 20, 2)
    enemy.hand = {}
    enemy.discardPile = {}
    enemy.mana = 0
    enemy.manaBonus = 0
    enemy.score = 0
    enemy.manaPool = 0
    
    return enemy
end

return EnemyClass