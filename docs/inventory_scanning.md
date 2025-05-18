# Inventory Scanning Technical Documentation

This document outlines the inventory scanning approach used in the Gear Picker mod to identify and collect information about items in the player's inventory in Kingdom Come Deliverance 2.

## Core Principles

1. **Focus on Stats Collection**: The primary purpose of inventory scanning is to collect comprehensive stats for all equippable gear.
2. **No Simulated Items**: We never create simulated items - we only work with real gear that exists in the inventory.
3. **Equipped State Irrelevant**: We don't track or care about whether items are equipped or not - this mod is about analyzing ALL available gear.
4. **Only Armor/Clothing**: We filter out weapons, consumables, and other non-armor items, focusing solely on equippable clothing/armor.

## Inventory Access Approaches

The inventory scanner implements multiple approaches to access inventory items, in order to handle potential API limitations:

1. **Primary Method:** `inventory:GetInventoryTable()`
   - This is used first and appears more reliable
   - Returns a comprehensive list of all items in the player's inventory

2. **Fallback Method:** Direct index access
   - If GetInventoryTable fails, we iterate through inventory slots by index
   - Uses `inventory:GetCount()` to determine inventory size
   - Then iterates through each index with `inventory:GetItem(i)`

## Item Filtering

We filter inventory items to focus only on equippable armor/clothing by:

1. Using the `CanEquip()` method to check if the item is equippable
2. Filtering out weapons by name pattern matching
3. Filtering out consumables and other non-gear items
4. Keeping only items that could potentially be equipped as armor/clothing

## Comprehensive Stat Collection

For each identified gear item, we collect all available stats:

### Physical Stats
- Weight
- Condition and maximum condition

### Defense Stats
- Stab defense
- Slash defense
- Blunt defense

### Stealth Stats
- Noise
- Visibility 
- Conspicuousness

### Social Stats
- Charisma

### Equipment Information
- Equipment slot
- Material type

## Item Categorization

Items are categorized in two ways:

1. **Slot Determination**
   - Uses name patterns and item properties to determine the equipment slot
   - Maps items to slots like "head", "torso_outer", "hands", etc.

2. **Material Detection**
   - First attempts to determine material from name patterns
   - When name-based detection isn't conclusive, uses heuristic rules based on stat patterns:
   ```lua
   -- Examples of stat-based material determination
   if stats.slashDefense > stats.stabDefense * 1.5 and stats.slashDefense > stats.bluntDefense * 1.5 then
       stats.material = "chainmail"  -- Chainmail is much better against slash
   elseif stats.stabDefense > 15 and stats.slashDefense > 15 and stats.bluntDefense > 15 then
       stats.material = "plate"  -- Plate has high defense across all types
   elseif stats.stabDefense < 5 and stats.slashDefense < 5 and stats.charisma > 0 then
       stats.material = "cloth"  -- Cloth has low defense but often has charisma
   elseif stats.stabDefense > 3 and stats.slashDefense > 3 and stats.bluntDefense < 10 then
       stats.material = "leather"  -- Leather has moderate defense
   end
   ```

## Error Tolerance

All API calls are wrapped in pcall to ensure that errors don't break the scanning process:

```lua
pcall(function()
    if item.GetWeight then stats.weight = item:GetWeight() end
    if item.GetCondition then stats.condition = item:GetCondition() end
    if item.GetMaxCondition then stats.maxCondition = item:GetMaxCondition() end
end)
```

This allows the scanner to collect as much information as possible even if some methods fail.

## Implementation Guidelines

When implementing or modifying the inventory scanning functionality, follow these key principles:

1. **NEVER create simulated or fake items** - only work with actual items from the inventory
2. **NEVER use weight-based detection** - this is unnecessary and complicates the code
3. **NEVER track equipped state** - we only care about the existence and stats of gear
4. **ALWAYS use pcall** for error tolerance around API calls
5. **ALWAYS implement multiple inventory access methods** for API robustness

## Logging Strategy

The inventory scanner uses a clear logging strategy to help with debugging:

1. Progress indicators for scanning large inventories
2. Detailed stats logging for each identified gear item
3. Summary information with counts of processed items and found gear
4. Color-coded logs for different types of information

This combination of approaches ensures that the inventory scanner can reliably collect all the item data needed for the gear optimization algorithms to function properly.