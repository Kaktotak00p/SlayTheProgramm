-- | Pure JSON asset parsing.
--
-- This module deliberately performs no IO.
module Game.Assets
    ( -- * Parsing
      parseCards
    , parseEnemyTemplates
    , parseAssets
    ) where

import Data.Aeson (eitherDecode)
import qualified Data.ByteString.Lazy as ByteString
import Game.Types (Assets (..), Card, EnemyTemplate)

-- | Parse a JSON array of cards.
parseCards :: ByteString.ByteString -> Either String [Card]
parseCards = eitherDecode

-- | Parse a JSON array of enemy templates.
parseEnemyTemplates :: ByteString.ByteString -> Either String [EnemyTemplate]
parseEnemyTemplates = eitherDecode

-- | Combine separately parsed card and enemy JSON documents into 'Assets'.
parseAssets :: ByteString.ByteString -> ByteString.ByteString -> Either String Assets
parseAssets cardsJson enemiesJson =
    Assets
        <$> parseCards cardsJson
        <*> parseEnemyTemplates enemiesJson
