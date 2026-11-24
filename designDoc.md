The three "regions" of this game:
- Core logic: 
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
        - What does the card have anyway?
            - Name
            - Cost
            - Type
            - (List of) effects 

        Regular cards *can* be exhausted by other cards or *can* have etherial applied to them, but such situations should not happen often
    
    - Decks:
        - Draw deck, where player draws from. When its contents are viewed they are shuffled, 
        so that the player cant plan around the draw order
        - Discard deck, where cards go after being played, unless they were exhausted
        - General deck, where player can check all of the cards they have.
        - Exhaust deck, where the exhausted cards go.

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

    - Enemies
        - Something player/s have to beat to get to the next encounter
        - As the run goes on the hp of the enemy grows larger (? base hp + (floor number * modifier))
        - Their attack pattern is a loop of actions, that can consist of some of the following:
            - Simple attack, just does damage
            - Multihit attack, does damage, but with multiple hits
            - Debuff attack, does damage and applies a debuff
            - Buff, applies buff to itself

