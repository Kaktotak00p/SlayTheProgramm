-- | Test suite for the game rules.
module Main (main) where

import Game.Types
import Test.HUnit (Test)
import Test.QuickCheck (Property)

-- | Run all unit and property tests.
main :: IO ()
main = undefined

unitTests :: Test
unitTests = undefined

properties :: [Property]
properties = undefined

-- ---------------------------------------------------------------------------
-- Unit test templates
-- ---------------------------------------------------------------------------

testNewGameStartsAtFullHp :: Test
testNewGameStartsAtFullHp = undefined

testDrawMovesCardsToHand :: Test
testDrawMovesCardsToHand = undefined

testPlayingCardSpendsEnergy :: Test
testPlayingCardSpendsEnergy = undefined

testExhaustMovesCardToExhaustPile :: Test
testExhaustMovesCardToExhaustPile = undefined

testEnemyPatternLoops :: Test
testEnemyPatternLoops = undefined

-- ---------------------------------------------------------------------------
-- Property templates
-- ---------------------------------------------------------------------------

-- | Drawing cards never changes the total number of cards in all piles.
prop_drawPreservesCardCount :: GameState -> Int -> Property
prop_drawPreservesCardCount = undefined

-- | Exhausted cards never appear in the discard pile.
prop_exhaustedCardsStayExhausted :: GameState -> Property
prop_exhaustedCardsStayExhausted = undefined

-- | Viewing the draw pile must not advance the game RNG.
prop_viewDrawPileIsPure :: GameState -> Property
prop_viewDrawPileIsPure = undefined
