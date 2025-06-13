-- cardData.lua

local CARD_INFO = {
    Zeus = {
        name     = "Zeus",
        manaCost = 5,
        power    = 5,
        text     = "When Revealed: Lower the power of each card in your opponent's hand by 1."
    },
    Hera = {
        name     = "Hera",
        manaCost = 4,
        power    = 5,
        text     = "When Revealed: Give cards in your hand +1 power."
    },
    Hermes = {
        name     = "Hermes",
        manaCost = 3,
        power    = 2,
        text     = "When Revealed: Moves to another location."
    },
    Dionysus = {
        name     = "Dionysus",
        manaCost = 4,
        power    = 2,
        text     = "When Revealed: Gain +2 power for each of your other cards here."
    },
    Medusa = {
        name     = "Medusa",
        manaCost = 3,
        power    = 2,
        text     = "When ANY other card is played here, lower that card's power by 1."
    },
    Apollo = {
        name     = "Apollo",
        manaCost = 2,
        power    = 3,
        text     = "When Revealed: Gain +1 mana next turn."
    },
    Athena = {
        name     = "Athena",
        manaCost = 5,
        power    = 4,
        text     = "Gain +1 power when you play another card here."
    },
    Midas = {
        name     = "Midas",
        manaCost = 3,
        power    = 3,
        text     = "When Revealed: Set ALL cards here to 3 power."
    },
    Hydra = {
        name     = "Hydra",
        manaCost = 3,
        power    = 4,
        text     = "Add two copies to your hand when this card is discarded."
    },
    Hades = {
        name     = "Hades",
        manaCost = 5,
        power    = 3,
        text     = "When Revealed: Gain +2 power for each card in your discard pile."
    },
    ["Ship of Theseus"] = {
        name     = "Ship of Theseus",
        manaCost = 3,
        power    = 4,
        text     = "When Revealed: Add a copy with +1 power to your hand."
    },
    Poseidon = {
        name     = "Poseidon",
        manaCost = 5,
        power    = 3,
        text     = "When Revealed: Move away an enemy card here with the lowest power."
    },
    Hephaestus = {
        name     = "Hephaestus",
        manaCost = 4,
        power    = 2,
        text     = "When Revealed: Lower the cost of 2 cards in your hand by 1."
    },
    ["Wooden Cow"] = {
        name     = "Wooden Cow",
        manaCost = 1,
        power    = 1,
        text     = "Mooooo!"
    },
    Pegasus = {
        name     = "Pegasus",
        manaCost = 3,
        power    = 5,
        text     = "Gallop through the clouds!"
    },
    Ares = {
        name     = "Ares",
        manaCost = 3,
        power    = 2,
        text     = "When Revealed: Gain +2 power for each enemy card here."
    },
    Pandora = {
        name     = "Pandora",
        manaCost = 3,
        power    = 6,
        text     = "When Revealed: If no ally cards are here, lower this card's power by 5."
    },
    Iris = {
        name     = "Iris",
        manaCost = 6,
        power    = 9,
        text     = "End of Turn: Give your cards at each other location +1 power if they have unique powers."
    },
    Nyx = {
        name     = "Nyx",
        manaCost = 7,
        power    = 4,
        text     = "When Revealed: Discards your other cards here, add their power to this card."
    },
    Titan = {
        name     = "Titan",
        manaCost = 6,
        power    = 12,
        text     = "Ancient strength, unbound."
    }
}

return CARD_INFO