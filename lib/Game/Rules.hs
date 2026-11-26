-- | State transitions for the game.
module Game.Rules
    ( -- * Setup
      newGame
    , newPlayer
    , newDeck
    , cardToInstance
    , spawnEnemy
    , scaleEnemy

      -- * Deck operations
    , viewDrawPile
    , shuffleDeck
    , drawCards
    , discardHand
    , moveToDiscard
    , moveToExhaust

      -- * Turn flow
    , startTurn
    , endTurn
    , playCard

      -- * Enemy flow
    , advanceEnemyAction
    , enemyTakeTurn

      -- * Effect resolution
    , resolveTiming
    , resolveEffect
    , resolveAction
    , dealDamage
    , gainBlock
    , heal
    , applyStatus
    , removeStatus
    , hasStatus
    , statusStacksFor

      -- * Queries
    , isCombatOver
    , isRunOver
    ) where

import Data.Text (Text)
import Game.Types
import System.Random (StdGen)

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------

-- | Build the initial state for a new run from immutable assets and a seed.
newGame :: Assets -> StdGen -> GameState
newGame = undefined

-- | Create a player at full health.
newPlayer :: Text -> Int -> PlayerState
newPlayer = undefined

-- | Wrap an ordered list of cards in a deck.
newDeck :: [CardInstance] -> Deck
newDeck = undefined

-- | Promote an immutable card definition to a per-combat instance.
cardToInstance :: Card -> CardInstance
cardToInstance = undefined

-- | Instantiate an enemy template, including any floor-based HP scaling.
spawnEnemy :: Int -> Int -> EnemyTemplate -> Enemy
spawnEnemy = undefined

-- | Apply floor-based HP scaling to an existing enemy.
scaleEnemy :: Int -> Int -> Enemy -> Enemy
scaleEnemy = undefined

-- ---------------------------------------------------------------------------
-- Deck operations
-- ---------------------------------------------------------------------------

-- | Return a shuffled copy of the draw pile for display only.
--
-- This must not advance the game RNG or modify the real draw order.
viewDrawPile :: GameState -> Deck
viewDrawPile = undefined

-- | Shuffle a deck using the supplied generator.
shuffleDeck :: StdGen -> Deck -> Deck
shuffleDeck = undefined

-- | Draw the given number of cards into the hand, reshuffling the discard pile
-- when the draw pile is empty.
drawCards :: Int -> GameState -> GameState
drawCards = undefined

-- | Move the whole hand to the discard pile.
discardHand :: GameState -> GameState
discardHand = undefined

-- | Move a card to the discard pile.
moveToDiscard :: CardInstance -> Decks -> Decks
moveToDiscard = undefined

-- | Move a card to the exhaust pile.
moveToExhaust :: CardInstance -> Decks -> Decks
moveToExhaust = undefined

-- ---------------------------------------------------------------------------
-- Turn flow
-- ---------------------------------------------------------------------------

-- | Apply turn-start effects, reset energy, and draw a new hand.
startTurn :: GameState -> GameState
startTurn = undefined

-- | Discard the hand, apply turn-end effects, and advance enemy intents.
endTurn :: GameState -> GameState
endTurn = undefined

-- | Play the card at the given hand index if it is playable and affordable.
playCard :: Int -> GameState -> GameState
playCard = undefined

-- ---------------------------------------------------------------------------
-- Enemy flow
-- ---------------------------------------------------------------------------

-- | Advance an enemy to the next action in its looping pattern.
advanceEnemyAction :: Enemy -> Enemy
advanceEnemyAction = undefined

-- | Execute the current action of every living enemy.
enemyTakeTurn :: GameState -> GameState
enemyTakeTurn = undefined

-- ---------------------------------------------------------------------------
-- Effect resolution
-- ---------------------------------------------------------------------------

-- | Resolve every effect whose timing matches the given moment.
resolveTiming :: Timing -> GameState -> GameState
resolveTiming = undefined

-- | Resolve a single effect.
resolveEffect :: Effect -> GameState -> GameState
resolveEffect = undefined

-- | Resolve a single structured action.
resolveAction :: Action -> GameState -> GameState
resolveAction = undefined

-- | Deal damage after applying the relevant buffs, debuffs, and block.
dealDamage :: Int -> GameState -> GameState
dealDamage = undefined

-- | Gain block after applying Dexterity and Frail.
gainBlock :: Int -> GameState -> GameState
gainBlock = undefined

-- | Restore health without exceeding the player's maximum.
heal :: Int -> GameState -> GameState
heal = undefined

-- | Add or stack a status.
applyStatus :: Status -> GameState -> GameState
applyStatus = undefined

-- | Remove the given number of stacks of a status.
removeStatus :: StatusKind -> Int -> GameState -> GameState
removeStatus = undefined

-- | Whether a status is present on the player or any enemy.
hasStatus :: StatusKind -> GameState -> Bool
hasStatus = undefined

-- | Current stack count of a status, or zero when absent.
statusStacksFor :: StatusKind -> [Status] -> Int
statusStacksFor = undefined

-- ---------------------------------------------------------------------------
-- Queries
-- ---------------------------------------------------------------------------

-- | Whether the current combat has been won or lost.
isCombatOver :: GameState -> Bool
isCombatOver = undefined

-- | Whether the player has died and the run is over.
isRunOver :: GameState -> Bool
isRunOver = undefined
