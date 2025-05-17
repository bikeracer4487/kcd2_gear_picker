# Inventory Scanning Technical Documentation

This document outlines the inventory scanning approach used in the Gear Picker mod to identify and collect information about items in the player's inventory in Kingdom Come Deliverance 2.

## Inventory Access Challenges

KCD2's modding API has certain limitations when it comes to accessing the player's inventory:

1. Some API methods like `inventory:GetItems()` can be unreliable on certain game versions
2. Item attributes and methods may not be consistently available across all game versions
3. Different game patches may change or update the API

## Multi-Method Inventory Access

Our implementation uses multiple methods to reliably access the player's inventory:

1. **Primary Method:** `inventory:GetInventoryTable()`
   - This is used in the original Helmet Off Dialog mod and appears more reliable
   - Returns a comprehensive list of all items in the player's inventory

2. **Fallback Method:** `inventory:GetItems()`
   - Standard API method that's used if GetInventoryTable isn't available
   - Generally works but may be less reliable in some game versions

## Item Classification

For each item in the inventory, we determine if it's potential gear by:

1. Using the ItemCategory service to check if the item is armor, clothing, jewelry, or weapon
2. Checking if the item can be equipped using the `CanEquip()` method
3. Examining the item name to filter out non-gear items like consumables, arrows, and misc items

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
- Equipped status
- Material type

## Item Material Detection

When item material isn't directly available, we use heuristic rules based on the item's stats:

```lua
-- Try to determine material based on stats pattern
if stats.slashDefense > stats.stabDefense * 1.5 and stats.slashDefense > stats.bluntDefense * 1.5 then
    stats.material = "chainmail"  -- Chainmail is much better against slash
elseif stats.stabDefense > 20 and stats.slashDefense > 20 and stats.bluntDefense > 20 then
    stats.material = "plate"  -- Plate has high defense across all types
elseif stats.stabDefense < 10 and stats.slashDefense < 10 and stats.charisma > 0 then
    stats.material = "cloth"  -- Cloth has low defense but often has charisma
elseif stats.stabDefense > 5 and stats.slashDefense > 5 and stats.bluntDefense < 15 then
    stats.material = "leather"  -- Leather has moderate defense
end
```

## Error Tolerance

All API calls are wrapped in pcall to ensure that errors don't break the scanning process:

```lua
pcall(function()
    if item.GetWeight then stats.weight = item:GetWeight() 
    elseif item.weight then stats.weight = item.weight end
    
    -- More stat collection...
end)
```

This allows the scanner to collect as much information as possible even if some methods fail.

## Equipped Items Detection

We can identify equipped items through multiple approaches:

1. Using the direct `IsEquipped()` method if available
2. Checking if the item has a non-empty equipped slot via `GetEquippedSlot()`

## Performance Considerations

- We process items one by one with small delays to prevent freezing the game
- We log progress only occasionally to avoid console spam
- Error handling ensures the process keeps going even if some item methods fail

## Implementation Strategy

The simplified inventory scanning approach follows this process:

1. Get all inventory items through the most reliable available method
2. Filter for potential gear items (armor, weapons, clothing, etc.)
3. For each gear item, collect all available stats and information
4. Track equipped items separately for quick access
5. Return the complete inventory data for optimization decision-making

This streamlined approach focuses on gathering comprehensive item information without needing to determine what's currently equipped through complex methods like weight-based detection.