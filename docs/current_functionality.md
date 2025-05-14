# Current Functionality Documentation

## Overview

The KCD2 Gear Picker mod has been completely repurposed from the original "Helmet Off Dialog" mod to focus on gear optimization. This document describes the current functionality of the mod after the significant refactoring work.

## Core Functionality

The Gear Picker mod provides the following key functionalities:

1. **Inventory Scanning**: Analyzes all gear items in the player's inventory with detailed stats logging
2. **Gear Optimization**: Optimizes gear selection for three primary scenarios:
   - Maximum Armor/Protection
   - Maximum Stealth
   - Maximum Charisma
3. **Preset Management**: Allows saving and loading custom gear loadouts
4. **Customizable Priorities**: Allows adjusting the weight of different stats in optimization calculations

## Reference Code

The original HelmetOffDialog-related files have been archived to `archived_mod/` for reference. The legacy variant directories have been removed to clean up the codebase and reduce confusion.

## Core Classes

### GearPicker

The main class that initializes the mod and provides access to all other components through factory methods. It loads required scripts and connects the various components.

### Equipment

Manages equipped gear with capabilities to:
- Track which items are equipped in each slot
- Apply complete gear sets with proper layering rules
- Handle unequipping and re-equipping of items

### UnequipGear

Handles the detection and removal of gear with methods:
- `takeOff`: Takes off specific gear types (helmets, chainmail, etc.)
- `unequipIfEquipped`: Verifies if an item is equipped before removing it
- `takeOffAll`: Removes all equipped gear 

### EquippedItem

Provides the critical weight-based detection mechanism to identify equipped items:
1. Measures the player's equipment weight
2. Attempts to unequip an item
3. Measures weight again
4. If weight changed, the item was equipped

Additionally, now provides comprehensive stat collection for items:
- Defensive stats (Stab/Slash/Blunt)
- Stealth stats (Visibility/Conspicuousness/Noise)
- Social stats (Charisma)
- Physical properties (Weight/Condition)

### ItemCategory

Defines item categories and checks if items belong to specific categories across all 16 equipment slots:
- Head gear: Helmet, Cap, Hood, Coif, HeadChainmail
- Torso gear: ChestPlate, Coat, Gambeson, Shirt
- Arm gear: Sleeves
- Hand gear: Gloves
- Leg gear: QuiltedHose
- Foot gear: Shoes, RowelSpurs
- Accessories: Jewelry1, Jewelry2

Also provides material detection to identify cloth, leather, chainmail, and plate items.

### GearScan

New class for comprehensive inventory scanning:
- Scans all items in player inventory
- Collects detailed stats for each item
- Categorizes items by slot and material
- Logs comprehensive analysis of inventory contents

### GearOptimizer

New class for optimization calculations:
- Implements algorithms for armor, stealth, and charisma optimization
- Handles stat calculations with configurable weights
- Ensures layering requirements are respected

### GearSwitcher

New class for managing gear loadouts:
- Handles switching between different gear configurations
- Manages preset saving and loading
- Ensures proper equipping order for layered gear

### Config

Manages mod settings including:
- Optimization priorities and weights
- Feature flags and preferences
- Limit settings for weight and other constraints

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

### Optimization Approach

The mod optimizes gear using a weighted scoring system:

1. **Armor Optimization**:
   - Prioritizes combined defensive stats (stab/slash/blunt)
   - Ensures proper layering (coif before helmet, etc.)
   - Considers weight constraints

2. **Stealth Optimization**:
   - Minimizes noise, visibility, and conspicuousness
   - Prioritizes dark, quiet clothing
   - Balances some protection with stealth properties

3. **Charisma Optimization**:
   - Maximizes charisma value of visible layers
   - Considers cleanliness and condition
   - Selects appropriate noble/high-status items

### Material Detection

Items are categorized by material type through naming pattern analysis:
- **Plate**: Items containing terms like "plate", "cuirass", "bascinet"
- **Chainmail**: Items containing "mail", "chain", "hauberk"
- **Leather**: Items containing "leather", "hide"
- **Cloth**: Items containing "cloth", "linen", "silk", "wool", "gambeson"

### Preset Management

The GearSwitcher class manages custom presets:
- Saves current loadouts with custom names
- Loads presets while respecting layering requirements
- Provides listing and deletion functionality

## User Interface & Controls

### Commands

The mod provides various console commands:

**Core Optimization Commands**:
- `gear_picker__optimize_armor`: Optimize for maximum protection
- `gear_picker__optimize_stealth`: Optimize for maximum stealth
- `gear_picker__optimize_charisma`: Optimize for maximum charisma

**Preset Management**:
- `gear_picker__save_preset [name]`: Save current gear as named preset
- `gear_picker__load_preset [name]`: Load a previously saved preset
- `gear_picker__list_presets`: List all available presets
- `gear_picker__delete_preset [name]`: Delete a named preset

**Configuration**:
- `gear_picker__set_priority_armor [0-100]`: Set armor priority weight
- `gear_picker__set_priority_stealth [0-100]`: Set stealth priority weight
- `gear_picker__set_priority_charisma [0-100]`: Set charisma priority weight
- Various other commands for fine-tuning optimization priorities

### Hotkeys

The mod provides hotkey bindings for quick access:
- **F6**: Scan and log inventory items
- **F7**: Optimize for maximum armor protection
- **F8**: Optimize for maximum stealth
- **F9**: Optimize for maximum charisma

## KCD2 Armor System Requirements

Based on our analysis of KCD2's armor mechanics, the mod implements support for:

### 1. The 16 Armor Slots

KCD2 has 16 distinct armor slots that our system tracks and manages:

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

The implementation respects these critical layering requirements:

- **Head:** A Coif must be equipped before a rigid Helmet
- **Body:** A Gambeson or Arming Doublet must be equipped before a Chest Plate or Mail Hauberk
- **Legs:** Quilted Hose or Padded Chausses must be equipped before Mail Chausses or Plate Leg Armor
- **Accessories:** Some items like Rowel Spurs require appropriate footwear to be equipped

### 3. Key Armor Statistics

The Gear Picker tracks and optimizes for these stat categories:

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