# Current Functionality Documentation

## Overview

The KCD2 Gear Picker mod will use the underlying logic and tooling from the "Helmet Off Dialog" mod but will be completely repurposed for gear optimization. This document describes the original mod's functionality that we'll adapt and the new armor system requirements we need to account for.

## Original Mod Functionality

The original "Helmet Off Dialog" mod was designed to automatically manage equipment during dialogues in Kingdom Come Deliverance 2. Its core functionality identifies and temporarily unequips specific gear when entering conversations, then re-equips it when dialogues end.

Unlike the original mod, the Gear Picker mod will not maintain separate optional modules but instead will integrate all optimization features into a single mod.

### Reference Code

The code in the following directories is kept for reference purposes only and will not be used in our implementation:
- `src/helmet_only/`: Contains code for the helmet-only variant of the original mod
- `src/random/`: Contains code for the random unequipping variant of the original mod
- `src/ranged/`: Contains code for the ranged weapons variant of the original mod

These directories contain variations of the code in `src/main/` and each has its own manifest file because they were designed as separate optional modules for the original mod. Our implementation will focus solely on extending and modifying the code in `src/main/`.

### Core Classes

#### HelmetOffDialog

The main class that initializes the mod and provides access to all other components through factory methods. It loads required scripts and connects the various components.

#### Equipment

Manages equipped gear with capabilities to:
- Track which items have been unequipped
- Remove/equip helmets, coifs, head chainmail, and ranged weapons
- Store references to removed items for re-equipping later

#### UnequipGear

Handles the detection and removal of gear with methods:
- `takeOff`: Takes off specific gear types (helmets, chainmail, etc.)
- `unequipIfEquipped`: Verifies if an item is equipped before removing it

#### EquippedItem

Provides the critical weight-based detection mechanism to identify equipped items:
1. Measures the player's equipment weight
2. Attempts to unequip an item
3. Measures weight again
4. If weight changed, the item was equipped

#### ItemCategory

Defines item categories and checks if items belong to specific categories:
- Helmet: Items containing "kettle", "bascinet", "helmet", or "skullcap"
- HeadChainmail: Items containing "coifmail" or with UI names containing "nm_ca_collar" or "nm_ca_hood"
- Coif: Items containing "coif" or "g_hood_"
- RangedWeapon: Items containing "bow_" or "crossbow"

#### OnTalkEvent

Handles the dialogue event triggers and orchestrates the unequipping sequence:
- Determines if gear should be removed based on settings and context
- Sequentially removes helmet, chainmail, coif, and ranged weapons as appropriate
- Sets up event handlers for re-equipping when dialogue ends

#### TalkEndedEvent

Listens for dialogue end events and triggers re-equipping of items.

#### Config

Manages mod settings including:
- Ranged mode (remove ranged weapons)
- Helmet-only mode (only remove helmets)
- Random mode (randomly remove gear)
- Enable/disable the entire mod

## Technical Implementation Details

### Equipment Detection Technique

The mod uses an innovative approach to identify equipped items since the game doesn't provide a direct API:

1. When checking if an item is equipped, the mod:
   - Records the player's current equipment weight
   - Temporarily unequips the item
   - Checks if the equipment weight changed
   - If weight changed, the item was equipped

2. The detection happens in `EquippedItem.isEquipped()` using weight comparison:
   ```lua
   local isEquipped = tostring(oldStats.equippedWeight) ~= tostring(newStats.equippedWeight)
   ```

### Event Handling

The mod hooks into the game's dialogue system:
- `HelmetOffDialog_Listeners.lua` sets up event listeners for dialogue start events
- When player enters dialogue, the mod triggers the item removal process
- When dialogue ends, items are re-equipped

### Item Categories

Items are categorized by pattern matching on item names/IDs. The current categories are:
- Helmets (full protection headgear)
- Head chainmail (mail protection for the head)
- Coifs (cloth head coverings)
- Ranged weapons (bows and crossbows)

## KCD2 Armor System Requirements

Based on our analysis of KCD2's armor mechanics, we need to incorporate the following into our implementation:

### 1. The 16 Armor Slots

KCD2 has 16 distinct armor slots that our system must track and manage:

1. **Helmet:** Primary head protection (e.g., Bascinet, Kettle Hat)
2. **Cap:** Worn under helmets or as standalone headwear
3. **Hood:** Outer head/shoulder covering (affects appearance & stealth)
4. **Coif:** Padded or mail head/neck protection
5. **Neck Guard:** Additional neck protection (e.g., Gorget, Aventail)
6. **Chest Plate:** Rigid torso protection (e.g., Cuirass)
7. **Coat:** Outer torso garment, worn over other layers
8. **Gambeson:** Essential padded torso armor, worn under mail/plate
9. **Shirt:** Basic undergarment
10. **Sleeves:** Arm protection, sometimes separate components
11. **Gloves:** Hand protection (e.g., Gauntlets, Leather Gloves)
12. **Quilted Hose:** Padded legwear, worn under mail/plate leg armor
13. **Shoes:** Basic footwear, required for other foot additions
14. **Rowel Spurs:** Accessories for riding, attached to shoes/boots
15. **Jewelry (Slot 1):** Rings, necklaces (affect Charisma)
16. **Jewelry (Slot 2):** Second accessory slot

### 2. Mandatory Layering Dependencies

Our implementation must respect these critical layering requirements:

- **Head:** A Coif must be equipped before a rigid Helmet
- **Body:** A Gambeson or Arming Doublet must be equipped before a Chest Plate or Mail Hauberk
- **Legs:** Quilted Hose or Padded Chausses must be equipped before Mail Chausses or Plate Leg Armor
- **Accessories:** Some items like Rowel Spurs require appropriate footwear to be equipped

### 3. Key Armor Statistics

The Gear Picker needs to track and optimize for these stat categories:

**Defensive Stats:**
- **Stab Defense:** Protection against piercing attacks
- **Slash Defense:** Protection against cutting attacks
- **Blunt Defense:** Protection against impact forces

**Stealth Stats:**
- **Visibility:** How easily Henry is visually detected (lower is better)
- **Conspicuousness:** How much Henry stands out or attracts attention
- **Noise:** Sound generated during movement (critical for stealth)

**Social & Utility Stats:**
- **Charisma:** Influences dialogue checks and NPC disposition
- **Weight:** Impacts encumbrance, movement speed, and stamina consumption
- **Condition:** Current state of repair (affects effectiveness and appearance)
- **Dirt & Blood:** Cleanliness affects Charisma and potentially Conspicuousness

### 4. Stat Calculation Methods

The system must properly implement how KCD2 calculates different stats:

- **Visibility & Conspicuousness:** Primarily driven by outermost layers (outer layer dominance)
- **Noise:** Cumulative from all equipped items (can't be muffled by outer layers)
- **Charisma:** Influenced by visible gear, condition, and cleanliness
- **Protection:** Cumulative across all armor pieces

### 5. Material-Based Considerations

The system must recognize and optimize for material-specific properties:

- **Cloth/Padded:** Very lightweight, quiet, minimal protection
- **Leather:** Moderate weight, relatively quiet, low-medium protection
- **Chainmail:** Medium weight, noisy, good protection against slashing
- **Plate:** Very heavy, very noisy, highest protection

### 6. Optimization Profiles

The mod will implement three primary optimization targets that mirror KCD2's preset system:

1. **Maximum Armor/Protection:** Prioritizing defensive stats with weighted balance
2. **Maximum Stealth:** Minimizing noise, visibility, and conspicuousness
3. **Maximum Charisma:** Optimizing appearance for social interactions

## KCD2 Game Data Structure

Analysis of the game's data files reveals important information about how equipment and armor are structured in KCD2:

### Equipment Parts

KCD2 defines the following equipment parts (`equipment_part.tbl`):
- Head related: `head`, `neck`, `face`, `beard`
- Body related: `torso`, `arms`, `hands`, `legs`, `feet`, `waist`, `belt`
- Accessories: `dog_fur`, `dog_eyes`, etc.

### Body Parts and Subparts

The game divides the body into main parts (`body_part.tbl`) and more specific subparts (`body_subpart.tbl`):

**Main Parts:**
- `head`, `torso`, `arm_left`, `arm_right`, `leg_left`, `leg_right`

**Subparts include:**
- Head: `head_up`, `head_back`, `head_sides`, `head_face`, `head_neck`, `head_necklace`, `head_beard`
- Body: `body_front_up`, `body_back_up`, `body_side`, `body_front_down`, `body_back_down`, `body_belt`, `body_pouch`, `body_scabbard`
- Arms: `arm_left_shoulder_front`, `arm_left_upper_front`, `arm_left_forearm_front`, etc.
- Hands: `hand_left`, `hand_right`, `hand_ring`
- Legs: `leg_left_upper_front`, `leg_left_lower_front`, `foot_left_boots`, etc.

### Layering System

The game uses a sophisticated layering system (`body_layer.tbl`) with these specific layers:
- `body`: Base layer
- `cloth_inner`, `chainmail_inner`, `plate_inner`, `decoration_inner`: Inner equipment layers
- `cloth_outer`, `chainmail_outer`, `plate_outer`, `decoration_outer`: Outer equipment layers
- `underwear`: Base clothing layer

### Armor Archetypes

KCD2 categorizes armor into detailed archetypes (`armor_archetype.tbl`) that indicate specific armor configurations:

**Head Gear:**
- `HeadClothCap`, `HeadChainCap`, `HeadPlateHatSmall`, `HeadPlateHelmOpen`, `HeadPlateHelmFull`
- Variants with collars: `HeadPlateHelmOpen_collar`, `HeadPlateHelmFull_collar`
- Hood variations: `HoodOn`, `HoodDown`

**Body Armor:**
- Plate variations: `BodyPlateCuirassFullLong`, `BodyPlateCuirassFullShort`, etc.
- Chain variations: `BodyChainVestShort`, `BodyChainShirt_longSleeves`, etc.
- Cloth variations: `BodyClothShirt_noSleeves`, `BodyClothShirtLong_shortSleeves`, etc.

**Arm Protection:**
- `ArmsPlateShoulderGuards`, `ArmsPlateFullGuardsLong`, `ArmsPlateBackGuardsShort`, etc.

**Leg Protection:**
- `LegsClothTrousersLong`, `LegsPlateProtsUpperFront`, `LegsPlateProtsLongFull_withFeet`, etc.

### Armor Types

The game classifies armor into specific types (`armor_type.tbl`) such as:
- `CoifCap`, `CoifSmall`, `CoifLarge`, `CoifMail`
- `Cap`, `KettleHat`, `SkullCap`, `BascinetOpen`, `BascinetVisor`
- `TunicShort`, `TunicLong`, `GambesonShort`, `GambesonLong`
- `MailShort`, `MailLong`, `Cuirass`, `Brigandine`
- Footwear: `Shoes`, `BootsAnkle`, `BootsKnee`
- Accessories: `Spurs`, `Ring`, `Belt`, `Pouch`

### Attachment System

Equipment items use specific attachment slots (`attachment_slot.tbl`) including:
- Generic: `slot1` through `slot6`
- Weapons: `LeftWeapon`, `RightWeapon`
- Ranged: `quiver`, `bow`, `crossbow`, `shield`

These details provide crucial insights into how the game structures equipment, which will be essential for implementing accurate gear optimization in our mod.