The three "regions" of this game:
- Core:
    - Cards:
        - Types:
            - Attack cards, damage the enemy, sometimes also applies an effect
            - Skill cards, apply an effect that diminishes as the turns go on
            - Power cards, gets consumed for combat on use, usually apply an effect that doesnt diminish
            or a lot of stacks of the effect that does diminish
            - Status cards, unplayable cards that have an effect when drawn or left in hand at the end of the turn.
            Usually only added to the draw (not the permanent) deck during an encounter.
            - (Not sure about this one) Curse cards, permanent negative status cards.
        - Their lifecycle:
            - Regular cards, stay in play forever
            - Exhaust cards, single use per combat cards, usually have either powerful attacks or effects
            - Etherial cards, "use it or lose it" cards, get exhausted if they are in hand by the end of the turn
        - What does the card have anyway? (to make a data type)
            - Recipe:
                ```haskell
                data Card = Card
                    { cardName      :: Text
                    , cardCost      :: Cost
                    , cardType      :: CardType
                    , cardLifecycle :: Lifecycle
                    , cardEffects   :: [Effect]
                    }

                data Cost
                    = FixedCost Int
                    | XCost             -- spends all remaining energy
                    | Unplayable        -- status and curse cards

                data CardType
                    = Attack
                    | Skill
                    | Power
                    | Status
                    | Curse

                data Lifecycle
                    = Regular
                    | Exhaust
                    | Ethereal
                ```
            - Design notes:
                - `cardEffects` is an ordered list; effects resolve left to right when the card is played.
                - `Status` and `Curse` are not played normally. Their trigger is in the `Effect` timing.
                - `Lifecycle` is a default. Regular cards can be exhausted by other effects, 
                and Ethereal can be applied at runtime, so per-combat overrides are kept separate from the immutable card definition:
                    ```haskell
                    data CardInstance = CardInstance
                        { instanceCard         :: Card
                        , instanceLifecycle    :: Lifecycle  -- may be overridden
                        , instanceCostOverride :: Maybe Int  -- e.g. from Confused
                        }
                    ```
                - The immutable `Card` (from JSON) and the per-combat `CardInstance` are distinct.
                - Cards are immutable values. Playing, exhausting, or moving a card returns an updated `GameState`; never mutate a `Card` or `CardInstance` in place.
                - The Confused cost override is produced by the draw transition from the `StdGen` in `GameState`.
    
    - Decks:
        - Draw deck, where player draws from. When its contents are viewed they are shuffled, 
        so that the player cant plan around the draw order
        - Discard deck, where cards go after being played, unless they were exhausted
        - General deck, where player can check all of the cards they have.
        - Exhaust deck, where the exhausted cards go.
        - What is a deck anyway?
            - A deck is an immutable ordered collection of cards; the order is meaningful for drawing and discarding.
            - Recipe:
                ```haskell
                newtype Deck = Deck { deckCards :: [CardInstance] }

                data Decks = Decks
                    { drawPile    :: Deck
                    , hand        :: Deck
                    , discardPile :: Deck
                    , exhaustPile :: Deck
                    , generalDeck :: Deck  -- all cards the player owns
                    }
                ```
            - Design notes:
                - `generalDeck` is the single source of truth.
                - The draw pile is shuffled only for display; the real order is kept internal, only the `viewDrawPile` function is exposed (shuffles a copy).
                - Adding a card to the draw/discard pile is a deck operation; exhausting a card moves it to `exhaustPile` instead of `discardPile`.
                - `viewDrawPile :: GameState -> Deck` must use a derived display seed and must not advance the game RNG.

    - Effects:
        - Buffs:
            - Dexterity, how much more block you get from playing a block card, additive. (card block amount + Dex amount)
            - Strength, how much more damage you get from attacking, additive (attack amount + Str amount)
            - Artifact, negate the next debuff, one debuff per stack. 
            Ex: 99 frail applied in one go counts as one debuff, so **all of it** will be negated by an artifact
            - Intangible, all of the damage is reduced to 1, great for big single hit attacks, worse for multihits, stacks are duration
            - Regenerate, at the end of the turn heal the [stack] amount of hp, stacks are duration
        - Debuffs:
            - Frail, block gained from cards is reduced by 25%, stacks are duration
            - Poison, at the start of the next turn lose [stack] amount of hp, stacks are duration
            - Vulnerable, takes 50% more dmg from attacks, stacks are duration
            - Weak, deals 25% less dmg from attacks, stacks are duration
            - Shackled, at the end of the turn loose [stack] amount of Str. Used usually for a single turn Str boost, but considered a debuff
            - Confused, cost of the cards are randomised on draw, between 0-3
            - Note: negative Dex and Str can also be considered debuffs 
        - What is an effect anyway?
            - An effect is a description of a pure state transition plus the moment in the turn when it happens.
            - Recipe:
                ```haskell
                data Timing
                    = OnDraw
                    | OnPlay
                    | OnTurnStart
                    | OnTurnEnd
                    | OnDamageDealt
                    | OnDamageTaken
                    | OnDeath

                data Effect = Effect
                    { effectTiming :: Timing
                    , effectAction :: Action
                    }

                data Action
                    = DealDamage Int
                    | GainBlock Int
                    | Heal Int
                    | ApplyStatus Status
                    | RemoveStatus StatusKind Int
                    | DrawCards Int
                    | AddCard Card
                    | Custom (GameState -> GameState)  -- escape hatch
                ```
            - Buffs and debuffs are statuses with a stack count:
                ```haskell
                data StatusKind
                    = Dexterity | Strength | Artifact | Intangible | Regenerate
                    | Frail | Poison | Vulnerable | Weak | Shackled | Confused

                data Status = Status
                    { statusKind   :: StatusKind
                    , statusStacks :: Int
                    }
                ```
            - Design notes:
                - Prefer the structured `Action` type over a bare `GameState -> GameState`. 
                - The interpreter should be total for every `Action` constructor:
                    ```haskell
                    resolveEffect :: Effect -> GameState -> GameState
                    resolveAction :: Action -> GameState -> GameState
                    ```
                - Negative Dexterity and Strength are simply negative `statusStacks`.
                - Stack semantics are per status:
                    - Dexterity/Strength are additive values.
                    - Artifact is a counter of debuffs to negate; one application of any size consumes one stack.
                    - Intangible, Regenerate, Frail, Poison, Vulnerable, Weak and Shackled use stacks as duration.
                    - Confused is a flag (or one stack) that randomises card costs on draw.
                - Multi-hit attacks are `[DealDamage n, DealDamage n, ...]`.
                - Resolve statuses at explicit points: Poison at turn start, Regenerate at turn end, duration statuses decrement at end of turn.

    - Enemies
        - Something player/s have to beat to get to the next encounter
        - As the run goes on the hp of the enemy grows larger (? base hp + (floor number * modifier))
        - Their attack pattern is a loop of actions, that can consist of some of the following:
            - Simple attack, just does damage
            - Multihit attack, does damage, but with multiple hits
            - Debuff attack, does damage and applies a debuff
            - Buff, applies buff to itself
            - Debuff, applies a big debuff to the player
        - What is an enemy anyway?
            - Recipe:
                ```haskell
                data Enemy = Enemy
                    { enemyName      :: Text
                    , enemyMaxHp     :: Int
                    , enemyCurrentHp :: Int
                    , enemyPattern   :: [EnemyAction]  -- looping list
                    , enemyActionIdx :: Int            -- position in the loop
                    }

                data EnemyAction = EnemyAction
                    { actionDamage  :: Int
                    , actionHits    :: Int      -- 1 for a simple attack
                    , actionEffects :: [Effect]
                    , actionTarget  :: Target
                    }

                data Target
                    = Self
                    | Player
                ```
            - Design notes:
                - The five action kinds are the same record with different fields:
                    - Simple attack: `actionHits = 1`, no effects.
                    - Multihit attack: `actionHits > 1`.
                    - Debuff attack: damage plus an `ApplyStatus` effect targeting `Player`.
                    - Buff: `actionDamage = 0`, effect targeting `Self`.
                    - Debuff: `actionDamage = 0`, effect targeting `Player`.
                - The pattern is a loop: advance `enemyActionIdx` modulo `length enemyPattern`.
                - HP scaling is a spawn-time transformation:
                    ```haskell
                    scaleEnemy :: Int -> Int -> Enemy -> Enemy
                    scaleEnemy floorNo hpModifier e =
                        e { enemyMaxHp = enemyMaxHp e + floorNo * hpModifier }
                    ```
                - Split enemies into `EnemyTemplate` (from JSON) and `EnemyInstance` (during combat), same as `Card`/`CardInstance`.

- UI
    - Brick library. 

- IO (only used during init stage)
    - Parse the JSON with assets into immutable data, then build the initial `GameState` with `newGame :: Assets -> StdGen -> GameState`.
    - No core module imports `System.IO` or other IO modules.
