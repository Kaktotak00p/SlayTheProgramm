-- | Filesystem access for loading game assets.
--
-- IO is confined to initialisation. Parsing itself lives in "Game.Assets".
module AssetLoader
    ( defaultCardsPath
    , defaultEnemiesPath
    , loadCards
    , loadEnemyTemplates
    , loadAssets
    ) where

import Data.Aeson (eitherDecodeFileStrict')
import Game.Types (Assets (..), Card, EnemyTemplate)

-- | Default location of the example card definitions.
defaultCardsPath :: FilePath
defaultCardsPath = "assets/cards.json"

-- | Default location of the example enemy definitions.
defaultEnemiesPath :: FilePath
defaultEnemiesPath = "assets/enemies.json"

-- | Read and parse a card file.
loadCards :: FilePath -> IO (Either String [Card])
loadCards = eitherDecodeFileStrict'

-- | Read and parse an enemy-template file.
loadEnemyTemplates :: FilePath -> IO (Either String [EnemyTemplate])
loadEnemyTemplates = eitherDecodeFileStrict'

-- | Read and combine the card and enemy asset files.
loadAssets :: FilePath -> FilePath -> IO (Either String Assets)
loadAssets cardsPath enemiesPath = do
    cardsResult <- loadCards cardsPath
    enemiesResult <- loadEnemyTemplates enemiesPath
    pure (Assets <$> cardsResult <*> enemiesResult)
