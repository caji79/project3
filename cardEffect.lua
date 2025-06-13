-- cardEffect.lua

local CARD_INFO = require "cardData"

local Effects = {}

-- copy a card
function cloneCard(card)
  local copy = {}
  for k,v in pairs(card) do copy[k]=v end
  return copy
end

-- get owner/opponent tables from GameManager
function ownerTables(gm, owner)
  if owner == "player" then
    return gm.player, gm.enemy
  else
    return gm.enemy, gm.player
  end
end

function Effects.onReveal(rec, gm)
  local c     = rec.card
  local loc   = rec.location
  local info  = CARD_INFO[c.name]
  if not info or not info.text:match("When Revealed") then
    return
  end

  local me, you = ownerTables(gm, c.owner)

  if c.name == "Zeus" then
    -- lower the power of each card in opponent’s hand by 1
    for _, card in ipairs(you.hand) do
      card.power = math.max(0, card.power - 1)
    end

  elseif c.name == "Hera" then
    -- Give all cards in your hand +1 power
    for _, card in ipairs(me.hand) do
      card.power = card.power + 1
    end

  elseif c.name == "Dionysus" then
    -- Gain +2 power for each of your other cards here
    local bonus = 0
    for _, boardCard in ipairs(gm.board[loc]) do
      if boardCard.owner == c.owner and boardCard ~= c then
        bonus = bonus + 2
      end
    end
    c.power = c.power + bonus

  elseif c.name == "Apollo" then
    -- Gain +1 extra mana next turn
    local me, _ = ownerTables(gm, c.owner)
    me.manaBonus = (me.manaBonus or 0) + 1

  elseif c.name == "Ares" then
    -- Gain +2 power for each enemy card here
    local enemyCount = 0
    for _, boardCard in ipairs(gm.board[loc]) do
      if boardCard.owner ~= c.owner then
        enemyCount = enemyCount + 1
      end
    end
    c.power = c.power + enemyCount * 2

  elseif c.name == "Midas" then
    -- Set all cards here to 3 power
    for _, boardCard in ipairs(gm.board[loc]) do
      boardCard.power = 3
    end

  elseif c.name == "Hades" then
    -- Gain +2 power for each card in your discard pile
    local pile = me.discardPile or {}
    c.power = c.power + (#pile * 2)

--   elseif c.name == "Ship of Theseus" then
--     -- Add a copy with +1 power to your hand
--     local copy = cloneCard(c)
--     copy.power = copy.power + 1
--     table.insert(me.hand, copy)

--   elseif c.name == "Poseidon" then
--     -- Move away the enemy card with the lowest power here
--     local lowest, idx = math.huge, nil
--     for i, boardCard in ipairs(gm.board[loc]) do
--       if boardCard.owner ~= c.owner and boardCard.power < lowest then
--         lowest = boardCard.power
--         idx = i
--       end
--     end
--     if idx then
--       table.remove(gm.board[loc], idx)
--     end

--   elseif c.name == "Hephaestus" then
--     -- Lower the cost of 2 cards in your hand by 1
--     local n = 0
--     for _, card in ipairs(me.hand) do
--       if n < 2 then
--         card.manaCost = math.max(0, card.manaCost - 1)
--         n = n + 1
--       end
--     end

--   elseif c.name == "Pandora" then
--     -- If no ally cards are here, lower this card’s power by 5
--     local hasAlly = false
--     for _, boardCard in ipairs(gm.board[loc]) do
--       if boardCard.owner == c.owner and boardCard ~= c then
--         hasAlly = true
--         break
--       end
--     end
--     if not hasAlly then
--       c.power = c.power - 5
--     end

--   elseif c.name == "Nyx" then
--     -- Discard your other cards here, add their power to this card
--     local sum = 0
--     local toDiscard = {}
--     for _, boardCard in ipairs(gm.board[loc]) do
--       if boardCard.owner == c.owner and boardCard ~= c then
--         sum = sum + boardCard.power
--         table.insert(toDiscard, boardCard)
--       end
--     end
--     -- remove them from the board and into your discard pile
--     me.discardPile = me.discardPile or {}
--     for _, d in ipairs(toDiscard) do
--       for i, b in ipairs(gm.board[loc]) do
--         if b == d then
--           table.remove(gm.board[loc], i)
--           break
--         end
--       end
--       table.insert(me.discardPile, d)
--     end
--     c.power = c.power + sum
  end
end

return Effects