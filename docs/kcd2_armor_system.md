# KCD2 Armor System Technical Documentation

This document provides a comprehensive technical breakdown of the Kingdom Come Deliverance 2 (KCD2) armor system based on the game's data files. This information serves as the foundation for the Gear Picker mod implementation.

## Table of Contents

1. [Overview](#overview)
2. [Equipment Slots](#equipment-slots)
3. [Body Layer System](#body-layer-system)
4. [Armor Materials](#armor-materials)
5. [Armor Types](#armor-types) 
6. [Layering Dependencies](#layering-dependencies)
7. [Equipment Parts](#equipment-parts)
8. [Armor Statistics](#armor-statistics)
9. [Implications for Gear Optimization](#implications-for-gear-optimization)

## Overview

KCD2 features a historically accurate medieval armor system with realistic layering requirements and material-based protection characteristics. The system models how medieval armor was actually worn - with padded layers underneath chainmail and plate to cushion impacts and prevent chafing. The game enforces these logical layering requirements through a comprehensive equipment slot system.

## Equipment Slots

The game defines 16 distinct equipment slots, each associated with a specific body part and layer type:

| Slot ID | Slot Name | Body Part | Layer Type | UI Slot |
|---------|-----------|-----------|------------|---------|
| 31 | head_coif | Head | Inner cloth | Coif (1) |
| 32 | head_coif_padded | Head | Inner cloth | Coif (2) |
| 33 | head_cap | Head | Outer cloth | Cap (1) |
| 34 | head_helmet | Head | Plate | Cap (2) |
| 23 | head_hood | Head | Decoration | Hood |
| 22 | collar | Head | Inner cloth | Collar |
| 35 | body_cloth | Torso | Inner cloth | Cloth (1) |
| 36 | body_cloth_padded | Torso | Inner cloth | Cloth (2) |
| 37 | body_chainmail | Torso | Chainmail | Chainmail |
| 38 | body_plate | Torso | Plate | Plate |
| 7 | body_coat | Torso | Decoration | Coat |
| 39 | sleeves | Arms | Plate | Sleeves |
| 40 | leg_trousers | Legs | Inner cloth | Trousers (1) |
| 41 | leg_trousers_padded | Legs | Inner cloth | Trousers (2) |
| 42 | leg_armor | Legs | Plate | Leg Armor |
| 30 | boot | Feet | Leather | Boot |
| 43 | spur | Feet | Decoration | Spur |
| 8 | gloves | Hands | Plate | Gloves |
| 44 | belt | Torso | Decoration | Belt |
| 45 | pouch | Torso | Decoration | Pouch |
| 18 | ring | Hands | Decoration | Ring |
| 19 | necklace | Neck | Decoration | Necklace |

Additionally, KCD2 includes equipment slots for horse gear:

| Slot ID | Slot Name | Body Part | Layer Type | UI Slot |
|---------|-----------|-----------|------------|---------|
| 14 | horse_head | Horse Head | Chainmail | Horse Head |
| 13 | horse_torso | Horse Torso | Inner cloth | Horse Torso |
| 16 | horse_saddle | Horse Torso | Decoration | Horse Saddle |
| 21 | horse_shoe | Horse Feet | Plate | Horse Shoe |

## Body Layer System

KCD2 uses a hierarchical layer system for equipment, with each layer having a specific order:

| Layer ID | Layer Name | Layer Type | Layer Order |
|----------|------------|------------|-------------|
| 0 | body | Body | 0 |
| 8 | underwear | Decoration | 1 |
| 1 | cloth_inner | Cloth | 2 |
| 2 | chainmail_inner | Chainmail | 3 |
| 3 | plate_inner | Plate | 4 |
| 5 | cloth_outer | Cloth | 5 |
| 6 | chainmail_outer | Chainmail | 6 |
| 7 | plate_outer | Plate | 7 |
| 4 | decoration_inner | Decoration | 8 |
| 9 | decoration_outer | Decoration | 9 |

This layering system ensures that items are displayed in the correct order on the character model and affects how stats from different layers interact (especially for stealth-related values).

## Armor Materials

KCD2 defines several primary armor materials, each with distinct characteristics:

| Material | Characteristics | Surface Priority |
|----------|----------------|-----------------|
| mat_fabric | Lightest, quietest, minimal protection | 1.0 (base) |
| mat_leather | Light, relatively quiet, low-medium protection | 1.0-1.5 |
| mat_chainmail | Medium weight, noisy, good slash protection | 1.5-2.5 |
| mat_plate | Heaviest, noisiest, highest protection | 1.5-3.0 |
| mat_bells | Special material, very noisy | - |

The Surface Priority Multiplier affects how visible the material is, with higher values indicating materials that "override" lower-priority materials visually. This directly impacts the Visibility and Conspicuousness stats.

## Armor Types

KCD2 defines 65 specific armor types, grouped by category and material. Each type has a designated material and sometimes a surface priority multiplier. Key armor types include:

### Head Armor
- **Coifs**: CoifCap, CoifSmall, CoifLarge (fabric), CoifMail (chainmail)
- **Helmets**: Cap, KettleHat, SkullCap, BascinetOpen, BascinetVisor (plate)
- **Hood**: Hood, F_Hood, F_HoodOpen (fabric)
- **Collar**: CollarPadded (fabric), CollarMail (chainmail)

### Torso Armor
- **Base Layers**: TunicShort, TunicLong (fabric)
- **Padded Layers**: GambesonShort, GambesonLong, Caftan, Pourpoint (fabric)
- **Chainmail**: MailShort, MailLong (chainmail)
- **Plate/Brigandine**: Cuirass (plate), Brigandine (leather)
- **Outer Garments**: Coat, Waffenrock, Habit (fabric)

### Arm Armor
- **Arm Protection**: ArmBrigandine (leather), ArmPlate (plate)
- **Hand Protection**: Gauntlets (plate), Gloves (leather)

### Leg Armor
- **Base Layers**: HoseJoined, HoseLoose, HoseSeparate (fabric)
- **Padded Layers**: LegsPadded (fabric), LegsChain (chainmail)
- **Outer Protection**: LegsBrigandine (leather), LegsPlate (plate)

### Foot Armor
- **Footwear**: Shoes (leather), BootsAnkle, BootsKnee (leather)
- **Accessories**: Spurs (plate)

### Accessories
- **Personal Items**: Belt, Pouch (leather), Ring, Necklace, Spectacles (special)

## Layering Dependencies

The game enforces several critical layering requirements through explicit dependencies:

1. **Head Protection Dependencies**:
   - Helmets (KettleHat, SkullCap, BascinetOpen, BascinetVisor) REQUIRE a coif (RequiresFilledSlot="head_coif_padded")
   - Caps, hoods and other fabric head coverings CANNOT be worn with coifs (RequiresEmptySlot="head_coif_padded")

2. **Torso Protection Dependencies**:
   - Plate armor (Cuirass, Brigandine) REQUIRES padded underlayer (RequiresFilledSlot="body_cloth_padded")
   - Chainmail (MailShort, MailLong) REQUIRES padded underlayer (RequiresFilledSlot="body_cloth_padded")

3. **Leg Protection Dependencies**:
   - Leg plate armor (LegsBrigandine, LegsPlate) REQUIRES padded leg protection (RequiresFilledSlot="leg_trousers_padded")

4. **Accessory Dependencies**:
   - Spurs REQUIRE boots (RequiresFilledSlot="boot")
   - Horse torso equipment REQUIRES saddle (RequiresFilledSlot="horse_saddle")

These dependencies ensure historically accurate armor combinations and prevent illogical equipment setups.

## Equipment Parts

KCD2 divides the character body into distinct equipment parts:

| Part ID | Name | Description |
|---------|------|-------------|
| 1 | Head | Head and neck area |
| 2 | Torso | Chest, back, and abdomen |
| 3 | Arms | Upper and lower arms |
| 4 | Hands | Hands and wrists |
| 5 | Legs | Upper and lower legs |
| 6 | Feet | Feet and ankles |
| 7-13 | Horse | Various horse body parts |

Each equipment slot is associated with a specific equipment part, ensuring that armor pieces protect the appropriate body areas.

## Armor Statistics

Each armor piece contributes to multiple stat categories:

### Defensive Stats
- **Stab Defense**: Protection against piercing attacks (arrows, spears, daggers)
- **Slash Defense**: Protection against cutting attacks (swords)
- **Blunt Defense**: Protection against impact damage (maces, hammers)

Material effectiveness against damage types:
- Plate: Strong against all damage types
- Chainmail: Strong against slash, weaker against stab and blunt
- Leather: Moderate protection against all types
- Fabric: Minimal protection, primarily serves as a base layer

### Stealth Stats
- **Visibility**: How easily NPCs visually detect the player
  - Affected by: Material type, color, and Surface Priority Multiplier
  - Calculation: Outer layers partially override inner layers
- **Conspicuousness**: How quickly NPCs recognize the player
  - Affected by: Clothing type and quality
  - Calculation: Outer layers have strong influence
- **Noise**: Sound generated during movement
  - Affected by: Material type (plate > chainmail > leather > fabric)
  - Calculation: Cumulative from all equipped items (cannot be hidden)

### Social & Utility Stats
- **Charisma**: Influences dialogue success and NPC disposition
  - Affected by: Visible clothing quality, condition, and cleanliness
- **Weight**: Affects movement speed and stamina consumption
  - Calculation: Cumulative across all equipment
- **Durability/Condition**: Maximum potential robustness and current repair state
- **Dirt & Blood**: Dynamic indicators affecting Charisma and Conspicuousness

## Implications for Gear Optimization

Given the detailed structure of KCD2's armor system, our Gear Picker implementation must:

1. **Respect Layering Requirements**:
   - Always ensure proper underlayers are equipped before adding plate or chainmail
   - Check slot dependencies before suggesting equipment changes
   - Follow the correct equipping sequence (underlayers first, outer layers last)

2. **Consider Material Tradeoffs for Different Optimization Goals**:
   - **Protection**: Prioritize plate > chainmail > leather > fabric
   - **Stealth**: Prioritize fabric > leather > chainmail > plate
   - **Charisma**: Focus on visible (outer) layers with high Surface Priority multipliers

3. **Optimize Based on Slot-Specific Constraints**:
   - Some slots (like boots) have both functional and aesthetic options
   - Certain slots significantly impact specific stats (e.g., chainmail for slash defense)
   - Accessories like spurs should only be considered when dependencies are met

4. **Account for Stats Calculation Methods**:
   - Defensive stats: Focus on cumulative totals
   - Stealth stats: Pay special attention to outer layers
   - Weight: Consider total equipment weight for mobility

This detailed understanding of KCD2's armor system provides the foundation for implementing intelligent gear optimization algorithms that respect the game's complex equipment rules and relationships.