# Project 3 - CCCG (Titanomachy)

## Programming Pattern

1. The Prototype Design Pattern

- Instances are created via a :new() method and metatable so each “class” cleanly encapsulates its state and behavior
- It's helpful to store/add/organize object's properties and behaviors

    ```lua
    ExampleClass = {}

    function ExampleClass:new()
        local example = {}
        local metadata = {__index = ExampleClass}
        setmetatable(example, metadata)
        return example
    end
    ```

2. The State Pattern

- Cards have three states (IDLE, MOUSE_OVER, GRABBED)
    - The Grabber can detect a card’s state to decide whether to pick it up, drag it, or drop it
    - Hover text feature

- Game Phase in gameManager (staging, revealing, game over)
    - Useful for game flow logic

3. The Observer Pattern

- The GameManager issues lifecycle events (onPlay, onReveal, onEndOfTurn) to a central cardEffect.lua module.

## Postmortem

### What went well

- Modular Class Structure
    - splitting cards, board, grabber, manager, and effects into separate files made it easy to navigate and extend

- Card States and Hover Test Display
    - using state attribute and apply it to the hover displaying feature, no need to squeeze the text in a small card

- Reveal Animation Queue
    - my first try doing time stuff in lua

- Clear Function Naming & Comments

### Challenges and Improvements

#### Challenges
- Card Effects
    - Challenge: Each card has its own “When Revealed,” “Ongoing,” or “End of Turn” ability, and many interact with the board, hand, or discard pile in different ways (unfinished)
    - Solution: Pulled all effect logic into a single cardEffect.lua module with onPlay, onReveal, and onEndOfTurn hooks. Every card’s name dispatches to its handler there

- Event/Game Flow System
    - Solution: Introduced a phase field in GameManager (announce -> staging -> revealing -> gameover) and moved timed reveals into GameManager:update(dt), sequencing enemy plays and scoring only once

- Game Balance & AI Behavior

- GameManager Complexity
    - Challenge: All of the above lives in one very large gameManager.lua, making it hard to trace where mana is spent, when cards get moved, or how phases tick over

#### Improvement (waht I'd change next time)
- Better Separation of UI: it is possible to make a new file for UI displaying, instead of putting them all in the love.draw() in main file
- Import Card Data
- Adding a New Scene Manager

### Assets

- No assets, all create by lua system

### Reference

- https://forum.renoise.com/t/how-to-have-tooltips-for-buttons-sliders-text-on-mouse-hover-over-on-lua-gui/73028