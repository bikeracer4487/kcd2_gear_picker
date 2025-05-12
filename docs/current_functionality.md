# Current Functionality Documentation

## Overview

The KCD2 Gear Picker mod will use the underlying logic and tooling from the "Helmet Off Dialog" mod but will be completely repurposed for gear optimization. This document describes the original mod's functionality that we'll adapt.

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