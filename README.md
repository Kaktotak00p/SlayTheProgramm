# Slay the Programm

A deck-building roguelike written in Haskell, inspired by
*Slay the Spire*. The project models the core parts of a run: cards, decks,
effects, statuses, enemies, turn flow, and the immutable game state.

The UI is planned to use [Brick](https://github.com/jtdaugherty/brick). 

## Project layout

```text
.
StP.cabal            -- package, library, executable, and test configuration
designDoc.md         -- game design notes
assets/
- cards.json       -- card definitions
- enemies.json     -- enemy definitions
lib/
- Game/
  - Types.hs     -- core datatypes and JSON instances
  - Rules.hs     -- game rules and function templates
  - Assets.hs    -- pure JSON parsing and encoding
src/
- Main.hs          -- executable entry point
- AssetLoader.hs   -- file IO for loading assets
test/
- GameTest.hs      -- HUnit and QuickCheck tests
```

## Requirements

- GHC 9.6.7 (the version this project is currently built with)
- Cabal 3.12 or newer
- Network access on the first build so Cabal can download dependencies

The library depends on `base`, `aeson`, `bytestring`, `random`, and `text`.
The executable also uses `brick`; the test suite uses `HUnit` and `QuickCheck`.
Cabal installs these automatically.

---

## How to build the project

Clone the repository, enter the project directory, and build everything:

```bash
cabal update
cabal build all
```

Useful commands:

```bash
# Build only the library
cabal build lib:Slay-The-Programm

# Build only the executable
cabal build exe:game

# Compile the test suite
cabal build test:tests

# Open a REPL with the game library loaded
cabal repl lib:Slay-The-Programm
```
The project and tests can be ran with:

```bash
cabal run game
cabal test
```

## Asset files

Assets are loaded from JSON at start-up and parsed into immutable
`Game.Types` values.

- `assets/cards.json` contains a JSON array of cards.
- `assets/enemies.json` contains a JSON array of enemy templates.

A card uses this shape:

```json
{
  "name": "Strike",
  "cost": 1,
  "type": "attack",
  "lifecycle": "regular",
  "effects": [
    {
      "timing": "onPlay",
      "action": { "damage": 6 }
    }
  ]
}
```

An enemy template uses this shape:

```json
{
  "name": "Jaw Worm",
  "maxHp": 44,
  "pattern": [
    {
      "damage": 11,
      "hits": 1,
      "effects": [],
      "target": "player"
    }
  ]
}
```

Supported JSON values:

- `cost`: an integer, `"X"`, or `"unplayable"`
- `type`: `"attack"`, `"skill"`, `"power"`, `"status"`, or `"curse"`
- `lifecycle`: `"regular"`, `"exhaust"`, or `"ethereal"`
- `timing`: `"onDraw"`, `"onPlay"`, `"onTurnStart"`, `"onTurnEnd"`,
  `"onDamageDealt"`, `"onDamageTaken"`, or `"onDeath"`
- `action`: a single-key object such as `{"damage": 6}`, `{"block": 5}`,
  `{"heal": 4}`, `{"draw": 2}`, or
  `{"applyStatus": {"kind": "vulnerable", "stacks": 2}}`
- `target`: `"self"` or `"player"`
