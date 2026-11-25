-- | Core data types for the game.
--
-- This module deliberately contains only data definitions. All behaviour
-- belongs in "Game.Rules" 
module Game.Types
    ( -- * Cards
      Card (..)
    , CardInstance (..)
    , Cost (..)
    , CardType (..)
    , Lifecycle (..)

      -- * Decks
    , Deck (..)
    , Decks (..)

      -- * Effects and statuses
    , Timing (..)
    , Effect (..)
    , Action (..)
    , Status (..)
    , StatusKind (..)

      -- * Enemies
    , Enemy (..)
    , EnemyTemplate (..)
    , EnemyAction (..)
    , Target (..)

      -- * Player and game state
    , PlayerState (..)
    , GameState (..)
    , Assets (..)
    ) where

import Data.Aeson (FromJSON (..), Value (..), withObject, (.:), (.:?), (.!=))
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import Data.Aeson.Types (Parser)
import Data.Text (Text)
import qualified Data.Text as Text
import System.Random (StdGen)

-- ---------------------------------------------------------------------------
-- Cards
-- ---------------------------------------------------------------------------

-- | The energy cost of a card.
data Cost
    = FixedCost Int
    | XCost
    | Unplayable
    deriving (Show, Eq)

-- | The broad category a card belongs to.
data CardType
    = Attack
    | Skill
    | Power
    | StatusCard
    | CurseCard
    deriving (Show, Eq)

-- | The default lifecycle of a card.
data Lifecycle
    = Regular
    | Exhaust
    | Ethereal
    deriving (Show, Eq)

-- | An immutable card definition, loaded from the game assets.
data Card = Card
    { cardName      :: Text
    , cardCost      :: Cost
    , cardType      :: CardType
    , cardLifecycle :: Lifecycle
    , cardEffects   :: [Effect]
    }

-- | A card as it exists during a single combat.
--
-- The lifecycle and cost may be overridden by combat effects without changing
-- the underlying 'Card' definition.
data CardInstance = CardInstance
    { instanceCard         :: Card
    , instanceLifecycle    :: Lifecycle
    , instanceCostOverride :: Maybe Int
    }

-- ---------------------------------------------------------------------------
-- Decks
-- ---------------------------------------------------------------------------

-- | An ordered collection of cards. Order is meaningful when drawing and
-- discarding.
newtype Deck = Deck
    { deckCards :: [CardInstance]
    }

-- | Every pile that makes up the player's current card collection.
data Decks = Decks
    { drawPile    :: Deck
    , hand        :: Deck
    , discardPile :: Deck
    , exhaustPile :: Deck
    , generalDeck :: Deck
    }

-- ---------------------------------------------------------------------------
-- Effects and statuses
-- ---------------------------------------------------------------------------

-- | The moment in the turn at which an effect resolves.
data Timing
    = OnDraw
    | OnPlay
    | OnTurnStart
    | OnTurnEnd
    | OnDamageDealt
    | OnDamageTaken
    | OnDeath
    deriving (Show, Eq)

-- | A description of a state transition together with its timing.
data Effect = Effect
    { effectTiming :: Timing
    , effectAction :: Action
    }

-- | Structured state-changing operations. Prefer these over 'Custom'.
data Action
    = DealDamage Int
    | GainBlock Int
    | Heal Int
    | ApplyStatus Status
    | RemoveStatus StatusKind Int
    | DrawCards Int
    | AddCard Card
    | Custom (GameState -> GameState)

-- | Buffs and debuffs share a single representation.
data Status = Status
    { statusKind   :: StatusKind
    , statusStacks :: Int
    }
    deriving (Show, Eq)

-- | Every buff and debuff in the game.
data StatusKind
    = Dexterity
    | Strength
    | Artifact
    | Intangible
    | Regenerate
    | Frail
    | Poison
    | Vulnerable
    | Weak
    | Shackled
    | Confused
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Enemies
-- ---------------------------------------------------------------------------

-- | The target of an enemy action.
data Target
    = Self
    | Player
    deriving (Show, Eq)

-- | One step in an enemy's looping action pattern.
data EnemyAction = EnemyAction
    { actionDamage  :: Int
    , actionHits    :: Int
    , actionEffects :: [Effect]
    , actionTarget  :: Target
    }

-- | The immutable definition of an enemy, normally loaded from assets.
data EnemyTemplate = EnemyTemplate
    { enemyTemplateName    :: Text
    , enemyTemplateMaxHp   :: Int
    , enemyTemplatePattern :: [EnemyAction]
    }

-- | An enemy as it exists during a single combat.
data Enemy = Enemy
    { enemyName      :: Text
    , enemyMaxHp     :: Int
    , enemyCurrentHp :: Int
    , enemyBlock     :: Int
    , enemyPattern   :: [EnemyAction]
    , enemyActionIdx :: Int
    , enemyStatuses  :: [Status]
    }

-- ---------------------------------------------------------------------------
-- Player and game state
-- ---------------------------------------------------------------------------

-- | The player's combat state.
data PlayerState = PlayerState
    { playerName      :: Text
    , playerMaxHp     :: Int
    , playerCurrentHp :: Int
    , playerBlock     :: Int
    , playerStatuses  :: [Status]
    }

-- | The complete state of a run.
data GameState = GameState
    { gamePlayer    :: PlayerState
    , gameEnemies   :: [Enemy]
    , gameDecks     :: Decks
    , gameEnergy    :: Int
    , gameMaxEnergy :: Int
    , gameFloor     :: Int
    , gameTurn      :: Int
    , gameGen       :: StdGen
    }

-- | Immutable content loaded before a run starts.
data Assets = Assets
    { assetCards          :: [Card]
    , assetEnemyTemplates :: [EnemyTemplate]
    }

-- ---------------------------------------------------------------------------
-- JSON instances
-- ---------------------------------------------------------------------------
--
-- Assets use a small, explicit JSON schema. Enumerations are represented by
-- lower-case strings, actions are single-key objects, and costs are either a
-- number, "X", or "unplayable".
instance FromJSON Cost where
    parseJSON value@(Number _) = FixedCost <$> parseJSON value
    parseJSON (String text) =
        case Text.unpack (Text.toLower text) of
            "x"          -> pure XCost
            "unplayable" -> pure Unplayable
            other        -> fail ("Unknown card cost: " <> other)
    parseJSON _ =
        fail "Card cost must be a number, \"X\", or \"unplayable\""

instance FromJSON CardType where
    parseJSON = withObjectText "CardType" $ \text ->
        case Text.unpack (Text.toLower text) of
            "attack" -> pure Attack
            "skill"  -> pure Skill
            "power"  -> pure Power
            "status" -> pure StatusCard
            "curse"  -> pure CurseCard
            other    -> fail ("Unknown card type: " <> other)

instance FromJSON Lifecycle where
    parseJSON = withObjectText "Lifecycle" $ \text ->
        case Text.unpack (Text.toLower text) of
            "regular"  -> pure Regular
            "exhaust"  -> pure Exhaust
            "ethereal" -> pure Ethereal
            other      -> fail ("Unknown lifecycle: " <> other)

instance FromJSON Timing where
    parseJSON = withObjectText "Timing" $ \text ->
        case Text.unpack (Text.toLower text) of
            "ondraw"        -> pure OnDraw
            "onplay"        -> pure OnPlay
            "onturnstart"   -> pure OnTurnStart
            "onturnend"     -> pure OnTurnEnd
            "ondamagedealt" -> pure OnDamageDealt
            "ondamagetaken" -> pure OnDamageTaken
            "ondeath"       -> pure OnDeath
            other           -> fail ("Unknown effect timing: " <> other)

instance FromJSON StatusKind where
    parseJSON = withObjectText "StatusKind" $ \text ->
        case Text.unpack (Text.toLower text) of
            "dexterity"  -> pure Dexterity
            "strength"   -> pure Strength
            "artifact"   -> pure Artifact
            "intangible" -> pure Intangible
            "regenerate" -> pure Regenerate
            "frail"      -> pure Frail
            "poison"     -> pure Poison
            "vulnerable" -> pure Vulnerable
            "weak"       -> pure Weak
            "shackled"   -> pure Shackled
            "confused"   -> pure Confused
            other        -> fail ("Unknown status: " <> other)

instance FromJSON Target where
    parseJSON = withObjectText "Target" $ \text ->
        case Text.unpack (Text.toLower text) of
            "self"   -> pure Self
            "player" -> pure Player
            other    -> fail ("Unknown target: " <> other)

instance FromJSON Status where
    parseJSON = withObject "Status" $ \o ->
        Status
            <$> o .: Key.fromString "kind"
            <*> o .: Key.fromString "stacks"

instance FromJSON Action where
    parseJSON = withObject "Action" $ \o ->
        case KeyMap.toList o of
            [(key, value)] ->
                case Key.toString key of
                    "damage"       -> DealDamage <$> parseJSON value
                    "block"        -> GainBlock <$> parseJSON value
                    "heal"         -> Heal <$> parseJSON value
                    "applyStatus"  -> ApplyStatus <$> parseJSON value
                    "removeStatus" -> parseRemoveStatus value
                    "draw"         -> DrawCards <$> parseJSON value
                    "addCard"      -> AddCard <$> parseJSON value
                    other          -> fail ("Unknown action: " <> other)
            _ ->
                fail "An action must be an object with exactly one key"

instance FromJSON Effect where
    parseJSON = withObject "Effect" $ \o ->
        Effect
            <$> (o .:? Key.fromString "timing" .!= OnPlay)
            <*> o .: Key.fromString "action"

instance FromJSON Card where
    parseJSON = withObject "Card" $ \o ->
        Card
            <$> o .: Key.fromString "name"
            <*> (o .:? Key.fromString "cost" .!= FixedCost 1)
            <*> o .: Key.fromString "type"
            <*> (o .:? Key.fromString "lifecycle" .!= Regular)
            <*> (o .:? Key.fromString "effects" .!= [])

instance FromJSON EnemyAction where
    parseJSON = withObject "EnemyAction" $ \o ->
        EnemyAction
            <$> (o .:? Key.fromString "damage" .!= 0)
            <*> (o .:? Key.fromString "hits" .!= 1)
            <*> (o .:? Key.fromString "effects" .!= [])
            <*> (o .:? Key.fromString "target" .!= Player)

instance FromJSON EnemyTemplate where
    parseJSON = withObject "EnemyTemplate" $ \o ->
        EnemyTemplate
            <$> o .: Key.fromString "name"
            <*> o .: Key.fromString "maxHp"
            <*> (o .:? Key.fromString "pattern" .!= [])

instance FromJSON Assets where
    parseJSON = withObject "Assets" $ \o ->
        Assets
            <$> (o .:? Key.fromString "cards" .!= [])
            <*> (o .:? Key.fromString "enemies" .!= [])

-- | Parse an enumeration value that is represented as a JSON string.
withObjectText :: String -> (Text -> Parser a) -> Value -> Parser a
withObjectText name parser value = 
    case value of
        String text -> parser text
        _           -> fail (name <> " must be a JSON string")

parseRemoveStatus :: Value -> Parser Action
parseRemoveStatus = withObject "RemoveStatus" $ \o ->
    RemoveStatus
        <$> o .: Key.fromString "kind"
        <*> o .: Key.fromString "stacks"
