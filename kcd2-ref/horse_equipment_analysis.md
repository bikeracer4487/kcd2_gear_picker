# Horse Equipment Analysis

## Location of Horse Equipment Data

The horse equipment data is located in:
- `/Users/douglas.mason/Documents/GitHub/kcd2_gear_picker/kcd2-ref/Libs/Tables/item/item__horse.xml`

## Structure of Horse Item Data

Horse items in KCD2 are stored as `<Armor>` elements with the following attributes:

### Defense Attributes (Protection for the Horse)
- `DefenseStab` - Protection against stab damage
- `DefenseSlash` - Protection against slash damage  
- `DefenseSmash` - Protection against smash/blunt damage

### Other Attributes
- `StrReq` - Strength requirement (always 0 for horse items)
- `Noise` - Noise generated (always 0 for horse items)
- `MaxStatus` - Maximum durability of the item
- `Visibility` - Visual detectability (0.1 for most items, 1 for horseshoes/harnesses)
- `Conspicuousness` - How conspicuous the item is (always 0 for horse items)
- `Charisma` - Charisma modifier (always 0 for horse items)
- `RPGBuffWeight` - Weight factor for RPG buffs (0.2 to 1.0)
- `SocialClassId` - Social class of the item
- `WealthLevel` - Wealth level indicator
- `MaxQuality` - Maximum quality level (1-4)
- `Weight` - Item weight in inventory
- `Price` - Base price of the item
- `FadeCoef` - Fade coefficient
- `VisibilityCoef` - Visibility coefficient

## Horse-Specific Statistics

Based on the analysis, horse equipment in KCD2 does NOT directly modify horse-specific stats like speed, stamina, or courage through item attributes. Instead:

1. **Horse equipment provides defensive protection** - The DefenseStab, DefenseSlash, and DefenseSmash values protect the horse from damage in combat.

2. **RPGBuffWeight** - This appears to be the key attribute that might affect horse performance. Different items have different buff weights (0.2 to 1.0), suggesting they may apply different levels of buffs.

3. **Horse performance modifiers** are handled through the buff system, not direct item attributes. The game has buffs like "player_horse_stamina_modifier" that are applied through other means.

4. **Visibility, Conspicuousness, and Charisma** - These are always 0 for horse equipment except for Visibility on horseshoes/harnesses (set to 1). These stats appear to be placeholders and don't actually affect gameplay for horse items.

## Item Categories

Horse equipment falls into several categories:
- **Saddles** (Basic, Noble, War, East)
- **Caparisons** (decorative horse coverings)
- **Padded Caparisons** (armored horse coverings)
- **Chanfrons** (horse head armor)
- **Harnesses** (BasicHarness)
- **Bridles** (Basic, Noble, East, Nomad)
- **Horseshoes** (Military, Nomad, Racing, Farmer, Noble)

## Key Findings

1. Horse equipment statistics are primarily defensive, not performance-based
2. The Visibility, Conspicuousness, and Charisma values in the CSV were incorrectly included - these don't affect horses
3. Horse speed, stamina, and courage are modified through the game's buff system, not item attributes
4. The most important stats for horse equipment are:
   - Defense values (Stab/Slash/Smash)
   - Durability (MaxStatus)
   - Price and Weight
   - RPGBuffWeight (which may influence buff application)

## Recommendations

The CSV files should be updated to remove misleading stats (Visibility, Conspicuousness, Charisma) and focus on the actual defensive and durability statistics that horse equipment provides.