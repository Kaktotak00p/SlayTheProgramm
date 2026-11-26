-- | Executable entry point.
--
-- IO is only performed during initialisation: assets are loaded here and then
-- the rest of the program operates on immutable game state.
module Main (main) where

import AssetLoader (defaultCardsPath, defaultEnemiesPath, loadAssets)
import Game.Rules (newGame)
import Game.Types (Assets, GameState)
import System.Random (mkStdGen)

-- | Load the assets and launch the game.
main :: IO ()
main = do
    result <- loadAssets defaultCardsPath defaultEnemiesPath
    case result of
        Left err -> ioError (userError ("Could not load assets: " <> err))
        Right assets -> launchGame assets

-- | Start the UI with the loaded assets.
launchGame :: Assets -> IO ()
launchGame assets = initialGameState assets `seq` undefined

-- | Initial state for a new run.
initialGameState :: Assets -> GameState
initialGameState assets = newGame assets (mkStdGen 0)
